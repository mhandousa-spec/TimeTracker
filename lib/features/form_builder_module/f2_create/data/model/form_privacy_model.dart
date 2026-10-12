import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/users_model.dart';

class FormPrivacyModel {
  final UsersModel? usersModel;
  List<Timestamp>? timestamps;
  String? id;
  static const String fieldUid = 'Users';
  static const String fieldGroups = 'Groups';
  static const String fieldDepartments = 'Departments';
  static const String fieldTimestamps = 'Timestamps';
  static const String fieldAccessBegin = 'AccessBegin';
  static const String fieldAccessEnd = 'AccessEnd';
  static const String fieldEditPermission = 'EditPermission';

  FormPrivacyModel({this.usersModel, this.timestamps, this.id});

  Map<String, dynamic> toMap() {
    return {
      fieldUid: usersModel?.toMap(),
      fieldTimestamps: timestamps,
    };
  }

  factory FormPrivacyModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FormPrivacyModel(
      id: id,
      usersModel:
          map[fieldUid] != null ? UsersModel.fromMap(map[fieldUid]) : null,
      timestamps: map[fieldTimestamps] != null
          ? List<Timestamp>.from(map[fieldTimestamps] as List)
          : null,
    );
  }
}
