import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/table_row_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
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
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
List<DataColumn> buildResultTableColumns(ResultLoaded state) {
  return List<DataColumn>.from(buildResultTableHeaders(state).map((header) {
    return DataColumn(
      label: Text(header, style: StyleText.fontSize16Weight400.copyWith(color: Colors.white)),
    );
  }));
}

List<DataRow> buildResultTableRows(ResultLoaded state) {
  List<DataRow> rows = [];
  for (int userIndex = 0;
      userIndex < state.filteredSubmittedUsers.length;
      userIndex++) {
    TableRowData tableRowData =
        TableRowData.fromUserGridItem(state.filteredSubmittedUsers[userIndex]);
    List<DataCell> cells = [];
    for (var answer in tableRowData.getTableList()) {
      cells.add(DataCell(
        Text(answer, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)),
      ));
    }
    rows.add(DataRow(
      cells: cells,
      color: WidgetStatePropertyAll(
        userIndex % 2 == 0 ? AppColors.evenRowColor : AppColors.oddRowColor,
      ),
    ));
  }
  return rows;
}

List<String> buildResultTableHeaders(ResultLoaded state) {
  List<String> headers = [];
  headers.add('Employee ID');
  headers.add('First Name');
  headers.add('Last Name');
  headers.add('Department');
  headers.add('Job Title');

  for (PageEntity page in state.formEntity!.pages) {
    for (var row in page.rows) {
      for (var field in row.fields) {
        if (field.type == FormFieldType.title) continue;
        switch (field.type) {
          case FormFieldType.textField:
            headers.add((field as TextFieldModel).title);
            break;
          case FormFieldType.checkBox:
            headers.add((field as CheckBoxFieldModel).title);
            break;

          case FormFieldType.termsAndCondition:
            headers.add((field as TermsAndConditionsFieldModel).title);
            break;

          case FormFieldType.phone:
            headers.add((field as PhoneFieldModel).title);
            break;
          case FormFieldType.image:
            headers.add((field as ImageFieldModel).title ?? "");
            break;
          case FormFieldType.link:
            headers.add((field as LinkFieldModel).title ?? "");
            break;
          case FormFieldType.email:
            headers.add((field as EmailFieldModel).title ?? "");
            break;
          case FormFieldType.radio:
            headers.add((field as RadioFieldModel).title ?? "");
            break;
          case FormFieldType.radioTextField:
            headers.add('Radio - Text Field');
            break;
          case FormFieldType.title:
          case FormFieldType.location:
            headers.add('Location');
          case FormFieldType.dropDown:
            headers.add((field as DropDownFieldModel).title);
            break;
          case FormFieldType.description:
            headers.add((field as DescriptionFieldModel).title);
            break;
          case FormFieldType.attachment:
            headers.add((field as AttachmentFieldModel).title);
            break;
          case FormFieldType.digitalSignature:
            headers.add((field as AttachmentDigitalSignatureFieldModel).title);
            break;
          case FormFieldType.dateSelector:
            headers.add((field as DateFieldModel).title);
            break;
          case FormFieldType.address:
            headers.add((field as AddressFieldModel).title);
            break;
          case FormFieldType.timeSelector:
            headers.add((field as TimeSelectorFieldModel).title ?? "");
            break;
        }
      }
    }
  }

  return headers;
}
