import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class EmailFieldController extends FieldController {
  // Text controllers for the hint and title of the email field.
  TextEditingController? hint, title;
  // Represents the alignment of the email field.
  String? alignment;
  // Indicates whether this email field is required or not.
  bool? isRequired;

  String? answer;
  /// Constructor that initializes the controller with email field type.
  EmailFieldController() : super(FormFieldType.email) {
    init();
  }

  @override

  /// Initializes the email field controllers.
  init() {
    hint = TextEditingController();
    title = TextEditingController();
    alignment = AlignmentEnum.center.name;
    isRequired = false;
    return super.init();
  }

  @override

  /// Disposes the email field controllers.
  dispose() {
    hint!.dispose();
    title!.dispose();
    return super.dispose();
  }

  @override

  /// Prints the model data of the email field.
  printModel() {

    
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current email field controller.
  duplicate() {
    var newController = EmailFieldController();
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

  /// Converts the email field controller to a model.
  EmailFieldModel toModel({bool isSetAnswer = false}) {
    return EmailFieldModel(
      hint: hint!.text,
      title: title!.text,
      alignment: alignment!,
      isRequired: isRequired!,
      emailAnswer: isSetAnswer ? answer : null,
    );
  }
}
