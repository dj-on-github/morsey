import 'dart:async';

import '../audio/audio_engine.dart';
import 'morse_code.dart';

enum _Phase { idle, mark, space }

/// A software iambic keyer + live Morse decoder.
///
/// Fed with raw paddle up/down state ([setDit] / [setDah]), it generates
/// correctly-timed dit/dah elements at the configured speed, drives the audio
/// side-tone, and assembles elements into decoded characters using standard
/// element (1 dit) and letter (3 dit) spacing. Iambic squeeze (holding both
/// paddles) produces alternating dits and dahs, with one element of memory
/// (Curtis "mode B"-ish behaviour).
class IambicKeyer {
  IambicKeyer({
    required this.ditMs,
    required this.audio,
    this.onElement,
    this.onPattern,
    this.onCharacter,
  });

  /// Current dit length in ms (read fresh each element so speed changes apply).
  int Function() ditMs;
  final AudioEngine audio;

  /// Called when an element starts, with '.' or '-'.
  void Function(String element)? onElement;

  /// Called whenever the in-progress pattern changes (append or reset).
  void Function(String pattern)? onPattern;

  /// Called when a letter gap commits a pattern. [char] is null if the pattern
  /// does not decode to a known character.
  void Function(String pattern, String? char)? onCharacter;

  bool _dit = false;
  bool _dah = false;
  bool _ditMem = false;
  bool _dahMem = false;

  _Phase _phase = _Phase.idle;
  String? _current; // '.' or '-'
  int _phaseEndMs = 0;
  int _commitAtMs = 0;
  final StringBuffer _pattern = StringBuffer();

  final Stopwatch _clock = Stopwatch();
  Timer? _ticker;

  void start() {
    if (_ticker != null) return;
    _clock.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 2), (_) => _tick());
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    audio.toneOff();
    _phase = _Phase.idle;
    _current = null;
    _dit = _dah = _ditMem = _dahMem = false;
    _resetPattern();
  }

  /// Clears any partially-keyed character without committing it.
  void clear() => _resetPattern();

  void setDit(bool down) {
    _dit = down;
    if (down && _current == '-') _ditMem = true; // latch during a dah
  }

  void setDah(bool down) {
    _dah = down;
    if (down && _current == '.') _dahMem = true; // latch during a dit
  }

  void _resetPattern() {
    if (_pattern.isNotEmpty) {
      _pattern.clear();
      onPattern?.call('');
    }
  }

  void _tick() {
    final now = _clock.elapsedMilliseconds;
    final dit = ditMs();

    switch (_phase) {
      case _Phase.idle:
        // Commit a finished character after the letter gap.
        if (_pattern.isNotEmpty && now >= _commitAtMs) {
          final pattern = _pattern.toString();
          final char = charForMorse(pattern);
          _pattern.clear();
          onPattern?.call('');
          onCharacter?.call(pattern, char);
        }
        // Start a new element if a paddle (or its memory) is active.
        final first = _pickFirstElement();
        if (first != null) _beginElement(first, now, dit);
        break;

      case _Phase.mark:
        _latchOpposite();
        if (now >= _phaseEndMs) {
          audio.toneOff();
          _phase = _Phase.space;
          _phaseEndMs = now + dit;
        }
        break;

      case _Phase.space:
        _latchOpposite();
        if (now >= _phaseEndMs) {
          final next = _pickNextElement();
          if (next != null) {
            _beginElement(next, now, dit);
          } else {
            _phase = _Phase.idle;
            // Letter gap is 3 dits; one already elapsed as the inter-element
            // space, so commit two dits from now.
            _commitAtMs = now + 2 * dit;
          }
        }
        break;
    }
  }

  /// While sounding/spacing an element, remember an opposite paddle press.
  void _latchOpposite() {
    if (_current == '.' && _dah) _dahMem = true;
    if (_current == '-' && _dit) _ditMem = true;
  }

  String? _pickFirstElement() {
    if (_dit || _ditMem) return '.';
    if (_dah || _dahMem) return '-';
    return null;
  }

  /// After finishing [_current], choose the next element for iambic keying.
  String? _pickNextElement() {
    if (_current == '.') {
      if (_dah || _dahMem) return '-';
      if (_dit) return '.';
    } else {
      if (_dit || _ditMem) return '.';
      if (_dah) return '-';
    }
    return null;
  }

  void _beginElement(String element, int now, int dit) {
    _current = element;
    if (element == '.') {
      _ditMem = false;
    } else {
      _dahMem = false;
    }
    _pattern.write(element);
    _phase = _Phase.mark;
    _phaseEndMs = now + (element == '-' ? dit * 3 : dit);
    audio.toneOn();
    onElement?.call(element);
    onPattern?.call(_pattern.toString());
  }

  void dispose() => stop();
}
