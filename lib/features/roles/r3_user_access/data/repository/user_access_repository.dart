/// Module: roles / r3_user_access / data / repository
///
///********************** FILE INFO **********************
/// File: user_access_repository.dart
/// Purpose: repository contains all function related to database for account status feature.
/// Author: Amr Mesbah
/// Date: 22/1/2025
/// Updated: 23/12/2025 - Added comprehensive notification system

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/core/helper/main_helper/biometric_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/notification/data/repository/account_status_notification_service.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/data_source/remote_data_source/user_access_remote_data_source.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/login_attempt_store.dart';

class UserAccessRepository {
  /// Sender identity attached to account-status notifications when the acting
  /// admin's own email is unavailable.
  ///
  /// Was typed inline as `"system@company.com"` / `"admin@company.com"` at
  /// three call sites (§15 — no magic values in the data layer).
  static const String _systemSenderEmail = 'system@company.com';
  static const String _adminSenderEmail = 'admin@company.com';

  UserAccessRemoteDataSource remoteDataSource =
  UserAccessRemoteDataSource();

  /// Method Name: [getAccountsStatusEntities]
  ///
  /// Purpose: get all employees from the database and convert them to UserAccessEntity
  ///
  /// return: [Either<Failure, dynamic>]
  ///                                 - Failure: if there is an error in the process or [UserAccessEntity] data.
  Future<Either<Failure, dynamic>> getAccountsStatusEntities() async {
    Either<Failure, dynamic> result = await remoteDataSource.getEmployees();
    if (result.isLeft()) return result;

    List<Map<String, dynamic>> employees = result.getOrElse(() => []);
    List<UserAccessEntity> entities = [];

    for (Map<String, dynamic> employee in employees) {
      entities.add(_toUserAccessEntity(NewEmployeeModelHistory.fromMap(employee)));
    }

    result = Right(entities);
    return result;
  }


  /// Function Name: [_toUserAccessEntity]
  ///
  /// Purpose: Map an employee data model onto a [UserAccessEntity].
  ///
  /// Moved here 12/8/2026 from `UserAccessEntity.fromEmployeeModelHistory`.
  /// Having the mapper on the entity forced `domain/` to import a `data/`
  /// model, and its date parsing needed `try/catch`, which §11.2 forbids under
  /// `domain/`. Model -> entity mapping is a data-layer job (§3/§34).
  ///
  /// Parameters:
  /// - [employeeModel]: The stored employee record.
  ///
  /// Returns: [UserAccessEntity]
  UserAccessEntity _toUserAccessEntity(NewEmployeeModelHistory employeeModel) {
    String? photo;

    if (employeeModel.photo.isNotEmpty) {
      final String lastPhoto = employeeModel.photo.last;
      if (lastPhoto.isNotEmpty &&
          lastPhoto != "[]" &&
          lastPhoto.trim().isNotEmpty) {
        photo = lastPhoto;
      }
    }

    if (photo == null || photo.isEmpty) {
      final bool isFemale = employeeModel.gender.isNotEmpty &&
          employeeModel.gender.last.toLowerCase() == "female";
      photo = isFemale
          ? 'assets/icons_assets/main_icons_assets/female_avatar.png'
          : 'assets/icons_assets/main_icons_assets/male_avatar.png';
    }

    return UserAccessEntity(
      email: employeeModel.email.isNotEmpty ? employeeModel.email.last : '',
      reactivationDate: _parseDateFlexible(employeeModel.activationDate),
      arabicTitle: employeeModel.titleInArabic.isNotEmpty
          ? employeeModel.titleInArabic.last
          : '',
      englishTitle:
          employeeModel.title.isNotEmpty ? employeeModel.title.last : '',
      deactivationDate: _parseDateFlexible(employeeModel.deactivationDate),
      photoUrl: photo,
      employeeId: employeeModel.id ?? '',
      status: employeeModel.status.isNotEmpty
          ? EmployeeStatusEnum.values.firstWhere(
              (element) => element.name == employeeModel.status.last,
              orElse: () => EmployeeStatusEnum.inactive,
            )
          : EmployeeStatusEnum.inactive,
      firstLogin: _parseDateFlexible(employeeModel.firstLogin),
      lastLogin: _parseDateFlexible(employeeModel.lastLogin),
      tempPassword: employeeModel.defaultPassword ?? '',
      englishName: employeeModel.firstName.isNotEmpty &&
              employeeModel.lastName.isNotEmpty
          ? "${employeeModel.firstName.last} ${employeeModel.lastName.last}"
          : '',
      arabicName: employeeModel.firstNameInArabic.isNotEmpty &&
              employeeModel.lastNameInArabic.isNotEmpty
          ? "${employeeModel.firstNameInArabic.last} ${employeeModel.lastNameInArabic.last}"
          : '',
      expirationTimeOfPassword: employeeModel.passwordExpirationTime ?? "12",
      expirationTimeUnit: employeeModel.passwordExpirationUnit ?? "Week",
      department: employeeModel.departmentId.isNotEmpty
          ? employeeModel.departmentId.last
          : '',
    );
  }

