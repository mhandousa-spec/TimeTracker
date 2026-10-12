/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: single_value_model.dart
/// Purpose: Declares `SingleValueModel`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// **************************** FILE INFO **************************** ///
/// Purpose: Model for employee insurance data
/// Author: Amr Mesbah
/// created At: 20/11/2024


import 'package:cloud_firestore/cloud_firestore.dart';

class SingleValueModel<T>{
  List<T> values;
  List<Timestamp>timestamps;

  SingleValueModel({
    required this.values,
    required this.timestamps,
  });

  static const String valuesKey = 'Values';
  static const String timestampsKey = 'Timestamps';

  Map<String, dynamic> toMap() {
    return {
      valuesKey: values,
      timestampsKey: timestamps,
    };
  }

  factory SingleValueModel.fromMap(Map<String, dynamic> map) {

    return SingleValueModel(
      values: List<T>.from(map[valuesKey] as List),
      timestamps: List<Timestamp>.from(map[timestampsKey] as List),
    );
  }

}