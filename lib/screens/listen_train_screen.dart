import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../models/settings.dart';
import '../morsey/morse_code.dart';
import 'page_scaffold.dart';

class ListenTrainScreen extends StatefulWidget {
  const ListenTrainScreen({super.key});

  @override
  State<ListenTrainScreen> createState() => _ListenTrainScreenState();
}

class _ListenTrainScreenState extends State<ListenTrainScreen> {
  final _random = Random();
  // Screen-level focus: we capture typing here so button clicks can't leave the
  // trainer unable to receive key input. Buttons re-request this focus.
  final _focusNode = FocusNode(debugLabel: 'ListenTrainInput');

  Settings? _settings;
  String _target = 'E';
  String _typed = ''; // last character the pupil typed (for display)
  bool _playing = false;
  int _playToken = 0; // bumped to cancel in-flight playback
  bool _revealed = false;
  bool? _lastCorrect;
  int _correct = 0;
  int _attempts = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      _settings = AppScope.of(context).settings;
      WidgetsBinding.instance.addPostFrameCallback((_) => _nextTarget());
    }
  }

  void _refocus() {
    if (mounted) _focusNode.requestFocus();
  }

  Future<void> _play() async {
    final scope = AppScope.of(context);
    final token = ++_playToken;
    setState(() => _playing = true);
    await scope.audio.playText(
      _target,
      _settings!.ditMs,
      cancelled: () => token != _playToken,
    );
    if (mounted && token == _playToken) setState(() => _playing = false);
    _refocus();
  }

  void _nextTarget() {
    final chars = _settings!.characterSet.characters;
    setState(() {
      _target = chars[_random.nextInt(chars.length)];
      _typed = '';
      _revealed = false;
      _lastCorrect = null;
    });
    _refocus();
    _play();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final ch = event.character;
    // Accept a single printable, non-whitespace character.
    if (ch == null || ch.length != 1 || ch.trim().isEmpty) {
      return KeyEventResult.ignored;
    }
    _check(ch);
    return KeyEventResult.handled;
  }

  void _check(String value) {
    final typed = value.toUpperCase();
    final ok = typed == _target;
    setState(() {
      _typed = typed;
      _attempts++;
      _lastCorrect = ok;
      if (ok) _correct++;
    });
    if (ok) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _nextTarget();
      });
    }
    // On a wrong answer we keep the same target so the pupil can try again;
    // focus stays on the screen-level node, so no re-focus is needed.
  }

  @override
  void dispose() {
    _playToken++; // cancel any playback
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);

    return PageScaffold(
      title: 'Listen Train',
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
              Row(
                children: [
                  if (!scope.audio.available)
                    Expanded(
                      child: Text(
                        'No audio backend available (needs pacat / PulseAudio) — '
                        'Listen Train needs sound.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    )
                  else
                    const Spacer(),
                  Text('Score: $_correct / $_attempts',
                      style: theme.textTheme.bodySmall),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Listen, then type the character you heard',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      Icon(
                        _playing ? Icons.graphic_eq : Icons.hearing,
                        size: 72,
                        color: _playing
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 24),
                      // Typed-character display box.
                      Container(
                        width: 120,
                        height: 96,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _lastCorrect == null
                                ? theme.colorScheme.outlineVariant
                                : (_lastCorrect!
                                    ? Colors.green
                                    : theme.colorScheme.error),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _typed.isEmpty ? '?' : _typed,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: _typed.isEmpty
                                ? theme.colorScheme.outline
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type a letter/number key (click here if typing does '
                        'nothing).',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(height: 16),
                      _feedback(theme),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _playing
                        ? null
                        : () {
                            _play();
                            _refocus();
                          },
                    icon: const Icon(Icons.replay),
                    label: const Text('Replay'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _revealed = true);
                      _refocus();
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Reveal'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _nextTarget,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip / Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedback(ThemeData theme) {
    if (_revealed) {
      final morse = morseForChar(_target) ?? '';
      return Text(
        'It was  "$_target"   ($morse)',
        style: theme.textTheme.titleMedium
            ?.copyWith(color: theme.colorScheme.tertiary),
      );
    }
    if (_lastCorrect == null) return const SizedBox(height: 30);
    final ok = _lastCorrect == true;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel,
            color: ok ? Colors.green : theme.colorScheme.error),
        const SizedBox(width: 8),
        Text(
          ok ? 'Correct!' : 'Not quite — listen again',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ok ? Colors.green : theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
