// ****************** FILE INFO ******************
// File Name: crm_add_quote_step1_details.dart
// Purpose: Step 1 Quote Details form for Add Quote wizard matching Figma screenshots 1 and 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmAddQuoteStep1Details extends StatelessWidget {
  final TextEditingController quoteNumberController;
  final TextEditingController quoteDateController;
  final TextEditingController quoteDateUntilController;
  final TextEditingController noteEnController;
  final TextEditingController noteArController;
  final VoidCallback onSelectQuoteDateUntil;
  final ValueChanged<String>? onChanged;

  const CrmAddQuoteStep1Details({
    super.key,
    required this.quoteNumberController,
    required this.quoteDateController,
    required this.quoteDateUntilController,
    required this.noteEnController,
    required this.noteArController,
    required this.onSelectQuoteDateUntil,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Quote Details',
        arabicName: 'تفاصيل عرض الأسعار',
      ),
      showHideToggle: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── 1. Quote Number (Half-width on large screens) ───────────────────
          buildResponsiveFields(
            context: context,
            left: _buildQuoteNumberField(),
            right: const SizedBox.shrink(),
          ),

          SizedBox(height: 16.sp),

          // ── 2. Quote Date & Quote Date Until ────────────────────────────────
          buildResponsiveFields(
            context: context,
            left: _buildQuoteDateField(),
            right: _buildQuoteDateUntilField(),
          ),

          SizedBox(height: 16.sp),

          // ── 3. Note (English) ───────────────────────────────────────────────
          _buildNoteEnField(),

          SizedBox(height: 16.sp),

          // ── 4. Note (Arabic) ───────────────────────────────────────────────
          _buildNoteArField(),
        ],
      ),
    );
  }

  Widget _buildQuoteNumberField() {
    return CustomTextField(
      label: FormatHelper.localizedString(
        englishName: 'Quote Number',
        arabicName: 'رقم عرض الأسعار',
      ),
      controller: quoteNumberController,
      hint: 'QT-15555',
      fillColor: AppColors.background,
      readOnly: false,
      onChanged: (String val) => onChanged?.call(val),
    );
  }

  Widget _buildQuoteDateField() {
    return CustomTextField(
      label: FormatHelper.localizedString(
        englishName: 'Quote Date',
        arabicName: 'تاريخ عرض الأسعار',
      ),
      controller: quoteDateController,
      hint: '7 Jun 2026',
      fillColor: AppColors.background,
      readOnly: true,
    );
  }

  Widget _buildQuoteDateUntilField() {
    return CustomTextField(
      label: FormatHelper.localizedString(
        englishName: 'Quote Date Until',
        arabicName: 'صالح حتى تاريخ',
      ),
      controller: quoteDateUntilController,
      hint: 'select',
      fillColor: AppColors.background,
      readOnly: true,
      onTap: onSelectQuoteDateUntil,
      suffixIcon: CustomSvgImage(
        assetPath: AppAssets.calendar,
        width: 18.sp,
        height: 18.sp,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildNoteEnField() {
    return CustomTextField(
      label: 'Note',
      controller: noteEnController,
      hint: 'Description',
      maxLines: 3,
      minLines: 3,
      fillColor: AppColors.background,
      maxLength: 500,
      showCharCount: true,
      onChanged: (String val) => onChanged?.call(val),
    );
  }

  Widget _buildNoteArField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'ملاحظة',
        controller: noteArController,
        hint: 'اكتب هنا',
        textAlign: TextAlign.right,
        maxLines: 3,
        minLines: 3,
        fillColor: AppColors.background,
        maxLength: 500,
        showCharCount: true,
        onChanged: (String val) => onChanged?.call(val),
      ),
    );
  }
}
