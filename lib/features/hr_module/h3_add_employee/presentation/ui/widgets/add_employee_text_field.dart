// ***************************** FILE INFO ***************************** //
// File Name: add_employee_text_field.dart
// Purpose: Provides the AddEmployeeTextField widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/custom/2-custom_textfield.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../controller/add_employee_cubit.dart';
import 'add_employee_read_only_scope.dart';

/// A validated adapter for the shared [CustomTextField].
class AddEmployeeTextField extends StatelessWidget {
  const AddEmployeeTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isRequired,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.readOnly = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isRequired;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final bool readOnly;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    if (!AddEmployeeReadOnlyScope.isEnabled(context)) {
      return Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) context.read<AddEmployeeCubit>().refreshProgress();
        },
        child: _withExplicitDirection(
          CustomTextField(
            controller: controller,
            label: label,
            hint: hint,
            required: false,
            readOnly: true,
            keyboardType: keyboardType,
            textDirection: textDirection,
            maxLines: maxLines,
            fillColor: AppColors.background,
          ),
        ),
      );
    }
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) context.read<AddEmployeeCubit>().refreshProgress();
        },
        child: _withExplicitDirection(
          CustomTextField(
            controller: controller,
            label: label,
            hint: hint,
            required: false,
            readOnly: readOnly,
            errorText: field.errorText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textDirection: textDirection,
            maxLines: maxLines,
            fillColor: AppColors.background,
            onChanged: field.didChange,
          ),
        ),
      ),
    );
  }

  /// Method Name: [_withExplicitDirection]
  ///
  /// Purpose: Aligns fixed-language labels and field content independently of
  /// the active application locale.
  ///
  /// Parameters:
  /// - [child]: Text field rendered with the requested language direction.
  ///
  /// Returns: The field wrapped in [Directionality] when a direction is set.
  Widget _withExplicitDirection(Widget child) {
    final direction = textDirection;
    if (direction == null) return child;
    return Directionality(textDirection: direction, child: child);
  }
}
