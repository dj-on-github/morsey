// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Entraîneur Morse';

  @override
  String get menuAbout => 'À propos';

  @override
  String get menuSettings => 'Réglages';

  @override
  String get menuInputTrain => 'Exercice d\'envoi';

  @override
  String get menuListenTrain => 'Exercice d\'écoute';

  @override
  String get menuListenTutorial => 'Tutoriel d\'écoute';

  @override
  String get menuInputTutorial => 'Tutoriel d\'envoi';

  @override
  String get aboutIntro =>
      'Un outil d\'entraînement pour apprendre le code Morse.';

  @override
  String get aboutPartsHeading => 'Les parties du programme';

  @override
  String get aboutAboutDesc =>
      'Cette page — une description du programme et de son fonctionnement.';

  @override
  String get aboutSettingsDesc =>
      'Réglez l\'orientation des palettes, la vitesse de manipulation, le volume et la fréquence de la tonalité, la langue et l\'apparence claire/sombre. La clé USB et les palettes du clavier sont toujours actives — aucune sélection d\'entrée n\'est nécessaire.';

  @override
  String get aboutInputTrainDesc =>
      'Un caractère s\'affiche et vous le manipulez en Morse. L\'entraîneur décode ce que vous envoyez et vous dit si c\'était correct.';

  @override
  String get aboutListenTrainDesc =>
      'L\'entraîneur joue un caractère en audio Morse et vous tapez le caractère entendu.';

  @override
  String get aboutListenTutorialDesc =>
      'Un cours d\'écoute guidé en 26 niveaux. Chaque niveau introduit une nouvelle lettre (ordre de la méthode Koch — les sons les plus faciles à distinguer d\'abord) : la lettre s\'affiche et son Morse est joué, tapez-la pour commencer, puis un exercice aléatoire sur toutes les lettres débloquées se poursuit jusqu\'à ce que chacune ait reçu trois bonnes réponses. Terminer un niveau débloque le suivant, et votre progression est mémorisée.';

  @override
  String get aboutInputTutorialDesc =>
      'Le même cours en 26 niveaux avec les rôles inversés, pour apprendre à envoyer. Chaque niveau montre les points et les traits de la nouvelle lettre avec la lettre à côté ; manipulez le motif pour commencer. En exercice, le motif disparaît — seule la lettre s\'affiche — et vous manipulez son Morse de mémoire avec la palette ou le clavier, en suivant en direct ce que vous manipulez. Un bouton « Écouter » joue le rythme de la cible, et un indice peut révéler le motif si vous êtes bloqué. La progression est suivie séparément du Tutoriel d\'écoute.';

  @override
  String get aboutUsbHeading => 'La clé Morse USB';

  @override
  String get aboutUsbBody =>
      'Ce programme prend en charge une clé Morse ïambique (double palette) qui s\'énumère en USB comme périphérique 413d:2107. Sous Linux, la clé est lue directement depuis son nœud /dev/hidraw — aucun pilote requis, tant que votre utilisateur peut lire le périphérique (groupe plugdev / règle udev). Chaque palette est signalée comme un bit modificateur de clavier (Ctrl-gauche et Ctrl-droite). En mode ïambique, le logiciel transforme ces appuis en dits et dahs correctement synchronisés — une palette pour les dits, une pour les dahs, serrez les deux pour alterner. En mode manipulateur droit (choisi dans les Réglages), tout contact agit comme une touche unique et c\'est vous qui rythmez : la tonalité suit votre appui, un appui de moins de deux dits compte comme un dit, un appui plus long comme un dah.';

  @override
  String get aboutTimingHeading => 'Synchronisation';

  @override
  String get aboutTimingBody =>
      'La vitesse s\'exprime en mots par minute (WPM) selon la synchronisation PARIS standard : un dit = 1200 / WPM millisecondes, un dah vaut trois dits, l\'espace entre éléments vaut un dit et l\'espace entre lettres vaut trois dits.';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get settingsInputDevice => 'Périphérique d\'entrée';

  @override
  String get settingsInputDeviceBody =>
      'Les palettes du clavier (flèches Gauche/Droite, ou . et -) et la clé USB (413d:2107) sont toujours actives — la manipulation fonctionne avec l\'une ou l\'autre. Branchez la clé à tout moment et elle fonctionne.';

  @override
  String get settingsUsbActsAsKeyboard =>
      'Ici, la clé USB se comporte comme un clavier — branchez-la ; les palettes arrivent en Ctrl-gauche/droite.';

  @override
  String settingsUsbDetected(Object path) {
    return 'Clé USB 413d:2107 détectée : $path';
  }

  @override
  String get settingsUsbNotDetected =>
      'Clé USB 413d:2107 non détectée — elle se connectera une fois branchée. Sinon, vérifiez les permissions (Linux : /dev/hidraw* ; macOS : Surveillance de l\'entrée dans Réglages Système).';

  @override
  String get settingsRescan => 'Rescanner';

  @override
  String get settingsPaddleOrientation => 'Orientation des palettes';

  @override
  String get settingsSpeed => 'Vitesse';

  @override
  String get settingsKeyingSpeed => 'Vitesse de manipulation';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM  (dit = $ditMs ms)';
  }

  @override
  String get settingsSideTone => 'Tonalité locale';

  @override
  String get settingsVolume => 'Volume';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => 'Fréquence';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'Tester la tonalité';

  @override
  String get settingsNoAudio =>
      'Aucun backend audio disponible (Linux : nécessite pacat / PulseAudio).';

  @override
  String get settingsCharacterSet => 'Jeu de caractères d\'entraînement';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Suivre le système';

  @override
  String get themeSystem => 'Suivre le système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get ditPaddleLeft => 'Palette gauche = dit';

  @override
  String get ditPaddleRight => 'Palette droite = dit';

  @override
  String get charSetLetters => 'Lettres';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => 'Chiffres';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'Lettres + chiffres';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => 'Ponctuation';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'Tout';

  @override
  String get charSetAllDesc => 'lettres, chiffres, ponctuation';

  @override
  String get statusStarting => 'Démarrage…';

  @override
  String score(Object correct, Object attempts) {
    return 'Score : $correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'Manipulez ce caractère :';

  @override
  String get showHint => 'Afficher l\'indice';

  @override
  String get youAreKeying => 'Vous manipulez :';

  @override
  String get correct => 'Correct !';

  @override
  String youKeyedTryAgain(Object decoded) {
    return 'Vous avez manipulé « $decoded » — réessayez';
  }

  @override
  String get clear => 'Effacer';

  @override
  String get skipNext => 'Passer / Suivant';

  @override
  String get audioMissingListenTrain =>
      'Aucun backend audio disponible (nécessite pacat / PulseAudio) — l\'Exercice d\'écoute a besoin du son.';

  @override
  String get listenThenType => 'Écoutez, puis tapez le caractère entendu';

  @override
  String get tapKeyBelow => 'Touchez la touche correspondante ci-dessous.';

  @override
  String get typeKeyHint =>
      'Tapez une lettre ou un chiffre (cliquez ici si la saisie ne répond pas).';

  @override
  String get replay => 'Rejouer';

  @override
  String get reveal => 'Révéler';

  @override
  String itWas(Object char, Object morse) {
    return 'C\'était « $char »   ($morse)';
  }

  @override
  String get notQuiteListen => 'Pas tout à fait — réécoutez';

  @override
  String get audioMissingTutorial =>
      'Aucun backend audio disponible — le Tutoriel d\'écoute a besoin du son.';

  @override
  String levelOf(Object level, Object count) {
    return 'Niveau $level sur $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'Niveau $level  ($letter)';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total lettres maîtrisées';
  }

  @override
  String get newLetter => 'Nouvelle lettre';

  @override
  String get listenTypeToBegin =>
      'Écoutez, puis tapez cette lettre pour commencer';

  @override
  String get greatStartingPractice => 'Bravo — l\'exercice commence…';

  @override
  String get typeLetterYouHear => 'Tapez la lettre que vous entendez';

  @override
  String get tutorialComplete => 'Tutoriel terminé !';

  @override
  String levelComplete(Object level) {
    return 'Niveau $level terminé !';
  }

  @override
  String learnedAllLetters(Object count) {
    return 'Vous avez appris les $count lettres. Bravo !';
  }

  @override
  String youMastered(Object letters) {
    return 'Vous avez maîtrisé $letters.';
  }

  @override
  String get repeatLevelEsc => 'Répéter le niveau (Échap)';

  @override
  String get nextLevelEnter => 'Niveau suivant (Entrée)';

  @override
  String get keyPatternToBegin => 'Manipulez ce motif pour commencer';

  @override
  String get keyThisLetter => 'Manipulez cette lettre';

  @override
  String canKeyAllLetters(Object count) {
    return 'Vous savez manipuler les $count lettres. Bravo !';
  }

  @override
  String masteredKeying(Object letters) {
    return 'Vous avez maîtrisé l\'envoi de $letters.';
  }

  @override
  String get hearIt => 'Écouter';

  @override
  String get statusKeyboardReady => 'Palettes clavier prêtes (←/→)';

  @override
  String get statusPaddlesTouch =>
      'Palettes : clavier ←/→, ou la clé USB (se comporte comme un clavier)';

  @override
  String get statusUsbWaiting =>
      'Clé USB non détectée — branchez-la et elle se connectera';

  @override
  String statusUsbConnected(Object detail) {
    return 'Clé USB connectée : $detail';
  }

  @override
  String get statusUsbUnplugged =>
      'Clé USB débranchée — se reconnecte une fois branchée';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return '$path trouvé mais impossible à ouvrir (permissions ?) : $error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'Impossible d\'ouvrir la clé USB (IOReturn $code) — accordez la Surveillance de l\'entrée dans Réglages Système';
  }

  @override
  String statusUsbError(Object error) {
    return 'Erreur de clé USB : $error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · clavier ←/→ aussi actif';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'Palettes : clavier ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'Saisie libre';

  @override
  String get freeTypeInputLabel => 'Tapez du texte ici';

  @override
  String get freeTypeMorseLabel => 'Morse';

  @override
  String get freeTypeAudioOn => 'Son activé';

  @override
  String get freeTypeAudioOff => 'Son coupé';

  @override
  String get aboutFreeTypeDesc =>
      'Tapez un texte quelconque et voyez-le en Morse — les points et les traits apparaissent à la vitesse configurée, avec un son facultatif joué en synchronisation.';

  @override
  String get menuFreeKey => 'Manipulation libre';

  @override
  String get freeKeyTextLabel => 'Texte';

  @override
  String get aboutFreeKeyDesc =>
      'L\'inverse de la Saisie libre : manipulez du Morse à la palette ou au clavier et voyez-le décodé en texte — les points et les traits apparaissent dans la case Morse pendant la manipulation, et les caractères terminés s\'écrivent en texte. Une pause de sept dits crée une espace.';

  @override
  String get settingsKeyerMode => 'Mode de manipulation';

  @override
  String get keyerModeIambic => 'Palettes ïambiques';

  @override
  String get keyerModeIambicDesc =>
      'Deux palettes — une pour les dits, une pour les dahs ; serrez les deux pour alterner';

  @override
  String get keyerModeStraight => 'Manipulateur droit';

  @override
  String get keyerModeStraightDesc =>
      'Une seule touche — c\'est vous qui rythmez : un appui court donne un dit, un appui long un dah';

  @override
  String levelAccuracy(Object percent) {
    return ' : $percent %';
  }

  @override
  String get hintUsed => '(indice utilisé)';

  @override
  String get menuTiming => 'Cadence';

  @override
  String get timingInstruction =>
      'Manipulez la ligne ci-dessous — la durée de chaque impulsion et de chaque espace est mesurée.';

  @override
  String get timingIambicNote =>
      'Mode ïambique : la machine cadence les éléments ; seuls les espaces entre lettres et mots sont notés. Manipulez la ligne ci-dessous.';

  @override
  String get timingRestart => 'Recommencer';

  @override
  String get timingComplete => 'Ligne terminée !';

  @override
  String get timingDits => 'Dits';

  @override
  String get timingDahs => 'Dahs';

  @override
  String get timingLetterGaps => 'Espaces entre lettres';

  @override
  String get timingWordGaps => 'Espaces entre mots';

  @override
  String timingStats(Object mean, Object sd, Object count) {
    return 'moyenne $mean ms · σ $sd ms · $count mesures';
  }

  @override
  String timingConsistency(Object percent) {
    return '$percent % de régularité';
  }

  @override
  String timingOverall(Object percent) {
    return 'Régularité globale : $percent %';
  }

  @override
  String get aboutTimingScreenDesc =>
      'Affiche une ligne tirée d\'un livre du domaine public avec son Morse ; manipulez-la et la durée de chaque impulsion et espace est mesurée. À la fin, des distributions et une note de régularité pour les dits, les dahs et les espaces entre lettres et mots (manipulateur droit), ou seulement les espaces (ïambique, la machine cadence les éléments). Votre vitesse d\'envoi réelle en WPM est également indiquée.';

  @override
  String timingWpm(Object wpm) {
    return 'Vitesse : $wpm WPM';
  }
}
