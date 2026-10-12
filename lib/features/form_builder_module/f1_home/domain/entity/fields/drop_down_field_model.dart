import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a dropdown field, including title, alignment, current value, and requirement status.

/// Represents the model for a dropdown field
class DropDownFieldModel extends FieldModel {
  /// Title of the dropdown field
  String title;

  /// Alignment of the dropdown field
  String alignment;

  /// Currently selected value in the dropdown
  String? currentValue;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of hint texts for the dropdown options
  List<String> hints = [];

  /// Constructor for initializing the DropDownFieldModel instance
  DropDownFieldModel({
    required this.alignment,
    required this.isRequired,
    required this.title,
    required this.hints,
    this.currentValue,
  }) : super(FormFieldType.dropDown);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.dropDown.name.toLowerCase(),
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
      response: currentValue,
    );
  }

  /// Method to duplicate the dropdown field model
  /// Returns a new instance of DropDownFieldModel with the same properties
  @override
  duplicate() {
    DropDownFieldModel newModel = DropDownFieldModel(
      alignment: alignment,
      isRequired: isRequired,
      title: title,
      hints: List<String>.from(hints),
      currentValue: currentValue,
    );
    return newModel;
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return DropDownFieldModel(
      alignment: model.alignment!.capitalize!,
      isRequired: model.isRequired!,
      title: model.title!,
      hints: model.hint!.split(', '),
      currentValue: model.response,
    );
  }

  @override
  DropDownFieldController toController({bool isSetData = false}) {
    DropDownFieldController controller = DropDownFieldController();
    List<TextEditingController> hintsController = [];
    for (var element in hints) {
      hintsController.add(TextEditingController(text: element));
    }
    if (isSetData) controller.currentValue = currentValue;
    controller.hints = hintsController;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    return controller;
  }

  List<DropdownMenuItem<String>> dropDownItems() {
    return hints.map((element) {
      return DropdownMenuItem(
        value: element,
        child: Text(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          element,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        ),
      );
    }).toList();
  }
}
