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
/// Platforms:
///   * Linux — opens `/dev/hidrawN` directly and reads the raw reports.
///   * macOS — talks to a native IOHIDManager bridge (see
///     `macos/Runner/HidPaddle.swift`) that ships the same 1-byte modifier
///     bitmap over an EventChannel.
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

  bool ditIsLeft;

  String _status = 'Not started';
  bool _connected = false;

  // Linux state.
  RandomAccessFile? _raf;
  bool _stopped = false;

  // macOS state.
  StreamSubscription<dynamic>? _macSub;

  // Debounce for paddle transitions (either platform).
  bool _lastDit = false;
  bool _lastDah = false;

  @override
  String get status => _status;
  @override
  bool get connected => _connected;

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
      await _startLinux();
    } else if (Platform.isMacOS) {
      await _startMacOS();
    } else {
      _status = 'USB paddle not supported on this platform';
      _connected = false;
    }
  }

  @override
  Future<void> stop() async {
    _stopped = true;
    // Linux
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
    _connected = false;
    _status = 'Stopped';
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

  Future<void> _startLinux() async {
    final path = _linuxFindDevicePath();
    if (path == null) {
      _status = 'USB key 413d:2107 not found';
      _connected = false;
      return;
    }
    try {
      _raf = await File(path).open(mode: FileMode.read);
    } on Object catch (e) {
      _status = 'Found $path but cannot open it (permissions?): $e';
      _connected = false;
      return;
    }
    _status = 'Connected: $path';
    _connected = true;
    unawaited(_linuxReadLoop());
  }

  Future<void> _linuxReadLoop() async {
    final raf = _raf;
    if (raf == null) return;
    try {
      while (!_stopped) {
        final report = await raf.read(8);
        if (report.isEmpty) break; // EOF — unplugged.
        _dispatchModifiers(report[0]);
      }
    } on Object catch (e) {
      if (!_stopped) _status = 'Read error: $e';
    } finally {
      _connected = false;
      _releaseLatched();
    }
  }

  // ---------------------------------------------------------------- macOS --

  Future<void> _startMacOS() async {
    String? status;
    try {
      status = await _macChannel.invokeMethod<String>('start');
    } on PlatformException catch (e) {
      _status = 'macOS HID error: ${e.message ?? e.code}';
      _connected = false;
      return;
    } on MissingPluginException {
      _status = 'macOS HID bridge not registered';
      _connected = false;
      return;
    }
    if (status == null) {
      _status = 'USB key 413d:2107 not found';
      _connected = false;
      return;
    }
    _status = status;
    _connected = status.startsWith('Connected');
    _macSub = _macEvents.receiveBroadcastStream().listen(
      (dynamic data) {
        if (data is Uint8List && data.isNotEmpty) {
          _dispatchModifiers(data[0]);
        } else if (data is List && data.isNotEmpty && data.first is int) {
          _dispatchModifiers(data.first as int);
        }
      },
      onError: (Object err) {
        _status = 'macOS HID stream error: $err';
        _connected = false;
        _releaseLatched();
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
