import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';

mixin EditValidator {
  bool allowEditing({required FormEntity old, required FormEntity edited}) {
    if (old.numberUsed == 0) {
      return true;
    }
    if (old.pages.length != edited.pages.length) {
      return false;
    }
    for (int pageIndex = 0; pageIndex < old.pages.length; pageIndex++) {
      if (old.pages[pageIndex].rows.length !=
          edited.pages[pageIndex].rows.length) {
        return false;
      }
      for (int rowIndex = 0;
          rowIndex < old.pages[pageIndex].rows.length;
          rowIndex++) {
        if (old.pages[pageIndex].rows[rowIndex].fields.length !=
            edited.pages[pageIndex].rows[rowIndex].fields.length) {
          return false;
        }
        for (int columnIndex = 0;
            columnIndex < old.pages[pageIndex].rows[rowIndex].fields.length;
            columnIndex++) {
          FieldModel oldField =
              old.pages[pageIndex].rows[rowIndex].fields[columnIndex];
          FieldModel? editedField;
          try {
            editedField =
                edited.pages[pageIndex].rows[rowIndex].fields[columnIndex];
          } catch (e) {
            return false;
          }
          if (!isSameField(oldField, editedField)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool isSameField(FieldModel oldField, FieldModel editedField) {

    if (oldField.type != editedField.type) {
      return false;
    }
    if (oldField.type == FormFieldType.dropDown) {
      oldField = oldField as DropDownFieldModel;
      editedField = editedField as DropDownFieldModel;
      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.checkBox) {
      oldField = oldField as CheckBoxFieldModel;
      editedField = editedField as CheckBoxFieldModel;
      if (oldField.options.length > editedField.options.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.options.length;
          optionIndex++) {
        if (oldField.options[optionIndex] != editedField.options[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.radio) {
      oldField = oldField as RadioFieldModel;
      editedField = editedField as RadioFieldModel;

      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.radioTextField) {
      oldField = oldField as RadioTextFieldModel;
      editedField = editedField as RadioTextFieldModel;

      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.location) {
      oldField = oldField as LocationFieldModel;
      editedField = editedField as LocationFieldModel;
      if (oldField.locationType != editedField.locationType) {
        return false;
      }
    }

    if (oldField.type == FormFieldType.address) {
      oldField = oldField as AddressFieldModel;
      editedField = editedField as AddressFieldModel;
      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }
    return true;
  }
}
