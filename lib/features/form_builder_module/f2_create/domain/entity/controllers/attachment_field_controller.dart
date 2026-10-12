import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

class AttachmentFieldController extends FieldController {
  // Text controller for the title of the attachment field.
  TextEditingController? title;
  // Indicates whether this attachment field is required or not.
  String? alignment;
  bool? isRequired;

  AttachmentEntity? attachmentEntity;

  /// Constructor that initializes the controller with attachment field type.
  AttachmentFieldController() : super(FormFieldType.attachment) {
    init();
  }

  @override

  /// Initializes the attachment field controllers.
  init() {
    title = TextEditingController();
    isRequired = false;
    alignment = AlignmentEnum.center.name;
    return super.init();
  }

  @override

  /// Disposes the attachment field controllers.
  dispose() {
    title!.dispose();
    return super.dispose();
  }

  @override

  /// Prints the model data of the attachment field.
  printModel() {

    
    return super.printModel();
  }

  @override

  /// Creates a duplicate of the current attachment field controller.
  duplicate() {
    var newController = AttachmentFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override

  /// Converts the attachment field controller to a model.
  AttachmentFieldModel toModel({bool isSetAnswer = false}) {
    return AttachmentFieldModel(
        isRequired: isRequired!,
        alignment: alignment!,
        title: title?.text ?? '',
        attachmentLink: attachmentEntity,
    );
  }
  @override
  bool valid() {
    if (isRequired! && attachmentEntity == null) {
      return false;
    }
    return super.valid();
  }
}
