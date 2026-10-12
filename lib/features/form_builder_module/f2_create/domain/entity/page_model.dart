import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/row_entity.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/row_model.dart';

class PageControllerModel {
  // List of row models for the page.
  List<RowControllerModel> rows;
  // Indicates whether this page is expanded or not.
  bool isPageExpanded;

  /// Constructor that initializes the page model with the given rows.
  /// By default, the page is expanded.
  PageControllerModel({required this.rows, this.isPageExpanded = true});

  /// Initializes the page model with the given rows.
  PageEntity toModel({bool isSetData=false}) {
    List<RowEntity> rowsModel = [];
    if (rows.isNotEmpty) {
      for (var row in rows) {
        rowsModel.add(row.toModel(isSetData: isSetData));
      }
    }
    return PageEntity(rows: rowsModel);
  }
}
