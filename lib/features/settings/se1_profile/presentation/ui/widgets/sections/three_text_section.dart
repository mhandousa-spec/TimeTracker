/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: three_text_section.dart
/// Purpose: Gender (dropdown) · Birth date (calendar) · Marital status
///          (dropdown) — one row on landscape, one column on portrait.
/// Author: Mohamed Elrashidy
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N05: split out of personal_data.dart, which
///          held three widget classes in one 523-line file. Date rendering now
///          goes through EmployeeDateFormatter (intl) rather than the
///          hand-rolled ArabicDigits replacement (N13), and Colors.transparent
///          is routed through AppColors (N15).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/employee_date_formatter.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ThreeTextSection extends StatefulWidget {
  // ── Gender ────────────────────────────────────────────────────────────────
  /// Selected gender key, e.g. `male` / `female`.
  final String? genderValue;

  /// Overrides the default male/female options.
  final List<DropdownItem<String>>? genderItems;
  final ValueChanged<String>? onGenderChanged;
  final String? genderHint;
  final String? genderError;

  // ── Birth date ────────────────────────────────────────────────────────────
  final DateTime? birthDate;
  final ValueChanged<DateTime?>? onBirthDateChanged;
  final String? birthDateHint;
  final String? birthDateError;
  final DateTime? firstDate;
  final DateTime? lastDate;

  // ── Marital status ────────────────────────────────────────────────────────
  /// Selected marital status key, e.g. `single` / `married`.
  final String? maritalStatusValue;

  /// Overrides the default single/married/divorced/widowed options.
  final List<DropdownItem<String>>? maritalStatusItems;
  final ValueChanged<String>? onMaritalStatusChanged;
  final String? maritalStatusHint;
  final String? maritalStatusError;

  // ── Shared ────────────────────────────────────────────────────────────────
  final bool isReadOnly;
  final bool required;

  const ThreeTextSection({
    super.key,
    required this.isReadOnly,
    this.genderValue,
    this.genderItems,
    this.onGenderChanged,
    this.genderHint,
    this.genderError,
    this.birthDate,
    this.onBirthDateChanged,
    this.birthDateHint,
    this.birthDateError,
    this.firstDate,
    this.lastDate,
    this.maritalStatusValue,
    this.maritalStatusItems,
    this.onMaritalStatusChanged,
    this.maritalStatusHint,
    this.maritalStatusError,
    this.required = false,
  });

  @override
  State<ThreeTextSection> createState() => _ThreeTextSectionState();
}