  /// Function Name: [_parseDateFlexible]
  ///
  /// Purpose: Parse a stored date written in any of the formats this data has
  /// used over time.
  ///
  /// Moved here 12/8/2026 from the domain entity — the strategy loop needs
  /// `try/catch`, which is allowed in `data/` (C1) but not in `domain/` (§11.2).
  ///
  /// Parameters:
  /// - [dateString]: The raw stored value; `null`/empty yields `null`.
  ///
  /// Returns: [DateTime?] `null` when no known format matches.
  static DateTime? _parseDateFlexible(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    // WIDENED 25/8/2026 — Arabic values are already in the data.
    //
    // `UserAccessDialogs.showSchedule` formatted the schedule date with a
    // locale-less `DateFormat`, which follows the AMBIENT locale, so every
    // schedule set while the app was in Arabic went to Firestore as
    // "أغسطس ٢٢, ٢٠٢٦". That write is fixed at its source now, but rows written
    // before the fix are still stored, and none of the patterns below matched
    // them — the card simply showed no schedule.
    //
    // Two things stand between those values and a DateTime: Arabic-Indic
    // digits, and Arabic month names. The first is a character swap done once
    // up front; the second needs the 'ar' date symbols, hence the extra
    // strategies.
    final String normalized = _toAsciiDigits(dateString);

    final strategies = <DateTime Function()>[
      () => DateTime.parse(normalized),
      () => DateFormat('MMM dd, yyyy', 'en').parse(normalized),
      () => DateFormat(Constants.userAccessDateFormat, 'en').parse(normalized),
      () => DateFormat('dd MMMM yyyy, hh:mm a', 'en').parse(normalized),
      () => DateFormat('yyyy-MM-dd').parse(normalized),
      // Arabic month names — what the old bug wrote.
      () => DateFormat(Constants.userAccessDateFormat, 'ar').parse(normalized),
      () => DateFormat('MMMM dd, yyyy', 'ar').parse(normalized),
      () => DateFormat('dd MMMM yyyy', 'ar').parse(normalized),
    ];

    for (final strategy in strategies) {
      try {
        return strategy();
      } catch (_) {
        continue;
      }
    }

    debugPrint('_parseDateFlexible: unrecognised date format "$dateString"');
    return null;
  }

  /// Function Name: [_toAsciiDigits]
  ///
  /// Purpose: Rewrite Arabic-Indic digits (٠-٩) as ASCII so `DateFormat` can
  ///          read them, leaving every other character alone.
  ///
  /// `DateFormat.parse` matches digits against the locale's own numerals, and
  /// intl's `ar` locale is Latin-digit (its `ZERO_DIGIT` is '0'), so it cannot
  /// read "٢٢" even with the 'ar' symbols loaded. Normalising first means one
  /// pass covers every pattern above.
  ///
  /// Parameters:
  /// - [value]: the raw stored string.
  ///
  /// Returns: [String] the same text with ASCII digits.
  static String _toAsciiDigits(String value) {
    const List<String> arabicIndic = <String>[
      '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
    ];

    String result = value;
    for (int i = 0; i < arabicIndic.length; i++) {
      result = result.replaceAll(arabicIndic[i], '$i');
    }
    return result;
  }

  /// Method Name: [updateAccountStatus]
  ///
  /// Purpose: Update employee status using synchronized history pattern
  ///
  /// Parameters:
  ///   [UserAccessEntity] accountStatusAccessEntity
  ///   [EmployeeStatusEnum] status - new status to set
  /// ✅ UPDATED: Now sends notifications based on status change
  Future<Either<Failure, dynamic>> updateAccountStatus(
      UserAccessEntity accountStatusAccessEntity,
      EmployeeStatusEnum status) async {

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);

