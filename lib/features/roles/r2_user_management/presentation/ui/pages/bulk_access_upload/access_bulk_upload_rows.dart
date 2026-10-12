/// Module: roles / r2_user_management / presentation / ui / pages / bulk_access_upload
///
///*************************** FILE INFO ****************************///
/// File Name: access_bulk_upload_rows.dart
/// Purpose: The editable rows of the User Management import review screen and
///          their validation against the live employee list, the role list
///          and the current access roster.
/// Author: Knowticed Plus team
/// Created At: 21/9/2026 — see access_bulk_upload_parser.dart.
///
/// Errors are stored as [AccessBulkError] codes, not strings: this class has no
/// BuildContext, and the review page turns each code into an English or Arabic
/// message.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_parser.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

/// Editable cells. The two derived columns (Current Role Type, Status) have no
/// field — they are computed from the others.
enum AccessBulkField { employeeId, email, desiredRole, accessGranted, accessRevoked }

enum AccessBulkError {
  identityRequired,
  employeeNotFound,
  emailNotFound,
  emailDoesNotMatchId,
  ownAccess,
  duplicateEmployee,
  roleRequired,
  roleNotFound,
  dateRequired,
  dateInvalid,
  datePast,
  revokedBeforeGranted,
}

/// One review row: text controllers for the identity cells, a resolved role
/// and two dates. [rawRole] / [rawGranted] / [rawRevoked] keep what the file
/// said, so an unmatched value can be shown back to the user as a hint.
class AccessBulkRowForm {
  AccessBulkRowForm({
    String employeeId = '',
    String email = '',
    this.rawRole = '',
    this.rawGranted = '',
    this.rawRevoked = '',
    this.desiredRole,
    this.accessGranted,
    this.accessRevoked,
  })  : employeeIdController = TextEditingController(text: employeeId),
        emailController = TextEditingController(text: email);

  factory AccessBulkRowForm.fromRaw(AccessBulkRawRow raw) => AccessBulkRowForm(
        employeeId: raw.employeeId,
        email: raw.email,
        rawRole: raw.desiredRole,
        rawGranted: raw.accessGranted,
        rawRevoked: raw.accessRevoked,
        accessGranted: parseAccessDate(raw.accessGranted),
        accessRevoked: parseAccessDate(raw.accessRevoked),
      );

  final TextEditingController employeeIdController;
  final TextEditingController emailController;
  final GlobalKey key = GlobalKey();
  final Map<AccessBulkField, FocusNode> focusNodes = <AccessBulkField, FocusNode>{
    for (final AccessBulkField f in AccessBulkField.values) f: FocusNode(),
  };

  final String rawRole;
  final String rawGranted;
  final String rawRevoked;

  /// `currentRoleName` of the matched role — the value `updateUserPermission`
  /// takes as `accessName`, same as the Edit dialog.
  String? desiredRole;
  DateTime? accessGranted;
  DateTime? accessRevoked;

  /// Filled by validation.
  EmployeeEntityPro? employee;
  UserPermissionEntity? currentAccess;
  final Map<AccessBulkField, AccessBulkError> errors = <AccessBulkField, AccessBulkError>{};

  AccessBulkRowForm copy() => AccessBulkRowForm(
        employeeId: employeeIdController.text,
        email: emailController.text,
        rawRole: rawRole,
        rawGranted: rawGranted,
        rawRevoked: rawRevoked,
        desiredRole: desiredRole,
        accessGranted: accessGranted,
        accessRevoked: accessRevoked,
      );

  void dispose() {
    employeeIdController.dispose();
    emailController.dispose();
    for (final FocusNode node in focusNodes.values) {
      node.dispose();
    }
  }
}

class AccessBulkUploadRows {
  AccessBulkUploadRows(
    List<AccessBulkRawRow> rawRows, {
    required this.employees,
    required this.roles,
    required this.currentAccessByEmployeeId,
    required this.currentUserEmail,
  }) : rows = rawRows.map(AccessBulkRowForm.fromRaw).toList() {
    for (final AccessBulkRowForm row in rows) {
      row.desiredRole = matchRole(row.rawRole)?.currentRoleName;
    }
    revalidateAll();
  }

