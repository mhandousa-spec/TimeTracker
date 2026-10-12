/// Module: roles / r1_role_management / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: role_repository.dart
/// Purpose: Declares `RoleRepository`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/edit_by_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/data_source/remote_data_source/role_remote_data_source.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
// ADDED 25/8/2026 — see the NOTIFICATIONS section at the foot of this class.
import 'package:knowticed_plus/features/notification/data/repository/role_management_notification_service.dart';

class RoleRepository {
  final RoleRemoteDataSource remoteDataSource = RoleRemoteDataSource();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Collection names
  static const String ROLES_COLLECTION = 'Roles';
  static const String SUBSCRIPTION_ADMIN_COLLECTION = 'Subscription_Admin';
  static const String SUBSCRIPTION_PERMISSION_ADMIN_COLLECTION = 'Subscription_Permission_Admin';

  /// ADDED 28/9/2026 — the Restricted Location allow-list, one document per
  /// role (`{Role_Id, Countries: [ISO codes], Updated_At}`). Kept OUT of
  /// `settings_module_permissions` on purpose: every field there is a history
  /// of BOOLS (`updateModulePermissions` does `List<bool>.from(...)` on each),
  /// so a list of country codes stored beside them would break the next save.
  static const String ROLE_RESTRICTED_LOCATIONS = 'role_restricted_locations';

  // Regular employee permission collections
  static const String SERVICES_PERMISSIONS = 'services_module_permissions';
  static const String services_app_PERMISSIONS = 'services_app_module_permissions';
  static const String MESSAGES_PERMISSIONS = 'messages_module_permissions';
  static const String INVENTORY_PERMISSIONS = 'inventory_module_permissions';
  static const String SETTINGS_PERMISSIONS = 'settings_module_permissions';
  static const String QIYAS_PERMISSIONS = 'qiyas_module_permissions';
  static const String GRC_PERMISSIONS = 'grc_module_permissions';
  static const String KNOWLEDGE_HUB_PERMISSIONS = 'knowledge_hub_module_permissions';
  // CHANGED 9/10/2026 — was `roles_permissions`, the only collection off the
  // house pattern `<module>_module_permissions`. Knowticed Admin creates
  // `roles_module_permissions` (clients_repository.dart) and login_controller
  // already mapped 'roles' there, so the client was reading one collection
  // and Admin/login writing another. Data move: Documents/Settings Fixes/
  // migrations/migrate_roles_permissions.py (run by Moataz, dry-run first).
  static const String ROLES_PERMISSIONS = 'roles_module_permissions';
  static const String HR_PERMISSIONS = 'hr_module_permissions';
  static const String CRM_PERMISSIONS = 'crm_module_permissions';
  static const String NOTIFICATION_PERMISSIONS = 'notification_module_permissions';
  // ADDED 7/10/2026 — To-Do (personal module). Mirrors
  // `TodoFirestorePaths.rolePermissions`; section `To_Do_Permissions`.
  static const String TODO_PERMISSIONS = 'todo_module_permissions';
  // ADDED 8/10/2026 — Time Tracker. Mirrors
  // `TimeTrackerFirestorePaths.rolePermissions`.
  static const String TIME_TRACKER_PERMISSIONS =
      'time_tracker_module_permissions';

  // Helper method to get collection reference with base path
  CollectionReference _getCollection(String collectionName) {
    return firestore.collection(getBaseUrl(collectionName));
  }

  bool isCompanyAdminByEmail(String email) {
    try {
      // No BuildContext here and no caller able to pass one down, so this
      // goes through the documented DI seam rather than a raw Get.find.
      String? adminEmail =
          AppControllers.company.state.company?.email?.emails?.last;

      if (adminEmail == null || adminEmail.isEmpty) {
        return false;
      }

      bool isAdmin = (email.toLowerCase().trim() == adminEmail.toLowerCase().trim());
      return isAdmin;
    } catch (e) {
      return false;
    }
  }

