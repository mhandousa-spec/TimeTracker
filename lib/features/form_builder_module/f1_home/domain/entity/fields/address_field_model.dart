import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: mohamed Mohy
// Last update: 22/1/2025
// Objectives:  Represents the model for an address field
class AddressFieldModel extends FieldModel {
  /// Title of the address field
  String title;

  /// List of hint texts for the address field
  List<String> hints;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of answers for the address field
  List<String>? answers;

  /// Constructor for initializing the AddressFieldModel instance
  AddressFieldModel(
      {required this.hints,
      required this.title,
      required this.isRequired,
      this.answers})
      : super(FormFieldType.address);

  /// Method to duplicate the address field model
  /// Returns a new instance of AddressFieldModel with the same properties
  @override
  duplicate() {
    AddressFieldModel newModel =
        AddressFieldModel(hints: hints, title: title, isRequired: isRequired);
    return newModel;
  }

//to model
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: null,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.address.name.toLowerCase(),
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
      response: answers?.map((e) => e).join(', '),
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return AddressFieldModel(
      isRequired: model.isRequired!,
      title: model.title!,
      hints: model.hint!.split(', '),
      answers: model.response?.split(', '),
    );
  }

  @override
  AddressFieldController toController({bool isSetData = false}) {
    AddressFieldController controller = AddressFieldController();
    List<TextEditingController> hintsController = [];
    for (var element in hints) {
      hintsController.add(TextEditingController(text: element));
    }
    controller.hints = hintsController;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    if (isSetData) controller.answers = answers;
    return controller;
  }
}
