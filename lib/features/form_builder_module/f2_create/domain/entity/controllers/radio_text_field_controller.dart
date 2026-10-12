import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class RadioTextFieldController extends FieldController {
  List<TextEditingController> hints = [];
  String? selectedRadio;
  // Indicates whether this radio text field is required or not.
  bool? isRequired;

  /// Constructor that initializes the controller with radio text field type.
  RadioTextFieldController() : super(FormFieldType.radioTextField) {
    init();
  }

  @override

  /// Initializes the radio text field controllers.
  init() {
    hints = [TextEditingController(), TextEditingController()];
    isRequired = false;
    return super.init();
  }

  @override

  /// Disposes the radio text field controllers.
  dispose() {
    for (var element in hints) {
      element.dispose();
    }
    return super.dispose();
  }

  @override

  /// Prints the model data of the radio text field.
  printModel() {

    
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current radio text field controller.
  duplicate() {
    var newController = RadioTextFieldController();
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the list of hints
    newController.hints = [];
    newController.hints
        .addAll(hints.map((e) => TextEditingController(text: e.text)));
    return newController;
  }

  @override

  /// Converts the radio text field controller to a model.
  RadioTextFieldModel toModel({bool isSetAnswer = false}) {
    return RadioTextFieldModel(
      hints: hints.map((e) => e.text).toList(),
      isRequired: isRequired!,
      selectedRadio: isSetAnswer?selectedRadio:null,
    );
  }
  @override
  bool valid() {
    if (selectedRadio == null) {
      return false;
    }
    return super.valid();
  }
}