  Future<Either<FirebaseFailure, Map<String, bool>>> getAdminRestrictionsForModule({
    required String companyId,
    required String moduleName,
  }) async {
    try {
      DocumentSnapshot demoPermDoc = await firestore
          .collection(FirebaseCollections.demoPermissions)
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        return Right({});
      }

      Map<String, dynamic> demoPermissions = demoPermDoc.data() as Map<String, dynamic>;

      if (!demoPermissions.containsKey(moduleName)) {
        return Right({});
      }

      if (demoPermissions[moduleName] is! Map) {
        return Right({});
      }

      Map<String, dynamic> modulePerms = Map<String, dynamic>.from(demoPermissions[moduleName]);
      Map<String, bool> restrictions = {};

      modulePerms.forEach((key, value) {
        if (key != 'Role_Id' && key != 'timestamps') {
          restrictions[key] = (value == true);
        }
      });

      return Right(restrictions);

    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, RoleHistoryModel?>> getAdminRole() async {
    try {
      String? currentUserEmail;
      try {
        // GetX is banned in this project; `AppControllers` is the single DI
        // seam that still knows about the service locator (§ standing rule).
        currentUserEmail = AppControllers.employee.employeeEntity?.email;

        if (currentUserEmail == null || currentUserEmail.isEmpty) {
          return Left(FirebaseFailure('Current user email not found'));
        }
      } catch (e) {
        return Left(FirebaseFailure('Cannot access employee controller'));
      }

      QuerySnapshot snapshot = await _getCollection(SUBSCRIPTION_ADMIN_COLLECTION)
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return Right(null);
      }

      Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
      data['_documentId'] = snapshot.docs.first.id;

      RoleHistoryModel role = RoleHistoryModel.fromMap(data);

      return Right(role);
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, Map<String, Map<String, bool>>>> getAdminPermissions(String roleId) async {
    try {
      DocumentSnapshot doc = await _getCollection(SUBSCRIPTION_PERMISSION_ADMIN_COLLECTION)
          .doc(roleId)
          .get();

      if (!doc.exists) {
        return Right({});
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, Map<String, bool>> adminPermissions = {};

      data.forEach((key, value) {
        if (key == 'companyId' ||
            key == 'roleId' ||
            key == 'createdAt' ||
            key == 'createdBy' ||
            key == 'timestamps') {
          return;
        }

        if (value is Map) {
          Map<String, bool> modulePerms = {};
          (value as Map).forEach((permKey, permValue) {
            modulePerms[permKey.toString()] = permValue == true;
          });
          adminPermissions[key] = modulePerms;
        }
      });

      return Right(adminPermissions);
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, Map<String, Map<String, bool>>>> validatePermissionsAgainstAdmin({
    required Map<String, Map<String, bool>> requestedPermissions,
    required String companyId,
  }) async {
    try {
      DocumentSnapshot demoPermDoc = await firestore
          .collection(FirebaseCollections.demoPermissions)
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        // SECURITY (default-deny): this used to `return Right(requestedPermissions)`
        // — a missing admin-permission document granted every permission the
        // caller asked for. Failing closed here surfaces the misconfiguration
        // instead of silently persisting elevated permissions.
        return Left(FirebaseFailure(
          'Permission template for this company is unavailable, so the role '
          'cannot be validated. No changes were saved.',
        ));
      }

      Map<String, dynamic> demoPermissions = demoPermDoc.data() as Map<String, dynamic>;

      // 9/10/2026 — the capping loop moved, unchanged, into the pure
      // [capToCompanyCeiling] so role creation's
      // Subscription_Permission_Admin document can be unit-tested.
      return Right(capToCompanyCeiling(
        requestedPermissions: requestedPermissions,
        demoPermissions: demoPermissions,
      ));

    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name: [capToCompanyCeiling]
  ///
  /// Purpose: Cap a role's requested switches by the company ceiling
  ///          (`Demo_Permissions/{cid}`) — the pure half of
  ///          [validatePermissionsAgainstAdmin] (extracted 9/10/2026).
  ///
  /// A switch stays as requested only when the ceiling grants it; anything
  /// the ceiling does not grant, and every switch of a module the ceiling
  /// does not list at all, becomes `false` (default-deny).
  ///
  /// Parameters:
  /// - [requestedPermissions]: `{module: {switch: bool}}` from the role form.
  /// - [demoPermissions]: the `Demo_Permissions/{cid}` document.
  ///
  /// Returns: the capped `{module: {switch: bool}}`, same keys as requested.
  static Map<String, Map<String, bool>> capToCompanyCeiling({
    required Map<String, Map<String, bool>> requestedPermissions,
    required Map<String, dynamic> demoPermissions,
  }) {
    final Map<String, Map<String, bool>> validatedPermissions = {};

    requestedPermissions.forEach((moduleName, modulePermissions) {
      // Every spelling the template may be keyed under (23/8/2026): asking
      // only for `services_app` when the document says `form_builder` made
      // the module look absent, and the default-deny branch below then wrote
      // all-false for a module the company had actually granted.
      // See [ModuleNameAliases].
      String? storedKey;
      for (final String spelling
          in ModuleNameAliases.spellingsOf(moduleName)) {
        if (demoPermissions[spelling] is Map) {
          storedKey = spelling;
          break;
        }
      }

      if (storedKey != null) {
        Map<String, dynamic> adminModulePerms =
        Map<String, dynamic>.from(demoPermissions[storedKey]);

        Map<String, bool> validatedModulePerms = {};

        modulePermissions.forEach((permKey, requestedValue) {
          bool adminAllows = (adminModulePerms[permKey] == true);

          if (adminAllows) {
            validatedModulePerms[permKey] = requestedValue;
          } else {
            validatedModulePerms[permKey] = false;
          }
        });

        validatedPermissions[moduleName] = validatedModulePerms;
      } else {
        // SECURITY (default-deny): a module absent from the admin template
        // used to pass through with everything the caller requested. An
        // un-granted module now resolves to all-false.
        validatedPermissions[moduleName] = <String, bool>{
          for (final String permKey in modulePermissions.keys) permKey: false,
        };
      }
    });

    return validatedPermissions;
  }

  /// Function Name: [buildSubscriptionPermissionAdminData]
  ///
  /// Purpose: The ONE builder for
  ///          `Demo/{cid}/Subscription_Permission_Admin/{roleId}` (ADDED
  ///          9/10/2026), shared by [addNewRole] and [updateRole].
  ///
  /// Until 9/10/2026 only [updateRole] wrote this document, so a new role had
  /// none and `PermissionSyncService._syncDemoPermissionsToAllRoles` skipped
  /// it (`if (!subPermDoc.exists) continue;`) until its first edit.
  ///
  /// Shape (unchanged from the edit path): `companyId`, `roleId`,
  /// `timestamps`, plus `{module: {switch: bool}}` for every selected module
  /// that has validated permissions.
  ///
  /// Parameters:
  /// - [companyId] / [roleId]: the ids stored on the document.
  /// - [selectedModules]: the role's modules, in form order.
  /// - [validatedPermissions]: already capped by [capToCompanyCeiling].
  /// - [timestamps]: `[millis]` at creation; `FieldValue.arrayUnion([millis])`
  ///   on edit (merge write), exactly as before.
  ///
  /// Returns: the document body.
  static Map<String, dynamic> buildSubscriptionPermissionAdminData({
    required String companyId,
    required String roleId,
    required List<String> selectedModules,
    required Map<String, Map<String, bool>> validatedPermissions,
    required Object timestamps,
  }) {
    final Map<String, dynamic> subPermData = <String, dynamic>{
      'companyId': companyId,
      'roleId': roleId,
      'timestamps': timestamps,
    };

    for (final String moduleName in selectedModules) {
      if (validatedPermissions.containsKey(moduleName)) {
        subPermData[moduleName] = validatedPermissions[moduleName];
      }
    }

    return subPermData;
  }

  // REMOVED 11/8/2026: `isPermissionAllowedByAdmin` — dead code (0 callers;
  // RoleCubit and PermissionSyncService each declare their own) and fail-open
  // twice over: it returned `true` both when the admin-permission document was
  // missing and when the module was absent from it.

  Future<Either<Failure, dynamic>> addNewRole({
    required List<String> selectedModules,
    required String roleName,
    required String roleNameAr,
    required String roleDescription,
    required String roleDescriptionAr,
    required String createdBy,
    required String? roleImage,
    required Map<String, Map<String, bool>> modulePermissions,
    RoleStatus status = RoleStatus.active,
    List<String>? restrictedCountryCodes,
  }) async {
    try {
      String companyId = getBaseUrl('').split('/').where((s) => s.isNotEmpty).last;

      Either<FirebaseFailure, Map<String, Map<String, bool>>> validationResult =
      await validatePermissionsAgainstAdmin(
        requestedPermissions: modulePermissions,
        companyId: companyId,
      );

      if (validationResult.isLeft()) {
        return validationResult;
      }

      Map<String, Map<String, bool>> validatedPermissions =
      validationResult.getOrElse(() => {});

      for (var module in validatedPermissions.keys) {
        var perms = validatedPermissions[module];
        if (perms != null) {
          for (var permValue in perms.values) {
            if (permValue is List) {
              throw Exception("Nested array detected in module '$module' permissions");
            }
          }
        }
      }

      String roleId = await remoteDataSource.generateNextRoleId();

      DocumentSnapshot existingDoc = await _getCollection(ROLES_COLLECTION).doc(roleId).get();
      if (existingDoc.exists) {
        throw Exception("Role ID collision detected - ID $roleId already exists!");
      }

      String? roleImageLink;
      if (roleImage != null) {
        try {
          dynamic uploadResult = await remoteDataSource.uploadRoleImage(roleImage);

          if (uploadResult is Either) {
            dynamic value = uploadResult.fold(
                  (failure) => null,
                  (success) => success,
            );

            if (value == null) {
              Failure failure = uploadResult.fold((l) => l, (r) => FirebaseFailure('Unexpected'));
              return Left(failure);
            }

            roleImageLink = value.toString();
          } else {
            return Left(FirebaseFailure('Unexpected result type from image upload'));
          }
        } catch (imageError, stackTrace) {
          return Left(FirebaseFailure('Image upload failed: $imageError'));
        }
      }

      RoleHistoryModel role = RoleHistoryModel.createNew(
        roleId: roleId,
        roleName: roleName,
        roleNameAr: roleNameAr,
        roleDescription: roleDescription,
        roleDescriptionAr: roleDescriptionAr,
        roleImage: roleImageLink ?? '',
        createdAt: Timestamp.now(),
        createdBy: createdBy,
        status: status,
        selectedModules: selectedModules,
      );

      WriteBatch batch = firestore.batch();

      DocumentReference roleRef = _getCollection(ROLES_COLLECTION).doc(roleId);

      Map<String, dynamic> roleMap = role.toMap();

      if (roleMap['Selected_Modules'] is List) {
        var modules = roleMap['Selected_Modules'] as List;
        for (var module in modules) {
          if (module is List) {
            throw Exception("Nested arrays in Selected_Modules are not supported");
          }
        }
      }

      batch.set(roleRef, roleMap);

      await _createPermissionDocuments(batch, roleId, selectedModules, validatedPermissions);

      // ADDED 9/10/2026 — the role's Subscription_Permission_Admin document,
      // in the same commit, same shape as the edit path. Without it
      // PermissionSyncService skipped the new role until its first edit.
      // A plain set (not merge): the id is new, and a stale document left
      // under a reused id must not leak its old modules into this role.
      batch.set(
        _getCollection(SUBSCRIPTION_PERMISSION_ADMIN_COLLECTION).doc(roleId),
        buildSubscriptionPermissionAdminData(
          companyId: companyId,
          roleId: roleId,
          selectedModules: selectedModules,
          validatedPermissions: validatedPermissions,
          timestamps: <int>[DateTime.now().millisecondsSinceEpoch],
        ),
      );

      if (restrictedCountryCodes != null) {
        _setRestrictedCountries(batch, roleId, restrictedCountryCodes);
      }

      await batch.commit();

      // ADDED 25/8/2026 — spec: Role Created. Fans out to the Master Admins,
      // minus the person who just did it.
      await _notifyRoleCreated(actorEmail: createdBy, roleName: roleName);

      return Right('Role created successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ✅ FIXED: Added status parameter
  Future<Either<Failure, dynamic>> updateRole({
    required RoleHistoryModel role,
    required String currentUserEmail,
    required String roleDescription,
    required String roleDescriptionAr,
    String? roleNameAr,
    required String? roleImage,
    required List<String> selectedModules,
    required Map<String, Map<String, bool>> modulePermissions,
    RoleStatus status = RoleStatus.active, // ✅ ADDED
    List<String>? restrictedCountryCodes,
  }) async {
    try {
      String roleId = role.roleId;
      int timestamp = DateTime.now().millisecondsSinceEpoch;

      // The status as STORED, read before anything is written.
      //
      // Not `role.currentStatus`: `RoleCubit.activateDraftRole` applies
      // `copyWith(status: active)` to the role BEFORE handing it here, so the
      // in-memory model already carries the new value and the draft → active
      // transition would compare active against active and look like no change
      // at all. Reading the document is the only view of the status that the
      // caller cannot have pre-mutated.
      final RoleStatus storedStatus = await _storedRoleStatus(roleId);

      String companyId = getBaseUrl('').split('/').where((s) => s.isNotEmpty).last;

      Either<FirebaseFailure, Map<String, Map<String, bool>>> validationResult =
      await validatePermissionsAgainstAdmin(
        requestedPermissions: modulePermissions,
        companyId: companyId,
      );

      if (validationResult.isLeft()) {
        return validationResult;
      }

      Map<String, Map<String, bool>> validatedPermissions =
      validationResult.getOrElse(() => {});

      WriteBatch batch = firestore.batch();

      EditBy currentEditBy = role.currentEditBy ?? EditBy(editorEmail: [], timestamps: []);
      List<String?> editorEmails = List<String?>.from(currentEditBy.editorEmail ?? []);
      List<Timestamp?> editTimestamps = List<Timestamp?>.from(currentEditBy.timestamps ?? []);
      editorEmails.add(currentUserEmail);
      editTimestamps.add(Timestamp.now());
      EditBy updatedEditBy = EditBy(
        editorEmail: editorEmails,
        timestamps: editTimestamps,
      );

      String? roleImageLink;
      if (roleImage != null) {
        try {
          dynamic uploadResult = await remoteDataSource.uploadRoleImage(roleImage);

          if (uploadResult is Either) {
            dynamic value = uploadResult.fold(
                  (failure) => null,
                  (success) => success,
            );

            if (value == null) {
              Failure failure = uploadResult.fold((l) => l, (r) => FirebaseFailure('Unexpected'));
              return Left(failure);
            }

            roleImageLink = value.toString();
          } else {
            return Left(FirebaseFailure('Unexpected result type from image upload'));
          }
        } catch (imageError, stackTrace) {
          return Left(FirebaseFailure('Image upload failed: $imageError'));
        }
      }

      RoleHistoryModel updatedRole = role.copyWith(
        roleDescription: roleDescription,
        roleDescriptionAr: roleDescriptionAr,
        roleNameAr: roleNameAr,
        roleImage: roleImageLink,
        selectedModules: selectedModules,
        editBy: updatedEditBy,
        status: status.name, // ✅ ADDED
      );

      Map<String, dynamic> synchronizedRoleData = updatedRole.toMap();

      DocumentReference roleRef = _getCollection(ROLES_COLLECTION).doc(roleId);
      batch.update(roleRef, synchronizedRoleData);

      for (String moduleName in selectedModules) {
        String collectionName = _getPermissionCollectionName(moduleName);
        if (collectionName.isEmpty) continue;

        DocumentReference permRef = _getCollection(collectionName).doc(roleId);
        DocumentSnapshot permDoc = await permRef.get();

        Map<String, dynamic> synchronizedPermissionData;

        if (permDoc.exists) {
          Map<String, dynamic> existingPermissions = permDoc.data() as Map<String, dynamic>;
          synchronizedPermissionData = _synchronizeModulePermissions(
            existingPermissions: existingPermissions,
            newPermissions: validatedPermissions[moduleName] ?? {},
            timestamp: timestamp,
            roleId: roleId,
          );
        } else {
          synchronizedPermissionData = _createNewModulePermissions(
            permissions: validatedPermissions[moduleName] ?? {},
            timestamp: timestamp,
            roleId: roleId,
          );
        }

        batch.set(permRef, synchronizedPermissionData);
      }

      DocumentReference subPermRef = firestore
          .collection(getBaseUrl('Subscription_Permission_Admin'))
          .doc(roleId);

      // CHANGED 9/10/2026 — built by the shared
      // [buildSubscriptionPermissionAdminData] (addNewRole uses it too);
      // same document, same merge write as before.
      Map<String, dynamic> subPermData = buildSubscriptionPermissionAdminData(
        companyId: companyId,
        roleId: roleId,
        selectedModules: selectedModules,
        validatedPermissions: validatedPermissions,
        timestamps: FieldValue.arrayUnion([timestamp]),
      );

      batch.set(subPermRef, subPermData, SetOptions(merge: true));

      if (restrictedCountryCodes != null) {
        _setRestrictedCountries(batch, roleId, restrictedCountryCodes);
      }

      List<String> oldModules = role.currentSelectedModules;

      // Compared canonically (23/8/2026). The caller now normalises module
      // names, so a role stored as `form_builder` arrives here as
      // `services_app`. A raw string comparison would call the old name
      // "removed", and `_getPermissionCollectionName` resolves both to the SAME
      // collection — so the batch would have deleted the permissions document
      // it had just written a few lines above. See [ModuleNameAliases].
      final Set<String> keptModules =
          selectedModules.map(ModuleNameAliases.canonical).toSet();
      List<String> removedModules = oldModules
          .where((m) => !keptModules.contains(ModuleNameAliases.canonical(m)))
          .toList();

      if (removedModules.isNotEmpty) {
        for (String moduleName in removedModules) {
          String collectionName = _getPermissionCollectionName(moduleName);
          if (collectionName.isNotEmpty) {
            DocumentReference permRef = _getCollection(collectionName).doc(roleId);
            batch.delete(permRef);
          }
        }
      }

      await batch.commit();

      // ADDED 25/8/2026 — spec: Role Updated, and Role Status Changed when
      // this save also flipped active/inactive. Both, when both happened: the
      // permissions genuinely changed AND the role was switched off, and an
      // admin reviewing the notice needs to know each.
      await _notifyRoleUpdated(
        actorEmail: currentUserEmail,
        roleName: role.currentRoleName,
        oldStatus: storedStatus,
        newStatus: status,
      );

      return Right('Role updated successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ── Restricted Location (ADDED 28/9/2026) ──────────────────────────────

  /// Queues the role's Restricted Location allow-list on [batch], so it is
  /// written in the same commit as the role and its permissions.
  void _setRestrictedCountries(
    WriteBatch batch,
    String roleId,
    List<String> countryCodes,
  ) {
    batch.set(
      _getCollection(ROLE_RESTRICTED_LOCATIONS).doc(roleId),
      <String, dynamic>{
        'Role_Id': roleId,
        'Countries': countryCodes.toSet().toList()..sort(),
        'Updated_At': Timestamp.now(),
      },
    );
  }

  /// The ISO country codes a role may open the app from. Empty when the role
  /// has no list (or it could not be read) — callers treat empty as "no
  /// restriction configured".
  Future<List<String>> getRestrictedCountryCodes(String roleId) async {
    try {
      final DocumentSnapshot doc =
          await _getCollection(ROLE_RESTRICTED_LOCATIONS).doc(roleId).get();
      if (!doc.exists) return <String>[];
      final Object? countries =
          (doc.data() as Map<String, dynamic>?)?['Countries'];
      if (countries is! List) return <String>[];
      return countries.map((Object? e) => e.toString()).toList();
    } catch (e) {
      debugPrint('getRestrictedCountryCodes($roleId) failed: $e');
      return <String>[];
    }
  }

  Future<Either<FirebaseFailure, dynamic>> getUnDeletedRoles() async {
    try {
      List<RoleHistoryModel> roleTypeList = [];

      // Roles come from two collections. A failure in one used to be swallowed
      // by an empty `catch {}`, so a permission error or an offline read
      // returned a *silently truncated* role list that looked like success
      // (§11.5). Failures are now recorded and reported if nothing was read.
      final List<String> readFailures = <String>[];

      try {
        String subscriptionAdminPath = getBaseUrl(SUBSCRIPTION_ADMIN_COLLECTION);

        QuerySnapshot subscriptionSnapshot = await firestore
            .collection(subscriptionAdminPath)
            .get();

        for (QueryDocumentSnapshot doc in subscriptionSnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['_documentId'] = doc.id;

            RoleHistoryModel role = RoleHistoryModel.fromMap(data);

            roleTypeList.add(role);

          } catch (e, stackTrace) {
            debugPrint(
              'getUnDeletedRoles: skipped malformed $SUBSCRIPTION_ADMIN_COLLECTION '
              'doc ${doc.id}: $e\n$stackTrace',
            );
            continue;
          }
        }

      } catch (e, stackTrace) {
        readFailures.add('$SUBSCRIPTION_ADMIN_COLLECTION: $e');
        debugPrint('getUnDeletedRoles: $SUBSCRIPTION_ADMIN_COLLECTION read failed: $e\n$stackTrace');
      }

      try {
        String rolesPath = getBaseUrl(ROLES_COLLECTION);

        QuerySnapshot rolesSnapshot = await firestore
            .collection(rolesPath)
            .get();

        for (QueryDocumentSnapshot doc in rolesSnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['_documentId'] = doc.id;

            RoleHistoryModel role = RoleHistoryModel.fromMap(data);

            if (role.currentStatus != RoleStatus.deleted) {
              roleTypeList.add(role);
            }
          } catch (e, stackTrace) {
            debugPrint(
              'getUnDeletedRoles: skipped malformed $ROLES_COLLECTION doc '
              '${doc.id}: $e\n$stackTrace',
            );
            continue;
          }
        }

      } catch (e, stackTrace) {
        readFailures.add('$ROLES_COLLECTION: $e');
        debugPrint('getUnDeletedRoles: $ROLES_COLLECTION read failed: $e\n$stackTrace');
      }

      // Only fail the call when nothing at all could be read — a partial result
      // is still useful, but "no roles" plus "a read blew up" must not be
      // reported to the UI as an empty-but-successful list.
      if (roleTypeList.isEmpty && readFailures.isNotEmpty) {
        return Left(FirebaseFailure(
          'Could not load roles (${readFailures.join('; ')}).',
        ));
      }

      return Right(roleTypeList);

    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, dynamic>> deleteRole({
    required RoleHistoryModel role,
    required String currentUserEmail,
  }) async {
    try {
      String roleId = role.roleId;

      WriteBatch batch = firestore.batch();

      EditBy currentEditBy = role.currentEditBy ?? EditBy(editorEmail: [], timestamps: []);
      List<String?> editorEmails = List<String?>.from(currentEditBy.editorEmail ?? []);
      List<Timestamp?> editTimestamps = List<Timestamp?>.from(currentEditBy.timestamps ?? []);
      editorEmails.add(currentUserEmail);
      editTimestamps.add(Timestamp.now());
      EditBy updatedEditBy = EditBy(
        editorEmail: editorEmails,
        timestamps: editTimestamps,
      );

      RoleHistoryModel updatedRole = role.copyWith(
        status: RoleStatus.deleted.name,
        editBy: updatedEditBy,
      );

      DocumentReference roleRef = _getCollection(ROLES_COLLECTION).doc(roleId);
      DocumentSnapshot docSnapshot = await roleRef.get();

      if (!docSnapshot.exists) {
        return Left(FirebaseFailure('Role document not found with ID: $roleId'));
      }

      batch.update(roleRef, updatedRole.toMap());

      List<String> permissionCollections = [
        SERVICES_PERMISSIONS,
        services_app_PERMISSIONS,
        MESSAGES_PERMISSIONS,
        INVENTORY_PERMISSIONS,
        SETTINGS_PERMISSIONS,
        GRC_PERMISSIONS,
        QIYAS_PERMISSIONS,
        KNOWLEDGE_HUB_PERMISSIONS,
        ROLES_PERMISSIONS,
        HR_PERMISSIONS,
        CRM_PERMISSIONS,
        NOTIFICATION_PERMISSIONS,
      ];

      for (String collection in permissionCollections) {
        DocumentReference permRef = _getCollection(collection).doc(roleId);
        DocumentSnapshot permSnapshot = await permRef.get();
        if (permSnapshot.exists) {
          batch.delete(permRef);
        }
      }

      String companyId = getBaseUrl('').split('/').where((s) => s.isNotEmpty).last;
      DocumentReference subPermRef = firestore
          .collection(getBaseUrl('Subscription_Permission_Admin'))
          .doc(roleId);

      batch.delete(subPermRef);

      await batch.commit();

      // ADDED 25/8/2026 — spec: Role Deleted.
      await _notifyRoleDeleted(
        actorEmail: currentUserEmail,
        roleName: role.currentRoleName,
      );

      return Right('Role deleted successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS — Role Management
  //
  //  ADDED 25/8/2026. `role_management_events.dart` has defined all four of
  //  these events since the catalog was written, the Notification Control
  //  screen has been listing them and letting admins edit their bilingual
  //  templates, and `RoleManagementNotificationService` has been able to
  //  send them since 18/8/2026 — but no code in r1_role_management ever
  //  called it, so not one of the four could ever reach anybody. The
  //  service's own header said so: "It does NOT wire itself into
  //  r1_role_management. role_cubit.dart and role_repository.dart still
  //  have to invoke these methods."
  //
  //  They are raised here rather than in the cubit because this is where the
  //  batch commits. A notification sent from the cubit would go out on the
  //  strength of a call having been made, not of a write having landed.
  //
  //  All four fan out to the Master Admins with the actor filtered out —
  //  telling someone what they just did is noise.
  // ══════════════════════════════════════════════════════════════════

  /// Function Name: [_storedRoleStatus]
  ///
  /// Purpose: The status currently persisted for [roleId].
  ///
  /// `Status` is a history list, so the current value is the last entry. An
  /// unreadable or missing document yields [RoleStatus.active], matching what
  /// `RoleHistoryModel.currentStatus` falls back to.
  ///
  /// Parameters:
  /// - [roleId]: the role document id.
  ///
  /// Returns: [Future<RoleStatus>].
  Future<RoleStatus> _storedRoleStatus(String roleId) async {
    try {
      final DocumentSnapshot snapshot =
          await _getCollection(ROLES_COLLECTION).doc(roleId).get();
      if (!snapshot.exists) return RoleStatus.active;

      final Object? data = snapshot.data();
      if (data is! Map<String, dynamic>) return RoleStatus.active;

      final Object? stored = data[RoleHistoryModel.STATUS_KEY];
      final String name = stored is List
          ? (stored.isEmpty ? '' : stored.last.toString())
          : (stored?.toString() ?? '');

      return RoleStatus.values.firstWhere(
        (RoleStatus s) => s.name == name,
        orElse: () => RoleStatus.active,
      );
    } catch (e, stackTrace) {
      debugPrint('stored role status read failed: $e\n$stackTrace');
      return RoleStatus.active;
    }
  }

  /// The actor's display name for the `{{userName}}` placeholder. Falls back
  /// to the address when the directory has no record for it — better a bare
  /// email in the message than the controller's "no name" sentinel.
  String _actorName(String actorEmail) {
    final String name = AppControllers.employee.getEmployeeName(actorEmail);
    return (name.isEmpty || name.trim() == 'no name') ? actorEmail : name.trim();
  }

  /// Function Name: [_notifyRoleCreated]
  ///
  /// Purpose: Announce a newly created role to the other Master Admins.
  ///
  /// Parameters:
  /// - [actorEmail]: who created it; excluded from the recipients.
  /// - [roleName]: the English role name, as stored.
  ///
  /// Returns: [Future<void>] — never throws. The role is already saved; a
  /// notification failure must not turn that into an error the user sees.
  Future<void> _notifyRoleCreated({
    required String actorEmail,
    required String roleName,
  }) async {
    try {
      await RoleManagementNotificationService.sendRoleCreatedNotification(
        actorEmail: actorEmail,
        actorName: _actorName(actorEmail),
        roleName: roleName,
      );
    } catch (e, stackTrace) {
      debugPrint('role-created notification failed: $e\n$stackTrace');
    }
  }

  /// Function Name: [_notifyRoleUpdated]
  ///
  /// Purpose: Announce an edited role, plus its status transition when the
  /// same save changed active/inactive.
  ///
  /// Parameters:
  /// - [actorEmail]: who saved the change; excluded from the recipients.
  /// - [roleName]: the English role name, as stored.
  /// - [oldStatus] / [newStatus]: the status before and after this save. The
  ///   status template prints the transition, so both are required — passing
  ///   only the new one renders "from  to Active".
  ///
  /// Returns: [Future<void>] — never throws.
  Future<void> _notifyRoleUpdated({
    required String actorEmail,
    required String roleName,
    required RoleStatus oldStatus,
    required RoleStatus newStatus,
  }) async {
    try {
      final String actorName = _actorName(actorEmail);

      await RoleManagementNotificationService.sendRoleUpdatedNotification(
        actorEmail: actorEmail,
        actorName: actorName,
        roleName: roleName,
      );

      if (oldStatus != newStatus) {
        await RoleManagementNotificationService
            .sendRoleStatusChangedNotification(
          actorEmail: actorEmail,
          actorName: actorName,
          roleName: roleName,
          oldStatus: oldStatus.name,
          newStatus: newStatus.name,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('role-updated notification failed: $e\n$stackTrace');
    }
  }

  /// Function Name: [_notifyRoleDeleted]
  ///
  /// Purpose: Announce a removed role to the other Master Admins.
  ///
  /// Parameters:
  /// - [actorEmail]: who deleted it; excluded from the recipients.
  /// - [roleName]: the English role name, as stored.
  ///
  /// Returns: [Future<void>] — never throws.
  Future<void> _notifyRoleDeleted({
    required String actorEmail,
    required String roleName,
  }) async {
    try {
      await RoleManagementNotificationService.sendRoleDeletedNotification(
        actorEmail: actorEmail,
        actorName: _actorName(actorEmail),
        roleName: roleName,
      );
    } catch (e, stackTrace) {
      debugPrint('role-deleted notification failed: $e\n$stackTrace');
    }
  }

  Future<Either<FirebaseFailure, String>> fixCorruptedQiyasDocument(String roleId) async {
    try {
      DocumentReference permRef = _getCollection(QIYAS_PERMISSIONS).doc(roleId);
      await permRef.delete();

      Map<String, dynamic> properPermissions = {
        'Role_Id': roleId,
        'timestamps': [DateTime.now().millisecondsSinceEpoch],
        'Export_Table': [false],
        'Export_Champion_Table': [false],
        'Assigned_Evidence_Module': [false],
        'Delete_Qiyas': [false],
        'Champions_Module': [false],
        'Dashboard_Module': [false],
        'Edit_Evidence': [false],
        'Uploaded_Documents_Module': [false],
        'Remove_Champion': [false],
        'Assign_Champion': [false],
        'Edit_Qiyas_Details': [false],
        'Change_Submission_Status_Module': [false],
        'Qiyas_Permissions_Module': [false],
        'Approvals_Module': [false],
        'Reassign_Champion': [false],
        'Vision_Badges': [false],
        'Bulk_Upload': [false],
      };

      await permRef.set(properPermissions);
      return Right('Qiyas document fixed successfully');
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<void> _createPermissionDocuments(
      WriteBatch batch,
      String roleId,
      List<String> selectedModules,
      Map<String, Map<String, bool>> modulePermissions,
      ) async {
    for (int i = 0; i < selectedModules.length; i++) {
      String module = selectedModules[i];
      String collectionName = _getPermissionCollectionName(module);

      if (collectionName.isEmpty) {
        continue;
      }

      DocumentReference permRef = _getCollection(collectionName).doc(roleId);

      Map<String, dynamic> permissionData = {
        'Role_Id': roleId,
        'timestamps': [DateTime.now().millisecondsSinceEpoch],
      };

      Map<String, bool>? permissions = modulePermissions[module];
      if (permissions != null && permissions.isNotEmpty) {
        permissions.forEach((key, value) {
          String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
          permissionData[dbKey] = [value];
        });
      }

      bool hasNestedArrays = false;
      permissionData.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            if (item is List) {
              hasNestedArrays = true;
            }
          }
        }
      });

      if (hasNestedArrays) {
        throw Exception("Nested arrays are not supported in Firestore");
      }

      batch.set(permRef, permissionData);
    }
  }

  /// Function Name: [permissionCollectionFor]
  ///
  /// Purpose: The `Demo/{cid}/<collection>` that holds a module's role
  ///          switches — public and static since 9/10/2026 so the mapping
  ///          (`roles` → `roles_module_permissions`) is unit-tested.
  ///
  /// Returns: the collection name, or `''` for a module without one.
  static String permissionCollectionFor(String module) =>
      _getPermissionCollectionName(module);

  // `static` since 9/10/2026 (it never used instance state) so
  // [permissionCollectionFor] can expose it without a Firestore instance.
  static String _getPermissionCollectionName(String module) {
    // Canonical first (23/8/2026): a role storing `form_builder` used to fall
    // through to `default: return ''`, and every caller reads that as "invalid
    // module" and skips the read or the write entirely — so that module's
    // permissions were never loaded from, or saved to, its collection.
    // See [ModuleNameAliases].
    switch (ModuleNameAliases.canonical(module)) {
      case 'services':
        return SERVICES_PERMISSIONS;
      case 'services_app':
        return services_app_PERMISSIONS;
      case 'messages':
        return MESSAGES_PERMISSIONS;
      case 'inventory':
        return INVENTORY_PERMISSIONS;
      case 'settings':
        return SETTINGS_PERMISSIONS;
      case 'qiyas':
        return QIYAS_PERMISSIONS;
      case 'grc':
        return GRC_PERMISSIONS;
      case 'knowledge_hub':
        return KNOWLEDGE_HUB_PERMISSIONS;
      case 'roles': // 9/10/2026 — now roles_module_permissions
        return ROLES_PERMISSIONS;
      case 'hr':
        return HR_PERMISSIONS;
      case 'crm':
        return CRM_PERMISSIONS;
      case 'notification':
        return NOTIFICATION_PERMISSIONS;
      case 'todo':
        return TODO_PERMISSIONS;
      case 'time_tracker': // ADDED 8/10/2026 — Time Tracker role grants
        return TIME_TRACKER_PERMISSIONS;
      default:
        return '';
    }
  }

  Map<String, dynamic> _synchronizeModulePermissions({
    required Map<String, dynamic> existingPermissions,
    required Map<String, bool> newPermissions,
    required int timestamp,
    required String roleId,
  }) {
    Map<String, dynamic> synchronizedData = {'Role_Id': roleId};

    List<int> timestamps = [];
    if (existingPermissions.containsKey('timestamps') && existingPermissions['timestamps'] is List) {
      timestamps = List<int>.from(existingPermissions['timestamps']).toList();
    }

    timestamps.add(timestamp);
    synchronizedData['timestamps'] = timestamps;

    Set<String> allPermissionKeys = {};

    existingPermissions.forEach((key, value) {
      if (key != 'Role_Id' && key != 'timestamps') {
        allPermissionKeys.add(key);
      }
    });

    newPermissions.forEach((key, value) {
      String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
      allPermissionKeys.add(dbKey);
    });

    for (String permissionKey in allPermissionKeys) {
      List<bool> permissionHistory = [];

      if (existingPermissions.containsKey(permissionKey) && existingPermissions[permissionKey] is List) {
        permissionHistory = List<bool>.from(
            existingPermissions[permissionKey].map((v) => v == true)
        ).toList();
      } else {
        permissionHistory = List.filled(timestamps.length - 1, false, growable: true);
      }

      bool currentValue = permissionHistory.isNotEmpty ? permissionHistory.last : false;
      bool newValue = currentValue;

      for (String newPermKey in newPermissions.keys) {
        String dbKey = newPermKey.trim().replaceAll(RegExp(r'\s+'), '_');
        if (dbKey == permissionKey) {
          newValue = newPermissions[newPermKey]!;
          break;
        }
      }

      permissionHistory.add(newValue);
      synchronizedData[permissionKey] = permissionHistory;
    }

    return synchronizedData;
  }

  Map<String, dynamic> _createNewModulePermissions({
    required Map<String, bool> permissions,
    required int timestamp,
    required String roleId,
  }) {
    Map<String, dynamic> permissionData = {
      'Role_Id': roleId,
      'timestamps': [timestamp],
    };

    permissions.forEach((key, value) {
      String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
      permissionData[dbKey] = [value];
    });

    return permissionData;
  }

  Future<Either<FirebaseFailure, Map<String, dynamic>?>> getRolePermissions({
    required String roleId,
    required String module,
  }) async {
    try {
      String collectionName = _getPermissionCollectionName(module);
      if (collectionName.isEmpty) {
        return Right(null);
      }

      DocumentSnapshot doc = await _getCollection(collectionName).doc(roleId).get();

      if (doc.exists) {
        return Right(doc.data() as Map<String, dynamic>);
      } else {
        return Right(null);
      }
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, Map<String, Map<String, dynamic>>>> getAllRolePermissions({
    required String roleId,
    required List<String> selectedModules,
  }) async {
    try {
      Map<String, Map<String, dynamic>> allPermissions = {};

      for (String module in selectedModules) {
        Either<FirebaseFailure, Map<String, dynamic>?> result =
        await getRolePermissions(roleId: roleId, module: module);

        if (result.isRight()) {
          Map<String, dynamic>? permissions = result.getOrElse(() => null);
          if (permissions != null) {
            allPermissions[module] = permissions;
          }
        }
      }

      return Right(allPermissions);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<FirebaseFailure, String>> updateModulePermissions({
    required String roleId,
    required String module,
    required Map<String, bool> permissions,
  }) async {
    try {
      String collectionName = _getPermissionCollectionName(module);
      if (collectionName.isEmpty) {
        return Left(FirebaseFailure('Invalid module: $module'));
      }

      DocumentReference permRef = _getCollection(collectionName).doc(roleId);
      DocumentSnapshot doc = await permRef.get();

      Map<String, dynamic> existingData = {};

      if (doc.exists) {
        existingData = doc.data() as Map<String, dynamic>;
      } else {
        existingData = {
          'Role_Id': roleId,
          'timestamps': [],
        };
      }

      int newTimestamp = DateTime.now().millisecondsSinceEpoch;
      List<int> timestamps = List<int>.from(existingData['timestamps'] ?? []);
      timestamps.add(newTimestamp);
      existingData['timestamps'] = timestamps;

      permissions.forEach((key, value) {
        String dbKey = key.trim().replaceAll(RegExp(r'\s+'), '_');
        List<bool> permissionHistory = List<bool>.from(existingData[dbKey] ?? []);
        permissionHistory.add(value);
        existingData[dbKey] = permissionHistory;
      });

      await permRef.set(existingData);
      return Right('Module permissions updated successfully');
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}