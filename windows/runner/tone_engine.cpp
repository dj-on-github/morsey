#include "tone_engine.h"

#include <audioclient.h>
#include <flutter/standard_method_codec.h>
#include <ksmedia.h>
#include <mmdeviceapi.h>
#include <mmreg.h>

#include <algorithm>
#include <cmath>
#include <cstdint>

namespace {

constexpr double kTwoPi = 6.283185307179586476925286766559;
// Attack/decay ramp used to avoid clicks, in seconds.
constexpr double kRampSeconds = 0.006;

// Reads a numeric value from a Flutter method-call argument map. Accepts either
// a double or an int encoding. Returns |fallback| if the key is missing.
double ReadNumber(const flutter::EncodableMap* args, const char* key,
                  double fallback) {
  if (args == nullptr) {
    return fallback;
  }
  auto it = args->find(flutter::EncodableValue(std::string(key)));
  if (it == args->end()) {
    return fallback;
  }
  if (const auto* d = std::get_if<double>(&it->second)) {
    return *d;
  }
  if (const auto* i = std::get_if<int32_t>(&it->second)) {
    return static_cast<double>(*i);
  }
  if (const auto* i64 = std::get_if<int64_t>(&it->second)) {
    return static_cast<double>(*i64);
  }
  return fallback;
}

}  // namespace

ToneEngine::~ToneEngine() {
  Stop();
  if (start_event_ != nullptr) {
    CloseHandle(start_event_);
    start_event_ = nullptr;
  }
}

void ToneEngine::RegisterWithMessenger(flutter::BinaryMessenger* messenger) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, kMethodChannelName,
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        const std::string& method = call.method_name();
        const auto* args =
            std::get_if<flutter::EncodableMap>(call.arguments());

        if (method == "start") {
          result->Success(flutter::EncodableValue(Start()));
        } else if (method == "dispose") {
          Stop();
          result->Success();
        } else if (method == "setFrequency") {
          frequency_.store(ReadNumber(args, "hz", frequency_.load()));
          result->Success();
        } else if (method == "setVolume") {
          double v = ReadNumber(args, "v", volume_.load());
          volume_.store((std::max)(0.0, (std::min)(1.0, v)));
          result->Success();
        } else if (method == "toneOn") {
          tone_on_.store(true);
          result->Success();
        } else if (method == "toneOff") {
          tone_on_.store(false);
          result->Success();
        } else {
          result->NotImplemented();
        }
      });
}

bool ToneEngine::Start() {
  if (started_.load()) {
    return true;
  }
  if (start_event_ == nullptr) {
    start_event_ = CreateEvent(nullptr, /*bManualReset=*/TRUE,
                               /*bInitialState=*/FALSE, nullptr);
    if (start_event_ == nullptr) {
      return false;
    }
  } else {
    ResetEvent(start_event_);
  }

  start_ok_.store(false);
  running_.store(true);
  render_thread_ = std::thread(&ToneEngine::RenderThreadMain, this);

  // Wait for the render thread to finish WASAPI initialisation.
  WaitForSingleObject(start_event_, 5000);
  if (!start_ok_.load()) {
    running_.store(false);
    if (render_thread_.joinable()) {
      render_thread_.join();
    }
    return false;
  }
  started_.store(true);
  return true;
}

void ToneEngine::Stop() {
  if (!running_.load() && !render_thread_.joinable()) {
    return;
  }
  running_.store(false);
  tone_on_.store(false);
  if (render_thread_.joinable()) {
    render_thread_.join();
  }
  started_.store(false);
  amp_ = 0.0;
  phase_ = 0.0;
}

