/// Module: roles / r2_user_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_controller.dart
/// Purpose: Declares `UserManagementController`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/controller_request_current_state.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/usecases/update_selected_members_use_case.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';


import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/usecases/delete_user_permission_use_case.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/usecases/update_user_permission_use_case.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:collection/collection.dart';

part './user_management_controller_state.dart';

/// App-wide shared UserManagementController instance.
///
/// Mirrors the existing `roleCubit` / `userManagementCubit` pattern so callers
/// don't depend on GetX registration order (the old `Get.find<EmployeeRoleController>()`
/// in RoleScreen.initState could run before `Get.put` had happened).
UserManagementController userManagementController = UserManagementController();

class UserManagementController extends Cubit<UserManagementControllerState> {
  UserManagementController() : super(UserManagementControllerInitial());

  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(UserManagementControllerState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Plain mirror of the request state (was an Rx field under GetX).
  ControllerRequestCurrentState requestCurrentState =
      ControllerRequestCurrentState.none;
  List<UserPermissionEntity> usersPermissionEntity = [];
  List<UserPermissionEntity> filteredUsersPermissionEntity = [];
  UserManagementAccessRepository userRoleRepository =
  UserManagementAccessRepository();
  List<NewEmployeeModelHistory> employeesNotHaveCurrentPermission = [];
  List<NewEmployeeModelHistory> employeesNotHaveCurrentPermissionFiltered = [];
  Map<String, NewEmployeeModelHistory> selectedMembersIds = {};

  // Store RoleCubit reference (will be set from outside)
  RoleCubit? _roleCubit;

  // ───────────────────────────────────────────────────────────────────────
  // REQUEST-DETAILS PRESENTATION LOGIC
  //
  // Moved out of umdr_methods1.dart (user_mangement_details_request page) so
  // that part file only builds widgets. Everything here is pure — no context,
  // no setState — which is why only these helpers moved; the rest of that file
  // drives widget state or shows dialogs and stays in the UI layer.
  // ───────────────────────────────────────────────────────────────────────

  /// Maps an incoming request field name onto the employee-model field path.
  String mapFieldName(String requestFieldName) {
    const fieldMappings = {
      'first_name': 'firstName',
      'middle_name': 'middleName',
      'last_name': 'lastName',
      'first_name_arabic': 'firstNameInArabic',
      'middle_name_arabic': 'middleNameInArabic',
      'last_name_arabic': 'lastNameInArabic',
      'email': 'email',
      'gender': 'gender',
      'date_of_birth': 'birthDay',
      'marital_status': 'maritalStatus',
      'street': 'street',
      'city': 'city',
      'province': 'province',
      'country': 'country',
      'postalCode': 'postalCode',
      'postal_code': 'postalCode',
      'phone': 'mobilePhone.phones',
      'Phone': 'mobilePhone.phones',
      'country_code': 'mobilePhone.countryCode',
      'Country_Code': 'mobilePhone.countryCode',
      'country_app': 'mobilePhone.countryApp',
      'Country_App': 'mobilePhone.countryApp',
      'insuranceName': 'insuranceName',
      'insurance_name': 'insuranceName',
      'Insurance_Name': 'insuranceName',
      'insurancePolicyNumber': 'insurancePolicyNumber',
      'insurance_policy_number': 'insurancePolicyNumber',
      'Insurance_Policy_Number': 'insurancePolicyNumber',
      'firstContactFirstName': 'firstContactFirstName',
      'firstContactLastName': 'firstContactLastName',
      'firstContactRelationship': 'firstContactRelationship',
      'firstContactEmail': 'firstContactEmail',
      'firstContactPhone': 'firstContactPhone',
      'secondContactFirstName': 'secondContactFirstName',
      'secondContactLastName': 'secondContactLastName',
      'secondContactRelationship': 'secondContactRelationship',
      'secondContactEmail': 'secondContactEmail',
      'secondContact_email': 'secondContactEmail',
      'secondContactPhone': 'secondContactPhone',
      // Address / language for both emergency contacts. These were missing,
      // so approving a request that touched them fell through to the raw key
      // and NewEmployeeModelHistory threw "Unknown field: secondContact_province".
      'firstContactLanguage': 'firstContactLanguage',
      'firstContactCountry': 'firstContactCountry',
      'firstContactProvince': 'firstContactProvince',
      'firstContactCity': 'firstContactCity',
      'firstContactStreet': 'firstContactStreet',
      'secondContactLanguage': 'secondContactLanguage',
      'secondContactCountry': 'secondContactCountry',
      'secondContactProvince': 'secondContactProvince',
      'secondContactCity': 'secondContactCity',
      'secondContactStreet': 'secondContactStreet',
    };

    final direct = fieldMappings[requestFieldName];
    if (direct != null) return direct;

    // The health-insurance screens write snake_case variants
    // (secondContact_province), the model uses camelCase
    // (secondContactProvince). Fold one into the other rather than listing
    // every spelling twice.
    final camel = _snakeToCamel(requestFieldName);
    return fieldMappings[camel] ?? camel;
  }

  /// `secondContact_province` → `secondContactProvince`.
  /// Leaves an already-camelCase key untouched.
  String _snakeToCamel(String value) {
    if (!value.contains('_')) return value;

    final parts = value.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return value;

    return parts.first +
        parts
            .skip(1)
            .map((p) => p[0].toUpperCase() + p.substring(1))
            .join();
  }

  /// Renders date-like values as `dd MMM yyyy`; other values pass through.
  String formatValueForDisplay(String value, String fieldName) {
    final bool isDateField = fieldName.toLowerCase().contains('date') ||
        fieldName.toLowerCase().contains('birth') ||
        fieldName.toLowerCase().contains('_of_');

    if (!isDateField) return value;

    try {
      DateTime? dateTime;
      if (value.contains('T')) {
        dateTime = DateTime.tryParse(value);
      } else if (value.contains('-') && value.split('-').length == 3) {
        dateTime = DateTime.tryParse(value);
      } else if (value.contains('/')) {
        final List<String> parts = value.split('/');
        if (parts.length == 3) {
          int month = int.tryParse(parts[0]) ?? 0;
          int day = int.tryParse(parts[1]) ?? 0;
          int year = int.tryParse(parts[2]) ?? 0;
          if (year < 100) year += (year <= 30) ? 2000 : 1900;
          if (month > 0 && day > 0 && year > 0) {
            dateTime = DateTime(year, month, day);
          }
        }
      } else if (int.tryParse(value) != null) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
      }
      if (dateTime != null) return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {}

    return value;
  }

  /// Arabic translation for the fixed request section headings.
  ///
  /// [isArabic] is passed in: this is a cubit, so it has no BuildContext, and
  /// the previous `Get.locale` read is banned. The calling widget reads the
  /// locale from `Localizations` and hands it over.
  String translateSectionTitle(String englishTitle, {required bool isArabic}) {
    if (!isArabic) return englishTitle;
    switch (englishTitle) {
      case 'Personal Information':
        return 'المعلومات الشخصية';
      case 'Emergency Contact':
        return 'جهة الاتصال في حالات الطوارئ';
      case 'Health Insurance':
        return 'التأمين الصحي';
      default:
        return englishTitle;
    }
  }

  String formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Folds the two spellings of cancelled the app writes into one key.
  String normalizeStatus(String status) {
    final value = status.toLowerCase().trim();
    return value == 'canceled' ? 'cancelled' : value;
  }

  Color getStatusColor(String status) {
    switch (normalizeStatus(status)) {
      case 'approved':
        return AppColors.statusApproved;
      case 'pending':
        return AppColors.statusPending;
      case 'rejected':
        // The duplicate 'rejected' case that used to sit here was dead code —
        // Dart takes the first match.
        return AppColors.red;
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.secondaryText;
    }
  }

  String getStatusIcon(String status) {
    switch (normalizeStatus(status)) {
      case 'approved':
        return 'assets/icons_assets/main_icons_assets/approve_icon.svg';
      case 'pending':
        return 'assets/icons_assets/main_icons_assets/status_pending_hourglass_orange.svg';
      case 'rejected':
        return 'assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg';
      case 'cancelled':
        return 'assets/icons_assets/main_icons_assets/status_cancelled_stamp_red.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg';
    }
  }

  /// Humanises a raw field key, e.g. `first_name` -> `First Name`.
  String formatFieldName(String fieldKey) {
    return fieldKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  // ───────────────────────────────────────────────────────────────────────
  // BULK-UPLOAD ERROR NAVIGATION
  //
  // Moved out of upload_methods2.dart. The upload page still owns the widget
  // state (controllers, focus nodes, scroll position), so only the pure
  // computations live here — the caller assigns the results.
  // ───────────────────────────────────────────────────────────────────────

  /// Flattens per-row validation errors into an ordered (row, column) list.
  List<MapEntry<int, String>> buildErrorLocations(
      List<Map<String, String>> validationErrors) {
    final List<MapEntry<int, String>> locations = [];
    for (int row = 0; row < validationErrors.length; row++) {
      validationErrors[row].forEach((header, _) {
        locations.add(MapEntry(row, header));
      });
    }
    return locations;
  }

  /// Keeps the highlighted-error cursor inside range.
  ///
  /// Returns -1 when there are no errors to point at.
  int normalizeErrorIndex(int currentIndex, int totalErrors) {
    if (totalErrors == 0) return -1;
    if (currentIndex >= totalErrors || currentIndex < 0) return 0;
    return currentIndex;
  }

  /// Next error index, wrapping around in either direction.
  int nextErrorIndex(int currentIndex, int totalErrors, bool forward) {
    if (totalErrors == 0) return -1;
    return forward
        ? (currentIndex + 1) % totalErrors
        : (currentIndex - 1 + totalErrors) % totalErrors;
  }

  /// Method Name: [setRoleCubit]
  ///
  /// Purpose: Set the RoleCubit instance to avoid GetX dependency
  void setRoleCubit(RoleCubit roleCubit) {
    _roleCubit = roleCubit;
  }

  /// Method Name : [getUsersPermissionsData]
  ///
  /// Purpose : This method is used to get all users permissions data from the database.
  getUsersPermissionsData() async {
    requestCurrentState = ControllerRequestCurrentState.loading;
    emitSafely(UserManagementControllerLoading());
    filteredUsersPermissionEntity = [];
    Either<Failure, dynamic> result =
    await userRoleRepository.getUsersPermissionsData();
    if (result.isLeft()) {
      requestCurrentState = ControllerRequestCurrentState.error;
      emitSafely(UserManagementControllerError(
          result.fold((l) => l.errMessage, (r) => 'Unknown error')));
      return;
    }
    if (result.isRight()) {
      usersPermissionEntity = result.getOrElse(() => []);
      filterUsersPermissionEntity(searchText: "");
      requestCurrentState = ControllerRequestCurrentState.loaded;
      emitSafely(UserManagementControllerLoaded());
      return;
    }

    emitSafely(UserManagementMembersUpdated());
  }

  /// Method Name : filterUsersPermissionEntity
  ///
  /// Parameters :
  ///             searchText : String
  ///
  /// Purpose : This method is used to filter the users permissions data based on the search text.
  filterUsersPermissionEntity({required String searchText}) {
    filteredUsersPermissionEntity = [];
    String currentRoleName = _getCurrentRoleName();

    filteredUsersPermissionEntity = usersPermissionEntity.where((element) {
      // Filter by role name if selected
      if (currentRoleName.isNotEmpty && currentRoleName != element.accessName) {
        return false;
      }

      // Filter by search text
      if (searchText.isEmpty) return true;

      String searchLower = searchText.toLowerCase();
      return element.accessName?.toLowerCase().contains(searchLower) == true ||
          element.englishName.toLowerCase().contains(searchLower) ||
          element.arabicName.toLowerCase().contains(searchLower);
    }).toList();

    emitSafely(UserManagementMembersUpdated());
  }

  /// Method Name : [delete]
  ///
  /// Parameters :
  ///             permission : [UserPermissionEntity]
  ///
  /// Purpose : This method is used to delete the user permission from the database.
  delete(UserPermissionEntity permission) async {
    String currentUserEmail =
    AppControllers.employeeDirectory.employee!.email!.last!;
    String employeeEmail = AppControllers.employeeDirectory
        .getEmployeeEmailFromId(permission.employeeEmail);
    Either<Failure, dynamic> result =
    await DeleteUserPermissionUseCase(userRoleRepository).execute(
        employeeEmail: employeeEmail,
        permission: permission,
        currentUserEmail: currentUserEmail);
    if (result.isRight()) _updateLocalData(permission);
  }

  /// Method Name : [_updateLocalData]
  ///
  /// Parameters :
  ///            permission : [UserPermissionEntity]
  ///
  /// Purpose : This method is used to update the local data after deleting the user permission.
  _updateLocalData(UserPermissionEntity permission) {
    usersPermissionEntity.remove(permission);
    NewEmployeeModelHistory? employee = AppControllers.employeeDirectory
        .allEmployees
        ?.firstWhereOrNull((element) => element.id == permission.employeeEmail);

    if (employee != null) {
      employee.role?.add(Constants.removedEmployeePermission);
      employee.timestamps?.add(DateTime.now().millisecondsSinceEpoch);
    }
    emitSafely(UserManagementMembersUpdated());
  }

  /// Method Name: [updateUserPermission]
  ///
  /// Purpose: Update user permission with new access details
  updateUserPermission({
    required String? employeeId,
    required String accessName,
    String? startDate,
    required String endDate,
  }) async {
    accessName = accessName.toLowerCase();
    UserPermissionEntity? permission = usersPermissionEntity
        .firstWhereOrNull((element) => element.employeeEmail == employeeId);

    if (permission == null) {
      return;
    }

    // NEW: Use the updated signature with named parameters
    Either<Failure, dynamic> result =
    await UpdateUserPermissionUseCase(userRoleRepository).execute(
      employeeId: permission.employeeId,
      currentUserEmail:
      AppControllers.employeeDirectory.employee!.email!.last!,
      accessName: (accessName != permission.accessName) ? accessName : null,
      accessBegin: (startDate != permission.startDate) ? startDate : null,
      accessEnd: (endDate != permission.endDate) ? endDate : null,
    );

    if (result.isRight()) {
      // Was `CustomDialogManager.showMessage(context: Get.context!, ...)`.
      // A cubit must not own a BuildContext or drive dialogs; it publishes the
      // outcome and the listening page decides how to present it.
      emitSafely(UserManagementPermissionSaved('The Access Has Been Edited Successfully'));
      getUsersPermissionsData();
    } else {
      // 9/10/2026 — a refusal (e.g. a user limit) was dropped silently.
      emitSafely(UserManagementControllerError(
          result.fold((Failure l) => l.errMessage, (_) => '')));
    }
  }

  List<NewEmployeeModelHistory> getEmployeesNotHaveCurrentPermission(
      String? accessName) {
    accessName = accessName?.toLowerCase();
    List<NewEmployeeModelHistory> employees = [];
    List<NewEmployeeModelHistory>? allEmployees =
        AppControllers.employeeDirectory.allEmployees;

    if (allEmployees == null) return employees;

    for (NewEmployeeModelHistory employee in allEmployees) {
      String? lastRole = employee.role?.lastOrNull;
      if ((lastRole == null ||
          lastRole == Constants.removedEmployeePermission) ||
          (lastRole != null && lastRole != accessName)) {
        employees.add(employee);
      }
    }
    return employees;
  }

  getFilteredEmployeesNotHavePermission(String? accessName, String searchText) {
    accessName = accessName?.toLowerCase();
    employeesNotHaveCurrentPermission =
        getEmployeesNotHaveCurrentPermission(accessName);
    employeesNotHaveCurrentPermissionFiltered = [];

    for (NewEmployeeModelHistory employee in employeesNotHaveCurrentPermission) {
      String searchLower = searchText.toLowerCase();
      bool matches = employee.firstName?.last
          ?.toLowerCase()
          .contains(searchLower) ==
          true ||
          employee.lastName?.last
              ?.toLowerCase()
              .contains(searchLower) ==
              true ||
          employee.email?.last?.toLowerCase().contains(searchLower) ==
              true;

      if (matches) {
        employeesNotHaveCurrentPermissionFiltered.add(employee);
      }
    }
  }

  selectMember(NewEmployeeModelHistory employee) {
    if (selectedMembersIds.containsKey(employee.id)) {
      selectedMembersIds.remove(employee.id);
    } else {
      selectedMembersIds[employee.id!] = employee;
    }
    emitSafely(UserManagementMembersUpdated());
  }

  /// Method Name: [addNewUsersPermissions]
  ///
  /// Purpose: Add permissions for multiple selected users
  addNewUsersPermissions({
    required String accessName,
    required String startDate,
    required String endDate,
  }) async {
    accessName = accessName.toLowerCase();
    if (selectedMembersIds.isEmpty || startDate.isEmpty || endDate.isEmpty) {
      return;
    }

    // Convert selected members to EmployeeEntity list
    List<EmployeeEntityPro> selectedEmployeeEntities = selectedMembersIds.values
        .map((employee) => EmployeeEntityPro(
      id: employee.id,
      email: employee.email?.last,
      firstName: employee.firstName?.last,
      lastName: employee.lastName?.last,
      // Add other required fields as needed
    ))
        .toList();

    Either<Failure, dynamic> result =
    await UpdateSelectedMembersUseCase(userRoleRepository).execute(
      currentUserEmail:
      AppControllers.employeeDirectory.employee!.email!.last!,
      accessName: accessName,
      startDate: startDate,
      endDate: endDate,
      selectedMembers: selectedEmployeeEntities,
    );

    if (result.isRight()) {
      // Was `CustomDialogManager.showMessage(context: Get.context!, ...)`.
      // A cubit must not own a BuildContext or drive dialogs; it publishes the
      // outcome and the listening page decides how to present it.
      emitSafely(UserManagementPermissionSaved('The Access Has Been Created Successfully'));
      getUsersPermissionsData();
      selectedMembersIds.clear();
    } else {
      // 9/10/2026 — a refusal (e.g. a user limit) was dropped silently.
      emitSafely(UserManagementControllerError(
          result.fold((Failure l) => l.errMessage, (_) => '')));
    }
  }

  /// Method Name: [getUserPermissionHistory]
  ///
  /// Purpose: Get the permission history for a specific user
  Future<List<Map<String, dynamic>>> getUserPermissionHistory(
      String userId) async {
    return await userRoleRepository.getUserPermissionHistory(userId);
  }

  /// Method Name: [getRoleAssignmentStats]
  ///
  /// Purpose: Get statistics about role assignments
  Map<String, dynamic> getRoleAssignmentStats() {
    Map<String, int> roleCount = {};
    Map<String, List<UserPermissionEntity>> roleUsers = {};

    for (UserPermissionEntity user in usersPermissionEntity) {
      String roleName = user.accessName ?? 'Unknown';
      roleCount[roleName] = (roleCount[roleName] ?? 0) + 1;
      roleUsers[roleName] = (roleUsers[roleName] ?? [])..add(user);
    }

    return {
      'totalUsers': usersPermissionEntity.length,
      'roleDistribution': roleCount,
      'roleUsers': roleUsers,
      'mostCommonRole': roleCount.isNotEmpty
          ? roleCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'None',
    };
  }

  /// Method Name: [getExpiringPermissions]
  ///
  /// Purpose: Get permissions that are expiring within specified days
  ///
  /// FIXED 12/8/2026: this parsed `user.endDate` with `DateTime.parse`, which
  /// only accepts ISO-8601. Dates are persisted with
  /// `DateFormat(Constants.userAccessDateFormat)` = "MMM dd, yyyy", so every
  /// call threw, the local catch swallowed it and the method always returned an
  /// empty list — the expiry surfacing never fired once. It now uses the same
  /// tolerant parser the repository uses to read these fields.
  List<UserPermissionEntity> getExpiringPermissions({int days = 30}) {
    final DateTime now = DateTime.now();
    final DateTime cutoffDate = now.add(Duration(days: days));

    return usersPermissionEntity.where((user) {
      final DateTime? endDate =
          userRoleRepository.parseAccessDate(user.endDate, label: 'end');
      if (endDate == null) return false;
      return endDate.isBefore(cutoffDate) && endDate.isAfter(now);
    }).toList();
  }

  /// Method Name: [bulkAssignRole]
  ///
  /// Purpose: Assign role to multiple employees at once
  Future<void> bulkAssignRole({
    required List<String> employeeIds,
    required String roleName,
    required String startDate,
    required String endDate,
  }) async {
    List<NewEmployeeModelHistory>? allEmployees =
        AppControllers.employeeDirectory.allEmployees;

    if (allEmployees == null) {
      return;
    }

    for (String employeeId in employeeIds) {
      NewEmployeeModelHistory? employee =
      allEmployees.firstWhereOrNull((emp) => emp.id == employeeId);
      if (employee != null) {
        selectedMembersIds[employeeId] = employee;
      }
    }

    await addNewUsersPermissions(
      accessName: roleName,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Method Name: [validatePermissionDates]
  ///
  /// Purpose: Validate permission start and end dates
  ///
  /// FIXED 12/8/2026: same `DateTime.parse` vs "MMM dd, yyyy" mismatch as
  /// [getExpiringPermissions] — this returned `false` for every date pair the
  /// app itself had written, so the validation was permanently dead.
  bool validatePermissionDates(String startDate, String endDate) {
    final DateTime? start =
        userRoleRepository.parseAccessDate(startDate, label: 'start');
    final DateTime? end =
        userRoleRepository.parseAccessDate(endDate, label: 'end');
    if (start == null || end == null) return false;

    return start.isBefore(end) && end.isAfter(DateTime.now());
  }

  /// Method Name: [searchUsersByRole]
  ///
  /// Purpose: Search users by specific role
  List<UserPermissionEntity> searchUsersByRole(String roleName) {
    return usersPermissionEntity
        .where((user) =>
    user.accessName?.toLowerCase() == roleName.toLowerCase())
        .toList();
  }

  /// Method Name: [exportPermissionData]
  ///
  /// Purpose: Export permission data for reporting
  List<Map<String, dynamic>> exportPermissionData() {
    return usersPermissionEntity
        .map((user) => {
      'employeeId': user.employeeId,
      'employeeEmail': user.employeeEmail,
      'englishName': user.englishName,
      'arabicName': user.arabicName,
      'accessName': user.accessName,
      'startDate': user.startDate,
      'endDate': user.endDate,
      'grantorEnglishName': user.grantorEnglishName,
      'grantorArabicName': user.grantorArabicName,
      'departmentId': user.departmentId,
      'jobTitle': user.englishJobTitle,
    })
        .toList();
  }

  /// Method Name: [getPermissionAuditTrail]
  ///
  /// Purpose: Get audit trail for permission changes
  Future<List<Map<String, dynamic>>> getPermissionAuditTrail({
    String? userId,
    String? roleName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (userId != null) {
      return await getUserPermissionHistory(userId);
    }
    return [];
  }

  /// Method Name: [checkRoleConflicts]
  ///
  /// Purpose: Check for role assignment conflicts
  List<String> checkRoleConflicts(String employeeId, String newRole) {
    List<String> conflicts = [];

    // Check if user already has this role
    UserPermissionEntity? existingPermission = usersPermissionEntity
        .firstWhereOrNull((user) => user.employeeId == employeeId);

    if (existingPermission != null &&
        existingPermission.accessName == newRole) {
      conflicts.add('User already has this role assigned');
    }

    // Add more conflict checks as needed
    // Example: Check for mutually exclusive roles_module

    return conflicts;
  }

  /// Method Name: [getActiveRoles]
  ///
  /// Purpose: Get list of all active roles_module
  List<String> getActiveRoles() {
    Set<String> roles = {};
    for (UserPermissionEntity user in usersPermissionEntity) {
      if (user.accessName != null) {
        roles.add(user.accessName!);
      }
    }
    return roles.toList()..sort();
  }

  /// Method Name: [getRoleFromHistory]
  ///
  /// Purpose: Get role details from RoleHistoryModel
  Map<String, dynamic>? getRoleFromHistory(String roleName) {
    if (_roleCubit == null) {
      return null;
    }

    RoleHistoryModel? role = _roleCubit!.roles.firstWhereOrNull(
            (r) => r.currentRoleName.toLowerCase() == roleName.toLowerCase());

    if (role == null) return null;

    return {
      'roleName': role.currentRoleName,
      'roleNameAr': role.currentRoleNameAr,
      'roleDescription': role.currentRoleDescription,
      'roleDescriptionAr': role.currentRoleDescriptionAr,
      'roleImage': role.currentRoleImage,
      'status': role.currentStatus.name,
      'createdAt': role.currentCreatedAt,
      'createdBy': role.currentCreatedBy,
      'modules': role.currentSelectedModules,
    };
  }

  /// Method Name: [getUsersByRoleHistory]
  ///
  /// Purpose: Get users assigned to a specific role from history
  List<UserPermissionEntity> getUsersByRoleHistory(
      RoleHistoryModel roleHistory) {
    return usersPermissionEntity
        .where((user) =>
    user.accessName?.toLowerCase() ==
        roleHistory.currentRoleName.toLowerCase())
        .toList();
  }

  /// Method Name: [getRoleChangeHistory]
  ///
  /// Purpose: Get role change history for a specific employee
  Future<List<Map<String, dynamic>>> getRoleChangeHistory(
      String employeeId) async {
    return await getUserPermissionHistory(employeeId);
  }

  /// Method Name: [compareRolePermissions]
  ///
  /// Purpose: Compare permissions between two roles_module
  Map<String, dynamic> compareRolePermissions(
      String roleNameA, String roleNameB) {
    if (_roleCubit == null) {
      return {'error': 'RoleCubit not set'};
    }

    RoleHistoryModel? roleA = _roleCubit!.roles.firstWhereOrNull(
            (r) => r.currentRoleName.toLowerCase() == roleNameA.toLowerCase());
    RoleHistoryModel? roleB = _roleCubit!.roles.firstWhereOrNull(
            (r) => r.currentRoleName.toLowerCase() == roleNameB.toLowerCase());

    if (roleA == null || roleB == null) {
      return {'error': 'One or both roles_module not found'};
    }

    return {
      'roleA': roleA.currentRoleName,
      'roleB': roleB.currentRoleName,
      'roleAModules': _getGrantedModules(roleA),
      'roleBModules': _getGrantedModules(roleB),
    };
  }

  /// Helper method to get granted modules from RoleHistoryModel
  List<String> _getGrantedModules(RoleHistoryModel role) {
    return role.currentSelectedModules;
  }

  /// Helper method to safely get role name from selected role
  String _getCurrentRoleName() {
    if (_roleCubit == null) return '';
    if (_roleCubit!.selectedRole == null) return '';

    return _roleCubit!.selectedRole!.currentRoleName;
  }

  /// Method Name: [getAllRoleNames]
  ///
  /// Purpose: Get all available role names
  List<String> getAllRoleNames() {
    if (_roleCubit == null) return [];

    return _roleCubit!.roles
        .map((role) => role.currentRoleName)
        .where((name) => name.isNotEmpty)
        .toList()
      ..sort();
  }

  /// Method Name: [getRoleDetails]
  ///
  /// Purpose: Get detailed information about a role
  Map<String, dynamic>? getRoleDetails(String roleName) {
    if (_roleCubit == null) {
      return null;
    }

    RoleHistoryModel? role = _roleCubit!.roles.firstWhereOrNull(
            (r) => r.currentRoleName.toLowerCase() == roleName.toLowerCase());

    if (role == null) return null;

    return {
      'roleName': role.currentRoleName,
      'roleNameAr': role.currentRoleNameAr,
      'description': role.currentRoleDescription,
      'descriptionAr': role.currentRoleDescriptionAr,
      'image': role.currentRoleImage,
      'status': role.currentStatus.name,
      'createdBy': role.currentCreatedBy,
      'createdAt': role.currentCreatedAt.toDate(),
      'grantedModules': _getGrantedModules(role),
      'userCount': searchUsersByRole(roleName).length,
    };
  }
}