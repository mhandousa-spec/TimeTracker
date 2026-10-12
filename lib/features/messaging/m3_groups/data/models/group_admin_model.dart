/// Module: messaging / groups / data/models/group_admin_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_admin_model.dart
/// Purpose: Group admin model — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupAdminsModel {
  Map<String, GroupAdminModel> adminData;
  GroupAdminsModel({
    required this.adminData,
  });

  static const String adminDataKey = 'Admin_Data';

  Map<String, dynamic> toMap() {
    return {
      adminDataKey: adminData.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory GroupAdminsModel.fromMap(Map<String, dynamic> map) {
    return GroupAdminsModel(
      adminData: (map[adminDataKey] as Map<String, dynamic>).map((key, value) =>
          MapEntry(
              key, GroupAdminModel.fromMap(value as Map<String, dynamic>))),
    );
  }
}

class GroupAdminModel {
  String adminId;
  List<bool> isAdmin;
  List<Timestamp> timestamps;

  GroupAdminModel({
    required this.adminId,
    required this.isAdmin,
    required this.timestamps,
  });

  static const String adminIdKey = 'Admin_Id';
  static const String isAdminKey = 'Is_Admin';
  static const String timestampsKey = 'Timestamps';

  Map<String, dynamic> toMap() {
    return {
      adminIdKey: adminId,
      isAdminKey: isAdmin,
      timestampsKey: timestamps,
    };
  }

  factory GroupAdminModel.fromMap(Map<String, dynamic> map) {
    return GroupAdminModel(
      adminId: map[adminIdKey] as String,
      isAdmin: List<bool>.from(map[isAdminKey] as List),
      timestamps: List<Timestamp>.from(map[timestampsKey] as List),
    );
  }
}
