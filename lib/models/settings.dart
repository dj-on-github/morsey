import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../morsey/morse_code.dart';

/// App colour theme. Display labels are localized (see l10n/enum_l10n.dart).
enum AppTheme { system, light, dark }

/// Which physical paddle produces a dit. The USB key reports the two paddles
/// as the Left-Ctrl (0x01) and Right-Ctrl (0x10) modifier bits.
/// Display labels are localized (see l10n/enum_l10n.dart).
enum DitPaddle { left, right }

/// UI language. [system] follows the platform locale; the rest force one of
/// the bundled translations.
enum AppLanguage {
  system(null, null),
  // Real languages: Latin-script endonyms alphabetically, then other
  // scripts, Klingon last (the picker shows declaration order).
  cy('cy', 'Cymraeg'),
  de('de', 'Deutsch'),
  en('en', 'English'),
  es('es', 'Español'),
  fr('fr', 'Français'),
  hi('hi', 'हिन्दी'),
  ja('ja', '日本語'),
  zh('zh', '中文'),
  tlh('tlh', 'tlhIngan Hol');

  const AppLanguage(this.code, this.endonym);

  final String? code;

  /// The language's own name for itself — shown untranslated in the picker,
  /// so a user lost in the wrong language can still find their own.
  final String? endonym;

  Locale? get locale => code == null ? null : Locale(code!);
}

/// Application settings, shared across the whole app. Listenable so widgets
/// (and the audio/keyer engines) can react to changes.
///
/// Construct with [Settings.load] to restore saved values and persist every
/// change (via shared_preferences). The plain constructor keeps everything in
/// memory only — handy for tests.
class Settings extends ChangeNotifier {
  Settings({this._prefs}) {
    _restore();
  }

  /// Loads the persisted settings.
  static Future<Settings> load() async =>
      Settings(prefs: await SharedPreferences.getInstance());

  final SharedPreferences? _prefs;

  // Preference keys.
  static const _kLanguage = 'language';
  static const _kAppTheme = 'appTheme';
  static const _kDitPaddle = 'ditPaddle';
  static const _kWpm = 'wpm';
  static const _kVolume = 'volume';
  static const _kFrequency = 'frequency';
  static const _kCharacterSet = 'characterSet';
  static const _kTutorialLevel = 'tutorialLevel';
  static const _kInputTutorialLevel = 'inputTutorialLevel';

  AppLanguage _language = AppLanguage.system;
  // Dark preserves the app's original look; the user can opt into light or
  // following the platform.
  AppTheme _appTheme = AppTheme.dark;
  DitPaddle _ditPaddle = DitPaddle.left;
  int _wpm = 15;
  double _volume = 0.5; // 0.0 .. 1.0
  double _frequency = 600; // Hz
  CharacterSet _characterSet = CharacterSet.letters;
  int _tutorialLevel = 1; // highest unlocked Listen Tutorial level, 1..26
  int _inputTutorialLevel = 1; // highest unlocked Input Tutorial level, 1..26

  /// Applies persisted values over the defaults, clamping/ignoring anything
  /// out of range or unrecognised (e.g. from an older app version).
  void _restore() {
    final p = _prefs;
    if (p == null) return;
    _language =
        AppLanguage.values.asNameMap()[p.getString(_kLanguage)] ?? _language;
    _appTheme =
        AppTheme.values.asNameMap()[p.getString(_kAppTheme)] ?? _appTheme;
    _ditPaddle =
        DitPaddle.values.asNameMap()[p.getString(_kDitPaddle)] ?? _ditPaddle;
    _wpm = (p.getInt(_kWpm) ?? _wpm).clamp(5, 40);
    _volume = (p.getDouble(_kVolume) ?? _volume).clamp(0.0, 1.0);
    _frequency = (p.getDouble(_kFrequency) ?? _frequency).clamp(200, 1200);
    _characterSet =
        CharacterSet.values.asNameMap()[p.getString(_kCharacterSet)] ??
            _characterSet;
    _tutorialLevel = (p.getInt(_kTutorialLevel) ?? _tutorialLevel)
        .clamp(1, kTutorialLetterOrder.length);
    _inputTutorialLevel =
        (p.getInt(_kInputTutorialLevel) ?? _inputTutorialLevel)
            .clamp(1, kTutorialLetterOrder.length);
  }

  AppLanguage get language => _language;
  set language(AppLanguage v) {
    if (v == _language) return;
    _language = v;
    _prefs?.setString(_kLanguage, v.name);
    notifyListeners();
  }

  AppTheme get appTheme => _appTheme;
  set appTheme(AppTheme v) {
    if (v == _appTheme) return;
    _appTheme = v;
    _prefs?.setString(_kAppTheme, v.name);
    notifyListeners();
  }

  DitPaddle get ditPaddle => _ditPaddle;
  set ditPaddle(DitPaddle v) {
    if (v == _ditPaddle) return;
    _ditPaddle = v;
    _prefs?.setString(_kDitPaddle, v.name);
    notifyListeners();
  }

  /// Words per minute. Dit length (ms) = 1200 / wpm (PARIS timing).
  int get wpm => _wpm;
  set wpm(int v) {
    v = v.clamp(5, 40);
    if (v == _wpm) return;
    _wpm = v;
    _prefs?.setInt(_kWpm, v);
    notifyListeners();
  }

  /// Duration of one dit, in milliseconds, for the current speed.
  int get ditMs => (1200 / _wpm).round();

  double get volume => _volume;
  set volume(double v) {
    v = v.clamp(0.0, 1.0);
    if (v == _volume) return;
    _volume = v;
    _prefs?.setDouble(_kVolume, v);
    notifyListeners();
  }

  double get frequency => _frequency;
  set frequency(double v) {
    v = v.clamp(200, 1200);
    if (v == _frequency) return;
    _frequency = v;
    _prefs?.setDouble(_kFrequency, v);
    notifyListeners();
  }

  CharacterSet get characterSet => _characterSet;
  set characterSet(CharacterSet v) {
    if (v == _characterSet) return;
    _characterSet = v;
    _prefs?.setString(_kCharacterSet, v.name);
    notifyListeners();
  }

  /// Highest Listen Tutorial level the pupil has unlocked (1-based). Each level
  /// introduces one more letter; completing a level unlocks the next.
  int get tutorialLevel => _tutorialLevel;
  set tutorialLevel(int v) {
    v = v.clamp(1, kTutorialLetterOrder.length);
    if (v == _tutorialLevel) return;
    _tutorialLevel = v;
    _prefs?.setInt(_kTutorialLevel, v);
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
    _prefs?.setInt(_kInputTutorialLevel, v);
    notifyListeners();
  }
}
