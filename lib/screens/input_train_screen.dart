import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../input/hid_paddle_source.dart';
import '../input/keyboard_paddle_source.dart';
import '../input/paddle_source.dart';
import '../models/settings.dart';
import '../morsey/iambic_keyer.dart';
import '../morsey/morse_code.dart';
import 'page_scaffold.dart';

class InputTrainScreen extends StatefulWidget {
  const InputTrainScreen({super.key});

  @override
  State<InputTrainScreen> createState() => _InputTrainScreenState();
}

class _InputTrainScreenState extends State<InputTrainScreen> {
  final _random = Random();
  final _focusNode = FocusNode();

  Settings? _settings;
  late IambicKeyer _keyer;
  PaddleSource? _source;
  InputMethod? _sourceMethod;

  bool _disposed = false;
  String _target = 'E';
  String _livePattern = '';
  String? _lastDecoded;
  bool? _lastCorrect;
  bool _showHint = false;
  int _correct = 0;
  int _attempts = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    if (_settings == null) {
      _settings = scope.settings;
      _keyer = IambicKeyer(
        ditMs: () => _settings!.ditMs,
        audio: scope.audio,
        onPattern: (p) => setState(() => _livePattern = p),
        onCharacter: _onCharacter,
      );
      _keyer.start();
      _settings!.addListener(_onSettingsChanged);
      _nextTarget();
      _rebuildSource();
    }
  }

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

  void _onCharacter(String pattern, String? char) {
    setState(() {
      _attempts++;
      _lastDecoded = char ?? '?';
      _lastCorrect = char != null && char.toUpperCase() == _target;
      if (_lastCorrect == true) {
        _correct++;
        // Move on after a short pause so the tick is visible.
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _nextTarget();
        });
      }
    });
  }

  void _nextTarget() {
    final chars = _settings!.characterSet.characters;
    setState(() {
      _target = chars[_random.nextInt(chars.length)];
      _livePattern = '';
      _lastDecoded = null;
      _lastCorrect = null;
    });
    _keyer.clear();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
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
    _settings?.removeListener(_onSettingsChanged);
    _keyer.dispose();
    _source?.stop();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = _settings!;
    final targetMorse = morseForChar(_target) ?? '';

    return PageScaffold(
      title: 'Input Train',
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status line.
              Row(
                children: [
                  Icon(
                    _source?.connected == true
                        ? Icons.link
                        : Icons.link_off,
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
                  Text('Score: $_correct / $_attempts',
                      style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              if (settings.inputMethod == InputMethod.keyboardPaddle)
                Text(
                  'Keyboard paddles: Left-Arrow = dit, Right-Arrow = dah '
                  '(click here first to focus).',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Key this character:',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        _target,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hint (morse of target).
                      SizedBox(
                        height: 28,
                        child: _showHint
                            ? Text(
                                targetMorse,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  letterSpacing: 4,
                                  color: theme.colorScheme.outline,
                                ),
                              )
                            : TextButton(
                                onPressed: () =>
                                    setState(() => _showHint = true),
                                child: const Text('Show hint'),
                              ),
                      ),
                      const SizedBox(height: 24),
                      // Live keyed pattern.
                      Text('You are keying:',
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Container(
                        constraints: const BoxConstraints(minWidth: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: theme.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _livePattern.isEmpty ? '·' : _livePattern,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            letterSpacing: 6,
                            fontFeatures: const [],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _feedback(theme),
                    ],
                  ),
                ),
              ),

              // Controls.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _keyer.clear();
                      setState(() {
                        _livePattern = '';
                        _lastDecoded = null;
                        _lastCorrect = null;
                      });
                    },
                    icon: const Icon(Icons.backspace_outlined),
                    label: const Text('Clear'),
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
    if (_lastDecoded == null) {
      return const SizedBox(height: 40);
    }
    final ok = _lastCorrect == true;
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ok ? Icons.check_circle : Icons.cancel,
              color: ok ? Colors.green : theme.colorScheme.error),
          const SizedBox(width: 8),
          Text(
            ok
                ? 'Correct!'
                : 'You keyed "$_lastDecoded" — try again',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ok ? Colors.green : theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
