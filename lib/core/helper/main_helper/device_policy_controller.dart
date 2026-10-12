/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: device_policy_controller.dart
/// Purpose: Declares `DevicePolicyController` — the on/off state behind the
///          Take Screen Shot, Restricted Location and Screen Share settings.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
/// Updated: 26/8/2026 - Take Screen Shot and Screen Share are no longer
///          state-only. Both now feed [ScreenCaptureGuard], which applies
///          FLAG_SECURE (Android), WDA_EXCLUDEFROMCAPTURE (Windows), the
///          secure-layer trick (iOS) and NSWindow.sharingType = .none
///          (macOS).
///
/// These three sit in `SettingsPermissions` alongside Branding, Company
/// Information, Animation and Biometrics, but unlike those they are not a
/// "hide this menu entry" flag — they describe a device behaviour. The role
/// permission decides whether the employee is ALLOWED to see and change the
/// setting; this controller holds what they chose.
///
/// Storage mirrors [BiometricController]: a GetStorage-backed RxBool per
/// toggle, defaulting to on when nothing has been written yet.
///
/// WHAT SCREEN SHARE MEANS HERE: whether another app on the device — Zoom,
/// Teams, Meet, QuickTime, OBS — may show this app's window to a meeting.
/// It is not a share feature inside Knowticed Plus.
///
/// THE TWO CAPTURE SWITCHES SHARE ONE OS LEVER. Every platform blocks
/// screenshots, screen recording and meeting shares with the same call, so
/// [ScreenCaptureGuard] blocks as soon as EITHER switch is off — turning
/// Screen Share off also stops screenshots, and vice versa. See the header of
/// screen_capture_guard.dart before trying to separate them.
///
/// RESTRICTED LOCATION stores its allow-list here ([allowedCountryCodes],
/// picked in `RestrictedLocationCountries` under the switch) but is STILL NOT
/// ENFORCED: nothing yet reads the list and refuses to open the app outside
/// it. That geofence check has to be written against this flag the same way
/// [applyScreenCapturePolicy] was for the other two.
library;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/core/services/screen_capture_guard.dart';

class DevicePolicyController extends GetxController {
  final GetStorage _storage = GetStorage();

  /// Storage keys match the Firestore permission names so the two are easy to
  /// line up when reading a device's state next to its role.
  static const String screenShotKey = 'Take_Screen_Shot';
  static const String restrictedLocationKey = 'Restricted_Location';
  static const String screenShareKey = 'Screen_Share';

  /// The Restricted Location allow-list. ISO country codes, not names —
  /// names are localised, so a stored name stops matching the moment the
  /// employee switches language.
  static const String restrictedCountriesKey = 'Restricted_Location_Countries';

  late final RxBool isScreenShotEnabled = _read(screenShotKey).obs;
  late final RxBool isRestrictedLocationEnabled =
      _read(restrictedLocationKey).obs;
  late final RxBool isScreenShareEnabled = _read(screenShareKey).obs;

  /// Whether the OS confirmed the capture block is in effect. False while both
  /// capture switches are on, and also false when one is off but the platform
  /// could not honour it (web, Linux, a runner that predates this change).
  /// Read it before telling an employee they are protected.
  final RxBool isScreenCaptureBlocked = false.obs;

  /// True while the OS reports the screen is being recorded, mirrored or
  /// shared into a meeting. iOS only — every other platform blocks silently
  /// and has no equivalent signal. Observe it to cover sensitive content or
  /// warn the employee while a share is running.
  final RxBool isBeingCaptured = false.obs;

  /// Countries the app is allowed to be opened from while Restricted Location
  /// is on. Empty means nothing has been chosen yet.
  late final RxList<String> allowedCountryCodes =
      RxList<String>(_readCountryCodes());

  @override
  void onInit() {
    super.onInit();
    // Keep the Rx mirror in step with the platform notifier so widgets can
    // observe it the same way they observe the toggles.
    ScreenCaptureGuard.instance.isBeingCaptured.addListener(_onCaptureChanged);
    applyScreenCapturePolicy();
  }

