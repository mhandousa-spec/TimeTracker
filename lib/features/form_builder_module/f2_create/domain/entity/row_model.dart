import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/row_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class RowControllerModel {
  // List of field controllers for the row.
  List<FieldController> controllers;
  // Text controller for the number of columns in the row.
  TextEditingController? numOfColumn;
  // Indicates whether this row is expanded or not.
  bool isRowExpanded;

  /// Constructor that initializes the row model with the given controllers.
  /// By default, the row is expanded and has one column.
  RowControllerModel({this.isRowExpanded = true, required this.controllers}) {
    numOfColumn = TextEditingController(text: FormDateTimeHelper.formatInt(1));
  }

  /// Creates a duplicate of the current row model.
  duplicate() {
    var newRow =
        RowControllerModel(controllers: [], isRowExpanded: isRowExpanded);
    newRow.numOfColumn?.text = numOfColumn?.text ?? '1';
    for (var element in controllers) {
      newRow.controllers.add(element.duplicate()!);
    }
    return newRow;
  }

  /// Initializes the row model with the given controllers.
  RowEntity toModel({bool isSetData=false}) {
    List<FieldModel> fields = [];
    for (var controller in controllers) {
      fields.add(controller.toModel(isSetAnswer: isSetData));
    }
    return RowEntity(fields: fields);
  }
}
