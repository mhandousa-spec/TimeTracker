import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a link field, including title, hint, alignment, and requirement status.

/// Represents the model for a link field
class LinkFieldModel extends FieldModel {
  /// Hint text for the link field
  String hint;

  /// Title of the link field
  String title;

  /// Alignment of the link field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Link of the answer
  String? linkAnswer;

  /// Constructor for initializing the LinkFieldModel instance
  LinkFieldModel({
    required this.title,
    required this.isRequired,
    required this.hint,
    required this.alignment,
    this.linkAnswer,
  }) : super(FormFieldType.link);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.link.name.toLowerCase(),
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
      response: linkAnswer,
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return LinkFieldModel(
      title: model.title!,
      isRequired: model.isRequired!,
      hint: model.hint!,
      alignment: model.alignment!.capitalize!,
      linkAnswer: model.response,
    );
  }

  /// Method to duplicate the link field model
  /// Returns a new instance of LinkFieldModel with the same properties
  @override
  duplicate() {
    LinkFieldModel newModel = LinkFieldModel(
      title: title,
      isRequired: isRequired,
      hint: hint,
      alignment: alignment,
    );
    return newModel;
  }

  @override
  LinkFieldController toController({bool isSetData = false}) {
    LinkFieldController controller = LinkFieldController();

    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) controller.answer = linkAnswer;
    return controller;
  }
}
