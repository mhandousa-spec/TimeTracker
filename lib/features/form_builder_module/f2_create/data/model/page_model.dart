import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/row_model.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of page model
class PageModel {
  List<RowModel> rows;

  PageModel({
    required this.rows,
  });

  PageModel copyWith({
    List<RowModel>? rows,
  }) {
    return PageModel(
      rows: rows ?? this.rows,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Rows': rows.map((x) => x.toMap()).toList(),
    };
  }

  factory PageModel.fromMap(Map<String, dynamic> map) {
    return PageModel(
      rows: List<RowModel>.from((map['Rows'] as List<dynamic>)
          .map<RowModel>((x) => RowModel.fromMap(x as Map<String, dynamic>))),
    );
  }
}
