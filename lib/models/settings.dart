import 'package:flutter/foundation.dart';

import '../morsey/morse_code.dart';

/// Which physical paddle produces a dit. The USB key reports the two paddles
/// as the Left-Ctrl (0x01) and Right-Ctrl (0x10) modifier bits.
enum DitPaddle {
  left('Left paddle = dit'),
  right('Right paddle = dit');

  const DitPaddle(this.label);
  final String label;
}

/// Application settings, shared across the whole app. Listenable so widgets
/// (and the audio/keyer engines) can react to changes.
class Settings extends ChangeNotifier {
  DitPaddle _ditPaddle = DitPaddle.left;
  int _wpm = 15;
  double _volume = 0.5; // 0.0 .. 1.0
  double _frequency = 600; // Hz
  CharacterSet _characterSet = CharacterSet.letters;
  int _tutorialLevel = 1; // highest unlocked Listen Tutorial level, 1..26
  int _inputTutorialLevel = 1; // highest unlocked Input Tutorial level, 1..26

  DitPaddle get ditPaddle => _ditPaddle;
  set ditPaddle(DitPaddle v) {
    if (v == _ditPaddle) return;
    _ditPaddle = v;
    notifyListeners();
  }

  /// Words per minute. Dit length (ms) = 1200 / wpm (PARIS timing).
  int get wpm => _wpm;
  set wpm(int v) {
    v = v.clamp(5, 40);
    if (v == _wpm) return;
    _wpm = v;
    notifyListeners();
  }

  /// Duration of one dit, in milliseconds, for the current speed.
  int get ditMs => (1200 / _wpm).round();

  double get volume => _volume;
  set volume(double v) {
    v = v.clamp(0.0, 1.0);
    if (v == _volume) return;
    _volume = v;
    notifyListeners();
  }

  double get frequency => _frequency;
  set frequency(double v) {
    v = v.clamp(200, 1200);
    if (v == _frequency) return;
    _frequency = v;
    notifyListeners();
  }

  CharacterSet get characterSet => _characterSet;
  set characterSet(CharacterSet v) {
    if (v == _characterSet) return;
    _characterSet = v;
    notifyListeners();
  }

  /// Highest Listen Tutorial level the pupil has unlocked (1-based). Each level
  /// introduces one more letter; completing a level unlocks the next.
  int get tutorialLevel => _tutorialLevel;
  set tutorialLevel(int v) {
    v = v.clamp(1, kTutorialLetterOrder.length);
    if (v == _tutorialLevel) return;
    _tutorialLevel = v;
    notifyListeners();
  }

  /// Highest Input Tutorial level the pupil has unlocked (1-based). Tracked
  /// separately from the listening course: hearing a letter and keying it are
  /// different skills.
  int get inputTutorialLevel => _inputTutorialLevel;
  set inputTutorialLevel(int v) {
    v = v.clamp(1, kTutorialLetterOrder.length);
    if (v == _inputTutorialLevel) return;
    _inputTutorialLevel = v;
    notifyListeners();
  }
}