  final List<AccessBulkRowForm> rows;
  final Set<int> selectedRows = <int>{};
  final List<EmployeeEntityPro> employees;

  /// ACTIVE roles only — the same list the Add New Access dropdown offers.
  final List<RoleHistoryModel> roles;
  final Map<String, UserPermissionEntity> currentAccessByEmployeeId;
  final String? currentUserEmail;

  /// Matches a file value to a role by English name, Arabic name or id.
  RoleHistoryModel? matchRole(String value) {
    final String v = value.trim().toLowerCase();
    if (v.isEmpty) return null;
    for (final RoleHistoryModel role in roles) {
      if (role.currentRoleName.trim().toLowerCase() == v ||
          role.currentRoleNameAr.trim().toLowerCase() == v ||
          role.roleId.trim().toLowerCase() == v) {
        return role;
      }
    }
    return null;
  }

  void revalidateAll() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    for (final AccessBulkRowForm row in rows) {
      row.errors.clear();
      row.employee = null;
      row.currentAccess = null;
      _validateIdentity(row);
      _validateRole(row);
      _validateDates(row, today);
    }
    _flagDuplicateEmployees();
  }

  void _validateIdentity(AccessBulkRowForm row) {
    final String id = row.employeeIdController.text.trim();
    final String email = row.emailController.text.trim().toLowerCase();

    if (id.isEmpty && email.isEmpty) {
      row.errors[AccessBulkField.employeeId] = AccessBulkError.identityRequired;
      return;
    }

    EmployeeEntityPro? byId;
    if (id.isNotEmpty) {
      byId = employees.where((EmployeeEntityPro e) => e.id == id).firstOrNull;
      if (byId == null) {
        row.errors[AccessBulkField.employeeId] = AccessBulkError.employeeNotFound;
      }
    }

    EmployeeEntityPro? byEmail;
    if (email.isNotEmpty) {
      byEmail = employees
          .where((EmployeeEntityPro e) => (e.email ?? '').toLowerCase() == email)
          .firstOrNull;
      if (byEmail == null) {
        row.errors[AccessBulkField.email] = AccessBulkError.emailNotFound;
      } else if (byId != null && byId.id != byEmail.id) {
        row.errors[AccessBulkField.email] = AccessBulkError.emailDoesNotMatchId;
      }
    }

    if (row.errors.containsKey(AccessBulkField.employeeId) ||
        row.errors.containsKey(AccessBulkField.email)) {
      return;
    }

    final EmployeeEntityPro employee = (byId ?? byEmail)!;
    // Same exclusion as the Add New Access list: nobody edits their own access.
    if ((employee.email ?? '').toLowerCase() ==
        (currentUserEmail ?? '').toLowerCase()) {
      row.errors[id.isNotEmpty ? AccessBulkField.employeeId : AccessBulkField.email] =
          AccessBulkError.ownAccess;
      return;
    }

    row.employee = employee;
    row.currentAccess = currentAccessByEmployeeId[employee.id];
  }

  void _validateRole(AccessBulkRowForm row) {
    if (row.desiredRole != null && matchRole(row.desiredRole!) != null) return;
    row.errors[AccessBulkField.desiredRole] = row.rawRole.trim().isEmpty
        ? AccessBulkError.roleRequired
        : AccessBulkError.roleNotFound;
  }

  void _validateDates(AccessBulkRowForm row, DateTime today) {
    AccessBulkError? check(DateTime? value, String raw) {
      if (value != null) return null;
      return raw.trim().isEmpty
          ? AccessBulkError.dateRequired
          : AccessBulkError.dateInvalid;
    }

    final AccessBulkError? grantedError = check(row.accessGranted, row.rawGranted);
    if (grantedError != null) {
      row.errors[AccessBulkField.accessGranted] = grantedError;
    } else if (row.accessGranted!.isBefore(today)) {
      // Same floor as the Add New Access date picker: no back-dated grants.
      row.errors[AccessBulkField.accessGranted] = AccessBulkError.datePast;
    }

    final AccessBulkError? revokedError = check(row.accessRevoked, row.rawRevoked);
    if (revokedError != null) {
      row.errors[AccessBulkField.accessRevoked] = revokedError;
    } else if (row.accessGranted != null &&
        !row.accessRevoked!.isAfter(row.accessGranted!)) {
      row.errors[AccessBulkField.accessRevoked] =
          AccessBulkError.revokedBeforeGranted;
    }
  }

  /// One employee, one row: two rows for the same person would race each
  /// other through `updateUserPermission` and the last write would win.
  void _flagDuplicateEmployees() {
    final Map<String, List<AccessBulkRowForm>> groups =
        <String, List<AccessBulkRowForm>>{};
    for (final AccessBulkRowForm row in rows) {
      final String? id = row.employee?.id;
      if (id == null) continue;
      groups.putIfAbsent(id, () => <AccessBulkRowForm>[]).add(row);
    }
    for (final List<AccessBulkRowForm> group in groups.values) {
      if (group.length < 2) continue;
      for (final AccessBulkRowForm row in group) {
        row.errors[AccessBulkField.employeeId] = AccessBulkError.duplicateEmployee;
      }
    }
  }

  void toggleSelected(int index) {
    if (!selectedRows.remove(index)) selectedRows.add(index);
  }

  void addBlankRow() {
    rows.add(AccessBulkRowForm());
    revalidateAll();
  }

  bool removeSelected() {
    if (selectedRows.isEmpty) return false;
    final List<int> descending = selectedRows.toList()..sort((a, b) => b.compareTo(a));
    for (final int index in descending) {
      rows[index].dispose();
      rows.removeAt(index);
    }
    selectedRows.clear();
    revalidateAll();
    return true;
  }

  bool duplicateSelected() {
    if (selectedRows.length != 1) return false;
    rows.add(rows[selectedRows.first].copy());
    selectedRows.clear();
    revalidateAll();
    return true;
  }

  void removeAt(int index) {
    rows[index].dispose();
    rows.removeAt(index);
    selectedRows.clear();
    revalidateAll();
  }

  int get errorCount =>
      rows.fold<int>(0, (int sum, AccessBulkRowForm row) => sum + row.errors.length);

  List<(int, AccessBulkField)> get errorLocations => <(int, AccessBulkField)>[
        for (int i = 0; i < rows.length; i++)
          for (final AccessBulkField field in AccessBulkField.values)
            if (rows[i].errors.containsKey(field)) (i, field),
      ];

  bool get isValid => rows.isNotEmpty && errorCount == 0;

  void dispose() {
    for (final AccessBulkRowForm row in rows) {
      row.dispose();
    }
  }
}

