// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Morse-Trainer';

  @override
  String get menuAbout => 'Über';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuInputTrain => 'Gebeübung';

  @override
  String get menuListenTrain => 'Hörübung';

  @override
  String get menuListenTutorial => 'Hör-Tutorial';

  @override
  String get menuInputTutorial => 'Gebe-Tutorial';

  @override
  String get aboutIntro =>
      'Ein Übungsprogramm zum Erlernen des Morsecodes, geschrieben in Dart / Flutter.';

  @override
  String get aboutPartsHeading => 'Die Teile des Programms';

  @override
  String get aboutAboutDesc =>
      'Diese Seite — eine Beschreibung des Programms und seiner Funktionsweise.';

  @override
  String get aboutSettingsDesc =>
      'Stellen Sie die Paddel-Ausrichtung, die Gebegeschwindigkeit, Lautstärke und Frequenz des Mithörtons, die Sprache und das helle/dunkle Erscheinungsbild ein. USB-Taste und Tastatur-Paddel sind immer beide aktiv — keine Eingabeauswahl nötig.';

  @override
  String get aboutInputTrainDesc =>
      'Ein Zeichen wird angezeigt und Sie geben es in Morse. Der Trainer dekodiert Ihre Sendung und sagt Ihnen, ob sie richtig war.';

  @override
  String get aboutListenTrainDesc =>
      'Der Trainer spielt ein Zeichen als Morse-Audio und Sie tippen das gehörte Zeichen.';

  @override
  String get aboutListenTutorialDesc =>
      'Ein geführter Hörkurs mit 26 Stufen. Jede Stufe führt einen neuen Buchstaben ein (Koch-Methode — die am leichtesten unterscheidbaren Klänge zuerst): Der Buchstabe wird angezeigt und sein Morse gespielt, tippen Sie ihn zum Start; danach läuft eine zufällige Übung über alle freigeschalteten Buchstaben, bis jeder dreimal richtig beantwortet wurde. Der Abschluss einer Stufe schaltet die nächste frei, und Ihr Fortschritt wird gespeichert.';

  @override
  String get aboutInputTutorialDesc =>
      'Derselbe Kurs mit vertauschten Rollen, um das Geben zu lernen. Jede Stufe zeigt die Punkte und Striche des neuen Buchstabens mit dem Buchstaben daneben; geben Sie das Muster zum Start. In der Übung verschwindet das Muster — nur der Buchstabe wird angezeigt — und Sie geben sein Morse aus dem Gedächtnis mit Paddel oder Tastatur, mit Live-Anzeige Ihrer Eingabe. Ein „Anhören“-Knopf spielt den Rhythmus des Ziels, und ein Hinweis kann das Muster aufdecken. Der Fortschritt wird getrennt vom Hör-Tutorial gespeichert.';

  @override
  String get aboutUsbHeading => 'Die USB-Morsetaste';

  @override
  String get aboutUsbBody =>
      'Dieses Programm unterstützt eine iambische Morsetaste (Doppelpaddel), die sich über USB als Gerät 413d:2107 meldet. Unter Linux wird die Taste direkt über ihren /dev/hidraw-Knoten gelesen — keine Treiber nötig, solange Ihr Benutzer das Gerät lesen darf (plugdev-Gruppe / udev-Regel). Jedes Paddel wird als Tastatur-Modifikatorbit gemeldet (Strg-Links und Strg-Rechts); die Software macht daraus korrekt getaktete Dits und Dahs.';

  @override
  String get aboutTimingHeading => 'Timing';

  @override
  String get aboutTimingBody =>
      'Die Geschwindigkeit wird in Wörtern pro Minute (WPM) nach dem PARIS-Standard angegeben: ein Dit = 1200 / WPM Millisekunden, ein Dah sind drei Dits, die Pause zwischen Elementen ein Dit und zwischen Buchstaben drei Dits.';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get settingsInputDevice => 'Eingabegerät';

  @override
  String get settingsInputDeviceBody =>
      'Die Tastatur-Paddel (Pfeil Links/Rechts oder . und -) und die USB-Taste (413d:2107) sind immer beide aktiv — das Geben funktioniert mit beiden. Die Taste kann jederzeit eingesteckt werden und funktioniert sofort.';

  @override
  String get settingsUsbActsAsKeyboard =>
      'Hier verhält sich die USB-Taste wie eine Tastatur — einfach einstecken; die Paddel kommen als Strg-Links/Rechts an.';

  @override
  String settingsUsbDetected(Object path) {
    return 'USB-Taste 413d:2107 erkannt: $path';
  }

  @override
  String get settingsUsbNotDetected =>
      'USB-Taste 413d:2107 nicht erkannt — sie verbindet sich nach dem Einstecken. Falls nicht, prüfen Sie die Berechtigungen (Linux: /dev/hidraw*; macOS: Eingabeüberwachung in den Systemeinstellungen).';

  @override
  String get settingsRescan => 'Neu suchen';

  @override
  String get settingsPaddleOrientation => 'Paddel-Ausrichtung';

  @override
  String get settingsSpeed => 'Geschwindigkeit';

  @override
  String get settingsKeyingSpeed => 'Gebegeschwindigkeit';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM  (Dit = $ditMs ms)';
  }

  @override
  String get settingsSideTone => 'Mithörton';

  @override
  String get settingsVolume => 'Lautstärke';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => 'Frequenz';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'Ton testen';

  @override
  String get settingsNoAudio =>
      'Kein Audio-Backend verfügbar (Linux: benötigt pacat / PulseAudio).';

  @override
  String get settingsCharacterSet => 'Zeichensatz für die Übung';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'System folgen';

  @override
  String get themeSystem => 'System folgen';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get ditPaddleLeft => 'Linkes Paddel = Dit';

  @override
  String get ditPaddleRight => 'Rechtes Paddel = Dit';

  @override
  String get charSetLetters => 'Buchstaben';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => 'Ziffern';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'Buchstaben + Ziffern';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => 'Satzzeichen';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'Alles';

  @override
  String get charSetAllDesc => 'Buchstaben, Ziffern, Satzzeichen';

  @override
  String get statusStarting => 'Startet…';

  @override
  String score(Object correct, Object attempts) {
    return 'Punkte: $correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'Geben Sie dieses Zeichen:';

  @override
  String get showHint => 'Hinweis anzeigen';

  @override
  String get youAreKeying => 'Sie geben:';

  @override
  String get correct => 'Richtig!';

  @override
  String youKeyedTryAgain(Object decoded) {
    return 'Sie gaben „$decoded“ — versuchen Sie es erneut';
  }

  @override
  String get clear => 'Löschen';

  @override
  String get skipNext => 'Überspringen / Weiter';

  @override
  String get audioMissingListenTrain =>
      'Kein Audio-Backend verfügbar (benötigt pacat / PulseAudio) — die Hörübung braucht Ton.';

  @override
  String get listenThenType =>
      'Hören Sie zu und tippen Sie dann das gehörte Zeichen';

  @override
  String get tapKeyBelow => 'Tippen Sie unten auf die passende Taste.';

  @override
  String get typeKeyHint =>
      'Tippen Sie einen Buchstaben oder eine Ziffer (hier klicken, falls nichts passiert).';

  @override
  String get replay => 'Wiederholen';

  @override
  String get reveal => 'Aufdecken';

  @override
  String itWas(Object char, Object morse) {
    return 'Es war „$char“   ($morse)';
  }

  @override
  String get notQuiteListen => 'Nicht ganz — hören Sie noch einmal';

  @override
  String get audioMissingTutorial =>
      'Kein Audio-Backend verfügbar — das Hör-Tutorial braucht Ton.';

  @override
  String levelOf(Object level, Object count) {
    return 'Stufe $level von $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'Stufe $level  ($letter)';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total Buchstaben gemeistert';
  }

  @override
  String get newLetter => 'Neuer Buchstabe';

  @override
  String get listenTypeToBegin =>
      'Hören Sie zu und tippen Sie diesen Buchstaben zum Start';

  @override
  String get greatStartingPractice => 'Prima — die Übung beginnt…';

  @override
  String get typeLetterYouHear => 'Tippen Sie den Buchstaben, den Sie hören';

  @override
  String get tutorialComplete => 'Tutorial abgeschlossen!';

  @override
  String levelComplete(Object level) {
    return 'Stufe $level geschafft!';
  }

  @override
  String learnedAllLetters(Object count) {
    return 'Sie haben alle $count Buchstaben gelernt. Gut gemacht!';
  }

  @override
  String youMastered(Object letters) {
    return 'Sie haben $letters gemeistert.';
  }

  @override
  String get repeatLevelEsc => 'Stufe wiederholen (Esc)';

  @override
  String get nextLevelEnter => 'Nächste Stufe (Enter)';

  @override
  String get keyPatternToBegin => 'Geben Sie dieses Muster zum Start';

  @override
  String get keyThisLetter => 'Geben Sie diesen Buchstaben';

  @override
  String canKeyAllLetters(Object count) {
    return 'Sie können alle $count Buchstaben geben. Gut gemacht!';
  }

  @override
  String masteredKeying(Object letters) {
    return 'Sie haben das Geben von $letters gemeistert.';
  }

  @override
  String get hearIt => 'Anhören';

  @override
  String get statusKeyboardReady => 'Tastatur-Paddel bereit (←/→)';

  @override
  String get statusPaddlesTouch =>
      'Paddel: Tastatur ←/→ oder die USB-Taste (verhält sich wie eine Tastatur)';

  @override
  String get statusUsbWaiting =>
      'USB-Taste nicht erkannt — einstecken, dann verbindet sie sich';

  @override
  String statusUsbConnected(Object detail) {
    return 'USB-Taste verbunden: $detail';
  }

  @override
  String get statusUsbUnplugged =>
      'USB-Taste abgezogen — verbindet sich nach dem Einstecken neu';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return '$path gefunden, aber nicht zu öffnen (Berechtigungen?): $error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'USB-Taste lässt sich nicht öffnen (IOReturn $code) — erlauben Sie die Eingabeüberwachung in den Systemeinstellungen';
  }

  @override
  String statusUsbError(Object error) {
    return 'USB-Tasten-Fehler: $error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · Tastatur ←/→ ebenfalls aktiv';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'Paddel: Tastatur ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'Freies Tippen';

  @override
  String get freeTypeInputLabel => 'Text hier eingeben';

  @override
  String get freeTypeMorseLabel => 'Morse';

  @override
  String get freeTypeAudioOn => 'Ton an';

  @override
  String get freeTypeAudioOff => 'Ton aus';

  @override
  String get aboutFreeTypeDesc =>
      'Tippen Sie beliebigen Text und sehen Sie ihn als Morse — Punkte und Striche erscheinen in der eingestellten Geschwindigkeit, auf Wunsch mit synchronem Ton.';
}
