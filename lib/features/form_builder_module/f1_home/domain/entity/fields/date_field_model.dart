import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a date field, including title, hint, alignment, and requirement status.

/// Represents the model for a date field
class DateFieldModel extends FieldModel {
  /// Hint text for the date field
  String hint;

  /// Title of the date field
  String title;

  /// Alignment of the date field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Date of the answer
  DateTime? answerDate;

  /// Constructor for initializing the DateFieldModel instance
  DateFieldModel({
    required this.alignment,
    required this.isRequired,
    required this.title,
    required this.hint,
    this.answerDate,
  }) : super(FormFieldType.dateSelector);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.dateSelector.name.toLowerCase(),
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
      response: answerDate?.toString(),
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return DateFieldModel(
      alignment: model.alignment!.capitalize!,
      isRequired: model.isRequired!,
      title: model.title!,
      hint: model.hint!,
      answerDate:
          model.response != null ? DateTime.parse(model.response!) : null,
    );
  }

  /// Method to duplicate the date field model
  /// Returns a new instance of DateFieldModel with the same properties
  @override
  duplicate() {
    DateFieldModel newModel = DateFieldModel(
      alignment: alignment,
      isRequired: isRequired,
      title: title,
      hint: hint,
    );
    return newModel;
  }

  @override
  DateFieldController toController({bool isSetData = false}) {
    DateFieldController controller = DateFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    if (isSetData) controller.answerDate = answerDate;
    return controller;
  }
}
