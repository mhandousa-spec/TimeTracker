// ****************** FILE INFO ******************
// File Name: crm_dynamic_field_builders.dart
// Purpose: Field-type builders mapping CrmTemplateFieldModel to core custom widgets
// Author: Mohand Adel
// Created At: 08/08/2026

import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_dynamic_address_field.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_dynamic_both_language_text_field.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';

/// Renders the matching core input widget for a single dynamic template field.
/// Value storage is keyed by [CrmTemplateFieldModel.id] through [onChanged].
Widget crmDynamicFieldBuilder({
  required BuildContext context,
  required CrmTemplateFieldModel field,
  required dynamic value,
  required String? error,
  String? englishError,
  String? arabicError,
  required Map<String, dynamic> formValues,
  required List<CrmTemplateFieldModel> allFields,
  required void Function(dynamic value) onChanged,
}) {
  final String type = field.fieldTypeId.toLowerCase();

  if (type == 'address') {
    return CrmDynamicAddressField(
      field: field,
      value: value,
      error: error,
      formValues: formValues,
      allFields: allFields,
      onChanged: onChanged,
    );
  }
  if (type == 'image') {
    return CrmDynamicImageField(
      field: field,
      value: value,
      error: error,
      onChanged: onChanged,
    );
  }
  if (type == 'dropdown' ||
      type == 'radio' ||
      type == 'company_size' ||
      type == 'sector' ||
      type == 'industry' ||
      type == 'preferred_language') {
    return CrmDynamicDropdownField(
      field: field,
      value: value is String ? value : null,
      error: error,
      onChanged: onChanged,
    );
  }
  if (type == 'multiselect' || type == 'tag') {
    return CrmDynamicMultiSelectField(
      field: field,
      value: value is List ? List<String>.from(value) : const <String>[],
      error: error,
      onChanged: onChanged,
    );
  }
  if (type == 'checkbox' || type == 'switch') {
    return CrmDynamicCheckboxField(
      field: field,
      value: value == true,
      error: error,
      onChanged: onChanged,
    );
  }
  if (type == 'date' || type == 'business_initiation_date' || type == 'time') {
    return CrmDynamicDateField(
      field: field,
      value: value?.toString(),
      error: error,
      onChanged: onChanged,
    );
  }
  if (type == 'attachment') {
    return CrmDynamicAttachmentField(
      field: field,
      value: value,
      error: error,
      onChanged: onChanged,
    );
  }
  if (type == 'digital_signature') {
    return CrmDynamicSignatureField(
      field: field,
      value: value?.toString(),
      error: error,
    );
  }

  // Default: plain text input (covers text, email, phone, link, website,
  // description, purchasing_value, and unknown types).
  if (_shouldShowBothLanguageInputs(field)) {
    return CrmDynamicBothLanguageTextField(
      field: field,
      value: value,
      englishError: englishError,
      arabicError: arabicError,
      onChanged: onChanged,
    );
  }
  return CrmDynamicTextField(
    field: field,
    value: value?.toString(),
    error: error,
    onChanged: (text) => onChanged(text),
  );
}

bool _shouldShowBothLanguageInputs(CrmTemplateFieldModel field) {
  if (!field.showBothLanguages) return false;
  final String type = field.fieldTypeId.toLowerCase();
  final String validationType = field.validationType.toLowerCase();
  if (_isEnglishOnlyTextType(type, validationType)) return false;
  return type == 'text' || type == 'description' || type.isEmpty;
}

/// Localized label for a dynamic field (Arabic label in Arabic locale).
String crmDynamicFieldLabel(CrmTemplateFieldModel field) {
  return FormatHelper.localizedString(
    englishName: field.nameEn,
    arabicName: field.nameAr,
  );
}

String _textHint(BuildContext context) {
  return Get.locale.toString().contains('en')
      ? S.current.crmTextHere
      : S.current.crmWriteHere;
}

String _chooseHint(BuildContext context) {
  return Get.locale.toString().contains('en')
      ? S.current.crmChoose
      : S.current.crmSelect;
}

TextStyle get _labelStyle => StyleText.fontSize14Weight400;

TextStyle get _hintStyle => StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey);

TextStyle get _errorStyle => StyleText.fontSize10Weight400.copyWith(
      color: AppColors.red,
    );

bool _isEnglishOnlyTextType(String type, String validationType) {
  return type == 'email' ||
      type == 'phone' ||
      type == 'link' ||
      type == 'website' ||
      validationType == 'email' ||
      validationType == 'phone' ||
      validationType == 'url';
}

