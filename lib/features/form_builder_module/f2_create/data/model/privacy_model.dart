import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of privacy model
class PrivacyModel {
  List<String?>? privacy;

  PrivacyModel({
    this.privacy,
  });

  PrivacyModel copyWith({
    List<String?>? privacy,
    List<Timestamp?>? timestamps,
  }) {
    return PrivacyModel(
      privacy: privacy ?? this.privacy,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Privacy': privacy,
    };
  }

  factory PrivacyModel.fromMap(Map<String, dynamic> map) {
    return PrivacyModel(
      privacy: map['Privacy'] != null
          ? List<String?>.from(
              (map['Privacy']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PrivacyModel.fromJson(String source) =>
      PrivacyModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
