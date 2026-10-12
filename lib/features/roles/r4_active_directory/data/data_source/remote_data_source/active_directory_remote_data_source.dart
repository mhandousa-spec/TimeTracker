/// Module: roles / r4_active_directory / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: active_directory_remote_data_source.dart
/// Purpose: Declares `ActiveDirectoryRemoteDataSource`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_access_model.dart';

class ActiveDirectoryRemoteDataSource {
  WriteBatch? _currentBatch;
  int _operationCount = 0;
  List<WriteBatch> _batches = [];

  static const int MAX_BATCH_OPERATIONS = 450; // Leave some buffer

  /// Helper method to build the correct collection path with base URI
  String _buildCollectionPath(String collectionName) {
    if (ApiConstants.baseUri.isNotEmpty) {
      return '${ApiConstants.baseUri}/$collectionName';
    }
    return collectionName;
  }

  startTransaction() {
    _batches = [];
    _operationCount = 0;
    _currentBatch = FirebaseFirestore.instance.batch();
    _batches.add(_currentBatch!);
  }

  void _checkBatchLimit() {
    _operationCount++;
    if (_operationCount >= MAX_BATCH_OPERATIONS) {
      _currentBatch = FirebaseFirestore.instance.batch();
      _batches.add(_currentBatch!);
      _operationCount = 0;
    }
  }


  void removeEmployeeWithinTransaction({required String employeeId}) {
    _checkBatchLimit();

    // Build the correct path (same as uploadEmployeeWithinTransaction)
    String collectionPath = _buildCollectionPath(ApiConstants.employeeInfo);

    _currentBatch!.delete(FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(employeeId));
  }


  Future<Either<Failure, void>> endTransaction() async {

    try {
      int batchNumber = 1;
      for (var batch in _batches) {
        await batch.commit();
        batchNumber++;
      }

      return Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  void uploadWrongEmployeeWithinTransaction({required NewEmployeeModelHistory employee}) {
    _checkBatchLimit();

    // ✅ Build the correct path
    String collectionPath = _buildCollectionPath(ApiConstants.wrongEmployees);

    _currentBatch!.set(
        FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(employee.id),
        employee.toMap());
  }

  void uploadEmployeeWithinTransaction({required NewEmployeeModelHistory employee}) {
    _checkBatchLimit();

    // ✅ Build the correct path
    String collectionPath = _buildCollectionPath(ApiConstants.employeeInfo);

    _currentBatch!.set(
        FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(employee.id),
        employee.toMap());
  }

  void uploadUserAccessWithinTransaction({
    required UserPermissionModel usersAccessModel,
    required String employeeId
  }) {
    _checkBatchLimit();

    // ✅ FIXED: Use directly, don't call _buildCollectionPath()
    String collectionPath = ApiConstants.userAccess;

    _currentBatch!.set(
        FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(employeeId),
        usersAccessModel.toMap());

  }

  void uploadDepartmentWithinTransaction({required DepartmentModelPro department}) {
    _checkBatchLimit();

    // ✅ FIXED: Use directly, don't call _buildCollectionPath()
    String collectionPath = ApiConstants.departments;

    _currentBatch!.set(
        FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(department.departmentID),
        department.toMap());

  }

  void uploadAccessTypeWithinTransaction({required RoleHistoryModel accessType}) {
    _checkBatchLimit();

    // ✅ FIXED: Use directly, don't call _buildCollectionPath()
    String collectionPath = ApiConstants.roles;

    _currentBatch!.set(
        FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(accessType.roleId),
        accessType.toMap());

  }

  void removeWrongEmployeeWithinTransaction({required String employeeId}) {
    _checkBatchLimit();

    // ✅ Build the correct path
    String collectionPath = _buildCollectionPath(ApiConstants.wrongEmployees);

    _currentBatch!.delete(FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(employeeId));
  }

  uploadDemoUserOverviewWithinTransaction({required DemoUserAccountOverview employee}) {
    _checkBatchLimit();

    // ✅ This is a root-level collection, don't use base URI
    _currentBatch!.set(
        FirebaseFirestore.instance
            .collection(ApiConstants.demoUsersAccounts)
            .doc(employee.email),
        employee.toMap());
  }

  void removeEmployeeAdminDefaultModel() {
    _checkBatchLimit();

    // ✅ Build the correct path
    String collectionPath = _buildCollectionPath(ApiConstants.employeeInfo);

    _currentBatch!.delete(FirebaseFirestore.instance
        .collection(collectionPath)
        .doc('1'));
  }

  void removeUserAccessAdminDefaultModel() {
    _checkBatchLimit();

    // ✅ Build the correct path
    String collectionPath = _buildCollectionPath(ApiConstants.userAccess);

    _currentBatch!.delete(FirebaseFirestore.instance
        .collection(collectionPath)
        .doc('1'));
  }

  // Keep these methods as-is (they don't use batch)
  getDemoUserAccountOverview({required String currentUserEmail}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.demoUsersAccounts,
        documentId: currentUserEmail);
  }

  Future<Either<Failure, dynamic>> getDemoDetails({required String companyName}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.demoRequests,
        documentId: companyName);
  }
}