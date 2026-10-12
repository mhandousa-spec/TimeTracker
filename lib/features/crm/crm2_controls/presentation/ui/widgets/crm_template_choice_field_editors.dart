// ****************** FILE INFO ******************
// File Name: crm_template_choice_field_editors.dart
// Purpose: Choice-based CRM template field editors
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_inputs.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_type_row.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_options_editor.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateDropdownChoiceEditor extends StatelessWidget {
  const CrmTemplateDropdownChoiceEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return _ChoiceShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmAllowSearch,
            value: model.boolConfig(CrmFirestoreKeys.ALLOW_SEARCH_KEY),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.ALLOW_SEARCH_KEY, value);
              model.setConfig(CrmFirestoreKeys.ENABLE_SEARCH_KEY, value);
              onChanged();
            },
          ),
          right: const SizedBox.shrink(),
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

class CrmTemplateTagChoiceEditor extends StatelessWidget {
  const CrmTemplateTagChoiceEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return _ChoiceShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmMultipleChoice,
            value: model.boolConfig(
              CrmFirestoreKeys.ALLOW_MULTIPLE_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.ALLOW_MULTIPLE_KEY, value);
              model.setConfig(
                  CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY, value);
              onChanged();
            },
          ),
          right: CrmTemplateSwitchRow(
            title: S.current.crmAllowSearch,
            value: model.boolConfig(
              CrmFirestoreKeys.ALLOW_SEARCH_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.ALLOW_SEARCH_KEY, value);
              model.setConfig(CrmFirestoreKeys.ENABLE_SEARCH_KEY, value);
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

class _ChoiceShell extends StatelessWidget {
  const _ChoiceShell({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
    required this.children,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;
  final List<Widget> children;

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
        CrmTemplateOptionsEditor(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        ...children,
      ],
    );
  }
}
