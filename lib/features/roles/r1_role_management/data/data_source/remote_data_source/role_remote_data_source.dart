/// Module: roles / r1_role_management / data / data_source / remote_data_source
///
///  FILE INFO
/// Purpose: This file contains the remote data source for the roles_module with history support
/// Author: Amr Mesbah

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';



class RoleRemoteDataSource {
  WriteBatch _batch = FirebaseFirestore.instance.batch();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Access_Employee collection constant
  static const String USER_MANAGEMENT_COLLECTION = 'User_Management';

  // Employees_Info collection constant
  static const String EMPLOYEES_INFO_COLLECTION = 'Employees_Info';


  /// Function Name: [generateNextRoleId]
  ///
  /// Purpose: Allocate the next role document id for this company.
  ///
  /// Moved here 12/8/2026 from `RoleHistoryModel.generateNextRoleId`, which ran
  /// this Firestore query from inside a data model (§10/§11.2 — models are pure
  /// data and must not contain try/catch or network access).
  ///
  /// Returns: [Future<String>] `max(existing numeric id) + 1`, or a timestamp
  /// when the collection is empty, holds no numeric ids, or the read fails.
  Future<String> generateNextRoleId() async {
    String timestampId() => DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final String rolesCollectionPath = getBaseUrl('Roles');
      final QuerySnapshot snapshot =
          await _firestore.collection(rolesCollectionPath).get();

      if (snapshot.docs.isEmpty) return timestampId();

      final List<BigInt> numericIds = <BigInt>[];
      for (final doc in snapshot.docs) {
        final BigInt? parsed = BigInt.tryParse(doc.id);
        if (parsed != null) {
          numericIds.add(parsed);
        } else {
          // Legacy non-numeric id: it cannot take part in the max() below, so
          // it is skipped — but recorded rather than swallowed (§11.5).
          debugPrint('generateNextRoleId: ignoring non-numeric role id "${doc.id}"');
        }
      }

      if (numericIds.isEmpty) return timestampId();

      final BigInt maxId = numericIds.reduce((a, b) => a > b ? a : b);
      return (maxId + BigInt.one).toString();
    } catch (e, stackTrace) {
      debugPrint('generateNextRoleId failed, falling back to a timestamp id: $e\n$stackTrace');
      return timestampId();
    }
  }

  /// Get company ID from ApiConstants
  String get companyId {
    // Extract company ID from the base URI
    // Example: "Demo/84763782" -> returns "84763782"
    String baseUri = ApiConstants.baseUri;
    if (baseUri.contains('/')) {
      return baseUri.split('/').last;
    }
    return baseUri;
  }

  /// Get the Access_Employee collection reference
  CollectionReference get accessEmployeeCollection {
    return _firestore
        .collection(getBaseUrl(USER_MANAGEMENT_COLLECTION));
  }

  /// Get the Employees_Info collection reference
  CollectionReference get employeesInfoCollection {
    return _firestore
        .collection(getBaseUrl(EMPLOYEES_INFO_COLLECTION));
  }

  Future<Either<Failure, dynamic>> getUnDeletedRoles() async {
    Either<FirebaseFailure, dynamic> result =
    await FirebaseRepository.getDocumentsWithOneIsNotEqualToFilter(
        collectionPath: ApiConstants.roles,
        filterKey: 'Status',
        filterValue: RoleStatus.deleted.name);

    // Convert FirebaseFailure to Failure
    return result.fold(
          (firebaseFailure) => Left(FeatureFailure(firebaseFailure.errMessage)),
          (data) => Right(data),
    );
  }

  /// Updated to handle RoleHistoryModel
  updateRole(
      {required Map<String, dynamic> roleData, required String roleID}) async {
    Either<FirebaseFailure, dynamic> result =
    await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.roles,
        data: roleData,
        documentId: roleID);

    // Convert FirebaseFailure to Failure
    return result.fold(
          (firebaseFailure) => Left(FeatureFailure(firebaseFailure.errMessage)),
          (data) => Right(data),
    );
  }

  /// Get specific role by ID with history support
  Future<Either<Failure, dynamic>> getRoleById(String roleId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection(ApiConstants.roles).doc(roleId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Right(data);
      } else {
        return Left(FeatureFailure("Role not found"));
      }
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  /// Get role history for a specific role
  Future<Either<Failure, dynamic>> getRoleHistory(String roleId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection(ApiConstants.roles).doc(roleId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if it's a history model (has timestamps array)
        if (data.containsKey('timestamps') && data['timestamps'] is List) {
          RoleHistoryModel historyModel = RoleHistoryModel.fromMap(data);

          // Return formatted history
          List<Map<String, dynamic>> history = [];
          for (int i = 0; i < historyModel.timestamps.length; i++) {
            history.add({
              'timestamp': DateTime.fromMillisecondsSinceEpoch(
                  historyModel.timestamps[i]),
              'roleName':
              i < historyModel.roleName.length ? historyModel.roleName[i] : '',
              'roleNameAr': i < historyModel.roleNameAr.length
                  ? historyModel.roleNameAr[i]
                  : '',
              'roleDescription': i < historyModel.roleDescription.length
                  ? historyModel.roleDescription[i]
                  : '',
              'roleDescriptionAr': i < historyModel.roleDescriptionAr.length
                  ? historyModel.roleDescriptionAr[i]
                  : '',
              'status':
              i < historyModel.status.length ? historyModel.status[i] : '',
              'roleImage': i < historyModel.roleImage.length
                  ? historyModel.roleImage[i]
                  : '',
            });
          }

          return Right(history);
        } else {
          // Legacy model - no history available
          return Right([]);
        }
      } else {
        return Left(FeatureFailure("Role not found"));
      }
    } catch (e) {
      return Left(FeatureFailure("Failed to get role history: $e"));
    }
  }

  /// Get roles_module by date range
  Future<Either<Failure, dynamic>> getRolesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection(ApiConstants.roles).get();

      List<Map<String, dynamic>> roles = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('timestamps') && data['timestamps'] is List) {
          List<dynamic> timestamps = data['timestamps'];

          for (var timestamp in timestamps) {
            int ts = timestamp is int ? timestamp : (timestamp as num).toInt();
            DateTime date = DateTime.fromMillisecondsSinceEpoch(ts);

            if (date.isAfter(startDate) && date.isBefore(endDate)) {
              roles.add(data);
              break;
            }
          }
        }
      }

      return Right(roles);
    } catch (e) {
      return Left(FeatureFailure("Failed to get roles_module by date range: $e"));
    }
  }

  /// Get roles_module with recent changes
  Future<Either<Failure, dynamic>> getRecentlyModifiedRoles(
      {int days = 7}) async {
    try {
      int cutoffTimestamp = DateTime.now()
          .subtract(Duration(days: days))
          .millisecondsSinceEpoch;

      QuerySnapshot querySnapshot =
      await _firestore.collection(ApiConstants.roles).get();

      List<Map<String, dynamic>> recentRoles = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('timestamps') && data['timestamps'] is List) {
          List<dynamic> timestamps = data['timestamps'];
          if (timestamps.isNotEmpty && timestamps.last >= cutoffTimestamp) {
            recentRoles.add(data);
          }
        }
      }

      return Right(recentRoles);
    } catch (e) {
      return Left(FeatureFailure("Failed to get recently modified roles_module: $e"));
    }
  }

  /// Search roles_module by name (supports both English and Arabic)
  Future<Either<Failure, dynamic>> searchRolesByName(String searchTerm) async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection(ApiConstants.roles).get();

      List<Map<String, dynamic>> matchingRoles = [];
      String searchLower = searchTerm.toLowerCase();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check current role name (English and Arabic)
        bool matches = false;

        if (data.containsKey('Name') && data['Name'] is List) {
          List<dynamic> names = data['Name'];
          if (names.isNotEmpty &&
              names.last.toString().toLowerCase().contains(searchLower)) {
            matches = true;
          }
        }

        if (!matches && data.containsKey('Name_Ar') && data['Name_Ar'] is List) {
          List<dynamic> namesAr = data['Name_Ar'];
          if (namesAr.isNotEmpty &&
              namesAr.last.toString().toLowerCase().contains(searchLower)) {
            matches = true;
          }
        }

        if (matches) {
          matchingRoles.add(data);
        }
      }

      return Right(matchingRoles);
    } catch (e) {
      return Left(FeatureFailure("Failed to search roles_module: $e"));
    }
  }

  /// Get user access from Access_Employee collection
  Future<Either<Failure, dynamic>> getUserAccessModels(
      {required String id}) async {
    try {
      DocumentSnapshot doc = await accessEmployeeCollection.doc(id).get();

      if (!doc.exists) {
        return Right(null);
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Right(data);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  getRolesNamesList() async {
    Either<FirebaseFailure, dynamic> result =
    await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.rolesNames,
        documentId: ApiConstants.rolesNames);

    return result.fold(
          (firebaseFailure) => Left(FeatureFailure(firebaseFailure.errMessage)),
          (data) => Right(data),
    );
  }

  uploadRoleImage(String roleImage) async {
    String getImageName = roleImage.split('/').last;
    if (Platform.isAndroid)
      getImageName = roleImage.split('/').last.replaceAll('%20', '_');
    else if (Platform.isIOS)
      getImageName = roleImage.split('/').last.replaceAll(' ', '_');
    else if (Platform.isWindows)
      getImageName = roleImage.split('\\').last.replaceAll(' ', '_');
    else if (Platform.isMacOS)
      getImageName = roleImage.split('/').last.replaceAll(' ', '_');

    Either<FirebaseFailure, dynamic> result =
    await FirebaseRepository.uploadFile(
        collectionName: ApiConstants.roleImages,
        documentName: getImageName,
        filePath: roleImage);

    return result.fold(
          (firebaseFailure) => Left(FeatureFailure(firebaseFailure.errMessage)),
          (data) => Right(data),
    );
  }

  updateRolesNamesList(Map<String, dynamic> map) async {
    Either<FirebaseFailure, dynamic> result =
    await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.rolesNames,
        data: map,
        documentId: ApiConstants.rolesNames);

    return result.fold(
          (firebaseFailure) => Left(FeatureFailure(firebaseFailure.errMessage)),
          (data) => Right(data),
    );
  }

  /// ADDED 9/10/2026 — every write queued on [_batch], in order, so the same
  /// writes can instead be committed inside a Firestore TRANSACTION by
  /// [commitTransactionChecked] (a `WriteBatch` cannot be read back or
  /// replayed). Both queue methods below add to it; [startTransaction] clears
  /// it.
  final List<MapEntry<DocumentReference, Map<String, dynamic>>> _queuedWrites =
      <MapEntry<DocumentReference, Map<String, dynamic>>>[];

  void startTransaction() {
    _batch = FirebaseFirestore.instance.batch();
    _queuedWrites.clear(); // 9/10/2026 — the journal follows the batch.
  }

  Future<Either<Failure, dynamic>> commitTransaction() async {
    try {
      await _batch.commit();
      _queuedWrites.clear(); // 9/10/2026
      return Right(true);
    } catch (e, stackTrace) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  /// Function Name: [commitTransactionChecked]
  ///
  /// Purpose: ADDED 9/10/2026 — commit the queued writes inside ONE Firestore
  /// transaction whose first step is [check].
  ///
  /// [check] runs inside the transaction: it may read through the
  /// `Transaction` (those reads are what make a concurrent change retry this
  /// one), may add its own writes, and throws to refuse — in which case
  /// NOTHING queued is written. Firestore re-runs the whole callback on a
  /// retry, so [check] sees fresh data each attempt. The writes are applied
  /// after [check] with the same `merge: true` the batch used.
  ///
  /// Used for user-limit enforcement (`LicenceSeatGuard`): the limit is
  /// re-checked at commit time, not only when the screen opened.
  ///
  /// Parameters:
  /// - [check]: the in-transaction check; throw to abort.
  ///
  /// Returns: [Future<Either<Failure, dynamic>>] — `Right(true)` once
  /// committed; `Left` with the thrown error's text otherwise. The batch is
  /// reset either way so its writes can never be committed a second time.
  Future<Either<Failure, dynamic>> commitTransactionChecked(
      Future<void> Function(Transaction transaction) check) async {
    final List<MapEntry<DocumentReference, Map<String, dynamic>>> writes =
        List<MapEntry<DocumentReference, Map<String, dynamic>>>.of(
            _queuedWrites);
    try {
      await _firestore.runTransaction((Transaction transaction) async {
        await check(transaction);
        for (final MapEntry<DocumentReference, Map<String, dynamic>> write
            in writes) {
          transaction.set(write.key, write.value, SetOptions(merge: true));
        }
      });
      return Right(true);
    } catch (e, stackTrace) {
      debugPrint('commitTransactionChecked: not committed — $e\n$stackTrace');
      return Left(FeatureFailure(e.toString()));
    } finally {
      _batch = _firestore.batch();
      _queuedWrites.clear();
    }
  }

  /// Update role in Access_Employee collection within transaction
  void updateRoleWithinTransaction(
      {required String id, required Map<String, dynamic> data}) {
    DocumentReference documentReference = accessEmployeeCollection.doc(id);
    _batch.set(documentReference, data, SetOptions(merge: true));
    _queuedWrites.add(MapEntry(documentReference, data)); // 9/10/2026
  }

  /// Get employee model from Employees_Info collection
  Future<Either<Failure, dynamic>> getEmployeeModel(String employeeId) async {
    try {
      DocumentSnapshot doc = await employeesInfoCollection.doc(employeeId).get();

      if (!doc.exists) {
        return Left(FeatureFailure("Employee not found"));
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Right(data);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  /// Update employee model in Employees_Info collection within transaction
  /// Uses NewEmployeeModelHistory format to maintain history
  void updateEmployeeModel(
      {required String id, required Map<String, dynamic> data}) {
    DocumentReference documentReference = employeesInfoCollection.doc(id);

    // Use SET with merge to maintain the history format (arrays)
    _batch.set(documentReference, data, SetOptions(merge: true));
    _queuedWrites.add(MapEntry(documentReference, data)); // 9/10/2026
  }

  /// Batch operations for efficient bulk updates
  Future<Either<Failure, dynamic>> batchUpdateRoles(
      List<Map<String, dynamic>> roleUpdates) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (Map<String, dynamic> update in roleUpdates) {
        String roleId = update['roleId'];
        Map<String, dynamic> data = update['data'];

        DocumentReference docRef =
        _firestore.collection(ApiConstants.roles).doc(roleId);

        batch.update(docRef, data);
      }

      await batch.commit();
      return Right("Batch update completed successfully");
    } catch (e) {
      return Left(FeatureFailure("Batch update failed: $e"));
    }
  }

  /// Get role statistics
  Future<Either<Failure, dynamic>> getRoleStatistics() async {
    try {
      QuerySnapshot snapshot =
      await _firestore.collection(ApiConstants.roles).get();

      Map<String, int> statusCount = {};
      int totalRoles = snapshot.docs.length;
      int historyEnabledRoles = 0;

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Count by status
        String status = 'unknown';
        if (data.containsKey('Status') && data['Status'] is List) {
          List<dynamic> statuses = data['Status'];
          if (statuses.isNotEmpty) {
            status = statuses.last.toString();
          }
        }
        statusCount[status] = (statusCount[status] ?? 0) + 1;

        // Count history-enabled roles_module
        if (data.containsKey('timestamps') && data['timestamps'] is List) {
          historyEnabledRoles++;
        }
      }

      return Right({
        'totalRoles': totalRoles,
        'historyEnabledRoles': historyEnabledRoles,
        'legacyRoles': totalRoles - historyEnabledRoles,
        'statusDistribution': statusCount,
      });
    } catch (e) {
      return Left(FeatureFailure("Failed to get role statistics: $e"));
    }
  }

  /// Clean up old role versions (for maintenance)
  Future<Either<Failure, dynamic>> cleanupOldRoleVersions(
      {int keepLastN = 10}) async {
    try {
      QuerySnapshot snapshot =
      await _firestore.collection(ApiConstants.roles).get();

      WriteBatch batch = _firestore.batch();
      int updatedRoles = 0;

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('timestamps') && data['timestamps'] is List) {
          List<dynamic> timestamps = data['timestamps'];

          if (timestamps.length > keepLastN) {
            // Keep only the last N entries for each field
            Map<String, dynamic> cleanedData = {};

            data.forEach((key, value) {
              if (value is List && value.length > keepLastN) {
                cleanedData[key] = value.sublist(value.length - keepLastN);
              } else {
                cleanedData[key] = value;
              }
            });

            batch.update(doc.reference, cleanedData);
            updatedRoles++;
          }
        }
      }

      if (updatedRoles > 0) {
        await batch.commit();
      }

      return Right(
          "Cleaned up $updatedRoles roles_module, keeping last $keepLastN versions");
    } catch (e) {
      return Left(FeatureFailure("Cleanup failed: $e"));
    }
  }

  /// Get all access employees from Access_Employee collection
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getAllAccessEmployees() async {
    try {
      QuerySnapshot snapshot = await accessEmployeeCollection.get();
      List<Map<String, dynamic>> accessList = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['_documentId'] = doc.id;
        accessList.add(data);
      }

      return Right(accessList);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  /// Delete user access from Access_Employee collection
  Future<Either<Failure, dynamic>> deleteUserAccess(
      {required String id}) async {
    try {
      await accessEmployeeCollection.doc(id).delete();
      return Right(true);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  /// Update role directly (without transaction) in Access_Employee collection
  Future<Either<Failure, dynamic>> updateRole_AccessEmployee({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await accessEmployeeCollection.doc(id).set(data, SetOptions(merge: true));
      return Right(true);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }
}