/// Reads the date formats a sheet realistically carries: ISO (what the parser
/// writes for real date cells), the Figma "23-04-2024", "23/04/2024",
/// "23 Apr 2024", the app's own storage format "Apr 23, 2024", and a bare
/// Excel serial number (days since 1899-12-30). Returns a date-only value, or
/// null when nothing matches.
DateTime? parseAccessDate(String raw) {
  final String value = raw.trim();
  if (value.isEmpty) return null;

  DateTime? parsed = DateTime.tryParse(value);

  if (parsed == null) {
    for (final String pattern in <String>[
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'd-M-yyyy',
      'd/M/yyyy',
      'dd MMM yyyy',
      'MMM dd, yyyy',
      'MMM d, yyyy',
    ]) {
      try {
        parsed = DateFormat(pattern, 'en').parseStrict(value);
        break;
      } catch (_) {
        // try the next pattern
      }
    }
  }

  if (parsed == null) {
    final int? serial = int.tryParse(value);
    // 20000..80000 ≈ 1954..2119: a plausible date serial, not a stray number.
    if (serial != null && serial > 20000 && serial < 80000) {
      parsed = DateTime(1899, 12, 30).add(Duration(days: serial));
    }
  }

  return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
}

/// Only active roles can be granted — the Add New Access dropdown offers the
/// same set.
List<RoleHistoryModel> grantableRoles(List<RoleHistoryModel> roles) => roles
    .where((RoleHistoryModel r) =>
        r.currentStatus == RoleStatus.active && r.currentRoleName.isNotEmpty)
    .toList();
