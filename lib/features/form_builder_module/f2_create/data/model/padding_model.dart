import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of padding model
class PaddingModel {
  List<String?>? padding;

  PaddingModel({
    this.padding,
  });

  PaddingModel copyWith({
    List<String?>? padding,
    List<Timestamp?>? timestamps,
  }) {
    return PaddingModel(
      padding: padding ?? this.padding,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Padding': padding,
    };
  }

  factory PaddingModel.fromMap(Map<String, dynamic> map) {
    return PaddingModel(
      padding: map['Padding'] != null
          ? List<String?>.from(
              (map['Padding']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaddingModel.fromJson(String source) =>
      PaddingModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
