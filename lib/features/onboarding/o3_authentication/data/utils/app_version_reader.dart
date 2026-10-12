/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: app_version_reader.dart
/// Purpose: Read the running app's version and build number.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Added for CR-SKEL-O3-N20. `_getAppVersion` held a `try/catch` on
/// `sign_in_screen.dart` — forbidden in presentation/ui/ (§11.2, §21).
/// `PackageInfo.fromPlatform()` genuinely can throw (a missing platform
/// channel on a cold start), so the handling belongs in a data-layer read, not
/// in the page.

import 'package:package_info_plus/package_info_plus.dart';

/// What the sign-in footer shows.
class AppVersionInfo {
  const AppVersionInfo({required this.version, required this.buildNumber});

  /// Shown when the platform channel is unavailable. Was the same pair of
  /// literals inside the page's `catch`.
  static const AppVersionInfo fallback =
      AppVersionInfo(version: '1.0.0', buildNumber: '1');

  final String version;
  final String buildNumber;
}

abstract class AppVersionReader {
  /// Function Name: [read]
  ///
  /// Purpose: The running app's version, or [AppVersionInfo.fallback] when the
  ///          platform cannot supply it.
  static Future<AppVersionInfo> read() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return AppVersionInfo(
        version: info.version,
        buildNumber: info.buildNumber,
      );
    } catch (_) {
      return AppVersionInfo.fallback;
    }
  }
}
