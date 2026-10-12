import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

class CheckBoxFieldController extends FieldController {
  // Text controllers for the title and maximum selections of the checkbox field.
  TextEditingController? title, maximumSelection;
  // Represents the alignment of the checkbox field.
  String? alignment;
  // Represents the arrangement of the checkbox field.
  String? arrangement;
  // Indicates whether this checkbox field is required or not.
  bool? isRequired;
  // List of checkbox options.
  List<CheckboxOptions> options = [];

  /// Constructor that initializes the controller with checkbox field type.
  CheckBoxFieldController() : super(FormFieldType.checkBox) {
    init();
  }

  @override

  /// Initializes the checkbox field controllers.
  init() {
    options = [
      CheckboxOptions(option: TextEditingController()),
      CheckboxOptions(option: TextEditingController()),
    ];
    title = TextEditingController();
    maximumSelection = TextEditingController();
    alignment = AlignmentEnum.center.name;
    arrangement = Arrangement.vertical.name;
    isRequired = false;
    return super.init();
  }

  @override

  /// Disposes the checkbox field controllers.
  dispose() {
    title!.dispose();
    maximumSelection!.dispose();
    for (var element in options) {
      element.option.dispose();
    }
    return super.dispose();
  }

  @override

  /// Prints the model data of the checkbox field.
  printModel() {

    
    
    for (var element in options) {
      
    }
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current checkbox field controller.
  duplicate() {
    var newController = CheckBoxFieldController();
    newController.title?.text = title?.text ?? '';
    newController.isRequired = isRequired;
    newController.options = [];
    newController.options.addAll(options.map((e) => CheckboxOptions(
        option: TextEditingController(text: e.option.text), value: e.value)));
    return newController;
  }

  @override

  /// Converts the checkbox field controller to a model.
  CheckBoxFieldModel toModel({bool isSetAnswer = false}) {
    return CheckBoxFieldModel(
      title: title?.text ?? '',
      maximumSelection: maximumSelection!.text.toEnglishNumber(),
      alignment: alignment!,
      arrangement: arrangement!,
      isRequired: isRequired!,
      options: options.map((e) => e.option.text).toList(),
      answers: isSetAnswer ? options.where((element) => element.value).map((e) => e.option.text).toList() : null,
    );
  }

  @override
  bool valid() {
    // Check if required and no option is selected
    if (isRequired! && options.every((element) => element.value == false)) {
      return false;
    }

    // Check if title is empty
    if (title?.text.trim().isEmpty ?? true) {
      return false;
    }

    // Check if all options are filled
    for (var option in options) {
      if (option.option.text.trim().isEmpty) {
        return false;
      }
    }

    // Check for duplicate options
    List<String> optionTexts = options
        .map((option) => option.option.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (optionTexts.length != optionTexts.toSet().length) {
      // Has duplicates
      return false;
    }

    // Validate maximum selection must be less than number of options
    if (maximumSelection?.text.trim().isNotEmpty ?? false) {
      int? maxSelection = maximumSelection!.text.trim().toEnglishNumber();

      if (maxSelection == null || maxSelection <= 0) {
        return false;
      }

      // Count non-empty options
      int optionsCount = options
          .where((option) => option.option.text.trim().isNotEmpty)
          .length;

      if (maxSelection >= optionsCount) {
        return false;
      }
    }

    return super.valid();
  }
}

/// This class represents options for the checkbox field.
class CheckboxOptions {
  // Text controller for a single checkbox option.
  TextEditingController option;
  // Indicates whether the checkbox option is selected or not.
  bool value;

  /// Constructor that initializes the checkbox option with a text controller and optional value.
  CheckboxOptions({required this.option, this.value = false});
}