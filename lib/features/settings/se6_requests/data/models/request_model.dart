/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_model.dart
/// Purpose: The legacy `User_Requests` document, still read by the login
///          bootstrap through `RequestController`.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N10/N14/N17: fields are final with a
///          `copyWith`; the Firestore keys are `static const`; the ~150 lines
///          of commented-out dead fields are deleted, taking the file from 227
///          LOC to under the 200-line model cap; `fromMap` takes a typed map;
///          and the file carries the standard header.
///
/// SCOPE NOTE: this is the *old* single-field request shape. The current flow
/// writes one document per submission with a `changes` array, modelled by
/// `ChangeRequest`. Only `getuserRequests` / `getAllRequests` still read this,
/// and only during login — the two are deliberately kept apart rather than
/// merged, because they describe different documents.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class RequestsModel {
  const RequestsModel({
    this.department,
    this.role,
    this.section,
    this.whatChanged,
    this.status,
    this.dateRequest,
    this.requestId,
    this.currentData,
    this.newData,
    this.image,
    this.firstName,
    this.lastName,
    this.email,
  });

  /// Firestore field keys. Were repeated as literals across `fromMap` and
  /// `toMap`, so a rename had to be made twice.
  static const String keyRequestId = 'Request_Id';
  static const String keyCurrentData = 'Current_Data';
  static const String keyNewData = 'New_Data';
  static const String keyImage = 'Image';
  static const String keyDateRequest = 'Date_Request';
  static const String keySection = 'Section';
  static const String keyStatus = 'Status';
  static const String keyDepartment = 'Department';
  static const String keyRole = 'Role';
  static const String keyFirstName = 'First_Name';
  static const String keyLastName = 'Last_Name';
  static const String keyEmail = 'Email';
  static const String keyWhatChanged = 'What_Changed';

  final String? department;
  final String? role;
  final String? section;
  final String? whatChanged;
  final String? status;
  final Timestamp? dateRequest;
  final String? requestId;
  final String? currentData;
  final String? newData;
  final String? image;
  final String? firstName;
  final String? lastName;
  final String? email;

  factory RequestsModel.fromMap(Map<dynamic, dynamic> data) {
    return RequestsModel(
      department: data[keyDepartment] as String?,
      role: data[keyRole] as String?,
      image: data[keyImage] as String?,
      firstName: data[keyFirstName] as String?,
      lastName: data[keyLastName] as String?,
      email: data[keyEmail] as String?,
      section: data[keySection] as String?,
      status: data[keyStatus] as String?,
      whatChanged: data[keyWhatChanged] as String?,
      dateRequest: data[keyDateRequest] as Timestamp?,
      requestId: data[keyRequestId] as String?,
      currentData: data[keyCurrentData] as String?,
      newData: data[keyNewData] as String?,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        keyRequestId: requestId,
        keyCurrentData: currentData,
        keyNewData: newData,
        keyImage: image,
        keyDateRequest: dateRequest,
        keySection: section,
        keyStatus: status,
        keyDepartment: department,
        keyRole: role,
        keyFirstName: firstName,
        keyLastName: lastName,
        keyEmail: email,
        keyWhatChanged: whatChanged,
      };

  /// Was mutated in place (`requestsModel.status = status`) by the four write
  /// methods that have since been deleted.
  RequestsModel copyWith({
    String? department,
    String? role,
    String? section,
    String? whatChanged,
    String? status,
    Timestamp? dateRequest,
    String? requestId,
    String? currentData,
    String? newData,
    String? image,
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return RequestsModel(
      department: department ?? this.department,
      role: role ?? this.role,
      section: section ?? this.section,
      whatChanged: whatChanged ?? this.whatChanged,
      status: status ?? this.status,
      dateRequest: dateRequest ?? this.dateRequest,
      requestId: requestId ?? this.requestId,
      currentData: currentData ?? this.currentData,
      newData: newData ?? this.newData,
      image: image ?? this.image,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }
}
