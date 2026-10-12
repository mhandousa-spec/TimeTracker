import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of orientation model
class OrientationModel {
  List<String?>? orientation;

  OrientationModel({
    this.orientation,
  });

  OrientationModel copyWith({
    List<String?>? orientation,
    List<Timestamp?>? timestamps,
  }) {
    return OrientationModel(
      orientation: orientation ?? this.orientation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Orientation': orientation,
    };
  }

  factory OrientationModel.fromMap(Map<String, dynamic> map) {
    return OrientationModel(
      orientation: map['Orientation'] != null
          ? List<String?>.from(
              (map['Orientation']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrientationModel.fromJson(String source) =>
      OrientationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
