// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Welsh (`cy`).
class AppLocalizationsCy extends AppLocalizations {
  AppLocalizationsCy([String locale = 'cy']) : super(locale);

  @override
  String get appTitle => 'Hyfforddwr Morse';

  @override
  String get menuAbout => 'Ynghylch';

  @override
  String get menuSettings => 'Gosodiadau';

  @override
  String get menuInputTrain => 'Ymarfer Bysellu';

  @override
  String get menuListenTrain => 'Ymarfer Gwrando';

  @override
  String get menuListenTutorial => 'Tiwtorial Gwrando';

  @override
  String get menuInputTutorial => 'Tiwtorial Bysellu';

  @override
  String get aboutIntro =>
      'Offeryn ymarfer ar gyfer dysgu cod Morse, wedi\'i ysgrifennu yn Dart / Flutter.';

  @override
  String get aboutPartsHeading => 'Rhannau\'r rhaglen';

  @override
  String get aboutAboutDesc =>
      'Y dudalen hon — disgrifiad o\'r rhaglen a sut mae\'n gweithio.';

  @override
  String get aboutSettingsDesc =>
      'Gosodwch gyfeiriadedd y padlau, cyflymder bysellu, lefel sain ac amledd y tôn ochr, yr iaith, a\'r ymddangosiad golau/tywyll. Mae\'r allwedd USB a phadlau\'r bysellfwrdd ill dau bob amser yn weithredol — nid oes angen dewis mewnbwn.';

  @override
  String get aboutInputTrainDesc =>
      'Dangosir nod ac rydych yn ei fysellu mewn Morse. Mae\'r hyfforddwr yn datgodio\'r hyn a anfonwch ac yn dweud wrthych a oedd yn gywir.';

  @override
  String get aboutListenTrainDesc =>
      'Mae\'r hyfforddwr yn chwarae nod fel sain Morse ac rydych yn teipio\'r nod a glywsoch.';

  @override
  String get aboutListenTutorialDesc =>
      'Cwrs gwrando dan arweiniad, 26 lefel. Mae pob lefel yn cyflwyno un llythyren newydd (trefn dull Koch — y seiniau hawsaf i\'w gwahaniaethu yn gyntaf): dangosir y llythyren a chwaraeir ei Morse, teipiwch hi i ddechrau, yna rhedir dril ar hap o bob llythyren a ddatglowyd hyd yma nes bod pob un wedi\'i hateb yn gywir dair gwaith. Mae cwblhau lefel yn datgloi\'r nesaf, a chofir eich cynnydd.';

  @override
  String get aboutInputTutorialDesc =>
      'Yr un cwrs 26 lefel gyda\'r rolau wedi\'u cyfnewid, i ddysgu anfon. Mae pob lefel yn dangos dotiau a llinellau\'r llythyren newydd gyda\'r llythyren wrth eu hymyl; bysellwch y patrwm i ddechrau. Wrth ymarfer, tynnir y patrwm i ffwrdd — dangosir y llythyren yn unig — a bysellwch ei Morse o\'r cof gyda\'r padl neu\'r bysellfwrdd, gan wylio\'n fyw yr hyn rydych yn ei fysellu. Mae botwm \"Clywed\" yn chwarae rhythm y targed, a gall awgrym ddatgelu\'r patrwm os byddwch yn sownd. Cedwir cynnydd ar wahân i\'r Tiwtorial Gwrando.';

  @override
  String get aboutUsbHeading => 'Yr allwedd Morse USB';

  @override
  String get aboutUsbBody =>
      'Mae\'r rhaglen hon yn cefnogi allwedd Morse iambig (padl ddeuol) sy\'n ymddangos dros USB fel dyfais 413d:2107. Ar Linux darllenir yr allwedd yn uniongyrchol o\'i nod /dev/hidraw — nid oes angen gyrwyr, cyn belled â bod eich defnyddiwr yn gallu darllen y ddyfais (y grŵp plugdev / rheol udev). Adroddir pob padl fel did addasydd bysellfwrdd (Ctrl-Chwith a Ctrl-Dde); mae\'r feddalwedd yn troi\'r pwysiadau hynny\'n ditiau a dahiau wedi\'u hamseru\'n gywir.';

  @override
  String get aboutTimingHeading => 'Amseru';

  @override
  String get aboutTimingBody =>
      'Mynegir cyflymder mewn geiriau y funud (WPM) gan ddefnyddio amseru safonol PARIS: un dit = 1200 / WPM milieiliad, mae dah yn dri dit, y bwlch rhwng elfennau yw un dit, a\'r bwlch rhwng llythrennau yw tri dit.';

