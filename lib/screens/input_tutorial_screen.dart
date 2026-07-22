import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/status_l10n.dart';
import '../input/combined_paddle_source.dart';
import '../models/settings.dart';
import '../morsey/iambic_keyer.dart';
import '../morsey/morse_code.dart';
import 'letter_progress.dart';
import 'page_scaffold.dart';

/// A guided, 26-level keying course — the Listen Tutorial with the roles of
/// the letter and the Morse reversed. Each level introduces one new letter
/// (following [kTutorialLetterOrder]): its dots and dashes are shown with the
/// letter beside them and the pupil keys the pattern to begin. In practice the
/// pattern is taken away — only the letter is shown — and the pupil must key
/// its Morse from memory (paddle or keyboard, as in Input Train) until every
/// unlocked letter has been keyed correctly [_targetPerLetter] times.
/// Completing a level unlocks the next and is remembered in [Settings].
class InputTutorialScreen extends StatefulWidget {
  const InputTutorialScreen({super.key});

  @override
  State<InputTutorialScreen> createState() => _InputTutorialScreenState();
}

/// Where the pupil is within a level.
enum _Phase { intro, practice, levelComplete }

/// Correct answers required per letter before a level is passed.
const int _targetPerLetter = 3;

class _InputTutorialScreenState extends State<InputTutorialScreen> {
  final _random = Random();
  final _focusNode = FocusNode(debugLabel: 'InputTutorialInput');

  Settings? _settings;
  late IambicKeyer _keyer;
  CombinedPaddleSource? _paddles;

  int _level = 1; // 1-based
  _Phase _phase = _Phase.intro;

