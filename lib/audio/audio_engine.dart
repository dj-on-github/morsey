import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Generates a Morse side-tone. Two use cases:
///   * real-time keying feedback  -> [toneOn] / [toneOff]
///   * playback of a sequence     -> [playPattern]
///
/// The default [PulseAudioEngine] synthesises a sine wave in Dart and streams
/// raw PCM to `pacat` (PulseAudio / PipeWire), so no native audio plugin or
/// gstreamer is required. Everything is guarded so the app still runs (silently)
/// if no audio backend is available.
abstract class AudioEngine {
  Future<void> start();
  Future<void> dispose();

  /// True if a working audio backend was found.
  bool get available;

  double frequency;
  double volume;

  /// Begin an indefinite tone (used while a paddle is keyed).
  void toneOn();

  /// Stop the current tone.
  void toneOff();

  AudioEngine(this.frequency, this.volume);

  /// Plays a Morse [pattern] (a string of '.' and '-') using [ditMs] timing.
  /// Completes when playback finishes. If [cancelled] returns true partway
  /// through, playback stops early.
  Future<void> playPattern(
    String pattern,
    int ditMs, {
    bool Function()? cancelled,
  }) async {
    for (var i = 0; i < pattern.length; i++) {
      if (cancelled?.call() ?? false) {
        toneOff();
        return;
      }
      final markMs = pattern[i] == '-' ? ditMs * 3 : ditMs;
      toneOn();
      await Future<void>.delayed(Duration(milliseconds: markMs));
      toneOff();
      // Inter-element gap of one dit, except after the last element.
      if (i != pattern.length - 1) {
        await Future<void>.delayed(Duration(milliseconds: ditMs));
      }
    }
  }

  /// Plays [text] as Morse, one character after another, with correct letter
  /// and word spacing.
  Future<void> playText(
    String text,
    int ditMs, {
    bool Function()? cancelled,
    void Function(String char)? onChar,
  }) async {
    final upper = text.toUpperCase();
    for (var i = 0; i < upper.length; i++) {
      if (cancelled?.call() ?? false) return;
      final ch = upper[i];
      if (ch == ' ') {
        // Word gap is 7 dits; 3 already elapse from the surrounding letter gap.
        await Future<void>.delayed(Duration(milliseconds: ditMs * 4));
        continue;
      }
      final pattern = _lookup(ch);
      if (pattern == null) continue;
      onChar?.call(ch);
      await playPattern(pattern, ditMs, cancelled: cancelled);
      if (i != upper.length - 1) {
        // Letter gap is 3 dits (one already elapsed as the trailing element
        // has no inter-element gap after it).
        await Future<void>.delayed(Duration(milliseconds: ditMs * 3));
      }
    }
  }

  static String? _lookup(String ch) {
    // Imported lazily to avoid a hard dependency cycle in this file.
    return _morse[ch];
  }
}

// Minimal lookup used by playText; kept local so the audio layer has no import
// of the UI/model layers.
const Map<String, String> _morse = {
  'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
  'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
  'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
  'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
  'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
  '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
  '8': '---..', '9': '----.', '.': '.-.-.-', ',': '--..--', '?': '..--..',
  "'": '.----.', '!': '-.-.--', '/': '-..-.', '(': '-.--.', ')': '-.--.-',
  '&': '.-...', ':': '---...', ';': '-.-.-.', '=': '-...-', '+': '.-.-.',
  '-': '-....-', '_': '..--.-', '"': '.-..-.', '@': '.--.-.',
};

/// Streams synthesised PCM to `pacat`. See [AudioEngine].
class PulseAudioEngine extends AudioEngine {
  PulseAudioEngine({double frequency = 600, double volume = 0.5})
      : super(frequency, volume);

  static const int _rate = 44100;
  // Keep this many milliseconds of audio buffered ahead of the play cursor.
  static const int _leadMs = 45;
  // Attack/decay ramp to avoid clicks, in seconds.
  static const double _rampSec = 0.006;

  Process? _proc;
  IOSink? _sink;
  Timer? _pump;
  final Stopwatch _clock = Stopwatch();
  int _samplesWritten = 0;
  double _phase = 0; // radians
  double _amp = 0; // current amplitude 0..1, ramped
  bool _toneOn = false;
  bool _available = false;

  @override
  bool get available => _available;

  @override
  Future<void> start() async {
    try {
      _proc = await Process.start('pacat', [
        '--rate=$_rate',
        '--channels=1',
        '--format=s16le',
        '--latency-msec=$_leadMs',
        '--stream-name=Morse Trainer',
      ]);
      _sink = _proc!.stdin;
      // Drain stderr so the pipe never blocks; ignore contents.
      _proc!.stderr.drain<void>();
      _available = true;
      _clock.start();
      _pump = Timer.periodic(const Duration(milliseconds: 5), (_) => _fill());
    } on Object {
      _available = false;
      _proc = null;
      _sink = null;
    }
  }