  @override
  String aboutVersion(Object version) {
    return 'Fersiwn $version';
  }

  @override
  String get settingsInputDevice => 'Dyfais fewnbwn';

  @override
  String get settingsInputDeviceBody =>
      'Mae padlau\'r bysellfwrdd (saethau Chwith/Dde, neu . a -) a\'r allwedd USB (413d:2107) ill dau bob amser yn weithredol — mae bysellu\'n gweithio o ba un bynnag a gyffyrddwch. Plygiwch yr allwedd i mewn unrhyw bryd ac fe fydd yn gweithio.';

  @override
  String get settingsUsbActsAsKeyboard =>
      'Yma mae\'r allwedd USB yn gweithredu fel bysellfwrdd — plygiwch hi i mewn; mae\'r padlau\'n cyrraedd fel Ctrl-Chwith/Dde.';

  @override
  String settingsUsbDetected(Object path) {
    return 'Canfuwyd allwedd USB 413d:2107: $path';
  }

  @override
  String get settingsUsbNotDetected =>
      'Ni chanfuwyd allwedd USB 413d:2107 — bydd yn cysylltu pan gaiff ei phlygio i mewn. Os na wnaiff byth, gwiriwch ganiatâd (Linux: /dev/hidraw*; macOS: Monitro Mewnbwn yng Ngosodiadau\'r System).';

  @override
  String get settingsRescan => 'Ail-sganio';

  @override
  String get settingsPaddleOrientation => 'Cyfeiriadedd y padlau';

  @override
  String get settingsSpeed => 'Cyflymder';

