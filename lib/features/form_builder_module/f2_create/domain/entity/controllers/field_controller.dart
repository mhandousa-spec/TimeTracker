import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_conditions_field_controller.dart'; // ✅ IMPORT THIS

class FieldController {
  FormFieldType type;

  FieldController(this.type);

  init() {}
  dispose() {}
  printModel() {}

  FieldController? duplicate() {
    return null;
  }

  FieldModel toModel({bool isSetAnswer = false}) {
    return FieldModel(type);
  }

  bool valid(){
    return true;
  }
}

extension FieldControllerExtension on FieldController {
  /// Every [TextEditingController] this field owns, whatever its type.
  ///
  /// ADDED 19/8/2026 for the "changes to Add Title / Limitation don't reach
  /// the preview until something else happens" bug.
  ///
  /// The cause: these controllers are handed straight to a `CustomTextField`,
  /// so typing mutates the controller IN PLACE. `CreateFormDataLoaded.pages`
  /// still points at the very same objects afterwards, so Equatable sees no
  /// change, nothing is emitted, and the preview — which reads `.text` off
  /// these at build time — keeps showing the old value until some unrelated
  /// action (adding a row, toggling Required) emits and drags it along. That
  /// is exactly the "delay or need refresh" in the report.
  ///
  /// `CreateFormDataCubit` subscribes to this list, so a keystroke re-emits by
  /// itself. Exposing it here rather than patching one widget means the fix
  /// covers EVERY field type — title, hint, limitation, options, terms, the
  /// lot — not just the Image field the bug was filed against.
  ///
  /// Keep this in step when a controller subclass gains or loses a text
  /// controller, or that field quietly stops updating live again.
  List<TextEditingController> get textControllers {
    switch (type) {
      case FormFieldType.image:
        final c = this as ImageFieldController;
        return [c.title, c.limitation]
            .whereType<TextEditingController>()
            .toList();
      case FormFieldType.textField:
        final c = this as TextFieldController;
        return [c.hint, c.title].whereType<TextEditingController>().toList();
      case FormFieldType.email:
        final c = this as EmailFieldController;
        return [c.hint, c.title].whereType<TextEditingController>().toList();
      case FormFieldType.phone:
        final c = this as PhoneFieldController;
        return [c.title].whereType<TextEditingController>().toList();
      case FormFieldType.location:
        final c = this as LocationFieldController;
        return [c.title, c.hintLatitude, c.hintLongitude, c.hintLink]
            .whereType<TextEditingController>()
            .toList();
      case FormFieldType.dropDown:
        final c = this as DropDownFieldController;
        return [if (c.title != null) c.title!, ...c.hints];
      case FormFieldType.radio:
        final c = this as RadioFieldController;
        return [if (c.title != null) c.title!, ...c.hints];
      case FormFieldType.checkBox:
        final c = this as CheckBoxFieldController;
        return [
          if (c.title != null) c.title!,
          if (c.maximumSelection != null) c.maximumSelection!,
          ...c.options.map((o) => o.option),
        ];
      case FormFieldType.termsAndCondition:
        final c = this as TermsConditionsFieldController;
        return [c.title, c.termsAr, c.termsEn]
            .whereType<TextEditingController>()
            .toList();
      case FormFieldType.description:
        final c = this as DescriptionFieldController;
        return [c.hint, c.title, c.limitation, c.answerController]
            .whereType<TextEditingController>()
            .toList();
      case FormFieldType.attachment:
        final c = this as AttachmentFieldController;
        return [c.title].whereType<TextEditingController>().toList();
      case FormFieldType.link:
        final c = this as LinkFieldController;
        return [c.hint, c.title].whereType<TextEditingController>().toList();
      case FormFieldType.digitalSignature:
        final c = this as AttachmentDigitalSignatureFieldController;
        return [c.title].whereType<TextEditingController>().toList();
      case FormFieldType.dateSelector:
        final c = this as DateFieldController;
        return [c.hint, c.title].whereType<TextEditingController>().toList();
      case FormFieldType.address:
        final c = this as AddressFieldController;
        return [if (c.title != null) c.title!, ...?c.hints];
      case FormFieldType.timeSelector:
        final c = this as TimeSelectorFieldController;
        return [c.title].whereType<TextEditingController>().toList();
      case FormFieldType.title:
        final c = this as TitleFieldController;
        return [c.title, c.textSize]
            .whereType<TextEditingController>()
            .toList();
      case FormFieldType.radioTextField:
        final c = this as RadioTextFieldController;
        return [...c.hints];
    }
  }

