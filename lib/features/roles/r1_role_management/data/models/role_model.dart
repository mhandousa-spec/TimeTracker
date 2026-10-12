// ignore_for_file: prefer_null_aware_operators

/// Module: roles / r1_role_management / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: role_model.dart
/// Purpose: Declares `RoleModel`, `RoleHistoryModel`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header; removed
///          the Firestore query (generateNextRoleId -> RoleRemoteDataSource)
///          and the 349 commented-out debug prints.
///
/// KNOWN DEBT (from the r1 code review, not yet closed):
/// - This file is ~1,000 LOC against a 200-LOC cap for models (§10). Splitting
///   it needs new files, which the current change set is not allowed to add.
/// - Four `try/catch` blocks remain (`currentEditBy`, `RoleHistoryModel.fromMap`,
///   `_sanitizeValue`, `_editByToJsonString`). §11.2 forbids try/catch in
///   `data/models/`; each wraps a `jsonEncode`/`jsonDecode` whose failure mode
///   is load-bearing, so they must move to the data source together with the
///   parsing they guard rather than simply be deleted.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/edit_by_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import './module_permission_model.dart';

class RoleModel {
  String? roleName;
  String? roleNameAr;
  String? roleDescription;
  String? roleDescriptionAr;
  String? roleImage;
  Timestamp? createdAt;
  String? createdBy;
  RoleStatus? status;
  EditBy? editBy;
  Map<ModulePermissionsSections, List<ModulePermissionsSectionsPermission>>?
  settingsPermissions;
  ModulePermissionModel? messageModule;
  ModulePermissionModel? taskModule;
  ModulePermissionModel? employeeModule;
  ModulePermissionModel? reqestModule;
  ModulePermissionModel? serviceModule;
  ModulePermissionModel? eventModule;
  ModulePermissionModel? noteModule;
  ModulePermissionModel? grcModule;
  ModulePermissionModel? formBuilderModule;
  ModulePermissionModel? databaseBuilderModule;
  ModulePermissionModel? dataGRCModule;
  ModulePermissionModel? knowledgeHubModule;
  ModulePermissionModel? trackingModule;
  ModulePermissionModel? inventoryModule;
  ModulePermissionModel? todoModule;
  ModulePermissionModel? roleModule;
  ModulePermissionModel? hrModule;
  ModulePermissionModel? notificationModule;
  ModulePermissionModel? crmModule;  // ✅ ADDED

  RoleModel({
    this.roleName,
    this.roleNameAr,
    this.roleImage,
    this.createdAt,
    this.createdBy,
    this.roleDescription,
    this.roleDescriptionAr,
    this.status,
    this.editBy,
    this.taskModule,
    this.employeeModule,
    this.messageModule,
    this.grcModule,
    this.reqestModule,
    this.serviceModule,
    this.eventModule,
    this.noteModule,
    this.formBuilderModule,
    this.databaseBuilderModule,
    this.dataGRCModule,
    this.knowledgeHubModule,
    this.inventoryModule,
    this.trackingModule,
    this.settingsPermissions,
    this.roleModule,
    this.todoModule,
    this.hrModule,
    this.notificationModule,
    this.crmModule,  // ✅ ADDED
  });

  static const String ACCESS_NAME_KEY = 'Access_Name';
  static const String ACCESS_NAME_AR_KEY = 'Access_Name_Ar';
  static const String ROLE_DESCRIPTION_KEY = 'Role_Description';
  static const String ROLE_DESCRIPTION_AR_KEY = 'Role_Description_Ar';
  static const String ACCESS_IMAGE_KEY = 'Access_Image';
  static const String CREATED_AT_KEY = 'Created_At';
  static const String CREATED_BY_KEY = 'Created_By';
  static const String EDIT_MESSAGE_KEY = 'Edit_Message';
  static const String DELETE_MESSAGE_KEY = 'Delete_Message';
  static const String REACTIONS_KEY = 'Reactions';
  static const String CREATE_MESSAGE_GROUPS_KEY = 'Create_Message_Groups';
  static const String EXPORT_CHAT_AS_EXCEL_KEY = 'Export_Chat_As_Excel';
  static const String TAKE_SCREENSHOT_KEY = 'Take_Screenshot';
  static const String KNOW_WHOS_ONLINE_KEY = 'Know_Whos_Online';
  static const String KNOW_LAST_SEEN_ACTIVE_KEY = 'Know_Last_Seen_Active';
  static const String BIOMETRICS_FOR_LOGIN_KEY = 'Biometrics_For_Login';
  static const String RESTRICTED_LOCATION = 'Restricted_Location';

  static const String COMPANY_INFORMATION_KEY = 'Company_Information';
  static const String ANIMATION = 'Animation';

