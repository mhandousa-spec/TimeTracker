import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of status model
class StatusModel {
  List<String?>? status;

  StatusModel({
    this.status,
  });

  StatusModel copyWith({
    List<String?>? status,
    List<Timestamp?>? timestamps,
  }) {
    return StatusModel(
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Status': status,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      status: map['Status'] != null
          ? List<String?>.from(
              (map['Status']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatusModel.fromJson(String source) =>
      StatusModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