  FieldController initialize() {
    switch (type) {
      case FormFieldType.textField:
        return TextFieldController();
      case FormFieldType.email:
        return EmailFieldController();
      case FormFieldType.phone:
        return PhoneFieldController();
      case FormFieldType.location:
        return LocationFieldController();
      case FormFieldType.dropDown:
        return DropDownFieldController();
      case FormFieldType.radio:
        return RadioFieldController();
      case FormFieldType.checkBox:
        return CheckBoxFieldController();
      case FormFieldType.termsAndCondition:
        return TermsConditionsFieldController(); // ✅ FIXED
      case FormFieldType.description:
        return DescriptionFieldController();
      case FormFieldType.attachment:
        return AttachmentFieldController();
      case FormFieldType.link:
        return LinkFieldController();
      case FormFieldType.digitalSignature:
        return AttachmentDigitalSignatureFieldController();
      case FormFieldType.dateSelector:
        return DateFieldController();
      case FormFieldType.address:
        return AddressFieldController();
      case FormFieldType.timeSelector:
        return TimeSelectorFieldController();
      case FormFieldType.title:
        return TitleFieldController();
      case FormFieldType.image:
        return ImageFieldController();
      case FormFieldType.radioTextField:
        return RadioTextFieldController();
    }
  }

  changeIsRequired(value) {
    switch (type) {
      case FormFieldType.image:
        (this as ImageFieldController).isRequired = value;
        break;
      case FormFieldType.textField:
        (this as TextFieldController).isRequired = value;
        break;
      case FormFieldType.email:
        (this as EmailFieldController).isRequired = value;
        break;
      case FormFieldType.phone:
        (this as PhoneFieldController).isRequired = value;
        break;
      case FormFieldType.location:
        (this as LocationFieldController).isRequired = value;
        break;
      case FormFieldType.dropDown:
        (this as DropDownFieldController).isRequired = value;
        break;
      case FormFieldType.radio:
        (this as RadioFieldController).isRequired = value;
        break;
      case FormFieldType.checkBox:
        (this as CheckBoxFieldController).isRequired = value;
        break;
      case FormFieldType.termsAndCondition:
        (this as TermsConditionsFieldController).isRequired = true;
        break;
      case FormFieldType.description:
        (this as DescriptionFieldController).isRequired = value;
        break;
      case FormFieldType.attachment:
        (this as AttachmentFieldController).isRequired = value;
        break;
      case FormFieldType.link:
        (this as LinkFieldController).isRequired = value;
        break;
      case FormFieldType.digitalSignature:
        (this as AttachmentDigitalSignatureFieldController).isRequired = value;
        break;
      case FormFieldType.dateSelector:
        (this as DateFieldController).isRequired = value;
        break;
      case FormFieldType.address:
        (this as AddressFieldController).isRequired = value;
        break;
      case FormFieldType.timeSelector:
        (this as TimeSelectorFieldController).isRequired = value;
        break;
      case FormFieldType.title:
        (this as TitleFieldController).isRequired = value;
        break;
      case FormFieldType.radioTextField:
        (this as RadioTextFieldController).isRequired = value;
        break;
    }
  }

  bool getIsRequired() {
    switch (type) {
      case FormFieldType.image:
        return (this as ImageFieldController).isRequired ?? false;
      case FormFieldType.textField:
        return (this as TextFieldController).isRequired ?? false;
      case FormFieldType.email:
        return (this as EmailFieldController).isRequired ?? false;
      case FormFieldType.phone:
        return (this as PhoneFieldController).isRequired ?? false;
      case FormFieldType.location:
        return (this as LocationFieldController).isRequired ?? false;
      case FormFieldType.dropDown:
        return (this as DropDownFieldController).isRequired ?? false;
      case FormFieldType.radio:
        return (this as RadioFieldController).isRequired ?? false;
      case FormFieldType.checkBox:
        return (this as CheckBoxFieldController).isRequired ?? false;
      case FormFieldType.termsAndCondition:
        return (this as TermsConditionsFieldController).isRequired = true;
      case FormFieldType.description:
        return (this as DescriptionFieldController).isRequired ?? false;
      case FormFieldType.attachment:
        return (this as AttachmentFieldController).isRequired ?? false;
      case FormFieldType.link:
        return (this as LinkFieldController).isRequired ?? false;
      case FormFieldType.digitalSignature:
        return (this as AttachmentDigitalSignatureFieldController).isRequired ?? false;
      case FormFieldType.dateSelector:
        return (this as DateFieldController).isRequired ?? false;
      case FormFieldType.address:
        return (this as AddressFieldController).isRequired ?? false;
      case FormFieldType.timeSelector:
        return (this as TimeSelectorFieldController).isRequired ?? false;
      case FormFieldType.title:
        return (this as TitleFieldController).isRequired ?? false;
      case FormFieldType.radioTextField:
        return (this as RadioTextFieldController).isRequired ?? false;
    }
  }

