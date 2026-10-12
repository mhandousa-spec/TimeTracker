// ***************************** FILE INFO ***************************** //
// File Name: add_employee_time_field.dart
// Purpose: Provides the AddEmployeeTimeField widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';

import '../../../../../../core/custom/2-custom_textfield.dart';
import '../../../../../../core/custom/62-custom_date_time_helper.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'add_employee_read_only_scope.dart';

/// A required time selector stored as a formatted controller value.
class AddEmployeeTimeField extends StatelessWidget {
  const AddEmployeeTimeField({
    super.key,
    required this.controller,
    this.label,
    required this.hint,
    required this.isRequired,
    required this.onChanged,
    required this.validator,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final bool isRequired;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    if (!AddEmployeeReadOnlyScope.isEnabled(context)) {
      return IgnorePointer(
        child: CustomTextField(
          controller: controller,
          label: label,
          hint: hint,
          required: false,
          readOnly: true,
          suffixIcon: const Icon(Icons.access_time_outlined),
          fillColor: AppColors.background,
        ),
      );
    }
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked == null) return;
          if (!context.mounted) return;
          final formatted = FormDateTimeHelper.formatTimeOfDayToString(picked);
          field.didChange(formatted);
          onChanged(formatted);
        },
        child: IgnorePointer(
          child: CustomTextField(
            controller: controller,
            label: label,
            hint: hint,
            required: false,
            errorText: field.errorText,
            suffixIcon: const Icon(Icons.access_time_outlined),
            fillColor: AppColors.background,
          ),
        ),
      ),
    );
  }
}