/// Plain text input for `text`, `email`, `phone`, `link`, `website`,
/// `description` and `purchasing_value` field types.
class CrmDynamicTextField extends StatefulWidget {
  final CrmTemplateFieldModel field;
  final String? value;
  final String? error;
  final ValueChanged<String> onChanged;

  const CrmDynamicTextField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  @override
  State<CrmDynamicTextField> createState() => _CrmDynamicTextFieldState();
}

class _CrmDynamicTextFieldState extends State<CrmDynamicTextField> {
  late final TextEditingController _controller;

  bool get _isArabic => Get.locale.toString().contains('ar');

  TextInputType get _keyboardType {
    final String type = widget.field.fieldTypeId.toLowerCase();
    if (type == 'email') return TextInputType.emailAddress;
    if (type == 'phone') return TextInputType.phone;
    if (type == 'purchasing_value') return TextInputType.number;
    if (type == 'description') return TextInputType.multiline;
    return TextInputType.text;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant CrmDynamicTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String nextText = widget.value ?? '';
    if (_controller.text != nextText) {
      _controller.text = nextText;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String type = widget.field.fieldTypeId.toLowerCase();
    final bool isMultiline = type == 'description';
    final String validationType = widget.field.validationType.toLowerCase();

    final Widget field = CustomTextField(
      controller: _controller,
      label: crmDynamicFieldLabel(widget.field),
      hint: _textHint(context),
      height: 36.sp,
      maxLines: isMultiline ? 4 : 1,
      errorText: widget.error,
      required: widget.field.isRequired,
      keyboardType: _keyboardType,
      textDirection: _isArabic && !_isEnglishOnly(type, validationType)
          ? TextDirection.rtl
          : TextDirection.ltr,
      textAlign: _isArabic && !_isEnglishOnly(type, validationType)
          ? TextAlign.right
          : TextAlign.left,
      onChanged: widget.onChanged,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.sp),
      labelStyle: _labelStyle,
      hintStyle: _hintStyle,
      errorStyle: _errorStyle,
    );

    if (!_isArabic || _isEnglishOnly(type, validationType)) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
  }

  /// Email, phone, link and URL fields are always LTR regardless of locale.
  bool _isEnglishOnly(String type, String validationType) {
    return _isEnglishOnlyTextType(type, validationType);
  }
}

/// Single-select dropdown for `dropdown`, `radio`, `company_size`, `sector`,
/// `industry` and `preferred_language` field types.
class CrmDynamicDropdownField extends StatelessWidget {
  final CrmTemplateFieldModel field;
  final String? value;
  final String? error;
  final ValueChanged<dynamic> onChanged;
  final List<String>? optionsOverride;

  const CrmDynamicDropdownField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
    this.optionsOverride,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> options = optionsOverride ?? field.options;
    final List<DropdownItem<String>> items = options
        .map((option) => DropdownItem<String>(value: option, label: option))
        .toList();

    return CustomDropdown<String>(
      label: crmDynamicFieldLabel(field),
      hint: _chooseHint(context),
      value: value,
      items: items,
      required: field.isRequired,
      errorText: error,
      onChanged: (selected) => onChanged(selected),
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.sp),
      overlayElevation: 0,
      labelStyle: _labelStyle,
      hintStyle: _hintStyle,
      errorStyle: _errorStyle,
    );
  }
}

/// Multi-select dropdown for `multiselect` and `tag` field types.
class CrmDynamicMultiSelectField extends StatelessWidget {
  final CrmTemplateFieldModel field;
  final List<String> value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const CrmDynamicMultiSelectField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<MultiSelectDropdownItem<String>> items = field.options
        .map(
          (option) =>
              MultiSelectDropdownItem<String>(value: option, label: option),
        )
        .toList();

    return CustomMultiSelectDropdown<String>(
      label: crmDynamicFieldLabel(field),
      hint: _chooseHint(context),
      values: value,
      items: items,
      required: field.isRequired,
      errorText: error,
      onChanged: (selected) => onChanged(selected),
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.sp),
      overlayElevation: 0,
      labelStyle: _labelStyle,
      hintStyle: _hintStyle,
      errorStyle: _errorStyle,
    );
  }
}

