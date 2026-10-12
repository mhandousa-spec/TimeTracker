/// Module: core/constants
///
///*************************** FILE INFO ****************************///
/// File Name: app_keys.dart
/// Purpose: Build-time credentials. No secret literal belongs in source.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// SECURITY
/// --------
/// Three separate Firebase **Admin** service-account private keys were
/// committed in client code:
///
///   * notification/data/data_source/notification_page_config.dart
///   * notification/presentation/controller/notification_cubit.dart  (deleted — dead file)
///   * notification/services/firebase_notification_handler.dart
///
/// They are in this repository's git history, so removing them from the
/// working tree does NOT make them safe. All three must be revoked in
/// GCP IAM and the history purged.
///
/// Beyond rotation: an Admin service-account key grants server-level access to
/// the whole Firebase project, and anything shipped in an app binary can be
/// extracted. FCM sending should move behind a Cloud Function so the client
/// holds no admin credential at all. The dart-define below is a stop-gap that
/// keeps the existing code path working without a literal in source.
///
/// Supply at build time:
///   flutter run \
///     --dart-define=FCM_PROJECT_ID=... \
///     --dart-define=FCM_PRIVATE_KEY_ID=... \
///     --dart-define=FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n" \
///     --dart-define=FCM_CLIENT_EMAIL=... \
///     --dart-define=FCM_CLIENT_ID=...
abstract final class AppKeys {
  const AppKeys._();

  static const String fcmProjectId = String.fromEnvironment('FCM_PROJECT_ID');
  static const String fcmPrivateKeyId =
      String.fromEnvironment('FCM_PRIVATE_KEY_ID');
  static const String fcmPrivateKey = String.fromEnvironment('FCM_PRIVATE_KEY');
  static const String fcmClientEmail =
      String.fromEnvironment('FCM_CLIENT_EMAIL');
  static const String fcmClientId = String.fromEnvironment('FCM_CLIENT_ID');

  /// `true` when every FCM service-account value was supplied at build time.
  static bool get isFcmConfigured =>
      fcmProjectId.isNotEmpty &&
      fcmPrivateKeyId.isNotEmpty &&
      fcmPrivateKey.isNotEmpty &&
      fcmClientEmail.isNotEmpty &&
      fcmClientId.isNotEmpty;

  /// Function Name: [fcmServiceAccountJson]
  ///
  /// Purpose: Build the service-account map `googleapis_auth` expects.
  ///
  /// Returns: [Map<String, String>] the service-account credentials.
  ///
  /// Throws: [StateError] when the FCM dart-defines are missing, so a
  ///         misconfigured build fails loudly instead of silently failing to
  ///         send every notification.
  static Map<String, String> fcmServiceAccountJson() {
    if (!isFcmConfigured) {
      throw StateError(
        'FCM service account is not configured. Pass --dart-define='
        'FCM_PROJECT_ID, FCM_PRIVATE_KEY_ID, FCM_PRIVATE_KEY, '
        'FCM_CLIENT_EMAIL and FCM_CLIENT_ID at build time.',
      );
    }
    return <String, String>{
      'type': 'service_account',
      'project_id': fcmProjectId,
      'private_key_id': fcmPrivateKeyId,
      // dart-define cannot carry real newlines; accept the escaped form.
      'private_key': fcmPrivateKey.replaceAll(r'\n', '\n'),
      'client_email': fcmClientEmail,
      'client_id': fcmClientId,
      'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
      'token_uri': 'https://oauth2.googleapis.com/token',
      'auth_provider_x509_cert_url':
          'https://www.googleapis.com/oauth2/v1/certs',
      'client_x509_cert_url':
          'https://www.googleapis.com/robot/v1/metadata/x509/'
              '${Uri.encodeComponent(fcmClientEmail)}',
      'universe_domain': 'googleapis.com',
    };
  }

  /// Scopes required to send FCM messages.
  static const List<String> fcmScopes = <String>[
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/firebase.database',
    'https://www.googleapis.com/auth/firebase.messaging',
  ];
}