  late String _newLetter; // letter introduced this level
  late List<String> _levelLetters; // every letter unlocked at this level
  Map<String, int> _counts = {}; // correct answers so far, per letter
  int _levelCorrect = 0; // practice answers that were right this level
  int _levelAttempts = 0; // all practice answers this level
  bool _hintUsed = false; // whether a hint was shown during this level
  String _target = ''; // letter currently drilled in practice
  String _livePattern = ''; // elements keyed so far in this character
  String? _lastDecoded; // what the last committed pattern decoded to
  bool? _lastCorrect;
  bool _showHint = false;
  bool _playing = false; // "Hear it" demo in progress
  int _playToken = 0; // bumped to cancel in-flight playback

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      final scope = AppScope.of(context);
      _settings = scope.settings;
      _keyer = IambicKeyer(
        ditMs: () => _settings!.ditMs,
        straightKey: () => _settings!.keyerMode == KeyerMode.straight,
        audio: scope.audio,
        onPattern: (p) => setState(() {
          _livePattern = p;
          // Keying takes over the side-tone: cancel a running demo.
          if (p.isNotEmpty && _playing) {
            _playToken++;
            _playing = false;
          }
        }),
        onCharacter: _onCharacter,
      );
      _keyer.start();
      _settings!.addListener(_onSettingsChanged);
      _setupLevel(_settings!.inputTutorialLevel);
      _attachPaddles(scope.paddles);
    }
  }

  void _refocus() {
    if (mounted) _focusNode.requestFocus();
  }

  int get _levelCount => kTutorialLetterOrder.length;

  // --- Paddle source (same plumbing as Input Train) --------------------------

  void _onSettingsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _handleDit(bool down) => _keyer.setDit(down);
  void _handleDah(bool down) => _keyer.setDah(down);
  void _handleStatus() {
    if (mounted) setState(() {});
  }

  /// Attaches this screen's keyer to the app-wide shared paddle source.
  void _attachPaddles(CombinedPaddleSource paddles) {
    _paddles = paddles;
    paddles.onDit = _handleDit;
    paddles.onDah = _handleDah;
    paddles.onStatus = _handleStatus;
  }

  /// Detaches, but only if the callbacks are still ours: the next keying
  /// screen attaches BEFORE this one's dispose runs, and must not be
  /// clobbered. (Same-instance method tear-offs compare equal.)
  void _detachPaddles() {
    final p = _paddles;
    if (p == null) return;
    if (p.onDit == _handleDit) p.onDit = null;
    if (p.onDah == _handleDah) p.onDah = null;
    if (p.onStatus == _handleStatus) p.onStatus = null;
  }

  // --- Level / phase transitions ---------------------------------------------

  /// Initialises the fields for [level]. Safe to call before the first frame.
  void _setupLevel(int level) {
    _level = level.clamp(1, _levelCount);
    _newLetter = kTutorialLetterOrder[_level - 1];
    _levelLetters = kTutorialLetterOrder.sublist(0, _level);
    _phase = _Phase.intro;
    _livePattern = '';
    _lastDecoded = null;
    _lastCorrect = null;
    _showHint = false;
  }

  void _startLevel(int level) {
    _keyer.clear();
    _cancelPlayback();
    setState(() => _setupLevel(level));
    _refocus();
  }

  void _startPractice() {
    _keyer.clear();
    setState(() {
      _phase = _Phase.practice;
      _counts = {for (final c in _levelLetters) c: 0};
      _levelCorrect = 0;
      _levelAttempts = 0;
      _hintUsed = false;
      _livePattern = '';
      _lastDecoded = null;
      _lastCorrect = null;
      _showHint = false;
    });
    _pickTarget();
  }

  void _pickTarget() {
    final remaining = _levelLetters
        .where((c) => (_counts[c] ?? 0) < _targetPerLetter)
        .toList();
    if (remaining.isEmpty) {
      _completeLevel();
      return;
    }
    // Avoid immediately repeating the same letter when another is available.
    String next = remaining[_random.nextInt(remaining.length)];
    if (remaining.length > 1) {
      while (next == _target) {
        next = remaining[_random.nextInt(remaining.length)];
      }
    }
    _keyer.clear();
    _cancelPlayback();
    setState(() {
      _target = next;
      _livePattern = '';
      _lastDecoded = null;
      _lastCorrect = null;
      _showHint = false;
    });
    _refocus();
  }

  // --- Audio demo ------------------------------------------------------------

  void _cancelPlayback() {
    _playToken++;
    _playing = false;
  }

  /// Plays the current target's Morse as a demonstration.
  Future<void> _play(String text) async {
    final scope = AppScope.of(context);
    if (!scope.audio.available) return;
    final token = ++_playToken;
    setState(() => _playing = true);
    await scope.audio.playText(
      text,
      _settings!.ditMs,
      cancelled: () => token != _playToken,
    );
    if (mounted && token == _playToken) setState(() => _playing = false);
    _refocus();
  }

  void _completeLevel() {
    final settings = _settings!;
    if (_level == settings.inputTutorialLevel && _level < _levelCount) {
      settings.inputTutorialLevel = _level + 1;
    }
    setState(() => _phase = _Phase.levelComplete);
    _refocus();
  }

  // --- Input -----------------------------------------------------------------

  /// A letter gap committed the keyed pattern — score it against the target.
  void _onCharacter(String pattern, String? char) {
    final decoded = char?.toUpperCase();
    final expected = _phase == _Phase.intro ? _newLetter : _target;
    if (_phase == _Phase.levelComplete) return;
    final ok = decoded == expected;
    setState(() {
      _lastDecoded = decoded ?? '?';
      _lastCorrect = ok;
      if (_phase == _Phase.practice) {
        _levelAttempts++;
        if (ok) {
          _levelCorrect++;
          _counts[_target] =
              min(_targetPerLetter, (_counts[_target] ?? 0) + 1);
        }
      }
    });
    if (!ok) return;
    if (_phase == _Phase.intro) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted && _phase == _Phase.intro) _startPractice();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted && _phase == _Phase.practice) _pickTarget();
      });
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // On the completion screen, Enter advances and Esc repeats the level.
    if (_phase == _Phase.levelComplete) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        if (_level < _levelCount) _startLevel(_level + 1);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _startLevel(_level);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    // Otherwise keys may be paddles (arrows, or the USB key as a keyboard).
    final handled = _paddles?.handleKeyEvent(event) ?? false;
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _detachPaddles();
    _playToken++; // cancel any playback
    _settings?.removeListener(_onSettingsChanged);
    _keyer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);

    return PageScaffold(
      title: l10n.menuInputTutorial,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _refocus,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(theme, scope.settings, l10n),
              // Keying-device status: keyboard always works, USB hotplugs.
              Row(
                children: [
                  Icon(
                    _paddles?.usbConnected == true
                        ? Icons.usb
                        : Icons.keyboard,
                    size: 18,
                    color: _paddles?.usbConnected == true
                        ? Colors.green
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _paddles?.statusText(l10n) ?? l10n.statusStarting,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              // Scroll when the body (e.g. several wrapped rows of progress
              // chips at high levels) is taller than the available space;
              // stay centred when it is shorter.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(child: _body(theme, l10n)),
                    ),
                  ),
                ),
              ),
              if (_phase != _Phase.levelComplete)
                _controls(theme, scope, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(ThemeData theme, Settings settings,
      AppLocalizations l10n) {
    final unlocked = settings.inputTutorialLevel;
    final levelText = Text(l10n.levelOf(_level, _levelCount),
        style: theme.textTheme.titleMedium);
    final dropdown = DropdownButton<int>(
      value: _level,
      underline: const SizedBox.shrink(),
      onChanged: (v) {
        if (v != null && v != _level) _startLevel(v);
      },
      items: [
        for (var i = 1; i <= unlocked; i++)
          DropdownMenuItem(
            value: i,
            child: Text(l10n.levelItem(i, kTutorialLetterOrder[i - 1])),
          ),
      ],
    );
    final mastered = _phase == _Phase.practice
        ? Text(
            l10n.lettersMastered(_mastered(), _levelLetters.length),
            style: theme.textTheme.bodySmall,
          )
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // On narrow screens, wrap the controls onto multiple lines instead
        // of letting the row overflow.
        if (constraints.maxWidth < 480) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 4,
            children: [
              levelText,
              dropdown,
              ?mastered,
            ],
          );
        }
        return Row(
          children: [
            levelText,
            const SizedBox(width: 16),
            dropdown,
            const Spacer(),
            ?mastered,
          ],
        );
      },
    );
  }

  int _mastered() =>
      _levelLetters.where((c) => (_counts[c] ?? 0) >= _targetPerLetter).length;

  Widget _body(ThemeData theme, AppLocalizations l10n) {
    switch (_phase) {
      case _Phase.intro:
        return _introBody(theme, l10n);
      case _Phase.practice:
        return _practiceBody(theme, l10n);
      case _Phase.levelComplete:
        return _completeBody(theme, l10n);
    }
  }

  Widget _introBody(ThemeData theme, AppLocalizations l10n) {
    final morse = displayMorse(morseForChar(_newLetter) ?? '');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.newLetter, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        // The Morse is the star here; the letter it stands for sits beside it.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              morse,
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              _newLetter,
              style: theme.textTheme.displayMedium
                  ?.copyWith(color: theme.colorScheme.tertiary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.keyPatternToBegin,
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        _keyingBox(theme, l10n),
        const SizedBox(height: 12),
        _feedback(theme, l10n, correctLabel: l10n.greatStartingPractice),
      ],
    );
  }

  Widget _practiceBody(ThemeData theme, AppLocalizations l10n) {
    final morse = displayMorse(morseForChar(_target) ?? '');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.keyThisLetter, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          _target,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        // Hint (morse of the target), mirroring Input Train.
        SizedBox(
          height: 28,
          child: _showHint
              ? Text(
                  morse,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 4,
                    color: theme.colorScheme.outline,
                  ),
                )
              : TextButton(
                  onPressed: () => setState(() {
                    _showHint = true;
                    _hintUsed = true;
                  }),
                  child: Text(l10n.showHint),
                ),
        ),
        const SizedBox(height: 16),
        _keyingBox(theme, l10n),
        const SizedBox(height: 12),
        _feedback(theme, l10n, correctLabel: l10n.correct),
        const SizedBox(height: 20),
        _progressChips(theme),
      ],
    );
  }

  Widget _completeBody(ThemeData theme, AppLocalizations l10n) {
    final last = _level >= _levelCount;
    final title = last ? l10n.tutorialComplete : l10n.levelComplete(_level);
    final percent = _levelAttempts == 0
        ? 100
        : ((_levelCorrect / _levelAttempts) * 100).round();
    var scored = '$title${l10n.levelAccuracy(percent)}';
    if (_hintUsed) scored = '$scored ${l10n.hintUsed}';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events, size: 72, color: theme.colorScheme.tertiary),
        const SizedBox(height: 16),
        Text(
          scored,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          last
              ? l10n.canKeyAllLetters(_levelCount)
              : l10n.masteredKeying(_levelLetters.join(' ')),
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _startLevel(_level),
              icon: const Icon(Icons.replay),
              label: Text(l10n.repeatLevelEsc),
            ),
            if (!last) ...[
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _startLevel(_level + 1),
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.nextLevelEnter),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// The live "you are keying" display, as on the Input Train screen.
  Widget _keyingBox(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Text(l10n.youAreKeying, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(minWidth: 160),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _lastCorrect == null
                  ? theme.colorScheme.outlineVariant
                  : (_lastCorrect! ? Colors.green : theme.colorScheme.error),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _livePattern.isEmpty ? '·' : displayMorse(_livePattern),
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(letterSpacing: 6),
          ),
        ),
      ],
    );
  }

  Widget _progressChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final c in _levelLetters)
          LetterProgress(
            letter: c,
            count: _counts[c] ?? 0,
            target: _targetPerLetter,
            isNew: c == _newLetter,
          ),
      ],
    );
  }

  Widget _feedback(ThemeData theme, AppLocalizations l10n,
      {required String correctLabel}) {
    if (_lastCorrect == null) return const SizedBox(height: 28);
    final ok = _lastCorrect == true;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel,
            color: ok ? Colors.green : theme.colorScheme.error),
        const SizedBox(width: 8),
        Text(
          ok
              ? correctLabel
              : l10n.youKeyedTryAgain(_lastDecoded ?? '?'),
          style: theme.textTheme.titleMedium?.copyWith(
            color: ok ? Colors.green : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _controls(ThemeData theme, AppScope scope, AppLocalizations l10n) {
    // The demo shares the side-tone with the keyer, so it can only start
    // while the keyer is quiet; keying also cancels a running demo.
    final canHear =
        scope.audio.available && !_playing && !_keyer.active;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.tonalIcon(
          onPressed: canHear
              ? () =>
                  _play(_phase == _Phase.intro ? _newLetter : _target)
              : null,
          icon: const Icon(Icons.volume_up),
          label: Text(l10n.hearIt),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            _keyer.clear();
            setState(() {
              _livePattern = '';
              _lastDecoded = null;
              _lastCorrect = null;
            });
            _refocus();
          },
          icon: const Icon(Icons.backspace_outlined),
          label: Text(l10n.clear),
        ),
      ],
    );
  }
}
