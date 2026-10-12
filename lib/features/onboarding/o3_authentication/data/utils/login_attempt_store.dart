/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: login_attempt_store.dart
/// Purpose: Counts consecutive failed sign-in attempts per email address and
///          decides when the account has earned a lock.
/// Author: Knowticed Plus team
/// Created at: 22/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The counter used to be a plain `int wrongPasswordCount` field on
/// `DemoLoginController`, which `LoginController` constructs as a field. That
/// had three problems, and together they are why an account could lock on the
/// user's second visible attempt instead of the third:
///
///  1. It was not keyed by email. Typing the wrong password once for user A and
///     once for user B left the shared counter at 2, so B's next mistake locked
///     B out on what was, for B, the first failure.
///  2. It counted *every* failed call to `login()`, including the silent
///     biometric auto-login that `LoginController.onInit()` fires on launch. A
///     stale saved credential burned an attempt before the user had typed
///     anything.
///  3. It lived only in memory, so `Get.put(LoginController())` — which
///     `SignInScreen` calls on every construction — reset it, making the
///     threshold non-deterministic in the other direction too.
///
/// The count is persisted so it survives a screen rebuild, and it is cleared on
/// every successful sign-in and whenever an admin unlocks the account.
library;

import 'package:knowticed_plus/core/helper/main_helper/biometric_controller.dart'
    show storage;

abstract class LoginAttemptStore {
  /// How many consecutive failed sign-in attempts an account gets before it is
  /// locked. The lock fires **on** this attempt: two wrong passwords show the
  /// "Incorrect Password" dialog, the third locks the account.
  static const int maxAttempts = 3;

  static const String _keyPrefix = 'failedLoginAttempts_';

  static String _keyFor(String email) =>
      '$_keyPrefix${email.trim().toLowerCase()}';

  /// Function Name: [attemptsFor]
  ///
  /// Purpose: The number of consecutive failures recorded for [email].
  ///
  /// Returns: [int] — 0 when nothing is stored.
  static int attemptsFor(String email) {
    final Object? stored = storage.read(_keyFor(email));
    if (stored is int) return stored;
    if (stored is String) return int.tryParse(stored) ?? 0;
    return 0;
  }

  /// Function Name: [registerFailure]
  ///
  /// Purpose: Record one failed attempt for [email] and report the new total.
  ///
  /// Returns: [int] the running count *after* this failure, so the caller can
  /// compare it against [maxAttempts] without a second read.
  static int registerFailure(String email) {
    final int next = attemptsFor(email) + 1;
    storage.write(_keyFor(email), next);
    return next;
  }

  /// Function Name: [shouldLock]
  ///
  /// Purpose: Whether [attempts] has reached the lock threshold.
  static bool shouldLock(int attempts) => attempts >= maxAttempts;

  /// Function Name: [reset]
  ///
  /// Purpose: Forget the failure history for [email].
  ///
  /// Called on a successful sign-in and when an administrator unlocks the
  /// account, so the next lock again takes a full [maxAttempts] failures.
  static void reset(String email) {
    storage.remove(_keyFor(email));
  }
}
