import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // Retained for the lifetime of the window; the HID manager registers native
  // callbacks that need a live owner.
  private var hidPaddle: HidPaddle?
  private var toneEngine: ToneEngine?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let hid = HidPaddle()
    hid.register(with: flutterViewController.engine.binaryMessenger)
    self.hidPaddle = hid

    let tone = ToneEngine()
    tone.register(with: flutterViewController.engine.binaryMessenger)
    self.toneEngine = tone

    super.awakeFromNib()
  }
}
