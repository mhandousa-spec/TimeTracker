import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a phone field, including title, alignment, and requirement status.

/// Represents the model for a phone field
class PhoneFieldModel extends FieldModel {
  /// Title of the phone field
  String title;

  /// Alignment of the phone field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Phone of the answer
  String? phoneAnswer;

  /// Phone code of the answer
  String? phoneCodeAnswer;

  /// Constructor for initializing the PhoneFieldModel instance
  PhoneFieldModel({
    required this.isRequired,
    required this.alignment,
    required this.title,
    this.phoneAnswer,
    this.phoneCodeAnswer,
  }) : super(FormFieldType.phone);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.phone.name.toLowerCase(),
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
      response: (phoneCodeAnswer == null && phoneAnswer == null)
          ? null
          : ' $phoneCodeAnswer, $phoneAnswer',
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return PhoneFieldModel(
      isRequired: model.isRequired!,
      title: model.title!,
      alignment: model.alignment!,
      phoneAnswer: model.response?.split(', ')[1],
      phoneCodeAnswer: model.response?.split(', ')[0],
    );
  }

  /// Method to duplicate the phone field model
  /// Returns a new instance of PhoneFieldModel with the same properties
  @override
  duplicate() {
    PhoneFieldModel newModel = PhoneFieldModel(
      isRequired: isRequired,
      alignment: alignment.capitalize!,
      title: title,
    );
    return newModel;
  }

  @override
  PhoneFieldController toController({bool isSetData = false}) {
    PhoneFieldController controller = PhoneFieldController();

    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) {
      controller.phoneAnswer = phoneAnswer;
      controller.currentCountry = phoneCodeAnswer;
    }
    return controller;
  }
}
