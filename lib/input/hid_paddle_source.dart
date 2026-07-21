import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'paddle_source.dart';

/// Reads the USB iambic key (VID:PID 413d:2107) as a HID boot-protocol
/// keyboard and turns Left-Ctrl / Right-Ctrl transitions into paddle events.
///
/// The device streams 8-byte boot-keyboard reports whose byte 0 is a modifier
/// bitmap:
///   * bit 0x01 (Left-Ctrl)  -> one paddle
///   * bit 0x10 (Right-Ctrl) -> the other paddle
///
/// Which paddle is dit vs dah is decided by [ditIsLeft] (from Settings).
///
/// The source keeps watching for the key while started: plugging it in (or
/// re-plugging it) mid-session connects automatically and fires [onStatus].
///
/// Platforms:
///   * Linux — opens `/dev/hidrawN` directly and reads the raw reports; a
///     2-second retry timer picks up hotplug arrivals and re-opens after EOF.
///   * macOS — talks to a native IOHIDManager bridge (see
///     `macos/Runner/HidPaddle.swift`). IOHIDManager tracks matching devices
///     natively; the bridge streams the 1-byte modifier bitmap plus
///     'connected' / 'disconnected' status strings over an EventChannel.
class HidPaddleSource extends PaddleSource {
  HidPaddleSource({this.ditIsLeft = true});

  /// USB identifiers of the supported key.
  static const int vendorId = 0x413d;
  static const int productId = 0x2107;

  /// Modifier bitmask for the left paddle (Left-Ctrl) and right (Right-Ctrl).
  static const int _leftBit = 0x01;
  static const int _rightBit = 0x10;

  static const MethodChannel _macChannel = MethodChannel('morsey/hid_paddle');
  static const EventChannel _macEvents =
      EventChannel('morsey/hid_paddle/events');

  /// How often to look for the key while it is absent (Linux).
  static const Duration _retryInterval = Duration(seconds: 2);

  bool ditIsLeft;

  PaddleStatus _status = const PaddleStatus(PaddleStatusKind.idle);
  bool _connected = false;

  // Linux state.
  RandomAccessFile? _raf;
  bool _stopped = false;
  Timer? _retry;
  bool _attempting = false;

  // macOS state.
  StreamSubscription<dynamic>? _macSub;

  // Debounce for paddle transitions (either platform).
  bool _lastDit = false;
  bool _lastDah = false;

  @override
  PaddleStatus get status => _status;
  @override
  bool get connected => _connected;

  void _setStatus(PaddleStatus status, bool connected) {
    if (status.kind == _status.kind &&
        status.detail == _status.detail &&
        status.error == _status.error &&
        connected == _connected) {
      return;
    }
    _status = status;
    _connected = connected;
    onStatus?.call();
  }

