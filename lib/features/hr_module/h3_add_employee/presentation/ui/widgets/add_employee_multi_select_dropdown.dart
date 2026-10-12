// ***************************** FILE INFO ***************************** //
// File Name: add_employee_multi_select_dropdown.dart
// Purpose: Provides the AddEmployeeMultiSelectDropdown widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';

import '../../../../../../core/custom/31-custom_multi_select_dropdown.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'add_employee_read_only_scope.dart';

/// A validated adapter for the shared [CustomMultiSelectDropdown].
class AddEmployeeMultiSelectDropdown<T> extends StatelessWidget {
  const AddEmployeeMultiSelectDropdown({
    super.key,
    required this.values,
    required this.items,
    required this.label,
    required this.hint,
    required this.isRequired,
    required this.onChanged,
    required this.validator,
  });

  final List<T> values;
  final List<MultiSelectDropdownItem<T>> items;
  final String label;
  final String hint;
  final bool isRequired;
  final ValueChanged<List<T>> onChanged;
  final FormFieldValidator<List<T>> validator;

  @override
  Widget build(BuildContext context) {
    if (!AddEmployeeReadOnlyScope.isEnabled(context)) {
      return CustomMultiSelectDropdown<T>(
        values: values,
        items: items,
        label: label,
        hint: hint,
        required: false,
        enabled: false,
        fillColor: AppColors.background,
      );
    }
    return FormField<List<T>>(
      initialValue: values,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => CustomMultiSelectDropdown<T>(
        values: values,
        items: items,
        label: label,
        hint: hint,
        required: false,
        errorText: field.errorText,
        fillColor: AppColors.background,
        onChanged: (selected) {
          field.didChange(selected);
          onChanged(selected);
        },
      ),
    );
  }
}
