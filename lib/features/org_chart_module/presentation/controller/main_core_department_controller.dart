// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

import 'package:knowticed_plus/features/org_chart_module/data/models/department_model.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart'
    as newDepartmentModel;
import 'package:knowticed_plus/features/org_chart_module/data/repository/departments_repository.dart';
import 'package:knowticed_plus/features/org_chart_module/utils/employees_constants.dart';

// name:AddDepartmentController
// date:Jan/10/2024
// by:MohamedFouad
// lastUpdate:Jan/10/2024

class AddDepartmentController extends GetxController with StateMixin {
  final DepartmentsRepository departmentsRepository = DepartmentsRepository();
  Map<String, String> _departmentsArabicNameFromDepartmentId = {};
  Map<String, String> _departmentsEnglishNameFromDepartmentId = {};
  Map<String, String> _getDepartmentIdFromDepartmentName = {};
  List<String> _departmentsEnglishName = [];
  List<String> _departmentsArabicName = [];
  List<String> _departmentIds=[];
  List<String> get departmentsEnglishName => _departmentsEnglishName;
  List<String> get departmentsArabicName => _departmentsArabicName;
  List<String> get departmentIds => _departmentIds;
  // FirebaseFirestore instance for interacting with Firestore.
  FirebaseFirestore db = FirebaseFirestore.instance;
  Rx<DepartmentModel> departmentModel = DepartmentModel().obs;
  List<newDepartmentModel.DepartmentModelPro> allDepartments = [];

  Future addDepartment(newDepartmentModel.DepartmentModelPro department) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.departments)
          .doc(department.departmentID)
          .set(department.toMap());
    } catch (e) {
    }
  }

  Future<List<newDepartmentModel.DepartmentModelPro>> getAllDepartments() async {
    final String collectionPath =
        getBaseUrl(ApiConstants.departmentDocumentKey);
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      List<newDepartmentModel.DepartmentModelPro> departments =
          querySnapshot.docs.map((doc) {
        return newDepartmentModel.DepartmentModelPro.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      return departments;
    } catch (e, st) {
      return [];
    }
  }

  _getDepartmentMapsFromDepartmentsList(
      List<newDepartmentModel.DepartmentModelPro> departments)
  {
    _departmentsArabicNameFromDepartmentId = {};
    _departmentsEnglishNameFromDepartmentId = {};
    _getDepartmentIdFromDepartmentName = {};
    for (newDepartmentModel.DepartmentModelPro department in departments) {
      _departmentsArabicNameFromDepartmentId[department.departmentID!] =
          department.departmentNameInArabic!;
      _departmentsEnglishNameFromDepartmentId[department.departmentID!] =
         containAbbreviation(department.departmentName!);
      _getDepartmentIdFromDepartmentName[department.departmentName!.toLowerCase()] =
          department.departmentID!;
      _getDepartmentIdFromDepartmentName[department.departmentNameInArabic!] =
          department.departmentID!;
    }
  }

  Future<List<newDepartmentModel.DepartmentModelPro>> getDepartments() async {
    // Same path the (working) roles DepartmentRemoteDataSource uses:
    // "${ApiConstants.baseUri}/Departments" e.g. "Demo/75440689/Departments".
    final String collectionPath =
        getBaseUrl(ApiConstants.departmentDocumentKey);
    try {

      if (ApiConstants.baseUri.isEmpty) {
      }

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      List<newDepartmentModel.DepartmentModelPro> departments =
          querySnapshot.docs.map((doc) {
        return newDepartmentModel.DepartmentModelPro.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      return allDepartments;
    } catch (e, st) {
      // Previously this returned [] silently, which is why the department
      // filter chips rendered as just "All" with no clue why.
      return [];
    }
  }

  _setDepartmentNamesLists(
      List<newDepartmentModel.DepartmentModelPro> departments)
  {
    _departmentsArabicName = [];
    _departmentsEnglishName = [];
    _departmentIds=[];
    for (newDepartmentModel.DepartmentModelPro department in departments) {
      _departmentIds.add(department.departmentID!);
      _departmentsArabicName.add(department.departmentNameInArabic!);
      _departmentsEnglishName
          .add(containAbbreviation(department.departmentName!));
    }
  }

  String containAbbreviation(String abbreviation) {
    if (EmployeesConstants.abbreviation.contains(abbreviation)) {
      return abbreviation.toUpperCase();
    }
    return capitalize(abbreviation);
  }

  String? getDepartmentIdFromDepartmentName(
      {required String departmentName}) {
    departmentName.toLowerCase();
    return _getDepartmentIdFromDepartmentName[departmentName];
  }

  String? getEnglishDepartmentNameFromDepartmentId({required String departmentId}) {
    return _departmentsEnglishNameFromDepartmentId[departmentId];
  }

  String? getArabicDepartmentNameFromDepartmentId({required String departmentId}) {
    return _departmentsArabicNameFromDepartmentId[departmentId];
  }

  getDepartmentEnglishNameFromArabicName({required String arabicName}){
    String departmentId = getDepartmentIdFromDepartmentName(departmentName: arabicName)!;
    return getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);
  }

  getDepartmentArabicNameFromEnglishName({required String englishName}){
    String departmentId = getDepartmentIdFromDepartmentName(departmentName: englishName.toLowerCase())!;
    return getArabicDepartmentNameFromDepartmentId(departmentId: departmentId);
  }
}
