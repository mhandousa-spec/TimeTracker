/// Module: roles / r3_user_access / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_remote_data_source.dart
/// Purpose: Declares `UserAccessRemoteDataSource`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header;
///          collection names routed through FirebaseCollections (§15).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';

// PORTING NOTE (services_app): services_app mixes in
// `EmployeeMixinRemoteDataSource` here, but this class already defines its own
// `getEmployees()`, `getEmployeeModel()` and `updateEmployeeModel()` - every
// member that mixin provides - so the mixin was fully shadowed and is dropped.
class UserAccessRemoteDataSource {
  WriteBatch _batch = FirebaseFirestore.instance.batch();

  /// Get all employees from Employees_Info collection
  /// getEmployees - ✅ FIXED: Now fetches from server to avoid stale cache
  Future<Either<Failure, dynamic>> getEmployees() async {
    try {

      // ✅ CRITICAL FIX: Force server read to get latest data after updates
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl(FirebaseCollections.employeesInfo))
          .get(GetOptions(source: Source.server));  // ← Force server read!


      List<Map<String, dynamic>> employees = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['Id'] = doc.id;

        // ✅ Debug: Print status for verification
        if (data['Status'] != null && data['Status'] is List) {
          List<dynamic> statusList = data['Status'] as List;
      // (was an `if (statusList.isNotEmpty) {}` shell left behind by a
      //  removed debug print)
        }

        employees.add(data);
      }

      return Right(employees);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// ✅ ADD THIS METHOD - Get single employee by ID
  Future<Either<Failure, dynamic>> getEmployeeModel(String employeeId) async {
    try {
      String collectionPath = getBaseUrl(FirebaseCollections.employeesInfo);

      // ✅ Force server read to get fresh data
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(employeeId)
          .get(GetOptions(source: Source.server));

      if (!docSnapshot.exists) {
        return Left(FirebaseFailure('Employee not found'));
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      data['Id'] = employeeId;  // ✅ Ensure ID is in the data


      return Right(data);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// ✅ ADD THIS METHOD - Update employee model
  Future<Either<Failure, dynamic>> updateEmployeeModel(
      NewEmployeeModelHistory employeeModel) async {
    try {
      String collectionPath = getBaseUrl(FirebaseCollections.employeesInfo);

      Map<String, dynamic> dataToSave = employeeModel.toMap();


      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(employeeModel.id)
          .set(dataToSave, SetOptions(merge: true));

      return Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> getDemoUserAccount(String email) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.demoUsersAccounts, documentId: email);
  }

  void startTransaction() {
    _batch = FirebaseFirestore.instance.batch();
  }

  void updateEmployeeWithinTransaction(NewEmployeeModelHistory employeeModel) {
    _batch.update(
        FirebaseFirestore.instance
            .collection(getBaseUrl(FirebaseCollections.employeesInfo))
            .doc(employeeModel.id!),
        employeeModel.toMap());
  }

  void updateDemoUsersAccountWithinTransaction(
      String email, Map<String, dynamic> data) {
    _batch.update(
        FirebaseFirestore.instance
            .collection(ApiConstants.demoUsersAccounts)
            .doc(email),
        data);
  }

  Future<Either<FirebaseFailure, dynamic>> commitTransaction() async {
    Either<FirebaseFailure, dynamic> result;
    try {
      await _batch.commit();
      result = Right(null);
    } catch (e) {
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }
}