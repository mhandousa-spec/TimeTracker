/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_employee.dart
/// Purpose: Declares `TimeTrackerEmployee` — one company employee as the
///          Employees / Groups screens show them (name, job title,
///          department, phone, e-mail, photo).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 3: the Employees tab lists the company's employees from the same
/// source the rest of the app uses (`MainCoreEmployeeController` /
/// `Employees_Info`), reached through `EmployeeDirectoryBaseRepository`.
/// Plain immutable Dart: no Firestore, no Flutter, no GetX.
/// Updated: 9/10/2026 - phase 4: [employeeId] (HR schedule lookup) and
/// [role] (who holds the approval switches — notifications).
/// Updated: 9/10/2026 - owner review: [name] shows a name stored all in
/// lower case ("salma fathy" — e.g. from an Active Directory upload) in
/// proper case ("Salma Fathy"); a name with any capital is shown exactly as
/// stored ("McDonald" stays). Never derived from the e-mail unless no name
/// is stored at all.
/// Updated: 9/10/2026 - owner finding (14:17): name, job title AND
/// department go through the module's ONE proper-case helper (`NameCase`).

import 'package:knowticed_plus/features/time_tracker/domain/rules/name_case.dart';

class TimeTrackerEmployee {
  const TimeTrackerEmployee({
    required this.email,
    this.nameEn = '',
    this.nameAr = '',
    this.jobTitleEn = '',
    this.jobTitleAr = '',
    this.departmentId = '',
    this.departmentName = '',
    this.phone = '',
    this.photo = '',
    this.employeeId = '',
    this.role = '',
    this.departmentNameEn = '',
    this.departmentNameAr = '',
  });

  /// Lower-cased; the key of the employee's `Location_Assignments` doc.
  final String email;
  final String nameEn;
  final String nameAr;
  final String jobTitleEn;
  final String jobTitleAr;
  final String departmentId;

  /// In the app language at load time ('' when unknown).
  final String departmentName;
  final String phone;

  /// A network URL or an app asset path ('' = none).
  final String photo;

  /// `Employees_Info` document id ('' when unknown).
  final String employeeId;

  /// The employee's current role (name or id, as `Employees_Info.Role`).
  final String role;

  /// ADDED 9/10/2026 (QA KP-TT-017): the department in BOTH languages, so a
  /// card follows the app language even when the list was read in the
  /// other one ('' = unknown → [departmentName]).
  final String departmentNameEn;
  final String departmentNameAr;

  /// Function Name: [name] / [jobTitle]
  ///
  /// Purpose: The value in the app language, falling back to the other one
  /// and, for the name, to the e-mail.
  ///
  /// Return type: [String]
  String name({required bool isArabic}) {
    final String picked =
        _pick(isArabic ? nameAr : nameEn, isArabic ? nameEn : nameAr);
    return picked.isNotEmpty ? properCase(picked) : email;
  }

  /// Function Name: [properCase]
  ///
  /// Purpose: ADDED 9/10/2026 — kept for callers; now the module helper
  /// `NameCase.proper` (Arabic untouched).
  ///
  /// Return type: [String]
  static String properCase(String value) => NameCase.proper(value);

  String jobTitle({required bool isArabic}) =>
      NameCase.proper(_pick(isArabic ? jobTitleAr : jobTitleEn, isArabic ? jobTitleEn : jobTitleAr));

  /// Function Name: [department]
  ///
  /// Purpose: ADDED 9/10/2026 — the department in the app language
  /// (KP-TT-017: "القسم: Citizen Services" in Arabic), proper case.
  ///
  /// Return type: [String]
  String department({required bool isArabic}) {
    final String picked = (isArabic ? departmentNameAr : departmentNameEn).trim();
    return NameCase.proper(picked.isNotEmpty ? picked : departmentName);
  }

  /// Search text (both names, title, department, e-mail).
  String get searchText =>
      '$nameEn $nameAr $jobTitleEn $jobTitleAr $departmentName $email'
          .toLowerCase();

  static String _pick(String first, String fallback) =>
      first.trim().isNotEmpty ? first.trim() : fallback.trim();
}
