import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a radio field, including title, alignment, arrangement, selected radio option, and requirement status.

/// Represents the model for a radio field
class RadioFieldModel extends FieldModel {
  /// Title of the radio field
  String title;

  /// Alignment of the radio field
  String alignment;

  /// Arrangement of the radio options (e.g., vertical, horizontal)
  String arrangement;

  /// Currently selected radio option
  String? selectedRadio;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of hint texts for the radio options
  List<String> hints = [];

  /// Constructor for initializing the RadioFieldModel instance
  RadioFieldModel({
    required this.title,
    required this.alignment,
    required this.isRequired,
    required this.hints,
    required this.arrangement,
    this.selectedRadio,
  }) : super(FormFieldType.radio);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.radio.name.toLowerCase(),
      arrangement: arrangement,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: selectedRadio,
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return RadioFieldModel(
      title: model.title!,
      alignment: model.alignment!.capitalize!,
      isRequired: model.isRequired!,
      hints: model.hint!.split(', '),
      arrangement: model.arrangement!.capitalize!,
      selectedRadio: model.response,
    );
  }

  /// Method to duplicate the radio field model
  /// Returns a new instance of RadioFieldModel with the same properties
  @override
  duplicate() {
    RadioFieldModel newModel = RadioFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hints: List<String>.from(hints),
      arrangement: arrangement,
      selectedRadio: selectedRadio,
    );
    return newModel;
  }

  @override
  RadioFieldController toController({bool isSetData = false}) {
    RadioFieldController controller = RadioFieldController();
    List<TextEditingController> hintsController = [];
    for (var element in hints) {
      hintsController.add(TextEditingController(text: element));
    }
    controller.hints = hintsController;
    controller.arrangement = arrangement;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) controller.selectedRadio = selectedRadio;
    return controller;
  }
}
