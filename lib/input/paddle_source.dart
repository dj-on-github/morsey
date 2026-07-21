/// What a paddle source is currently doing. Sources report structured status
/// rather than display text so the UI layer can localize it (see
/// l10n/status_l10n.dart).
enum PaddleStatusKind {
  /// start() has not run (or the source was stopped).
  idle,

  /// Keyboard paddles are listening (they always are once started).
  keyboardReady,

  /// No USB key present; the source keeps watching and connects on hotplug.
  usbWaiting,

  /// The USB key is attached and delivering events.
  usbConnected,

  /// The USB key was attached earlier and has been unplugged.
  usbUnplugged,

  /// The device node exists but could not be opened (Linux permissions).
  usbOpenFailed,

  /// The OS denied opening the device (macOS TCC / Input Monitoring).
  usbOpenDenied,

  /// Any other failure (bridge missing, stream error…).
  usbError,
}

/// A status snapshot: the [kind] plus optional raw details for display.
/// [detail] is a location (e.g. `/dev/hidraw3`); [error] is untranslated
/// diagnostic text (exception message, IOReturn code).
class PaddleStatus {
  const PaddleStatus(this.kind, {this.detail, this.error});

  final PaddleStatusKind kind;
  final String? detail;
  final String? error;
}

/// A source of raw paddle up/down events feeding the iambic keyer.
///
/// Two paddles: [dit] and [dah]. Implementations translate a physical input
/// (USB HID key, or keyboard keys) into calls on [onDit] / [onDah].
abstract class PaddleSource {
  /// Called whenever the dit paddle changes state (true = pressed).
  void Function(bool down)? onDit;

  /// Called whenever the dah paddle changes state (true = pressed).
  void Function(bool down)? onDah;

  /// Called when [status] / [connected] change (e.g. the USB key was plugged
  /// in or unplugged mid-session), so the UI can repaint.
  void Function()? onStatus;

  /// Structured status; render with the extensions in l10n/status_l10n.dart.
  PaddleStatus get status;

  /// True when the source is connected and delivering events.
  bool get connected;

  Future<void> start();
  Future<void> stop();
}
