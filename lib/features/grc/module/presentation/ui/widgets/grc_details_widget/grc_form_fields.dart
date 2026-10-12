/// Module: GRC Module Management
/// Description: Provides the form input fields for the GRC Module details page,
///              including bilingual name/description fields, department dropdown,
///              and activation date picker.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, CustomTextField, CustomDropdown, CustomDropdownCalendar
/// Revision History: 2026-06-29 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_form_fields.dart
/// Purpose: Contains GrcFormFields, a stateless widget that renders all input
///          fields needed to create or edit a GRC Module record.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcFormFields]
///
/// purpose: stateless form section for a GRC Module. Renders bilingual name
///          fields (EN/AR), bilingual description fields, owning-department
///          dropdown, and activation-date picker. All values are managed by the
///          parent page's state via controllers and callbacks.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
bool containsEnglishLetters(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

bool containsArabicLetters(String text) => RegExp(r'[؀-ۿ]').hasMatch(text);

class GrcFormFields extends StatefulWidget {
  final TextEditingController nameEnController;
  final TextEditingController nameArController;
  final TextEditingController descEnController;
  final TextEditingController descArController;
  final String? selectedDepartment;
  final DateTime? activationDate;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final bool submitted;
  final bool readOnly;

  const GrcFormFields({
    super.key,
    required this.nameEnController,
    required this.nameArController,
    required this.descEnController,
    required this.descArController,
    required this.selectedDepartment,
    required this.activationDate,
    required this.onDepartmentChanged,
    required this.onDateChanged,
    this.submitted = false,
    this.readOnly = false,
  });

  @override
  State<GrcFormFields> createState() => _GrcFormFieldsState();
}

class _GrcFormFieldsState extends State<GrcFormFields> {
  @override
  void initState() {
    super.initState();
    for (final controller in _bilingualControllers) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _bilingualControllers) {
      controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  List<TextEditingController> get _bilingualControllers => [
        widget.nameEnController,
        widget.nameArController,
        widget.descEnController,
        widget.descArController,
      ];

  void _onTextChanged() => setState(() {});

  /// Computes error text for an English-language bilingual field: a required
  /// check first, then a wrong-script (Arabic letters present) check.
  String? _englishFieldErrorText({
    required bool submitted,
    required String text,
    required String requiredMessage,
    required String wrongScriptMessage,
  }) {
    if (submitted && text.trim().isEmpty) return requiredMessage;
    if (containsArabicLetters(text)) return wrongScriptMessage;
    return null;
  }

  /// Computes error text for an Arabic-language bilingual field: a required
  /// check first, then a wrong-script (English letters present) check.
  String? _arabicFieldErrorText({
    required bool submitted,
    required String text,
    required String requiredMessage,
    required String wrongScriptMessage,
  }) {
    if (submitted && text.trim().isEmpty) return requiredMessage;
    if (containsEnglishLetters(text)) return wrongScriptMessage;
    return null;
  }

  /// Computes error text for a non-text field (dropdown/date picker): only a
  /// required-field check, and only once the form has been submitted.
  String? _requiredFieldErrorText({
    required bool submitted,
    required bool isEmpty,
    required String requiredMessage,
  }) {
    if (!submitted) return null;
    return isEmpty ? requiredMessage : null;
  }

  Widget _buildNameEnField(bool submitted, bool readOnly) {
    final nameEnController = widget.nameEnController;
    return CustomTextField(
      label: 'GRC Module Name',
      hint: 'Text here',
      controller: nameEnController,
      autoCapitalize: true,
      // Latin-only, enforced at the keystroke (and on paste) rather than
      // reported afterwards. See the AR twin for why.
      textDirection: TextDirection.ltr,
      restrictByDirection: true,
      errorText: _englishFieldErrorText(
        submitted: submitted,
        text: nameEnController.text,
        requiredMessage: "GRC Module Name is required",
        wrongScriptMessage: "GRC Module Name must be written in English",
      ),
      submitted: submitted,
      readOnly: readOnly,
      fillColor: AppColors.background,
      valueStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      labelStyle:
          StyleText.fontSize16Weight500.copyWith(fontSize: 14.sp),
      onChanged: (_) {},
    );
  }

  Widget _buildNameArField(bool submitted, bool readOnly) {
    final nameArController = widget.nameArController;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'عنوان اطار الحوكمه',
        hint: 'اكتب هنا',
        controller: nameArController,
        // Arabic-only, enforced at the KEYSTROKE rather than reported after
        // the fact.
        //
        // The "must be written in Arabic" message is a two-line error slot
        // that opens under this field only. Because the EN and AR name fields
        // are Expanded siblings in one Row, that growth pushed the AR input
        // box down while the EN box stayed put, and the pair visibly came out
        // of line mid-typing — the gap in the screenshot.
        //
        // CustomTextField already ships the fix: `restrictByDirection` wires
        // up _ArabicOnlyInputFormatter, which REJECTS an edit that adds Latin
        // letters instead of stripping them, so the clipboard survives a
        // mis-paste. It keys off the widget's OWN textDirection, not the
        // ambient Directionality, so that has to be passed explicitly.
        //
        // The errorText validators below stay: they still catch mixed-script
        // values that arrive pre-filled from an existing record, which no
        // input formatter can reach.
        textDirection: TextDirection.rtl,
        restrictByDirection: true,
        errorText: _arabicFieldErrorText(
          submitted: submitted,
          text: nameArController.text,
          requiredMessage: S.of(context).grcModuleNameIsRequired,
          wrongScriptMessage: S.of(context).grcModuleNameMustBeWrittenInArabic,
        ),
        submitted: submitted,
        readOnly: readOnly,
        fillColor: AppColors.background,
        valueStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.text),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText),
        // IDENTICAL to the English twin's label style, and that is the point.
        //
        // This one alone was `fontSize: 12.sp, height: 2.2`, which is a line
        // box of 12 x 2.2 = 26.4 against roughly 21 for a 14.sp label at the
        // style's own height. `height` scales the LINE BOX, not the glyphs, so
        // the extra ~5 logical pixels went straight into the label's height —
        // and since the label sits above the input inside each field, the
        // Arabic input box started ~5px lower than the English one with no
        // error text involved at all.
        //
        // The two fields are Expanded siblings in one Row, so any difference
        // in label height shows up as the pair failing to line up.
        labelStyle: StyleText.fontSize16Weight500.copyWith(fontSize: 14.sp),
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildDepartmentField(
    BuildContext context,
    String? selectedDepartment,
    ValueChanged<String?> onDepartmentChanged,
    bool submitted,
    bool readOnly,
    String requiredError,
  ) {
    return CustomDropdown<String>(
      label: S.of(context).OwningDepartment,
      hint: S.of(context).chooseDepartment,
      items: Get.find<MainCoreDepartmentCubit>().departmentIds.map((id) {
        final depCtrl = Get.find<MainCoreDepartmentCubit>();
        final label = FormatHelper.capitalize(
          context.isArabic
              ? depCtrl.getArabicDepartmentNameFromDepartmentId(
                      departmentId: id) ??
                  ''
              : depCtrl.getEnglishDepartmentNameFromDepartmentId(
                      departmentId: id) ??
                  '',
        );
        return DropdownItem<String>(value: label, label: label);
      }).toList(),
      value: selectedDepartment,
      onChanged: onDepartmentChanged,
      enabled: !readOnly,
      fillColor: AppColors.background,
      errorText: _requiredFieldErrorText(
        submitted: submitted,
        isEmpty: selectedDepartment == null,
        requiredMessage: requiredError,
      ),
      labelStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      valueStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      borderRadius: BorderRadius.circular(4.r),
      required: false,
      // GRC bug report p10: same height as the Activation Date beside it.
      height: 38,
    );
  }

  Widget _buildActivationDateField(
    BuildContext context,
    DateTime? activationDate,
    ValueChanged<DateTime?> onDateChanged,
    bool submitted,
    bool readOnly,
    String requiredError,
  ) {
    // final today = DateTime.now();
    // final startOfToday = DateTime(today.year, today.month, today.day);
    // final isPastDate =
    //     activationDate != null && activationDate.isBefore(startOfToday);

    return CustomDropdownCalendar(
      borderRadius: BorderRadius.circular(4.r),
      height: 38, // GRC bug report p10: matches Owning Department

      label: S.of(context).activationDate,
      hint: S.of(context).selectActivationDate,
      value: activationDate,
      onChanged: onDateChanged,
      enabled: !readOnly,
      fillColor: AppColors.background,
      // firstDate: startOfToday,
      dateFormatter: (d) =>
          DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en').format(d),
      errorText: _requiredFieldErrorText(
        submitted: submitted,
        isEmpty: activationDate == null,
        requiredMessage: requiredError,
      ),
      labelStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      valueStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      required: false,
    );
  }

  Widget _buildDescEnField(bool submitted, bool readOnly) {
    final descEnController = widget.descEnController;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomTextField(
        label: 'Description',
        hint: 'Text here',
        autoCapitalize: true,
        controller: descEnController,
        textDirection: TextDirection.ltr,
        restrictByDirection: true,
        errorText: _englishFieldErrorText(
          submitted: submitted,
          text: descEnController.text,
          requiredMessage: "Description is required",
          wrongScriptMessage: "Description must be written in English",
        ),
        submitted: submitted,
        readOnly: readOnly,
        maxLines: 3,
        minLines: 3,
        maxLength: 500, // GRC bug report p11: 500, not 1000
        showCharCount: true,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        valueStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.text),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText),
        labelStyle:
            StyleText.fontSize16Weight500.copyWith(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildDescArField(bool submitted, bool readOnly) {
    final descArController = widget.descArController;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'الوصف',
        hint: 'اكتب وصف',
        controller: descArController,
        textDirection: TextDirection.rtl,
        restrictByDirection: true,
        errorText: _arabicFieldErrorText(
          submitted: submitted,
          text: descArController.text,
          requiredMessage: S.of(context).descriptionIsRequired,
          wrongScriptMessage: S.of(context).descriptionMustBeWrittenInArabic,
        ),
        submitted: submitted,
        readOnly: readOnly,
        maxLines: 3,
        minLines: 3,
        maxLength: 500, // GRC bug report p11: 500, not 1000
        showCharCount: true,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        valueStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.text),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText),
        labelStyle:
            StyleText.fontSize16Weight500.copyWith(fontSize: 14.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDepartment = widget.selectedDepartment;
    final activationDate = widget.activationDate;
    final onDepartmentChanged = widget.onDepartmentChanged;
    final onDateChanged = widget.onDateChanged;
    final submitted = widget.submitted;
    final readOnly = widget.readOnly;

    final requiredError = S.of(context).thisFieldIsRequired;

    // Figma lays the bilingual pairs out side by side at 768 (310 each)
    // and 1024 (410 each), and stacks them at 375. Keyed off width, not
    // shortestSide, so a phone in landscape doesn't claim the wide rows.
    final bool isWide = screenSizeOf(context) != ScreenSize.mobile;

    final nameEnField = _buildNameEnField(submitted, readOnly);
    final nameArField = _buildNameArField(submitted, readOnly);
    final departmentField = _buildDepartmentField(
      context,
      selectedDepartment,
      onDepartmentChanged,
      submitted,
      readOnly,
      requiredError,
    );
    final activationDateField = _buildActivationDateField(
      context,
      activationDate,
      onDateChanged,
      submitted,
      readOnly,
      requiredError,
    );

    return Column(
      children: [
        // ── Module name (EN + AR) ─────────────────────────────────────────────
        Directionality(
          textDirection: TextDirection.ltr,
          child: isWide
              ? Row(
                  // TOP, not the Row default of centre.
                  //
                  // Blocking wrong-script input (see the field builders above)
                  // stops the commonest error, but not every one: submit with
                  // only the English name filled and a "required" message
                  // still opens under the Arabic field alone. Centred, the
                  // shorter column slides DOWN by half that message's height,
                  // so the two input boxes stop lining up whenever the pair is
                  // uneven. Anchored at the top they never move, and the error
                  // simply hangs below the field it belongs to.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: nameEnField),
                    SizedBox(width: 15.w),
                    Expanded(child: nameArField),
                  ],
                )
              : Column(
                  children: context.isArabic
                      ? [
                          nameArField,
                          SizedBox(height: 15.h),
                          nameEnField,
                        ]
                      : [
                          nameEnField,
                          SizedBox(height: 15.h),
                          nameArField,
                        ],
                ),
        ),
        SizedBox(height: 15.h),

        // ── Description EN ────────────────────────────────────────────────────
        _buildDescEnField(submitted, readOnly),
        SizedBox(height: 15.h),

        // ── Description AR ────────────────────────────────────────────────────
        _buildDescArField(submitted, readOnly),
        SizedBox(height: 15.h),

        // ── Owning Department + Activation Date ───────────────────────────────
        isWide
            ? Row(
                // Same reason as the name pair above: an error under one of
                // these two must not shift the other one's box.
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: departmentField),
                  SizedBox(width: 15.w),
                  Expanded(child: activationDateField),
                ],
              )
            : Column(
                children: [
                  departmentField,
                  SizedBox(height: 15.h),
                  activationDateField,
                ],
              ),
      ],
    );
  }
}