  /// Whether this field holds an answer when a form is being FILLED OUT.
  ///
  /// ADDED for the form bug report (#16/#21/#22): Submit stays locked until
  /// every required field has one. Fields with nothing to answer (a title)
  /// count as filled.
  bool isAnswerFilled() {
    bool text(String? v) => v != null && v.trim().isNotEmpty;
    switch (type) {
      case FormFieldType.textField:
        return text((this as TextFieldController).answer);
      case FormFieldType.email:
        return text((this as EmailFieldController).answer);
      case FormFieldType.phone:
        return text((this as PhoneFieldController).phoneAnswer);
      case FormFieldType.link:
        return text((this as LinkFieldController).answer);
      case FormFieldType.dateSelector:
        return (this as DateFieldController).answerDate != null;
      case FormFieldType.dropDown:
        return text((this as DropDownFieldController).currentValue);
      case FormFieldType.description:
        return text((this as DescriptionFieldController).answerController?.text);
      case FormFieldType.radio:
        return (this as RadioFieldController).selectedRadio != null;
      case FormFieldType.radioTextField:
        return (this as RadioTextFieldController).selectedRadio != null;
      case FormFieldType.checkBox:
        return (this as CheckBoxFieldController)
            .options
            .any((option) => option.value == true);
      case FormFieldType.timeSelector:
        return text((this as TimeSelectorFieldController).time);
      case FormFieldType.address:
        final answers = (this as AddressFieldController).answers ?? <String>[];
        return answers.isNotEmpty && answers.every(text);
      case FormFieldType.location:
        final c = this as LocationFieldController;
        return text(c.answerLatitude) || text(c.answerLink);
      case FormFieldType.title:
        return true;
      default:
        // image / attachment / signature / terms: their own valid() already
        // encodes "required and still empty".
        return getIsValidated();
    }
  }

  bool getIsValidated() {
    switch (type) {
      case FormFieldType.image:
        return (this as ImageFieldController).valid();
      case FormFieldType.radio:
        return (this as RadioFieldController).valid();
      case FormFieldType.checkBox:
        return (this as CheckBoxFieldController).valid();
      case FormFieldType.termsAndCondition:
        return (this as TermsConditionsFieldController).valid(); // ✅ ADDED
      case FormFieldType.attachment:
        return (this as AttachmentFieldController).valid();
      case FormFieldType.digitalSignature:
        return (this as AttachmentDigitalSignatureFieldController).valid();
      case FormFieldType.radioTextField:
        return (this as RadioTextFieldController).valid();
      default:
        return true;
    }
  }

  changeAlignmentValue(String value) {
    switch (type) {
      case FormFieldType.textField:
        (this as TextFieldController).alignment = value;
        break;
      case FormFieldType.checkBox:
        (this as CheckBoxFieldController).alignment = value;
        break;
      case FormFieldType.termsAndCondition:
        (this as TermsConditionsFieldController).alignment = value; // ✅ ADDED
        break;
      case FormFieldType.dateSelector:
        (this as DateFieldController).alignment = value;
        break;
      case FormFieldType.dropDown:
        (this as DropDownFieldController).alignment = value;
        break;
      case FormFieldType.radio:
        (this as RadioFieldController).alignment = value;
        break;
      case FormFieldType.description:
        (this as DescriptionFieldController).alignment = value;
        break;
      case FormFieldType.email:
        (this as EmailFieldController).alignment = value;
        break;
      case FormFieldType.title:
        (this as TitleFieldController).alignment = value;
        break;
      case FormFieldType.link:
        (this as LinkFieldController).alignment = value;
        break;
      case FormFieldType.phone:
        (this as PhoneFieldController).alignment = value;
        break;
      case FormFieldType.digitalSignature:
        (this as AttachmentDigitalSignatureFieldController).alignment = value;
        break;
      case FormFieldType.attachment:
        (this as AttachmentFieldController).alignment = value;
        break;
      default:
        break;
    }
  }

  changeArrangementValue(String value) {
    switch (type) {
      case FormFieldType.radio:
        (this as RadioFieldController).arrangement = value;
        break;
      case FormFieldType.checkBox:
        (this as CheckBoxFieldController).arrangement = value;
        break;
    // ✅ NOTE: T&C doesn't have arrangement - single checkbox only
      default:
        break;
    }
  }

  addOption() {
    switch (type) {
      case FormFieldType.dropDown:
        (this as DropDownFieldController).hints.add(TextEditingController());
        break;
      case FormFieldType.radio:
        (this as RadioFieldController).hints.add(TextEditingController());
        break;
      case FormFieldType.checkBox:
        (this as CheckBoxFieldController)
            .options
            .add(CheckboxOptions(option: TextEditingController()));
        break;
    // ✅ NOTE: T&C doesn't have options
      case FormFieldType.address:
        (this as AddressFieldController).hints!.add(TextEditingController());
        break;
      case FormFieldType.radioTextField:
        (this as RadioTextFieldController).hints.add(TextEditingController());
        break;
      default:
        break;
    }
  }

  removeOption(int index) {
    switch (type) {
      case FormFieldType.dropDown:
        (this as DropDownFieldController).hints.removeAt(index);
        break;
      case FormFieldType.radio:
        (this as RadioFieldController).hints.removeAt(index);
        break;
      case FormFieldType.checkBox:
        (this as CheckBoxFieldController).options.removeAt(index);
        break;
    // ✅ NOTE: T&C doesn't have options to remove
      case FormFieldType.address:
        (this as AddressFieldController).hints!.removeAt(index);
        break;
      case FormFieldType.radioTextField:
        (this as RadioTextFieldController).hints.removeAt(index);
        break;
      default:
        break;
    }
  }
}