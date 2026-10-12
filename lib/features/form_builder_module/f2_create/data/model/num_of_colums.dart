import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of number of columns model
class NumOfColumns {
  List<String?>? numberofColumns;

  NumOfColumns({
    this.numberofColumns,
  });

  NumOfColumns copyWith({
    List<String?>? numberofColumns,
    List<Timestamp?>? timestamps,
  }) {
    return NumOfColumns(
      numberofColumns: numberofColumns ?? this.numberofColumns,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Num_Of_Columns': numberofColumns,
    };
  }

  factory NumOfColumns.fromMap(Map<String, dynamic> map) {
    return NumOfColumns(
      numberofColumns: map['Num_Of_Columns'] != null
          ? List<String?>.from(
              (map['Num_Of_Columns']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NumOfColumns.fromJson(String source) =>
      NumOfColumns.fromMap(json.decode(source) as Map<String, dynamic>);
}
