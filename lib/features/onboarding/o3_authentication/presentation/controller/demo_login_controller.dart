/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_login_controller.dart
/// Purpose: Drives the demo-tenant login flow.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N10: added the standard header; the repository is still constructed
///          inline here.

/// ************************* FILE INFO ************************* ///
/// File Name: demo_login_controller.dart
/// Purpose: Contains the controller for demo login feature.
/// Author: Amr Mesbah
/// Created At: 4/1/2025
/// Updated: 23/12/2025 - Added comprehensive notification system
/// ✅ UPDATED: Added moduleUserLimitReached handler
/// ✅ FIXED: Removed duplicate success handling - login_controller handles navigation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';


import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/custom/64-custom_response_dialog.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/notification/data/repository/account_status_notification_service.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/repository/demo_login_repository.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/login_attempt_store.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/failure_authentication_type.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
// ADDED 26/8/2026 — raising the unlock request. See
// [handleLockedAccountSignIn].
import 'package:knowticed_plus/features/roles/r3_user_access/data/repository/user_access_repository.dart';
class DemoLoginController {
  final DemoLoginRepository demoLoginRepository = DemoLoginRepository();
  SystemLogsController systemLogsController = Get.find<SystemLogsController>();

  /// Used for one thing only: turning a repeat sign-in attempt on an already
  /// locked account into an unlock request the administrators can see.
  final UserAccessRepository _userAccessRepository = UserAccessRepository();

  /// Function Name: [loginWithEmailAndPassword]
  ///
  /// Purpose: Attempt a sign-in and, on failure, show the matching dialog.
  ///
  /// Parameters:
  /// - [email] / [password]: the credentials to try.
  /// - [countsTowardLockout]: whether a wrong password on this call should
  ///   count against the lock threshold. `false` for the biometric auto-login
  ///   fired from `LoginController.onInit()`: that runs before the user has
  ///   typed anything, and a stale saved credential silently burning an attempt
  ///   is what made an account lock on the user's *second* visible try.
  ///
  /// Returns: the repository's `Either`, unmodified.
  loginWithEmailAndPassword({
    required String email,
    required String password,
    bool countsTowardLockout = true,
  }) async {
    Either<Failure, dynamic> result = await demoLoginRepository
        .loginWithEmailAndPassword(email: email, password: password);

    if (result.isLeft()) {
      String errorMessage = result.fold((l) => l.errMessage, (r) => "");
      await handleAuthenticationErrorMessage(
          errorMessage: errorMessage,
          email: email,
          countsTowardLockout: countsTowardLockout);
    } else {
      // A clean sign-in clears the failure history, so the next lock again
      // requires a full LoginAttemptStore.maxAttempts consecutive failures.
      LoginAttemptStore.reset(email);
    }
    return result;
  }

