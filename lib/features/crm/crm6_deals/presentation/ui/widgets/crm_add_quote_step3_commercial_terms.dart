// ****************** FILE INFO ******************
// File Name: crm_add_quote_step3_commercial_terms.dart
// Purpose: Step 3 Commercial Terms form for Add Quote wizard matching Figma screenshot 4
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmAddQuoteStep3CommercialTerms extends StatelessWidget {
  final String? selectedPaymentTerm;
  final String? selectedDeliveryTerm;
  final List<String> paymentTermOptions;
  final List<String> deliveryTermOptions;
  final ValueChanged<String?> onPaymentTermChanged;
  final ValueChanged<String?> onDeliveryTermChanged;
  final TextEditingController noteEnController;
  final TextEditingController noteArController;
  final List<String> uploadedFiles;
  final VoidCallback onUploadFile;
  final VoidCallback onAddFiles;
  final bool showValidationErrors;
  final ValueChanged<String>? onChanged;

  const CrmAddQuoteStep3CommercialTerms({
    super.key,
    required this.selectedPaymentTerm,
    required this.selectedDeliveryTerm,
    this.paymentTermOptions = const <String>[
      'Net 30 Days',
      'Net 60 Days',
      '50% Advance, 50% on Delivery',
      '100% Advance Payment',
    ],
    this.deliveryTermOptions = const <String>[
      'Standard Delivery (5-7 Days)',
      'Express Delivery (24-48 Hours)',
      'Immediate / Pickup',
      'FOB Shipping Point',
    ],
    required this.onPaymentTermChanged,
    required this.onDeliveryTermChanged,
    required this.noteEnController,
    required this.noteArController,
    this.uploadedFiles = const <String>[],
    required this.onUploadFile,
    required this.onAddFiles,
    this.showValidationErrors = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPaymentTermError = showValidationErrors &&
        (selectedPaymentTerm == null || selectedPaymentTerm!.isEmpty);
    final bool hasDeliveryTermError = showValidationErrors &&
        (selectedDeliveryTerm == null || selectedDeliveryTerm!.isEmpty);

    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Terms',
        arabicName: 'الشروط',
      ),
      showHideToggle: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── 1. Payment Terms & Delivery Terms Dropdowns ─────────────────────
          buildResponsiveFields(
            context: context,
            left: _buildPaymentTermsField(hasPaymentTermError),
            right: _buildDeliveryTermsField(hasDeliveryTermError),
          ),

          SizedBox(height: 16.sp),

          // ── 2. Note (English) ───────────────────────────────────────────────
          _buildNoteEnField(),

          SizedBox(height: 16.sp),

          // ── 3. Note (Arabic) ───────────────────────────────────────────────
          _buildNoteArField(),

          SizedBox(height: 20.sp),

          // ── 4. File Upload Section ──────────────────────────────────────────
          _buildFileUploadSection(context),
        ],
      ),
    );
  }

  Widget _buildPaymentTermsField(bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Payment Terms',
            arabicName: 'شروط الدفع',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomDropdown<String>(
          hint: FormatHelper.localizedString(
            englishName: 'Choose',
            arabicName: 'اختر',
          ),
          value: selectedPaymentTerm,
          items: paymentTermOptions
              .map((String opt) => DropdownItem<String>(value: opt, label: opt))
              .toList(),
          onChanged: onPaymentTermChanged,
          fillColor: AppColors.background,
          errorText: hasError
              ? FormatHelper.localizedString(
                  englishName: 'Field Required',
                  arabicName: 'هذا الحقل مطلوب',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildDeliveryTermsField(bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Delivery Terms',
            arabicName: 'شروط التسليم',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomDropdown<String>(
          hint: FormatHelper.localizedString(
            englishName: 'Choose',
            arabicName: 'اختر',
          ),
          value: selectedDeliveryTerm,
          items: deliveryTermOptions
              .map((String opt) => DropdownItem<String>(value: opt, label: opt))
              .toList(),
          onChanged: onDeliveryTermChanged,
          fillColor: AppColors.background,
          errorText: hasError
              ? FormatHelper.localizedString(
                  englishName: 'Field Required',
                  arabicName: 'هذا الحقل مطلوب',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildNoteEnField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Note',
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomTextField(
          controller: noteEnController,
          hint: 'Description',
          maxLines: 3,
          minLines: 3,
          fillColor: AppColors.background,
          onChanged: (String val) => onChanged?.call(val),
        ),
        SizedBox(height: 4.sp),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${noteEnController.text.length}/500',
            style: StyleText.fontSize12Weight400.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteArField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ملاحظة',
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(height: 6.sp),
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomTextField(
            controller: noteArController,
            hint: 'اكتب هنا',
            textAlign: TextAlign.right,
            maxLines: 3,
            minLines: 3,
            fillColor: AppColors.background,
            onChanged: (String val) => onChanged?.call(val),
          ),
        ),
        SizedBox(height: 4.sp),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${_toArabicDigits(noteArController.text.length)}/٥٠٠',
            style: StyleText.fontSize12Weight400.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'File',
            arabicName: 'الملف',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 10.sp),

        // Yellow Upload Bar Button
        SizedBox(
          width: double.infinity,
          child: customButtonWithSvg(
            title: FormatHelper.localizedString(
              englishName: 'Upload',
              arabicName: 'رفع ملف',
            ),
            image: AppAssets.download,
            widthImage: 16.sp,
            heightImage: 16.sp,
            color: AppColors.primary,
            colorBorder: Colors.transparent,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
            ),
            function: onUploadFile,
          ),
        ),

        SizedBox(height: 12.sp),

        // Dark + Add Files button
        customButton(
          title: FormatHelper.localizedString(
            englishName: '+ Add Files',
            arabicName: '+ إضافة ملفات',
          ),
          color: const Color(0xFF2D2D2D),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          function: onAddFiles,
        ),

        if (uploadedFiles.isNotEmpty) ...<Widget>[
          SizedBox(height: 12.sp),
          Wrap(
            spacing: 8.sp,
            runSpacing: 8.sp,
            children: uploadedFiles.map((String file) {
              return Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6.sp),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.insert_drive_file_outlined,
                        size: 16.sp, color: const Color(0xFF6B7280)),
                    SizedBox(width: 6.sp),
                    Text(
                      file,
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  static String _toArabicDigits(int number) {
    const Map<String, String> arabicDigits = <String, String>{
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return number
        .toString()
        .split('')
        .map((String e) => arabicDigits[e] ?? e)
        .join();
  }
}
