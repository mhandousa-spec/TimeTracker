import 'package:get/get.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/core/helper/form_builder/attachment_helper.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for an attachment field, including title and requirement status.

class AttachmentFieldModel extends FieldModel {
  /// Title of the attachment field
  String title;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Alignment of the email field
  String alignment;

  /// Link of the attachment
  AttachmentEntity? attachmentLink;

  /// Constructor for initializing the AttachmentFieldModel instance
  AttachmentFieldModel(
      {required this.title,
      required this.alignment,
      required this.isRequired,
      this.attachmentLink})
      : super(FormFieldType.attachment);
  @override
  ColumnModel toModel({bool isSetData = false}) {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.attachment.name.toLowerCase(),
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
      response: attachmentLink?.encodedAttachmentData,
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return AttachmentFieldModel(
      title: model.title!,
      alignment: model.alignment!.capitalize!,
      isRequired: model.isRequired!,
      attachmentLink: model.response == null
          ? null
          : AttachmentEntity.fromDecodedData(model.response!),
    );
  }

  /// Method to duplicate the attachment field model
  /// Returns a new instance of AttachmentFieldModel with the same properties
  @override
  duplicate() {
    AttachmentFieldModel newModel = AttachmentFieldModel(
      title: title,
      isRequired: isRequired,
      alignment: alignment,
    );
    return newModel;
  }

  @override
  AttachmentFieldController toController({bool isSetData = false}) {
    AttachmentFieldController controller = AttachmentFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.isRequired = isRequired;
    if (isSetData) {
      controller.attachmentEntity = attachmentLink;
      /*     if (attachmentLink != null) {
        if (!attachmentLink!.contains('http')) {
          controller.file = File(attachmentLink!);
        }
      }*/
    }
    return controller;
  }

  @override
  uploadMedia(
      {required String mediaPath, required String fileNamePrefix}) async {
    try {
      
      if (attachmentLink != null && !attachmentLink!.path.contains('http')) {
        
        attachmentLink!.path =
            await FirebaseRepository.uploadFileWithoutHandlingError(
                collectionName: mediaPath,
                documentName: createNewAttachmentName(
                    attachmentPath: attachmentLink!.path,
                    fileNamePrefix: fileNamePrefix),
                filePath: attachmentLink!.path);
        
      }
    } catch (e) {
      
    }
    return;
  }
}
