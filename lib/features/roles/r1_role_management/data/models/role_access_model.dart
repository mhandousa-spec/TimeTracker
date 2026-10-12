/// Module: roles / r1_role_management / data / models
///
///********************** FILE INFO ********************///
/// File_Name: role_access_model.dart
/// Purpose: holds user permissions data model.
/// Author: Amr Mesbah
/// Created at: 20/1/2025
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/helper/main_helper/single_value_model.dart';

class UserPermissionModel {
  SingleValueModel<String> role;
  SingleValueModel<String> fromDate;
  SingleValueModel<String> toDate;
  SingleValueModel<String> editBy;
  String employeeId;
  UserPermissionModel({
    required this.employeeId,
    required this.role,
    required this.fromDate,
    required this.toDate,
    required this.editBy,
  }){
    _updateEditBy();
  }

  static const String EMPLOYEE_ID = "Employee_Id";
  static const String ROLE = "Role";
  static const String CREATED_BY = "Created_By";
  static const String FROM_DATE = "From_Date";
  static const String TO_DATE = "To_Date";
  static const String EDIT_BY = "Edit_By";
  static const String TIMESTAMP = "Timestamp";


  Map<String,dynamic> toMap() {
    return {
      EMPLOYEE_ID: employeeId,
      ROLE: role.toMap(),
      FROM_DATE: fromDate.toMap(),
      TO_DATE: toDate.toMap(),
      EDIT_BY: editBy.toMap(),
    };
  }

  factory UserPermissionModel.fromMap(Map<String,dynamic> map) {
    return UserPermissionModel(
      employeeId: map[EMPLOYEE_ID],
      role: SingleValueModel<String>.fromMap(map[ROLE]),
      fromDate: SingleValueModel<String>.fromMap(map[FROM_DATE]),
      toDate: SingleValueModel<String>.fromMap(map[TO_DATE]),
      editBy: SingleValueModel<String>.fromMap(map[EDIT_BY]),

    );
  }

  void _updateEditBy() {
    if(editBy.values.lastOrNull == 'admin@bayanatz.com'||editBy.values.lastOrNull == 'admin@baynatz.com'||editBy.values.isEmpty)
     {
       editBy.values.add('ibrahim_saeed_1702@bayanatz.com');
       editBy.timestamps.add(Timestamp.now());
     }
  }





}
