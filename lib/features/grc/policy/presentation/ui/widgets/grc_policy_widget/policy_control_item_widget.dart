/// Module: GRC Policy Management
/// Description: Card widget for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlModel, PolicyDocumentPreviewWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Control Document into English/Arabic
///                   2026-07-14 - Converted to StatefulWidget; added Control
///                                Number field and English/Arabic
///                                language-mismatch validation
///                   2026-09-16 - Wrong-script input is now blocked (as in
///                                the role form); required errors only after
///                                Preview; paired fields top-aligned
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_item_widget.dart
/// Purpose: Contains PolicyControlItemWidget, a card widget that renders
///          all fields for a single policy control entry. Validates that EN
///          fields contain no Arabic letters and vice versa.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_frequency.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_completeness.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_responsive_field_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'policy_document_preview_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

class PolicyControlItemWidget extends StatefulWidget {
  final PolicyControlModel control;
  final bool isArabicEnabled;
  final bool showRemoveButton;
  final VoidCallback? onRemove;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;
  final ValueChanged<String?> onFrequencyChanged;
  final DateTime? policyStartDate;
  final DateTime? policyEndDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final bool controlsSubmitted;

  /// Zero-based position in the list; shown as "Control 1", "Control 2"…
  /// in the card header. Null hides the title.
  final int? index;

  /// Fires on every keystroke in any of this control's text fields — the
  /// parent page's own completeness/error checks (e.g. the Preview button's
  /// enabled state) read straight from these same TextEditingControllers,
  /// so it needs to rebuild on every change, not just on the
  /// dropdown/date/document callbacks below.
  final VoidCallback? onChanged;

  const PolicyControlItemWidget({
    super.key,
    required this.control,
    required this.isArabicEnabled,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    required this.onFrequencyChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.controlsSubmitted,
    this.policyStartDate,
    this.policyEndDate,
    this.showRemoveButton = false,
    this.onRemove,
    this.onChanged,
    this.index,
  });

  @override
  State<PolicyControlItemWidget> createState() =>
      _PolicyControlItemWidgetState();
}

/// Unscaled height shared by every single-line field and the Frequency
/// dropdown on this card (both widgets apply `.sp` internally).
const double _kSingleLineFieldHeight = 38;

class _PolicyControlItemWidgetState extends State<PolicyControlItemWidget> {
  List<TextEditingController> get _bilingualControllers => [
        widget.control.nameController,
        widget.control.nameArController,
        widget.control.numberController,
        widget.control.numberArController,
        widget.control.descriptionController,
        widget.control.descriptionArController,
      ];

  @override
  void initState() {
    super.initState();
    for (final c in _bilingualControllers) {
      c.addListener(_onTextChanged);
    }
    widget.control.weightController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    for (final c in _bilingualControllers) {
      c.removeListener(_onTextChanged);
    }
    widget.control.weightController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call();
  }

