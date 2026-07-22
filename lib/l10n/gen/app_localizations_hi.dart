// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'मोर्स ट्रेनर';

  @override
  String get menuAbout => 'परिचय';

  @override
  String get menuSettings => 'सेटिंग्स';

  @override
  String get menuInputTrain => 'भेजने का अभ्यास';

  @override
  String get menuListenTrain => 'सुनने का अभ्यास';

  @override
  String get menuListenTutorial => 'सुनने का ट्यूटोरियल';

  @override
  String get menuInputTutorial => 'भेजने का ट्यूटोरियल';

  @override
  String get aboutIntro => 'मोर्स कोड सीखने का एक अभ्यास उपकरण।';

  @override
  String get aboutPartsHeading => 'प्रोग्राम के भाग';

  @override
  String get aboutAboutDesc =>
      'यह पृष्ठ — प्रोग्राम और उसके काम करने के तरीके का विवरण।';

  @override
  String get aboutSettingsDesc =>
      'पैडल की दिशा, भेजने की गति, साइड-टोन की आवाज़ और आवृत्ति, भाषा, और हल्का/गहरा रूप सेट करें। USB कुंजी और कीबोर्ड पैडल हमेशा दोनों सक्रिय रहते हैं — इनपुट चुनने की ज़रूरत नहीं।';

  @override
  String get aboutInputTrainDesc =>
      'एक अक्षर दिखाया जाता है और आप उसे मोर्स में भेजते हैं। ट्रेनर आपके भेजे हुए को डिकोड करता है और बताता है कि सही था या नहीं।';

  @override
  String get aboutListenTrainDesc =>
      'ट्रेनर एक अक्षर को मोर्स ध्वनि में बजाता है और आप सुना हुआ अक्षर टाइप करते हैं।';

  @override
  String get aboutListenTutorialDesc =>
      '26 स्तरों का एक निर्देशित सुनने का पाठ्यक्रम। हर स्तर एक नया अक्षर सिखाता है (कोच पद्धति का क्रम — सबसे आसानी से पहचाने जाने वाले स्वर पहले): अक्षर दिखाया जाता है और उसका मोर्स बजाया जाता है, शुरू करने के लिए उसे टाइप करें; फिर अब तक खुले सभी अक्षरों का यादृच्छिक अभ्यास तब तक चलता है जब तक हर अक्षर का तीन बार सही उत्तर न मिल जाए। स्तर पूरा करने पर अगला खुलता है, और आपकी प्रगति याद रखी जाती है।';

  @override
  String get aboutInputTutorialDesc =>
      'वही 26 स्तरों का पाठ्यक्रम, भूमिकाएँ उलटकर — भेजना सीखने के लिए। हर स्तर नए अक्षर की बिंदियाँ और रेखाएँ अक्षर के साथ दिखाता है; शुरू करने के लिए वह पैटर्न भेजें। अभ्यास में पैटर्न हटा दिया जाता है — केवल अक्षर दिखता है — और आप याद से उसका मोर्स पैडल या कीबोर्ड से भेजते हैं, और जो भेज रहे हैं वह लाइव दिखता है। «सुनें» बटन लक्ष्य की लय बजाता है, और अटकने पर संकेत पैटर्न दिखा सकता है। प्रगति सुनने के ट्यूटोरियल से अलग दर्ज होती है।';

  @override
  String get aboutUsbHeading => 'USB मोर्स कुंजी';

  @override
  String get aboutUsbBody =>
      'यह प्रोग्राम एक iambic (दोहरे पैडल वाली) मोर्स कुंजी का समर्थन करता है जो USB पर डिवाइस 413d:2107 के रूप में दिखती है। Linux पर कुंजी सीधे उसके /dev/hidraw नोड से पढ़ी जाती है — कोई ड्राइवर नहीं चाहिए, बशर्ते आपका उपयोगकर्ता डिवाइस पढ़ सके (plugdev समूह / udev नियम)। हर पैडल कीबोर्ड मॉडिफ़ायर बिट (बायाँ Ctrl और दायाँ Ctrl) के रूप में रिपोर्ट होता है। iambic मोड में सॉफ़्टवेयर इन दबावों को सही समय वाले डिट और डाह में बदलता है — एक पैडल डिट के लिए, एक डाह के लिए; दोनों दबाने पर बारी-बारी। सीधी कुंजी मोड में (सेटिंग्स में चुनें) कोई भी संपर्क एक ही कुंजी की तरह काम करता है और समय आप तय करते हैं: टोन आपके दबाव के साथ चलता है, दो डिट से छोटा दबाव डिट और लंबा दबाव डाह गिना जाता है।';

  @override
  String get aboutTimingHeading => 'समय';

  @override
  String get aboutTimingBody =>
      'गति शब्द प्रति मिनट (WPM) में मानक PARIS समय से मापी जाती है: एक डिट = 1200 / WPM मिलीसेकंड, डाह तीन डिट का होता है, तत्वों के बीच अंतराल एक डिट और अक्षरों के बीच तीन डिट।';

  @override
  String aboutVersion(Object version) {
    return 'संस्करण $version';
  }

  @override
  String get settingsInputDevice => 'इनपुट डिवाइस';

  @override
  String get settingsInputDeviceBody =>
      'कीबोर्ड पैडल (बाएँ/दाएँ तीर, या . और -) और USB कुंजी (413d:2107) हमेशा दोनों सक्रिय हैं — जिसे छुएँ उसी से भेज सकते हैं। कुंजी कभी भी लगाएँ, तुरंत काम करती है।';

  @override
  String get settingsUsbActsAsKeyboard =>
      'यहाँ USB कुंजी कीबोर्ड की तरह काम करती है — बस लगाएँ; पैडल बाएँ/दाएँ Ctrl के रूप में आते हैं।';

  @override
  String settingsUsbDetected(Object path) {
    return 'USB कुंजी 413d:2107 मिली: $path';
  }

  @override
  String get settingsUsbNotDetected =>
      'USB कुंजी 413d:2107 नहीं मिली — लगाने पर अपने आप जुड़ जाएगी। अगर न जुड़े, तो अनुमतियाँ जाँचें (Linux: /dev/hidraw*; macOS: सिस्टम सेटिंग्स में Input Monitoring)।';

  @override
  String get settingsRescan => 'फिर से खोजें';

  @override
  String get settingsPaddleOrientation => 'पैडल की दिशा';

  @override
  String get settingsSpeed => 'गति';

  @override
  String get settingsKeyingSpeed => 'भेजने की गति';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM  (डिट = $ditMs ms)';
  }

  @override
  String get settingsSideTone => 'साइड-टोन';

  @override
  String get settingsVolume => 'आवाज़';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => 'आवृत्ति';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'टोन परखें';

  @override
  String get settingsNoAudio =>
      'कोई ऑडियो बैकएंड उपलब्ध नहीं (Linux: pacat / PulseAudio चाहिए)।';

  @override
  String get settingsCharacterSet => 'अभ्यास के अक्षर-समूह';

  @override
  String get settingsAppearance => 'रूप';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम के अनुसार';

  @override
  String get themeSystem => 'सिस्टम के अनुसार';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get ditPaddleLeft => 'बायाँ पैडल = डिट';

  @override
  String get ditPaddleRight => 'दायाँ पैडल = डिट';

  @override
  String get charSetLetters => 'अक्षर';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => 'अंक';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'अक्षर + अंक';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => 'विराम चिह्न';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'सब कुछ';

  @override
  String get charSetAllDesc => 'अक्षर, अंक, विराम चिह्न';

  @override
  String get statusStarting => 'शुरू हो रहा है…';

  @override
  String score(Object correct, Object attempts) {
    return 'स्कोर: $correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'यह अक्षर भेजें:';

  @override
  String get showHint => 'संकेत दिखाएँ';

  @override
  String get youAreKeying => 'आप भेज रहे हैं:';

  @override
  String get correct => 'सही!';

  @override
  String youKeyedTryAgain(Object decoded) {
    return 'आपने \"$decoded\" भेजा — फिर से कोशिश करें';
  }

  @override
  String get clear => 'साफ़ करें';

  @override
  String get skipNext => 'छोड़ें / अगला';

  @override
  String get audioMissingListenTrain =>
      'कोई ऑडियो बैकएंड उपलब्ध नहीं (pacat / PulseAudio चाहिए) — सुनने के अभ्यास के लिए ध्वनि ज़रूरी है।';

  @override
  String get listenThenType => 'सुनें, फिर सुना हुआ अक्षर टाइप करें';

  @override
  String get tapKeyBelow => 'नीचे मिलती-जुलती कुंजी दबाएँ।';

  @override
  String get typeKeyHint =>
      'कोई अक्षर/अंक कुंजी टाइप करें (कुछ न हो तो यहाँ क्लिक करें)।';

  @override
  String get replay => 'फिर से बजाएँ';

  @override
  String get reveal => 'उत्तर दिखाएँ';

  @override
  String itWas(Object char, Object morse) {
    return 'उत्तर था \"$char\"   ($morse)';
  }

  @override
  String get notQuiteListen => 'सही नहीं — फिर से सुनें';

  @override
  String get audioMissingTutorial =>
      'कोई ऑडियो बैकएंड उपलब्ध नहीं — सुनने के ट्यूटोरियल के लिए ध्वनि ज़रूरी है।';

  @override
  String levelOf(Object level, Object count) {
    return 'स्तर $level / $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'स्तर $level  ($letter)';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total अक्षरों में महारत';
  }

  @override
  String get newLetter => 'नया अक्षर';

  @override
  String get listenTypeToBegin =>
      'सुनें, फिर शुरू करने के लिए यह अक्षर टाइप करें';

  @override
  String get greatStartingPractice => 'बहुत अच्छे — अभ्यास शुरू…';

  @override
  String get typeLetterYouHear => 'जो अक्षर सुनें वह टाइप करें';

  @override
  String get tutorialComplete => 'ट्यूटोरियल पूरा!';

  @override
  String levelComplete(Object level) {
    return 'स्तर $level पूरा!';
  }

  @override
  String learnedAllLetters(Object count) {
    return 'आपने सभी $count अक्षर सीख लिए। शाबाश!';
  }

  @override
  String youMastered(Object letters) {
    return 'आपने $letters में महारत पा ली।';
  }

  @override
  String get repeatLevelEsc => 'स्तर दोहराएँ (Esc)';

  @override
  String get nextLevelEnter => 'अगला स्तर (Enter)';

  @override
  String get keyPatternToBegin => 'शुरू करने के लिए यह पैटर्न भेजें';

  @override
  String get keyThisLetter => 'यह अक्षर भेजें';

  @override
  String canKeyAllLetters(Object count) {
    return 'अब आप सभी $count अक्षर भेज सकते हैं। शाबाश!';
  }

  @override
  String masteredKeying(Object letters) {
    return 'आपने $letters भेजने में महारत पा ली।';
  }

  @override
  String get hearIt => 'सुनें';

  @override
  String get statusKeyboardReady => 'कीबोर्ड पैडल तैयार (←/→)';

  @override
  String get statusPaddlesTouch =>
      'पैडल: कीबोर्ड ←/→, या USB कुंजी (कीबोर्ड की तरह)';

  @override
  String get statusUsbWaiting =>
      'USB कुंजी नहीं मिली — लगाने पर अपने आप जुड़ जाएगी';

  @override
  String statusUsbConnected(Object detail) {
    return 'USB कुंजी जुड़ी: $detail';
  }

  @override
  String get statusUsbUnplugged =>
      'USB कुंजी निकाली गई — दोबारा लगाने पर जुड़ जाएगी';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return '$path मिला पर खुल नहीं रहा (अनुमतियाँ?): $error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'USB कुंजी खोली नहीं जा सकी (IOReturn $code) — सिस्टम सेटिंग्स में Input Monitoring की अनुमति दें';
  }

  @override
  String statusUsbError(Object error) {
    return 'USB कुंजी त्रुटि: $error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · कीबोर्ड ←/→ भी सक्रिय';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'पैडल: कीबोर्ड ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'मुक्त टाइपिंग';

  @override
  String get freeTypeInputLabel => 'यहाँ टेक्स्ट टाइप करें';

  @override
  String get freeTypeMorseLabel => 'मोर्स';

  @override
  String get freeTypeAudioOn => 'ध्वनि चालू';

  @override
  String get freeTypeAudioOff => 'ध्वनि बंद';

  @override
  String get aboutFreeTypeDesc =>
      'कोई भी टेक्स्ट टाइप करें और उसे मोर्स में देखें — बिंदियाँ और रेखाएँ आपकी चुनी गति से दिखती हैं, चाहें तो साथ में ध्वनि भी।';

  @override
  String get menuFreeKey => 'मुक्त भेजना';

  @override
  String get freeKeyTextLabel => 'टेक्स्ट';

  @override
  String get aboutFreeKeyDesc =>
      'मुक्त टाइपिंग का उल्टा: पैडल या कीबोर्ड से मोर्स भेजें और उसे टेक्स्ट में बदलते देखें — भेजते समय बिंदियाँ और रेखाएँ मोर्स बॉक्स में दिखती हैं, और पूरे अक्षर टेक्स्ट में लिखे जाते हैं। शब्द के बीच जगह के लिए सात डिट रुकें।';

  @override
  String get settingsKeyerMode => 'कुंजी मोड';

  @override
  String get keyerModeIambic => 'iambic पैडल';

  @override
  String get keyerModeIambicDesc =>
      'दो पैडल — एक डिट के लिए, एक डाह के लिए; दोनों दबाने पर बारी-बारी';

  @override
  String get keyerModeStraight => 'सीधी कुंजी';

  @override
  String get keyerModeStraightDesc =>
      'एक ही कुंजी — समय आप तय करते हैं: छोटा दबाव डिट, लंबा दबाव डाह';

  @override
  String levelAccuracy(Object percent) {
    return ': $percent%';
  }

  @override
  String get hintUsed => '(संकेत इस्तेमाल हुआ)';
}
