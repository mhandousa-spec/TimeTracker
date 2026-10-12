import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a radio text field, including title, alignment, and requirement status.

/// Represents the model for a radio text field
class RadioTextFieldModel extends FieldModel {
  /// List of hint texts for the radio options
  List<String> hints = [];

  /// Flag to determine if the field is required
  bool isRequired;
  String? selectedRadio;

  /// Constructor for initializing the RadioTextFieldModel instance
  RadioTextFieldModel({
    required this.isRequired,
    required this.hints,
    this.selectedRadio,
  }) : super(FormFieldType.radioTextField);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: null,
      alignment: null,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.radioTextField.name.toLowerCase(),
      arrangement: null,
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
    return RadioTextFieldModel(
      isRequired: model.isRequired ?? false,
      hints: model.hint?.split(', ') ?? [],
      selectedRadio: model.response,
    );
  }

  /// Method to duplicate the radio text field model
  /// Returns a new instance of RadioTextFieldModel with the same properties
  @override
  duplicate() {
    RadioTextFieldModel newModel = RadioTextFieldModel(
      isRequired: isRequired,
      selectedRadio: selectedRadio,
      hints: List<String>.from(hints),
    );
    return newModel;
  }

  @override
  RadioTextFieldController toController({bool isSetData = false}) {
    RadioTextFieldController controller = RadioTextFieldController();

    controller.isRequired = isRequired;
    List<TextEditingController> hintsController = [];
    for (var element in hints) {
      hintsController.add(TextEditingController(text: element));
    }
    controller.hints = hintsController;
    if (isSetData) {
      controller.selectedRadio = selectedRadio;
    }
    return controller;
  }
}