  /// Best-effort device presence check. Returns a human-readable location
  /// (e.g. `/dev/hidraw3` on Linux, `IOKit HID 413D:2107` on macOS) if the
  /// key is plugged in, else null. Returns null on unsupported platforms.
  static Future<String?> detect() async {
    if (Platform.isLinux) return _linuxFindDevicePath();
    if (Platform.isMacOS) {
      try {
        return await _macChannel.invokeMethod<String>('detect');
      } on PlatformException {
        return null;
      } on MissingPluginException {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> start() async {
    _stopped = false;
    if (Platform.isLinux) {
      await _linuxAttempt();
      // Keep watching so a key plugged in (or re-plugged) mid-session just
      // starts working.
      _retry?.cancel();
      _retry = Timer.periodic(_retryInterval, (_) {
        if (!_stopped && !_connected) _linuxAttempt();
      });
    } else if (Platform.isMacOS) {
      await _startMacOS();
    } else {
      _setStatus(const PaddleStatus(PaddleStatusKind.usbError,
          error: 'unsupported platform'), false);
    }
  }

  @override
  Future<void> stop() async {
    _stopped = true;
    // Linux
    _retry?.cancel();
    _retry = null;
    try {
      await _raf?.close();
    } on Object {
      // ignore
    }
    _raf = null;
    // macOS
    await _macSub?.cancel();
    _macSub = null;
    if (Platform.isMacOS) {
      try {
        await _macChannel.invokeMethod<void>('stop');
      } on Object {
        // ignore
      }
    }
    _setStatus(const PaddleStatus(PaddleStatusKind.idle), false);
    _releaseLatched();
  }

  // ---------------------------------------------------------------- Linux --

  static String? _linuxFindDevicePath() {
    final want = '${vendorId.toRadixString(16).padLeft(4, '0')}'
            ':${productId.toRadixString(16).padLeft(4, '0')}'
        .toUpperCase();
    final dir = Directory('/sys/class/hidraw');
    if (!dir.existsSync()) return null;
    for (final entry in dir.listSync()) {
      // Symlink entries end in '/', so read the node name from the path.
      final name = entry.path.split('/').last;
      if (!name.startsWith('hidraw')) continue;
      final uevent = File('${entry.path}/device/uevent');
      if (!uevent.existsSync()) continue;
      try {
        final text = uevent.readAsStringSync().toUpperCase();
        // HID_ID line looks like: HID_ID=0003:0000413D:00002107
        if (text.contains('413D') && text.contains('2107')) {
          if (text.contains('HID_ID') &&
              (text.contains('413D:00002107') ||
                  text.contains(':0000413D:00002107') ||
                  text.contains(want))) {
            return '/dev/$name';
          }
        }
      } on Object {
        // Unreadable; keep looking.
      }
    }
    return null;
  }

  /// One attempt to find and open the device. Called at start and from the
  /// retry timer while disconnected.
  Future<void> _linuxAttempt() async {
    if (_attempting) return;
    _attempting = true;
    try {
      // Drop any stale handle from before an unplug.
      try {
        await _raf?.close();
      } on Object {
        // ignore
      }
      _raf = null;
      final path = _linuxFindDevicePath();
      if (path == null) {
        _setStatus(const PaddleStatus(PaddleStatusKind.usbWaiting), false);
        return;
      }
      RandomAccessFile raf;
      try {
        raf = await File(path).open(mode: FileMode.read);
      } on Object catch (e) {
        _setStatus(
            PaddleStatus(PaddleStatusKind.usbOpenFailed,
                detail: path, error: '$e'),
            false);
        return;
      }
      if (_stopped) {
        await raf.close();
        return;
      }
      _raf = raf;
      _setStatus(PaddleStatus(PaddleStatusKind.usbConnected, detail: path),
          true);
      unawaited(_linuxReadLoop(raf));
    } finally {
      _attempting = false;
    }
  }

  Future<void> _linuxReadLoop(RandomAccessFile raf) async {
    try {
      while (!_stopped) {
        final report = await raf.read(8);
        if (report.isEmpty) break; // EOF — unplugged.
        _dispatchModifiers(report[0]);
      }
    } on Object {
      // Fall through to the unplugged state; the retry timer reconnects.
    } finally {
      _releaseLatched();
      if (!_stopped) {
        _setStatus(
            const PaddleStatus(PaddleStatusKind.usbUnplugged), false);
      }
    }
  }

  // ---------------------------------------------------------------- macOS --

  Future<void> _startMacOS() async {
    String? status;
    try {
      status = await _macChannel.invokeMethod<String>('start');
    } on PlatformException catch (e) {
      _setStatus(
          PaddleStatus(PaddleStatusKind.usbError,
              error: e.message ?? e.code),
          false);
      return;
    } on MissingPluginException {
      _setStatus(
          const PaddleStatus(PaddleStatusKind.usbError,
              error: 'HID bridge not registered'),
          false);
      return;
    }
    // Native contract: null = no device yet (the manager stays open and
    // reports 'connected' when the key arrives); 'connected' = attached;
    // 'denied:<IOReturn>' = the OS refused (TCC / Input Monitoring).
    if (status == null) {
      _setStatus(const PaddleStatus(PaddleStatusKind.usbWaiting), false);
    } else if (status == 'connected') {
      _setStatus(
          const PaddleStatus(PaddleStatusKind.usbConnected,
              detail: 'IOKit HID 413D:2107'),
          true);
    } else if (status.startsWith('denied:')) {
      _setStatus(
          PaddleStatus(PaddleStatusKind.usbOpenDenied,
              error: status.substring('denied:'.length)),
          false);
    } else {
      _setStatus(PaddleStatus(PaddleStatusKind.usbError, error: status),
          false);
    }
    _macSub = _macEvents.receiveBroadcastStream().listen(
      (dynamic data) {
        if (data is Uint8List && data.isNotEmpty) {
          _dispatchModifiers(data[0]);
        } else if (data is String) {
          if (data == 'connected') {
            _setStatus(
                const PaddleStatus(PaddleStatusKind.usbConnected,
                    detail: 'IOKit HID 413D:2107'),
                true);
          } else if (data == 'disconnected') {
            _releaseLatched();
            _setStatus(
                const PaddleStatus(PaddleStatusKind.usbUnplugged), false);
          }
        } else if (data is List && data.isNotEmpty && data.first is int) {
          _dispatchModifiers(data.first as int);
        }
      },
      onError: (Object err) {
        _releaseLatched();
        _setStatus(
            PaddleStatus(PaddleStatusKind.usbError, error: '$err'), false);
      },
    );
  }

  // ---------------------------------------------------------------- shared --

  void _dispatchModifiers(int mods) {
    final leftDown = (mods & _leftBit) != 0;
    final rightDown = (mods & _rightBit) != 0;
    final ditDown = ditIsLeft ? leftDown : rightDown;
    final dahDown = ditIsLeft ? rightDown : leftDown;
    if (ditDown != _lastDit) {
      _lastDit = ditDown;
      onDit?.call(ditDown);
    }
    if (dahDown != _lastDah) {
      _lastDah = dahDown;
      onDah?.call(dahDown);
    }
  }

  void _releaseLatched() {
    if (_lastDit) {
      _lastDit = false;
      onDit?.call(false);
    }
    if (_lastDah) {
      _lastDah = false;
      onDah?.call(false);
    }
  }
}
