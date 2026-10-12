import 'package:cloud_firestore/cloud_firestore.dart';

/// Module: services_app_module/share
///
/// FILE INFO
/// File Name   : forms_group_model.dart
/// Objective   : Immutable data model for a shared forms group (final fields
///               + copyWith, static const keys, toMap/fromMap) — §10.
/// Author      : Fouad
class FormsGroupModel {
  final String id;
  final List<String> image;
  final List<String> name;
  final List<String> description;
  final List<Timestamp> timestamp;
  final List<String> emails;
  final List<String> status;
  final bool isDeleted;

  FormsGroupModel({
    required this.id,
    required this.emails,
    required this.status,
    required this.image,
    required this.name,
    required this.description,
    required this.timestamp,
    this.isDeleted = false,
  });
  static const String fieldId = "Id";
  static const String fieldImage = "Image";
  static const String fieldName = "Group_Name";
  static const String fieldDescription = "Description";
  static const String fieldTimestamp = "Timestamp";
  static const String fieldStatus = "Status";
  static const String fieldEmails = "Emails";
  static const String fieldIsDeleted = "Is_Deleted";

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      fieldId: id,
      fieldImage: image,
      fieldName: name,
      fieldDescription: description,
      fieldTimestamp: timestamp,
      fieldEmails: emails,
      fieldStatus: status,
      fieldIsDeleted: isDeleted,
    };
  }

  factory FormsGroupModel.fromMap(Map<String, dynamic> map) {
    return FormsGroupModel(
      id: map[fieldId],
      image: List<String>.from(map[fieldImage]),
      name: List<String>.from(map[fieldName]),
      description: List<String>.from(map[fieldDescription]),
      timestamp: List<Timestamp>.from(map[fieldTimestamp]),
      emails: List<String>.from(map[fieldEmails]),
      status: List<String>.from(map[fieldStatus]),
      isDeleted: map[fieldIsDeleted] ?? false,
    );
  }

  FormsGroupModel copyWith({
    String? id,
    List<String>? image,
    List<String>? name,
    List<String>? description,
    List<Timestamp>? timestamp,
    List<String>? emails,
    List<String>? status,
    bool? isDeleted,
  }) {
    return FormsGroupModel(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      emails: emails ?? this.emails,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
