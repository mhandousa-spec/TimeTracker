/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_backup_remote_data_source.dart
/// Purpose: All Firestore access for employee reads, writes and the two-level
///          backup/restore, lifted out of EmployeeController.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// `EmployeeController` previously held `FirebaseFirestore db` and ran queries,
/// merges, whole-collection deletes and the backup rotation directly from a UI
/// controller. All of it lives here now.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/models/employee_directory_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/utils/employee_collection_paths.dart';

class EmployeeBackupRemoteDataSource {
  EmployeeBackupRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _main =>
      _firestore.collection(EmployeeCollectionPaths.main);
  CollectionReference<Map<String, dynamic>> get _backupOne =>
      _firestore.collection(EmployeeCollectionPaths.backupOne);
  CollectionReference<Map<String, dynamic>> get _backupTwo =>
      _firestore.collection(EmployeeCollectionPaths.backupTwo);

  /// Function Name: [getEmployeeByEmail]
  ///
  /// Purpose: Find an employee whose `Email` array contains [email].
  ///
  /// Returns: [Future<NewEmployeeModelHistory?>] — `null` when not found.
  Future<NewEmployeeModelHistory?> getEmployeeByEmail(String email) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _main.where('Email', arrayContains: email).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return NewEmployeeModelHistory.fromMap(snapshot.docs.first.data());
  }

  /// Function Name: [getEmployeeDirectory]
  ///
  /// Purpose: Read the directory entry keyed by email.
  Future<EmployeeDirectoryModel?> getEmployeeDirectory(String email) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(ApiConstants.employeesDirectory).doc(email).get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return EmployeeDirectoryModel.fromMap(data);
  }

  /// Function Name: [saveEmployee]
  ///
  /// Purpose: Create or merge-update the employee document.
  Future<void> saveEmployee(NewEmployeeModelHistory employee) async {
    final String? id = employee.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Cannot save an employee without an id.');
    }
    await _main.doc(id).set(employee.toMap(), SetOptions(merge: true));
  }

  /// Function Name: [clearCollection]
  ///
  /// Purpose: Delete every document in [collection], in batches.
  ///
  /// **Destructive.** [confirmDestructive] must be `true`. The guard exists
  /// because this used to be a public method on a UI controller sitting one
  /// call away from the live `Employees_Info` collection — an accidental or
  /// mis-ordered call wipes the tenant's employees.
  ///
  /// Parameters:
  /// - [collection]: Target collection.
  /// - [confirmDestructive]: Must be `true`.
  ///
  /// Throws: [StateError] when the guard is not set.
  Future<void> clearCollection(
    CollectionReference<Map<String, dynamic>> collection, {
    required bool confirmDestructive,
  }) async {
    if (!confirmDestructive) {
      throw StateError(
        'clearCollection deletes every document in ${collection.path}. '
        'Pass confirmDestructive: true to proceed.',
      );
    }
    // Batched: the original deleted one document per round-trip, which is slow
    // and can partially fail on a large collection.
    const int batchLimit = 400;
    while (true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await collection.limit(batchLimit).get();
      if (snapshot.docs.isEmpty) break;
      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snapshot.docs.length < batchLimit) break;
    }
  }

  /// Function Name: [getBackupEmployees]
  ///
  /// Purpose: Read every document of one backup collection, so the Restore
  ///          dialog can show what a backup actually holds BEFORE the
  ///          destructive [restoreFromBackup] runs.
  ///
  /// ADDED 30/8/2026. `restoreFromBackup` was the only reader of these two
  /// collections and it reads them one step before clearing `Employees_Info` —
  /// there was no way to look at a backup without restoring it. The Restore
  /// button therefore showed a success dialog and touched no data at all.
  ///
  /// Parameters:
  /// - [backupVersion]: `'second'` for backup two, anything else for backup
  ///   one — the same convention [restoreFromBackup] uses, so the value the
  ///   dialog previews with is the value it restores with.
  ///
  /// Returns: [Future<List<NewEmployeeModelHistory>>] — empty when the backup
  ///          has never been written.
  Future<List<NewEmployeeModelHistory>> getBackupEmployees(
    String backupVersion,
  ) async {
    final CollectionReference<Map<String, dynamic>> backup =
        backupVersion == 'second' ? _backupTwo : _backupOne;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await backup.get();

    final List<NewEmployeeModelHistory> employees = <NewEmployeeModelHistory>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      try {
        employees.add(NewEmployeeModelHistory.fromMap(doc.data()));
      } catch (_) {
        // Same rule as EmployeesRepository.getAllEmployees: one malformed
        // document must not blank out the whole preview.
        continue;
      }
    }
    return employees;
  }

  /// Function Name: [backupCollections]
  ///
  /// Purpose: Roll the two-level backup — backup1 → backup2, then main →
  ///          backup1. Reads main first so the snapshot is consistent.
  Future<void> backupCollections() async {
    final QuerySnapshot<Map<String, dynamic>> mainSnapshot = await _main.get();
    final QuerySnapshot<Map<String, dynamic>> backupOneSnapshot =
        await _backupOne.get();

    await clearCollection(_backupTwo, confirmDestructive: true);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in backupOneSnapshot.docs) {
      await _backupTwo.doc(doc.id).set(doc.data(), SetOptions(merge: true));
    }

    await clearCollection(_backupOne, confirmDestructive: true);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in mainSnapshot.docs) {
      await _backupOne.doc(doc.id).set(doc.data(), SetOptions(merge: true));
    }
  }

  /// Function Name: [restoreFromBackup]
  ///
  /// Purpose: Replace the main collection with a backup's contents.
  ///
  /// **Destructive** — clears `Employees_Info` before copying.
  ///
  /// Parameters:
  /// - [backupVersion]: `'second'` for backup two, anything else for backup one.
  /// - [confirmDestructiveRestore]: Must be `true`.
  ///
  /// Throws: [StateError] when the guard is not set, or when the chosen backup
  ///         is empty — restoring from an empty backup would delete every
  ///         employee and replace them with nothing.
  Future<void> restoreFromBackup(
    String backupVersion, {
    required bool confirmDestructiveRestore,
  }) async {
    if (!confirmDestructiveRestore) {
      throw StateError(
        'restoreFromBackup replaces the entire employee collection. '
        'Pass confirmDestructiveRestore: true to proceed.',
      );
    }

    final CollectionReference<Map<String, dynamic>> backup =
        backupVersion == 'second' ? _backupTwo : _backupOne;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await backup.get();
    if (snapshot.docs.isEmpty) {
      throw StateError(
        'Backup "$backupVersion" is empty; refusing to clear the live '
        'employee collection.',
      );
    }

    await clearCollection(_main, confirmDestructive: true);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      await _main.doc(doc.id).set(doc.data(), SetOptions(merge: true));
    }
  }
}
