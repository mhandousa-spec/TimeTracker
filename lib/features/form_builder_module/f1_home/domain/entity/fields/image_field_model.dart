import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/core/helper/form_builder/attachment_helper.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for an image field, including title, limitation, images, and requirement status.

/// Represents the model for an image field
class ImageFieldModel extends FieldModel {
  /// Title of the image field
  String title;

  /// Limitation or maximum size of the image
  String limitation;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of image links
  List<String?>? images;

  /// Constructor for initializing the ImageFieldModel instance
  ImageFieldModel({
    required this.isRequired,
    required this.title,
    required this.limitation,
    required this.images,
  }) : super(FormFieldType.image);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: null,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.image.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: int.parse(limitation),
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: images?.map((e) => e).join(', '),
    );
  }

//fromModel

  static FieldModel fromColumnModel(ColumnModel model) {
    return ImageFieldModel(
      isRequired: model.isRequired!,
      title: model.title!,
      limitation: model.limitation.toString(),
      images: model.response != null
          ? model.response!.split(', ').map((e) => e).toList()
          : [],
    );
  }

  /// Method to duplicate the image field model
  /// Returns a new instance of ImageFieldModel with the same properties
  @override
  duplicate() {
    ImageFieldModel newModel = ImageFieldModel(
      isRequired: isRequired,
      title: title,
      limitation: limitation,
      images: List<String>.from(images!),
    );
    return newModel;
  }

  @override
  ImageFieldController toController({bool isSetData = false}) {
    ImageFieldController controller = ImageFieldController();
    controller.limitation!.text = limitation;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.insertImagesList(limitation);
    controller.imagesLink = images ?? controller.imagesLink;

    return controller;
  }

  @override
  uploadMedia(
      {required String mediaPath, required String fileNamePrefix}) async {
    
    if (images != null) {
      for (int i = 0; i < images!.length; i++) {
        if (images![i] != null &&
            images![i] != 'null' &&
            !images![i]!.contains('http')) {
          
          images![i] = await FirebaseRepository.uploadFileWithoutHandlingError(
              collectionName: mediaPath,
              documentName: createNewAttachmentName(
                  attachmentPath: images![i]!, fileNamePrefix: fileNamePrefix),
              filePath: images![i]!);
        }
      }
    }
    return;
  }
}
