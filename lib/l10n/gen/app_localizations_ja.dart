// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'モールストレーナー';

  @override
  String get menuAbout => '概要';

  @override
  String get menuSettings => '設定';

  @override
  String get menuInputTrain => '送信練習';

  @override
  String get menuListenTrain => '受信練習';

  @override
  String get menuListenTutorial => '受信チュートリアル';

  @override
  String get menuInputTutorial => '送信チュートリアル';

  @override
  String get aboutIntro => 'モールス信号を学ぶための練習ツール。Dart / Flutter 製。';

  @override
  String get aboutPartsHeading => 'プログラムの構成';

  @override
  String get aboutAboutDesc => 'このページ — プログラムの説明と仕組み。';

  @override
  String get aboutSettingsDesc =>
      'パドルの向き、送信速度、サイドトーンの音量と周波数、言語、ライト/ダーク外観を設定します。USB キーとキーボードパドルは常に両方有効 — 入力の選択は不要です。';

  @override
  String get aboutInputTrainDesc =>
      '表示された文字をモールスで送信します。トレーナーが送信内容を解読し、正解かどうかを教えます。';

  @override
  String get aboutListenTrainDesc => 'トレーナーが文字をモールス音で再生し、聞き取った文字を入力します。';

  @override
  String get aboutListenTutorialDesc =>
      '全 26 レベルのガイド付き受信コース。各レベルで新しい文字を 1 つ導入します（コッホ法の順序 — 聞き分けやすい音から）。文字が表示されモールスが再生されるので、入力して開始します。その後、解放済みの全文字のランダム練習が、各文字に 3 回正解するまで続きます。レベルをクリアすると次が解放され、進捗は保存されます。';

  @override
  String get aboutInputTutorialDesc =>
      '同じ 26 レベルのコースで役割を逆にした、送信を学ぶためのコースです。各レベルで新しい文字の短点・長点が文字と並んで表示されるので、そのパターンを送信して開始します。練習ではパターンが隠され — 文字だけが表示され — パドルまたはキーボードで記憶からモールスを送信し、送信内容をリアルタイムで確認できます。「聞く」ボタンでお手本のリズムを再生でき、行き詰まったらヒントでパターンを表示できます。進捗は受信チュートリアルとは別に記録されます。';

  @override
  String get aboutUsbHeading => 'USB モールスキー';

  @override
  String get aboutUsbBody =>
      'このプログラムは、USB デバイス 413d:2107 として認識されるイアンビック（デュアルパドル）モールスキーに対応しています。Linux では /dev/hidraw ノードから直接読み取るためドライバーは不要です（plugdev グループ / udev ルールでデバイスを読める必要があります）。各パドルはキーボードの修飾キービット（左 Ctrl と右 Ctrl）として報告され、ソフトウェアがそれを正しいタイミングの短点・長点に変換します。';

  @override
  String get aboutTimingHeading => 'タイミング';

  @override
  String get aboutTimingBody =>
      '速度は標準の PARIS タイミングによる毎分語数（WPM）で表します。短点 1 つ = 1200 / WPM ミリ秒、長点は短点 3 つ分、要素間の間隔は短点 1 つ、文字間は短点 3 つです。';

  @override
  String aboutVersion(Object version) {
    return 'バージョン $version';
  }

  @override
  String get settingsInputDevice => '入力デバイス';

  @override
  String get settingsInputDeviceBody =>
      'キーボードパドル（左右矢印キー、または . と -）と USB キー（413d:2107）は常に両方有効です — どちらでも送信できます。キーはいつ接続してもすぐ使えます。';

  @override
  String get settingsUsbActsAsKeyboard =>
      'この環境では USB キーはキーボードとして動作します — 接続するだけ。パドルは左/右 Ctrl として届きます。';

  @override
  String settingsUsbDetected(Object path) {
    return 'USB キー 413d:2107 を検出：$path';
  }

  @override
  String get settingsUsbNotDetected =>
      'USB キー 413d:2107 が見つかりません — 接続すれば自動でつながります。つながらない場合は権限を確認してください（Linux：/dev/hidraw*、macOS：システム設定の「入力監視」）。';

  @override
  String get settingsRescan => '再スキャン';

  @override
  String get settingsPaddleOrientation => 'パドルの向き';

  @override
  String get settingsSpeed => '速度';

  @override
  String get settingsKeyingSpeed => '送信速度';

  @override
  String settingsWpmValue(Object wpm, Object ditMs) {
    return '$wpm WPM（短点 = $ditMs ms）';
  }

  @override
  String get settingsSideTone => 'サイドトーン';

  @override
  String get settingsVolume => '音量';

  @override
  String settingsVolumeValue(Object percent) {
    return '$percent %';
  }

  @override
  String get settingsFrequency => '周波数';

  @override
  String settingsFrequencyValue(Object hz) {
    return '$hz Hz';
  }

  @override
  String get settingsTestTone => 'テストトーン';

  @override
  String get settingsNoAudio =>
      '利用可能なオーディオバックエンドがありません（Linux：pacat / PulseAudio が必要）。';

  @override
  String get settingsCharacterSet => '練習する文字セット';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystem => 'システムに従う';

  @override
  String get themeSystem => 'システムに従う';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get ditPaddleLeft => '左パドル = 短点';

  @override
  String get ditPaddleRight => '右パドル = 短点';

  @override
  String get charSetLetters => 'アルファベット';

  @override
  String get charSetLettersDesc => 'A – Z';

  @override
  String get charSetNumbers => '数字';

  @override
  String get charSetNumbersDesc => '0 – 9';

  @override
  String get charSetLettersNumbers => 'アルファベット + 数字';

  @override
  String get charSetLettersNumbersDesc => 'A – Z, 0 – 9';

  @override
  String get charSetPunctuation => '記号';

  @override
  String get charSetPunctuationDesc => '. , ? / = + …';

  @override
  String get charSetAll => 'すべて';

  @override
  String get charSetAllDesc => 'アルファベット、数字、記号';

  @override
  String get statusStarting => '起動中…';

  @override
  String score(Object correct, Object attempts) {
    return 'スコア：$correct / $attempts';
  }

  @override
  String get keyThisCharacter => 'この文字を送信してください：';

  @override
  String get showHint => 'ヒントを表示';

  @override
  String get youAreKeying => '送信中：';

  @override
  String get correct => '正解！';

  @override
  String youKeyedTryAgain(Object decoded) {
    return '「$decoded」を送信しました — もう一度';
  }

  @override
  String get clear => 'クリア';

  @override
  String get skipNext => 'スキップ / 次へ';

  @override
  String get audioMissingListenTrain =>
      '利用可能なオーディオバックエンドがありません（pacat / PulseAudio が必要）— 受信練習には音が必要です。';

  @override
  String get listenThenType => '聞いてから、聞き取った文字を入力してください';

  @override
  String get tapKeyBelow => '下の対応するキーをタップしてください。';

  @override
  String get typeKeyHint => '文字か数字のキーを入力してください（反応しない場合はここをクリック）。';

  @override
  String get replay => 'もう一度再生';

  @override
  String get reveal => '答えを表示';

  @override
  String itWas(Object char, Object morse) {
    return '答えは「$char」（$morse）';
  }

  @override
  String get notQuiteListen => '残念 — もう一度聞いてみましょう';

  @override
  String get audioMissingTutorial =>
      '利用可能なオーディオバックエンドがありません — 受信チュートリアルには音が必要です。';

  @override
  String levelOf(Object level, Object count) {
    return 'レベル $level / $count';
  }

  @override
  String levelItem(Object level, Object letter) {
    return 'レベル $level（$letter）';
  }

  @override
  String lettersMastered(Object mastered, Object total) {
    return '$mastered / $total 文字を習得';
  }

  @override
  String get newLetter => '新しい文字';

  @override
  String get listenTypeToBegin => '聞いてから、この文字を入力して開始';

  @override
  String get greatStartingPractice => 'よくできました — 練習を始めます…';

  @override
  String get typeLetterYouHear => '聞こえた文字を入力してください';

  @override
  String get tutorialComplete => 'チュートリアル完了！';

  @override
  String levelComplete(Object level) {
    return 'レベル $level クリア！';
  }

  @override
  String learnedAllLetters(Object count) {
    return '全 $count 文字を習得しました。お見事！';
  }

  @override
  String youMastered(Object letters) {
    return '$letters を習得しました。';
  }

  @override
  String get repeatLevelEsc => 'レベルをやり直す（Esc）';

  @override
  String get nextLevelEnter => '次のレベル（Enter）';

  @override
  String get keyPatternToBegin => 'このパターンを送信して開始';

  @override
  String get keyThisLetter => 'この文字を送信してください';

  @override
  String canKeyAllLetters(Object count) {
    return '全 $count 文字を送信できるようになりました。お見事！';
  }

  @override
  String masteredKeying(Object letters) {
    return '$letters の送信を習得しました。';
  }

  @override
  String get hearIt => '聞く';

  @override
  String get statusKeyboardReady => 'キーボードパドル準備完了（←/→）';

  @override
  String get statusPaddlesTouch => 'パドル：キーボード ←/→、または USB キー（キーボードとして動作）';

  @override
  String get statusUsbWaiting => 'USB キーが見つかりません — 接続すれば自動でつながります';

  @override
  String statusUsbConnected(Object detail) {
    return 'USB キー接続済み：$detail';
  }

  @override
  String get statusUsbUnplugged => 'USB キーが抜かれました — 再接続すればつながります';

  @override
  String statusUsbOpenFailed(Object path, Object error) {
    return '$path を検出しましたが開けません（権限？）：$error';
  }

  @override
  String statusUsbOpenDenied(Object code) {
    return 'USB キーを開けません（IOReturn $code）— システム設定で「入力監視」を許可してください';
  }

  @override
  String statusUsbError(Object error) {
    return 'USB キーのエラー：$error';
  }

  @override
  String statusUsbAndKeyboard(Object usb) {
    return '$usb · キーボード ←/→ も有効';
  }

  @override
  String statusKeyboardAndUsb(Object usb) {
    return 'パドル：キーボード ←/→ · $usb';
  }

  @override
  String get menuFreeType => 'フリータイプ';

  @override
  String get freeTypeInputLabel => 'ここに入力';

  @override
  String get freeTypeMorseLabel => 'モールス';

  @override
  String get freeTypeAudioOn => '音オン';

  @override
  String get freeTypeAudioOff => '音オフ';

  @override
  String get aboutFreeTypeDesc =>
      '好きなテキストを入力するとモールスで表示されます — 短点・長点は設定した速度で現れ、必要なら音も同期して再生されます。';

  @override
  String get menuFreeKey => 'フリー送信';

  @override
  String get freeKeyTextLabel => 'テキスト';

  @override
  String get aboutFreeKeyDesc =>
      'フリータイプの逆です。パドルまたはキーボードでモールスを送信すると、テキストに解読されます — 送信中の短点・長点はモールス欄に表示され、確定した文字はテキストとして書かれます。単語の区切りは短点 7 つ分の休止で入ります。';
}
