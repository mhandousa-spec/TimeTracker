
import 'package:get/get.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/core/helper/form_builder/attachment_helper.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a digital signature field, including title and requirement status.

class AttachmentDigitalSignatureFieldModel extends FieldModel {
  /// Title of the attachment digital signature field
  String title;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Alignment of the email field
  String alignment;

  AttachmentEntity? attachmentLink;

  /// Constructor for initializing the AttachmentDigitalSignatureFieldModel instance
  AttachmentDigitalSignatureFieldModel(
      {required this.title,
      required this.alignment,
      required this.isRequired,
      this.attachmentLink})
      : super(FormFieldType.digitalSignature);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.digitalSignature.name.toLowerCase(),
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
    return AttachmentDigitalSignatureFieldModel(
      title: model.title!,
      alignment: model.alignment!.capitalize!,
      isRequired: model.isRequired!,
      attachmentLink: model.response == null
          ? null
          : AttachmentEntity.fromDecodedData(model.response!),
    );
  }

  /// Method to duplicate the attachment digital signature field model
  /// Returns a new instance of AttachmentDigitalSignatureFieldModel with the same properties
  @override
  duplicate() {
    AttachmentDigitalSignatureFieldModel newModel =
        AttachmentDigitalSignatureFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
    );
    return newModel;
  }

  @override
  AttachmentDigitalSignatureFieldController toController(
      {bool isSetData = false}) {
    AttachmentDigitalSignatureFieldController controller =
        AttachmentDigitalSignatureFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.isRequired = isRequired;
    controller.attachmentEntity = attachmentLink;
    return controller;
  }

  @override
  uploadMedia(
      {required String mediaPath, required String fileNamePrefix}) async {
    
    if (attachmentLink != null && !attachmentLink!.path.contains('http')) {
      
      attachmentLink!.path =
          await FirebaseRepository.uploadFileWithoutHandlingError(
              collectionName: mediaPath,
              documentName: createNewAttachmentName(
                  attachmentPath: attachmentLink!.path,
                  fileNamePrefix: fileNamePrefix),
              filePath: attachmentLink!.path);
    }
    
    return;
  }
}