    if (result.isLeft()) {
      return result;
    }

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    Map<String, dynamic> employeeData =
    employeeDataOrNull as Map<String, dynamic>;


    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeData);


    // ✅ Store old values for notification logic
    String oldStatus = employeeModel.status.isNotEmpty
        ? employeeModel.status.last
        : '';
    String? oldActivationDate = employeeModel.activationDate;
    String? oldDeactivationDate = employeeModel.deactivationDate;


    // Is this the admin lifting a lock, as opposed to any other status change?
    final bool isUnlocking = status == EmployeeStatusEnum.active &&
        (oldStatus == EmployeeStatusEnum.locked.name ||
            oldStatus == EmployeeStatusEnum.lockedWithRequest.name ||
            oldStatus == _lockedWithRequestStatus);

    // Update the employee model
    employeeModel = employeeModel.copyWithUpdateSynchronized(
      status: status.name,
      deactivationDate: '', // Clear scheduled deactivation
      activationDate: '',   // Clear scheduled activation
    );

    if (isUnlocking) {
      // ADDED 22/8/2026 — unlocking must NOT hand the account straight back to
      // the user's old password.
      //
      // `DemoLoginRepository.validateActiveAccount` resolves the accepted
      // credential as `employeeModel.password ?? employeeModel.defaultPassword`,
      // so as long as `Password` holds a value the personal password the user
      // was locked out on keeps working — the lock taught them nothing and the
      // admin had no way to hand over a fresh credential.
      //
      // Clearing `Password` makes the account fall back to `Default_Password`,
      // which is exactly the value the admin can see in the Default Password
      // column of this screen and read out to the user.
      employeeModel.password = null;
    }

    // REMOVED 12/8/2026: `Map<String, dynamic> mapToSave = employeeModel.toMap();`
    // — computed and never used; the write below sends `employeeModel` directly.
    var updateResult = await remoteDataSource.updateEmployeeModel(employeeModel);

    if (updateResult.isRight() && isUnlocking) {
      // …and flipping Is_Activated back to false routes the next sign-in
      // through `validateInactiveAccount`, whose success type is
      // `SuccessAuthenticationType.inactive` — which `LoginController.login`
      // already sends to the ResetPassword screen. So the unlocked user signs
      // in once with the default password and is then required to create a new
      // one before reaching the app. `DemoLoginRepository.updateEmployeePassword`
      // sets both fields back when they save.
      await _requirePasswordResetOnNextLogin(accountStatusAccessEntity.email);

      // The failure history that produced the lock is spent. Without this the
      // unlocked user would be one wrong password away from being locked again.
      LoginAttemptStore.reset(accountStatusAccessEntity.email);
    }

    if (updateResult.isRight()) {

      // ═══════════════════════════════════════════════════════════
      // ✅ SEND NOTIFICATIONS BASED ON STATUS CHANGE
      // ═══════════════════════════════════════════════════════════

      String userEmail = accountStatusAccessEntity.email;
      String userName = accountStatusAccessEntity.englishName;
      String adminEmail = storage.read('email') ?? _systemSenderEmail;

      // 1. Account Activated
      if (status == EmployeeStatusEnum.active && oldStatus != 'active') {
        await AccountStatusNotificationService.sendAccountActivatedNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }

      // 2. Account Deactivated
      if (status == EmployeeStatusEnum.deactivated && oldStatus != 'deactivated') {
        await AccountStatusNotificationService.sendAccountDeactivatedNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS

        );
      }

      // 3. Account Unlocked (from locked to active)
      if (status == EmployeeStatusEnum.active &&
          (oldStatus == 'locked' || oldStatus == 'locked with send request')) {
        await AccountStatusNotificationService.sendAccountUnlockedNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }

      // 4. Schedule Canceled (if had scheduled dates and now cleared)
      if ((oldActivationDate != null && oldActivationDate.isNotEmpty) ||
          (oldDeactivationDate != null && oldDeactivationDate.isNotEmpty)) {
        await AccountStatusNotificationService.sendScheduleCanceledNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }
    }

    return updateResult;
  }

  /// Method Name: [scheduleDeactivationTime]
  ///
  /// Purpose: schedule deactivation time for the employee.
  ///
  /// Parameters:
  ///            [UserAccessEntity] accountStatusAccessEntity
  ///            [String] deactivationTime
  /// ✅ UPDATED: Now sends notifications when scheduling deactivation
  Future<Either<Failure, dynamic>> scheduleDeactivationTime(
      UserAccessEntity accountStatusAccessEntity,
      String deactivationTime) async {

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);
    if (result.isLeft()) return result;

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeDataOrNull as Map<String, dynamic>);


    // ✅ Store old value to detect edit vs new schedule
    String? oldDeactivationDate = employeeModel.deactivationDate;

    // Update dates
    employeeModel.deactivationDate = deactivationTime;
    employeeModel.activationDate = ''; // Clear activation schedule


    var updateResult = await remoteDataSource.updateEmployeeModel(employeeModel);

    // ═══════════════════════════════════════════════════════════
    // ✅ SEND NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════
    if (updateResult.isRight()) {
      String userEmail = accountStatusAccessEntity.email;
      String userName = accountStatusAccessEntity.englishName;
      String adminEmail = _adminSenderEmail;

      // Check if this is a NEW schedule or EDIT
      if (oldDeactivationDate != null && oldDeactivationDate.isNotEmpty) {
        // EDIT - schedule was changed
        await AccountStatusNotificationService.sendScheduleEditedNotification(
          userEmail: userEmail,
          userName: userName,
          newScheduledDate: deactivationTime,
          scheduleType: "deactivation",
          senderEmail: adminEmail, // ✅ ADD THIS
        );
        // ADDED 26/8/2026 — see [_recordScheduleChange]. This branch already
        // knew a date had MOVED; until now that knowledge died with the
        // notification and the calendar had no way to recover it.
        await _recordScheduleChange(
          employeeId: accountStatusAccessEntity.employeeId,
          field: _deactivationChangedAtField,
          previousValue: oldDeactivationDate,
        );
      } else {
        // NEW - first time scheduling
        await AccountStatusNotificationService.sendDeactivationScheduledNotification(
          userEmail: userEmail,
          userName: userName,
          scheduledDate: deactivationTime,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }
    }

    return updateResult;
  }

  /// Method Name: [scheduleReactivationTime]
  ///
  /// Purpose: schedule reactivation time for the employee.
  ///
  /// Parameters:
  ///            [UserAccessEntity] accountStatusAccessEntity
  ///            [String] reactivationTime
  /// ✅ UPDATED: Now sends notifications when scheduling reactivation
  Future<Either<Failure, dynamic>> scheduleReactivationTime(
      UserAccessEntity accountStatusAccessEntity,
      String reactivationTime) async {

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);
    if (result.isLeft()) return result;

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeDataOrNull as Map<String, dynamic>);


    // ✅ Store old value to detect edit vs new schedule
    String? oldActivationDate = employeeModel.activationDate;

    // Update dates
    employeeModel.activationDate = reactivationTime;
    employeeModel.deactivationDate = ''; // Clear deactivation schedule


    var updateResult = await remoteDataSource.updateEmployeeModel(employeeModel);

    // ═══════════════════════════════════════════════════════════
    // ✅ SEND NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════
    if (updateResult.isRight()) {
      String userEmail = accountStatusAccessEntity.email;
      String userName = accountStatusAccessEntity.englishName;
      String adminEmail = _adminSenderEmail;

      // Check if this is a NEW schedule or EDIT
      if (oldActivationDate != null && oldActivationDate.isNotEmpty) {
        // EDIT - schedule was changed
        await AccountStatusNotificationService.sendScheduleEditedNotification(
          userEmail: userEmail,
          userName: userName,
          newScheduledDate: reactivationTime,
          scheduleType: "activation",
        );
        // ADDED 26/8/2026 — see [_recordScheduleChange].
        await _recordScheduleChange(
          employeeId: accountStatusAccessEntity.employeeId,
          field: _activationChangedAtField,
          previousValue: oldActivationDate,
        );
      } else {
        // NEW - first time scheduling
        await AccountStatusNotificationService.sendActivationScheduledNotification(
          userEmail: userEmail,
          userName: userName,
          scheduledDate: reactivationTime,
        );
      }
    }

    return updateResult;
  }

  /// Method Name: [approveResetPassword]
  ///
  /// Purpose: Approve reset password request and deactivate account
  ///
  /// Parameters:
  ///            [UserAccessEntity] accountStatusAccessEntity
  Future<Either<Failure, dynamic>> approveResetPassword(
      UserAccessEntity accountStatusAccessEntity) async {
    remoteDataSource.startTransaction();

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);
    if (result.isLeft()) {
      return result;
    }

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeDataOrNull as Map<String, dynamic>);

    // Use copyWithUpdateSynchronized for status change
    employeeModel = employeeModel.copyWithUpdateSynchronized(
      status: EmployeeStatusEnum.inactive.name,
      deactivationDate: '',
      activationDate: '',
    );

    remoteDataSource.updateDemoUsersAccountWithinTransaction(
        accountStatusAccessEntity.email,
        {DemoUserAccountOverview.isActivatedField: false});

    remoteDataSource.updateEmployeeWithinTransaction(employeeModel);

    var commitResult = await remoteDataSource.commitTransaction();

    // ═══════════════════════════════════════════════════════════
    // ✅ SEND NOTIFICATION (Password Reset Approved)
    // ═══════════════════════════════════════════════════════════
    if (commitResult.isRight()) {
      String userName = accountStatusAccessEntity.englishName;

      await AccountStatusNotificationService.sendAccountDeactivatedNotification(
        userEmail: accountStatusAccessEntity.email,
        userName: userName,
      );
    }

    return commitResult;
  }

  /// Method Name: [updateAccessDetails]
  ///
  /// Purpose: Update default password and expiration time in Firebase
  Future<Either<Failure, dynamic>> updateAccessDetails(
      UserAccessEntity entity) async {


    try {
      String? documentId = entity.employeeId;

      if (documentId == null || documentId.isEmpty) {
        return Left(FirebaseFailure('Document ID cannot be null or empty'));
      }

      final employeesInfoRef = FirebaseFirestore.instance
          .collection(getBaseUrl(FirebaseCollections.employeesInfo));

      DocumentSnapshot docSnapshot = await employeesInfoRef
          .doc(documentId)
          .get(const GetOptions(source: Source.server));

      if (!docSnapshot.exists) {
        return Left(FirebaseFailure('Employee document not found'));
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      data['Id'] = documentId;
      NewEmployeeModelHistory employeeModel =
      NewEmployeeModelHistory.fromMap(data);


      // Update ALL THREE fields
      employeeModel.defaultPassword = entity.tempPassword;
      employeeModel.passwordExpirationTime = entity.expirationTimeOfPassword;
      employeeModel.passwordExpirationUnit = entity.expirationTimeUnit;


      Map<String, dynamic> mapToSave = employeeModel.toMap();

      await employeesInfoRef.doc(documentId).set(
          mapToSave, SetOptions(merge: true));

      return Right(null);
    } catch (e) {
      return Left(FirebaseFailure('Failed to update access details: $e'));
    }
  }

  /// The stored `Status` string for an account that was locked while a reset
  /// request was outstanding. `EmployeeStatusEnum.lockedWithRequest.name` is
  /// the camel-case enum name, which is *not* what earlier builds wrote into
  /// Firestore, so both spellings are matched when detecting an unlock.
  static const String _lockedWithRequestStatus = 'locked with send request';

  // ══════════════════════════════════════════════════════════════════
  //  SCHEDULE-CHANGE MARKERS — added 26/8/2026 for the calendar
  //
  //  `CalendarDataService.getUserAccessCalendarEvents` emitted only four of
  //  the module's eight catalog entries, and said why in a comment:
  //
  //      "Activation_Date / Deactivation_Date are single strings with no
  //       history, so a change cannot be detected. Role Management can do this
  //       because its dates ARE history lists."
  //
  //  True as far as it goes, and it led to the wrong conclusion — that the
  //  fix is to give those fields a history. It is not. Giving them one would
  //  change the type of two fields that a dozen call sites read as plain
  //  strings (`employeeModel.activationDate`, `_parseDateFlexible(...)`,
  //  every `.isNotEmpty` check in this file), for the sake of a question the
  //  calendar only ever asks about the LATEST change: "was this date moved,
  //  and when?"
  //
  //  Two scalar timestamps answer exactly that, cost two writes on a path that
  //  was already writing, and change no existing type. They are written only
  //  on the EDIT branch of each scheduler — the branch that already knew it
  //  was looking at a moved date, because that is what tells
  //  `sendScheduleEditedNotification` apart from
  //  `sendActivationScheduledNotification`. A first-time schedule writes
  //  nothing, which is correct: nothing was moved.
  //
  //  Both survive later writes: every writer to `Employees_Info` in this
  //  feature uses `SetOptions(merge: true)`.
  // ══════════════════════════════════════════════════════════════════

  /// When `Activation_Date` was last moved (epoch ms).
  static const String _activationChangedAtField = 'Activation_Date_Changed_At';

  /// When `Deactivation_Date` was last moved (epoch ms).
  static const String _deactivationChangedAtField =
      'Deactivation_Date_Changed_At';

  /// Function Name: [_recordScheduleChange]
  ///
  /// Purpose: Stamp the moment a scheduled activation or deactivation date was
  /// moved, so the calendar has a date to hang its "… Date Updated" card on.
  ///
  /// The previous value is stored beside the timestamp rather than discarded:
  /// a card that can say what the date was moved FROM is worth more than one
  /// that only says it moved, and it is free here — the caller is holding the
  /// old value already.
  ///
  /// Parameters:
  /// - [employeeId]: the `Employees_Info` document id.
  /// - [field]: [_activationChangedAtField] or [_deactivationChangedAtField].
  /// - [previousValue]: the date string as it stood before this save.
  ///
  /// Returns: [Future<void>] — never throws. The schedule change itself has
  /// already been written and notified; failing to stamp it must not turn a
  /// successful reschedule into an error.
  Future<void> _recordScheduleChange({
    required String? employeeId,
    required String field,
    required String previousValue,
  }) async {
    if (employeeId == null || employeeId.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection(getBaseUrl(FirebaseCollections.employeesInfo))
          .doc(employeeId)
          .set(
        <String, dynamic>{
          field: DateTime.now().millisecondsSinceEpoch,
          '${field}_Previous': previousValue,
        },
        SetOptions(merge: true),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'schedule-change marker: could not stamp $field on $employeeId: '
        '$e\n$stackTrace',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  UNLOCK REQUEST — added 26/8/2026
  //
  //  `AccountStatusNotificationService.sendUnlockRequestNotification` and its
  //  event `accountUnlockRequestedAdmin` have existed since the catalog was
  //  written, with no caller anywhere in `lib/`. The same is true of the
  //  status the request produces: `EmployeeStatusEnum.lockedWithRequest` is
  //  READ in three places — `_checkEmployeeStatus` maps it to
  //  `SuccessAuthenticationType.lockedWithRequest`, [updateAccountStatus]
  //  treats it as unlockable, and the User Access screen styles it — and was
  //  WRITTEN by nothing. Half a feature, wired at both ends and missing its
  //  middle.
  //
  //  This is that middle. The trigger is the locked user's next sign-in
  //  attempt: someone who has been locked out and comes back to try again IS
  //  asking to be let in, and making them find a button to say so adds a step
  //  without adding information. The caller is
  //  `DemoLoginController.handleLockedAccountSignIn`, reached from both sign-in
  //  paths that can land on a locked account — `lockAccount`'s "already locked"
  //  branch (wrong password again) and `LoginController`'s catch-all `else`
  //  (right password, locked account).
  //
  //  It is idempotent by construction: the status it writes is the same status
  //  it refuses to act on, so a user who tries five times raises one request.
  // ══════════════════════════════════════════════════════════════════

  /// Function Name: [requestAccountUnlock]
  ///
  /// Purpose: Record that a locked-out user has asked to be unlocked, and tell
  /// the Master Admins.
  ///
  /// Parameters:
  /// - [employeeModel]: the locked account, freshly read by the caller.
  /// - [userName]: the display name to print in the admin notification.
  ///
  /// Returns: [Future<bool>] true when a NEW request was raised. False when the
  /// account was not locked, when a request was already outstanding, or when
  /// the write failed — in all three cases no notification is sent.
  Future<bool> requestAccountUnlock({
    required NewEmployeeModelHistory employeeModel,
    required String userName,
  }) async {
    final String email =
        employeeModel.email.isNotEmpty ? employeeModel.email.last : '';
    if (email.isEmpty) return false;

    final String currentStatus =
        employeeModel.status.isNotEmpty ? employeeModel.status.last : '';

    // Already asked. Both spellings, for the reason [_lockedWithRequestStatus]
    // gives.
    if (currentStatus == EmployeeStatusEnum.lockedWithRequest.name ||
        currentStatus == _lockedWithRequestStatus) {
      return false;
    }

    // Only a locked account can ask to be unlocked.
    if (currentStatus != EmployeeStatusEnum.locked.name) return false;

    // `updateEmployeeModel` addresses the document by `id`, and this model was
    // read by EMAIL — `FirebaseRepository.getDocumentWithFieldLasValue` returns
    // `document.data()` without folding in `document.id`, so `Id` is there only
    // because `toMap()` happens to write it as a field. A record last written
    // through an older path may not carry it, and a null id would write to a
    // document literally named "null". Resolved from the address in that case,
    // and resolved BEFORE the copy: `copyWithUpdateSynchronized` appends a row
    // to every history list, so calling it twice would record two status
    // changes for one request.
    String? documentId = employeeModel.id;
    if (documentId == null || documentId.trim().isEmpty) {
      documentId = await _employeeIdForEmail(email);
      if (documentId == null) return false;
    }

    final NewEmployeeModelHistory requested =
        employeeModel.copyWithUpdateSynchronized(
      id: documentId,
      status: EmployeeStatusEnum.lockedWithRequest.name,
    );

    final Either<Failure, dynamic> updateResult =
        await remoteDataSource.updateEmployeeModel(requested);
    if (updateResult.isLeft()) return false;

    await AccountStatusNotificationService.sendUnlockRequestNotification(
      userEmail: email,
      userName: userName,
      // The user IS the sender here — this is the one notification in the
      // module that travels upward, from the locked account to the
      // administrators, rather than from an admin to a user.
      senderEmail: email,
    );

    return true;
  }

  /// Function Name: [_employeeIdForEmail]
  ///
  /// Purpose: The `Employees_Info` document id for an address.
  ///
  /// Only used as the fallback in [requestAccountUnlock], for a record whose
  /// stored `Id` field is missing. `Email` is a history list whose current
  /// value is the last entry, so the match is on the last element — the same
  /// rule `getDocumentWithFieldLasValue` encodes with `arrayContains`, but
  /// tightened: `arrayContains` would also match an address the employee USED
  /// to have, and handing an unlock request to whoever holds that address now
  /// would be wrong.
  ///
  /// Parameters:
  /// - [email]: the address to look up, matched case-insensitively.
  ///
  /// Returns: [Future<String?>] the document id, or null when no record's
  /// current address matches.
  Future<String?> _employeeIdForEmail(String email) async {
    final String target = email.trim().toLowerCase();
    if (target.isEmpty) return null;

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection(getBaseUrl(FirebaseCollections.employeesInfo))
              .where('Email', arrayContains: email)
              .get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final Object? emails = doc.data()['Email'];
        if (emails is List &&
            emails.isNotEmpty &&
            emails.last.toString().trim().toLowerCase() == target) {
          return doc.id;
        }
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('unlock request: could not resolve an id for $email: '
          '$e\n$stackTrace');
      return null;
    }
  }

  /// Function Name: [_requirePasswordResetOnNextLogin]
  ///
  /// Purpose: Mark [email]'s demo account inactive so the next successful
  /// sign-in is routed to the create-password screen.
  ///
  /// Added 22/8/2026 for the unlock flow — see the note in
  /// [updateAccountStatus]. A failure here is logged rather than propagated:
  /// the status write has already succeeded and the account is genuinely
  /// unlocked, so surfacing this as a failed unlock would be wrong. The user
  /// would simply sign in with the default password without the forced reset.
  ///
  /// Parameters:
  /// - [email]: the unlocked account's email, the document id in
  ///   `Demo_Users_Accounts`.
  ///
  /// Returns: [Future<void>]
  Future<void> _requirePasswordResetOnNextLogin(String email) async {
    final String normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.demoUsersAccounts)
          .doc(normalizedEmail)
          .update({DemoUserAccountOverview.isActivatedField: false});
    } catch (e, stackTrace) {
      debugPrint(
        'unlock: could not flag $normalizedEmail for a password reset: '
        '$e\n$stackTrace',
      );
    }
  }

  // REMOVED 12/8/2026: `_buildEmployeeFullName` — its only call sites were
  // the `englishName ?? _buildEmployeeFullName(...)` fallbacks, which were
  // unreachable because `englishName` is non-nullable.
}