  // ✅ UPDATED: Added moduleUserLimitReached case
  handleAuthenticationErrorMessage({
    required String errorMessage,
    required String email,
    bool countsTowardLockout = true,
  }) async {
    hideLoadingIndicator();
    await Future.delayed(const Duration(milliseconds: 300));

    FailureAuthenticationType? failureType;

    try {
      failureType = FailureAuthenticationType.values
          .firstWhere((element) => element.dialogBoxMessage == errorMessage);
    } catch (e) {
      // DIAGNOSTIC 7/9/2026. Reaching this `catch` means `firstWhere` matched
      // no `FailureAuthenticationType`: `errorMessage` is not one of the app's
      // own login failures but a raw exception string forwarded from a
      // `catch (e) => Left(FirebaseFailure(e.toString()))` in the data layer —
      // which is exactly how "[cloud_firestore/permission-denied] The caller
      // does not have permission…" ends up under the "Authentication Error"
      // title. The `[firestore]` line logged at the failing read names the
      // path; this line marks where it turned into a dialog.
      if (kDebugMode) {
        debugPrint(
          '[login] UNMAPPED failure for "$email" — no FailureAuthenticationType '
          'matches this message, so it is shown verbatim as "Authentication '
          'Error". Raw message: $errorMessage',
        );
      }
      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: S.of(context).authenticationError,
              subtitle: errorMessage.isNotEmpty
                  ? errorMessage
                  : S.of(context).anErrorOccurredDuringLoginPleaseTryAgain,
              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
            );
          });
      return;
    }

    switch (failureType) {
      case FailureAuthenticationType.emailNotFound:
        await handleEmailNotFound();
        break;
      case FailureAuthenticationType.wrongPassword:
        await handleFailureWrongPassword(email,
            countsTowardLockout: countsTowardLockout);
        break;
      case FailureAuthenticationType.wrongActivationPassword:
        await handleWrongActivationPassword();
        break;
      case FailureAuthenticationType.notFoundInCompanyDatabase:
        await handleNotFoundInCompanyDatabase();
        break;
      case FailureAuthenticationType.demoCancelled:
        await handleDemoCancelled();
        break;
      case FailureAuthenticationType.beforActivationDate:
        await handleBeforeActivationDate();
        break;
      case FailureAuthenticationType.subscriptionExpired:
        await handleSubscriptionExpired();
        break;
      case FailureAuthenticationType.dontHavePermission:
        await handleNoPermission();
        break;
      case FailureAuthenticationType.tooManyUsers:
        await handleTooManyUsers();
        break;
      case FailureAuthenticationType.moduleUserLimitReached: // ✅ NEW
        await handleModuleUserLimitReached();
        break;
      default:
        await handleDefaultFailure(errorMessage);
    }
  }

  handleEmailNotFound() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.emailNotFound.dialogBoxTitle,
            subtitle: FailureAuthenticationType.emailNotFound.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  /// Function Name: [handleFailureWrongPassword]
  ///
  /// Purpose: Show the "Incorrect Password" dialog, or lock the account once
  /// the user has burned [LoginAttemptStore.maxAttempts] consecutive tries.
  ///
  /// FIXED 22/8/2026: the count lived in a per-instance `wrongPasswordCount`
  /// field that was shared across every email and was also incremented by the
  /// silent biometric auto-login. See login_attempt_store.dart for the full
  /// account of why that locked users out early. The counter is now stored per
  /// email, only user-initiated attempts increment it, and the threshold is a
  /// named constant instead of a bare `3`.
  ///
  /// Parameters:
  /// - [email]: whose failure this is.
  /// - [countsTowardLockout]: `false` for background/biometric attempts, which
  ///   report the error but must not push the account toward a lock.
  handleFailureWrongPassword(String email,
      {bool countsTowardLockout = true}) async {
    final int attempts = countsTowardLockout
        ? LoginAttemptStore.registerFailure(email)
        : LoginAttemptStore.attemptsFor(email);

    if (countsTowardLockout && LoginAttemptStore.shouldLock(attempts)) {
      await lockAccount(email: email);
      return;
    }

    final int remaining = LoginAttemptStore.maxAttempts - attempts;

    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.wrongPassword.dialogBoxTitle,
            subtitle: remaining > 0
                ? '${FailureAuthenticationType.wrongPassword.dialogBoxMessage}\n\n'
                    '${_attemptsRemainingMessage(remaining)}'
                : "${FailureAuthenticationType.wrongPassword.dialogBoxMessage}\n\n",
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  /// Bilingual "you have N attempts left before this account is locked" line.
  ///
  /// Built here rather than through `S.of(context)` because the surrounding
  /// failure copy in [FailureAuthenticationType] is still literal EN/AR (see
  /// the REMAINING note at the top of that file); moving one of the two halves
  /// to the .arb bundle on its own would leave the dialog half-translated.
  String _attemptsRemainingMessage(int remaining) {
    final bool isArabic =
        Intl.getCurrentLocale().toLowerCase().startsWith('ar');
    if (isArabic) {
      return 'لديك $remaining محاولة متبقية قبل قفل الحساب.';
    }
    return remaining == 1
        ? 'You have 1 attempt remaining before this account is locked.'
        : 'You have $remaining attempts remaining before this account is locked.';
  }

  handleWrongActivationPassword() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.wrongActivationPassword.dialogBoxTitle,
            subtitle: FailureAuthenticationType.wrongActivationPassword.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleNotFoundInCompanyDatabase() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxTitle,
            subtitle: FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleDemoCancelled() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.demoCancelled.dialogBoxTitle,
            subtitle: FailureAuthenticationType.demoCancelled.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleBeforeActivationDate() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.beforActivationDate.dialogBoxTitle,
            subtitle: FailureAuthenticationType.beforActivationDate.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/newAttension.json",
          );
        });
  }

  handleSubscriptionExpired() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.subscriptionExpired.dialogBoxTitle,
            subtitle: FailureAuthenticationType.subscriptionExpired.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleNoPermission() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.dontHavePermission.dialogBoxTitle,
            subtitle: FailureAuthenticationType.dontHavePermission.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleTooManyUsers() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.tooManyUsers.dialogBoxTitle,
            subtitle: FailureAuthenticationType.tooManyUsers.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/newAttension.json",
          );
        });
  }

  // ✅ NEW: Handle module user limit reached error dialog
  handleModuleUserLimitReached() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.moduleUserLimitReached.dialogBoxTitle,
            subtitle: FailureAuthenticationType.moduleUserLimitReached.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/newAttension.json",
          );
        });
  }

  handleDefaultFailure(String errorMessage) async {
    try {
      FailureAuthenticationType failureType = FailureAuthenticationType.values
          .firstWhere((element) => element.dialogBoxMessage == errorMessage);

      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: failureType.dialogBoxTitle,
              subtitle: failureType.dialogBoxMessage,
              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
            );
          });
    } catch (e) {
      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: S.of(context).authenticationFailed,
              subtitle: errorMessage.isNotEmpty
                  ? errorMessage
                  : S.of(context).invalidCredentialsPleaseVerifyAndTryAgain,
              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
            );
          });
    }
  }

  /// Function Name: [handleLockedAccountSignIn]
  ///
  /// Purpose: What happens when someone tries to sign in to an account that is
  /// already locked — raise the unlock request, then say so.
  ///
  /// ADDED 26/8/2026. Two things were missing and they turned out to be the
  /// same gap seen from two ends:
  ///
  ///  1. `AccountStatusNotificationService.sendUnlockRequestNotification` and
  ///     its event `accountUnlockRequestedAdmin` had no caller anywhere in
  ///     `lib/`, and neither did the status a request produces —
  ///     `EmployeeStatusEnum.lockedWithRequest` was read in three places and
  ///     written in none.
  ///  2. A locked user who typed the RIGHT password reached
  ///     `LoginController`'s catch-all `else`, which dismissed the spinner and
  ///     said nothing at all. They were told neither that they were locked nor
  ///     what to do about it.
  ///
  /// The trigger is the sign-in attempt itself. Someone who has been locked out
  /// and has come back to try again is asking to be let in; making them hunt
  /// for a "request unlock" button would add a step without adding information.
  ///
  /// Idempotent by construction: `requestAccountUnlock` refuses an account
  /// already sitting in `lockedWithRequest`, so repeated attempts raise one
  /// request, not one per press.
  ///
  /// Awaited before the dialog on purpose. The dialog tells the user to contact
  /// an administrator; by the time they read that sentence, the administrators
  /// have been told.
  ///
  /// Parameters:
  /// - [employee]: the locked account, as read by the caller.
  ///
  /// Returns: [Future<void>]
  Future<void> handleLockedAccountSignIn({
    required NewEmployeeModelHistory employee,
  }) async {
    await _userAccessRepository.requestAccountUnlock(
      employeeModel: employee,
      userName: _getEmployeeFullName(employee),
    );

    if (Get.context == null) return;

    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: S.of(context).accountLocked,
            subtitle: S.of(context).accountLockedMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  lockAccount({required String email}) async {
    // The account is now locked, so the running failure count has done its job.
    // Clearing it here means that after an admin unlocks the account the user
    // again gets the full LoginAttemptStore.maxAttempts before re-locking,
    // rather than being one mistake away from another lock.
    LoginAttemptStore.reset(email);

    Either<Failure, dynamic> result =
    await demoLoginRepository.getEmployee(email: email);

    if (result.isRight()) {
      List<Map<String, dynamic>> employeeData = result.getOrElse(() => []);
      NewEmployeeModelHistory employee =
      NewEmployeeModelHistory.fromMap(employeeData.first);

      String currentStatus = employee.status.isNotEmpty
          ? employee.status.last
          : '';

      if (currentStatus == EmployeeStatusEnum.locked.name) {
        // The account was ALREADY locked before this attempt. Nothing to lock;
        // what this is, is a locked-out user coming back and trying again.
        // [handleLockedAccountSignIn] treats that as the unlock request it is.
        await handleLockedAccountSignIn(employee: employee);
        hideLoadingIndicator();
      } else {
        employee = employee.copyWithUpdateSynchronized(
          status: 'locked',
          addTimestamp: DateTime.now().millisecondsSinceEpoch,
        );

        EmployeeController employeeController = Get.find<EmployeeController>();
        await employeeController.createEmployee(employee, email);
        systemLogsController.systemLogsAction("update employee");

        String userName = _getEmployeeFullName(employee);
        await AccountStatusNotificationService.sendAccountLockedNotification(
          userEmail: email,
          userName: userName,
        );

        await showDialog(
            context: Get.context!,
            barrierDismissible: true,
            builder: (context) {
              return ResponseDialog(
                title: S.of(context).accountLocked,
                subtitle: S.of(context).accountLockedMessage,
                lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
              );
            });

        hideLoadingIndicator();
      }
    }
  }

  String _getEmployeeFullName(NewEmployeeModelHistory employee) {
    List<String> nameParts = [];

    if (employee.firstName.isNotEmpty && employee.firstName.last.isNotEmpty) {
      nameParts.add(employee.firstName.last);
    }

    if (employee.middleName.isNotEmpty && employee.middleName.last.isNotEmpty) {
      nameParts.add(employee.middleName.last);
    }

    if (employee.lastName.isNotEmpty && employee.lastName.last.isNotEmpty) {
      nameParts.add(employee.lastName.last);
    }

    if (nameParts.isEmpty) {
      return 'Unknown User';
    }

    return nameParts.join(' ');
  }
}