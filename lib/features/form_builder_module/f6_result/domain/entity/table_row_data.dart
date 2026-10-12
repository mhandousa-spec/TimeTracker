/// ************************ FILE INFO ************************
/// File_Name: table_row_data.dart
/// Purpose:
/// Author: mohamed Elrashidy
/// Created at: 25/3/2025

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/row_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';
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
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';
class TableRowData {
  String id;
  String firstName;
  String lastName;
  String department;
  String title;
  List<String> answers;

  TableRowData(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.department,
      required this.title,
      required this.answers});

  static TableRowData fromUserGridItem(UserGridItem user) {
    return TableRowData(
        id: user.person.id,
        firstName: FormatHelper.capitalize(user.person.name.split(' ')[0]),
        lastName: FormatHelper.capitalize(user.person.name.split(' ')[1]),
        department: FormatHelper.capitalize(user.person.departmentName),
        title: FormatHelper.capitalize(user.person.title),
        answers: _getAnswersFromPages(user.page!));
  }

  /// Method Name: [_getAnswersFromPages]
  ///
  /// Purpose: This method is responsible for getting the answers from the services_management_module.
  ///
  /// Arguments: [List<PageEntity>] services_management_module
  ///
  /// Returns: [List<String>] answers
  static _getAnswersFromPages(List<PageEntity> pages) {
    List<String> answers = [];

    for (PageEntity page in pages) {
      for (RowEntity row in page.rows) {
        for (FieldModel field in row.fields) {
          if (field.type == FormFieldType.title) continue;
          switch (field.type) {
            case FormFieldType.textField:
              answers.add((field as TextFieldModel).textAnswer ?? "");
              break;
            case FormFieldType.checkBox:
              List<String> ans = [];
              for (String option
                  in ((field as CheckBoxFieldModel).answers ?? [])) {
                ans.add(option);
              }
              
              answers.add(ans.join(', '));

              break;

            case FormFieldType.termsAndCondition:
              bool isAccepted = (field as TermsAndConditionsFieldModel).isAccepted ?? false;
              
              answers.add(isAccepted.toString());
              break;

            case FormFieldType.phone:
              answers.add((field as PhoneFieldModel).phoneAnswer ?? "");
              break;

            case FormFieldType.image:
              List<String> imagesList = [];
              if ((field as ImageFieldModel).images != null) {
                for (int i = 0; i < (field).images!.length; i++) {
                  if ((field).images![i] != null) {
                    imagesList.add((field).images![i]!);
                  }
                }
              }
              String images = _joinList(imagesList);
              answers.add(images);
            case FormFieldType.email:
              answers.add((field as EmailFieldModel).emailAnswer ?? "");
              break;
            case FormFieldType.location:
              String answer = "";
              if ((field as LocationFieldModel).latitudeLocationAnswer !=
                  null) {
                answer +=
                    "${(field as LocationFieldModel).latitudeLocationAnswer} : ${(field as LocationFieldModel).longitudeLocationAnswer}";
              } else {
                answer += "${(field as LocationFieldModel).linkLocationAnswer}";
              }
              answers.add(answer);
            case FormFieldType.dropDown:
              answers.add((field as DropDownFieldModel).currentValue ?? "");
              break;
            case FormFieldType.radio:
              answers.add((field as RadioFieldModel).selectedRadio ?? "");
              break;
            case FormFieldType.description:
              answers.add(
                  (field as DescriptionFieldModel).descriptionAnswer ?? "");
              break;
            case FormFieldType.attachment:
              answers.add(
                  (field as AttachmentFieldModel).attachmentLink?.path ?? "");
              break;
            case FormFieldType.link:
              answers.add((field as LinkFieldModel).linkAnswer ?? "");
              break;
            case FormFieldType.digitalSignature:
              answers.add((field as AttachmentDigitalSignatureFieldModel)
                      .attachmentLink
                      ?.path ??
                  "");
            case FormFieldType.dateSelector:
              answers.add((field as DateFieldModel).answerDate == null
                  ? ""
                  : DateFormat('dd/MM/yyyy')
                      .format((field as DateFieldModel).answerDate!));
              break;
            case FormFieldType.address:
              answers.add(_joinList((field as AddressFieldModel).answers));
              break;
            case FormFieldType.timeSelector:
              answers.add((field as TimeSelectorFieldModel).time ??
                  "${(field as TimeSelectorFieldModel).time != null ? ' : ' : ''}${((field as TimeSelectorFieldModel).amOrPm ?? "")}");
            case FormFieldType.title:
              /*answers.add((field as TitleFieldModel).title ?? "");*/
              break;
            case FormFieldType.radioTextField:
              answers.add((field as RadioTextFieldModel).selectedRadio ?? "");

              break;
          }
        }
      }
    }

    return answers;
  }

  static String _joinList(List<String>? strings) {
    return strings?.join(', ') ?? "";
  }

  /// Method Name: [_getTableList]
  ///
  /// Purpose: This method is responsible for getting the data as list of string with same order as table.
  ///
  /// Returns: [List<String>] tableList
  getTableList() {
    List<String> tableList = [];
    tableList.add(id);
    tableList.add(firstName);
    tableList.add(lastName);
    tableList.add(department);
    tableList.add(title);
    tableList.addAll(answers);
    return tableList;
  }
}
