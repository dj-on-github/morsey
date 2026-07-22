// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Klingon tlhIngan Hol (`tlh`).
class AppLocalizationsTlh extends AppLocalizations {
  AppLocalizationsTlh([String locale = 'tlh']) : super(locale);

  @override
  String get appTitle => 'morS ngoq ghojmoHwI\'';

  @override
  String get menuAbout => 'De\'';

  @override
  String get menuSettings => 'DuHmey';

  @override
  String get menuInputTrain => 'lab qeq';

  @override
  String get menuListenTrain => '\'Ij qeq';

  @override
  String get menuListenTutorial => '\'Ij ghojmoH';

  @override
  String get menuInputTutorial => 'lab ghojmoH';

  @override
  String get aboutIntro => 'morS ngoq ghojmeH jan.';

  @override
  String get aboutPartsHeading => 'jan \'ay\'mey';

  @override
  String get aboutAboutDesc => 'jan De\' \'ang navvam.';

  @override
  String get aboutSettingsDesc =>
      'leQ lurgh, Do, wab, Hol, HaSta je DaSeHlaH. reH Qap USB jan leQmey je — wIv poQbe\'lu\'.';

  @override
  String get aboutInputTrainDesc =>
      'ngutlh cha\'lu\'; morS ngoq Dalab. Dalabpu\'bogh yaj ghojmoHwI\' \'ej bIlughchugh Duja\'.';

  @override
  String get aboutListenTrainDesc =>
      'ngutlh morS wab chu\' ghojmoHwI\'; ngutlh DaQoypu\'bogh DaghItlh.';

  @override
  String get aboutListenTutorialDesc =>
      '\'Ij ghojmeH 26 patlh. patlh HochDaq ngutlh chu\' \'anglu\' (Koch mIw): ngutlh cha\'lu\' \'ej morS chu\'lu\'; taghmeH yIghItlh; ngugh Hoch ngutlhmey ngaQHa\'pu\'bogh qeq, wejlogh lugh Hoch. patlh DarInDI\' veb ngaQHa\'; qeq qawlu\'.';

  @override
  String get aboutInputTutorialDesc =>
      'rap 26 patlh \'ach tammey Da\'mey: labmeH ghojmoH. patlh HochDaq ngutlh chu\' QIn je \'anglu\'; taghmeH ngoq yIlab. qeqDaq ngoq So\'lu\' — ngutlh neH cha\'lu\' — \'ej qawlI\'vo\' morS Dalab. \"yIQoy\" leQ wab chu\'; qeS ngoq \'anglaH. \'Ij ghojmoH pIm qeq qawlu\'.';

  @override
  String get aboutUsbHeading => 'USB morS jan';

  @override
  String get aboutUsbBody =>
      'morS jan cha\' leQ ghaj (USB 413d:2107). Linux-Daq /dev/hidraw lo\'lu\' — driver poQbe\'lu\' (plugdev ghom / udev chut poQlu\'). Ctrl-poS Ctrl-nIH je Da leQmey. iambic mIwDaq dit dah je lughmoH software — wa\' leQ dit, wa\' leQ dah; cha\' Da\'uychugh tlhej. leQ mob mIwDaq (DuHmeyDaq wIv) wa\' leQ Da Hoch \'ej poH DachenmoH: \'uyDI\' wab chu\'lu\'; cha\' dit puSchugh \'uy dit \'oH, nI\'chugh dah \'oH.';

  @override
  String get aboutTimingHeading => 'poH';

  @override
  String get aboutTimingBody =>
      'Do: mu\'mey rep (WPM), PARIS mIw: dit = 1200 / WPM ms; dah = wej dit; \'ay\' bIng = wa\' dit; ngutlh bIng = wej dit.';

  @override
  String aboutVersion(Object version) {
    return 'verSIn $version';
  }

  @override
  String get settingsInputDevice => 'lab jan';

