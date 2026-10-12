/// Module: core/services/twilio
///
///*************************** FILE INFO ****************************///
/// File Name: twilio_constants.dart
/// Purpose: Build-time Twilio configuration.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Hardcoded credentials removed.
///
/// SECURITY
/// --------
/// This file previously committed a live Twilio Account SID, Auth Token and
/// Verify Service SID as plain string literals. They are now read from the
/// build environment.
///
/// Those credentials are in this repository's git history, so removing them
/// here does NOT make them safe. They must be rotated in the Twilio console
/// and the history purged.
///
/// Longer term the auth token should not reach the client at all — anyone can
/// extract it from a shipped binary. Move OTP sending behind a Cloud Function
/// and have the app call that instead.
///
/// Supply values at build time:
///   flutter run \
///     --dart-define=TWILIO_ACCOUNT_SID=... \
///     --dart-define=TWILIO_AUTH_TOKEN=... \
///     --dart-define=TWILIO_VERIFY_SERVICE_SID=...
class TwilioConstants {
  const TwilioConstants._();

  static const String twilioAccountSid =
      String.fromEnvironment('TWILIO_ACCOUNT_SID');
  static const String twilioAuthToken =
      String.fromEnvironment('TWILIO_AUTH_TOKEN');
  static const String twilioVerifyServiceSid =
      String.fromEnvironment('TWILIO_VERIFY_SERVICE_SID');

  /// `true` when every value was supplied at build time.
  static bool get isConfigured =>
      twilioAccountSid.isNotEmpty &&
      twilioAuthToken.isNotEmpty &&
      twilioVerifyServiceSid.isNotEmpty;

  /// Function Name: [assertConfigured]
  ///
  /// Purpose: Fail loudly when the Twilio dart-defines are missing, rather
  ///          than firing a request with empty credentials and reporting a
  ///          confusing 401 to the user.
  ///
  /// Throws: [StateError] when any value is unset.
  static void assertConfigured() {
    if (isConfigured) return;
    throw StateError(
      'Twilio is not configured. Pass --dart-define=TWILIO_ACCOUNT_SID, '
      'TWILIO_AUTH_TOKEN and TWILIO_VERIFY_SERVICE_SID at build time.',
    );
  }
}
