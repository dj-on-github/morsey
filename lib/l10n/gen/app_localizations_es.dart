// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Entrenador de Morse';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get menuInputTrain => 'Práctica de envío';

  @override
  String get menuListenTrain => 'Práctica de escucha';

  @override
  String get menuListenTutorial => 'Tutorial de escucha';

  @override
  String get menuInputTutorial => 'Tutorial de envío';

  @override
  String get aboutIntro =>
      'Una herramienta de práctica para aprender código Morse.';

  @override
  String get aboutPartsHeading => 'Las partes del programa';

  @override
  String get aboutAboutDesc =>
      'Esta página: una descripción del programa y de su funcionamiento.';

  @override
  String get aboutSettingsDesc =>
      'Configure la orientación de las palas, la velocidad de manipulación, el volumen y la frecuencia del tono, el idioma y la apariencia clara/oscura. La llave USB y las palas del teclado están siempre activas: no hace falta elegir entrada.';

  @override
  String get aboutInputTrainDesc =>
      'Se muestra un carácter y usted lo manipula en Morse. El entrenador decodifica lo que envía y le dice si fue correcto.';

  @override
  String get aboutListenTrainDesc =>
      'El entrenador reproduce un carácter en audio Morse y usted teclea el carácter que oyó.';

  @override
  String get aboutListenTutorialDesc =>
      'Un curso guiado de escucha de 26 niveles. Cada nivel introduce una letra nueva (orden del método Koch: primero los sonidos más fáciles de distinguir): se muestra la letra y se reproduce su Morse, tecléela para empezar; luego una práctica aleatoria con todas las letras desbloqueadas continúa hasta responder cada una correctamente tres veces. Completar un nivel desbloquea el siguiente y su progreso se recuerda.';

  @override
  String get aboutInputTutorialDesc =>
      'El mismo curso de 26 niveles con los papeles invertidos, para aprender a enviar. Cada nivel muestra los puntos y rayas de la letra nueva con la letra al lado; manipule el patrón para empezar. En la práctica el patrón desaparece —solo se muestra la letra— y usted manipula su Morse de memoria con la pala o el teclado, viendo en directo lo que manipula. Un botón «Escuchar» reproduce el ritmo del objetivo, y una pista puede revelar el patrón si se atasca. El progreso se registra por separado del Tutorial de escucha.';

  @override
  String get aboutUsbHeading => 'La llave Morse USB';

  @override
  String get aboutUsbBody =>
      'Este programa admite una llave Morse yámbica (doble pala) que se enumera por USB como dispositivo 413d:2107. En Linux la llave se lee directamente de su nodo /dev/hidraw, sin controladores, siempre que su usuario pueda leer el dispositivo (grupo plugdev / regla udev). Cada pala se informa como un bit modificador de teclado (Ctrl-izquierda y Ctrl-derecha). En modo yámbico el software convierte esas pulsaciones en dits y dahs correctamente temporizados — una pala para dits, otra para dahs; apriete ambas para alternar. En modo de llave vertical (se elige en Ajustes) cualquier contacto actúa como una sola llave y usted marca el tiempo: el tono sigue su pulsación, una pulsación de menos de dos dits cuenta como dit y una más larga como dah.';

  @override
  String get aboutTimingHeading => 'Temporización';

  @override
  String get aboutTimingBody =>
      'La velocidad se expresa en palabras por minuto (WPM) con la temporización PARIS estándar: un dit = 1200 / WPM milisegundos, un dah son tres dits, el espacio entre elementos es un dit y entre letras tres dits.';

  @override
  String aboutVersion(Object version) {
    return 'Versión $version';
  }

  @override
  String get settingsInputDevice => 'Dispositivo de entrada';

  @override
  String get settingsInputDeviceBody =>
      'Las palas del teclado (flechas Izquierda/Derecha, o . y -) y la llave USB (413d:2107) están siempre activas: la manipulación funciona con cualquiera. Conecte la llave en cualquier momento y funcionará.';

  @override
  String get settingsUsbActsAsKeyboard =>
      'Aquí la llave USB actúa como teclado: conéctela; las palas llegan como Ctrl-izquierda/derecha.';

  @override
  String settingsUsbDetected(Object path) {
    return 'Llave USB 413d:2107 detectada: $path';
  }

  @override
  String get settingsUsbNotDetected =>
      'Llave USB 413d:2107 no detectada — se conectará al enchufarla. Si no lo hace, revise los permisos (Linux: /dev/hidraw*; macOS: Supervisión de entrada en Ajustes del Sistema).';

  @override
  String get settingsRescan => 'Reescanear';

  @override
  String get settingsPaddleOrientation => 'Orientación de las palas';

  @override
  String get settingsSpeed => 'Velocidad';

  @override
  String get settingsKeyingSpeed => 'Velocidad de manipulación';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM  (dit = $ditMs ms)';
  }

  @override
  String get settingsSideTone => 'Tono local';

  @override
  String get settingsVolume => 'Volumen';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => 'Frecuencia';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'Probar tono';

  @override
  String get settingsNoAudio =>
      'No hay backend de audio disponible (Linux: requiere pacat / PulseAudio).';

  @override
  String get settingsCharacterSet => 'Juego de caracteres de práctica';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Seguir el sistema';

  @override
  String get themeSystem => 'Seguir el sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get ditPaddleLeft => 'Pala izquierda = dit';

  @override
  String get ditPaddleRight => 'Pala derecha = dit';

  @override
  String get charSetLetters => 'Letras';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => 'Números';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'Letras + números';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => 'Puntuación';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'Todo';

  @override
  String get charSetAllDesc => 'letras, números, puntuación';

  @override
  String get statusStarting => 'Iniciando…';

  @override
  String score(Object correct, Object attempts) {
    return 'Puntuación: $correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'Manipule este carácter:';

  @override
  String get showHint => 'Mostrar pista';

  @override
  String get youAreKeying => 'Está manipulando:';

  @override
  String get correct => '¡Correcto!';

  @override
  String youKeyedTryAgain(Object decoded) {
    return 'Manipuló «$decoded» — inténtelo de nuevo';
  }

  @override
  String get clear => 'Borrar';

  @override
  String get skipNext => 'Saltar / Siguiente';

  @override
  String get audioMissingListenTrain =>
      'No hay backend de audio disponible (requiere pacat / PulseAudio): la Práctica de escucha necesita sonido.';

  @override
  String get listenThenType => 'Escuche y teclee el carácter que oyó';

  @override
  String get tapKeyBelow => 'Toque la tecla correspondiente abajo.';

  @override
  String get typeKeyHint =>
      'Teclee una letra o número (haga clic aquí si no responde).';

  @override
  String get replay => 'Repetir';

  @override
  String get reveal => 'Revelar';

  @override
  String itWas(Object char, Object morse) {
    return 'Era «$char»   ($morse)';
  }

  @override
  String get notQuiteListen => 'No exactamente — escuche otra vez';

  @override
  String get audioMissingTutorial =>
      'No hay backend de audio disponible: el Tutorial de escucha necesita sonido.';

  @override
  String levelOf(Object level, Object count) {
    return 'Nivel $level de $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'Nivel $level  ($letter)';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total letras dominadas';
  }

  @override
  String get newLetter => 'Letra nueva';

  @override
  String get listenTypeToBegin => 'Escuche y teclee esta letra para empezar';

  @override
  String get greatStartingPractice => '¡Muy bien! Empieza la práctica…';

  @override
  String get typeLetterYouHear => 'Teclee la letra que oye';

  @override
  String get tutorialComplete => '¡Tutorial completado!';

  @override
  String levelComplete(Object level) {
    return '¡Nivel $level completado!';
  }

  @override
  String learnedAllLetters(Object count) {
    return 'Ha aprendido las $count letras. ¡Bien hecho!';
  }

  @override
  String youMastered(Object letters) {
    return 'Ha dominado $letters.';
  }

  @override
  String get repeatLevelEsc => 'Repetir nivel (Esc)';

  @override
  String get nextLevelEnter => 'Siguiente nivel (Intro)';

  @override
  String get keyPatternToBegin => 'Manipule este patrón para empezar';

  @override
  String get keyThisLetter => 'Manipule esta letra';

  @override
  String canKeyAllLetters(Object count) {
    return 'Sabe manipular las $count letras. ¡Bien hecho!';
  }

  @override
  String masteredKeying(Object letters) {
    return 'Ha dominado el envío de $letters.';
  }

  @override
  String get hearIt => 'Escuchar';

  @override
  String get statusKeyboardReady => 'Palas de teclado listas (←/→)';

  @override
  String get statusPaddlesTouch =>
      'Palas: teclado ←/→, o la llave USB (actúa como teclado)';

  @override
  String get statusUsbWaiting =>
      'Llave USB no detectada — conéctela y se conectará';

  @override
  String statusUsbConnected(Object detail) {
    return 'Llave USB conectada: $detail';
  }

  @override
  String get statusUsbUnplugged =>
      'Llave USB desconectada — se reconecta al enchufarla';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return 'Se encontró $path pero no se puede abrir (¿permisos?): $error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'No se puede abrir la llave USB (IOReturn $code) — conceda Supervisión de entrada en Ajustes del Sistema';
  }

  @override
  String statusUsbError(Object error) {
    return 'Error de la llave USB: $error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · teclado ←/→ también activo';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'Palas: teclado ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'Texto libre';

  @override
  String get freeTypeInputLabel => 'Escriba texto aquí';

  @override
  String get freeTypeMorseLabel => 'Morse';

  @override
  String get freeTypeAudioOn => 'Sonido activado';

  @override
  String get freeTypeAudioOff => 'Sonido desactivado';

  @override
  String get aboutFreeTypeDesc =>
      'Escriba cualquier texto y véalo como Morse: los puntos y rayas aparecen a la velocidad configurada, con audio opcional sincronizado.';

  @override
  String get menuFreeKey => 'Manipulación libre';

  @override
  String get freeKeyTextLabel => 'Texto';

  @override
  String get aboutFreeKeyDesc =>
      'Lo inverso de Texto libre: manipule Morse con la pala o el teclado y véalo decodificado como texto — los puntos y rayas aparecen en el cuadro Morse mientras manipula, y los caracteres terminados se escriben como texto. Haga una pausa de siete dits para un espacio.';

  @override
  String get settingsKeyerMode => 'Modo de manipulación';

  @override
  String get keyerModeIambic => 'Palas yámbicas';

  @override
  String get keyerModeIambicDesc =>
      'Dos palas: una para dits y otra para dahs; apriete ambas para alternar';

  @override
  String get keyerModeStraight => 'Llave vertical';

  @override
  String get keyerModeStraightDesc =>
      'Una sola llave — usted marca el tiempo: una pulsación corta es un dit y una larga, un dah';

  @override
  String levelAccuracy(Object percent) {
    return ': $percent %';
  }

  @override
  String get hintUsed => '(pista usada)';

  @override
  String get menuTiming => 'Temporización';

  @override
  String get timingInstruction =>
      'Manipule la línea de abajo: se mide la duración de cada pulso y espacio.';

  @override
  String get timingIambicNote =>
      'Modo yámbico: la máquina temporiza los elementos; solo se puntúan los espacios entre letras y palabras. Manipule la línea de abajo.';

  @override
  String get timingRestart => 'Reiniciar';

  @override
  String get timingComplete => '¡Línea completada!';

  @override
  String get timingDits => 'Dits';

  @override
  String get timingDahs => 'Dahs';

  @override
  String get timingLetterGaps => 'Espacios entre letras';

  @override
  String get timingWordGaps => 'Espacios entre palabras';

  @override
  String timingStats(Object mean, Object sd, Object count) {
    return 'media $mean ms · σ $sd ms · $count muestras';
  }

  @override
  String timingConsistency(Object percent) {
    return '$percent % de regularidad';
  }

  @override
  String timingOverall(Object percent) {
    return 'Regularidad total: $percent %';
  }

  @override
  String get aboutTimingScreenDesc =>
      'Muestra una línea de un libro de dominio público con su Morse; manipúlela y se mide la duración de cada pulso y espacio. Al final verá distribuciones y una puntuación de regularidad para dits, dahs y espacios entre letras y palabras (llave vertical), o solo los espacios (yámbico, la máquina temporiza los elementos). También se indica su velocidad real de envío en WPM.';

  @override
  String timingWpm(Object wpm) {
    return 'Velocidad: $wpm WPM';
  }
}
