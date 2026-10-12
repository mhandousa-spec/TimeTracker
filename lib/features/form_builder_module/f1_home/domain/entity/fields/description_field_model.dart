import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a description field, including title, hint, alignment, limitation, and requirement status.

/// Represents the model for a description field
class DescriptionFieldModel extends FieldModel {
  /// Hint text for the description field
  String hint;

  /// Title of the description field
  String title;

  /// Limitation or maximum length of the description
  String limitation;

  /// Alignment of the description field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  String? descriptionAnswer;

  /// Constructor for initializing the DescriptionFieldModel instance
  DescriptionFieldModel({
    required this.hint,
    required this.title,
    required this.isRequired,
    required this.alignment,
    required this.limitation,
    this.descriptionAnswer,
  }) : super(FormFieldType.description);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.description.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: int.parse(limitation),
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: descriptionAnswer,
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return DescriptionFieldModel(
      title: model.title!,
      alignment: model.alignment!.capitalize!,
      isRequired: model.isRequired!,
      hint: model.hint!,
      limitation: model.limitation.toString(),
      descriptionAnswer: model.response,
    );
  }

  /// Method to duplicate the description field model
  /// Returns a new instance of DescriptionFieldModel with the same properties
  @override
  duplicate() {
    DescriptionFieldModel newModel = DescriptionFieldModel(
      hint: hint,
      title: title,
      isRequired: isRequired,
      alignment: alignment,
      limitation: limitation,
    );
    return newModel;
  }

  @override
  DescriptionFieldController toController({bool isSetData = false}) {
    DescriptionFieldController controller = DescriptionFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    controller.limitation!.text = limitation;
    controller.answerController!.text = descriptionAnswer ?? "";
    return controller;
  }
}
