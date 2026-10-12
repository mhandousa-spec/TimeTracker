import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/address_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/attachment_digital_signature_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/attachment_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/check_box_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/date_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/description_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/drop_down_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/email_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/image_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/link_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/location_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/phone_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/radio_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/radio_text_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/text_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/time_selector_field_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/title_field_widget.dart';

/// Builds the editable field widget for a column based on its [type].
Widget buildColumnFieldWidget(
  FormFieldType type,
  int index,
  int rowIndex,
  int pageIndex,
  bool isReadOnly,
) {
  final key = ValueKey('field_${pageIndex}_${rowIndex}_${index}_${type.name}');

  final widgetMap = {
    FormFieldType.image: () => ImageFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.textField: () => TextFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.email: () => EmailFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.phone: () => PhoneFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.location: () => LocationFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.dropDown: () => DropDownFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.radio: () => RadioFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.checkBox: () => CheckBoxFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.termsAndCondition: () => TermsAndConditionsFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.description: () => DescriptionFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.attachment: () => AttachmentFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.link: () => LinkFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.digitalSignature: () => AttachmentDigitalSignatureFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.dateSelector: () => DateFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.address: () => AddressFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.timeSelector: () => TimeSelectorFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.radioTextField: () => RadioTextFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
    FormFieldType.title: () => TitleFieldWidget(
          key: key,
          columnIndex: index,
          rowIndex: rowIndex,
          pageIndex: pageIndex,
          isReadOnly: isReadOnly,
        ),
  };
  return widgetMap[type]!();
}
