/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: success_authentication_type.dart
/// Purpose: Why an authentication attempt succeeded.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

enum SuccessAuthenticationType {
  login,
  inactive,
  locked,
  resetPassword,
  lockedWithRequest,
  deactivated
  ;
}