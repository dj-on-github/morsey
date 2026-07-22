import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../audio/audio_engine.dart';
import '../input/combined_paddle_source.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/status_l10n.dart';
import '../models/settings.dart';
import '../morsey/iambic_keyer.dart';
import '../morsey/morse_code.dart';
import 'page_scaffold.dart';

/// The reverse of Free Type: the operator keys Morse (USB paddle or keyboard)
/// and the program decodes it into text. The dots and dashes appear in the
/// Morse box as they are keyed; each pattern committed by the letter gap is
/// decoded and appended to the text box, and a further pause up to the word
/// gap (seven dits) inserts a space. The audio toggle mutes or unmutes the
/// keying side-tone.
class FreeKeyScreen extends StatefulWidget {
  const FreeKeyScreen({super.key});

  @override
  State<FreeKeyScreen> createState() => _FreeKeyScreenState();
}

/// Forwards the keyer's tone calls to the real engine only while [enabled] —
/// lets the audio toggle silence keying without touching the shared engine.
class _GatedAudio extends AudioEngine {
  _GatedAudio(this._inner) : super(_inner.frequency, _inner.volume);

  final AudioEngine _inner;
  bool enabled = true;

  @override
  bool get available => _inner.available;
  @override
  Future<void> start() async {}
  @override
  Future<void> dispose() async {}
  @override
  void toneOn() {
    if (enabled) _inner.toneOn();
  }

  @override
  void toneOff() => _inner.toneOff();
}

class _FreeKeyScreenState extends State<FreeKeyScreen> {
  final _focusNode = FocusNode(debugLabel: 'FreeKeyInput');
  final _textScroll = ScrollController();
  final _morseScroll = ScrollController();

  Settings? _settings;
  late _GatedAudio _gated;
  late IambicKeyer _keyer;
  CombinedPaddleSource? _paddles;

  bool _audioOn = true;
  String _text = ''; // decoded characters (plus word spaces)
  final List<String> _patterns = []; // keyed patterns; ' ' marks a word gap
  String _livePattern = '';
  Timer? _wordGap;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      final scope = AppScope.of(context);
      _settings = scope.settings;
      _gated = _GatedAudio(scope.audio);
      _keyer = IambicKeyer(
        ditMs: () => _settings!.ditMs,
        straightKey: () => _settings!.keyerMode == KeyerMode.straight,
        audio: _gated,
        onPattern: (p) => setState(() {
          _livePattern = p;
          if (p.isNotEmpty) _wordGap?.cancel();
        }),
        onCharacter: _onCharacter,
      );
      _keyer.start();
      _settings!.addListener(_onSettingsChanged);
      _attachPaddles(scope.paddles);
    }
  }

  @override
  void dispose() {
    _detachPaddles();
    _wordGap?.cancel();
    _settings?.removeListener(_onSettingsChanged);
    _keyer.dispose();
    _focusNode.dispose();
    _textScroll.dispose();
    _morseScroll.dispose();
    super.dispose();
  }

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

  // --- Decoding --------------------------------------------------------------

  /// A letter gap committed the keyed pattern: append it and its decoding.
  void _onCharacter(String pattern, String? char) {
    setState(() {
      _patterns.add(pattern);
      _text += char ?? '*'; // '*' marks an undecodable pattern
    });
    _scrollToEnd();
    // The commit fires 3 dits after the last mark; a word gap is 7, so a
    // space is due 4 dits later unless a new character starts first.
    _wordGap?.cancel();
    _wordGap = Timer(
      Duration(milliseconds: 4 * _settings!.ditMs),
      () {
        if (!mounted || _livePattern.isNotEmpty) return;
        if (_text.isEmpty || _text.endsWith(' ')) return;
        setState(() {
          _text += ' ';
          _patterns.add(' ');
        });
        _scrollToEnd();
      },
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in [_textScroll, _morseScroll]) {
        if (c.hasClients) c.jumpTo(c.position.maxScrollExtent);
      }
    });
  }

  void _toggleAudio() {
    setState(() => _audioOn = !_audioOn);
    _gated.enabled = _audioOn;
    if (!_audioOn) _gated.toneOff(); // in case a mark is sounding
  }

  void _clear() {
    _keyer.clear();
    _wordGap?.cancel();
    setState(() {
      _text = '';
      _patterns.clear();
      _livePattern = '';
    });
    _refocus();
  }

  void _refocus() {
    if (mounted) _focusNode.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final handled = _paddles?.handleKeyEvent(event) ?? false;
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  /// The keyed morse: committed patterns (letters separated by spaces, word
  /// gaps as " / ") plus the in-progress character's elements.
  String _renderedMorse() {
    final buf = StringBuffer();
    for (final p in _patterns) {
      if (p == ' ') {
        buf.write('/  ');
      } else {
        buf
          ..write(displayMorse(p))
          ..write('  ');
      }
    }
    buf.write(displayMorse(_livePattern));
    return buf.toString();
  }

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final morse = _renderedMorse();
    final usb = _paddles?.usbConnected == true;

    return PageScaffold(
      title: l10n.menuFreeKey,
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
                  FilledButton.tonalIcon(
                    onPressed: _toggleAudio,
                    icon:
                        Icon(_audioOn ? Icons.volume_up : Icons.volume_off),
                    label: Text(_audioOn
                        ? l10n.freeTypeAudioOn
                        : l10n.freeTypeAudioOff),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.backspace_outlined),
                    label: Text(l10n.clear),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    usb ? Icons.usb : Icons.keyboard,
                    size: 18,
                    color: usb ? Colors.green : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _paddles?.statusText(l10n) ?? l10n.statusStarting,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.freeKeyTextLabel, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Container(
                height: 96,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  controller: _textScroll,
                  child: SelectableText(
                    _text.isEmpty ? '·' : _text,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      height: 1.4,
                      color: _text.isEmpty
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.freeTypeMorseLabel, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    controller: _morseScroll,
                    child: Text(
                      morse.isEmpty ? '·' : morse,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        letterSpacing: 4,
                        height: 1.6,
                        color: morse.isEmpty
                            ? theme.colorScheme.outline
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
