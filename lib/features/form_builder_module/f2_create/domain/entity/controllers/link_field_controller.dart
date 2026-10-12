import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class LinkFieldController extends FieldController {
  // Text controllers for the hint and title of the link field.
  TextEditingController? hint, title;
  // Represents the alignment of the link field.
  String? alignment;
  // Indicates whether this link field is required or not.
  bool? isRequired;
  String? answer;
  /// Constructor that initializes the controller with link field type.
  LinkFieldController() : super(FormFieldType.link) {
    init();
  }

  @override

  /// Initializes the link field controllers.
  init() {
    hint = TextEditingController();
    title = TextEditingController();
    isRequired = false;
    alignment = AlignmentEnum.center.name;
    return super.init();
  }

  @override

  /// Disposes the link field controllers.
  dispose() {
    hint!.dispose();
    title!.dispose();
    return super.dispose();
  }

  @override

  /// Prints the model data of the link field.
  printModel() {

    
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current link field controller.
  duplicate() {
    var newController = LinkFieldController();
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

  /// Converts the link field controller to a model.
  LinkFieldModel toModel({bool isSetAnswer = false}) {
    return LinkFieldModel(
      title: title!.text,
      hint: hint!.text,
      alignment: alignment!,
      isRequired: isRequired!,
      linkAnswer: isSetAnswer ? answer : null,
    );
  }
}
