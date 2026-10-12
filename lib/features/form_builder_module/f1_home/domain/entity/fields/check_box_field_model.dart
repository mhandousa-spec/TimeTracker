import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a checkbox field, including title, alignment, arrangement, and other properties.

class CheckBoxFieldModel extends FieldModel {
  /// Title of the checkbox field
  String title;

  /// Alignment of the checkbox field
  String alignment;

  /// Arrangement of the checkbox options (e.g., vertical, horizontal)
  String arrangement;

  /// Maximum number of selections allowed
  int? maximumSelection;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of options for the checkbox field
  List<String> options = [];

  List<String>? answers;

  /// Constructor for initializing the CheckBoxFieldModel instance
  CheckBoxFieldModel({
    required this.title,
    required this.isRequired,
    required this.options,
    this.maximumSelection,
    required this.arrangement,
    required this.alignment,
    this.answers,
  }) : super(FormFieldType.checkBox);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.checkBox.name.toLowerCase(),
      arrangement: arrangement,
      options: options,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: maximumSelection?.toString(),
      response: answers?.map((e) => e).join(', '),
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return CheckBoxFieldModel(
      title: model.title!,
      isRequired: model.isRequired!,
      options: model.options!.map((e) => e!).toList(),
      maximumSelection:
          model.maxSelection != null ? int.parse(model.maxSelection!) : null,
      alignment: model.alignment!,
      arrangement: model.arrangement!,
      answers: model.response?.split(', '),
    );
  }

  /// Method to duplicate the checkbox field model
  /// Returns a new instance of CheckBoxFieldModel with the same properties
  @override
  duplicate() {
    CheckBoxFieldModel newModel = CheckBoxFieldModel(
      title: title,
      isRequired: isRequired,
      options: List<String>.from(options),
      maximumSelection: maximumSelection,
      arrangement: arrangement,
      alignment: alignment,
    );
    return newModel;
  }

  @override
  CheckBoxFieldController toController({bool isSetData = false}) {
    CheckBoxFieldController controller = CheckBoxFieldController();
    List<CheckboxOptions> hintsController = [];
    for (var element in options) {
      hintsController.add(CheckboxOptions(
          option: TextEditingController(text: element),
          value: answers?.contains(element) ?? false));
    }
    controller.options = hintsController;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.arrangement = arrangement;
    controller.maximumSelection!.text = maximumSelection == null
        ? ''
        : FormDateTimeHelper.formatInt(maximumSelection!);
    return controller;
  }
}
