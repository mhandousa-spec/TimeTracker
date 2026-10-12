import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class DescriptionFieldController extends FieldController {
  // Text controllers for the hint, title, and limitation of the description field.
  TextEditingController? hint, title, limitation, answerController;
  // Represents the alignment of the description field.
  String? alignment;
  // Indicates whether this description field is required or not.
  bool? isRequired;

  /// Constructor that initializes the controller with description field type.
  DescriptionFieldController() : super(FormFieldType.description) {
    init();
  }

  @override

  /// Initializes the description field controllers.
  init() {
    hint = TextEditingController();
    title = TextEditingController();
    limitation = TextEditingController();
    answerController = TextEditingController();
    alignment = AlignmentEnum.center.name;
    isRequired = false;
    return super.init();
  }

  @override

  /// Disposes the description field controllers.
  dispose() {
    hint!.dispose();
    title!.dispose();
    limitation!.dispose();
    answerController!.dispose();
    return super.dispose();
  }

  @override

  /// Prints the model data of the description field.
  printModel() {

    
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current description field controller.
  duplicate() {
    var newController = DescriptionFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the hint
    newController.hint?.text = hint?.text ?? '';
    // Duplicate the limitation
    newController.limitation?.text = limitation?.text ?? '';
    newController.answerController?.text = answerController?.text ?? '';
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override

  /// Converts the description field controller to a model.
  DescriptionFieldModel toModel({bool isSetAnswer = false}) {
    return DescriptionFieldModel(
        alignment: alignment!,
        hint: hint?.text ?? '',
        isRequired: isRequired!,
        limitation: limitation?.text ?? '',
        title: title?.text ?? '',
        descriptionAnswer: answerController?.text ?? '',
    );
  }
}