/// Date/time picker for `date`, `business_initiation_date` and `time` field
/// types. The stored value is an ISO-8601 string.
class CrmDynamicDateField extends StatelessWidget {
  final CrmTemplateFieldModel field;
  final String? value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const CrmDynamicDateField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? current = DateTime.tryParse(value ?? '');
    final List<DateTime?>? selectedDates = await DatePicker().showDatePicker(
      context,
      <DateTime?>[current ?? DateTime.now()],
      current ?? DateTime.now(),
      CalendarDatePicker2Type.single,
    );
    final DateTime? selectedDate = selectedDates?.firstOrNull;
    if (selectedDate == null) return;
    onChanged(selectedDate.toIso8601String());
  }

  String get _displayText {
    if (value == null || value!.isEmpty) return '';
    return FormatHelper.formatDate(value, Get.locale.toString());
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: TextEditingController(text: _displayText),
      label: crmDynamicFieldLabel(field),
      hint: S.current.crmSelectDate,
      height: 36.sp,
      readOnly: true,
      required: field.isRequired,
      errorText: error,
      onTap: () => _pickDate(context),
      suffixIcon: CustomSvgImage(
        assetPath: AppAssets.calendar,
        width: 16.sp,
        height: 16.sp,
        color: AppColors.grey,
      ),
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.sp),
      labelStyle: _labelStyle,
      hintStyle: _hintStyle,
      errorStyle: _errorStyle,
    );
  }
}

/// Circular image picker for the `image` field type. The picked [File] is
/// stored in the form values and uploaded on submit.
class CrmDynamicImageField extends StatelessWidget {
  final CrmTemplateFieldModel field;
  final dynamic value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const CrmDynamicImageField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final File? imageFile = value is File ? value as File : null;
    final String? imageUrl = value is String ? value as String : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          crmDynamicFieldLabel(field),
          style: _labelStyle,
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: CustomImagePicker(
            imageFile: imageFile,
            imageUrl: imageUrl,
            onImagePicked: onChanged,
            radius: 28.sp,
            badgeRadius: 12.sp,
            placeholderSvg: AppAssets.defaultIcon,
            badgeSvg: AppAssets.camera,
          ),
        ),
        if (error != null && error!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(error!, style: _errorStyle),
        ],
      ],
    );
  }
}

/// Boolean checkbox/switch tile for `checkbox` and `switch` field types.
class CrmDynamicCheckboxField extends StatelessWidget {
  final CrmTemplateFieldModel field;
  final bool value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const CrmDynamicCheckboxField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: Row(
          children: [
            CustomCheckBox(size: 20.sp, isSelected: value),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                crmDynamicFieldLabel(field),
                style: StyleText.fontSize14Weight400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// File attachment tile for the `attachment` field type. The picked [File] is
/// stored in the form values and uploaded on submit.
class CrmDynamicAttachmentField extends StatelessWidget {
  final CrmTemplateFieldModel field;
  final dynamic value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const CrmDynamicAttachmentField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  Future<void> _pickAttachment(BuildContext context) async {
    final PickedFileData? picked = await MediaPickerService().pickDocument();
    if (picked == null) return;
    if (picked.path != null) {
      onChanged(File(picked.path!));
      return;
    }
    onChanged(picked.name);
  }

  String get _fileName {
    if (value is File) return (value as File).path.split('/').last;
    if (value is String && value!.isNotEmpty) return value as String;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickAttachment(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: Row(
          children: [
            CustomSvgImage(
              assetPath: AppAssets.upload,
              width: 18.sp,
              height: 18.sp,
              color: AppColors.black,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                _fileName.isEmpty ? crmDynamicFieldLabel(field) : _fileName,
                style: _fileName.isEmpty
                    ? _hintStyle
                    : StyleText.fontSize14Weight400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only placeholder for the `digital_signature` field type. Signature
/// drawing is out of scope for the initial dynamic engine; the field renders
/// as a disabled input so templates remain fully renderable.
class CrmDynamicSignatureField extends StatelessWidget {
  final CrmTemplateFieldModel field;
  final String? value;
  final String? error;

  const CrmDynamicSignatureField({
    super.key,
    required this.field,
    required this.value,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: TextEditingController(text: value ?? ''),
      label: crmDynamicFieldLabel(field),
      hint: _chooseHint(context),
      height: 36.sp,
      readOnly: true,
      errorText: error,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.sp),
      labelStyle: _labelStyle,
      hintStyle: _hintStyle,
      errorStyle: _errorStyle,
    );
  }
}
