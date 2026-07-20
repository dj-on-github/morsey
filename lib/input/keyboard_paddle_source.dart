import 'package:flutter/services.dart';

import 'paddle_source.dart';

/// Uses two keyboard keys as dit / dah paddles, so the trainer can be practised
/// without the USB key. Defaults: Left-Arrow = dit, Right-Arrow = dah (the
/// '.'/period and '-'/minus keys work too).
///
/// Left-Ctrl and Right-Ctrl are also mapped (left/right group respectively):
/// the USB iambic key enumerates as a HID keyboard whose paddles send those
/// modifiers, so on platforms without raw HID access (iPadOS) it drives this
/// source directly.
///
/// The owning widget forwards raw [KeyEvent]s to [handleKeyEvent]; this class
/// translates them into paddle transitions.
class KeyboardPaddleSource extends PaddleSource {
  KeyboardPaddleSource({this.ditIsLeft = true, this.statusLabel});

  bool ditIsLeft;

  /// Overrides the default status line (used when this source is standing in
  /// for the USB key on platforms where it appears as a keyboard).
  final String? statusLabel;

  bool _ditDown = false;
  bool _dahDown = false;

  @override
  String get status =>
      statusLabel ??
      'Keyboard paddles — ${ditIsLeft ? "Left-Arrow = dit, Right-Arrow = dah" : "Right-Arrow = dit, Left-Arrow = dah"}';
  @override
  bool get connected => true;

  static bool _isDitKey(LogicalKeyboardKey k) =>
      k == LogicalKeyboardKey.arrowLeft ||
      k == LogicalKeyboardKey.period ||
      k == LogicalKeyboardKey.numpadDecimal ||
      k == LogicalKeyboardKey.controlLeft;

  static bool _isDahKey(LogicalKeyboardKey k) =>
      k == LogicalKeyboardKey.arrowRight ||
      k == LogicalKeyboardKey.minus ||
      k == LogicalKeyboardKey.numpadSubtract ||
      k == LogicalKeyboardKey.controlRight;

  /// Returns true if the event was a paddle key (so the widget can swallow it).
  bool handleKeyEvent(KeyEvent event) {
    final key = event.logicalKey;
    final isLeftKey = _isDitKey(key); // "left" group: arrow-left / period
    final isRightKey = _isDahKey(key); // "right" group: arrow-right / minus
    if (!isLeftKey && !isRightKey) return false;

    // Repeats just re-assert the held state; ignore them.
    if (event is KeyRepeatEvent) return true;
    final down = event is KeyDownEvent;

    // Map the physical side to a paddle according to ditIsLeft.
    final targetsDit = ditIsLeft ? isLeftKey : isRightKey;

    if (targetsDit) {
      if (down != _ditDown) {
        _ditDown = down;
        onDit?.call(down);
      }
    } else {
      if (down != _dahDown) {
        _dahDown = down;
        onDah?.call(down);
      }
    }
    return true;
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {
    if (_ditDown) {
      _ditDown = false;
      onDit?.call(false);
    }
    if (_dahDown) {
      _dahDown = false;
      onDah?.call(false);
    }
  }
}
