import Cocoa
import FlutterMacOS

/// File Name: MainFlutterWindow.swift
/// Purpose: Hosts the Flutter view, and handles the `screen_capture` channel
///          behind the Settings > Take Screen Shot switch.
/// Updated: 26/8/2026
///
/// macOS lever: `NSWindow.sharingType = .none`. It tells the window server
/// this window may not be read by other processes, which covers screen
/// sharing, screen recorders, ScreenCaptureKit and window-targeted captures —
/// the window is left out or comes back blank.
///
/// HONEST LIMIT: unlike Android's FLAG_SECURE this is not absolute. macOS
/// exposes no "user took a screenshot" notification, and a full-screen system
/// grab (Cmd+Shift+3) is not guaranteed to be redacted on every macOS
/// version. Treat macOS as best effort and do not promise the employee more.
class MainFlutterWindow: NSWindow {

  private static let screenCaptureChannelName = "knowticed_plus/screen_capture"

  private var screenCaptureChannel: FlutterMethodChannel?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    setUpScreenCaptureChannel(messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }

  private func setUpScreenCaptureChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: MainFlutterWindow.screenCaptureChannelName,
      binaryMessenger: messenger)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(false)
        return
      }

      switch call.method {
      case "setAllowed":
        let arguments = call.arguments as? [String: Any]
        let allowed = arguments?["allowed"] as? Bool ?? true
        DispatchQueue.main.async {
          self.sharingType = allowed ? .readOnly : .none
          result(!allowed)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    screenCaptureChannel = channel
  }
}
