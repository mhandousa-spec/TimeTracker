import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/row_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/row_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents a row model containing a list of field models
class RowEntity {
  /// List of fields in the row
  List<FieldModel> fields;

  /// Constructor for initializing the RowModel instance
  RowEntity({required this.fields});

  RowControllerModel toController({bool isSetData = false}) {
    List<FieldController> controllers = [];
    for (var element in fields) {
      controllers.add(element.toController(isSetData: isSetData)!);
    }

    RowControllerModel model = RowControllerModel(controllers: controllers);
    model.numOfColumn!.text = FormDateTimeHelper.formatInt(controllers.length);
    return model;
  }

  RowEntity duplicate() {
    List<FieldModel> newFields = [];
    for (var element in fields) {
      newFields.add(element.duplicate()!);
    }

    return RowEntity(fields: newFields);
  }
  //toModel

  RowModel toModel() {
    List<ColumnModel> columnModel = [];
    for (var element in fields) {
      columnModel.add(element.toModel()!);
    }

    return RowModel(
      columns: columnModel,
    );
  }
  //from model

  static RowEntity fromModel(RowModel model) {
    List<FieldModel> fieldsModel = [];
    for (var element in model.columns) {
      fieldsModel.add(FieldModel.fromModel(element)!);
    }

    return RowEntity(fields: fieldsModel);
  }
}
