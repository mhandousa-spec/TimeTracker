/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_collection_paths.dart
/// Purpose: Resolve the tenant-aware employee collection paths in one place.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// The same `if (ApiConstants.baseUri.isNotEmpty) … else …` block was copied
/// into createEmployee, getEmployee, backupCollections and restoreFromBackup.
/// Four copies of a path rule is how the two backup collections ended up with
/// literal spaces in one branch and `ApiConstants` getters in the other.

import 'package:knowticed_plus/core/network/api_constants.dart';

abstract final class EmployeeCollectionPaths {
  const EmployeeCollectionPaths._();

  /// Sub-collection name under the tenant root.
  ///
  /// The two backup names contain spaces. That is preserved deliberately —
  /// these are live collection names and renaming them is a data migration,
  /// not a refactor.
  static const String _mainName = 'Employees_Info';
  static const String _backupOneName = 'Employees Backup One';
  static const String _backupTwoName = 'Employees Backup Two';

  static bool get _isTenantScoped => ApiConstants.baseUri.isNotEmpty;

  /// `Demo/{companyId}/Employees_Info` when tenant-scoped, else the bare name.
  static String get main =>
      _isTenantScoped ? '${ApiConstants.baseUri}/$_mainName' : ApiConstants.employeeInfo;

  static String get backupOne => _isTenantScoped
      ? '${ApiConstants.baseUri}/$_backupOneName'
      : ApiConstants.employeesProfileBackUpOne;

  static String get backupTwo => _isTenantScoped
      ? '${ApiConstants.baseUri}/$_backupTwoName'
      : ApiConstants.employeesProfileBackUpTwo;
}
