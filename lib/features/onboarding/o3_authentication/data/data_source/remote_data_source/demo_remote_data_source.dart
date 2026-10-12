/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_remote_data_source.dart
/// Purpose: Firestore reads for demo companies, roles and user access.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N02: moved into the `remote_data_source/` sub-folder and renamed
///          to match the FILE INFO block, which already said `demo_remote_data_source.dart`.

///************************** FILE INFO **************************///
/// File Name: demo_remote_data_source.dart
/// Purpose: Contains the remote data source for demo login feature.
/// Author: Amr Mesbah
/// Created At: 1/1/2025
/// ✅ FINAL FIX: Roles collection with timestamp ID and correct paths
/// ✅ UPDATED: Added getModuleUserLimits() and getModuleUserCount() for per-module user limit feature
/// (REMOVED again 9/10/2026 — unused; see LicenceSeatGuard in r2_user_management.)
/// Updated: 9/10/2026 - DEBUG-ONLY `debugGetCompanyEmployees` /
///          `debugGetCompanyDepartments` (read-only) for the "Switch to test
///          employee" picker; both refuse outside a debug build.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_access_model.dart';
// ADDED 9/10/2026 — DEBUG-ONLY guard for the test-employee switch reads.
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';

class DemoRemoteDataSource {
  WriteBatch batch = FirebaseFirestore.instance.batch();
  String? _currentCompanyId;

