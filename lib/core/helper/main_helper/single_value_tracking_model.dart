/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: single_value_tracking_model.dart
/// Purpose: Declares `SingleValueTrackingModel`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

class SingleValueTrackingModel<T>{
  List<T> values;
  List<Timestamp> timestamps;

  SingleValueTrackingModel({
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

  factory SingleValueTrackingModel.fromMap(Map<String, dynamic> map) {
    return SingleValueTrackingModel(
      values: List<T>.from(map[valuesKey] as List),
      timestamps: List<Timestamp>.from(map[timestampsKey] as List),
    );
  }

}