import 'dart:math';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../input/combined_paddle_source.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/status_l10n.dart';
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
  CombinedPaddleSource? _source;

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
        straightKey: () => _settings!.keyerMode == KeyerMode.straight,
        audio: scope.audio,
        onPattern: (p) => setState(() => _livePattern = p),
        onCharacter: _onCharacter,
      );
      _keyer.start();
      _settings!.addListener(_onSettingsChanged);
      _nextTarget();
      _startSource();
    }
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    _source?.ditIsLeft = _settings!.ditPaddle == DitPaddle.left;
    setState(() {});
  }

  /// Starts the combined keyboard + USB source; the USB key hotplugs.
  Future<void> _startSource() async {
    final src = CombinedPaddleSource(
      ditIsLeft: _settings!.ditPaddle == DitPaddle.left,
    );
    src.onDit = (down) => _keyer.setDit(down);
    src.onDah = (down) => _keyer.setDah(down);
    src.onStatus = () {
      if (mounted) setState(() {});
    };
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
    final handled = _source?.handleKeyEvent(event) ?? false;
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
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
    final l10n = AppLocalizations.of(context);
    final targetMorse = displayMorse(morseForChar(_target) ?? '');
    final usb = _source?.usbConnected == true;

    return PageScaffold(
      title: l10n.menuInputTrain,
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
              // Status line: keyboard always works, USB key hotplugs.
              Row(
                children: [
                  Icon(
                    usb ? Icons.usb : Icons.keyboard,
                    size: 18,
                    color: usb ? Colors.green : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _source?.statusText(l10n) ?? l10n.statusStarting,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(l10n.score(_correct, _attempts),
                      style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.keyThisCharacter,
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
                                child: Text(l10n.showHint),
                              ),
                      ),
                      const SizedBox(height: 24),
                      // Live keyed pattern.
                      Text(l10n.youAreKeying,
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
                          _livePattern.isEmpty
                              ? '·'
                              : displayMorse(_livePattern),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            letterSpacing: 6,
                            fontFeatures: const [],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _feedback(theme, l10n),
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
                    label: Text(l10n.clear),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _nextTarget,
                    icon: const Icon(Icons.skip_next),
                    label: Text(l10n.skipNext),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedback(ThemeData theme, AppLocalizations l10n) {
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
            ok ? l10n.correct : l10n.youKeyedTryAgain(_lastDecoded ?? '?'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: ok ? Colors.green : theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
