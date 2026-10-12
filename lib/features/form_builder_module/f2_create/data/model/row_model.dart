import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/num_of_colums.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/status_model.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of row model
class RowModel {
  List<ColumnModel> columns;

  RowModel({
    required this.columns,
  });

  RowModel copyWith({
    List<ColumnModel>? columns,
    NumOfColumns? numOfColumns,
    StatusModel? status,
  }) {
    return RowModel(
      columns: columns ?? this.columns,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Columns': columns.map((x) => x.toMap()).toList(),
    };
  }

  factory RowModel.fromMap(Map<String, dynamic> map) {
    return RowModel(
      columns: List<ColumnModel>.from(
        (map['Columns']).map<ColumnModel>(
          (x) => ColumnModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
