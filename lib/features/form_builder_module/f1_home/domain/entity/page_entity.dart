import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/row_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/row_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/row_entity.dart';

// Date: 21/1/2025
// By: mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents a page model containing a list of row models
class PageEntity {
  /// List of rows in the page
  final List<RowEntity> rows;

  /// Constructor for initializing the PageModel instance
  PageEntity({required this.rows});

  PageControllerModel toController({bool isSetData = false}) {
    List<RowControllerModel> rowsModel = [];
    for (var row in rows) {
      rowsModel.add(row.toController(isSetData: isSetData));
    }

    PageControllerModel model = PageControllerModel(rows: rowsModel);

    return model;
  }

  PageEntity duplicate() {
    List<RowEntity> newRows = [];
    for (var row in rows) {
      newRows.add(row.duplicate());
    }
    return PageEntity(rows: newRows);
  }
  // to model

  PageModel toModel() {
    List<RowModel> rowsModel = [];
    for (var row in rows) {
      rowsModel.add(row.toModel());
    }

    return PageModel(rows: rowsModel);
  }
  //from model

  static PageEntity fromModel(PageModel model) {
    List<RowEntity> rowsModel = [];
    for (var row in model.rows) {
      rowsModel.add(RowEntity.fromModel(row));
    }
    return PageEntity(rows: rowsModel);
  }
}