  TextStyle get _labelStyle =>
      StyleText.fontSize16Weight400.copyWith(fontSize: 14.sp);
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText);
  TextStyle get _hintStyle => StyleText.fontSize14Weight500
      .copyWith(color: AppColors.secondaryText.withOpacity(.5));

  /// Same behaviour as the role form (adding_new_role.dart): the field
  /// itself BLOCKS the wrong script via CustomTextField.restrictByDirection
  /// (English fields reject Arabic letters, Arabic fields reject English
  /// letters), so no language-mismatch error is ever shown. The "required"
  /// error appears only after Preview was pressed with this field empty
  /// ([PolicyControlItemWidget.controlsSubmitted]).
  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
    bool isMandatory = false,
    bool onlyDigits = false,
  }) {
    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      onlyDigits: onlyDigits,
      restrictByDirection: !onlyDigits,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      submitted: widget.controlsSubmitted && isMandatory,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      // 4.r, matching the dropdown's own default and the date pickers --
      // every field in this flow uses the same corner.
      borderRadius: BorderRadius.circular(4.r),
      // UNSCALED — CustomTextField applies `.sp` itself (30.h here was
      // scaled twice). Same value as the Frequency dropdown's `height`, so
      // the two fields in that row are exactly the same height.
      height: maxLines == null ? _kSingleLineFieldHeight : null,
      valueStyle: _valueStyle,
      hintStyle: _hintStyle,
      labelStyle: _labelStyle,
      onChanged: (_) {},
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
  }

  Widget _documentButton({required VoidCallback onTap, required String title}) {
    // Phone: 36.sp tall with a 12.sp title. Tablet / desktop unchanged.
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return customButtonWithSvg(
      fixedHeight: isMobile ? 36.sp : null,
      colorBorder: AppColors.primary,
      widthImage: 16.w,
      heightImage: 16.h,
      function: onTap,
      title: title,
      textStyle: isMobile
          ? StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton, fontSize: 12.sp)
          : StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
      image: 'assets/icons_assets/data_grc_assets/upload_minimalistic.svg',
      color: AppColors.primary,
      svgColor: AppColors.textButton,
    );
  }

  /// function name: [_documentColumn]
  ///
  /// purpose: one document upload/preview column — shared by the ENG and AR
  ///          Control Document sections so their layout stays identical
  ///          whether they're shown side by side or (Arabic disabled) alone.
  Widget _documentColumn({
    required String label,
    required PolicyDocumentInfo? document,
    required VoidCallback onRemove,
    required VoidCallback onUpload,
  }) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        document != null
            ? PolicyDocumentPreviewWidget(
                document: document, onRemove: onRemove)
            : SizedBox(
                width: double.infinity,
                child: _documentButton(
                    onTap: onUpload, title: S.of(context).controlDocument),
              ),
      ],
    );
  }

  /// The Control Name (English) + (Arabic-or-Number) paired row.
  Widget _buildNameRow(bool isTablet) {
    final control = widget.control;
    return GrcResponsiveFieldRow(
      mobileSpacing: 5.sp,
      isTablet: isTablet,
      children: [
        _textField(
          label: S.of(context).controlName,
          hint: S.of(context).Texthere,
          controller: control.nameController,
          isMandatory: true,
        ),
        widget.isArabicEnabled
            ? _textField(
                label: "اسم ضابط",
                hint: 'اكتب هنا',
                controller: control.nameArController,
                rtl: true,
                isMandatory: controlArabicTouched(control),
              )
            : _textField(
                label: S.of(context).controlNumber,
                hint: S.of(context).Texthere,
                controller: control.numberController,
                isMandatory: true,
              ),
      ],
    );
  }

  /// The Control Number (English) + (Arabic) paired row — Arabic mode only.
  Widget _buildNumberRow(bool isTablet) {
    final control = widget.control;
    return GrcResponsiveFieldRow(
      mobileSpacing: 5.sp,
      isTablet: isTablet,
      children: [
        _textField(
          label: S.of(context).controlNumber,
          hint: S.of(context).Texthere,
          controller: control.numberController,
          isMandatory: true,
        ),
        _textField(
          label: "رقم الضابط",
          hint: 'اكتب هنا',
          controller: control.numberArController,
          rtl: true,
          isMandatory: controlArabicTouched(control),
        ),
      ],
    );
  }

  /// The Control Description (English) and, in Arabic mode, (Arabic) fields.
  Widget _buildDescriptionFields() {
    final control = widget.control;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textField(
          label: S.of(context).controlDescription,
          hint: S.of(context).Texthere,
          controller: control.descriptionController,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
          isMandatory: true,
        ),
        if (widget.isArabicEnabled) ...[
          SizedBox(height: 5.sp),
          _textField(
            label: "وصف التحكم",
            hint: 'اكتب هنا',
            controller: control.descriptionArController,
            rtl: true,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            isMandatory: controlArabicTouched(control),
          ),
        ],
      ],
    );
  }

  /// The Frequency dropdown + Control Weight field paired row.
  Widget _buildFrequencyWeightRow(bool isTablet) {
    final control = widget.control;
    final frequencyField = CustomDropdown<String>(
      label: S.of(context).frequency,
      hint: S.of(context).chooseHere,
      items: ControlFrequency.allValues
          .map((d) => DropdownItem<String>(value: d, label: grcTr(context, d)))
          .toList(),
      value: control.frequency,
      onChanged: widget.onFrequencyChanged,
      fillColor: AppColors.background,
      labelStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      itemStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      required: false,
      height: _kSingleLineFieldHeight,
    );

    final weightField = _textField(
      label: S.of(context).controlWeight,
      hint: S.of(context).Texthere,
      controller: control.weightController,
      isMandatory: true,
      onlyDigits: true,
    );

    return GrcResponsiveFieldRow(
      mobileSpacing: 5.sp,
      isTablet: isTablet,
      children: [frequencyField, weightField],
    );
  }

  /// The Control Document upload columns. Two Expanded columns split the row
  /// 50/50 when Arabic is on; with only the ENG column left, an Expanded there
  /// would stretch it across the whole row instead of keeping that same
  /// half-width look, so a [FractionallySizedBox] is used instead.
  Widget _buildDocumentsRow(bool isTablet) {
    final control = widget.control;
    final en = _documentColumn(
      label: S.of(context).controlDocumentEng,
      document: control.documentEn,
      onRemove: widget.onRemoveDocumentEn,
      onUpload: widget.onUploadDocumentEn,
    );
    final ar = _documentColumn(
      label: S.of(context).controlDocumentAr,
      document: control.documentAr,
      onRemove: widget.onRemoveDocumentAr,
      onUpload: widget.onUploadDocumentAr,
    );

    // iPhone (375): every field in the control card is full width, the two
    // document slots included — a half-width upload button there is the
    // iPad layout leaking onto the phone.
    if (!isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: double.infinity, child: en),
          if (widget.isArabicEnabled) ...[
            SizedBox(height: 5.sp),
            SizedBox(width: double.infinity, child: ar),
          ],
        ],
      );
    }

    return widget.isArabicEnabled
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.w,
            children: [Expanded(child: en), Expanded(child: ar)],
          )
        : FractionallySizedBox(
            widthFactor: 0.5,
            alignment: AlignmentDirectional.centerStart,
            child: en,
          );
  }

  @override
  Widget build(BuildContext context) {
    final isArabicEnabled = widget.isArabicEnabled;
    // Width-based, matching the 375 / 768 / 1024 design ladder.
    final isTablet = screenSizeOf(context) != ScreenSize.mobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Control N" at the start, remove icon at the end.
          if (widget.index != null || widget.showRemoveButton) ...[
            Row(
              children: [
                if (widget.index != null)
                  Text(
                    '${S.of(context).control} '
                    '${LocalizedNumber.of(context, widget.index! + 1)}',
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.text),
                  ),
                const Spacer(),
                if (widget.showRemoveButton)
                  InkWell(
                    onTap: widget.onRemove,
                    child: CustomSvgImage(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/cancel_minus_circle.svg',
                      width: 15.sp,
                      fit: BoxFit.fill,
                      height: 15.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.sp),
          ],
          _buildNameRow(isTablet),
          SizedBox(height: 5.sp),
          if (isArabicEnabled) ...[
            _buildNumberRow(isTablet),
            SizedBox(height: 5.sp),
          ],
          _buildDescriptionFields(),
          SizedBox(height: 5.sp),
          _buildFrequencyWeightRow(isTablet),
          SizedBox(height: 5.sp),
          _buildDocumentsRow(isTablet),
        ],
      ),
    );
  }
}
