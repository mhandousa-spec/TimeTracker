import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 08/1/2026
// By: Amr
// Last update: 08/1/2026
// Objectives: Represents the model for a terms and conditions field

class TermsAndConditionsFieldModel extends FieldModel {
  /// Title of the terms and conditions field
  String title;

  /// Alignment of the terms and conditions field
  String alignment;

  /// Arabic terms and conditions text
  String termsAr;

  /// English terms and conditions text
  String termsEn;

  /// Flag to determine if the field is required (always true for T&C)
  bool isRequired;

  /// Checkbox acceptance status (for submitted forms)
  bool? isAccepted;

  /// Constructor for initializing the TermsAndConditionsFieldModel instance
  TermsAndConditionsFieldModel({
    required this.title,
    required this.termsAr,
    required this.termsEn,
    required this.alignment,
    this.isRequired = true, // Always required
    this.isAccepted,
  }) : super(FormFieldType.termsAndCondition);

  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: true, // Always required
      hint: termsAr, // Store Arabic terms in hint field
      fieldType: FormFieldType.termsAndCondition.name.toLowerCase(),
      arrangement: termsEn, // Store English terms in arrangement field
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: isAccepted?.toString(),
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return TermsAndConditionsFieldModel(
      title: model.title!,
      termsAr: model.hint ?? '', // Read Arabic terms from hint field
      termsEn: model.arrangement ?? '', // Read English terms from arrangement field
      alignment: model.alignment!,
      isRequired: true, // Always required
      isAccepted: model.response != null ? model.response == 'true' : null,
    );
  }

  /// Method to duplicate the terms and conditions field model
  /// Returns a new instance of TermsAndConditionsFieldModel with the same properties
  @override
  duplicate() {
    TermsAndConditionsFieldModel newModel = TermsAndConditionsFieldModel(
      title: title,
      termsAr: termsAr,
      termsEn: termsEn,
      alignment: alignment,
      isRequired: true, // Always required
      isAccepted: null, // Reset acceptance in duplicate
    );
    return newModel;
  }

  @override
  TermsConditionsFieldController toController({bool isSetData = false}) {
    TermsConditionsFieldController controller = TermsConditionsFieldController();
    controller.title!.text = title;
    controller.termsAr!.text = termsAr;
    controller.termsEn!.text = termsEn;
    controller.alignment = alignment;
    controller.isRequired = true; // Always required
    controller.isAccepted = isAccepted ?? false;
    return controller;
  }
}