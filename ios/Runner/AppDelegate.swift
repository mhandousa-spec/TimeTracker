import Flutter
import UIKit

/// File Name: AppDelegate.swift
/// Purpose: App entry point, plus the `screen_capture` channel behind the
///          Settings > Take Screen Shot switch.
/// Updated: 26/8/2026
///
/// iOS has NO supported API to prevent a screenshot. Two things are done here
/// and both are needed:
///
/// 1. BLOCK — the Flutter window's layer is re-parented into the private
///    canvas layer of a `UITextField` with `isSecureTextEntry` on. iOS redacts
///    that layer out of any captured image, so screenshots and recordings of
///    the app come out blank. This is the trick banking apps use. It is
///    undocumented; Apple could change it in any release, which is why...
/// 2. DETECT — `userDidTakeScreenshotNotification` and
///    `UIScreen.capturedDidChangeNotification` are forwarded to Dart, so the
///    app still knows a capture happened even if the block stops working.
///
/// Toggling is just `isSecureTextEntry`: the layer stays re-parented for the
/// whole run, and turning the flag off restores normal screenshots.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private static let screenCaptureChannelName = "knowticed_plus/screen_capture"

  private var screenCaptureChannel: FlutterMethodChannel?
  private let secureField = UITextField()
  private var secureLayerInstalled = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    observeCaptureNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // The channel is set up from a registrar rather than from the root view
    // controller: at this point in launch the controller may not be attached
    // to the window yet, but the messenger already exists.
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "KnowticedScreenCaptureGuard")
    {
      setUpScreenCaptureChannel(messenger: registrar.messenger())
    }
  }

  // MARK: - Channel

  private func setUpScreenCaptureChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: AppDelegate.screenCaptureChannelName, binaryMessenger: messenger)

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
          let blocked = self.applyScreenCapturePolicy(allowed: allowed)
          result(blocked)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    screenCaptureChannel = channel
  }

  // MARK: - Blocking

  /// Applies or lifts the secure layer.
  ///
  /// - Parameter allowed: true = screenshots permitted, false = blocked.
  /// - Returns: whether the block is in effect afterwards.
  @discardableResult
  private func applyScreenCapturePolicy(allowed: Bool) -> Bool {
    installSecureLayerIfNeeded()
    guard secureLayerInstalled else { return false }
    secureField.isSecureTextEntry = !allowed
    return !allowed
  }

  /// Re-parents the app window's layer into the secure text field's canvas
  /// layer. Done once; after that the redaction is toggled by the flag alone.
  private func installSecureLayerIfNeeded() {
    guard !secureLayerInstalled, let window = currentWindow() else { return }

    secureField.isSecureTextEntry = false
    secureField.isUserInteractionEnabled = false
    secureField.backgroundColor = .clear
    secureField.borderStyle = .none

    // The field must cover the whole window at (0,0). The window's layer is
    // placed inside the field's canvas layer, so wherever the field's origin
    // sits is where the app's top-left corner ends up. A zero-size field
    // centred in the window pushed the whole app into the bottom-right
    // quarter of the screen.
    window.addSubview(secureField)
    secureField.frame = window.bounds
    secureField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    secureField.layoutIfNeeded()

    // Hoist the field's layer above the window, then put the window's own
    // layer inside the field's redacted canvas sublayer.
    window.layer.superlayer?.addSublayer(secureField.layer)

    if #available(iOS 17.0, *) {
      secureField.layer.sublayers?.last?.addSublayer(window.layer)
    } else {
      secureField.layer.sublayers?.first?.addSublayer(window.layer)
    }

    secureLayerInstalled = true
  }

  /// With the UIScene lifecycle the window belongs to the scene, so
  /// `self.window` on the app delegate is nil. Look it up from the active
  /// window scene instead (falls back to `self.window` just in case).
  private func currentWindow() -> UIWindow? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    if let scene = scene {
      if let delegateWindow = (scene.delegate as? UIWindowSceneDelegate)?.window ?? nil {
        return delegateWindow
      }
      if let key = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
        return key
      }
    }
    return self.window
  }

  // MARK: - Detection

  private func observeCaptureNotifications() {
    let center = NotificationCenter.default

    center.addObserver(
      self,
      selector: #selector(handleScreenshotTaken),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil)

    center.addObserver(
      self,
      selector: #selector(handleCaptureStateChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil)
  }

  @objc private func handleScreenshotTaken() {
    screenCaptureChannel?.invokeMethod("onScreenshotTaken", arguments: nil)
  }

  @objc private func handleCaptureStateChanged() {
    let captured = UIScreen.main.isCaptured
    screenCaptureChannel?.invokeMethod(
      "onCaptureStateChanged", arguments: ["captured": captured])
  }
}
