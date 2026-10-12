/// Module: roles / r3_user_access / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_entity.dart
/// Purpose: Declares `UserAccessEntity` — the user-access view of an employee,
///          isolating the UI from the employee data model.
/// Author: Amr Mesbah
/// Created: 22/1/2025
/// Updated: 12/8/2026 - Domain purity pass. Removed:
///          - the `package:get/get.dart` import (unused; GetX is banned);
///          - the presentation import (`MainCoreDepartmentCubit`) that backed
///            `departmentName(...)` — the widget now resolves the department
///            name itself from the cubit it already holds;
///          - the data import (`NewEmployeeModelHistory`) and the
///            `fromEmployeeModelHistory` mapper, which moved to
///            `UserAccessRepository` where model -> entity mapping belongs;
///          - `_parseDateFlexible`, which wrapped parsing in `try/catch` — §11.2
///            forbids try/catch anywhere under `domain/`; it moved with the
///            mapper;
///          - dead `_applyScheduledStatusChanges` (no callers).
///          All fields are now `final` with a `copyWith` (§10/§20).

import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';

class UserAccessEntity {
  final String employeeId;
  final String email;
  final EmployeeStatusEnum status;
  final String? photoUrl;
  final DateTime? firstLogin;
  final DateTime? lastLogin;
  final DateTime? deactivationDate;
  final DateTime? reactivationDate;
  final String tempPassword;
  final String englishName;
  final String arabicName;

  /// The department **id**, not its display name. Callers that need the name
  /// resolve it through `MainCoreDepartmentCubit` in the presentation layer.
  final String department;
  final String englishTitle;
  final String arabicTitle;
  final String expirationTimeOfPassword;
  final String expirationTimeUnit;

  const UserAccessEntity({
    required this.employeeId,
    required this.email,
    required this.status,
    required this.firstLogin,
    required this.lastLogin,
    required this.tempPassword,
    required this.reactivationDate,
    required this.englishName,
    required this.arabicName,
    required this.department,
    required this.arabicTitle,
    required this.englishTitle,
    required this.expirationTimeOfPassword,
    required this.photoUrl,
    required this.deactivationDate,
    required this.expirationTimeUnit,
  });

  /// Function Name: [copyWith]
  ///
  /// Purpose: Produce a modified copy — the entity is immutable, so status
  /// transitions and edits create a new instance instead of mutating in place.
  ///
  /// Returns: [UserAccessEntity]
  UserAccessEntity copyWith({
    String? employeeId,
    String? email,
    EmployeeStatusEnum? status,
    String? photoUrl,
    DateTime? firstLogin,
    DateTime? lastLogin,
    DateTime? deactivationDate,
    DateTime? reactivationDate,
    String? tempPassword,
    String? englishName,
    String? arabicName,
    String? department,
    String? englishTitle,
    String? arabicTitle,
    String? expirationTimeOfPassword,
    String? expirationTimeUnit,
  }) {
    return UserAccessEntity(
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      firstLogin: firstLogin ?? this.firstLogin,
      lastLogin: lastLogin ?? this.lastLogin,
      deactivationDate: deactivationDate ?? this.deactivationDate,
      reactivationDate: reactivationDate ?? this.reactivationDate,
      tempPassword: tempPassword ?? this.tempPassword,
      englishName: englishName ?? this.englishName,
      arabicName: arabicName ?? this.arabicName,
      department: department ?? this.department,
      englishTitle: englishTitle ?? this.englishTitle,
      arabicTitle: arabicTitle ?? this.arabicTitle,
      expirationTimeOfPassword:
          expirationTimeOfPassword ?? this.expirationTimeOfPassword,
      expirationTimeUnit: expirationTimeUnit ?? this.expirationTimeUnit,
    );
  }

  /// The job title in the caller's language.
  String jobTitle(bool isArabic) => isArabic ? arabicTitle : englishTitle;

  // ── Formatted date getters (locale-aware) ─────────────────────────────────
  // Formatting lives in DateTimeHelper.formatDateDDMMMYYYY.

  /// "23 Aug 2026"  /  "23 أغسطس 2026"
  String get firstLoginDateFormatted =>
      DateTimeHelper.formatDateDDMMMYYYY(firstLogin);

  /// "23 Aug 2026"  /  "23 أغسطس 2026"
  String get lastLoginDateFormatted =>
      DateTimeHelper.formatDateDDMMMYYYY(lastLogin);

  /// "23 Aug 2026"  /  "23 أغسطس 2026"
  String get deactivationDateFormatted =>
      DateTimeHelper.formatDateDDMMMYYYY(deactivationDate);

  // ── Raw getters kept for backward compatibility ───────────────────────────
  String get firstLoginDate =>
      firstLogin == null ? '' : DateFormat('yyyy-MM-dd').format(firstLogin!);
  String get firstLoginTime =>
      firstLogin == null ? '' : DateFormat('hh:mm a').format(firstLogin!);
  String get lastLoginDate =>
      lastLogin == null ? '' : DateFormat('yyyy-MM-dd').format(lastLogin!);
  String get lastLoginTime =>
      lastLogin == null ? '' : DateFormat('hh:mm a').format(lastLogin!);
  String get deactivationDateDate => deactivationDate == null
      ? ''
      : DateFormat('yyyy-MM-dd').format(deactivationDate!);
  String get deactivationTime => deactivationDate == null
      ? ''
      : DateFormat('hh:mm a').format(deactivationDate!);

  // ── Status helpers ────────────────────────────────────────────────────────
  bool get isActive => status == EmployeeStatusEnum.active;
  bool get isInactive => status == EmployeeStatusEnum.inactive;
  bool get isRequestToReset => status == EmployeeStatusEnum.resetPassword;
  bool get isLockedWithRequest =>
      status == EmployeeStatusEnum.lockedWithRequest;
  bool get isLocked => status == EmployeeStatusEnum.locked;
  bool get isDeactivated => status == EmployeeStatusEnum.deactivated;
  bool get willBeDeactivated => deactivationDate != null;
  bool get willBeActivated => reactivationDate != null;
}
