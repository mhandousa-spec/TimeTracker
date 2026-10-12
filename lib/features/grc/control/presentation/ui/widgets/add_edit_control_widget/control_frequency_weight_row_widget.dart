/// Module: GRC Policy Management
/// Description: Frequency dropdown + Control Weight field paired row for
///              the Add/Edit Control form, extracted from
///              AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, CustomDropdown, CustomTextField, ControlFrequency
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_frequency_weight_row_widget.dart
/// Purpose: Contains ControlFrequencyWeightRowWidget, the Frequency +
///          Control Weight paired row. Owns the live Control Weight
///          validation (must be a positive number no greater than 100).
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_frequency.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_responsive_field_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ControlFrequencyWeightRowWidget]
///
/// purpose: renders the Frequency dropdown next to the Control Weight
///          field. Mirrors AddEditControlPage's own `_weightError` rule so
///          validation stays live as the user types.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlFrequencyWeightRowWidget extends StatefulWidget {
  final bool isTablet;
  final bool submitted;
  final String? frequency;
  final ValueChanged<String?> onFrequencyChanged;
  final TextEditingController weightController;

  const ControlFrequencyWeightRowWidget({
    super.key,
    required this.isTablet,
    required this.submitted,
    required this.frequency,
    required this.onFrequencyChanged,
    required this.weightController,
  });

  @override
  State<ControlFrequencyWeightRowWidget> createState() =>
      _ControlFrequencyWeightRowWidgetState();
}

class _ControlFrequencyWeightRowWidgetState
    extends State<ControlFrequencyWeightRowWidget> {
  @override
  void initState() {
    super.initState();
    widget.weightController.addListener(_onWeightChanged);
  }

  @override
  void dispose() {
    widget.weightController.removeListener(_onWeightChanged);
    super.dispose();
  }

  void _onWeightChanged() => setState(() {});

  /// Live validation for the Control Weight field: must be a positive
  /// number no greater than 100, mirroring Policy Weight's own rule.
  String? get _weightError {
    final text = widget.weightController.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null) return S.of(context).controlWeightMustBeAValidNumber;
    if (value <= 0) return S.of(context).controlWeightMustBeAPositiveNumber;
    if (value > 100) return S.of(context).controlWeightCannotBeMoreThan100;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GrcResponsiveFieldRow(
      isTablet: widget.isTablet,
      children: [
        CustomDropdown<String>(
          label: S.of(context).frequency,
          hint: S.of(context).chooseHere,
          items: ControlFrequency.allValues
              .map((d) => DropdownItem<String>(value: d, label: d))
              .toList(),
          value: widget.frequency,
          onChanged: widget.onFrequencyChanged,
          fillColor: AppColors.background,
          errorText: widget.submitted && widget.frequency == null
              ? S.of(context).thisFieldIsRequired
              : null,
        ),
        CustomTextField(
          label: S.of(context).controlWeight,
          hint: S.of(context).Texthere,
          controller: widget.weightController,
          required: true,
          submitted: widget.submitted,
          onlyDigits: true,
          errorText: _weightError,
          fillColor: AppColors.background,
          onChanged: (_) {},
        ),
      ],
    );
  }
}
