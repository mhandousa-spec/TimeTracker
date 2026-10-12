// ****************** FILE INFO ******************
// File Name: crm_template_field_edits_list.dart
// Purpose: Editable field cards list and current operation error message
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_editor_card.dart';

/// The list of editable field cards of the section/field element form.
class CrmTemplateFieldEditsList extends StatelessWidget {
  const CrmTemplateFieldEditsList({
    super.key,
    required this.fieldEdits,
    required this.fieldTypes,
    required this.readOnly,
    this.showRemove = true,
    required this.onChanged,
    required this.onRemove,
    this.operationError,
  });

  final List<CrmTemplateFieldEditModel> fieldEdits;
  final List<CrmFieldTypeModel> fieldTypes;
  final bool readOnly;
  final bool showRemove;
  final VoidCallback onChanged;
  final ValueChanged<CrmTemplateFieldEditModel> onRemove;
  final String? operationError;

  @override
  Widget build(BuildContext context) {
    final bool showOperationError =
        !readOnly && operationError != null && operationError!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final CrmTemplateFieldEditModel edit in fieldEdits) ...[
          CrmTemplateFieldEditorCard(
            model: edit,
            fieldTypes: fieldTypes,
            readOnly: readOnly,
            showRemove: showRemove,
            onChanged: onChanged,
            onRemove: () => onRemove(edit),
          ),
          SizedBox(height: 16.sp),
        ],
        if (showOperationError) ...[
          Text(
            operationError!,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.red,
            ),
          ),
          SizedBox(height: 12.sp),
        ],
      ],
    );
  }
}
