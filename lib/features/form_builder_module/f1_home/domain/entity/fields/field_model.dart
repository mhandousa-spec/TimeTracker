// Date: 21/1/2025
// By: mohamed Mohy
// Last update: 22/1/2025
// Objectives:  Represents the model for a generic field

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/title_field_model.dart';

class FieldModel {
  /// Type of the field
  FormFieldType type;

  /// Constructor for initializing the FieldModel instance
  FieldModel(this.type);

  /// Method to duplicate the field model
  /// Returns a new instance of FieldModel
  FieldModel? duplicate() {
    return null;
  }

  FieldController? toController({bool isSetData = false}) {
    return null;
  }

  ColumnModel? toModel() {
    return null;
  }

  static FieldModel? fromModel(ColumnModel model) {
    FormFieldType type = FormFieldType.values.firstWhere((element) {
      return (element.name.toLowerCase() == model.fieldType);
    });
    switch (type) {
      case FormFieldType.image:
        return ImageFieldModel.fromColumnModel(model);
      case FormFieldType.textField:
        return TextFieldModel.fromColumnModel(model);
      case FormFieldType.email:
        return EmailFieldModel.fromColumnModel(model);
      case FormFieldType.phone:
        return PhoneFieldModel.fromColumnModel(model);
      case FormFieldType.location:
        return LocationFieldModel.fromColumnModel(model);
      case FormFieldType.dropDown:
        return DropDownFieldModel.fromColumnModel(model);
      case FormFieldType.radio:
        return RadioFieldModel.fromColumnModel(model);
      case FormFieldType.checkBox:
        return CheckBoxFieldModel.fromColumnModel(model);

      case FormFieldType.termsAndCondition:
        return TermsAndConditionsFieldModel.fromColumnModel(model);

      case FormFieldType.description:
        return DescriptionFieldModel.fromColumnModel(model);
      case FormFieldType.attachment:
        return AttachmentFieldModel.fromColumnModel(model);
      case FormFieldType.link:
        return LinkFieldModel.fromColumnModel(model);
      case FormFieldType.digitalSignature:
        return AttachmentDigitalSignatureFieldModel.fromColumnModel(model);
      case FormFieldType.dateSelector:
        return DateFieldModel.fromColumnModel(model);
      case FormFieldType.address:
        return AddressFieldModel.fromColumnModel(model);
      case FormFieldType.timeSelector:
        return TimeSelectorFieldModel.fromColumnModel(model);
      case FormFieldType.title:
        return TitleFieldModel.fromColumnModel(model);
      case FormFieldType.radioTextField:
        return RadioTextFieldModel.fromColumnModel(model);

    }
  }

  /// MethodName: [uploadMedia]
  ///
  /// Description: Uploads media files to a specified path with a given prefix
  ///
  /// Parameters:
  /// - [mediaPath]: The path where the media files will be uploaded
  /// - [fileNamePrefix]: The prefix for the file names
  Future<void> uploadMedia(
      {required String mediaPath, required String fileNamePrefix}) async {}
}
