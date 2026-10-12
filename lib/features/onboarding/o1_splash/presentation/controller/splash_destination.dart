/// Module: onboarding/o1_splash
///
///*************************** FILE INFO ****************************///
/// File Name: splash_destination.dart
/// Purpose: Where the splash screen sends the user once its animation ends.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Added for CR-SKEL-O1-N03. The decision was an `if/else` inside an animation
/// status listener that read persistence directly and pushed a
/// `MaterialPageRoute` — routing policy embedded in a widget.

enum SplashDestination {
  /// Biometric sign-in is enabled and credentials exist, so
  /// `LoginController.signWithBiometrics()` — already started in its
  /// `onInit()` — will navigate. The splash screen must do nothing, or it
  /// races the biometric flow and replaces the route out from under it.
  waitForBiometrics,

  /// The intro carousel has been completed before.
  signIn,

  /// First run.
  intro,
}
