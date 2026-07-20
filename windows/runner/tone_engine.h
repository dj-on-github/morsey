#ifndef RUNNER_TONE_ENGINE_H_
#define RUNNER_TONE_ENGINE_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <atomic>
#include <memory>
#include <thread>

// Sine-wave side-tone generator for Windows. Mirrors the macOS ToneEngine and
// speaks the identical `morsey/tone_engine` MethodChannel contract:
//   * `start`        -> Bool         Boot the engine. False if WASAPI fails.
//   * `dispose`      -> void         Tear down.
//   * `setFrequency` ({hz: Double})  Change tone frequency (Hz).
//   * `setVolume`    ({v: Double})   Change peak amplitude (0..1).
//   * `toneOn`       -> void         Ramp gain up to the current volume.
//   * `toneOff`      -> void         Ramp gain down to 0.
//
// Audio is synthesised on a dedicated WASAPI (shared, event-driven) render
// thread. A short (~6 ms) amplitude ramp avoids the click a hard gate makes.
class ToneEngine {
 public:
  static constexpr const char* kMethodChannelName = "morsey/tone_engine";

  ToneEngine() = default;
  ~ToneEngine();

  ToneEngine(const ToneEngine&) = delete;
  ToneEngine& operator=(const ToneEngine&) = delete;

  // Registers the method-call handler on |messenger|.
  void RegisterWithMessenger(flutter::BinaryMessenger* messenger);

 private:
  // Boots the WASAPI render thread. Returns false if audio init fails.
  bool Start();
  // Stops the render thread and releases audio resources.
  void Stop();
  // Entry point for the render thread: WASAPI setup + render loop.
  void RenderThreadMain();

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;

  std::thread render_thread_;
  HANDLE start_event_ = nullptr;

  std::atomic<bool> running_{false};
  std::atomic<bool> started_{false};
  std::atomic<bool> start_ok_{false};

  // Shared state: written on the platform thread, read on the audio thread.
  std::atomic<double> frequency_{600.0};
  std::atomic<double> volume_{0.5};
  std::atomic<bool> tone_on_{false};

  // Audio-thread only.
  double amp_ = 0.0;
  double phase_ = 0.0;
};

#endif  // RUNNER_TONE_ENGINE_H_
