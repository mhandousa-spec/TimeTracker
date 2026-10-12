import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of status model
class UsersModel {
  List<String>? emails;
  List<String>? status;
  List<Timestamp?>? accessEnd;
  List<Timestamp?>? accessBegin;
  List<bool>? editPermission;
  UsersModel({
    this.emails,
    this.status,
    this.accessEnd,
    this.accessBegin,
    this.editPermission,
  });

  static const String EMAILSFEILD = "Emails";
  static const String STATUSFIELD = "Status";
  static const String ACCESSBEGIN = "Access Begin";
  static const String ACCESSEND = "Access End";
  static const String EDITPERMISSION = "Edit Permission";

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      EMAILSFEILD: emails,
      STATUSFIELD: status,
      ACCESSEND: accessEnd,
      ACCESSBEGIN: accessBegin,
      EDITPERMISSION: editPermission,
    };
  }

  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      emails: List<String>.from((map[EMAILSFEILD])),
      status: List<String>.from((map[STATUSFIELD])),
      accessEnd: map[ACCESSEND] != null
          ? List<Timestamp?>.from((map[ACCESSEND]))
          : null,
      accessBegin: map[ACCESSBEGIN] != null
          ? List<Timestamp?>.from((map[ACCESSBEGIN]))
          : null,
      editPermission: map[EDITPERMISSION] != null
          ? List<bool>.from((map[EDITPERMISSION]))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UsersModel.fromJson(String source) =>
      UsersModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
