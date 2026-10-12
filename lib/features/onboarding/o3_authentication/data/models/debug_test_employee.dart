/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: debug_test_employee.dart
/// Purpose: DEBUG-ONLY row of the "Switch to test employee" picker — the
///          display fields of one test account, nothing else.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 - DEBUG-ONLY (see debug_test_employee_switch.dart)
///
/// Deliberately has NO password field: the repository strips `Password` and
/// `Default_Password` from the raw document before anything parses it.

/// DEBUG-ONLY 9/10/2026 — one selectable test account.
class DebugTestEmployee {
  const DebugTestEmployee({
    required this.email,
    required this.nameEn,
    required this.nameAr,
    required this.role,
    required this.departmentEn,
    required this.departmentAr,
    required this.status,
    this.isActivated,
  });

  /// CHANGED 9/10/2026 — DEBUG-ONLY: `Demo_Users_Accounts/{email}.Is_Activated`
  /// (`null` when unknown). `false` is shown as a grey note only; the switch
  /// still signs a test account in.
  final bool? isActivated;

  /// Current (`.last`) email, lower case.
  final String email;

  /// "First Last" in English ('' when absent).
  final String nameEn;

  /// "First Last" in Arabic ('' when absent).
  final String nameAr;

  /// Current role name as stored on `Employees_Info.Role` ('' when absent).
  final String role;

  /// Department name in English ('' when unknown).
  final String departmentEn;

  /// Department name in Arabic ('' when unknown).
  final String departmentAr;

  /// Current `Employees_Info.Status` ('' when absent).
  final String status;

  /// Name in the requested language, falling back to the other one, then to
  /// the email.
  String name({required bool arabic}) {
    final String preferred = arabic ? nameAr : nameEn;
    final String fallback = arabic ? nameEn : nameAr;
    if (preferred.trim().isNotEmpty) return preferred.trim();
    if (fallback.trim().isNotEmpty) return fallback.trim();
    return email;
  }

  /// Department in the requested language, falling back to the other one.
  String department({required bool arabic}) {
    final String preferred = arabic ? departmentAr : departmentEn;
    final String fallback = arabic ? departmentEn : departmentAr;
    return preferred.trim().isNotEmpty ? preferred.trim() : fallback.trim();
  }

  /// Whether the status allows a sign-in (anything else is shown as a hint).
  bool get isActive => status.trim().isEmpty || status.trim().toLowerCase() == 'active';
}
