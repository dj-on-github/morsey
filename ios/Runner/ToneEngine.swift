import AVFoundation
import Flutter

/// Sine-wave side-tone generator for iOS/iPadOS. Mirrors
/// `macos/Runner/ToneEngine.swift` (same channel, same methods); the only
/// platform differences are the Flutter import and the AVAudioSession
/// activation, which macOS does not have.
///
/// Method channel `morsey/tone_engine`:
///   * `start`         -> Bool         Boot the engine. Returns false if
///                                     the session/engine can't start.
///   * `dispose`       -> void         Tear down.
///   * `setFrequency`  ({hz: Double})  Change tone frequency (Hz).
///   * `setVolume`     ({v: Double})   Change peak amplitude (0..1).
///   * `toneOn`        -> void         Ramp gain up to the current volume.
///   * `toneOff`       -> void         Ramp gain down to 0.
///
/// Ramping (~6 ms) avoids the click a hard gate would produce.
final class ToneEngine {
    static let methodChannelName = "morsey/tone_engine"

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var started = false

    // Shared state — writes on the main thread, reads on the audio thread.
    private let lock = NSLock()
    private var _frequency: Double = 600
    private var _volume: Double = 0.5
    private var _toneOn: Bool = false

    // Audio-thread only.
    private var amp: Double = 0
    private var phase: Double = 0

    private let rampSeconds: Double = 0.006

    func register(with messenger: FlutterBinaryMessenger) {
        let ch = FlutterMethodChannel(
            name: ToneEngine.methodChannelName, binaryMessenger: messenger)
        ch.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    // MARK: - Method channel

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "start":
            result(start())
        case "dispose":
            dispose()
            result(nil)
        case "setFrequency":
            if let hz = (args["hz"] as? NSNumber)?.doubleValue {
                lock.lock(); _frequency = hz; lock.unlock()
            }
            result(nil)
        case "setVolume":
            if let v = (args["v"] as? NSNumber)?.doubleValue {
                lock.lock(); _volume = max(0, min(1, v)); lock.unlock()
            }
            result(nil)
        case "toneOn":
            lock.lock(); _toneOn = true; lock.unlock()
            result(nil)
        case "toneOff":
            lock.lock(); _toneOn = false; lock.unlock()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Engine lifecycle

    private func start() -> Bool {
        if started { return true }

        // iOS-only: the audio session must be configured and activated before
        // the engine starts. .playback keeps the side-tone audible regardless
        // of the ringer/silent state.
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default,
                                    options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            NSLog("ToneEngine: AVAudioSession setup failed: \(error)")
            return false
        }

        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        guard sampleRate > 0,
              let format = AVAudioFormat(
                standardFormatWithSampleRate: sampleRate, channels: 1)
        else { return false }

        let source = AVAudioSourceNode(format: format) {
            [weak self] _, _, frameCount, abl -> OSStatus in
            guard let self = self else { return noErr }
            self.render(frameCount: Int(frameCount),
                        sampleRate: sampleRate,
                        abl: abl)
            return noErr
        }
        self.sourceNode = source
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            started = true
            return true
        } catch {
            NSLog("ToneEngine: AVAudioEngine.start() failed: \(error)")
            return false
        }
    }

    private func dispose() {
        lock.lock(); _toneOn = false; lock.unlock()
        if started {
            engine.stop()
            started = false
        }
        if let node = sourceNode {
            engine.detach(node)
            sourceNode = nil
        }
        amp = 0
        phase = 0
    }

    // MARK: - Render callback

    private func render(frameCount: Int,
                        sampleRate: Double,
                        abl: UnsafeMutablePointer<AudioBufferList>) {
        // Snapshot main-thread state once per callback.
        lock.lock()
        let freq = _frequency
        let target = _toneOn ? _volume : 0.0
        lock.unlock()

        let twoPiF = 2.0 * .pi * freq / sampleRate
        let ampStep = 1.0 / (rampSeconds * sampleRate)
        let buffers = UnsafeMutableAudioBufferListPointer(abl)

        // Compute samples once; fan out to every channel (typically 1).
        var scratch = [Float](repeating: 0, count: frameCount)
        for i in 0..<frameCount {
            if amp < target {
                amp = min(target, amp + ampStep)
            } else if amp > target {
                amp = max(target, amp - ampStep)
            }
            var sample: Double = 0
            if amp > 0 {
                sample = sin(phase) * amp
                phase += twoPiF
                if phase > 2 * .pi { phase -= 2 * .pi }
            }
            scratch[i] = Float(sample)
        }
        for buffer in buffers {
            guard let data = buffer.mData?.assumingMemoryBound(to: Float.self)
            else { continue }
            let frames = Int(buffer.mDataByteSize) / MemoryLayout<Float>.size
            let n = min(frames, frameCount)
            scratch.withUnsafeBufferPointer { src in
                if let base = src.baseAddress {
                    data.update(from: base, count: n)
                }
            }
        }
    }
}
