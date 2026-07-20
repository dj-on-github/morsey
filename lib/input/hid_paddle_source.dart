import 'dart:async';
import 'dart:io';

import 'paddle_source.dart';

/// Reads the USB iambic key (VID:PID 413d:2107) directly from its Linux
/// `/dev/hidrawN` node.
///
/// The device presents as a boot-protocol HID keyboard and streams 8-byte
/// reports continuously (~125 Hz). Only byte 0 (the modifier bitmap) matters:
///   * bit 0x01 (Left-Ctrl)  -> one paddle
///   * bit 0x10 (Right-Ctrl) -> the other paddle
///
/// Which paddle is dit vs dah is decided by [ditIsLeft] (from Settings).
class HidPaddleSource extends PaddleSource {
  HidPaddleSource({this.ditIsLeft = true});

  /// USB identifiers of the supported key.
  static const int vendorId = 0x413d;
  static const int productId = 0x2107;

  /// Modifier bitmask for the left paddle (Left-Ctrl) and right (Right-Ctrl).
  static const int _leftBit = 0x01;
  static const int _rightBit = 0x10;

  bool ditIsLeft;

  String _status = 'Not started';
  bool _connected = false;
  RandomAccessFile? _raf;
  StreamSubscription<List<int>>? _sub;
  bool _lastDit = false;
  bool _lastDah = false;
  bool _stopped = false;

  @override
  String get status => _status;
  @override
  bool get connected => _connected;

  /// Scans /sys/class/hidraw for the node belonging to 413d:2107.
  /// Returns e.g. `/dev/hidraw10`, or null if not found.
  static String? findDevicePath() {
    final want = '${vendorId.toRadixString(16).padLeft(4, '0')}'
            ':${productId.toRadixString(16).padLeft(4, '0')}'
        .toUpperCase();
    final dir = Directory('/sys/class/hidraw');
    if (!dir.existsSync()) return null;
    for (final entry in dir.listSync()) {
      // Note: for symlink entries the URI ends in '/', so derive the node
      // name from the path rather than uri.pathSegments.last (which is empty).
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

  @override
  Future<void> start() async {
    _stopped = false;
    final path = findDevicePath();
    if (path == null) {
      _status = 'USB key 413d:2107 not found';
      _connected = false;
      return;
    }
    try {
      _raf = await File(path).open(mode: FileMode.read);
    } on Object catch (e) {
      _status = 'Found $path but cannot open it '
          '(permissions?): $e';
      _connected = false;
      return;
    }
    _status = 'Connected: $path';
    _connected = true;
    unawaited(_readLoop());
  }

  /// Continuously reads 8-byte reports and dispatches paddle transitions.
  Future<void> _readLoop() async {
    final raf = _raf;
    if (raf == null) return;
    try {
      while (!_stopped) {
        final report = await raf.read(8);
        if (report.isEmpty) {
          // EOF — device likely unplugged.
          break;
        }
        final mods = report[0];
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
    } on Object catch (e) {
      if (!_stopped) {
        _status = 'Read error: $e';
      }
    } finally {
      _connected = false;
      // Release any latched paddles so the keyer doesn't hang.
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

  @override
  Future<void> stop() async {
    _stopped = true;
    await _sub?.cancel();
    _sub = null;
    try {
      await _raf?.close();
    } on Object {
      // ignore
    }
    _raf = null;
    _connected = false;
    _status = 'Stopped';
  }
}
