import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class RadioFieldController extends FieldController {
  // Text controllers for the title and maximum selections of the radio field.
  TextEditingController? title;
  // Represents the alignment of the radio field.
  String? alignment;
  // Represents the arrangement of the radio field.
  String? arrangement;
  // Represents the currently selected radio button.
  String? selectedRadio;
  // Indicates whether this radio field is required or not.
  bool? isRequired;
  // List of text controllers for the radio options (hints).
  List<TextEditingController> hints = [];

  /// Constructor that initializes the controller with radio field type.
  RadioFieldController() : super(FormFieldType.radio) {
    init();
  }

  @override

  /// Initializes the radio field controllers.
  init() {
    hints = [TextEditingController(), TextEditingController()];
    title = TextEditingController();
    alignment = AlignmentEnum.center.name;
    arrangement = Arrangement.vertical.name;
    isRequired = false;
    return super.init();
  }

  @override

  /// Disposes the radio field controllers.
  dispose() {
    title!.dispose();
    for (var element in hints) {
      element.dispose();
    }
    return super.dispose();
  }

  @override

  /// Prints the model data of the radio field.
  printModel() {

    
    
    for (var element in hints) {
      
    }
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current radio field controller.
  duplicate() {
    var newController = RadioFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the alignment
    newController.alignment = alignment;
    // Duplicate the arrangement
    newController.arrangement = arrangement;
    // Duplicate the selected radio
    newController.selectedRadio = selectedRadio;
    // Duplicate the list of hints
    newController.hints = [];
    newController.hints
        .addAll(hints.map((e) => TextEditingController(text: e.text)));
    return newController;
  }

  @override

  /// Converts the radio field controller to a model.
  RadioFieldModel toModel({bool isSetAnswer = false}) {
    return RadioFieldModel(
      title: title!.text,
      hints: hints.map((e) => e.text).toList(),
      alignment: alignment!,
      arrangement: arrangement!,
      isRequired: isRequired!,
      selectedRadio: isSetAnswer?selectedRadio:null,
    );
  }
  @override
  bool valid() {
    if(isRequired!&&selectedRadio==null){
      return false;
    }
    return super.valid();
  }
}