  @override
  String get settingsKeyingSpeed => 'Cyflymder bysellu';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM  (dit = $ditMs ms)';
  }

  @override
  String get settingsSideTone => 'Tôn ochr';

  @override
  String get settingsVolume => 'Lefel sain';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => 'Amledd';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'Tôn brawf';

  @override
  String get settingsNoAudio =>
      'Dim cefn sain ar gael (Linux: angen pacat / PulseAudio).';

  @override
  String get settingsCharacterSet => 'Set nodau hyfforddi';

  @override
  String get settingsAppearance => 'Ymddangosiad';

  @override
  String get settingsLanguage => 'Iaith';

  @override
  String get languageSystem => 'Dilyn y system';

  @override
  String get themeSystem => 'Dilyn y system';

  @override
  String get themeLight => 'Golau';

  @override
  String get themeDark => 'Tywyll';

  @override
  String get ditPaddleLeft => 'Padl chwith = dit';

  @override
  String get ditPaddleRight => 'Padl dde = dit';

  @override
  String get charSetLetters => 'Llythrennau';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => 'Rhifau';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'Llythrennau + Rhifau';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => 'Atalnodi';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'Popeth';

  @override
  String get charSetAllDesc => 'llythrennau, rhifau, atalnodi';

  @override
  String get statusStarting => 'Yn cychwyn…';

  @override
  String score(Object correct, Object attempts) {
    return 'Sgôr: $correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'Bysellwch y nod hwn:';

  @override
  String get showHint => 'Dangos awgrym';

  @override
  String get youAreKeying => 'Rydych yn bysellu:';

  @override
  String get correct => 'Cywir!';

  @override
  String youKeyedTryAgain(Object decoded) {
    return 'Bysellwyd \"$decoded\" — ceisiwch eto';
  }

  @override
  String get clear => 'Clirio';

  @override
  String get skipNext => 'Hepgor / Nesaf';

  @override
  String get audioMissingListenTrain =>
      'Dim cefn sain ar gael (angen pacat / PulseAudio) — mae angen sain ar Ymarfer Gwrando.';

  @override
  String get listenThenType => 'Gwrandewch, yna teipiwch y nod a glywsoch';

  @override
  String get tapKeyBelow => 'Tapiwch y fysell gyfatebol isod.';

  @override
  String get typeKeyHint =>
      'Teipiwch fysell llythyren/rhif (cliciwch yma os nad yw teipio\'n gwneud dim).';

  @override
  String get replay => 'Ailchwarae';

  @override
  String get reveal => 'Datgelu';

  @override
  String itWas(Object char, Object morse) {
    return '\"$char\" ydoedd   ($morse)';
  }

  @override
  String get notQuiteListen => 'Ddim yn hollol — gwrandewch eto';

  @override
  String get audioMissingTutorial =>
      'Dim cefn sain ar gael — mae angen sain ar y Tiwtorial Gwrando.';

  @override
  String levelOf(Object level, Object count) {
    return 'Lefel $level o $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'Lefel $level  ($letter)';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total llythyren wedi\'u meistroli';
  }

  @override
  String get newLetter => 'Llythyren newydd';

  @override
  String get listenTypeToBegin =>
      'Gwrandewch, yna teipiwch y llythyren hon i ddechrau';

  @override
  String get greatStartingPractice => 'Gwych — yn dechrau ymarfer…';

  @override
  String get typeLetterYouHear => 'Teipiwch y llythyren a glywch';

  @override
  String get tutorialComplete => 'Tiwtorial wedi\'i gwblhau!';

  @override
  String levelComplete(Object level) {
    return 'Lefel $level wedi\'i chwblhau!';
  }

  @override
  String learnedAllLetters(Object count) {
    return 'Rydych wedi dysgu pob un o\'r $count llythyren. Da iawn!';
  }

  @override
  String youMastered(Object letters) {
    return 'Fe wnaethoch feistroli $letters.';
  }

  @override
  String get repeatLevelEsc => 'Ailadrodd y lefel (Esc)';

  @override
  String get nextLevelEnter => 'Lefel nesaf (Enter)';

  @override
  String get keyPatternToBegin => 'Bysellwch y patrwm hwn i ddechrau';

  @override
  String get keyThisLetter => 'Bysellwch y llythyren hon';

  @override
  String canKeyAllLetters(Object count) {
    return 'Gallwch fysellu pob un o\'r $count llythyren. Da iawn!';
  }

  @override
  String masteredKeying(Object letters) {
    return 'Fe wnaethoch feistroli bysellu $letters.';
  }

  @override
  String get hearIt => 'Clywed';

  @override
  String get statusKeyboardReady => 'Padlau\'r bysellfwrdd yn barod (←/→)';

  @override
  String get statusPaddlesTouch =>
      'Padlau: bysellfwrdd ←/→, neu\'r allwedd USB (fel bysellfwrdd)';

  @override
  String get statusUsbWaiting =>
      'Allwedd USB heb ei chanfod — plygiwch hi i mewn ac fe gysylltir';

  @override
  String statusUsbConnected(Object detail) {
    return 'Allwedd USB wedi cysylltu: $detail';
  }

  @override
  String get statusUsbUnplugged =>
      'Allwedd USB wedi\'i datgysylltu — ailgysylltir pan gaiff ei phlygio i mewn';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return 'Canfuwyd $path ond methu ei agor (caniatâd?): $error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'Methu agor yr allwedd USB (IOReturn $code) — rhowch ganiatâd Monitro Mewnbwn yng Ngosodiadau\'r System';
  }

  @override
  String statusUsbError(Object error) {
    return 'Gwall allwedd USB: $error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · bysellfwrdd ←/→ hefyd yn weithredol';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'Padlau: bysellfwrdd ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'Teipio Rhydd';

  @override
  String get freeTypeInputLabel => 'Teipiwch destun yma';

  @override
  String get freeTypeMorseLabel => 'Morse';

  @override
  String get freeTypeAudioOn => 'Sain ymlaen';

  @override
  String get freeTypeAudioOff => 'Sain i ffwrdd';

  @override
  String get aboutFreeTypeDesc =>
      'Teipiwch unrhyw destun a\'i weld fel Morse — mae\'r dotiau a\'r llinellau\'n ymddangos ar eich cyflymder dewisedig, gyda sain ddewisol yn chwarae\'n gydamserol.';

  @override
  String get menuFreeKey => 'Bysellu Rhydd';

  @override
  String get freeKeyTextLabel => 'Testun';

  @override
  String get aboutFreeKeyDesc =>
      'Gwrthwyneb Teipio Rhydd: bysellwch Morse gyda\'r padl neu\'r bysellfwrdd a\'i weld yn cael ei ddatgodio\'n destun — mae\'r dotiau a\'r llinellau\'n ymddangos yn y blwch Morse wrth i chi fysellu, ac ysgrifennir nodau gorffenedig fel testun. Oedwch saith dit i gael bwlch gair.';

  @override
  String get settingsKeyerMode => 'Modd bysellu';

  @override
  String get keyerModeIambic => 'Padlau iambig';

  @override
  String get keyerModeIambicDesc =>
      'Dau badl — un ar gyfer ditiau, un ar gyfer dahiau; gwasgwch y ddau am ailadrodd bob yn ail';

  @override
  String get keyerModeStraight => 'Allwedd syth';

  @override
  String get keyerModeStraightDesc =>
      'Un allwedd — chi sy\'n amseru: mae pwysiad byr yn dit, a phwysiad hir yn dah';
}
