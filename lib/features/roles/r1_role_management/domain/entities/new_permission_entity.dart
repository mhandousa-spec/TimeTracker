/// Module: roles / r1_role_management / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: new_permission_entity.dart
/// Purpose: Declares `UserPermissionHistoryModel`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_access_model.dart';

class UserPermissionHistoryModel {
  final String employeeId;
  final List<int> timestamps;
  final List<String> role;
  final List<String> fromDate;
  final List<String> toDate;
  final List<String> editBy;

  UserPermissionHistoryModel({
    required this.employeeId,
    required this.timestamps,
    required this.role,
    required this.fromDate,
    required this.toDate,
    required this.editBy,
  });

  // Constants for database keys
  static const String EMPLOYEE_ID = "Employee_Id";
  static const String TIMESTAMPS = "Timestamps";
  static const String ROLE = "Role";
  static const String FROM_DATE = "From_Date";
  static const String TO_DATE = "To_Date";
  static const String EDIT_BY = "Edit_By";

  // Helper getters for current (latest) values
  String get currentRole => role.isNotEmpty ? role.last : '';
  String get currentFromDate => fromDate.isNotEmpty ? fromDate.last : '';
  String get currentToDate => toDate.isNotEmpty ? toDate.last : '';
  String get currentEditBy => editBy.isNotEmpty ? editBy.last : '';
  int get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : DateTime.now().millisecondsSinceEpoch;

  // Get value at specific index
  String? getRoleAt(int index) => index < role.length ? role[index] : null;
  String? getFromDateAt(int index) => index < fromDate.length ? fromDate[index] : null;
  String? getToDateAt(int index) => index < toDate.length ? toDate[index] : null;
  String? getEditByAt(int index) => index < editBy.length ? editBy[index] : null;
  int? getTimestampAt(int index) => index < timestamps.length ? timestamps[index] : null;

  Map<String, dynamic> toMap() {
    return {
      EMPLOYEE_ID: employeeId,
      TIMESTAMPS: timestamps,
      ROLE: role,
      FROM_DATE: fromDate,
      TO_DATE: toDate,
      EDIT_BY: editBy,
    };
  }

  factory UserPermissionHistoryModel.fromMap(Map<String, dynamic> map) {
    try {

      return UserPermissionHistoryModel(
        employeeId: map[EMPLOYEE_ID] ?? '',
        timestamps: _parseIntList(map[TIMESTAMPS]),
        role: _parseStringList(map[ROLE]),
        fromDate: _parseStringList(map[FROM_DATE]),
        toDate: _parseStringList(map[TO_DATE]),
        editBy: _parseStringList(map[EDIT_BY]),
      );
    } catch (e, stack) {
      rethrow;
    }
  }

  static List<int> _parseIntList(dynamic value) {
    if (value == null) return [DateTime.now().millisecondsSinceEpoch];
    if (value is List) {
      return value.map((e) => e is int ? e : (e as num).toInt()).toList();
    }
    return [DateTime.now().millisecondsSinceEpoch];
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    return [value.toString()];
  }

  // Create new permission (index 0)
  factory UserPermissionHistoryModel.createNew({
    required String employeeId,
    required String role,
    required String fromDate,
    required String toDate,
    required String editBy,
  }) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    return UserPermissionHistoryModel(
      employeeId: employeeId,
      timestamps: [timestamp],
      role: [role],
      fromDate: [fromDate],
      toDate: [toDate],
      editBy: [editBy],
    );
  }

  // Update permission (add new index: 0,1,2...)
  UserPermissionHistoryModel copyWith({
    String? role,
    String? fromDate,
    String? toDate,
    String? editBy,
  }) {
    int newTimestamp = DateTime.now().millisecondsSinceEpoch;

    final result = UserPermissionHistoryModel(
      employeeId: employeeId,
      // Add new timestamp
      timestamps: List<int>.from(timestamps)..add(newTimestamp),
      // Add new role or repeat current
      role: List<String>.from(this.role)..add(role ?? currentRole),
      // Add new fromDate or repeat current
      fromDate: List<String>.from(this.fromDate)..add(fromDate ?? currentFromDate),
      // Add new toDate or repeat current
      toDate: List<String>.from(this.toDate)..add(toDate ?? currentToDate),
      // Add new editBy or repeat current
      editBy: List<String>.from(this.editBy)..add(editBy ?? currentEditBy),
    );

    return result;
  }

  // Convert from old UserPermissionModel (for migration)
  factory UserPermissionHistoryModel.fromOldModel(UserPermissionModel oldModel) {
    return UserPermissionHistoryModel(
      employeeId: oldModel.employeeId,
      timestamps: oldModel.role.timestamps.map((t) => t.millisecondsSinceEpoch).toList(),
      role: oldModel.role.values,
      fromDate: oldModel.fromDate.values,
      toDate: oldModel.toDate.values,
      editBy: oldModel.editBy.values,
    );
  }

  // Get history count
  int get historyCount => timestamps.length;

  // Get all history as list of maps
  List<Map<String, dynamic>> getHistory() {
    List<Map<String, dynamic>> history = [];
    for (int i = 0; i < timestamps.length; i++) {
      history.add({
        'index': i,
        'timestamp': timestamps[i],
        'role': getRoleAt(i),
        'fromDate': getFromDateAt(i),
        'toDate': getToDateAt(i),
        'editBy': getEditByAt(i),
      });
    }
    return history;
  }
}