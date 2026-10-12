import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';

abstract class AnalyticsHelper {
  /// Safely resolves a country from a phone dial code, returning `null`
  /// instead of throwing when the code can't be parsed. Keeps try/catch out
  /// of UI widgets (§11.2) — parsing safety lives in this util (§11.1).
  static Country? safeParsePhoneCode(String dialCode) {
    try {
      return CountryParser.parsePhoneCode(dialCode);
    } catch (_) {
      return null;
    }
  }

  static dynamic getFieldAnswer(FieldModel model) {
    switch (model.type) {
      case FormFieldType.dropDown:
        {
          return (model as DropDownFieldModel).currentValue ?? "";
        }
      case FormFieldType.radio:
        {
          return (model as RadioFieldModel).selectedRadio ?? "";
        }
      case FormFieldType.description:
        {
          return (model as DescriptionFieldModel).descriptionAnswer ?? "";
        }
      case FormFieldType.textField:
        {
          return (model as TextFieldModel).textAnswer ?? "";
        }
      case FormFieldType.email:
        {
          return (model as EmailFieldModel).emailAnswer ?? "";
        }
      case FormFieldType.dateSelector:
        {
          return (model as DateFieldModel).answerDate == null
              ? ""
              : DateFormat("dd/MM/yyyy",
                      Localizations.localeOf(Get.context!).toString())
                  .format((model).answerDate!);
        }
      case FormFieldType.link:
        {
          return (model as LinkFieldModel).linkAnswer ?? "";
        }
      case FormFieldType.location:
        {
          String ans = "";
          if ((model as LocationFieldModel).locationType.toLowerCase() ==
              "link") {
            ans = (model).linkLocationAnswer ?? "";
          } else {
            ans = (model).latitudeLocationAnswer ?? "";
            ans += ",";
            ans += (model).longitudeLocationAnswer ?? "";
          }
          return ans;
        }
      case FormFieldType.phone:
        {
          String ans = "";
          ans += (model as PhoneFieldModel).phoneCodeAnswer ?? "";
          ans += "-";
          ans += (model).phoneAnswer ?? "";
          return ans;
        }
      case FormFieldType.address:
        {
          List<String> answers = (model as AddressFieldModel).answers ?? [];
          String ans = "";
          
          if (answers.isEmpty || answers.first.isEmpty) {
            answers = List.filled(model.hints.length, " ");
          }
          ans = answers.join(',   ');

          return ans;
        }
      case FormFieldType.timeSelector:
        {
          String ans = "";
          ans += (model as TimeSelectorFieldModel).time ?? "";
          ans += " ";
          ans += (model).amOrPm ?? "";
          
          return ans;
        }
      case FormFieldType.checkBox:
        {
          List<String> ans = [];
          ans = (model as CheckBoxFieldModel).answers ?? [];
          return ans.join(', ');
        }

      default:
        return "";
    }
  }

  static bool doughnutChartAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.dropDown:
        return true;
      case FormFieldType.radio:
        return true;
      default:
        return false;
    }
  }

  static bool isChartWithFixedOptions(FormFieldType type) {
    switch (type) {
      case FormFieldType.dropDown:
        return true;
      case FormFieldType.radio:
        return true;
      case FormFieldType.checkBox:
        return true;
      default:
        return false;
    }
  }

  static bool barChartAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.checkBox:
        return true;
      case FormFieldType.timeSelector:
        return true;
      case FormFieldType.dateSelector:
        return true;
      case FormFieldType.address:
        return true;
      default:
        return false;
    }
  }

  static bool answerAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.textField:
        return true;
      case FormFieldType.email:
        return true;
      case FormFieldType.phone:
        return true;
      case FormFieldType.location:
        return true;
      case FormFieldType.description:
        return true;
      case FormFieldType.link:
        return true;
      case FormFieldType.timeSelector:
        return true;
      case FormFieldType.dateSelector:
        return true;
      case FormFieldType.address:
        return true;
      default:
        return false;
    }
  }

  static bool isHasAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.title:
        return false;
      case FormFieldType.image:
        return false;
      case FormFieldType.attachment:
        return false;
      case FormFieldType.digitalSignature:
        return false;
      case FormFieldType.radioTextField:
        return false;
      default:
        return true;
    }
  }

  static bool hasTextFieldAndAggregated(FormFieldType type) {
    switch (type) {
      case FormFieldType.timeSelector:
        return true;
      case FormFieldType.dateSelector:
        return true;
      case FormFieldType.address:
        return true;
      default:
        return false;
    }
  }
}