  @override
  String get settingsInputDeviceBody =>
      'reH Qap leQmey (poS/nIH, . -) USB jan (413d:2107) je. jan DararDI\' tugh Qap.';

  @override
  String get settingsUsbActsAsKeyboard =>
      'naDev leQmey Da USB jan — yIrar \'ej Qap (poS/nIH-Ctrl).';

  @override
  String settingsUsbDetected(Object path) {
    return 'USB jan 413d:2107 tu\'lu\': $path';
  }

  @override
  String get settingsUsbNotDetected =>
      'USB jan 413d:2107 tu\'lu\'be\' — DararDI\' rar. Qapbe\'chugh, chaw\' yIlegh (Linux: /dev/hidraw*; macOS: Input Monitoring).';

  @override
  String get settingsRescan => 'yInejqa\'';

  @override
  String get settingsPaddleOrientation => 'leQ lurgh';

  @override
  String get settingsSpeed => 'Do';

  @override
  String get settingsKeyingSpeed => 'lab Do';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM  (dit = $ditMs ms)';
  }

  @override
  String get settingsSideTone => 'retlh wab';

  @override
  String get settingsVolume => 'wab tIn';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => 'wab qu\'';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'wab yIwaH';

  @override
  String get settingsNoAudio =>
      'wab jan tu\'lu\'be\' (Linux: pacat / PulseAudio poQlu\').';

  @override
  String get settingsCharacterSet => 'qeq ngutlhmey';

  @override
  String get settingsAppearance => 'HaSta';

  @override
  String get settingsLanguage => 'Hol';

  @override
  String get languageSystem => 'pat tlha\'';

  @override
  String get themeSystem => 'pat tlha\'';

  @override
  String get themeLight => 'wov';

  @override
  String get themeDark => 'Hurgh';

  @override
  String get ditPaddleLeft => 'poS leQ = dit';

  @override
  String get ditPaddleRight => 'nIH leQ = dit';

  @override
  String get charSetLetters => 'ngutlhmey';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => 'mI\'mey';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'ngutlhmey + mI\'mey';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => 'latlh ngutlhmey';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'Hoch';

  @override
  String get charSetAllDesc => 'ngutlhmey, mI\'mey, latlh';

  @override
  String get statusStarting => 'tagh…';

  @override
  String score(Object correct, Object attempts) {
    return 'mI\': $correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'ngutlhvam yIlab:';

  @override
  String get showHint => 'qeS yI\'ang';

  @override
  String get youAreKeying => 'Dalab:';

  @override
  String get correct => 'lugh! majQa\'!';

  @override
  String youKeyedTryAgain(Object decoded) {
    return '\"$decoded\" Dalabpu\' — yInIDqa\'';
  }

  @override
  String get clear => 'yIchImmoH';

  @override
  String get skipNext => 'veb';

  @override
  String get audioMissingListenTrain =>
      'wab Hutlh (pacat / PulseAudio poQlu\') — wab poQ \'Ij qeq.';

  @override
  String get listenThenType => 'yI\'Ij, vaj ngutlh DaQoypu\'bogh yIghItlh';

  @override
  String get tapKeyBelow => 'bIngDaq leQ yI\'uy.';

  @override
  String get typeKeyHint => 'ngutlh leQ yI\'uy (Qapbe\'chugh naDev yI\'uy).';

  @override
  String get replay => 'yIQoyqa\'';

  @override
  String get reveal => 'yI\'ang';

  @override
  String itWas(Object char, Object morse) {
    return '\"$char\" \'oH   ($morse)';
  }

  @override
  String get notQuiteListen => 'Qagh — yI\'Ijqa\'';

  @override
  String get audioMissingTutorial => 'wab Hutlh — wab poQ \'Ij ghojmoH.';

  @override
  String levelOf(Object level, Object count) {
    return 'patlh $level / $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'patlh $level  ($letter)';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total ngutlhmey Daghojpu\'';
  }

  @override
  String get newLetter => 'ngutlh chu\'';

  @override
  String get listenTypeToBegin => 'yI\'Ij, vaj taghmeH ngutlhvam yIghItlh';

  @override
  String get greatStartingPractice => 'majQa\' — qeq tagh…';

  @override
  String get typeLetterYouHear => 'ngutlh DaQoybogh yIghItlh';

  @override
  String get tutorialComplete => 'rIn ghojmoH! majQa\'!';

  @override
  String levelComplete(Object level) {
    return 'rIn patlh $level!';
  }

  @override
  String learnedAllLetters(Object count) {
    return 'Hoch $count ngutlhmey Daghojpu\'. majQa\'!';
  }

  @override
  String youMastered(Object letters) {
    return '$letters Daghojpu\'.';
  }

  @override
  String get repeatLevelEsc => 'patlh yIqeqqa\' (Esc)';

  @override
  String get nextLevelEnter => 'patlh veb (Enter)';

  @override
  String get keyPatternToBegin => 'taghmeH ngoqvam yIlab';

  @override
  String get keyThisLetter => 'ngutlhvam yIlab';

  @override
  String canKeyAllLetters(Object count) {
    return 'Hoch $count ngutlhmey DalablaH. majQa\'!';
  }

  @override
  String masteredKeying(Object letters) {
    return '$letters lab Daghojpu\'.';
  }

  @override
  String get hearIt => 'yIQoy';

  @override
  String get statusKeyboardReady => 'leQmey SIQ (←/→)';

  @override
  String get statusPaddlesTouch => 'leQmey: ←/→, pagh USB jan (leQmey Da)';

  @override
  String get statusUsbWaiting => 'USB jan tu\'lu\'be\' — DararDI\' rar';

  @override
  String statusUsbConnected(Object detail) {
    return 'rarlu\' USB jan: $detail';
  }

  @override
  String get statusUsbUnplugged => 'teqlu\'pu\' USB jan — DararDI\' rarqa\'';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return '$path tu\'lu\' \'ach poSmoHlaHbe\' (chaw\'?): $error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'USB jan poSmoHlaHbe\' (IOReturn $code) — Input Monitoring chaw\' yInob';
  }

  @override
  String statusUsbError(Object error) {
    return 'USB jan Qagh: $error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · ←/→ je Qap';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'leQmey: ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'tlhab ghItlh';

  @override
  String get freeTypeInputLabel => 'naDev yIghItlh';

  @override
  String get freeTypeMorseLabel => 'morS';

  @override
  String get freeTypeAudioOn => 'wab Qap';

  @override
  String get freeTypeAudioOff => 'wab tam';

  @override
  String get aboutFreeTypeDesc =>
      'vay\' DaghItlh \'ej morS Dalegh — Do DawIvpu\'bogh lo\'lu\' \'ej DaneHchugh wab je chu\'lu\'.';

  @override
  String get menuFreeKey => 'tlhab lab';

  @override
  String get freeKeyTextLabel => 'ghItlh';

  @override
  String get aboutFreeKeyDesc =>
      'tlhab ghItlh tammey: morS Dalab \'ej ngutlhmey mojmoH jan — Dalab morS \'anglu\', rInDI\' ngutlh ghItlhlu\'. mu\' bIng DaneHchugh Soch dit yIloS.';

  @override
  String get settingsKeyerMode => 'leQ mIw';

  @override
  String get keyerModeIambic => 'cha\' leQ (iambic)';

  @override
  String get keyerModeIambicDesc =>
      'cha\' leQ — wa\' dit, wa\' dah; cha\' Da\'uychugh tlhej';

  @override
  String get keyerModeStraight => 'leQ mob';

  @override
  String get keyerModeStraightDesc =>
      'wa\' leQ neH — poH DachenmoH: \'uy ngaj dit \'oH, \'uy nI\' dah \'oH';
}
