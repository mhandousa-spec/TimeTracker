
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/org_chart_module/data/data_source/remote_data_source/employees_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/models/employee_directory_model.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: EmployeesRepository
/// Purpose: This file contains the class for employees repository
/// Author: Mohamed Elrashidy
/// Created At: 5/11/2024
class EmployeesRepository {
  final EmployeesRemoteDataSource _remoteDataSource =
      EmployeesRemoteDataSource();

  /// Function Name : getAllEmployees
  /// Purpose: function to get all employees in form of employee model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee model or list of empty of map or failure
  Future<Either<Failure, List<NewEmployeeModelHistory>>> getAllEmployees() async {
    try {
      // ✅ Build the correct path using baseUri
      String collectionPath;

      if (ApiConstants.baseUri.isNotEmpty) {
        // Demo path: "Demo/84763782/Employees_Info"
        collectionPath = "${ApiConstants.baseUri}/${ApiConstants.employeeInfo}";
        // print("📍 Fetching employees from DEMO path: $collectionPath");
      } else {
        // Fallback to direct path if baseUri is empty
        collectionPath = ApiConstants.employeeInfo;
        // print("📍 Fetching employees from direct path: $collectionPath");
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .get();

      // print("📊 Found ${querySnapshot.docs.length} employee documents");

      List<NewEmployeeModelHistory> employees = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          NewEmployeeModelHistory employee = NewEmployeeModelHistory.fromMap(data);
          employees.add(employee);
        } catch (e) {
          // print("⚠️ Error parsing employee ${doc.id}: $e");
          continue;
        }
      }

      // print("✅ Successfully loaded ${employees.length} employees");
      return Right(employees);
    } catch (e) {
      // print("❌ Error in getAllEmployees: $e");
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name : getAllEmployeesDirectory
  /// Purpose: function to get all employees directory in form of employee directory model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee directory model or list of empty of map or failure
  Future<Either<Failure, dynamic>> getAllEmployeesDirectory() async {
    Either<Failure, dynamic> result;
    result = await _remoteDataSource.getAllEmployeesDirectory();
    if (result.isLeft()) return result;
    List<EmployeeDirectoryModel> directories = [];
    List<Map<String, dynamic>> data = result.getOrElse(() => []);
    for (var element in data) {
      directories.add(EmployeeDirectoryModel.fromMap(element));
    }
    result = Right(directories);
    return result;
  }

  Future<Either<Failure, dynamic>> isEmployeeExist(
      {required String employeeId}) async {
    Either<Failure, dynamic> result =
        await _remoteDataSource.getEmployee(employeeId: employeeId);
    if (result.isLeft()) return result;
    if (result.getOrElse(() => null) == null) {
      return result= Right(false);
    }
    return result = Right(true);
  }

  /// Function Name: [getEmployeeById]
  ///
  /// Purpose: Read one employee straight from the server, bypassing every
  /// in-memory list and Firestore's own local cache.
  ///
  /// Added 22/8/2026. The org chart holds its own copy of the employee list,
  /// loaded once by [getAllEmployees]. Editing a profile elsewhere in the app
  /// — the Social settings screen writes Academic_History, Skills and Hobbies
  /// — refreshes the *settings* controller and nothing else, so a profile
  /// opened from the org chart in the same session still rendered the document
  /// as it looked before the save. That is the other half of "when I add info
  /// it doesn't show here", and no amount of fixing the read helpers cures it.
  ///
  /// `Source.server` matters: without it Firestore can answer from its local
  /// cache, which is precisely the stale copy we are trying to get past.
  ///
  /// Parameters:
  /// - [employeeId]: the `Id` field of the `Employees_Info` document.
  ///
  /// Returns: [Future<Either<Failure, NewEmployeeModelHistory>>]
  Future<Either<Failure, NewEmployeeModelHistory>> getEmployeeById(
      String employeeId) async {
    if (employeeId.isEmpty) {
      return Left(FirebaseFailure('Employee id is missing.'));
    }

    try {
      final String collectionPath = ApiConstants.baseUri.isNotEmpty
          ? "${ApiConstants.baseUri}/${ApiConstants.employeeInfo}"
          : ApiConstants.employeeInfo;

      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(employeeId)
          .get(const GetOptions(source: Source.server));

      if (!snapshot.exists) {
        return Left(FirebaseFailure('Employee $employeeId not found.'));
      }

      final Map<String, dynamic> data =
          snapshot.data() as Map<String, dynamic>;
      data['Id'] = snapshot.id;

      return Right(NewEmployeeModelHistory.fromMap(data));
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<void> activateAccountOverview(String email, bool isDemoActivation) async {
    return await _remoteDataSource.activateAccountOverview(email, isDemoActivation);
  }
}


class EmployeesRepositoryPro {
  final EmployeesRemoteDataSource _remoteDataSource =
  EmployeesRemoteDataSource();

  /// Function Name : getAllEmployees
  /// Purpose: function to get all employees in form of employee model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee model or list of empty of map or failure
  Future<Either<Failure, List<NewEmployeeModelHistory>>> getAllEmployees() async {
    try {
      // ✅ Build the correct path using baseUri
      String collectionPath;

      if (ApiConstants.baseUri.isNotEmpty) {
        // Demo path: "Demo/84763782/Employees_Info"
        collectionPath = "${ApiConstants.baseUri}/${ApiConstants.employeeInfo}";
        // print("📍 Fetching employees from DEMO path: $collectionPath");
      } else {
        // Fallback to direct path if baseUri is empty
        collectionPath = ApiConstants.employeeInfo;
        // print("📍 Fetching employees from direct path: $collectionPath");
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .get();

      // print("📊 Found ${querySnapshot.docs.length} employee documents");

      List<NewEmployeeModelHistory> employees = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          NewEmployeeModelHistory employee = NewEmployeeModelHistory.fromMap(data);
          employees.add(employee);
        } catch (e) {
          // print("⚠️ Error parsing employee ${doc.id}: $e");
          continue;
        }
      }

      // print("✅ Successfully loaded ${employees.length} employees");
      return Right(employees);
    } catch (e) {
      // print("❌ Error in getAllEmployees: $e");
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name : getAllEmployeesDirectory
  /// Purpose: function to get all employees directory in form of employee directory model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee directory model or list of empty of map or failure
  Future<Either<Failure, dynamic>> getAllEmployeesDirectory() async {
    Either<Failure, dynamic> result;
    result = await _remoteDataSource.getAllEmployeesDirectory();
    if (result.isLeft()) return result;
    List<EmployeeDirectoryModel> directories = [];
    List<Map<String, dynamic>> data = result.getOrElse(() => []);
    for (var element in data) {
      directories.add(EmployeeDirectoryModel.fromMap(element));
    }
    result = Right(directories);
    return result;
  }

  Future<Either<Failure, dynamic>> isEmployeeExist(
      {required String employeeId}) async {
    Either<Failure, dynamic> result =
    await _remoteDataSource.getEmployee(employeeId: employeeId);
    if (result.isLeft()) return result;
    if (result.getOrElse(() => null) == null) {
      return result= Right(false);
    }
    return result = Right(true);
  }

  Future<void> activateAccountOverview(String email, bool isDemoActivation) async {
    return await _remoteDataSource.activateAccountOverview(email, isDemoActivation);
  }
}
