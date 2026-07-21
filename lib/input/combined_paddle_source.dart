import 'dart:io';

import 'package:flutter/services.dart';

import 'hid_paddle_source.dart';
import 'keyboard_paddle_source.dart';
import 'paddle_source.dart';

/// Runs the keyboard paddles and the USB key side by side and fans both into
/// one pair of [onDit] / [onDah] callbacks — whichever the operator touches
/// just works, with no input-method setting.
///
/// On Linux/macOS a [HidPaddleSource] is kept watching in the background, so
/// plugging the key in mid-session connects it automatically. On the other
/// platforms (iPadOS, Android, Windows) the key enumerates as a hardware
/// keyboard whose paddles send Left/Right-Ctrl, which the keyboard source
/// already understands — so no HID access is needed there at all.
class CombinedPaddleSource extends PaddleSource {
  CombinedPaddleSource({bool ditIsLeft = true})
      : _keyboard = KeyboardPaddleSource(ditIsLeft: ditIsLeft),
        _hid = (Platform.isLinux || Platform.isMacOS)
            ? HidPaddleSource(ditIsLeft: ditIsLeft)
            : null;

  final KeyboardPaddleSource _keyboard;
  final HidPaddleSource? _hid;

  // ignore: avoid_setters_without_getters
  set ditIsLeft(bool v) {
    _keyboard.ditIsLeft = v;
    _hid?.ditIsLeft = v;
  }

  /// Forward a raw key event to the keyboard paddles. Returns true when the
  /// event was a paddle key (so the owning widget can swallow it).
  bool handleKeyEvent(KeyEvent event) => _keyboard.handleKeyEvent(event);

  /// The keyboard is always there, so input is always possible.
  @override
  bool get connected => true;

  /// True when the USB key is currently attached and delivering events.
  bool get usbConnected => _hid?.connected ?? false;

  @override
  String get status {
    const kb = 'keyboard ←/→';
    final hid = _hid;
    if (hid == null) {
      // The USB key shows up as a keyboard here (Ctrl-bit paddles).
      return 'Paddles: $kb, or the USB key (acts as a keyboard)';
    }
    if (hid.connected) return '${hid.status} · $kb also active';
    return 'Paddles: $kb · ${hid.status}';
  }

  @override
  Future<void> start() async {
    _keyboard.onDit = (down) => onDit?.call(down);
    _keyboard.onDah = (down) => onDah?.call(down);
    await _keyboard.start();
    final hid = _hid;
    if (hid != null) {
      hid.onDit = (down) => onDit?.call(down);
      hid.onDah = (down) => onDah?.call(down);
      hid.onStatus = () => onStatus?.call();
      await hid.start();
    }
  }

  @override
  Future<void> stop() async {
    await _keyboard.stop();
    await _hid?.stop();
  }
}
