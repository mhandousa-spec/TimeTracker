import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class TextFieldController extends FieldController {
  // Text controllers for the hint and title of the text field.
  TextEditingController? hint, title;
  // Represents the alignment of the text field.
  String? alignment;
  // Indicates whether this text field is required or not.
  bool? isRequired;

  String? answer;
  /// Constructor that initializes the controller with text field type.
  TextFieldController() : super(FormFieldType.textField) {
    init();
  }

  @override

  /// Initializes the text field controllers.
  init() {
    hint = TextEditingController();
    title = TextEditingController();
    alignment = AlignmentEnum.center.name;
    isRequired = false;
    return super.init();
  }

  @override

  /// Disposes the text field controllers.
  dispose() {
    hint!.dispose();
    title!.dispose();
    return super.dispose();
  }

  @override

  /// Prints the model data of the text field.
  printModel() {

    
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current text field controller.
  duplicate() {
    var newController = TextFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the hint
    newController.hint?.text = hint?.text ?? '';
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override

  /// Converts the text field controller to a model.
  TextFieldModel toModel({bool isSetAnswer = false}) {

    return TextFieldModel(
      title: title!.text,
      hint: hint!.text,
      alignment: alignment!,
      isRequired: isRequired!,
      textAnswer: isSetAnswer?answer:null,
    );
  }
}
