import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../audio/audio_engine.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/settings.dart';
import '../morsey/morse_code.dart';
import 'onscreen_keyboard.dart';
import 'page_scaffold.dart';

/// Type any text and watch it rendered as Morse. The dots and dashes appear
/// element by element at the configured WPM (PARIS timing), and — when the
/// audio toggle is on — the side-tone sounds in sync with each mark, so the
/// display always advances at exactly the rate the audio plays.
class FreeTypeScreen extends StatefulWidget {
  const FreeTypeScreen({super.key});

  @override
  State<FreeTypeScreen> createState() => _FreeTypeScreenState();
}

class _FreeTypeScreenState extends State<FreeTypeScreen> {
  final _controller = TextEditingController();
  final _morseScroll = ScrollController();

  Settings? _settings;
  AudioEngine? _audio;

  bool _audioOn = true;
  int _done = 0; // characters of the text fully rendered
  String _partial = ''; // elements shown of the character in progress
  String _prevText = '';
  int _token = 0; // bumped to cancel the in-flight character
  bool _running = false;
  bool _disposed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      final scope = AppScope.of(context);
      _settings = scope.settings;
      _audio = scope.audio;
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _token++;
    _audio?.toneOff();
    _controller.dispose();
    _morseScroll.dispose();
    super.dispose();
  }

  // --- Rendering queue -------------------------------------------------------

  void _onTextChanged() {
    final text = _controller.text;
    // How much of the already-rendered prefix survived this edit.
    var cp = 0;
    while (cp < text.length &&
        cp < _prevText.length &&
        text[cp] == _prevText[cp]) {
      cp++;
    }
    _prevText = text;
    if (_done > cp || (_done == cp && _partial.isNotEmpty)) {
      // The edit touched what we were rendering: cancel the in-flight
      // character and fall back to the surviving prefix.
      _token++;
      _audio?.toneOff();
      setState(() {
        if (_done > cp) _done = cp;
        _partial = '';
      });
    } else {
      setState(() {}); // repaint (e.g. hint visibility)
    }
    _ensureRunning();
  }

  void _ensureRunning() {
    if (_running || _disposed) return;
    if (_done >= _controller.text.length) return;
    _running = true;
    unawaited(_drive());
  }

  /// Consumes untyped-out characters one element at a time, at PARIS timing.
  /// The display and the (optional) tone advance together by construction.
  Future<void> _drive() async {
    try {
      while (!_disposed) {
        final text = _controller.text;
        if (_done >= text.length) break;
        final tok = _token;
        final dit = _settings!.ditMs;
        final ch = text[_done];

        if (ch == ' ') {
          // Word gap is 7 dits; 3 already elapsed as the letter gap after
          // the previous character.
          await _wait(4 * dit);
          if (tok != _token) continue;
          setState(() => _done++);
          continue;
        }

        final pattern = morseForChar(ch);
        if (pattern == null) {
          // Not encodable — skip it silently.
          setState(() => _done++);
          continue;
        }

        var interrupted = false;
        for (var i = 0; i < pattern.length; i++) {
          final markMs = pattern[i] == '-' ? 3 * dit : dit;
          setState(() => _partial = pattern.substring(0, i + 1));
          _scrollMorseToEnd();
          if (_audioOn) _audio?.toneOn();
          await _wait(markMs);
          _audio?.toneOff();
          if (tok != _token) {
            interrupted = true;
            break;
          }
          if (i != pattern.length - 1) {
            await _wait(dit); // inter-element gap
            if (tok != _token) {
              interrupted = true;
              break;
            }
          }
        }
        if (interrupted) continue; // state was reset by an edit

        setState(() {
          _done++;
          _partial = '';
        });
        await _wait(3 * dit); // letter gap
        if (tok != _token) continue;
      }
    } finally {
      _running = false;
      // Text may have arrived between the loop's check and here.
      if (!_disposed && _done < _controller.text.length) _ensureRunning();
    }
  }

  Future<void> _wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

  void _scrollMorseToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_morseScroll.hasClients) {
        _morseScroll.jumpTo(_morseScroll.position.maxScrollExtent);
      }
    });
  }

  void _toggleAudio() {
    setState(() => _audioOn = !_audioOn);
    if (!_audioOn) _audio?.toneOff(); // in case a mark is sounding
  }

  // --- On-screen keyboard editing (touch platforms) --------------------------

  /// Inserts [s] at the caret (replacing any selection); appends when the
  /// field has no valid selection.
  void _insertText(String s) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, s),
      selection: TextSelection.collapsed(offset: start + s.length),
    );
  }

  /// Deletes the selection, or the character before the caret.
  void _backspace() {
    final text = _controller.text;
    final sel = _controller.selection;
    if (sel.isValid && !sel.isCollapsed) {
      _insertText('');
      return;
    }
    final pos = sel.isValid ? sel.start : text.length;
    if (pos <= 0) return;
    _controller.value = TextEditingValue(
      text: text.replaceRange(pos - 1, pos, ''),
      selection: TextSelection.collapsed(offset: pos - 1),
    );
  }

  static final bool _isTouchPlatform = Platform.isIOS || Platform.isAndroid;

  /// The morse rendered so far: finished characters (letters separated by a
  /// space, words by " / ") plus the in-progress character's elements.
  String _renderedMorse() {
    final text = _controller.text;
    final buf = StringBuffer();
    for (var i = 0; i < _done && i < text.length; i++) {
      final ch = text[i];
      if (ch == ' ') {
        buf.write('/  ');
        continue;
      }
      final pattern = morseForChar(ch);
      if (pattern == null) continue;
      buf
        ..write(displayMorse(pattern))
        ..write('  ');
    }
    buf.write(displayMorse(_partial));
    return buf.toString();
  }

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final morse = _renderedMorse();

    return PageScaffold(
      title: l10n.menuFreeType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: _toggleAudio,
                icon: Icon(_audioOn ? Icons.volume_up : Icons.volume_off),
                label:
                    Text(_audioOn ? l10n.freeTypeAudioOn : l10n.freeTypeAudioOff),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: l10n.freeTypeInputLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.freeTypeMorseLabel, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
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
          // Touch platforms may have no keyboard to type with (iPadOS even
          // suppresses the system one while the USB key is plugged in).
          if (_isTouchPlatform) ...[
            const SizedBox(height: 8),
            OnScreenKeyboard(
              onKey: _insertText,
              onSpace: () => _insertText(' '),
              onBackspace: _backspace,
            ),
          ],
        ],
      ),
    );
  }
}