  /// Get demo account overview by email
  getDemoAccountOverview({required String email}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.demoUsersAccounts, documentId: email);
  }

  /// Get company demo request by company ID
  getCompanyDemoRequest({required String companyId}) async {
    return await FirebaseRepository.getDocumentWithId(
      collection: ApiConstants.demoRequests,
      documentId: companyId,
    );
  }

  /// ✅ Set current company ID
  void setCurrentCompanyId(String companyId) {
    _currentCompanyId = companyId;
    // print('📍 Set current company ID: $companyId');
  }

  /// ✅ Get current company ID
  String? getCurrentCompanyId() {
    return _currentCompanyId;
  }

  /// Start a new batch transaction
  startTransaction() {
    batch = FirebaseFirestore.instance.batch();
    // print('🔄 Transaction started, batch initialized');
  }

  /// Commit the batch transaction
  endTransaction() async {
    Either<Failure, dynamic> result;
    try {
      // print('💾 Committing batch with company ID: $_currentCompanyId...');
      await batch.commit();
      // print('✅ Batch committed successfully');
      result = Right(null);
    } catch (e) {
      // print('❌ Batch commit failed: $e');
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }

  /// Upload employee within transaction
  void uploadEmployeeWithinTransaction({required NewEmployeeModelHistory employee}) {
    String fullPath = "Demo/$_currentCompanyId/Employees_Info";
    // print('📝 Adding employee to batch: $fullPath/${employee.id}');

    batch.set(
        FirebaseFirestore.instance
            .collection(fullPath)
            .doc(employee.id),
        employee.toMap());
  }

  /// ✅ FIXED: Upload user access with correct path
  uploadUserAccessWithinTransaction(
      {required UserPermissionModel usersAccessModel, String? employeeId}) {
    String fullPath = "Demo/$_currentCompanyId/Users_Access";
    // print('📝 Adding user access to batch: $fullPath/$employeeId');

    batch.set(
        FirebaseFirestore.instance
            .collection(fullPath)
            .doc(employeeId),
        usersAccessModel.toMap());
  }

  /// ✅ CRITICAL FIX: Upload role to Roles collection with TIMESTAMP as document ID
  void uploadAccessTypeWithinTransaction({required RoleHistoryModel accessType}) {
    // ✅ Use roleId (TIMESTAMP) as document ID, NOT roleName!
    String roleId = accessType.roleId;  // ✅ This is the timestamp!

    // ✅ Build correct path without duplication
    String fullPath = "Demo/$_currentCompanyId/Roles";

    // print('📝 Adding role to batch: $fullPath/$roleId');
    // print('📝 Role ID (timestamp): $roleId');
    // print('📝 Role Name: ${accessType.currentRoleName}');
    // print('📝 Selected Modules: ${accessType.selectedModules}');

    batch.set(
        FirebaseFirestore.instance
            .collection(fullPath)
            .doc(roleId),
        accessType.toMap());
  }

  /// ✅ FIXED: Upload module permissions with correct path
  void uploadModulePermissionWithinTransaction({
    required String collectionName,
    required String roleId,
    required Map<String, dynamic> permissions,
  }) {
    String fullPath = "Demo/$_currentCompanyId/$collectionName";

    // print('📝 Adding module permissions to batch:');
    // print('   Path: $fullPath/$roleId');
    // print('   Role ID: $roleId');
    // print('   Permission count: ${permissions.length - 2}');

    batch.set(
        FirebaseFirestore.instance
            .collection(fullPath)
            .doc(roleId),
        permissions);
  }

  /// Get employee account by email
  getEmployeeAccount({required String email}) async {
    String collectionPath;

    if (ApiConstants.baseUri.isNotEmpty) {
      collectionPath = "${ApiConstants.baseUri}/Employees_Info";
    } else {
      collectionPath = "Employees_Info";
    }

    // print("📍 Fetching employee account from: '$collectionPath'");
    // print("📍 Looking for email: $email");

    return await FirebaseRepository.getDocumentWithFieldLasValue(
        collection: collectionPath,
        field: 'Email',
        value: email);
  }

  /// Get employee permission by employee ID
  /// ✅ UPDATED: Query the correct collection name
  Future<Either<Failure, dynamic>> getEmployeePermission({
    required String employeeId
  }) async {

    // Declared OUTSIDE the try so the `catch` below can name the path it
    // failed on — it used to live inside, where the handler could not see it.
    final String fullPath = "${ApiConstants.baseUri}/Users_Access/$employeeId";

    try {
      // ⚠️ THE ACCESS WINDOW LIVES IN `Users_Access`, NOT `User_Management`.
      //
      // Both collections carry From_Date / To_Date maps with the same shape,
      // and only this one gates sign-in — the Role Management calendar reads
      // the other. Editing the wrong copy changes nothing about who can log
      // in, which is impossible to tell from the "Access Denied" dialog, so
      // the path actually read is logged rather than described. ADDED
      // 30/8/2026.
      // kDebugMode-gated: this fires on EVERY sign-in, and `debugPrint` is not
      // stripped from release builds — an ungated line would log the tenant
      // path and employee id in production. Matches how
      // `AppNotificationSender` gates its own diagnostics.
      if (kDebugMode) {
        debugPrint('[login] reading access record: $fullPath');
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .doc(fullPath)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          debugPrint(
            '[login] no access record at $fullPath — active employee allowed '
            'through with no date window.',
          );
        }
        return Right(null);
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return Right(data);
    } catch (e, stackTrace) {
      // DIAGNOSTIC 7/9/2026. The path was logged on the way IN (above, when
      // kDebugMode) but not on the way out, so a permission-denied here read
      // as "Failed to fetch employee permissions: [cloud_firestore/
      // permission-denied]…" with nothing tying it to `$fullPath`.
      FirebaseRepository.logFirestoreFailure(
          'getEmployeePermission', fullPath, e);
      return Left(FirebaseFailure("Failed to fetch employee permissions: ${e.toString()}"));
    }
  }


  /// Get company's actual number of users
  getCompanyActualNumberOfUsers({required String companyId}) async {
    String collectionPath = "Demo/$companyId/Employees_Info";
    // print("📍 Counting users in collection: '$collectionPath'");

    return await FirebaseRepository.getNumberOfDocumentsInACollection(
        collection: collectionPath);
  }

  /// Function Name: [debugGetCompanyEmployees]
  ///
  /// Purpose: DEBUG-ONLY 9/10/2026 — every `Demo/{companyId}/Employees_Info`
  /// document, for the "Switch to test employee" picker. Read only.
  ///
  /// Refuses outside a debug build ([isDebugTestEmployeeSwitchEnabled]).
  ///
  /// Parameters:
  /// - [companyId]: the company typed in the picker (e.g. `DM-003`).
  ///
  /// Returns: [Future<Either<Failure, dynamic>>] — the raw maps on success.
  Future<Either<Failure, dynamic>> debugGetCompanyEmployees(
      {required String companyId}) async {
    if (!isDebugTestEmployeeSwitchEnabled()) {
      return const Left(FeatureFailure('debug-only'));
    }
    return FirebaseRepository.getCollection(
        collectionPath: 'Demo/$companyId/${ApiConstants.employeesInfo}');
  }

  /// Function Name: [debugGetCompanyDepartments]
  ///
  /// Purpose: DEBUG-ONLY 9/10/2026 — `Demo/{companyId}/Departments`, so the
  /// picker can show department names instead of ids. Read only.
  ///
  /// Parameters:
  /// - [companyId]: the company typed in the picker.
  ///
  /// Returns: [Future<Either<Failure, dynamic>>] — the raw maps on success.
  Future<Either<Failure, dynamic>> debugGetCompanyDepartments(
      {required String companyId}) async {
    if (!isDebugTestEmployeeSwitchEnabled()) {
      return const Left(FeatureFailure('debug-only'));
    }
    return FirebaseRepository.getCollection(
        collectionPath:
            'Demo/$companyId/${ApiConstants.departmentDocumentKey}');
  }

  // REMOVED 9/10/2026: `getModuleUserLimits` / `getModuleUserCount` — 0 call
  // sites, and the counter had the bugs that kept the limits from ever
  // blocking: it matched roles on `roleName` (roles are saved as `Name`) and
  // counted `Users_Access` (grants are written to `User_Management`). The
  // per-module user limits are read and enforced by
  // r2_user_management/data/services/licence_seat_guard.dart.
}