  /// Generate and queue however many samples are needed to stay [_leadMs]
  /// ahead of real time. Timing comes from the wall clock, so scheduler jitter
  /// only changes chunk sizes, never audio tempo.
  void _fill() {
    final sink = _sink;
    if (sink == null) return;
    final targetSamples =
        ((_clock.elapsedMicroseconds / 1e6 + _leadMs / 1000.0) * _rate).floor();
    final need = targetSamples - _samplesWritten;
    if (need <= 0) return;

    final bytes = Uint8List(need * 2);
    final view = ByteData.view(bytes.buffer);
    final twoPiF = 2 * math.pi * frequency / _rate;
    final ampStep = 1.0 / (_rampSec * _rate);
    final target = _toneOn ? volume.clamp(0.0, 1.0) : 0.0;

    for (var i = 0; i < need; i++) {
      if (_amp < target) {
        _amp = math.min(target, _amp + ampStep);
      } else if (_amp > target) {
        _amp = math.max(target, _amp - ampStep);
      }
      double sample = 0;
      if (_amp > 0) {
        sample = math.sin(_phase) * _amp;
        _phase += twoPiF;
        if (_phase > 2 * math.pi) _phase -= 2 * math.pi;
      }
      view.setInt16(i * 2, (sample * 30000).round(), Endian.little);
    }
    _samplesWritten += need;
    try {
      sink.add(bytes);
    } on Object {
      // Pipe closed (process died); mark unavailable.
      _available = false;
      _pump?.cancel();
    }
  }

  @override
  void toneOn() => _toneOn = true;

  @override
  void toneOff() => _toneOn = false;

  @override
  Future<void> dispose() async {
    _pump?.cancel();
    _toneOn = false;
    try {
      await _sink?.close();
    } on Object {
      // ignore
    }
    _proc?.kill();
    _proc = null;
  }
}

/// Native side-tone engine driven over the `morsey/tone_engine` MethodChannel.
/// The native side synthesises the sine wave: an AVAudioSourceNode on macOS
/// and a WASAPI render thread on Windows. Both expose the identical method
/// contract, so a single Dart class serves both platforms.
class NativeToneEngine extends AudioEngine {
  NativeToneEngine({double frequency = 600, double volume = 0.5})
      : super(frequency, volume);

  static const MethodChannel _channel = MethodChannel('morsey/tone_engine');

  bool _available = false;

  @override
  bool get available => _available;

  @override
  Future<void> start() async {
    try {
      final ok = await _channel.invokeMethod<bool>('start');
      _available = ok ?? false;
    } on PlatformException {
      _available = false;
      return;
    } on MissingPluginException {
      _available = false;
      return;
    }
    if (_available) {
      // Push the initial values so the native side matches Settings.
      await _invoke('setFrequency', {'hz': frequency});
      await _invoke('setVolume', {'v': volume});
    }
  }

  @override
  set frequency(double v) {
    super.frequency = v;
    if (_available) _invoke('setFrequency', {'hz': v});
  }

  @override
  set volume(double v) {
    super.volume = v;
    if (_available) _invoke('setVolume', {'v': v});
  }

  @override
  void toneOn() {
    if (_available) _invoke('toneOn', null);
  }

  @override
  void toneOff() {
    if (_available) _invoke('toneOff', null);
  }

  @override
  Future<void> dispose() async {
    _available = false;
    await _invoke('dispose', null);
  }

  // Fire-and-forget wrapper: platform errors here shouldn't crash the app.
  Future<void> _invoke(String method, Map<String, dynamic>? args) async {
    try {
      await _channel.invokeMethod<void>(method, args);
    } on Object {
      // ignore
    }
  }
}

/// No-op fallback when no audio backend is available.
class SilentAudioEngine extends AudioEngine {
  SilentAudioEngine() : super(600, 0.5);
  @override
  bool get available => false;
  @override
  Future<void> start() async {}
  @override
  Future<void> dispose() async {}
  @override
  void toneOn() {}
  @override
  void toneOff() {}
}

/// Picks the best available engine for the platform.
AudioEngine createAudioEngine({double frequency = 600, double volume = 0.5}) {
  if (Platform.isLinux) {
    return PulseAudioEngine(frequency: frequency, volume: volume);
  }
  if (Platform.isMacOS || Platform.isWindows) {
    return NativeToneEngine(frequency: frequency, volume: volume);
  }
  return SilentAudioEngine();
}