class _ThreeTextSectionState extends State<ThreeTextSection> {
  String? _gender;
  String? _maritalStatus;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _gender = widget.genderValue;
    _maritalStatus = widget.maritalStatusValue;
    _birthDate = widget.birthDate;
  }

  @override
  void didUpdateWidget(covariant ThreeTextSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.genderValue != widget.genderValue) {
      _gender = widget.genderValue;
    }
    if (oldWidget.maritalStatusValue != widget.maritalStatusValue) {
      _maritalStatus = widget.maritalStatusValue;
    }
    if (oldWidget.birthDate != widget.birthDate) {
      _birthDate = widget.birthDate;
    }
  }

  // ── Default option sets ───────────────────────────────────────────────────

  List<DropdownItem<String>> _genderItems(BuildContext context) =>
      widget.genderItems ??
      <DropdownItem<String>>[
        DropdownItem<String>(value: 'male', label: S.of(context).male),
        DropdownItem<String>(value: 'female', label: S.of(context).female),
      ];

  List<DropdownItem<String>> _maritalStatusItems(BuildContext context) =>
      widget.maritalStatusItems ??
      <DropdownItem<String>>[
        DropdownItem<String>(value: 'single', label: S.of(context).single),
        DropdownItem<String>(value: 'married', label: S.of(context).married),
        DropdownItem<String>(value: 'divorced', label: S.of(context).divorced),
        DropdownItem<String>(value: 'widowed', label: S.of(context).widowed),
      ];

  // ── Individual fields ─────────────────────────────────────────────────────

  /// CustomDropdown fades its label when disabled, CustomTextField does not.
  /// Pin it so a read-only "Gender" label matches a read-only "First Name".
  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  // ── Read-only rendering ───────────────────────────────────────────────────
  //
  // ADDED 8/9/2026. The personal-information VIEW passes `isReadOnly: true`,
  // which until now only reached `enabled: false` on the dropdowns and the
  // calendar. Disabling them does not remove their trailing chevron and
  // calendar icon, so a page that cannot be edited still looked like a form —
  // three tappable-looking controls sitting under the name fields, which are
  // plain text boxes on the same card.
  //
  // On the view these three now render as disabled [CustomTextField]s: same
  // widget, same styles and same default radius as the names directly above
  // them, so the whole card reads as displayed data.
  //
  // The edit pages are untouched — they pass `isReadOnly: false` and still get
  // the real pickers.

  /// One value shown as a plain, non-interactive field.
  Widget _readOnlyField({
    required String label,
    required String hint,
    required String? value,
  }) {
    return CustomTextField(
      // CustomTextField reads `initialValue` once, in initState. The profile
      // arrives after the first build, so without a value-derived key the
      // field would keep showing whatever was there when it was created.
      key: ValueKey<String>('$label|${value ?? ''}'),
      label: label,
      hint: hint,
      initialValue: value ?? '',
      enabled: false,
      maxLines: 1,
      valueStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight400
          .copyWith(color: AppColors.secondaryText),
    );
  }

  /// The human-readable label for a stored key (`male` -> "Male"), so the
  /// read-only field shows what the dropdown would have shown rather than the
  /// raw value. Returns null for an unknown or absent key, which leaves the
  /// hint visible.
  String? _labelFor(List<DropdownItem<String>> items, String? value) {
    if (value == null) return null;
    for (final DropdownItem<String> item in items) {
      if (item.value == value) return item.label;
    }
    return null;
  }

  Widget _buildGenderField(BuildContext context) {
    if (widget.isReadOnly) {
      return _readOnlyField(
        label: S.of(context).gender,
        hint: widget.genderHint ?? S.of(context).selectGender,
        value: _labelFor(_genderItems(context), _gender),
      );
    }

    return CustomDropdown<String>(
      label: S.of(context).gender,
      hint: widget.genderHint ?? S.of(context).selectGender,
      value: _gender,
      items: _genderItems(context),
      errorText: widget.genderError,
      enabled: !widget.isReadOnly,
      required: widget.required,
      labelStyle: _labelStyle,
      // HEIGHT 21/9/2026 (Settings bug report p.11/p.15): pinned so every field
      // in the row paints the same box — left to size themselves, the
      // dropdown (20.sp chevron), the calendar (18.sp icon) and the text field
      // each came out a slightly different height.
      height: 40,
      borderRadius: BorderRadius.circular(4.r),
      onChanged: (String value) {
        setState(() => _gender = value);
        widget.onGenderChanged?.call(value);
      },
    );
  }

  Widget _buildBirthdayField(BuildContext context) {
    // The locale comes from the widget tree, not from Get.locale — a UI widget
    // should not be asking a service locator what language it is in (§13).
    final String localeName = Localizations.localeOf(context).toLanguageTag();

    if (widget.isReadOnly) {
      return _readOnlyField(
        label: S.of(context).birthday,
        hint: widget.birthDateHint ?? S.of(context).enterbirthday,
        value: _birthDate == null
            ? null
            : EmployeeDateFormatter.format(_birthDate!, localeName: localeName),
      );
    }

    return CustomDropdownCalendar(
      label: S.of(context).birthday,
      hint: widget.birthDateHint ?? S.of(context).enterbirthday,
      value: _birthDate,
      errorText: widget.birthDateError,
      enabled: !widget.isReadOnly,
      required: widget.required,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime.now(),
      // HEIGHT 21/9/2026 (Settings bug report p.11/p.15): pinned so every field
      // in the row paints the same box — left to size themselves, the
      // dropdown (20.sp chevron), the calendar (18.sp icon) and the text field
      // each came out a slightly different height.
      height: 40,
      borderRadius: BorderRadius.circular(4.r),
      dateFormatter: (DateTime date) =>
          EmployeeDateFormatter.format(date, localeName: localeName),
      onChanged: (DateTime? date) {
        setState(() => _birthDate = date);
        widget.onBirthDateChanged?.call(date);
      },
    );
  }

  Widget _buildMaritalStatusField(BuildContext context) {
    if (widget.isReadOnly) {
      return _readOnlyField(
        label: S.of(context).status,
        hint: widget.maritalStatusHint ?? S.of(context).maritalStatus,
        value: _labelFor(_maritalStatusItems(context), _maritalStatus),
      );
    }

    return CustomDropdown<String>(
      label: S.of(context).status,
      hint: widget.maritalStatusHint ?? S.of(context).maritalStatus,
      value: _maritalStatus,
      items: _maritalStatusItems(context),
      errorText: widget.maritalStatusError,
      enabled: !widget.isReadOnly,
      required: widget.required,
      labelStyle: _labelStyle,
      // HEIGHT 21/9/2026 (Settings bug report p.11/p.15): pinned so every field
      // in the row paints the same box — left to size themselves, the
      // dropdown (20.sp chevron), the calendar (18.sp icon) and the text field
      // each came out a slightly different height.
      height: 40,
      borderRadius: BorderRadius.circular(4.r),
      onChanged: (String value) {
        setState(() => _maritalStatus = value);
        widget.onMaritalStatusChanged?.call(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final List<Widget> fields = <Widget>[
      _buildGenderField(context),
      _buildBirthdayField(context),
      _buildMaritalStatusField(context),
    ];

    return Theme(
      data: Theme.of(context).copyWith(hoverColor: AppColors.transparent),
      child: isVertical
          ? _buildVerticalLayout(context, fields)
          : _buildHorizontalLayout(fields),
    );
  }

  Widget _buildVerticalLayout(BuildContext context, List<Widget> fields) {
    // NOT `ContextExtension(context).isPhone` / `context.isPhone`.
    //
    // This file imports core/helper/main_helper/extensions.dart, whose
    // extension is ALSO called ContextExtension — and its `isPhone` is
    //
    //     bool get isPhone => MediaQuery.of(this).size.width >= 600;
    //
    // i.e. true on WIDE screens, the exact inverse of
    // core/extensions/context_extensions.dart's `shortestSide < 600`. Same
    // name, same target type, opposite meaning, and the file's own comment
    // admits it. Every `isPhone` here was therefore reading FALSE on a phone.
    // Computed inline so it cannot bind to the wrong extension again.
    final bool isPhone = MediaQuery.of(context).size.shortestSide < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < fields.length; i++) ...<Widget>[
          fields[i],
          // Mobile only: matches the 16.h the edit page uses between fields.
          if (i != fields.length - 1) SizedBox(height: isPhone ? 10.sp : 16.h),
        ],
      ],
    );
  }

  Widget _buildHorizontalLayout(List<Widget> fields) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < fields.length; i++) ...<Widget>[
          Expanded(child: fields[i]),
          if (i != fields.length - 1) SizedBox(width: 12.w),
        ],
      ],
    );
  }
}
