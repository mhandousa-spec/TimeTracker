// ***************************** FILE INFO ***************************** //
// File Name: add_employee_date_field.dart
// Purpose: Provides the AddEmployeeDateField widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';

import '../../../../../../core/custom/3-custom_dropdwon_calander.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'add_employee_read_only_scope.dart';

/// A validated adapter for the shared [CustomDropdownCalendar].
class AddEmployeeDateField extends StatelessWidget {
  const AddEmployeeDateField({
    super.key,
    required this.value,
    required this.label,
    required this.hint,
    required this.isRequired,
    required this.onChanged,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? value;
  final String label;
  final String hint;
  final ValueChanged<DateTime> onChanged;
  final FormFieldValidator<DateTime>? validator;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => CustomDropdownCalendar(
        value: value,
        label: label,
        hint: hint,
        required: false,
        enabled: AddEmployeeReadOnlyScope.isEnabled(context),
        errorText: field.errorText,
        fillColor: AppColors.background,
        firstDate: firstDate,
        lastDate: lastDate,
        onChanged: (selected) {
          if (selected == null) return;
          field.didChange(selected);
          onChanged(selected);
        },
      ),
    );
  }
}
