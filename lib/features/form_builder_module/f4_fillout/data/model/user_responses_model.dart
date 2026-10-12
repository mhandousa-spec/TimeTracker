// ignore: dangling_library_doc_comments
import 'package:cloud_firestore/cloud_firestore.dart';

///**************************** FILE INFO *************************/
/// File Name: user_responses_model.dart
/// Purpose : Holds user response forms ids
/// Author: Mohamed Elrashidy
/// Created At: 12/3/2025

class UserResponsesModel {
  final String email;
  final List<String> formIds;
  final List<Timestamp> submissionTimestamp;

  UserResponsesModel({
    required this.email,
    required this.formIds,
    required this.submissionTimestamp,
  });

  static const String emailField = 'Email';
  static const String formIdsField = 'Form_Ids';
  static const String submissionTimestampField = 'Submission_Timestamp';

  factory UserResponsesModel.fromMap(Map<String, dynamic> map) {
    return UserResponsesModel(
      email: map[emailField],
      formIds: List<String>.from( map[formIdsField]),
      submissionTimestamp: List<Timestamp>.from( map[submissionTimestampField]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      emailField: email,
      formIdsField: formIds,
      submissionTimestampField: submissionTimestamp,
    };
  }

  UserResponsesModel copyWith({
    String? email,
    List<String>? formIds,
    List<Timestamp>? submissionTimestamp,
  }) {
    return UserResponsesModel(
      email: email ?? this.email,
      formIds: formIds ?? this.formIds,
      submissionTimestamp: submissionTimestamp ?? this.submissionTimestamp,
    );
  }
}