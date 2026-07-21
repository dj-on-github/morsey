// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '摩尔斯电码训练器';

  @override
  String get menuAbout => '关于';

  @override
  String get menuSettings => '设置';

  @override
  String get menuInputTrain => '发报练习';

  @override
  String get menuListenTrain => '收听练习';

  @override
  String get menuListenTutorial => '收听教程';

  @override
  String get menuInputTutorial => '发报教程';

  @override
  String get aboutIntro => '一款用于学习摩尔斯电码的练习工具，使用 Dart / Flutter 编写。';

  @override
  String get aboutPartsHeading => '程序的组成部分';

  @override
  String get aboutAboutDesc => '本页 — 介绍程序及其工作原理。';

  @override
  String get aboutSettingsDesc =>
      '设置拨片方向、发报速度、侧音音量和频率、语言以及浅色/深色外观。USB 电键和键盘拨片始终同时可用 — 无需选择输入方式。';

  @override
  String get aboutInputTrainDesc => '屏幕显示一个字符，你用摩尔斯电码发出它。训练器会解码你发送的内容并告诉你是否正确。';

  @override
  String get aboutListenTrainDesc => '训练器以摩尔斯电码音频播放一个字符，你输入听到的字符。';

  @override
  String get aboutListenTutorialDesc =>
      '一套引导式收听课程，共 26 级。每级引入一个新字母（Koch 教学法顺序 — 最容易分辨的声音在前）：显示字母并播放其电码，输入该字母即可开始；随后对已解锁的全部字母进行随机练习，直到每个字母都答对三次。完成一级即解锁下一级，进度会被记住。';

  @override
  String get aboutInputTutorialDesc =>
      '同样的 26 级课程，但角色互换，用于学习发报。每级显示新字母的点和划，字母就在旁边；发出该电码即可开始。练习时电码会被隐藏 — 只显示字母 — 你需要凭记忆用拨片或键盘发出它的摩尔斯电码，并实时看到自己发出的内容。「听一听」按钮可播放目标的节奏，卡住时提示可以显示电码。进度与收听教程分开记录。';

  @override
  String get aboutUsbHeading => 'USB 摩尔斯电键';

  @override
  String get aboutUsbBody =>
      '本程序支持以 USB 设备 413d:2107 枚举的双拨片（iambic）摩尔斯电键。在 Linux 上直接从其 /dev/hidraw 节点读取 — 无需驱动，只要你的用户能读取该设备（plugdev 组 / udev 规则）。每个拨片以键盘修饰键位报告（左 Ctrl 和右 Ctrl）；软件把这些按压转换为节拍正确的点和划。';

  @override
  String get aboutTimingHeading => '节拍';

  @override
  String get aboutTimingBody =>
      '速度以每分钟单词数（WPM）表示，采用标准 PARIS 节拍：1 点 = 1200 / WPM 毫秒，1 划等于 3 点，码元间隔为 1 点，字母间隔为 3 点。';

  @override
  String aboutVersion(Object version) {
    return '版本 $version';
  }

  @override
  String get settingsInputDevice => '输入设备';

  @override
  String get settingsInputDeviceBody =>
      '键盘拨片（左/右方向键，或 . 和 -）与 USB 电键（413d:2107）始终同时可用 — 用哪个都能发报。随时插入电键即可使用。';

  @override
  String get settingsUsbActsAsKeyboard =>
      '在此平台上，USB 电键相当于一个键盘 — 插入即可；拨片以左/右 Ctrl 键送达。';

  @override
  String settingsUsbDetected(Object path) {
    return '已检测到 USB 电键 413d:2107：$path';
  }

  @override
  String get settingsUsbNotDetected =>
      '未检测到 USB 电键 413d:2107 — 插入后会自动连接。如果始终无法连接，请检查权限（Linux：/dev/hidraw*；macOS：系统设置中的“输入监控”）。';

  @override
  String get settingsRescan => '重新扫描';

  @override
  String get settingsPaddleOrientation => '拨片方向';

  @override
  String get settingsSpeed => '速度';

  @override
  String get settingsKeyingSpeed => '发报速度';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM（1 点 = $ditMs 毫秒）';
  }

  @override
  String get settingsSideTone => '侧音';

  @override
  String get settingsVolume => '音量';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => '频率';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => '测试音';

  @override
  String get settingsNoAudio => '没有可用的音频后端（Linux：需要 pacat / PulseAudio）。';

  @override
  String get settingsCharacterSet => '练习字符集';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get ditPaddleLeft => '左拨片 = 点';

  @override
  String get ditPaddleRight => '右拨片 = 点';

  @override
  String get charSetLetters => '字母';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => '数字';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => '字母 + 数字';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => '标点符号';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => '全部';

  @override
  String get charSetAllDesc => '字母、数字、标点';

  @override
  String get statusStarting => '正在启动…';

  @override
  String score(Object correct, Object attempts) {
    return '得分：$correct / $attempts';
  }

  @override
  String get keyThisCharacter => '请发出这个字符：';

  @override
  String get showHint => '显示提示';

  @override
  String get youAreKeying => '你正在发出：';

  @override
  String get correct => '正确！';

  @override
  String youKeyedTryAgain(Object decoded) {
    return '你发出的是“$decoded” — 再试一次';
  }

  @override
  String get clear => '清除';

  @override
  String get skipNext => '跳过 / 下一个';

  @override
  String get audioMissingListenTrain =>
      '没有可用的音频后端（需要 pacat / PulseAudio）— 收听练习需要声音。';

  @override
  String get listenThenType => '先听，然后输入你听到的字符';

  @override
  String get tapKeyBelow => '点按下方对应的按键。';

  @override
  String get typeKeyHint => '输入一个字母/数字键（如果输入无反应请先点击此处）。';

  @override
  String get replay => '重放';

  @override
  String get reveal => '显示答案';

  @override
  String itWas(Object char, Object morse) {
    return '答案是“$char”（$morse）';
  }

  @override
  String get notQuiteListen => '不对 — 再听一次';

  @override
  String get audioMissingTutorial => '没有可用的音频后端 — 收听教程需要声音。';

  @override
  String levelOf(Object level, Object count) {
    return '第 $level 级，共 $count 级';
  }

  @override
  String levelItem(Object level, Object letter) {
    return '第 $level 级（$letter）';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '已掌握 $mastered / $total 个字母';
  }

  @override
  String get newLetter => '新字母';

  @override
  String get listenTypeToBegin => '先听，然后输入这个字母开始';

  @override
  String get greatStartingPractice => '很好 — 开始练习…';

  @override
  String get typeLetterYouHear => '输入你听到的字母';

  @override
  String get tutorialComplete => '教程完成！';

  @override
  String levelComplete(Object level) {
    return '第 $level 级完成！';
  }

  @override
  String learnedAllLetters(Object count) {
    return '你已学会全部 $count 个字母。干得好！';
  }

  @override
  String youMastered(Object letters) {
    return '你已掌握 $letters。';
  }

  @override
  String get repeatLevelEsc => '重做本级（Esc）';

  @override
  String get nextLevelEnter => '下一级（Enter）';

  @override
  String get keyPatternToBegin => '发出这个电码开始';

  @override
  String get keyThisLetter => '请发出这个字母';

  @override
  String canKeyAllLetters(Object count) {
    return '你已能发出全部 $count 个字母。干得好！';
  }

  @override
  String masteredKeying(Object letters) {
    return '你已掌握 $letters 的发报。';
  }

  @override
  String get hearIt => '听一听';

  @override
  String get statusKeyboardReady => '键盘拨片就绪（←/→）';

  @override
  String get statusPaddlesTouch => '拨片：键盘 ←/→，或 USB 电键（相当于键盘）';

  @override
  String get statusUsbWaiting => '未检测到 USB 电键 — 插入后会自动连接';

  @override
  String statusUsbConnected(Object detail) {
    return 'USB 电键已连接：$detail';
  }

  @override
  String get statusUsbUnplugged => 'USB 电键已拔出 — 插回后会自动重连';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return '找到 $path 但无法打开（权限问题？）：$error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return '无法打开 USB 电键（IOReturn $code）— 请在系统设置中授予“输入监控”权限';
  }

  @override
  String statusUsbError(Object error) {
    return 'USB 电键错误：$error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · 键盘 ←/→ 也可用';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return '拨片：键盘 ←/→ · $usb';
  }

  @override
  String get menuFreeType => '自由输入';

  @override
  String get freeTypeInputLabel => '在此输入文字';

  @override
  String get freeTypeMorseLabel => '摩尔斯';

  @override
  String get freeTypeAudioOn => '声音开';

  @override
  String get freeTypeAudioOff => '声音关';

  @override
  String get aboutFreeTypeDesc => '输入任意文字并将其显示为摩尔斯电码 — 点和划按设定速度出现，可选择同步播放声音。';

  @override
  String get menuFreeKey => '自由发报';

  @override
  String get freeKeyTextLabel => '文字';

  @override
  String get aboutFreeKeyDesc =>
      '自由输入的反向操作：用拨片或键盘发出摩尔斯电码，程序将其解码为文字 — 发报时点和划显示在摩尔斯框中，完成的字符会写入文字框。停顿七个点的时长即为词间空格。';
}
