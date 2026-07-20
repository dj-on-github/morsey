import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../models/settings.dart';
import '../morsey/morse_code.dart';
import 'onscreen_keyboard.dart';
import 'page_scaffold.dart';

/// A guided, 26-level listening course. Each level introduces one new letter
/// (following [kTutorialLetterOrder]): the letter is shown and its Morse is
/// played for the pupil to copy, then a random drill of every letter unlocked
/// so far runs until each has been answered correctly [_targetPerLetter] times.
/// Completing a level unlocks the next and is remembered in [Settings].
class ListenTutorialScreen extends StatefulWidget {
  const ListenTutorialScreen({super.key});

  @override
  State<ListenTutorialScreen> createState() => _ListenTutorialScreenState();
}

/// Where the pupil is within a level.
enum _Phase { intro, practice, levelComplete }

/// Correct answers required per letter before a level is passed.
const int _targetPerLetter = 3;

class _ListenTutorialScreenState extends State<ListenTutorialScreen> {
  final _random = Random();
  final _focusNode = FocusNode(debugLabel: 'ListenTutorialInput');

  Settings? _settings;
  int _level = 1; // 1-based
  _Phase _phase = _Phase.intro;

  late String _newLetter; // letter introduced this level
  late List<String> _levelLetters; // every letter unlocked at this level
  Map<String, int> _counts = {}; // correct answers so far, per letter
  String _target = ''; // letter currently being played in practice
  String _typed = ''; // last key the pupil pressed (for display)
  bool? _lastCorrect;
  bool _playing = false;
  int _playToken = 0; // bumped to cancel in-flight playback

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      _settings = AppScope.of(context).settings;
      // Set up the level state synchronously so the first build is valid, then
      // start the intro tone once the first frame has been laid out.
      _setupLevel(_settings!.tutorialLevel);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _play(_newLetter));
    }
  }

  void _refocus() {
    if (mounted) _focusNode.requestFocus();
  }

  int get _levelCount => kTutorialLetterOrder.length;

  // --- Level / phase transitions -------------------------------------------

  /// Initialises the fields for [level] without touching audio. Safe to call
  /// before the first frame.
  void _setupLevel(int level) {
    _level = level.clamp(1, _levelCount);
    _newLetter = kTutorialLetterOrder[_level - 1];
    _levelLetters = kTutorialLetterOrder.sublist(0, _level);
    _phase = _Phase.intro;
    _typed = '';
    _lastCorrect = null;
  }

  void _startLevel(int level) {
    setState(() => _setupLevel(level));
    _refocus();
    _play(_newLetter);
  }

  void _startPractice() {
    setState(() {
      _phase = _Phase.practice;
      _counts = {for (final c in _levelLetters) c: 0};
      _typed = '';
      _lastCorrect = null;
    });
    _pickTarget();
  }

  void _pickTarget() {
    final remaining =
        _levelLetters.where((c) => (_counts[c] ?? 0) < _targetPerLetter).toList();
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
    setState(() {
      _target = next;
      _typed = '';
      _lastCorrect = null;
    });
    _play(_target);
  }

  void _completeLevel() {
    final settings = _settings!;
    if (_level == settings.tutorialLevel && _level < _levelCount) {
      settings.tutorialLevel = _level + 1;
    }
    setState(() {
      _phase = _Phase.levelComplete;
      _playing = false;
    });
    _refocus();
  }

  // --- Audio ----------------------------------------------------------------

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

  void _replay() {
    switch (_phase) {
      case _Phase.intro:
        _play(_newLetter);
      case _Phase.practice:
        if (_target.isNotEmpty) _play(_target);
      case _Phase.levelComplete:
        break;
    }
  }

  // --- Input ----------------------------------------------------------------

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // On the completion screen, Enter advances and Esc repeats the level.
    if (_phase == _Phase.levelComplete) {
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

    final ch = event.character;
    if (ch == null || ch.length != 1 || ch.trim().isEmpty) {
      return KeyEventResult.ignored;
    }
    _check(ch);
    return KeyEventResult.handled;
  }

  void _check(String value) {
    final typed = value.toUpperCase();
    if (_phase == _Phase.intro) {
      final ok = typed == _newLetter;
      setState(() {
        _typed = typed;
        _lastCorrect = ok;
      });
      if (ok) {
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted && _phase == _Phase.intro) _startPractice();
        });
      }
      return;
    }
    if (_phase == _Phase.practice) {
      final ok = typed == _target;
      setState(() {
        _typed = typed;
        _lastCorrect = ok;
        if (ok) {
          _counts[_target] =
              min(_targetPerLetter, (_counts[_target] ?? 0) + 1);
        }
      });
      if (ok) {
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted && _phase == _Phase.practice) _pickTarget();
        });
      }
    }
  }

  @override
  void dispose() {
    _playToken++; // cancel any playback
    _focusNode.dispose();
    super.dispose();
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);

    return PageScaffold(
      title: 'Listen Tutorial',
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
              if (!scope.audio.available)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'No audio backend available — the Listen Tutorial needs sound.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              Expanded(child: Center(child: _body(theme))),
              if (_phase != _Phase.levelComplete) _controls(theme),
              // Touch platforms have no hardware keyboard to answer with.
              if (_phase != _Phase.levelComplete && _isTouchPlatform) ...[
                const SizedBox(height: 8),
                OnScreenKeyboard(
                  characters: CharacterSet.letters.characters.toSet(),
                  onKey: _check,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static final bool _isTouchPlatform = Platform.isIOS || Platform.isAndroid;

  Widget _header(ThemeData theme, Settings settings) {
    final unlocked = settings.tutorialLevel;
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
    final morse = morseForChar(_newLetter) ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('New letter', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          _newLetter,
          style: theme.textTheme.displayLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        Text(
          morse,
          style: theme.textTheme.headlineSmall
              ?.copyWith(color: theme.colorScheme.tertiary, letterSpacing: 4),
        ),
        const SizedBox(height: 16),
        Icon(
          _playing ? Icons.graphic_eq : Icons.hearing,
          size: 56,
          color: _playing
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text('Listen, then type this letter to begin',
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        _answerBox(theme),
        const SizedBox(height: 12),
        _feedback(theme, correctLabel: 'Great — starting practice…'),
      ],
    );
  }

  Widget _practiceBody(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Type the letter you hear', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Icon(
          _playing ? Icons.graphic_eq : Icons.hearing,
          size: 56,
          color: _playing
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        const SizedBox(height: 16),
        _answerBox(theme),
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
              ? 'You have learned all $_levelCount letters. Well done!'
              : 'You mastered ${_levelLetters.join(' ')}.',
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

  Widget _answerBox(ThemeData theme) {
    return Container(
      width: 110,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: _lastCorrect == null
              ? theme.colorScheme.outlineVariant
              : (_lastCorrect! ? Colors.green : theme.colorScheme.error),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _typed.isEmpty ? '?' : _typed,
        style: theme.textTheme.displaySmall?.copyWith(
          color: _typed.isEmpty
              ? theme.colorScheme.outline
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _progressChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final c in _levelLetters)
          _LetterProgress(
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
          ok ? correctLabel : 'Not quite — listen again',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ok ? Colors.green : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _controls(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.tonalIcon(
          onPressed: _playing ? null : _replay,
          icon: const Icon(Icons.replay),
          label: const Text('Replay'),
        ),
      ],
    );
  }
}

/// A compact chip showing one letter's mastery progress (filled dots).
class _LetterProgress extends StatelessWidget {
  const _LetterProgress({
    required this.letter,
    required this.count,
    required this.target,
    required this.isNew,
  });

  final String letter;
  final int count;
  final int target;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = count >= target;
    final border = done
        ? Colors.green
        : (isNew ? theme.colorScheme.primary : theme.colorScheme.outlineVariant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: border, width: isNew ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
        color: done ? Colors.green.withValues(alpha: 0.12) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(letter,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < target; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    i < count ? Icons.circle : Icons.circle_outlined,
                    size: 8,
                    color: i < count
                        ? Colors.green
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
