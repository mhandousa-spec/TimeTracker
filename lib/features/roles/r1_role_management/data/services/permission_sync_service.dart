/// Module: roles / r1_role_management / data / services
///
/// ************************* FILE INFO ************************* ///
/// File Name: permission_sync_service.dart
/// Purpose: Handles real-time synchronization between Demo_Permissions,
///          Subscription_Permission_Admin, and module permission collections
/// Author: [Amr Mesbah Hosny]
/// Created At: [11/12/2025]
/// FIXED: Now correctly syncs FALSE→TRUE by iterating Demo_Permissions keys
/// DEBUG VERSION: Extensive logging to identify sync issues
///
/// SYNC FLOW:
/// 1. Demo_Permissions → Master Admin Subscription_Permission_Admin
/// 2. Demo_Permissions → Employee Subscription_Permission_Admin (enforce restrictions)
/// 3. Employee Subscription_Permission_Admin → Module collections

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/api_constants.dart' hide FirebaseCollections;

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';

class PermissionSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, StreamSubscription> _subscriptions = {};
  String? _companyId;

  void initialize(String companyId) {
    _companyId = companyId;
  }

  void startDemoPermissionsListener() {
    if (_companyId == null || _companyId!.isEmpty) {
      return;
    }

    _subscriptions['demo_permissions']?.cancel();

    _subscriptions['demo_permissions'] = _firestore
        .collection(FirebaseCollections.demoPermissions)
        .doc(_companyId)
        .snapshots()
        .listen(
          (snapshot) async {
        if (!snapshot.exists) {
          return;
        }

        // Firestore delivers a local echo before the server ack, so every write
        // arrives twice. Ignore the pending-write copy or the sync runs (and
        // appends) twice per change.
        if (snapshot.metadata.hasPendingWrites) {
          return;
        }

        await _syncDemoPermissionsToAllRoles(snapshot);
      },
      onError: (error) {
      },
    );

  }

  /// ✅ FIXED: Iterate through Demo_Permissions keys, not current subscription keys
  Future<void> _syncDemoPermissionsToAllRoles(
      DocumentSnapshot<Map<String, dynamic>> demoPermSnapshot) async {
    try {

      if (!demoPermSnapshot.exists) {
        return;
      }

      Map<String, dynamic> demoPermissions = demoPermSnapshot.data()!;

      QuerySnapshot rolesSnapshot = await _firestore

          .collection(getBaseUrl('Roles'))
          .get();

      WriteBatch batch = _firestore.batch();
      int updateCount = 0;

      for (var roleDoc in rolesSnapshot.docs) {

        Map<String, dynamic> roleData = roleDoc.data() as Map<String, dynamic>;
        String roleId = roleDoc.id;
        String roleName = '';

        if (roleData['roleName'] is List && (roleData['roleName'] as List).isNotEmpty) {
          roleName = roleData['roleName'][0].toString();
        } else if (roleData['roleName'] is String) {
          roleName = roleData['roleName'];
        }

        bool isMasterAdmin = roleName.toLowerCase().contains('master') &&
            roleName.toLowerCase().contains('admin');

        DocumentReference subPermRef = _firestore

            .collection(getBaseUrl('Subscription_Permission_Admin'))
            .doc(roleId);

        DocumentSnapshot subPermDoc = await subPermRef.get();

        if (!subPermDoc.exists) {
          continue;
        }

        Map<String, dynamic> currentSubPerm = subPermDoc.data() as Map<String, dynamic>;

        Map<String, dynamic> updatedSubPerm = {
          'companyId': _companyId,
          'roleId': roleId,
        };

        // Preserve timestamps
        if (currentSubPerm.containsKey('timestamps')) {
          List<int> timestamps = List<int>.from(currentSubPerm['timestamps']);
          timestamps.add(DateTime.now().millisecondsSinceEpoch);
          updatedSubPerm['timestamps'] = timestamps;
        } else {
          updatedSubPerm['timestamps'] = [DateTime.now().millisecondsSinceEpoch];
        }

        int restrictedCount = 0;
        int allowedCount = 0;
        int changesDetected = 0;

        // ✅ FIX: Iterate through Demo_Permissions modules (the source of truth)
        for (String moduleName in demoPermissions.keys) {
          if (moduleName == 'companyId' || moduleName == 'roleId' ||
              moduleName == 'timestamps' || moduleName == 'createdAt' ||
              moduleName == 'createdBy') {
            continue;
          }

          if (demoPermissions[moduleName] is! Map) {
            continue;
          }

          Map<String, dynamic> demoModulePerms =
          Map<String, dynamic>.from(demoPermissions[moduleName]);

          // Get current module perms (if they exist)
          Map<String, dynamic> currentModulePerms = {};
          if (currentSubPerm.containsKey(moduleName) && currentSubPerm[moduleName] is Map) {
            currentModulePerms = Map<String, dynamic>.from(currentSubPerm[moduleName]);
          } else {
          }

          Map<String, bool> updatedModulePerms = {};

          // ✅ FIX: Loop through Demo_Permissions keys (not current keys)

          demoModulePerms.forEach((permKey, demoValue) {
            bool adminAllows = (demoValue == true);
            bool currentValue = (currentModulePerms[permKey] == true);

            if (isMasterAdmin) {
              // ✅ Master Admin: Always copy from Demo_Permissions
              updatedModulePerms[permKey] = adminAllows;

              if (adminAllows != currentValue) {
                changesDetected++;
              }
            } else {
              // Employee: If admin blocks it, force false; otherwise keep employee value
              if (adminAllows) {
                updatedModulePerms[permKey] = currentValue;
                allowedCount++;
              } else {
                updatedModulePerms[permKey] = false;
                restrictedCount++;
                if (currentValue) {
                }
              }
            }
          });

          updatedSubPerm[moduleName] = updatedModulePerms;
        }

        if (isMasterAdmin) {
        } else if (restrictedCount > 0) {
        }

        // `changesDetected` above only counts the Master-Admin branch, so
        // compare the rebuilt module maps against what is already stored.
        // Writing an identical document still notifies the
        // Subscription_Permission_Admin listener, which then appends another
        // history entry to every module collection — the main source of the
        // runaway index growth.
        bool roleChanged = false;
        for (final entry in updatedSubPerm.entries) {
          if (entry.value is! Map) continue;
          final Map newMap = entry.value as Map;
          final Map oldMap = currentSubPerm[entry.key] is Map
              ? currentSubPerm[entry.key] as Map
              : const {};
          if (newMap.length != oldMap.length) {
            roleChanged = true;
            break;
          }
          for (final k in newMap.keys) {
            if ((oldMap[k] == true) != (newMap[k] == true)) {
              roleChanged = true;
              break;
            }
          }
          if (roleChanged) break;
        }

        if (!roleChanged) {
          continue;
        }

        batch.set(subPermRef, updatedSubPerm);
        updateCount++;

      }

      if (updateCount > 0) {
        await batch.commit();

        // Sync ALL roles_module to module collections
        for (var roleDoc in rolesSnapshot.docs) {
          String roleId = roleDoc.id;

          DocumentSnapshot updatedSubPermDoc = await _firestore

              .collection(getBaseUrl('Subscription_Permission_Admin'))
              .doc(roleId)
              .get();

          if (updatedSubPermDoc.exists) {
            Map<String, dynamic> subPermData = updatedSubPermDoc.data() as Map<String, dynamic>;

            await _syncSubscriptionToModuleCollections(
              roleId: roleId,
              subscriptionPermData: subPermData,
            );
          }
        }
      }

    } catch (e, stackTrace) {
      debugPrint('PermissionSyncService.syncSubscriptionPermissions failed: $e\n$stackTrace');
    }
  }

  void startEmployeeSubscriptionListener(String roleId) {
    if (_companyId == null || _companyId!.isEmpty) {
      return;
    }

    String listenerKey = 'employee_sub_$roleId';
    _subscriptions[listenerKey]?.cancel();

    _subscriptions[listenerKey] = _firestore

        .collection(getBaseUrl('Subscription_Permission_Admin'))
        .doc(roleId)
        .snapshots()
        .listen(
          (snapshot) async {
        if (!snapshot.exists) {
          return;
        }

        // Ignore the local-write echo (see Demo_Permissions listener above).
        if (snapshot.metadata.hasPendingWrites) {
          return;
        }

        Map<String, dynamic> subscriptionPermissions =
        snapshot.data() as Map<String, dynamic>;

        await _syncSubscriptionToModuleCollections(
          roleId: roleId,
          subscriptionPermData: subscriptionPermissions,
        );
      },
      onError: (error) {
      },
    );

  }

  Future<void> _syncSubscriptionToModuleCollections({
    required String roleId,
    required Map<String, dynamic> subscriptionPermData,
  }) async {
    try {

      DocumentSnapshot demoPermDoc = await _firestore
          .collection(FirebaseCollections.demoPermissions)
          .doc(_companyId)
          .get();

      Map<String, dynamic>? demoPermissions;
      if (demoPermDoc.exists) {
        demoPermissions = demoPermDoc.data() as Map<String, dynamic>?;
      } else {
      }

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      WriteBatch batch = _firestore.batch();
      int updateCount = 0;

      for (String key in subscriptionPermData.keys) {
        if (key == 'companyId' ||
            key == 'roleId' ||
            key == 'timestamps' ||
            key == 'createdAt' ||
            key == 'createdBy') {
          continue;
        }

        String moduleName = key;

        if (subscriptionPermData[moduleName] is! Map) {
          continue;
        }

        Map<String, dynamic> modulePerms =
        Map<String, dynamic>.from(subscriptionPermData[moduleName]);

        Map<String, bool> validatedPerms = {};

        if (demoPermissions != null &&
            demoPermissions.containsKey(moduleName) &&
            demoPermissions[moduleName] is Map) {

          Map<String, dynamic> adminModulePerms =
          Map<String, dynamic>.from(demoPermissions[moduleName]);

          int blocked = 0;
          int allowed = 0;

          modulePerms.forEach((permKey, permValue) {
            bool adminAllows = (adminModulePerms[permKey] == true);
            bool employeeValue = (permValue == true);

            if (adminAllows) {
              validatedPerms[permKey] = employeeValue;
              allowed++;
            } else {
              validatedPerms[permKey] = false;
              blocked++;
              if (employeeValue) {
              }
            }
          });

        } else {
          modulePerms.forEach((permKey, permValue) {
            validatedPerms[permKey] = (permValue == true);
          });
        }

        String collectionName = _getModuleCollectionName(moduleName);
        if (collectionName.isEmpty) {
          continue;
        }

        DocumentReference docRef = _firestore

            .collection(getBaseUrl(collectionName))
            .doc(roleId);

        DocumentSnapshot existingDoc = await docRef.get();

        Map<String, dynamic> updateData = {
          'Role_Id': roleId,
        };

        if (existingDoc.exists) {
          Map<String, dynamic> existingData =
          existingDoc.data() as Map<String, dynamic>;

          // Only record a new history entry when a permission actually changed.
          // This method also runs when a listener re-delivers an unchanged
          // document (on attach, and again as the local-write echo), so
          // appending unconditionally grew every field by one element per
          // delivery — thousands of entries for a handful of real edits.
          bool anyChanged = false;
          final Map<String, List<bool>> histories = {};

          validatedPerms.forEach((permKey, newValue) {
            String dbKey = permKey.trim().replaceAll(RegExp(r'\s+'), '_');
            List<bool> history =
            List<bool>.from(existingData[dbKey] ?? []);
            histories[dbKey] = history;
            final bool lastValue = history.isNotEmpty ? history.last : false;
            if (history.isEmpty || lastValue != newValue) {
              anyChanged = true;
            }
          });

          if (!anyChanged) {
            continue;
          }

          // Something changed: append to every field so the permission arrays
          // stay index-aligned with `timestamps`.
          List<int> timestamps =
          List<int>.from(existingData['timestamps'] ?? []);
          timestamps.add(timestamp);
          updateData['timestamps'] = timestamps;

          validatedPerms.forEach((permKey, newValue) {
            String dbKey = permKey.trim().replaceAll(RegExp(r'\s+'), '_');
            final List<bool> history = histories[dbKey]!..add(newValue);
            updateData[dbKey] = history;
          });

        } else {
          updateData['timestamps'] = [timestamp];

          validatedPerms.forEach((permKey, value) {
            String dbKey = permKey.trim().replaceAll(RegExp(r'\s+'), '_');
            updateData[dbKey] = [value];
          });

        }

        batch.set(docRef, updateData);
        updateCount++;
      }

      if (updateCount > 0) {
        await batch.commit();
      }

    } catch (e, stackTrace) {
      debugPrint('PermissionSyncService: module-collection sync failed: $e\n$stackTrace');
    }
  }

  /// Function Name: [moduleCollectionFor]
  ///
  /// Purpose: The module collection a Subscription_Permission_Admin module
  ///          key is synced into — public and static since 9/10/2026 so the
  ///          `roles` → `roles_module_permissions` mapping is unit-tested.
  static String moduleCollectionFor(String moduleName) =>
      _getModuleCollectionName(moduleName);

  // `static` since 9/10/2026 (no instance state), see [moduleCollectionFor].
  static String _getModuleCollectionName(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':
        return 'services_module_permissions';
      case 'services_app':
        return 'services_app_module_permissions';
      case 'messages':
        return 'messages_module_permissions';
      case 'inventory':
        return 'inventory_module_permissions';
      case 'settings':
        return 'settings_module_permissions';
      case 'qiyas':
        return 'qiyas_module_permissions';
      case 'grc':
        return 'grc_module_permissions';
      case 'knowledge_hub':
        return 'knowledge_hub_module_permissions';
      // ADDED 7/10/2026 — To-Do role grants.
      case 'todo':
        return 'todo_module_permissions';
      // ADDED 8/10/2026 — Time Tracker role grants.
      case 'time_tracker':
        return 'time_tracker_module_permissions';
      // CHANGED 9/10/2026 — was `roles_permissions`; house pattern
      // `<module>_module_permissions`, same as RoleRepository.ROLES_PERMISSIONS.
      case 'roles':
        return 'roles_module_permissions';
      default:
        return '';
    }
  }

  Future<void> startAllEmployeeListeners() async {
    if (_companyId == null || _companyId!.isEmpty) {
      return;
    }

    try {
      QuerySnapshot rolesSnapshot = await _firestore

          .collection(getBaseUrl('Roles'))
          .get();

      for (var roleDoc in rolesSnapshot.docs) {
        String roleId = roleDoc.id;
        Map<String, dynamic> roleData = roleDoc.data() as Map<String, dynamic>;

        String roleName = '';
        if (roleData['roleName'] is List && (roleData['roleName'] as List).isNotEmpty) {
          roleName = roleData['roleName'].last;
        }

        bool isMasterAdmin = roleName.toLowerCase().contains('master admin');

        if (!isMasterAdmin) {
          startEmployeeSubscriptionListener(roleId);
        }
      }

    } catch (e, stackTrace) {
      debugPrint('PermissionSyncService.startAllEmployeeListeners failed: $e\n$stackTrace');
    }
  }

  void dispose() {

    for (var entry in _subscriptions.entries) {
      entry.value.cancel();
    }

    _subscriptions.clear();
    _companyId = null;

  }

  Future<bool> isPermissionAllowedByAdmin(String moduleName, String permissionKey) async {
    if (_companyId == null || _companyId!.isEmpty) {
      return false;
    }

    try {
      DocumentSnapshot demoPermDoc = await _firestore
          .collection(FirebaseCollections.demoPermissions)
          .doc(_companyId)
          .get();

      if (!demoPermDoc.exists) {
        return false;
      }

      Map<String, dynamic> demoPermissions =
      demoPermDoc.data() as Map<String, dynamic>;

      if (demoPermissions.containsKey(moduleName) &&
          demoPermissions[moduleName] is Map) {
        Map<String, dynamic> modulePerms =
        Map<String, dynamic>.from(demoPermissions[moduleName]);

        return modulePerms[permissionKey] == true;
      }

      return false;

    } catch (e) {
      return false;
    }
  }

  Future<Map<String, bool>> getAdminRestrictionsForModule(String moduleName) async {
    if (_companyId == null || _companyId!.isEmpty) {
      return {};
    }

    try {
      DocumentSnapshot demoPermDoc = await _firestore
          .collection(FirebaseCollections.demoPermissions)
          .doc(_companyId)
          .get();

      if (!demoPermDoc.exists) {
        return {};
      }

      Map<String, dynamic> demoPermissions =
      demoPermDoc.data() as Map<String, dynamic>;

      if (demoPermissions.containsKey(moduleName) &&
          demoPermissions[moduleName] is Map) {
        return Map<String, bool>.from(demoPermissions[moduleName]);
      }

      return {};

    } catch (e) {
      return {};
    }
  }
}