  static const String LOCK_OUT_OF_GEOGRAPHICAL_BOUNDARIES_KEY =
      'Lock_Out_Of_Geographical_Boundaries';
  static const String SHARE_EMAILS_AND_SOCIAL_DATA_KEY =
      'Share_Emails_And_Social_Data';
  static const String SHARE_CELLPHONES_KEY = 'Share_Cellphones';
  static const String SHARE_SOCIAL_INFORMATION_KEY = 'Share_Social_Information';
  static const String BIO_KEY = 'Bio';
  static const String ACADEMIC_HISTORY_KEY = 'Academic_History';
  static const String CERTIFICATES_KEY = 'Certificates';
  static const String SKILLS_KEY = 'Skills';
  static const String HOBBIES_KEY = 'Hobbies';
  static const String ADD_EMPLOYEES_KEY = 'Add_Employees';
  static const String ONE_BY_ONE_KEY = 'One_By_One';
  static const String BULK_UPLOAD_VIA_EXCEL_SHEET_KEY =
      'Bulk_Upload_Via_Excel_Sheet';
  static const String VIEW_AND_SEARCH_EMPLOYEE_RECORDS_KEY =
      'View_And_Search_Employee_Records';
  static const String STATUS_KEY = 'Status';
  static const String EDIT_BY_KEY = 'Edit_By';
  static const String TASK_MODULE_KEY = 'Task_Module';
  static const String EMPLOYEE_MODULE_KEY = 'Employee_Module';
  static const String MESSAGE_MODULE_KEY = 'Message_Module';
  static const String GRC_MODULE_KEY = 'Grc_Module';
  static const String REQUEST_MODULE_KEY = 'Reqest_Module';
  static const String SERVICE_MODULE_KEY = 'Service_Module';
  static const String EVENT_MODULE_KEY = 'Event_Module';
  static const String NOTE_MODULE_KEY = 'Note_Module';
  static const String services_app_MODULE_KEY = 'services_app_Module';
  static const String DATABASE_BUILDER_MODULE_KEY = 'Database_Builder_Module';
  static const String DATA_GRC_MODULE_KEY = 'Data_GRC_Module';
  static const String KNOWLEDGE_HUB_MODULE_KEY = 'Knowledge_Hub_Module';
  static const String TRACKING_MODULE_KEY = 'Time_Tracking_Module';
  static const String INVENTORY_MODULE_KEY = 'Inventory_Module';
  static const String TODO_MODULE_KEY = 'Todo_Module';
  static const String ROLE_MODULE_KEY = 'Role_Module';
  static const String HR_MODULE_KEY = 'HR_Module';
  static const String NOTIFICATION_MODULE_KEY = 'Notification_Module';
  static const String CRM_MODULE_KEY = 'CRM_Module';  // ✅ ADDED

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      ACCESS_NAME_KEY: roleName,
      ACCESS_NAME_AR_KEY: roleNameAr,
      ACCESS_IMAGE_KEY: roleImage,
      ROLE_DESCRIPTION_KEY: roleDescription,
      ROLE_DESCRIPTION_AR_KEY: roleDescriptionAr,
      CREATED_AT_KEY: createdAt,
      CREATED_BY_KEY: createdBy,
      STATUS_KEY: status?.name,
      EDIT_BY_KEY: editBy != null ? editBy!.toMap() : null,
      TASK_MODULE_KEY: taskModule != null ? taskModule!.toMap() : null,
      EMPLOYEE_MODULE_KEY:
      employeeModule != null ? employeeModule!.toMap() : null,
      MESSAGE_MODULE_KEY: messageModule != null ? messageModule!.toMap() : null,
      REQUEST_MODULE_KEY: reqestModule != null ? reqestModule!.toMap() : null,
      SERVICE_MODULE_KEY: serviceModule != null ? serviceModule!.toMap() : null,
      EVENT_MODULE_KEY: eventModule != null ? eventModule!.toMap() : null,
      NOTE_MODULE_KEY: noteModule != null ? noteModule!.toMap() : null,
      services_app_MODULE_KEY:
      formBuilderModule != null ? formBuilderModule!.toMap() : null,
      DATABASE_BUILDER_MODULE_KEY:
      databaseBuilderModule != null ? databaseBuilderModule!.toMap() : null,

