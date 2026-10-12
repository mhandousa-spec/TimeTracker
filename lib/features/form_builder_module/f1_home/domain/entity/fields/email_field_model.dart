import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for an email field, including title, hint, alignment, and requirement status.

/// Represents the model for an email field
class EmailFieldModel extends FieldModel {
  /// Hint text for the email field
  String hint;

  /// Title of the email field
  String title;

  /// Alignment of the email field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Email of the answer
  String? emailAnswer;

  /// Constructor for initializing the EmailFieldModel instance
  EmailFieldModel({
    required this.title,
    required this.isRequired,
    required this.alignment,
    required this.hint,
    this.emailAnswer,
  }) : super(FormFieldType.email);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.email.name.toLowerCase(),
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
      response: emailAnswer,
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return EmailFieldModel(
      isRequired: model.isRequired!,
      title: model.title!,
      alignment: model.alignment!.capitalize!,
      hint: model.hint!,
      emailAnswer: model.response,
    );
  }

  /// Method to duplicate the email field model
  /// Returns a new instance of EmailFieldModel with the same properties
  @override
  duplicate() {
    EmailFieldModel newModel = EmailFieldModel(
      title: title,
      isRequired: isRequired,
      alignment: alignment,
      hint: hint,
    );
    return newModel;
  }

  @override
  EmailFieldController toController({bool isSetData = false}) {
    EmailFieldController controller = EmailFieldController();

    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) controller.answer = emailAnswer;

    return controller;
  }
}
