/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_details.dart
/// Purpose: Trial window and temporary credentials for a demo tenant.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

///******************************** FILE INFO *******************************///
/// File Name: demo_details.dart
/// Purpose: Contains company demo details.
/// Author: Amr Mesbah
/// Created At: 31/12/2024

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/helper/main_helper/single_value_model.dart';

class DemoDetails {
  String? reasonOfRejection;
  SingleValueModel<int>? numberOfUsers;
  SingleValueModel<Timestamp>? accessBegin;
  SingleValueModel<Timestamp>? accessEnd;
  SingleValueModel<String>? userName;
  SingleValueModel<String>? temporaryPassword;
  Timestamp responseTime;
  SingleValueModel<String> updatedBy;
  Map<Modules, SingleValueModel<bool>>? modules;
  DemoDetails({
    required this.reasonOfRejection,
    this.numberOfUsers,
    this.accessBegin,
    this.accessEnd,
    this.userName,
    this.temporaryPassword,
    required this.responseTime,
    required this.updatedBy,
    this.modules,
  });

  static const String REASON_OF_REJECTION = 'Reason_Of_Rejection';
  static const String NUMBER_OF_USERS = 'Number_Of_Users';
  static const String ACCESS_BEGIN = 'Access_Begin';
  static const String ACCESS = 'Access_End';
  static const String USER_NAME = 'User_Name';
  static const String TEMPORARY_PASSWORD = 'Temporary_Password';
  static const String RESPONSE_TIME = 'Response_Time';
  static const String UPDATED_BY = 'Updated_By';
  static const String MODULES = 'Modules';

  Map<String, dynamic> toMap() {
    return {
      REASON_OF_REJECTION: reasonOfRejection,
      NUMBER_OF_USERS: numberOfUsers?.toMap(),
      ACCESS_BEGIN: accessBegin?.toMap(),
      ACCESS: accessEnd?.toMap(),
      USER_NAME: userName?.toMap(),
      TEMPORARY_PASSWORD: temporaryPassword?.toMap(),
      RESPONSE_TIME: responseTime,
      UPDATED_BY: updatedBy.toMap(),
      MODULES: modules == null
          ? null
          : modules!.map((key, value) => MapEntry(key.name, value.toMap())),
    };
  }

  factory DemoDetails.fromMap(Map<String, dynamic> map) {
    return DemoDetails(
      reasonOfRejection: map[REASON_OF_REJECTION],
      numberOfUsers: map[NUMBER_OF_USERS] == null
          ? null
          : SingleValueModel.fromMap(map[NUMBER_OF_USERS]),
      accessBegin: map[ACCESS_BEGIN] == null
          ? null
          : SingleValueModel.fromMap(map[ACCESS_BEGIN]),
      accessEnd: map[ACCESS] == null
          ? null
          : SingleValueModel.fromMap(map[ACCESS]),
      userName: map[USER_NAME] == null
          ? null
          : SingleValueModel.fromMap(map[USER_NAME]),
      temporaryPassword: map[TEMPORARY_PASSWORD] == null
          ? null
          : SingleValueModel.fromMap(map[TEMPORARY_PASSWORD]),
      responseTime: map[RESPONSE_TIME],
      updatedBy: SingleValueModel.fromMap(map[UPDATED_BY]),
      modules: map[MODULES]?.map<Modules, SingleValueModel<bool>>(
              (key, value) => MapEntry(
                  Modules.values.firstWhere((element) => element.name == key),
                  SingleValueModel<bool>.fromMap(value)),
            ),
    );
  }
}
