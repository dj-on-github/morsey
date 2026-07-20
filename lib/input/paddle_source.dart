/// A source of raw paddle up/down events feeding the iambic keyer.
///
/// Two paddles: [dit] and [dah]. Implementations translate a physical input
/// (USB HID key, or keyboard keys) into calls on [onDit] / [onDah].
abstract class PaddleSource {
  /// Called whenever the dit paddle changes state (true = pressed).
  void Function(bool down)? onDit;

  /// Called whenever the dah paddle changes state (true = pressed).
  void Function(bool down)? onDah;

  /// Human-readable status (e.g. detected device path, or an error).
  String get status;

  /// True when the source is connected and delivering events.
  bool get connected;

  Future<void> start();
  Future<void> stop();
}
