import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class PhoneFieldController extends FieldController {
  // Text controller for the title of the phone field.
  TextEditingController? title;
  // Represents the alignment of the phone field.
  String? alignment, currentCountry;
  // Indicates whether this phone field is required or not.
  bool? isRequired;

  String? phoneAnswer;
  /// Constructor that initializes the controller with phone field type.
  PhoneFieldController() : super(FormFieldType.phone) {
    init();
  }

  @override

  /// Initializes the phone field controllers.
  init() {
    title = TextEditingController();
    isRequired = false;
    alignment = AlignmentEnum.center.name;
    return super.init();
  }

  @override

  /// Disposes the phone field controllers.
  dispose() {
    title!.dispose();
    return super.dispose();
  }

  @override

  /// Prints the model data of the phone field.
  printModel() {

    
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current phone field controller.
  duplicate() {
    var newController = PhoneFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override

  /// Converts the phone field controller to a model.
  PhoneFieldModel toModel({bool isSetAnswer = false}) {
    return PhoneFieldModel(
      title: title!.text,
      isRequired: isRequired!,
      alignment: alignment!,
      phoneAnswer: isSetAnswer?phoneAnswer:null,
      phoneCodeAnswer: isSetAnswer?currentCountry:null,
    );
  }
}