  @override
  void onClose() {
    ScreenCaptureGuard.instance.isBeingCaptured
        .removeListener(_onCaptureChanged);
    super.onClose();
  }

  void _onCaptureChanged() {
    isBeingCaptured.value = ScreenCaptureGuard.instance.isBeingCaptured.value;
  }

  /// Function Name: [_read]
  ///
  /// Purpose: Read a stored toggle, treating "never written" as on — the same
  ///          default [BiometricController] uses.
  ///
  /// Parameters:
  /// - [key]: One of the storage keys above.
  ///
  /// Returns: [bool] the stored value, or true when absent.
  bool _read(String key) {
    final Object? stored = _storage.read(key);
    if (stored == null) return true;
    return stored == true;
  }

  /// Function Name: [_readCountryCodes]
  ///
  /// Purpose: Read the stored allow-list, tolerating both a missing value and
  ///          the untyped List GetStorage hands back after a restart.
  ///
  /// Returns: [List<String>] the stored codes, or empty.
  List<String> _readCountryCodes() {
    final Object? stored = _storage.read(restrictedCountriesKey);
    if (stored is List) {
      return stored.map((Object? e) => e.toString()).toList();
    }
    return <String>[];
  }

  /// Function Name: [saveAllowedCountryCodes]
  ///
  /// Purpose: Persist the Restricted Location allow-list. Called from the
  ///          country picker's confirm dialog, never straight from a tick —
  ///          the employee gets to back out first.
  ///
  /// Parameters:
  /// - [codes]: ISO country codes the app may be opened from.
  Future<void> saveAllowedCountryCodes(List<String> codes) async {
    final List<String> cleaned = codes.toSet().toList();
    allowedCountryCodes.assignAll(cleaned);
    await _storage.write(restrictedCountriesKey, cleaned);
    update();
  }

  /// Function Name: [applyScreenCapturePolicy]
  ///
  /// Purpose: Push both capture switches down to the OS.
  ///
  /// Called from `main()` at boot as well as from [toggleScreenShot] and
  /// [toggleScreenShare], so a device that was left with either switch off is
  /// protected from the first frame rather than from the first time Settings
  /// is opened.
  ///
  /// Returns: [Future<bool>] whether the block is actually in effect.
  Future<bool> applyScreenCapturePolicy() async {
    final bool blocked = await ScreenCaptureGuard.instance.apply(
      allowScreenshot: isScreenShotEnabled.value,
      allowScreenShare: isScreenShareEnabled.value,
    );
    isScreenCaptureBlocked.value = blocked;
    return blocked;
  }

  /// Function Name: [toggleScreenShot]
  ///
  /// Purpose: Persist the Take Screen Shot choice and apply it to the OS.
  ///
  /// Parameters:
  /// - [value]: The new state. `false` blocks screenshots — and, because the
  ///   OS offers one lever for both, screen recording and meeting shares too.
  void toggleScreenShot(bool value) {
    _set(isScreenShotEnabled, screenShotKey, value);
    applyScreenCapturePolicy();
  }

  /// Function Name: [toggleScreenShare]
  ///
  /// Purpose: Persist the Screen Share choice and apply it to the OS.
  ///
  /// Parameters:
  /// - [value]: The new state. `false` keeps this app's window out of any
  ///   other app's screen share, meeting or recording — Zoom, Teams, Meet,
  ///   QuickTime, OBS. The window stays fully visible on the employee's own
  ///   screen; only the capture is denied.
  void toggleScreenShare(bool value) {
    _set(isScreenShareEnabled, screenShareKey, value);
    applyScreenCapturePolicy();
  }

  /// Function Name: [toggleRestrictedLocation]
  ///
  /// Purpose: Persist the Restricted Location choice.
  ///
  /// Parameters:
  /// - [value]: The new state.
  void toggleRestrictedLocation(bool value) =>
      _set(isRestrictedLocationEnabled, restrictedLocationKey, value);

  void _set(RxBool flag, String key, bool value) {
    flag.value = value;
    _storage.write(key, value);
    update();
  }
}
