/// Module: onboarding/o1_splash
///
///*************************** FILE INFO ****************************///
/// File Name: splash_controller.dart
/// Purpose: Decides where the splash screen navigates, and exposes the brand
///          logo to show while it waits.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Added for CR-SKEL-O1-N03 / N04. The widget used to read `storage` directly
/// six times, call `Get.find<LoginController>()`, and branch navigation from
/// inside an animation status listener. The reads are behind one injectable
/// seam here, so the page only asks "where next?".

import 'package:get_storage/get_storage.dart';

import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/features/onboarding/o1_splash/presentation/controller/splash_destination.dart';

class SplashController {
  SplashController({
    GetStorage? storage,
    required bool Function() isBiometricLoginEnabled,
  })  : _storage = storage ?? GetStorage(),
        _isBiometricLoginEnabled = isBiometricLoginEnabled;

  final GetStorage _storage;

  /// Supplied by the caller rather than resolved with `Get.find<LoginController>()`
  /// here, so this class does not depend on the auth feature.
  final bool Function() _isBiometricLoginEnabled;

  /// Function Name: [resolveDestination]
  ///
  /// Purpose: Decide where to go once the splash animation completes.
  SplashDestination resolveDestination() {
    final bool hasCredentials =
        _storage.read(AppConstants.emailStorageKey) != null;

    if (_isBiometricLoginEnabled() && hasCredentials) {
      return SplashDestination.waitForBiometrics;
    }

    final bool onboardingCompleted =
        _storage.read(AppConstants.onboardingStorageKey) ==
            AppConstants.onboardingCompletedValue;

    return onboardingCompleted
        ? SplashDestination.signIn
        : SplashDestination.intro;
  }

  /// Function Name: [companyLogoUrl]
  ///
  /// Purpose: The tenant's own logo, or `null` to fall back to the app mark.
  String? get companyLogoUrl {
    final Object? stored = _storage.read(AppConstants.logoStorageKey);
    final String? url = stored is String ? stored : null;
    return (url == null || url.isEmpty) ? null : url;
  }
}
