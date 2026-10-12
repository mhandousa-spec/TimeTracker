/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_collection_paths.dart
/// Purpose: Resolve the tenant-aware collection paths this feature reads and
///          writes, in one place.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N19. `employee_branding_repository.dart` built
/// `'Demo/$companyId/Employee_Data'` and `'Demo/$companyId/Employees_Info'`
/// inline — the `Demo/` prefix hardcoded twice, in a file that also read
/// `ApiConstants.baseUri` (which already contains it). Deriving from `baseUri`
/// means a tenant change cannot leave one of the two behind.

import 'package:knowticed_plus/core/network/api_constants.dart';

abstract final class CompanyCollectionPaths {
  const CompanyCollectionPaths._();

  static const String _employeeDataName = 'Employee_Data';

  /// The tenant root, e.g. `Demo/75440689`.
  static String get _root => ApiConstants.baseUri;

  /// The company id embedded in the tenant root.
  static String get companyId => _root.split('/').last;

  /// `{baseUri}/Companys` — the company documents themselves.
  static String get companies => ApiConstants.company;

  /// `{baseUri}/Employee_Data` — per-employee branding overrides.
  static String get employeeData => '$_root/$_employeeDataName';

  /// `{baseUri}/Employees_Info` — the employee profiles.
  static String get employeesInfo => ApiConstants.employeesProfile;
}
