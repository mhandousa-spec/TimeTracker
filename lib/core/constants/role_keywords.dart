// ******************* FILE INFO *******************
// File Name: role_keywords
// Description: Shared keyword lists used to classify employee roles.
// Module: core / constants / services_management
// *************************************************

/// Keyword lists used to classify an employee as leadership vs. regular staff.
///
/// These are matching keywords (not display strings) and were previously
/// duplicated inline in both the details-switch page and its cubit (§17 — no
/// duplicated data lists).
class RoleKeywords {
  const RoleKeywords._();

  static const List<String> leadership = [
    'manager', 'director', 'head', 'lead', 'chief', 'supervisor', 'admin',
    'مدير', 'رئيس', 'قائد', 'مشرف',
  ];

  static const List<String> englishEmployee = [
    'employee', 'staff', 'worker', 'clerk', 'junior', 'trainee', 'intern',
  ];

  static const List<String> arabicEmployee = [
    'موظف', 'موظفة', 'عامل', 'عاملة', 'كاتب', 'كاتبة',
    'متدرب', 'متدربة', 'طالب تدريب', 'طالبة تدريب',
  ];
}
