// ****************** FILE INFO ******************
// File Name: crm_dynamic_both_language_text_field.dart
// Purpose: Text input pair for fields configured to collect Arabic and English values.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Text input pair for fields configured to collect Arabic and English values.
class CrmDynamicBothLanguageTextField extends StatefulWidget {
  final CrmTemplateFieldModel field;
  final dynamic value;
  final String? englishError;
  final String? arabicError;
  final ValueChanged<dynamic> onChanged;

  const CrmDynamicBothLanguageTextField({
    super.key,
    required this.field,
    required this.value,
    required this.englishError,
    required this.arabicError,
    required this.onChanged,
  });

  @override
  State<CrmDynamicBothLanguageTextField> createState() =>
      _CrmDynamicBothLanguageTextFieldState();
}

class _CrmDynamicBothLanguageTextFieldState
    extends State<CrmDynamicBothLanguageTextField> {
  late final TextEditingController _englishController;
  late final TextEditingController _arabicController;

  bool get _isMultiline =>
      widget.field.fieldTypeId.toLowerCase() == 'description';

  TextStyle get _labelStyle => StyleText.fontSize14Weight400;
  TextStyle get _hintStyle => StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey);
  TextStyle get _errorStyle => StyleText.fontSize10Weight400.copyWith(
        color: AppColors.red,
      );

  String _textHint(BuildContext context) {
    return Get.locale.toString().contains('en')
        ? S.current.crmTextHere
        : S.current.crmWriteHere;
  }

  @override
  void initState() {
    super.initState();
    final Map<String, String> values = _readLanguageValues(widget.value);
    _englishController = TextEditingController(text: values['en'] ?? '');
    _arabicController = TextEditingController(text: values['ar'] ?? '');
  }

  @override
  void didUpdateWidget(covariant CrmDynamicBothLanguageTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Map<String, String> values = _readLanguageValues(widget.value);
    _syncController(_englishController, values['en'] ?? '');
    _syncController(_arabicController, values['ar'] ?? '');
  }

  @override
  void dispose() {
    _englishController.dispose();
    _arabicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildResponsiveFields(
      context: context,
      left: CustomTextField(
        controller: _englishController,
        label: widget.field.nameEn.isNotEmpty
            ? widget.field.nameEn
            : widget.field.nameAr,
        hint: _textHint(context),
        height: 36.sp,
        maxLines: _isMultiline ? 4 : 1,
        required: widget.field.isRequired,
        errorText: widget.englishError,
        keyboardType: TextInputType.text,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        onChanged: (_) => _emitValue(),
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.sp),
        labelStyle: _labelStyle,
        hintStyle: _hintStyle,
        errorStyle: _errorStyle,
      ),
      right: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomTextField(
          controller: _arabicController,
          label: widget.field.nameAr.isEmpty
              ? widget.field.nameEn
              : widget.field.nameAr,
          hint: S.current.crmWriteHere,
          height: 36.sp,
          maxLines: _isMultiline ? 4 : 1,
          required: widget.field.isRequired,
          errorText: widget.arabicError,
          keyboardType: TextInputType.text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: (_) => _emitValue(),
          fillColor: AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
          labelStyle: _labelStyle,
          hintStyle: _hintStyle,
          errorStyle: _errorStyle,
        ),
      ),
      mobileSpacing: 12.sp,
    );
  }

  void _emitValue() {
    widget.onChanged(
      <String, String>{
        'en': _englishController.text,
        'ar': _arabicController.text,
      },
    );
  }

  void _syncController(TextEditingController controller, String text) {
    if (controller.text == text) return;
    controller.text = text;
    controller.selection = TextSelection.collapsed(offset: text.length);
  }

  Map<String, String> _readLanguageValues(dynamic value) {
    if (value is Map) {
      return <String, String>{
        'en': (value['en'] ?? value['EN'] ?? value['Name_En'] ?? '').toString(),
        'ar': (value['ar'] ?? value['AR'] ?? value['Name_Ar'] ?? '').toString(),
      };
    }
    final String text = value?.toString() ?? '';
    if (text.startsWith('{') && text.endsWith('}')) {
      String en = '';
      String ar = '';
      final RegExp enReg = RegExp(r'en:\s*([^,}]+)');
      final RegExp arReg = RegExp(r'ar:\s*([^,}]+)');
      final matchEn = enReg.firstMatch(text);
      if (matchEn != null) en = matchEn.group(1)?.trim() ?? '';
      final matchAr = arReg.firstMatch(text);
      if (matchAr != null) ar = matchAr.group(1)?.trim() ?? '';
      if (en.isNotEmpty || ar.isNotEmpty) {
        return <String, String>{'en': en, 'ar': ar};
      }
    }
    return <String, String>{'en': text, 'ar': ''};
  }
}