void ToneEngine::RenderThreadMain() {
  // All COM interfaces are created and used on this single thread.
  HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
  const bool com_initialised = SUCCEEDED(hr);

  IMMDeviceEnumerator* enumerator = nullptr;
  IMMDevice* device = nullptr;
  IAudioClient* client = nullptr;
  IAudioRenderClient* render = nullptr;
  WAVEFORMATEX* wfx = nullptr;
  HANDLE audio_event = nullptr;
  UINT32 buffer_frames = 0;
  bool ok = false;

  do {
    hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
                          __uuidof(IMMDeviceEnumerator),
                          reinterpret_cast<void**>(&enumerator));
    if (FAILED(hr)) break;
    hr = enumerator->GetDefaultAudioEndpoint(eRender, eConsole, &device);
    if (FAILED(hr)) break;
    hr = device->Activate(__uuidof(IAudioClient), CLSCTX_ALL, nullptr,
                          reinterpret_cast<void**>(&client));
    if (FAILED(hr)) break;
    hr = client->GetMixFormat(&wfx);
    if (FAILED(hr) || wfx == nullptr) break;

    hr = client->Initialize(AUDCLNT_SHAREMODE_SHARED,
                            AUDCLNT_STREAMFLAGS_EVENTCALLBACK,
                            /*hnsBufferDuration=*/0, /*periodicity=*/0, wfx,
                            nullptr);
    if (FAILED(hr)) break;

    audio_event = CreateEvent(nullptr, FALSE, FALSE, nullptr);
    if (audio_event == nullptr) break;
    hr = client->SetEventHandle(audio_event);
    if (FAILED(hr)) break;

    hr = client->GetBufferSize(&buffer_frames);
    if (FAILED(hr)) break;
    hr = client->GetService(__uuidof(IAudioRenderClient),
                            reinterpret_cast<void**>(&render));
    if (FAILED(hr)) break;
    hr = client->Start();
    if (FAILED(hr)) break;
    ok = true;
  } while (false);

  start_ok_.store(ok);
  SetEvent(start_event_);

  if (ok) {
    // Determine the endpoint sample format.
    const double sample_rate = static_cast<double>(wfx->nSamplesPerSec);
    const int channels = wfx->nChannels;
    bool is_float = false;
    if (wfx->wFormatTag == WAVE_FORMAT_IEEE_FLOAT) {
      is_float = true;
    } else if (wfx->wFormatTag == WAVE_FORMAT_EXTENSIBLE) {
      auto* ext = reinterpret_cast<WAVEFORMATEXTENSIBLE*>(wfx);
      is_float =
          IsEqualGUID(ext->SubFormat, KSDATAFORMAT_SUBTYPE_IEEE_FLOAT) != 0;
    }
    const double amp_step = 1.0 / (kRampSeconds * sample_rate);

    while (running_.load()) {
      DWORD wait = WaitForSingleObject(audio_event, 200);
      if (!running_.load()) break;
      if (wait != WAIT_OBJECT_0) continue;

      UINT32 padding = 0;
      if (FAILED(client->GetCurrentPadding(&padding))) break;
      UINT32 available = buffer_frames - padding;
      if (available == 0) continue;

      BYTE* data = nullptr;
      if (FAILED(render->GetBuffer(available, &data))) break;

      const double freq = frequency_.load();
      const double target = tone_on_.load() ? volume_.load() : 0.0;
      const double phase_inc = kTwoPi * freq / sample_rate;

      auto* out_f = reinterpret_cast<float*>(data);
      auto* out_i = reinterpret_cast<int16_t*>(data);

      for (UINT32 frame = 0; frame < available; ++frame) {
        if (amp_ < target) {
          amp_ = (std::min)(target, amp_ + amp_step);
        } else if (amp_ > target) {
          amp_ = (std::max)(target, amp_ - amp_step);
        }
        double sample = 0.0;
        if (amp_ > 0.0) {
          sample = std::sin(phase_) * amp_;
          phase_ += phase_inc;
          if (phase_ > kTwoPi) phase_ -= kTwoPi;
        }
        for (int ch = 0; ch < channels; ++ch) {
          const UINT32 idx = frame * channels + ch;
          if (is_float) {
            out_f[idx] = static_cast<float>(sample);
          } else {
            out_i[idx] = static_cast<int16_t>(sample * 32767.0);
          }
        }
      }
      render->ReleaseBuffer(available, 0);
    }
    client->Stop();
  }

  if (wfx != nullptr) CoTaskMemFree(wfx);
  if (render != nullptr) render->Release();
  if (client != nullptr) client->Release();
  if (device != nullptr) device->Release();
  if (enumerator != nullptr) enumerator->Release();
  if (audio_event != nullptr) CloseHandle(audio_event);
  if (com_initialised) CoUninitialize();
}
