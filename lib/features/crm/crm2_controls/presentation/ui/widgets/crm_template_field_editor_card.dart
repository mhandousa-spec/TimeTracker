// ****************** FILE INFO ******************
// File Name: crm_template_field_editor_card.dart
// Purpose: Firestore-backed CRM template field editor card widgets
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_choice_field_editors.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_address_inputs.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_inputs.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_options_editor.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_type_row.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_special_field_editors.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_shared_widgets.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_value_signature_website_editors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateFieldEditorCard extends StatelessWidget {
  const CrmTemplateFieldEditorCard({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.onRemove,
    this.readOnly = false,
    this.showRemove = true,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final bool readOnly;
  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    return CrmTemplateSectionShell(
      title: S.current.crmFieldDetails,
      isExpanded: model.isExpanded,
      showToggle: !readOnly,
      onToggleExpand: () {
        model.isExpanded = !model.isExpanded;
        onChanged();
      },
      trailingActions: readOnly || !showRemove
          ? null
          : CustomDeleteIcon(
              color: AppColors.red,
              svgColor: AppColors.white,
              onTap: onRemove,
            ),
      child: _FieldEditorContent(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      ),
    );
  }
}

class _FieldEditorContent extends StatelessWidget {
  const _FieldEditorContent({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (model.field.fieldTypeId.trim().isEmpty) {
      return CrmTemplateFieldTypeRow(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }

    final String fieldTypeId = model.field.fieldTypeId.toLowerCase();
    final String type = model
        .stringConfig(
          CrmFirestoreKeys.FIELD_KIND_KEY,
          fallback: model.field.fieldTypeId,
        )
        .toLowerCase();
    if (fieldTypeId == 'purchasing_value') {
      return CrmTemplatePurchasingValueEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (fieldTypeId == 'website') {
      return CrmTemplateWebsiteEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (fieldTypeId == 'business_initiation_date') {
      return CrmTemplateDateEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'address') {
      return _AddressEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'dropdown' || type == 'checkbox' || type == 'radio') {
      return CrmTemplateDropdownChoiceEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'tag') {
      return CrmTemplateTagChoiceEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'email') {
      return _EmailEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'phone') {
      return _PhoneEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'image') {
      return _ImageEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'description') {
      return CrmTemplateDescriptionEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'link') {
      return CrmTemplateLinkEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'attachment' || type == 'file') {
      return CrmTemplateFileEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'signature') {
      return CrmTemplateSignatureEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'date') {
      return CrmTemplateDateEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'time') {
      return CrmTemplateTimeEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    if (type == 'switch') {
      return CrmTemplateSwitchEditor(
        model: model,
        fieldTypes: fieldTypes,
        onChanged: onChanged,
        readOnly: readOnly,
      );
    }
    return _TextEditor(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
    );
  }
}

class _TextEditor extends StatelessWidget {
  const _TextEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrmTemplateFieldTypeRow(
          model: model,
          fieldTypes: fieldTypes,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        CrmTemplateNameRow(model: model, readOnly: readOnly),
        SizedBox(height: 16.sp),
        CrmTemplateMaxAndValidationRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmShowBothLanguages,
            value: model.field.showBothLanguages,
            readOnly: readOnly,
            onChanged: (bool value) {
              model.field = model.field.copyWith(showBothLanguages: value);
              onChanged();
            },
          ),
          right: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _EmailEditor extends StatelessWidget {
  const _EmailEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrmTemplateFieldTypeRow(
          model: model,
          fieldTypes: fieldTypes,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        CrmTemplateNameRow(model: model, readOnly: readOnly),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchInput(
            title: S.current.crmAllowMultipleEmails,
            value: model.boolConfig(CrmFirestoreKeys.ALLOW_MULTIPLE_KEY),
            controller: model.maxController,
            inputTitle: S.current.crmMaxLength,
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.ALLOW_MULTIPLE_KEY, value);
              model.setConfig(
                CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY,
                value,
              );
              onChanged();
            },
          ),
          right: CrmTemplateSwitchInput(
            title: S.current.crmMaxLength,
            value: model.boolConfig(CrmFirestoreKeys.MAX_LENGTH_ENABLED_KEY),
            controller: model.maxController,
            inputTitle: S.current.crmMaxNumber,
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.MAX_LENGTH_ENABLED_KEY, value);
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateLabeledField(
          title: S.current.crmFormatExample,
          controller: model.formatController,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmUnique,
            value: model.boolConfig(
              CrmFirestoreKeys.UNIQUE_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.UNIQUE_KEY, value);
              model.setConfig(CrmFirestoreKeys.IS_UNIQUE_KEY, value);
              onChanged();
            },
          ),
          right: CrmTemplateSwitchRow(
            title: S.current.crmTrimSpaces,
            value: model.boolConfig(CrmFirestoreKeys.TRIM_SPACES_KEY),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.TRIM_SPACES_KEY, value);
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class _PhoneEditor extends StatelessWidget {
  const _PhoneEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrmTemplateFieldTypeRow(
          model: model,
          fieldTypes: fieldTypes,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        CrmTemplateNameRow(model: model, readOnly: readOnly),
        SizedBox(height: 16.sp),
        CrmTemplatePhoneOptionsSection(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmUnique,
            value: model.boolConfig(CrmFirestoreKeys.UNIQUE_KEY),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.UNIQUE_KEY, value);
              model.setConfig(CrmFirestoreKeys.IS_UNIQUE_KEY, value);
              onChanged();
            },
          ),
          right: CrmTemplateSwitchRow(
            title: S.current.crmAllowSpaces,
            value: model.boolConfig(
              CrmFirestoreKeys.ALLOW_SPACES_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.ALLOW_SPACES_KEY, value);
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class _ImageEditor extends StatelessWidget {
  const _ImageEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrmTemplateFieldTypeRow(
          model: model,
          fieldTypes: fieldTypes,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        CrmTemplateNameRow(model: model, readOnly: readOnly),
        SizedBox(height: 16.sp),
        CrmTemplateImageConstraintsSection(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class _AddressEditor extends StatelessWidget {
  const _AddressEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final String entryType = model.stringConfig(
      CrmFirestoreKeys.ENTRY_TYPE_KEY,
      fallback: 'Text Field',
    );
    final String addressComponent = model.stringConfig(
      CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
      fallback: 'City',
    );
    final bool showDropdownOptions = entryType == 'Dropdown' &&
        addressComponent != 'Country' &&
        addressComponent != 'City';

    return Column(
      children: [
        CrmTemplateFieldTypeRow(
          model: model,
          fieldTypes: fieldTypes,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateDropdownBox(
            title: S.current.crmAddressComponents,
            value: model.stringConfig(CrmFirestoreKeys.ADDRESS_COMPONENT_KEY),
            items: const [
              'Country',
              'City',
              'State / Province',
              'Street',
              'Postal / ZIP Code',
              'Building / Suite / Unit',
            ],
            readOnly: readOnly,
            onChanged: (String value) {
              model.setConfig(CrmFirestoreKeys.ADDRESS_COMPONENT_KEY, value);
              onChanged();
            },
          ),
          right: CrmTemplateDropdownBox(
            title: S.current.crmEntryType,
            value: model.stringConfig(CrmFirestoreKeys.ENTRY_TYPE_KEY),
            items: const ['Text Field', 'Dropdown'],
            readOnly: readOnly,
            onChanged: (String value) {
              model.setConfig(CrmFirestoreKeys.ENTRY_TYPE_KEY, value);
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateAddressSelectorRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        if (showDropdownOptions) ...[
          SizedBox(height: 16.sp),
          CrmTemplateOptionsEditor(
            model: model,
            onChanged: onChanged,
            readOnly: readOnly,
          ),
        ],
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmAllowSpecialCharacters,
            value: model.boolConfig(
              CrmFirestoreKeys.ALLOW_SPECIAL_CHARACTERS_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(
                CrmFirestoreKeys.ALLOW_SPECIAL_CHARACTERS_KEY,
                value,
              );
              onChanged();
            },
          ),
          right: CrmTemplateSwitchRow(
            title: S.current.crmTrimSpaces,
            value: model.boolConfig(
              CrmFirestoreKeys.TRIM_SPACES_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.TRIM_SPACES_KEY, value);
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}
