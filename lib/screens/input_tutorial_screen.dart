import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../input/hid_paddle_source.dart';
import '../input/keyboard_paddle_source.dart';
import '../input/paddle_source.dart';
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
  PaddleSource? _source;
  InputMethod? _sourceMethod;
  bool _disposed = false;

  int _level = 1; // 1-based
  _Phase _phase = _Phase.intro;

  late String _newLetter; // letter introduced this level
  late List<String> _levelLetters; // every letter unlocked at this level
  Map<String, int> _counts = {}; // correct answers so far, per letter
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
      _rebuildSource();
    }
  }

  void _refocus() {
    if (mounted) _focusNode.requestFocus();
  }

  int get _levelCount => kTutorialLetterOrder.length;

  // --- Paddle source (same plumbing as Input Train) --------------------------

  void _onSettingsChanged() {
    if (!mounted) return;
    final ditIsLeft = _settings!.ditPaddle == DitPaddle.left;
    final src = _source;
    if (src is HidPaddleSource) src.ditIsLeft = ditIsLeft;
    if (src is KeyboardPaddleSource) src.ditIsLeft = ditIsLeft;
    if (_settings!.inputMethod != _sourceMethod) {
      _rebuildSource();
    }
    setState(() {});
  }

  Future<void> _rebuildSource() async {
    await _source?.stop();
    final ditIsLeft = _settings!.ditPaddle == DitPaddle.left;
    _sourceMethod = _settings!.inputMethod;
    final PaddleSource src;
    if (_sourceMethod != InputMethod.usbPaddle) {
      src = KeyboardPaddleSource(ditIsLeft: ditIsLeft);
    } else if (Platform.isIOS) {
      // iPadOS has no raw HID access, but the USB key enumerates as a
      // keyboard whose paddles send Left-Ctrl / Right-Ctrl — read it as one.
      src = KeyboardPaddleSource(
        ditIsLeft: ditIsLeft,
        statusLabel: 'USB key as keyboard (Left/Right-Ctrl paddles)',
      );
    } else {
      src = HidPaddleSource(ditIsLeft: ditIsLeft);
    }
    src.onDit = (down) => _keyer.setDit(down);
    src.onDah = (down) => _keyer.setDah(down);
    await src.start();
    // If the screen was disposed while starting, don't keep the device open.
    if (_disposed || !mounted) {
      await src.stop();
      return;
    }
    setState(() => _source = src);
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
      if (ok && _phase == _Phase.practice) {
        _counts[_target] = min(_targetPerLetter, (_counts[_target] ?? 0) + 1);
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
    // Otherwise keys may be paddles (keyboard mode, or USB-as-keyboard).
    final src = _source;
    if (src is KeyboardPaddleSource) {
      final handled = src.handleKeyEvent(event);
      if (handled) return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _disposed = true;
    _playToken++; // cancel any playback
    _settings?.removeListener(_onSettingsChanged);
    _keyer.dispose();
    _source?.stop();
    _focusNode.dispose();
    super.dispose();
  }

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);

    return PageScaffold(
      title: 'Input Tutorial',
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
              _header(theme, scope.settings),
              // Connection status of the keying device.
              Row(
                children: [
                  Icon(
                    _source?.connected == true ? Icons.link : Icons.link_off,
                    size: 18,
                    color: _source?.connected == true
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _source?.status ?? 'Starting…',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              Expanded(child: Center(child: _body(theme))),
              if (_phase != _Phase.levelComplete) _controls(theme, scope),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(ThemeData theme, Settings settings) {
    final unlocked = settings.inputTutorialLevel;
    return Row(
      children: [
        Text('Level $_level of $_levelCount',
            style: theme.textTheme.titleMedium),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: _level,
          underline: const SizedBox.shrink(),
          onChanged: (v) {
            if (v != null && v != _level) _startLevel(v);
          },
          items: [
            for (var i = 1; i <= unlocked; i++)
              DropdownMenuItem(
                value: i,
                child: Text('Level $i  (${kTutorialLetterOrder[i - 1]})'),
              ),
          ],
        ),
        const Spacer(),
        if (_phase == _Phase.practice)
          Text(
            '${_mastered()} / ${_levelLetters.length} letters mastered',
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }

  int _mastered() =>
      _levelLetters.where((c) => (_counts[c] ?? 0) >= _targetPerLetter).length;

  Widget _body(ThemeData theme) {
    switch (_phase) {
      case _Phase.intro:
        return _introBody(theme);
      case _Phase.practice:
        return _practiceBody(theme);
      case _Phase.levelComplete:
        return _completeBody(theme);
    }
  }

  Widget _introBody(ThemeData theme) {
    final morse = displayMorse(morseForChar(_newLetter) ?? '');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('New letter', style: theme.textTheme.titleMedium),
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
        Text('Key this pattern to begin',
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        _keyingBox(theme),
        const SizedBox(height: 12),
        _feedback(theme, correctLabel: 'Great — starting practice…'),
      ],
    );
  }

  Widget _practiceBody(ThemeData theme) {
    final morse = displayMorse(morseForChar(_target) ?? '');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Key this letter', style: theme.textTheme.titleMedium),
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
                  onPressed: () => setState(() => _showHint = true),
                  child: const Text('Show hint'),
                ),
        ),
        const SizedBox(height: 16),
        _keyingBox(theme),
        const SizedBox(height: 12),
        _feedback(theme, correctLabel: 'Correct!'),
        const SizedBox(height: 20),
        _progressChips(theme),
      ],
    );
  }

  Widget _completeBody(ThemeData theme) {
    final last = _level >= _levelCount;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events, size: 72, color: theme.colorScheme.tertiary),
        const SizedBox(height: 16),
        Text(
          last ? 'Tutorial complete!' : 'Level $_level complete!',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          last
              ? 'You can key all $_levelCount letters. Well done!'
              : 'You mastered keying ${_levelLetters.join(' ')}.',
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
              label: const Text('Repeat level (Esc)'),
            ),
            if (!last) ...[
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _startLevel(_level + 1),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next level (Enter)'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// The live "you are keying" display, as on the Input Train screen.
  Widget _keyingBox(ThemeData theme) {
    return Column(
      children: [
        Text('You are keying:', style: theme.textTheme.bodySmall),
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

  Widget _feedback(ThemeData theme, {required String correctLabel}) {
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
              : 'You keyed "$_lastDecoded" — try again',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ok ? Colors.green : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _controls(ThemeData theme, AppScope scope) {
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
          label: const Text('Hear it'),
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
          label: const Text('Clear'),
        ),
      ],
    );
  }
}
