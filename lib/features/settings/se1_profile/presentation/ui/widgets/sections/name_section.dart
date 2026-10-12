/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: name_section.dart
/// Purpose: First / middle / last name — a row on landscape, a column on
///          phones. Built on the shared [CustomTextField].
/// Author: Mohamed Elrashidy
/// Created at: 09/08/2026
/// Updated: 11/8/2026 - CR-SKEL-SE1-N15/N18: text direction now comes from the
///          widget tree instead of `Get.locale` (§13), which also removes the
///          GetX import; Colors.transparent routed through AppColors.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class NameSection extends StatefulWidget {
  // ── First name ────────────────────────────────────────────────────────────
  final String firstNameHint;
  final String? firstNameInitialValue;
  final Function(String)? firstNameOnChanged;
  final String? firstNameError;

  // ── Middle name ───────────────────────────────────────────────────────────
  final String middleNameHint;
  final String? middleNameInitialValue;
  final Function(String)? middleNameOnChanged;
  final String? middleNameError;

  // ── Last name ─────────────────────────────────────────────────────────────
  final String lastNameHint;
  final String? lastNameInitialValue;
  final Function(String)? lastNameOnChanged;
  final String? lastNameError;

  // ── Shared ────────────────────────────────────────────────────────────────
  final bool isReadOnly;
  final bool required;
  final bool submitted;
  final String? title;

  const NameSection({
    super.key,
    required this.isReadOnly,
    required this.firstNameHint,
    required this.middleNameHint,
    required this.lastNameHint,
    this.firstNameInitialValue,
    this.middleNameInitialValue,
    this.lastNameInitialValue,
    this.firstNameOnChanged,
    this.middleNameOnChanged,
    this.lastNameOnChanged,
    this.firstNameError,
    this.middleNameError,
    this.lastNameError,
    this.required = false,
    this.submitted = false,
    this.title,
  });

  @override
  State<NameSection> createState() => _NameSectionState();
}

class _NameSectionState extends State<NameSection> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.firstNameInitialValue ?? '');
    _middleNameController =
        TextEditingController(text: widget.middleNameInitialValue ?? '');
    _lastNameController =
        TextEditingController(text: widget.lastNameInitialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant NameSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstNameInitialValue != widget.firstNameInitialValue) {
      _firstNameController.text = widget.firstNameInitialValue ?? '';
    }
    if (oldWidget.middleNameInitialValue != widget.middleNameInitialValue) {
      _middleNameController.text = widget.middleNameInitialValue ?? '';
    }
    if (oldWidget.lastNameInitialValue != widget.lastNameInitialValue) {
      _lastNameController.text = widget.lastNameInitialValue ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  /// Reads the locale from the tree, not from GetX (§13).
  TextDirection get _direction =>
      Directionality.of(context);

  // ── Single field builder — used by both layouts ───────────────────────────
  Widget _nameField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String)? onChanged,
    String? errorText,
  }) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      errorText: errorText,
      textDirection: _direction,
      enabled: !widget.isReadOnly,
      required: widget.required,
      submitted: widget.submitted,
      maxLines: 1,
      valueStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight400
          .copyWith(color: AppColors.secondaryText),
      onChanged: (value) => onChanged?.call(value),
    );
  }

  List<Widget> _fields(BuildContext context) => [
        _nameField(
          label: S.of(context).firstName,
          hint: widget.firstNameHint,
          controller: _firstNameController,
          onChanged: widget.firstNameOnChanged,
          errorText: widget.firstNameError,
        ),
        _nameField(
          label: S.of(context).middleName,
          hint: widget.middleNameHint,
          controller: _middleNameController,
          onChanged: widget.middleNameOnChanged,
          errorText: widget.middleNameError,
        ),
        _nameField(
          label: S.of(context).lastName,
          hint: widget.lastNameHint,
          controller: _lastNameController,
          onChanged: widget.lastNameOnChanged,
          errorText: widget.lastNameError,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    // Phone spacing scale (mobile only — every other breakpoint keeps its
    // original value): 10.sp between fields, 15.sp after a title.
    final isPhone = ContextExtension(context).isPhone;

    return Theme(
      data: Theme.of(context).copyWith(hoverColor: AppColors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style:
                  StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
            ),
            SizedBox(height: isPhone ? 15.sp : 16.h),
          ],
          isVertical
              ? _buildVerticalLayout(context)
              : _buildHorizontalLayout(context),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    final isPhone = ContextExtension(context).isPhone;
    final fields = _fields(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          fields[i],
          if (i != fields.length - 1)
            SizedBox(height: isPhone ? 10.sp : 16.h),
        ],
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    final fields = _fields(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          Expanded(child: fields[i]),
          if (i != fields.length - 1) SizedBox(width: 12.w),
        ],
      ],
    );
  }
}
