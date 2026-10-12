import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class DropDownFieldController extends FieldController {
  // Text controller for the title of the dropdown field.
  TextEditingController? title;
  // Represents the alignment of the dropdown field.
  String? alignment;
  // Represents the current selected value in the dropdown field.
  String? currentValue;
  // Indicates whether this dropdown field is required or not.
  bool? isRequired;
  // List of text controllers for the dropdown options (hints).
  List<TextEditingController> hints = [];

  /// Constructor that initializes the controller with dropdown field type.
  DropDownFieldController() : super(FormFieldType.dropDown) {
    init();
  }

  @override

  /// Initializes the dropdown field controllers.
  init() {
    hints = [TextEditingController(), TextEditingController()];
    title = TextEditingController();
    alignment = AlignmentEnum.center.name;
    currentValue = null;
    isRequired = false;
    return super.init();
  }

  @override

  /// Disposes the dropdown field controllers.
  dispose() {
    title!.dispose();
    for (var element in hints) {
      element.dispose();
    }
    return super.dispose();
  }

  @override

  /// Prints the model data of the dropdown field.
  printModel() {

    
    
    for (var element in hints) {
      
    }
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current dropdown field controller.
  duplicate() {
    var newController = DropDownFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the current value
    newController.currentValue = currentValue;
    // Duplicate the alignment
    newController.alignment = alignment;
    // Duplicate the list of hints
    newController.hints = [];
    newController.hints
        .addAll(hints.map((e) => TextEditingController(text: e.text)));
    return newController;
  }

  /// Returns a list of dropdown menu items based on the hints.
  List<DropdownMenuItem<String>> dropDownItems() {
    return hints.map((element) {
      return DropdownMenuItem(
        value: element.text,
        child: Text(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          element.text,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        ),
      );
    }).toList();
  }

  @override

  /// Converts the dropdown field controller to a model.
  DropDownFieldModel toModel({bool isSetAnswer = false}) {
    return DropDownFieldModel(
      title: title?.text ?? '',
      hints: hints.map((e) => e.text).toList(),
      isRequired: isRequired ?? false,
      alignment: alignment!,
      currentValue: isSetAnswer ? currentValue : null,
    );
  }
}
