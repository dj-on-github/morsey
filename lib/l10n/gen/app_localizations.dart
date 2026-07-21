import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cy.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_tlh.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cy'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('tlh'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Morse Trainer'**
  String get appTitle;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuInputTrain.
  ///
  /// In en, this message translates to:
  /// **'Input Train'**
  String get menuInputTrain;

  /// No description provided for @menuListenTrain.
  ///
  /// In en, this message translates to:
  /// **'Listen Train'**
  String get menuListenTrain;

  /// No description provided for @menuListenTutorial.
  ///
  /// In en, this message translates to:
  /// **'Listen Tutorial'**
  String get menuListenTutorial;

  /// No description provided for @menuInputTutorial.
  ///
  /// In en, this message translates to:
  /// **'Input Tutorial'**
  String get menuInputTutorial;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'A practice tool for learning Morse code, written in Dart / Flutter.'**
  String get aboutIntro;

  /// No description provided for @aboutPartsHeading.
  ///
  /// In en, this message translates to:
  /// **'The parts of the program'**
  String get aboutPartsHeading;

  /// No description provided for @aboutAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'This page — a description of the program and how it works.'**
  String get aboutAboutDesc;

  /// No description provided for @aboutSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set the paddle orientation, the keying speed, the side-tone volume and frequency, the language, and the light/dark appearance. The USB key and the keyboard paddles are both always active — no input selection needed.'**
  String get aboutSettingsDesc;

  /// No description provided for @aboutInputTrainDesc.
  ///
  /// In en, this message translates to:
  /// **'A character is shown and you key it in Morse. The trainer decodes what you send and tells you if it was correct.'**
  String get aboutInputTrainDesc;

  /// No description provided for @aboutListenTrainDesc.
  ///
  /// In en, this message translates to:
  /// **'The trainer plays a character in Morse audio and you type the character you heard.'**
  String get aboutListenTrainDesc;

  /// No description provided for @aboutListenTutorialDesc.
  ///
  /// In en, this message translates to:
  /// **'A guided, 26-level listening course. Each level introduces one new letter (Koch-method order — the easiest-to-distinguish sounds come first): the letter is shown and its Morse is played, you type it to begin, then a random drill of every letter unlocked so far runs until each has been answered correctly three times. Completing a level unlocks the next, and your progress is remembered.'**
  String get aboutListenTutorialDesc;

  /// No description provided for @aboutInputTutorialDesc.
  ///
  /// In en, this message translates to:
  /// **'The same 26-level course with the roles reversed, to teach sending. Each level shows the new letter\'s dots and dashes with the letter beside them; key the pattern to begin. In practice the pattern is taken away — only the letter is shown — and you key its Morse from memory with the paddle or keyboard, watching a live display of what you are keying. A \"Hear it\" button plays the target\'s rhythm, and a hint can reveal the pattern if you get stuck. Progress is tracked separately from the Listen Tutorial.'**
  String get aboutInputTutorialDesc;

  /// No description provided for @aboutUsbHeading.
  ///
  /// In en, this message translates to:
  /// **'The USB Morse key'**
  String get aboutUsbHeading;

  /// No description provided for @aboutUsbBody.
  ///
  /// In en, this message translates to:
  /// **'This program supports an iambic (dual-paddle) Morse key that enumerates over USB as device 413d:2107. On Linux the key is read directly from its /dev/hidraw node — no drivers required, as long as your user can read the device (the plugdev group / a udev rule). Each paddle is reported as a keyboard modifier bit (Left-Ctrl and Right-Ctrl); the software turns those paddle presses into properly-timed dits and dahs.'**
  String get aboutUsbBody;

  /// No description provided for @aboutTimingHeading.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get aboutTimingHeading;

  /// No description provided for @aboutTimingBody.
  ///
  /// In en, this message translates to:
  /// **'Speed is expressed in words per minute (WPM) using standard PARIS timing: one dit = 1200 / WPM milliseconds, a dah is three dits, the gap between elements is one dit, and the gap between letters is three dits.'**
  String get aboutTimingBody;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(Object version);

  /// No description provided for @settingsInputDevice.
  ///
  /// In en, this message translates to:
  /// **'Input device'**
  String get settingsInputDevice;

  /// No description provided for @settingsInputDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'The keyboard paddles (Left/Right arrows, or . and -) and the USB key (413d:2107) are both always active — keying works from whichever you touch. Plug the key in at any time and it just works.'**
  String get settingsInputDeviceBody;

  /// No description provided for @settingsUsbActsAsKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Here the USB key acts as a keyboard — just plug it in; the paddles arrive as Left/Right-Ctrl.'**
  String get settingsUsbActsAsKeyboard;

  /// No description provided for @settingsUsbDetected.
  ///
  /// In en, this message translates to:
  /// **'USB key 413d:2107 detected: {path}'**
  String settingsUsbDetected(Object path);

  /// No description provided for @settingsUsbNotDetected.
  ///
  /// In en, this message translates to:
  /// **'USB key 413d:2107 not detected — it will connect when plugged in. If it never does, check permissions (Linux: /dev/hidraw*; macOS: Input Monitoring in System Settings).'**
  String get settingsUsbNotDetected;

  /// No description provided for @settingsRescan.
  ///
  /// In en, this message translates to:
  /// **'Re-scan'**
  String get settingsRescan;

  /// No description provided for @settingsPaddleOrientation.
  ///
  /// In en, this message translates to:
  /// **'Paddle orientation'**
  String get settingsPaddleOrientation;

  /// No description provided for @settingsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get settingsSpeed;

  /// No description provided for @settingsKeyingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Keying speed'**
  String get settingsKeyingSpeed;

  /// No description provided for @settingsWpmValue.
  ///
  /// In en, this message translates to:
  /// **'{wpm} WPM  (dit = {ditMs} ms)'**
  String settingsWpmValue(Object wpm, Object ditMs);

  /// No description provided for @settingsSideTone.
  ///
  /// In en, this message translates to:
  /// **'Side-tone'**
  String get settingsSideTone;

  /// No description provided for @settingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolume;

  /// No description provided for @settingsVolumeValue.
  ///
  /// In en, this message translates to:
  /// **'{percent} %'**
  String settingsVolumeValue(Object percent);

  /// No description provided for @settingsFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get settingsFrequency;

  /// No description provided for @settingsFrequencyValue.
  ///
  /// In en, this message translates to:
  /// **'{hz} Hz'**
  String settingsFrequencyValue(Object hz);

  /// No description provided for @settingsTestTone.
  ///
  /// In en, this message translates to:
  /// **'Test tone'**
  String get settingsTestTone;

  /// No description provided for @settingsNoAudio.
  ///
  /// In en, this message translates to:
  /// **'No audio backend available (Linux: needs pacat / PulseAudio).'**
  String get settingsNoAudio;

  /// No description provided for @settingsCharacterSet.
  ///
  /// In en, this message translates to:
  /// **'Training character set'**
  String get settingsCharacterSet;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @ditPaddleLeft.
  ///
  /// In en, this message translates to:
  /// **'Left paddle = dit'**
  String get ditPaddleLeft;

  /// No description provided for @ditPaddleRight.
  ///
  /// In en, this message translates to:
  /// **'Right paddle = dit'**
  String get ditPaddleRight;

  /// No description provided for @charSetLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get charSetLetters;

  /// No description provided for @charSetLettersDesc.
  ///
  /// In en, this message translates to:
  /// **'A – Z'**
  String get charSetLettersDesc;

  /// No description provided for @charSetNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get charSetNumbers;

  /// No description provided for @charSetNumbersDesc.
  ///
  /// In en, this message translates to:
  /// **'0 – 9'**
  String get charSetNumbersDesc;

  /// No description provided for @charSetLettersNumbers.
  ///
  /// In en, this message translates to:
  /// **'Letters + Numbers'**
  String get charSetLettersNumbers;

  /// No description provided for @charSetLettersNumbersDesc.
  ///
  /// In en, this message translates to:
  /// **'A – Z, 0 – 9'**
  String get charSetLettersNumbersDesc;

  /// No description provided for @charSetPunctuation.
  ///
  /// In en, this message translates to:
  /// **'Punctuation'**
  String get charSetPunctuation;

  /// No description provided for @charSetPunctuationDesc.
  ///
  /// In en, this message translates to:
  /// **'. , ? / = + …'**
  String get charSetPunctuationDesc;

  /// No description provided for @charSetAll.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get charSetAll;

  /// No description provided for @charSetAllDesc.
  ///
  /// In en, this message translates to:
  /// **'letters, numbers, punctuation'**
  String get charSetAllDesc;

  /// No description provided for @statusStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get statusStarting;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score: {correct} / {attempts}'**
  String score(Object correct, Object attempts);

  /// No description provided for @keyThisCharacter.
  ///
  /// In en, this message translates to:
  /// **'Key this character:'**
  String get keyThisCharacter;

  /// No description provided for @showHint.
  ///
  /// In en, this message translates to:
  /// **'Show hint'**
  String get showHint;

  /// No description provided for @youAreKeying.
  ///
  /// In en, this message translates to:
  /// **'You are keying:'**
  String get youAreKeying;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @youKeyedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'You keyed \"{decoded}\" — try again'**
  String youKeyedTryAgain(Object decoded);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @skipNext.
  ///
  /// In en, this message translates to:
  /// **'Skip / Next'**
  String get skipNext;

  /// No description provided for @audioMissingListenTrain.
  ///
  /// In en, this message translates to:
  /// **'No audio backend available (needs pacat / PulseAudio) — Listen Train needs sound.'**
  String get audioMissingListenTrain;

  /// No description provided for @listenThenType.
  ///
  /// In en, this message translates to:
  /// **'Listen, then type the character you heard'**
  String get listenThenType;

  /// No description provided for @tapKeyBelow.
  ///
  /// In en, this message translates to:
  /// **'Tap the matching key below.'**
  String get tapKeyBelow;

  /// No description provided for @typeKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Type a letter/number key (click here if typing does nothing).'**
  String get typeKeyHint;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @reveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get reveal;

  /// No description provided for @itWas.
  ///
  /// In en, this message translates to:
  /// **'It was  \"{char}\"   ({morse})'**
  String itWas(Object char, Object morse);

  /// No description provided for @notQuiteListen.
  ///
  /// In en, this message translates to:
  /// **'Not quite — listen again'**
  String get notQuiteListen;

  /// No description provided for @audioMissingTutorial.
  ///
  /// In en, this message translates to:
  /// **'No audio backend available — the Listen Tutorial needs sound.'**
  String get audioMissingTutorial;

  /// No description provided for @levelOf.
  ///
  /// In en, this message translates to:
  /// **'Level {level} of {count}'**
  String levelOf(Object level, Object count);

  /// No description provided for @levelItem.
  ///
  /// In en, this message translates to:
  /// **'Level {level}  ({letter})'**
  String levelItem(Object level, Object letter);

  /// No description provided for @lettersMastered.
  ///
  /// In en, this message translates to:
  /// **'{mastered} / {total} letters mastered'**
  String lettersMastered(Object mastered, Object total);

  /// No description provided for @newLetter.
  ///
  /// In en, this message translates to:
  /// **'New letter'**
  String get newLetter;

  /// No description provided for @listenTypeToBegin.
  ///
  /// In en, this message translates to:
  /// **'Listen, then type this letter to begin'**
  String get listenTypeToBegin;

  /// No description provided for @greatStartingPractice.
  ///
  /// In en, this message translates to:
  /// **'Great — starting practice…'**
  String get greatStartingPractice;

  /// No description provided for @typeLetterYouHear.
  ///
  /// In en, this message translates to:
  /// **'Type the letter you hear'**
  String get typeLetterYouHear;

  /// No description provided for @tutorialComplete.
  ///
  /// In en, this message translates to:
  /// **'Tutorial complete!'**
  String get tutorialComplete;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level {level} complete!'**
  String levelComplete(Object level);

  /// No description provided for @learnedAllLetters.
  ///
  /// In en, this message translates to:
  /// **'You have learned all {count} letters. Well done!'**
  String learnedAllLetters(Object count);

  /// No description provided for @youMastered.
  ///
  /// In en, this message translates to:
  /// **'You mastered {letters}.'**
  String youMastered(Object letters);

  /// No description provided for @repeatLevelEsc.
  ///
  /// In en, this message translates to:
  /// **'Repeat level (Esc)'**
  String get repeatLevelEsc;

  /// No description provided for @nextLevelEnter.
  ///
  /// In en, this message translates to:
  /// **'Next level (Enter)'**
  String get nextLevelEnter;

  /// No description provided for @keyPatternToBegin.
  ///
  /// In en, this message translates to:
  /// **'Key this pattern to begin'**
  String get keyPatternToBegin;

  /// No description provided for @keyThisLetter.
  ///
  /// In en, this message translates to:
  /// **'Key this letter'**
  String get keyThisLetter;

  /// No description provided for @canKeyAllLetters.
  ///
  /// In en, this message translates to:
  /// **'You can key all {count} letters. Well done!'**
  String canKeyAllLetters(Object count);

  /// No description provided for @masteredKeying.
  ///
  /// In en, this message translates to:
  /// **'You mastered keying {letters}.'**
  String masteredKeying(Object letters);

  /// No description provided for @hearIt.
  ///
  /// In en, this message translates to:
  /// **'Hear it'**
  String get hearIt;

  /// No description provided for @statusKeyboardReady.
  ///
  /// In en, this message translates to:
  /// **'Keyboard paddles ready (←/→)'**
  String get statusKeyboardReady;

  /// No description provided for @statusPaddlesTouch.
  ///
  /// In en, this message translates to:
  /// **'Paddles: keyboard ←/→, or the USB key (acts as a keyboard)'**
  String get statusPaddlesTouch;

  /// No description provided for @statusUsbWaiting.
  ///
  /// In en, this message translates to:
  /// **'USB key not detected — plug it in and it will connect'**
  String get statusUsbWaiting;

  /// No description provided for @statusUsbConnected.
  ///
  /// In en, this message translates to:
  /// **'USB key connected: {detail}'**
  String statusUsbConnected(Object detail);

  /// No description provided for @statusUsbUnplugged.
  ///
  /// In en, this message translates to:
  /// **'USB key unplugged — reconnects when plugged in'**
  String get statusUsbUnplugged;

  /// No description provided for @statusUsbOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Found {path} but cannot open it (permissions?): {error}'**
  String statusUsbOpenFailed(Object path, Object error);

  /// No description provided for @statusUsbOpenDenied.
  ///
  /// In en, this message translates to:
  /// **'Cannot open USB key (IOReturn {code}) — grant Input Monitoring in System Settings'**
  String statusUsbOpenDenied(Object code);

  /// No description provided for @statusUsbError.
  ///
  /// In en, this message translates to:
  /// **'USB key error: {error}'**
  String statusUsbError(Object error);

  /// No description provided for @statusUsbAndKeyboard.
  ///
  /// In en, this message translates to:
  /// **'{usb} · keyboard ←/→ also active'**
  String statusUsbAndKeyboard(Object usb);

  /// No description provided for @statusKeyboardAndUsb.
  ///
  /// In en, this message translates to:
  /// **'Paddles: keyboard ←/→ · {usb}'**
  String statusKeyboardAndUsb(Object usb);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'cy',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'tlh',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cy':
      return AppLocalizationsCy();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'tlh':
      return AppLocalizationsTlh();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
