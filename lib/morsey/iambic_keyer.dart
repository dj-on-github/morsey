import 'dart:async';

import '../audio/audio_engine.dart';
import 'morse_code.dart';

enum _Phase { idle, mark, space }

/// A software keyer + live Morse decoder with two modes.
///
/// **Iambic** (default): fed with raw paddle up/down state ([setDit] /
/// [setDah]), it generates correctly-timed dit/dah elements at the configured
/// speed, drives the audio side-tone, and assembles elements into decoded
/// characters using standard element (1 dit) and letter (3 dit) spacing.
/// Iambic squeeze (holding both paddles) produces alternating dits and dahs,
/// with one element of memory (Curtis "mode B"-ish behaviour).
///
/// **Straight** (when [straightKey] returns true): any contact (either
/// paddle, so every input route works) is a single key. The side-tone
/// follows the contact exactly; the operator makes the timing. On release
/// the press length classifies the element — under 2 dits is a dit,
/// otherwise a dah — and 2 dits of silence commits the character.
class IambicKeyer {
  IambicKeyer({
    required this.ditMs,
    required this.audio,
    this.straightKey,
    this.onElement,
    this.onPattern,
    this.onCharacter,
  });

  /// Current dit length in ms (read fresh each element so speed changes apply).
  int Function() ditMs;
  final AudioEngine audio;

  /// When it returns true the keyer runs in straight-key mode. Read every
  /// tick, so flipping the setting applies immediately.
  final bool Function()? straightKey;

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

  // Straight-key state.
  bool _inStraight = false;
  bool _skDown = false;
  int _skDownAt = 0;
  int _skUpAt = 0;

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
    _skDown = false;
    _resetPattern();
  }

  /// Clears any partially-keyed character without committing it.
  void clear() => _resetPattern();

  /// True while an element is sounding/spacing or a keyed pattern is still
  /// awaiting its letter-gap commit — i.e. the keyer owns the side-tone.
  bool get active => _phase != _Phase.idle || _pattern.isNotEmpty || _skDown;

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

    final straight = straightKey?.call() ?? false;
    if (straight != _inStraight) {
      // Mode flipped mid-session: drop all in-flight state so neither mode
      // inherits a stuck tone or a half-built character.
      _inStraight = straight;
      audio.toneOff();
      _phase = _Phase.idle;
      _current = null;
      _ditMem = _dahMem = false;
      _skDown = false;
      _resetPattern();
    }
    if (straight) {
      _tickStraight(now, dit);
      return;
    }

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

  /// Straight-key mode: the tone follows the contact (either paddle), the
  /// press length classifies the element on release, and 2 dits of silence
  /// commits the character. The 2-dit thresholds sit midway between the
  /// nominal 1/3-dit timings, which forgives hand-keying jitter.
  void _tickStraight(int now, int dit) {
    final down = _dit || _dah;
    if (down != _skDown) {
      _skDown = down;
      if (down) {
        audio.toneOn();
        _skDownAt = now;
      } else {
        audio.toneOff();
        final element = (now - _skDownAt) < 2 * dit ? '.' : '-';
        _pattern.write(element);
        onElement?.call(element);
        onPattern?.call(_pattern.toString());
        _skUpAt = now;
      }
      return;
    }
    if (!down && _pattern.isNotEmpty && now - _skUpAt >= 2 * dit) {
      final pattern = _pattern.toString();
      final char = charForMorse(pattern);
      _pattern.clear();
      onPattern?.call('');
      onCharacter?.call(pattern, char);
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
