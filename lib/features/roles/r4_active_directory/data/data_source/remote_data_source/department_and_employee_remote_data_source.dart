/// Module: roles / r4_active_directory / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: department_and_employee_remote_data_source.dart
/// Purpose: Declares `DepartmentRemoteDataSource`, `MainCoreEmployeeRemoteDataSource`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Moved from `data/data_source/remote_data_source.dart`,
///          a stray file sitting beside the folder of the same name, and
///          renamed after the two data sources it actually declares.

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

class DepartmentRemoteDataSource {
  Future<dynamic> getDepartments() async {
    return await FirebaseRepository.getCollection(
        collectionPath: getBaseUrl(ApiConstants.departmentDocumentKey));
  }
}
class MainCoreEmployeeRemoteDataSource {
  Future<dynamic> getAllEmployees() async {
    return await FirebaseRepository.getCollection(
        collectionPath: getBaseUrl(ApiConstants.employeesInfo));
  }
}