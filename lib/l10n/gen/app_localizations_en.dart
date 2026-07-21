// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Morse Trainer';

  @override
  String get menuAbout => 'About';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuInputTrain => 'Input Train';

  @override
  String get menuListenTrain => 'Listen Train';

  @override
  String get menuListenTutorial => 'Listen Tutorial';

  @override
  String get menuInputTutorial => 'Input Tutorial';

  @override
  String get aboutIntro =>
      'A practice tool for learning Morse code, written in Dart / Flutter.';

  @override
  String get aboutPartsHeading => 'The parts of the program';

  @override
  String get aboutAboutDesc =>
      'This page — a description of the program and how it works.';

  @override
  String get aboutSettingsDesc =>
      'Set the paddle orientation, the keying speed, the side-tone volume and frequency, the language, and the light/dark appearance. The USB key and the keyboard paddles are both always active — no input selection needed.';

  @override
  String get aboutInputTrainDesc =>
      'A character is shown and you key it in Morse. The trainer decodes what you send and tells you if it was correct.';

  @override
  String get aboutListenTrainDesc =>
      'The trainer plays a character in Morse audio and you type the character you heard.';

  @override
  String get aboutListenTutorialDesc =>
      'A guided, 26-level listening course. Each level introduces one new letter (Koch-method order — the easiest-to-distinguish sounds come first): the letter is shown and its Morse is played, you type it to begin, then a random drill of every letter unlocked so far runs until each has been answered correctly three times. Completing a level unlocks the next, and your progress is remembered.';

  @override
  String get aboutInputTutorialDesc =>
      'The same 26-level course with the roles reversed, to teach sending. Each level shows the new letter\'s dots and dashes with the letter beside them; key the pattern to begin. In practice the pattern is taken away — only the letter is shown — and you key its Morse from memory with the paddle or keyboard, watching a live display of what you are keying. A \"Hear it\" button plays the target\'s rhythm, and a hint can reveal the pattern if you get stuck. Progress is tracked separately from the Listen Tutorial.';

  @override
  String get aboutUsbHeading => 'The USB Morse key';

  @override
  String get aboutUsbBody =>
      'This program supports an iambic (dual-paddle) Morse key that enumerates over USB as device 413d:2107. On Linux the key is read directly from its /dev/hidraw node — no drivers required, as long as your user can read the device (the plugdev group / a udev rule). Each paddle is reported as a keyboard modifier bit (Left-Ctrl and Right-Ctrl); the software turns those paddle presses into properly-timed dits and dahs.';

  @override
  String get aboutTimingHeading => 'Timing';

  @override
  String get aboutTimingBody =>
      'Speed is expressed in words per minute (WPM) using standard PARIS timing: one dit = 1200 / WPM milliseconds, a dah is three dits, the gap between elements is one dit, and the gap between letters is three dits.';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get settingsInputDevice => 'Input device';

  @override
  String get settingsInputDeviceBody =>
      'The keyboard paddles (Left/Right arrows, or . and -) and the USB key (413d:2107) are both always active — keying works from whichever you touch. Plug the key in at any time and it just works.';

  @override
  String get settingsUsbActsAsKeyboard =>
      'Here the USB key acts as a keyboard — just plug it in; the paddles arrive as Left/Right-Ctrl.';

  @override
  String settingsUsbDetected(Object path) {
    return 'USB key 413d:2107 detected: $path';
  }

  @override
  String get settingsUsbNotDetected =>
      'USB key 413d:2107 not detected — it will connect when plugged in. If it never does, check permissions (Linux: /dev/hidraw*; macOS: Input Monitoring in System Settings).';

  @override
  String get settingsRescan => 'Re-scan';

  @override
  String get settingsPaddleOrientation => 'Paddle orientation';

  @override
  String get settingsSpeed => 'Speed';

  @override
  String get settingsKeyingSpeed => 'Keying speed';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM  (dit = $ditMs ms)';
  }

  @override
  String get settingsSideTone => 'Side-tone';

  @override
  String get settingsVolume => 'Volume';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => 'Frequency';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'Test tone';

  @override
  String get settingsNoAudio =>
      'No audio backend available (Linux: needs pacat / PulseAudio).';

  @override
  String get settingsCharacterSet => 'Training character set';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get ditPaddleLeft => 'Left paddle = dit';

  @override
  String get ditPaddleRight => 'Right paddle = dit';

  @override
  String get charSetLetters => 'Letters';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => 'Numbers';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'Letters + Numbers';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => 'Punctuation';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'Everything';

  @override
  String get charSetAllDesc => 'letters, numbers, punctuation';

  @override
  String get statusStarting => 'Starting…';

  @override
  String score(Object correct, Object attempts) {
    return 'Score: $correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'Key this character:';

  @override
  String get showHint => 'Show hint';

  @override
  String get youAreKeying => 'You are keying:';

  @override
  String get correct => 'Correct!';

  @override
  String youKeyedTryAgain(Object decoded) {
    return 'You keyed \"$decoded\" — try again';
  }

  @override
  String get clear => 'Clear';

  @override
  String get skipNext => 'Skip / Next';

  @override
  String get audioMissingListenTrain =>
      'No audio backend available (needs pacat / PulseAudio) — Listen Train needs sound.';

  @override
  String get listenThenType => 'Listen, then type the character you heard';

  @override
  String get tapKeyBelow => 'Tap the matching key below.';

  @override
  String get typeKeyHint =>
      'Type a letter/number key (click here if typing does nothing).';

  @override
  String get replay => 'Replay';

  @override
  String get reveal => 'Reveal';

  @override
  String itWas(Object char, Object morse) {
    return 'It was  \"$char\"   ($morse)';
  }

  @override
  String get notQuiteListen => 'Not quite — listen again';

  @override
  String get audioMissingTutorial =>
      'No audio backend available — the Listen Tutorial needs sound.';

  @override
  String levelOf(Object level, Object count) {
    return 'Level $level of $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'Level $level  ($letter)';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total letters mastered';
  }

  @override
  String get newLetter => 'New letter';

  @override
  String get listenTypeToBegin => 'Listen, then type this letter to begin';

  @override
  String get greatStartingPractice => 'Great — starting practice…';

  @override
  String get typeLetterYouHear => 'Type the letter you hear';

  @override
  String get tutorialComplete => 'Tutorial complete!';

  @override
  String levelComplete(Object level) {
    return 'Level $level complete!';
  }

  @override
  String learnedAllLetters(Object count) {
    return 'You have learned all $count letters. Well done!';
  }

  @override
  String youMastered(Object letters) {
    return 'You mastered $letters.';
  }

  @override
  String get repeatLevelEsc => 'Repeat level (Esc)';

  @override
  String get nextLevelEnter => 'Next level (Enter)';

  @override
  String get keyPatternToBegin => 'Key this pattern to begin';

  @override
  String get keyThisLetter => 'Key this letter';

  @override
  String canKeyAllLetters(Object count) {
    return 'You can key all $count letters. Well done!';
  }

  @override
  String masteredKeying(Object letters) {
    return 'You mastered keying $letters.';
  }

  @override
  String get hearIt => 'Hear it';

  @override
  String get statusKeyboardReady => 'Keyboard paddles ready (←/→)';

  @override
  String get statusPaddlesTouch =>
      'Paddles: keyboard ←/→, or the USB key (acts as a keyboard)';

  @override
  String get statusUsbWaiting =>
      'USB key not detected — plug it in and it will connect';

  @override
  String statusUsbConnected(Object detail) {
    return 'USB key connected: $detail';
  }

  @override
  String get statusUsbUnplugged =>
      'USB key unplugged — reconnects when plugged in';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return 'Found $path but cannot open it (permissions?): $error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'Cannot open USB key (IOReturn $code) — grant Input Monitoring in System Settings';
  }

  @override
  String statusUsbError(Object error) {
    return 'USB key error: $error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · keyboard ←/→ also active';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'Paddles: keyboard ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'Free Type';

  @override
  String get freeTypeInputLabel => 'Type text here';

  @override
  String get freeTypeMorseLabel => 'Morse';

  @override
  String get freeTypeAudioOn => 'Audio on';

  @override
  String get freeTypeAudioOff => 'Audio off';

  @override
  String get aboutFreeTypeDesc =>
      'Type any text and watch it rendered as Morse — the dots and dashes appear at your configured speed, with optional audio playing in sync.';
}
