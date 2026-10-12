import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a text field, including title, hint, alignment, and requirement status.

/// Represents the model for a text field
class TextFieldModel extends FieldModel {
  /// Hint text for the text field
  String hint;

  /// Title of the text field
  String title;

  /// Alignment of the text field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  String? textAnswer;

  /// Constructor for initializing the TextFieldModel instance
  TextFieldModel({
    required this.title,
    required this.alignment,
    required this.isRequired,
    required this.hint,
    this.textAnswer,
  }) : super(FormFieldType.textField);

  /// Method to duplicate the text field model
  /// Returns a new instance of TextFieldModel with the same properties
  @override
  duplicate() {
    TextFieldModel newModel = TextFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
    );
    return newModel;
  }

//to model
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.textField.name.toLowerCase(),
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
      response: textAnswer,
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return TextFieldModel(
      isRequired: model.isRequired!,
      title: model.title!,
      alignment: model.alignment!.capitalize!,
      hint: model.hint!,
      textAnswer: model.response,
    );
  }

  @override
  TextFieldController toController({bool isSetData = false}) {
    
    TextFieldController controller = TextFieldController();

    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.hint!.text = hint;
    if (isSetData) controller.answer = textAnswer;
    return controller;
  }
}
