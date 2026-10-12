import 'package:get/get.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a title field, including title, text size, alignment, and text formatting options.

/// Represents the model for a title field
class TitleFieldModel extends FieldModel {
  /// Title of the field
  String title;

  /// Text size of the title
  double textSize;

  /// Alignment of the title field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Flag to determine if the title is bold
  bool isBold;

  /// Flag to determine if the title is italic
  bool isItalic;

  /// Flag to determine if the title is underlined
  bool isUnderLine;

  /// Color of the title text
  String titleColor;

  /// Constructor for initializing the TitleFieldModel instance
  TitleFieldModel({
    required this.title,
    required this.isRequired,
    required this.alignment,
    required this.textSize,
    required this.isUnderLine,
    required this.isBold,
    required this.titleColor,
    required this.isItalic,
  }) : super(FormFieldType.title);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.title.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: textSize.toString(),
      isBold: isBold,
      isItalic: isItalic,
      isUnderLine: isUnderLine,
      color: titleColor,
      maxSelection: null,
      response: null,
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return TitleFieldModel(
      title: model.title!,
      isRequired: model.isRequired!,
      alignment: model.alignment!.capitalize!,
      textSize: model.textSize!.toDouble(),
      isUnderLine: model.isUnderLine!,
      isBold: model.isBold!,
      titleColor: model.color!,
      isItalic: model.isItalic!,
    );
  }

  /// Method to duplicate the title field model
  /// Returns a new instance of TitleFieldModel with the same properties
  @override
  duplicate() {
    TitleFieldModel newModel = TitleFieldModel(
      title: title,
      isRequired: isRequired,
      alignment: alignment,
      textSize: textSize,
      isUnderLine: isUnderLine,
      isBold: isBold,
      titleColor: titleColor,
      isItalic: isItalic,
    );
    return newModel;
  }

  @override
  TitleFieldController toController({bool isSetData = false}) {
    TitleFieldController controller = TitleFieldController();

    controller.title!.text = title ?? '';
    controller.isRequired = isRequired;
    controller.alignment = alignment;
    controller.textSize!.text =
        FormDateTimeHelper.formatInt(textSize.toInt()).doubleDigit;
    controller.isUnderLine = isUnderLine;
    controller.isBold = isBold;
    controller.titleColor = titleColor.toColor();
    controller.isItalic = isItalic;

    return controller;
  }
}
