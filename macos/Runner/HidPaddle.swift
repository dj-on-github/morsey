import Cocoa
import FlutterMacOS
import IOKit
import IOKit.hid

/// Bridges the USB iambic key (VID:PID 413d:2107) to Flutter on macOS.
///
/// macOS has no /dev/hidraw*, so the Dart code cannot open the device by
/// filesystem path the way it does on Linux. Instead we open the device via
/// IOHIDManager, watch the Left-Ctrl (usage 0xE0) and Right-Ctrl (usage 0xE4)
/// modifier keys, and stream a synthesized 1-byte "modifier bitmap" over an
/// event channel. Byte layout matches the Linux HID boot-keyboard report so
/// the Dart side can decode both platforms identically.
final class HidPaddle: NSObject, FlutterStreamHandler {
    private static let vendorId: Int = 0x413D
    private static let productId: Int = 0x2107

    static let methodChannelName = "morsey/hid_paddle"
    static let eventChannelName = "morsey/hid_paddle/events"

    private var manager: IOHIDManager?
    private var opened = false
    private var eventSink: FlutterEventSink?
    private var modifiers: UInt8 = 0

    func register(with messenger: FlutterBinaryMessenger) {
        let method = FlutterMethodChannel(
            name: HidPaddle.methodChannelName, binaryMessenger: messenger)
        method.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
        let events = FlutterEventChannel(
            name: HidPaddle.eventChannelName, binaryMessenger: messenger)
        events.setStreamHandler(self)
    }

    // MARK: - Method channel

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "detect":
            result(detect())
        case "start":
            result(start())
        case "stop":
            stop()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Returns a human-readable location string if the key is present, else nil.
    /// Does not open the device.
    private func detect() -> String? {
        let mgr = IOHIDManagerCreate(kCFAllocatorDefault,
                                     IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatching(mgr, matchingDict() as CFDictionary)
        guard let devices = IOHIDManagerCopyDevices(mgr) as? Set<IOHIDDevice>,
              !devices.isEmpty else {
            return nil
        }
        return "IOKit HID 413D:2107"
    }

    /// Opens the device and starts delivering modifier-byte events. Returns a
    /// status string suitable for display (nil means "no device").
    private func start() -> String? {
        stop()
        let mgr = IOHIDManagerCreate(kCFAllocatorDefault,
                                     IOOptionBits(kIOHIDOptionsTypeNone))
        self.manager = mgr
        IOHIDManagerSetDeviceMatching(mgr, matchingDict() as CFDictionary)

        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterInputValueCallback(mgr, { context, _, _, value in
            guard let context = context else { return }
            let me = Unmanaged<HidPaddle>.fromOpaque(context).takeUnretainedValue()
            me.onInputValue(value)
        }, context)
        // Hotplug: IOHIDManager tracks matching devices for the manager's
        // lifetime, so a key plugged in mid-session starts delivering input
        // automatically. These callbacks let the Dart side show the state.
        IOHIDManagerRegisterDeviceMatchingCallback(mgr, { context, _, _, _ in
            guard let context = context else { return }
            let me = Unmanaged<HidPaddle>.fromOpaque(context).takeUnretainedValue()
            me.modifiers = 0
            me.eventSink?("connected")
        }, context)
        IOHIDManagerRegisterDeviceRemovalCallback(mgr, { context, _, _, _ in
            guard let context = context else { return }
            let me = Unmanaged<HidPaddle>.fromOpaque(context).takeUnretainedValue()
            me.modifiers = 0
            me.eventSink?("disconnected")
        }, context)
        IOHIDManagerScheduleWithRunLoop(mgr, CFRunLoopGetMain(),
                                        CFRunLoopMode.defaultMode.rawValue)

        let rc = IOHIDManagerOpen(mgr, IOOptionBits(kIOHIDOptionsTypeNone))
        if rc != kIOReturnSuccess {
            // 0xE00002C5 = kIOReturnNotPermitted — usually TCC / Input
            // Monitoring not yet granted.
            let hex = String(format: "0x%08X", UInt32(bitPattern: rc))
            return "Cannot open USB key (IOReturn \(hex)). "
                + "Grant Input Monitoring in System Settings if prompted."
        }
        self.opened = true

        // If nothing matched, the manager stays open and connects the key
        // whenever it is plugged in; nil tells Dart "waiting".
        let devices = IOHIDManagerCopyDevices(mgr) as? Set<IOHIDDevice>
        if devices?.isEmpty ?? true {
            return nil
        }
        return "Connected: IOKit HID 413D:2107"
    }

    private func stop() {
        modifiers = 0
        guard let mgr = manager else { return }
        if opened {
            IOHIDManagerClose(mgr, IOOptionBits(kIOHIDOptionsTypeNone))
        }
        IOHIDManagerUnscheduleFromRunLoop(mgr, CFRunLoopGetMain(),
                                          CFRunLoopMode.defaultMode.rawValue)
        manager = nil
        opened = false
    }

    // MARK: - HID callback

    private func onInputValue(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        // Keyboard/Keypad usage page.
        guard IOHIDElementGetUsagePage(element) == 0x07 else { return }
        let usage = IOHIDElementGetUsage(element)
        let mask: UInt8
        switch usage {
        case 0xE0: mask = 0x01 // Left-Ctrl
        case 0xE4: mask = 0x10 // Right-Ctrl
        default: return
        }
        let pressed = IOHIDValueGetIntegerValue(value) != 0
        var next = modifiers
        if pressed { next |= mask } else { next &= ~mask }
        if next == modifiers { return }
        modifiers = next
        // Ship 1 byte so the Dart decoder is the same as for Linux's byte 0.
        let bytes = Data([modifiers])
        eventSink?(FlutterStandardTypedData(bytes: bytes))
    }

    // MARK: - Helpers

    private func matchingDict() -> [String: Any] {
        return [
            kIOHIDVendorIDKey as String: HidPaddle.vendorId,
            kIOHIDProductIDKey as String: HidPaddle.productId,
        ]
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
