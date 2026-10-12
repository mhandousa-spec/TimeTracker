// ***************************** FILE INFO ***************************** //
// File Name: add_employee_dropdown.dart
// Purpose: Provides the AddEmployeeDropdown widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'add_employee_read_only_scope.dart';

/// A validated adapter for the shared [CustomDropdown].
class AddEmployeeDropdown<T> extends StatelessWidget {
  const AddEmployeeDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.hint,
    required this.isRequired,
    required this.onChanged,
    this.validator,
  });

  final T? value;
  final List<DropdownItem<T>> items;
  final String label;
  final String hint;
  final bool isRequired;
  final ValueChanged<T> onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    if (!AddEmployeeReadOnlyScope.isEnabled(context)) {
      return IgnorePointer(
        child: CustomDropdown<T>(
          value: value,
          items: items,
          label: label,
          hint: hint,
          required: false,
          enabled: true,
          fillColor: AppColors.background,
        ),
      );
    }
    return FormField<T>(
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => CustomDropdown<T>(
        value: value,
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