      DATA_GRC_MODULE_KEY:
      dataGRCModule != null ? dataGRCModule!.toMap() : null,
      KNOWLEDGE_HUB_MODULE_KEY:
      knowledgeHubModule != null ? knowledgeHubModule!.toMap() : null,
      TRACKING_MODULE_KEY:
      trackingModule != null ? trackingModule!.toMap() : null,
      INVENTORY_MODULE_KEY:
      inventoryModule != null ? inventoryModule!.toMap() : null,
      TODO_MODULE_KEY: todoModule != null ? todoModule!.toMap() : null,
      ROLE_MODULE_KEY: roleModule != null ? roleModule!.toMap() : null,
      GRC_MODULE_KEY: grcModule != null ? grcModule!.toMap() : null,
      HR_MODULE_KEY: hrModule != null ? hrModule!.toMap() : null,
      NOTIFICATION_MODULE_KEY: notificationModule != null ? notificationModule!.toMap() : null,
      CRM_MODULE_KEY: crmModule != null ? crmModule!.toMap() : null,  // ✅ ADDED
    };
       // "setting permissions: ${settingsPermissions?.map((key, value) => MapEntry(key.getName, value.map((e) => e.getDataBaseName).toList()))}");
    map.addAll(settingsPermissions?.map((key, value) => MapEntry(
        key.getName, value.map((e) => e.getDataBaseName).toList())) ??
        {});
    return map;
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      roleName: map[ACCESS_NAME_KEY],
      roleNameAr: map[ACCESS_NAME_AR_KEY],
      roleImage: map[ACCESS_IMAGE_KEY],
      createdAt: _getCreatedAt(map[CREATED_AT_KEY]),
      createdBy: map[CREATED_BY_KEY],
      status: RoleStatus.values.firstWhere(
            (e) => e.name == map[STATUS_KEY],
        orElse: () => RoleStatus.active,
      ),
      roleDescription: map[ROLE_DESCRIPTION_KEY],
      roleDescriptionAr: map[ROLE_DESCRIPTION_AR_KEY],
      editBy:
      map[EDIT_BY_KEY] != null ? EditBy.fromMap(map[EDIT_BY_KEY]) : null,
      roleModule: map[ROLE_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[ROLE_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[ROLE_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[ROLE_MODULE_KEY], []),
      )
          : null,
      taskModule: map[TASK_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[TASK_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[TASK_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[TASK_MODULE_KEY], []),
      )
          : null,
      employeeModule: map[EMPLOYEE_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[EMPLOYEE_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[EMPLOYEE_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[EMPLOYEE_MODULE_KEY], []),
      )
          : null,
      messageModule: map[MESSAGE_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[MESSAGE_MODULE_KEY],
        constructedAdminSections: _getAdminSections(map[MESSAGE_MODULE_KEY], []),
        constructedSectionsPermissions: _getSectionsPermissions(map[MESSAGE_MODULE_KEY], []),
      )
          : null,
      reqestModule: map[REQUEST_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[REQUEST_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[REQUEST_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[REQUEST_MODULE_KEY], []),
      )
          : null,
      serviceModule: map[SERVICE_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[SERVICE_MODULE_KEY],
        constructedAdminSections: _getAdminSections(
            map[SERVICE_MODULE_KEY], ServicePermissionsSections.values),
        constructedSectionsPermissions: _getSectionsPermissions(
            map[SERVICE_MODULE_KEY], ServicePermissionsSections.values),
      )
          : null,
      eventModule: map[EVENT_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[EVENT_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[EVENT_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[EVENT_MODULE_KEY], []),
      )
          : null,
      noteModule: map[NOTE_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[NOTE_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[NOTE_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[NOTE_MODULE_KEY], []),
      )
          : null,
      formBuilderModule: map[services_app_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[services_app_MODULE_KEY],
        constructedAdminSections: _getAdminSections(
            map[services_app_MODULE_KEY], FormPermissionsSections.values),
        constructedSectionsPermissions: _getSectionsPermissions(
            map[services_app_MODULE_KEY], FormPermissionsSections.values),
      )
          : null,
      databaseBuilderModule: map[DATABASE_BUILDER_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[DATABASE_BUILDER_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[DATABASE_BUILDER_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[DATABASE_BUILDER_MODULE_KEY], []),
      )
          : null,
      dataGRCModule: map[DATA_GRC_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[DATA_GRC_MODULE_KEY],
        constructedAdminSections: _getAdminSections(map[DATA_GRC_MODULE_KEY], []),
        constructedSectionsPermissions: _getSectionsPermissions(map[DATA_GRC_MODULE_KEY], []),
      )
          : null,
      knowledgeHubModule: map[KNOWLEDGE_HUB_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[KNOWLEDGE_HUB_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[KNOWLEDGE_HUB_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[KNOWLEDGE_HUB_MODULE_KEY], []),
      )
          : null,
      trackingModule: map[TRACKING_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[TRACKING_MODULE_KEY],
        constructedAdminSections:
        _getAdminSections(map[TRACKING_MODULE_KEY], []),
        constructedSectionsPermissions:
        _getSectionsPermissions(map[TRACKING_MODULE_KEY], []),
      )
          : null,
      inventoryModule: map[INVENTORY_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[INVENTORY_MODULE_KEY],
        constructedAdminSections: _getAdminSections(map[INVENTORY_MODULE_KEY], []),
        constructedSectionsPermissions: _getSectionsPermissions(map[INVENTORY_MODULE_KEY], []),
      )
          : null,
      hrModule: map[HR_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[HR_MODULE_KEY],
        constructedAdminSections: _getAdminSections(map[HR_MODULE_KEY], []),
        constructedSectionsPermissions: _getSectionsPermissions(map[HR_MODULE_KEY], []),
      )
          : null,
      crmModule: map[CRM_MODULE_KEY] != null  // ✅ ADDED
          ? ModulePermissionModel.fromMap(
        map[CRM_MODULE_KEY],
        constructedAdminSections: _getAdminSections(map[CRM_MODULE_KEY], []),
        constructedSectionsPermissions: _getSectionsPermissions(map[CRM_MODULE_KEY], []),
      )
          : null,
      notificationModule: map[NOTIFICATION_MODULE_KEY] != null
          ? ModulePermissionModel.fromMap(
        map[NOTIFICATION_MODULE_KEY],
        constructedAdminSections: _getAdminSections(map[NOTIFICATION_MODULE_KEY], []),
        constructedSectionsPermissions: _getSectionsPermissions(map[NOTIFICATION_MODULE_KEY], []),
      )
          : null,
      settingsPermissions: getSettingsPermissions(map),
    );
  }

  String toJson() => json.encode(toMap());

  factory RoleModel.fromJson(String source) =>
      RoleModel.fromMap(json.decode(source));

  /// Reads `Created_At`, which is a [Timestamp] on new documents and a
  /// `"Jan 29, 2025"` string on legacy ones.
  ///
  /// Was a `try { … as Timestamp } catch { … parse(…) }` — a type test does the
  /// same job without try/catch, which §11.2 forbids in `data/models/`.
  static _getCreatedAt(dynamic createdAt) {
    if (createdAt is Timestamp) return createdAt;

    /// string format jan 29, 2025
    return Timestamp.fromDate(DateFormat('MMM d, yyyy').parse(createdAt));
  }

  static _getAdminSections(
      Map<String, dynamic> map, List<ModulePermissionsSections> sections) {
    List<ModulePermissionsSections> adminSections = [];
    sections.forEach((element) {
      if (map[ModulePermissionModel.adminSectionsKey] != null &&
          map[ModulePermissionModel.adminSectionsKey]
              .contains(element.getName)) {
        adminSections.add(element);
      }
    });
    return adminSections;
  }

  static _getSectionsPermissions(
      Map<String, dynamic> map, List<ModulePermissionsSections> sections) {
    Map<ModulePermissionsSections, List<ModulePermissionsSectionsPermission>>
    allowedSections = {};
    for (ModulePermissionsSections section in sections) {
      if (map.containsKey(section.getName)) {
        allowedSections[section] = [];
        for (Enum subSection in section.sectionPermissions) {
          if (map[section.getName] != null &&
              map[section.getName].contains(
                  (subSection as ModulePermissionsSectionsPermission)
                      .getDataBaseName)) {
            allowedSections[section]!
                .add((subSection as ModulePermissionsSectionsPermission));
          }
        }
      }
    }
    return allowedSections;
  }

  static Map<SettingsPermissionsSections,
      List<ModulePermissionsSectionsPermission>>
  getSettingsPermissions(Map<String, dynamic> map) {
    Map<SettingsPermissionsSections, List<ModulePermissionsSectionsPermission>>
    allowedSections = {};
    for (SettingsPermissionsSections section
    in SettingsPermissionsSections.values) {
      if (map.containsKey(section.getName)) {
        allowedSections[section] = [];
        for (Enum permission in section.sectionPermissions) {
          if (map[section.getName] != null &&
              map[section.getName].contains(
                  (permission as ModulePermissionsSectionsPermission)
                      .getDataBaseName)) {
            allowedSections[section]!
                .add(((permission as ModulePermissionsSectionsPermission)));
          }
        }
      }
    }
    return allowedSections;
  }
}

class RoleHistoryModel {
  final String roleId;
  final List<int> timestamps;
  final List<String> roleName;
  final List<String> roleNameAr;
  final List<String> roleDescription;
  final List<String> roleDescriptionAr;
  final List<String> roleImage;
  final List<Timestamp> createdAt;
  final List<String> createdBy;
  final List<String> status;
  final List<List<String>> selectedModules;
  final List<String> editBy;

  RoleHistoryModel({
    required this.roleId,
    required this.timestamps,
    required this.roleName,
    required this.roleNameAr,
    required this.roleDescription,
    required this.roleDescriptionAr,
    required this.roleImage,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    required this.selectedModules,
    required this.editBy,
  });

  // Constants for database keys
  static const String ROLE_ID_KEY = 'Role_Id';
  static const String ACCESS_NAME_KEY = 'Role_Name';
  static const String ACCESS_NAME_KEY_ALT = 'Name';
  static const String ACCESS_NAME_KEY_ALT2 = 'Access_Name';
  static const String ACCESS_NAME_AR_KEY = 'Role_Name_Ar';
  static const String ACCESS_NAME_AR_KEY_ALT = 'Name_Ar';
  static const String ACCESS_NAME_AR_KEY_ALT2 = 'Access_Name_Ar';
  static const String ROLE_DESCRIPTION_KEY = 'Role_Description';
  static const String ROLE_DESCRIPTION_KEY_ALT = 'Description';
  static const String ROLE_DESCRIPTION_AR_KEY = 'Role_Description_Ar';
  static const String ROLE_DESCRIPTION_AR_KEY_ALT = 'Description_Ar';
  static const String ACCESS_IMAGE_KEY = 'Role_Image';
  static const String ACCESS_IMAGE_KEY_ALT = 'Image_Url';
  static const String ACCESS_IMAGE_KEY_ALT2 = 'Access_Image';
  static const String CREATED_AT_KEY = 'Created_At';
  static const String CREATED_BY_KEY = 'Created_By';
  static const String STATUS_KEY = 'Status';
  static const String SELECTED_MODULES_KEY = 'Selected_Modules';
  static const String SELECTED_MODULES_KEY_ALT = 'selectedModules'; // ← ADD THIS
  static const String EDIT_BY_KEY = 'Edit_By';
  static const String TIMESTAMPS_KEY = 'timestamps';

  // Helper getters for current (latest) values
  String get currentRoleName => roleName.isNotEmpty ? roleName.last : '';
  String get currentRoleNameAr => roleNameAr.isNotEmpty ? roleNameAr.last : '';
  String get currentRoleDescription => roleDescription.isNotEmpty ? roleDescription.last : '';
  String get currentRoleDescriptionAr => roleDescriptionAr.isNotEmpty ? roleDescriptionAr.last : '';
  String get currentRoleImage => roleImage.isNotEmpty ? roleImage.last : '';
  Timestamp get currentCreatedAt => createdAt.isNotEmpty ? createdAt.last : Timestamp.now();
  String get currentCreatedBy => createdBy.isNotEmpty ? createdBy.last : '';
  RoleStatus get currentStatus => status.isNotEmpty ?
  RoleStatus.values.firstWhere((e) => e.name == status.last, orElse: () => RoleStatus.active) :
  RoleStatus.active;
  List<String> get currentSelectedModules => selectedModules.isNotEmpty ? selectedModules.last : [];
  EditBy? get currentEditBy {
    if (editBy.isEmpty) return null;
    try {
      String editByString = editBy.last;
      Map<String, dynamic> data;

      if (editByString.startsWith('{') && editByString.endsWith('}')) {
        data = jsonDecode(editByString);
      } else {
        return null;
      }

      return EditBy.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  int? getTimestampAt(int index) => index < timestamps.length ? timestamps[index] : null;
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  RoleModel toLegacyRoleModel() {
    return RoleModel(
      roleName: currentRoleName.isNotEmpty ? currentRoleName : null,
      roleNameAr: currentRoleNameAr.isNotEmpty ? currentRoleNameAr : null,
      roleDescription: currentRoleDescription.isNotEmpty ? currentRoleDescription : null,
      roleDescriptionAr: currentRoleDescriptionAr.isNotEmpty ? currentRoleDescriptionAr : null,
      roleImage: currentRoleImage.isNotEmpty ? currentRoleImage : null,
      createdAt: currentCreatedAt,
      createdBy: currentCreatedBy.isNotEmpty ? currentCreatedBy : null,
      status: currentStatus,
      editBy: currentEditBy,
    );
  }

  // CRITICAL: Updated fromMap to read old module structure
  factory RoleHistoryModel.fromMap(Map<String, dynamic> map) {
    try {

      final List<int> sharedTimestamps = (map[TIMESTAMPS_KEY] as List<dynamic>?)
          ?.map((e) => e is int ? e : (e as num).toInt()).toList()
          ?? [DateTime.now().millisecondsSinceEpoch];

      // Parse role name with multiple fallbacks
      var roleNameData = map[ACCESS_NAME_KEY] ??
          map[ACCESS_NAME_KEY_ALT] ??
          map[ACCESS_NAME_KEY_ALT2] ??
          map['roleName'];

      if (roleNameData == null ||
          (roleNameData is List && roleNameData.isEmpty) ||
          (roleNameData is String && roleNameData.isEmpty)) {
        String? docId = map['_documentId'];
        if (docId != null && docId.isNotEmpty) {
          roleNameData = [docId];
        }
      }

      var roleNameArData = map[ACCESS_NAME_AR_KEY] ??
          map[ACCESS_NAME_AR_KEY_ALT] ??
          map[ACCESS_NAME_AR_KEY_ALT2];
      var roleDescData = map[ROLE_DESCRIPTION_KEY] ?? map[ROLE_DESCRIPTION_KEY_ALT];
      var roleDescArData = map[ROLE_DESCRIPTION_AR_KEY] ?? map[ROLE_DESCRIPTION_AR_KEY_ALT];
      var roleImageData = map[ACCESS_IMAGE_KEY] ??
          map[ACCESS_IMAGE_KEY_ALT] ??
          map[ACCESS_IMAGE_KEY_ALT2];

      // ✅ CRITICAL FIX: Handle Selected_Modules OR selectedModules (both naming conventions)

      // ✅ CHECK BOTH: Selected_Modules (Roles) AND selectedModules (Subscription_Admin)
      var selectedModulesData = map[SELECTED_MODULES_KEY] ?? map[SELECTED_MODULES_KEY_ALT];

      List<List<String>> parsedSelectedModules;

      if (selectedModulesData == null) {
        List<String> modulesFromOldStructure = _extractModulesFromOldStructure(map);
        parsedSelectedModules = [modulesFromOldStructure];
      } else {

        if (selectedModulesData is List) {
          if ((selectedModulesData as List).isNotEmpty) {
          }
        }

        parsedSelectedModules = _parseSelectedModulesList(selectedModulesData);

        if (parsedSelectedModules.isNotEmpty) {
        }
      }

      var parsedRoleName = _parseListSafely(roleNameData);

      return RoleHistoryModel(
        roleId: map[ROLE_ID_KEY] ?? map['_documentId'] ?? '',
        timestamps: sharedTimestamps,
        roleName: parsedRoleName,
        roleNameAr: _parseListSafely(roleNameArData),
        roleDescription: _parseListSafely(roleDescData),
        roleDescriptionAr: _parseListSafely(roleDescArData),
        roleImage: _parseListSafely(roleImageData),
        createdAt: _parseTimestampList(map[CREATED_AT_KEY]),
        createdBy: _parseListSafely(map[CREATED_BY_KEY]),
        status: _parseListSafely(map[STATUS_KEY]),
        selectedModules: parsedSelectedModules,
        editBy: _parseEditByList(map[EDIT_BY_KEY]),
      );
    } catch (e, stack) {
      rethrow;
    }
  }

  // NEW: Extract modules from old structure
  static List<String> _extractModulesFromOldStructure(Map<String, dynamic> map) {
    List<String> modules = [];

    // Map of old field names to new module names
    Map<String, String> oldToNewModuleMap = {
      'Service_Module': 'services',
      'Employee_Module': 'employees',
      'Task_Module': 'tasks',
      'Todo_Module': 'todo',
      'Event_Module': 'events',
      'Note_Module': 'notes',
      'Request_Module': 'requests',
      'Reqest_Module': 'requests',  // Typo in old structure
      'Knowledge_Hub_Module': 'knowledge_hub',
      'Data_GRC_Module': 'qiyas',  // Keep this for backward compatibility
      'Grc_Module': 'grc',  // ✅ ADD THIS - New GRC module
      'Time_Tracking_Module': 'tracking',  // ✅ This should work now
      'Inventory_Module': 'inventory',
      'Message_Module': 'messages',
      'Database_Builder_Module': 'database_builder',
      'services_app_Module': 'services_app',
      'Role_Module': 'roles',
      'HR_Module': 'hr',
      'CRM_Module': 'crm',
      'Notification_Module': 'notification',
    };

    // Check each old field and add if it exists and is granted
    oldToNewModuleMap.forEach((oldKey, newModuleName) {
      if (map.containsKey(oldKey)) {
        var moduleData = map[oldKey];

        // Check if module is granted (exists and has granted: true)
        bool isGranted = false;

        if (moduleData is Map) {
          isGranted = moduleData['granted'] == true || moduleData['Granted'] == true;
        } else if (moduleData != null) {
          // If it exists and is not null, consider it granted
          isGranted = true;
        }

        if (isGranted) {
          modules.add(newModuleName);
        }
      }
    });

    // Always include settings
    if (!modules.contains('settings')) {
      modules.add('settings');
    }

    return modules;
  }

  static List<String> _parseListSafely(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    return [value.toString()];
  }

  static List<Timestamp> _parseTimestampList(dynamic value) {
    if (value == null) return [Timestamp.now()];
    if (value is List) {
      return value.map((e) {
        if (e is Timestamp) return e;
        if (e is int) return Timestamp.fromMillisecondsSinceEpoch(e);
        if (e is Map && e.containsKey('_seconds')) {
          return Timestamp(e['_seconds'], e['_nanoseconds'] ?? 0);
        }
        return Timestamp.now();
      }).toList();
    }
    if (value is int) return [Timestamp.fromMillisecondsSinceEpoch(value)];
    return [Timestamp.now()];
  }

  static List<String> _parseEditByList(dynamic value) {
    if (value == null) return [jsonEncode({'editorEmail': [], 'timestamps': []})];
    if (value is List) {
      return value.map((e) => _convertToJsonString(e)).toList();
    }
    return [_convertToJsonString(value)];
  }

  // static List<List<String>> _parseSelectedModulesList(dynamic value) {
  //   if (value == null) return [[]];
  //
  //   // CRITICAL FIX: Handle both nested and flat arrays
  //   if (value is List) {
  //     if (value.isEmpty) return [[]];
  //
  //     // Check if it's already a nested array
  //     if (value.first is List) {
  //       return value.map((e) => List<String>.from(e)).toList();
  //     }
  //
  //     // If it's a flat array, wrap it in another array for history tracking
  //     return [List<String>.from(value)];
  //   }
  //
  //   return [[]];
  // }

  static List<List<String>> _parseSelectedModulesList(dynamic value) {

    if (value == null) {
      return [[]];
    }

    if (value is List) {

      if (value.isEmpty) {
        return [[]];
      }

      // ✅ Case 1: Nested array (Roles collection - history format)
      if (value.first is List) {

        List<List<String>> result = value.map((e) {
          if (e is List) {
            return List<String>.from(e);
          }
          return <String>[];
        }).toList();

        return result;
      }

      // ✅ Case 2: Flat array of strings (Subscription_Admin format)
      if (value.first is String) {

        List<String> modules = List<String>.from(value);

        // ✅ CRITICAL: Wrap in array for history tracking
        List<List<String>> result = [modules];
        return result;
      }

      // // ✅ Fallback for unexpected types
      return [[]];
    }

    // Not a list at all
    return [[]];
  }

  static String _convertToJsonString(dynamic value) {
    if (value == null) return '{}';

    if (value is String) {
      if (value.trim().startsWith('{') && value.trim().endsWith('}')) {
        return value;
      }
      return '{}';
    }

    if (value is Map<String, dynamic>) {
      try {
        return jsonEncode(_sanitizeMapForFirebase(value));
      } catch (e) {
        return '{}';
      }
    }

    return '{}';
  }

  static Map<String, dynamic> _sanitizeMapForFirebase(Map<String, dynamic> map) {
    Map<String, dynamic> result = {};

    map.forEach((key, value) {
      if (value is Timestamp) {
        result[key] = value.millisecondsSinceEpoch;
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Timestamp) return item.millisecondsSinceEpoch;
          if (item is Map<String, dynamic>) return _sanitizeMapForFirebase(item);
          return item;
        }).toList();
      } else if (value is Map<String, dynamic>) {
        result[key] = _sanitizeMapForFirebase(value);
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  // ✅ FIXED: toMap now uses primary keys (Name, Name_Ar, Image_Url)
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      ROLE_ID_KEY: roleId,
      TIMESTAMPS_KEY: timestamps,

      // ✅ CHANGED: Use ACCESS_NAME_KEY_ALT instead of ACCESS_NAME_KEY_ALT2
      // This maps to 'Name' instead of 'Access_Name'
      ACCESS_NAME_KEY_ALT: roleName,

      // ✅ CHANGED: Use ACCESS_NAME_AR_KEY_ALT instead of ACCESS_NAME_AR_KEY_ALT2
      // This maps to 'Name_Ar' instead of 'Access_Name_Ar'
      ACCESS_NAME_AR_KEY_ALT: roleNameAr,

      ROLE_DESCRIPTION_KEY: roleDescription,
      ROLE_DESCRIPTION_AR_KEY: roleDescriptionAr,

      // ✅ CHANGED: Use ACCESS_IMAGE_KEY_ALT instead of ACCESS_IMAGE_KEY_ALT2
      // This maps to 'Image_Url' instead of 'Access_Image'
      ACCESS_IMAGE_KEY_ALT: roleImage,

      CREATED_AT_KEY: createdAt.map((t) => t.millisecondsSinceEpoch).toList(),
      CREATED_BY_KEY: createdBy,
      STATUS_KEY: status,
      // ✅ FIX: Use only the current (last) value to avoid nested arrays
      SELECTED_MODULES_KEY: selectedModules.isNotEmpty ? selectedModules.last : [],
      EDIT_BY_KEY: editBy,
    };

    return map;
  }

  String toJson() => json.encode(toMap());

  factory RoleHistoryModel.fromJson(String source) =>
      RoleHistoryModel.fromMap(json.decode(source));

  // ✅✅✅ FIXED: copyWith method that ALWAYS synchronizes ALL fields
  RoleHistoryModel copyWith({
    String? roleName,
    String? roleNameAr,
    String? roleDescription,
    String? roleDescriptionAr,
    String? roleImage,
    Timestamp? createdAt,
    String? createdBy,
    String? status,
    List<String>? selectedModules,
    EditBy? editBy,
  }) {

    // Add new timestamp for this update
    final newTimestamps = List<int>.from(timestamps)
      ..add(DateTime.now().millisecondsSinceEpoch);

    // ✅ CRITICAL: ALL fields get updated - edited values OR current values repeated
    final result = RoleHistoryModel(
      roleId: roleId,
      timestamps: newTimestamps,

      // ✅ Role Name: append provided value OR repeat current value
      roleName: List<String>.from(this.roleName)
        ..add(roleName ?? currentRoleName),

      // ✅ Role Name Ar: append provided value OR repeat current value
      roleNameAr: List<String>.from(this.roleNameAr)
        ..add(roleNameAr ?? currentRoleNameAr),

      // ✅ Role Description: append provided value OR repeat current value
      roleDescription: List<String>.from(this.roleDescription)
        ..add(roleDescription ?? currentRoleDescription),

      // ✅ Role Description Ar: append provided value OR repeat current value
      roleDescriptionAr: List<String>.from(this.roleDescriptionAr)
        ..add(roleDescriptionAr ?? currentRoleDescriptionAr),

      // ✅ Role Image: append provided value OR repeat current value
      roleImage: List<String>.from(this.roleImage)
        ..add(roleImage ?? currentRoleImage),

      // ✅ Created At: append provided value OR repeat current value
      createdAt: List<Timestamp>.from(this.createdAt)
        ..add(createdAt ?? currentCreatedAt),

      // ✅ Created By: append provided value OR repeat current value
      createdBy: List<String>.from(this.createdBy)
        ..add(createdBy ?? currentCreatedBy),

      // ✅ Status: append provided value OR repeat current value
      status: List<String>.from(this.status)
        ..add(status ?? currentStatus.name),

      // ✅ Selected Modules: append provided value OR repeat current value
      selectedModules: List<List<String>>.from(this.selectedModules)
        ..add(selectedModules ?? currentSelectedModules),

      // ✅ Edit By: append provided value OR repeat current value
      editBy: List<String>.from(this.editBy)
        ..add(editBy != null
            ? _editByToJsonString(editBy)
            : (this.editBy.isNotEmpty
            ? this.editBy.last
            : jsonEncode({'Editor_Email': [], 'Timestamp': []}))),
    );

    return result;
  }

  static String _editByToJsonString(EditBy editBy) {
    try {
      // Convert the EditBy map to a Firebase-safe format
      Map<String, dynamic> editByMap = editBy.toMap();
      Map<String, dynamic> safeMap = _sanitizeMapForFirebase(editByMap);
      return jsonEncode(safeMap);
    } catch (e) {
      return jsonEncode({'Editor_Email': [], 'Timestamp': []});
    }
  }

  factory RoleHistoryModel.createNew({
    required String roleId,
    String roleName = '',
    String roleNameAr = '',
    String roleDescription = '',
    String roleDescriptionAr = '',
    String roleImage = '',
    Timestamp? createdAt,
    String createdBy = '',
    RoleStatus status = RoleStatus.active,
    List<String> selectedModules = const [],
    EditBy? editBy,
  }) {
    return RoleHistoryModel(
      roleId: roleId,
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleName: [roleName],
      roleNameAr: [roleNameAr],
      roleDescription: [roleDescription],
      roleDescriptionAr: [roleDescriptionAr],
      roleImage: [roleImage],
      createdAt: [createdAt ?? Timestamp.now()],
      createdBy: [createdBy],
      status: [status.name],
      selectedModules: [selectedModules],
      editBy: [editBy != null ? _editByToJsonString(editBy) : jsonEncode({'Editor_Email': [], 'Timestamp': []})],
    );
  }

  // MOVED 12/8/2026 -> RoleRemoteDataSource.generateNextRoleId.
  // This ran a Firestore query (and two try/catch blocks) from inside a
  // data model. Models are pure data (§10/§11.2); network access belongs to
  // the data source. Callers: RoleRepository.addNewRole and
  // ActiveDirectoryRepository._createAccessType.


}
