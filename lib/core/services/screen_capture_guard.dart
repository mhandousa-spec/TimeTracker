/// Module: core/services
///
///*************************** FILE INFO ****************************///
/// File Name: screen_capture_guard.dart
/// Purpose: The platform side of the Take Screen Shot and Screen Share
///          settings — asks each OS to keep this app out of screenshots and
///          out of any other app's screen share, and reports back when a
///          capture is detected on the platforms that can tell us.
/// Author: Knowticed Plus team
/// Created at: 26/8/2026
/// Updated: 26/8/2026 - Screen Share wired in alongside Take Screen Shot.
///
/// Until recently `DevicePolicyController` stored these toggles and nothing
/// acted on them (its own header said so). This is the missing half: one
/// MethodChannel, `knowticed_plus/screen_capture`, handled inside each runner
/// — no new pub dependency, no plugin registration, nothing to add to the
/// Xcode project.
///
/// ─────────────────────────────────────────────────────────────────────────
/// ONE OS LEVER, TWO SWITCHES — read this before changing the behaviour.
/// ─────────────────────────────────────────────────────────────────────────
/// Screen Share here means: can Zoom / Teams / Meet / QuickTime / OBS — any
/// other app on the machine — show THIS app's window to the people in the
/// meeting. It is NOT about a share feature inside Knowticed Plus.
///
/// Every OS exposes exactly ONE control for that, and it is the same control
/// that blocks screenshots. FLAG_SECURE, SetWindowDisplayAffinity,
/// NSWindow.sharingType and the iOS secure layer each cover screenshots AND
/// recording AND meeting shares together; no platform lets you block one and
/// keep the other. So the policy is deliberately combined:
///
///     protection ON  ⟺  Take Screen Shot is OFF  OR  Screen Share is OFF
///
/// Turning Screen Share off therefore also stops screenshots, and vice
/// versa. That coupling is the OS's, not ours — do not "fix" it by picking a
/// second mechanism.
///
/// ─────────────────────────────────────────────────────────────────────────
/// WHAT EACH PLATFORM ACTUALLY DOES — they are not equivalent, and the UI
/// should not promise more than the OS delivers.
/// ─────────────────────────────────────────────────────────────────────────
/// - Android: `FLAG_SECURE`. A real block. Screenshots fail outright, and
///   screen recording, casting and MediaProjection-based meeting shares all
///   capture black. The app is also hidden from the recents preview.
/// - Windows: `SetWindowDisplayAffinity(WDA_EXCLUDEFROMCAPTURE)`, Windows 10
///   2004+. The window is excluded from every capture path — a Teams or Zoom
///   share of the desktop shows what is behind the window, while the window
///   stays fully visible on the physical screen. Older builds fall back to
///   `WDA_MONITOR`: the share sees a black rectangle instead.
/// - macOS: `NSWindow.sharingType = .none`. This is the screen-share lever in
///   the literal sense — the window server refuses to hand the window to any
///   other process, so screen sharing, screen recording and ScreenCaptureKit
///   grabs come back without it. Weaker against the system screenshot key: a
///   full-screen Cmd+Shift+3 is not guaranteed to be redacted on every macOS
///   version. macOS also gives no screenshot notification, so no detection.
/// - iOS: Apple ships NO supported way to prevent a screenshot. The window's
///   layer is hosted inside a secure `UITextField`, which blanks screenshots,
///   screen recordings and AirPlay mirroring alike — the trick banking apps
///   use. It is undocumented, so the AppDelegate ALSO reports
///   `userDidTakeScreenshot` and `UIScreen.isCaptured` back here
///   ([screenshotCount], [isBeingCaptured]). On iOS a meeting share IS screen
///   recording, so [isBeingCaptured] is the signal that one is running.
/// - Web / Linux: nothing to call. [apply] is a no-op and [isEnforceable]
///   reports false.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ScreenCaptureGuard {
  ScreenCaptureGuard._();

  /// The one instance. Deliberately not a GetxController: the enforcement has
  /// to be reachable from `main()` before any controller is registered.
  static final ScreenCaptureGuard instance = ScreenCaptureGuard._();

  static const MethodChannel _channel =
      MethodChannel('knowticed_plus/screen_capture');

  /// True while the OS reports the screen is being recorded, mirrored or
  /// shared into a meeting. iOS only — no other platform exposes an
  /// equivalent signal. Watch it to cover sensitive content or warn the
  /// employee; on iOS this is what a Zoom/Teams share looks like.
  final ValueNotifier<bool> isBeingCaptured = ValueNotifier<bool>(false);

  /// Increments every time iOS reports the user took a screenshot. Bind a
  /// listener to log it, warn the employee, or raise a system-log entry.
  final ValueNotifier<int> screenshotCount = ValueNotifier<int>(0);

  /// The last policy applied, re-asserted when the app resumes.
  bool _allowScreenshot = true;
  bool _allowScreenShare = true;
  bool _wired = false;
  AppLifecycleListener? _lifecycleListener;

  /// Whether the last [apply] actually put the block in place.
  bool get isProtected => _protected;
  bool _protected = false;

  /// Function Name: [isEnforceable]
  ///
  /// Purpose: Whether the current platform has anything to enforce with, so
  ///          the caller can word the UI honestly instead of claiming a block
  ///          that never happens.
  ///
  /// Returns: [bool] true on Android, iOS, macOS and Windows.
  bool get isEnforceable {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
        return false;
    }
  }

  /// Function Name: [apply]
  ///
  /// Purpose: Push both switches down to the OS. Protection goes on when
  ///          either one is off — see the "one OS lever" note in the header.
  ///
  /// Parameters:
  /// - [allowScreenshot]: the Take Screen Shot switch.
  /// - [allowScreenShare]: the Screen Share switch. `false` keeps this app's
  ///   window out of any other app's screen share, meeting or recording.
  ///
  /// Returns: [Future<bool>] whether protection is in effect afterwards. A
  ///          `false` return when something was meant to be blocked means the
  ///          platform could not honour it (old Windows build, unsupported
  ///          OS, a runner that predates this change) — worth surfacing
  ///          rather than leaving the employee believing they are covered.
  Future<bool> apply({
    required bool allowScreenshot,
    required bool allowScreenShare,
  }) async {
    _allowScreenshot = allowScreenshot;
    _allowScreenShare = allowScreenShare;

    if (!isEnforceable) {
      _protected = false;
      return false;
    }

    _wireCallbacks();

    // The single value every runner acts on. Blocking is requested as soon as
    // either switch is off, because no OS can separate the two.
    final bool allowed = allowScreenshot && allowScreenShare;

    try {
      final bool? blocked = await _channel.invokeMethod<bool>(
        'setAllowed',
        <String, dynamic>{
          'allowed': allowed,
          // Sent for the runners' benefit — none of them differentiates
          // today, but a platform that ever gains two separate levers can
          // read these without another channel change.
          'allowScreenshot': allowScreenshot,
          'allowScreenShare': allowScreenShare,
        },
      );
      _protected = blocked ?? false;
      return _protected;
    } on PlatformException catch (error) {
      // A runner that has not been updated yet answers with an error. Do not
      // crash the settings screen over it — report "not protected" instead.
      debugPrint('ScreenCaptureGuard.apply failed: ${error.message}');
      _protected = false;
      return false;
    } on MissingPluginException {
      debugPrint(
        'ScreenCaptureGuard: no native handler on this platform build.',
      );
      _protected = false;
      return false;
    }
  }

  /// Function Name: [reapply]
  ///
  /// Purpose: Re-send the last policy. Called on resume — Android keeps
  ///          FLAG_SECURE across a pause, but a recreated activity or a
  ///          restored macOS window starts unprotected.
  Future<bool> reapply() => apply(
        allowScreenshot: _allowScreenshot,
        allowScreenShare: _allowScreenShare,
      );

  /// Function Name: [_wireCallbacks]
  ///
  /// Purpose: Attach the native -> Dart handler and the resume hook once.
  void _wireCallbacks() {
    if (_wired) return;
    _wired = true;

    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onScreenshotTaken':
          screenshotCount.value = screenshotCount.value + 1;
          break;
        case 'onCaptureStateChanged':
          final Object? captured = call.arguments is Map
              ? (call.arguments as Map)['captured']
              : call.arguments;
          isBeingCaptured.value = captured == true;
          break;
      }
      return null;
    });

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        if (!_allowScreenshot || !_allowScreenShare) reapply();
      },
    );
  }

  /// Function Name: [dispose]
  ///
  /// Purpose: Release the lifecycle hook. Only useful in tests — the app
  ///          keeps this alive for its whole run.
  void dispose() {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _wired = false;
  }
}
