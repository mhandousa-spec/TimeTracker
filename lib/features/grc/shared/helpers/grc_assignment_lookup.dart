/// Shared lookups used by every GRC champion/owner assignment page —
/// resolving the current user's email, finding a cached employee by email,
/// and finding a control inside an already-loaded policy->controls map.
/// Extracted because control_champion and control_owner each duplicated
/// these four functions verbatim across their cubit + 3 page files.
library;

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Placeholder phone number shown when an employee record has none set.
/// TODO(product): replace with a real empty-state (e.g. "No phone on file")
/// instead of fake digits — kept as a literal constant for now so there is
/// exactly one place to fix instead of four.
const String grcMockPhoneFallback = '2010258963';

/// Placeholder job title shown when an employee record has none set.
/// Used as a business-default fallback in assignment flows.
const String grcMockJobTitleFallback = 'Technician';

/// Placeholder department shown when an employee record has none set.
/// Used as a business-default fallback in assignment flows.
const String grcMockDepartmentFallback = 'IT';

/// Resolves the signed-in user's email for GRC assignment flows, falling
/// back from [Constant.emailUser] to the cached employee controller when
/// the constant hasn't been populated yet. Returns '' if neither is set.
String currentGrcUserEmail() {
  final fromConstant = Constant.emailUser;
  if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
  if (Get.isRegistered<MainCoreEmployeeController>()) {
    final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (email != null && email.isNotEmpty) return email;
  }
  return '';
}

/// Looks up an employee by email from the globally cached employee list.
/// Returns null if the controller isn't registered or no match exists.
EmployeeEntityPro? findEmployeeByEmail(String email) {
  if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
  final employees =
      Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
  // Case/space-insensitive: emails arrive from several screens.
  final String wanted = email.trim().toLowerCase();
  for (final e in employees) {
    if ((e.email ?? '').trim().toLowerCase() == wanted) return e;
  }
  return null;
}

/// Localized display name for [email], falling back to the raw email when
/// no matching employee is cached.
String employeeDisplayName(BuildContext context, String email) {
  final employee = findEmployeeByEmail(email);
  if (employee == null) return email;
  // FIXED 28/9/2026 (GRC bug report p22/p25/p28/p34): names are stored in
  // whatever case they were typed ("ibrahim al-shammari", "demo company").
  // Capitalize each word here so every GRC screen shows "Ibrahim Al-shammari".
  return FormatHelper.capitalize(EmployeeHelper.getEmployeeLocalizedName(
      employee: employee, context: context));
}

/// Display-field fallbacks for a possibly-missing employee — extracted
/// because control_champion_details_page and reassign_champion_page each
/// computed department/job title/photo/phone via the same chained ternary
/// fallbacks directly in build() (`employee != null ? EmployeeHelper... : ''`
/// etc.), duplicated verbatim across both files.
extension EmployeeDisplayFields on EmployeeEntityPro? {
  /// Localized department for this employee, or '' when null.
  String localizedDepartment(BuildContext context) {
    final employee = this;
    return employee != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context)
        : '';
  }

  /// Localized job title for this employee, or '' when null.
  String localizedJobTitle(BuildContext context) {
    final employee = this;
    return employee != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(
                    employee: employee, context: context)
                ?.toString() ??
            '')
        : '';
  }

  /// Photo URL/asset path for this employee, or the default avatar asset
  /// when null.
  String get displayPhoto {
    final employee = this;
    return employee != null
        ? EmployeeHelper.getEmployeeImage(employee: employee)
        : AppAssets.defaultEmployeeAvatar;
  }

  /// Mobile phone number for this employee, falling back to
  /// [grcMockPhoneFallback] when null or unset.
  String get displayPhone => this?.mobilePhone?.phone ?? grcMockPhoneFallback;
}

/// Finds the [ControlEntity] for [controlId] under [policyId] inside
/// [policyControls] — the policy-id -> controls map every champion/owner
/// assignment page already loads via GetAllControlsUseCase.
ControlEntity? findControlInPolicy(
  Map<String, List<ControlEntity>> policyControls,
  String policyId,
  String controlId,
) {
  final list = policyControls[policyId];
  if (list == null) return null;
  for (final c in list) {
    if (c.id == controlId) return c;
  }
  return null;
}
