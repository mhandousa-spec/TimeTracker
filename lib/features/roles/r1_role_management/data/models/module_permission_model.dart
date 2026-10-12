/// Module: roles / r1_role_management / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: module_permission_model.dart
/// Purpose: Declares `ModulePermissionModel`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

class ModulePermissionModel {
  bool? granted;
  List<String>? grantorEmail;
  List<Timestamp>? timestamps;
  bool isAdmin;
  List<ModulePermissionsSections> adminSections;
  Map<ModulePermissionsSections, List<ModulePermissionsSectionsPermission>>
      sectionsPermissions;

  ModulePermissionModel({
    this.granted,
    this.grantorEmail,
    this.timestamps,
    this.isAdmin = false,
    this.adminSections = const [],
    this.sectionsPermissions = const {},
  });

  static const String grantedKey = 'Granted';
  static const String grantorEmailKey = 'Grantor_Email';
  static const String timestampsKey = 'Timestamp';
  static const String isAdminKey = 'IsAdmin';
  static const String adminSectionsKey = 'Admin_Section';

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      grantedKey: granted,
      grantorEmailKey: grantorEmail,
      timestampsKey: timestamps,
      isAdminKey: isAdmin,
      adminSectionsKey: adminSections.map((e) => e.getName).toList(),
    };
    Map<String, dynamic> sectionPermissionKeys = {};
    sectionsPermissions.forEach((key, value) {
      sectionPermissionKeys[key.getName] =
          value.map((e) => e.getDataBaseName).toList();
    });
    map.addAll(sectionPermissionKeys);
    return map;
  }

  factory ModulePermissionModel.fromMap(Map<String, dynamic> map,
      {required List<ModulePermissionsSections> constructedAdminSections,
        required Map<ModulePermissionsSections,
            List<ModulePermissionsSectionsPermission>>
        constructedSectionsPermissions})
  {
    return ModulePermissionModel(
      granted: map[grantedKey] != null ? map[grantedKey] as bool : null,
      grantorEmail: map[grantorEmailKey] != null
          ? List<String>.from(map[grantorEmailKey])
          : null,
      timestamps: map[timestampsKey] != null
          ? _parseTimestampList(map[timestampsKey])
          : null,
      isAdmin: map[isAdminKey] != null ? map[isAdminKey] as bool : false,
      adminSections: constructedAdminSections,
      sectionsPermissions: constructedSectionsPermissions,
    );
  }

// Helper method to parse timestamp list (handles both Timestamp and int)
  static List<Timestamp> _parseTimestampList(dynamic value) {
    if (value is! List) return [];

    return value.map((item) {
      if (item is Timestamp) {
        return item;
      } else if (item is int) {
        return Timestamp.fromMillisecondsSinceEpoch(item);
      } else {
        return Timestamp.now(); // Fallback
      }
    }).toList();
  }

  // REMOVED 12/8/2026: `_parseTimestamp(dynamic)` — dead code; the list
  // variant `_parseTimestampList` is the one used by `fromMap`.
}
