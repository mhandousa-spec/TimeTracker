// ****************** FILE INFO ******************
// File Name: crm_quote_overview_section.dart
// Purpose: Shared Overview section widget for Quote Details (view and edit mode)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

/// Displays Quote Number, Dates, and bilingual Notes in view or edit mode.
///
/// When [isReadOnly] is true the fields are locked; the Edit button appears
/// when [onEditTap] is provided.
/// When [isReadOnly] is false the fields become editable; [onDateUntilTap]
/// is wired to the date-picker for Quote Date Until.
class CrmQuoteOverviewSection extends StatelessWidget {
  final TextEditingController quoteNumberCtrl;
  final TextEditingController quoteDateCtrl;
  final TextEditingController quoteDateUntilCtrl;
  final TextEditingController noteEnCtrl;
  final TextEditingController noteArCtrl;
  final bool isReadOnly;
  final VoidCallback? onDateUntilTap;
  final VoidCallback? onEditTap;

  const CrmQuoteOverviewSection({
    super.key,
    required this.quoteNumberCtrl,
    required this.quoteDateCtrl,
    required this.quoteDateUntilCtrl,
    required this.noteEnCtrl,
    required this.noteArCtrl,
    this.isReadOnly = true,
    this.onDateUntilTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Quote Details',
        arabicName: 'تفاصيل عرض الأسعار',
      ),
      showHideToggle: false,
      trailing:
          (isReadOnly && onEditTap != null) ? _buildEditButton(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Quote Number — half-width per Single-Field Rule
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              label: FormatHelper.localizedString(
                englishName: 'Quote Number',
                arabicName: 'رقم عرض الأسعار',
              ),
              controller: quoteNumberCtrl,
              fillColor: AppColors.background,
              readOnly: isReadOnly,
            ),
            right: const SizedBox.shrink(),
          ),

          SizedBox(height: 14.sp),

          // Date pair
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              label: FormatHelper.localizedString(
                englishName: 'Quote Date',
                arabicName: 'تاريخ عرض الأسعار',
              ),
              controller: quoteDateCtrl,
              fillColor: AppColors.background,
              readOnly: true,
            ),
            right: CustomTextField(
              label: FormatHelper.localizedString(
                englishName: 'Quote Date Until',
                arabicName: 'صالح حتى تاريخ',
              ),
              controller: quoteDateUntilCtrl,
              hint: 'select',
              fillColor: AppColors.background,
              readOnly: true,
              onTap: isReadOnly ? null : onDateUntilTap,
              suffixIcon: isReadOnly
                  ? null
                  : Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: const Color(0xFF6B7280),
                    ),
            ),
          ),

          SizedBox(height: 14.sp),

          // Note EN
          CustomTextField(
            label: 'Note',
            controller: noteEnCtrl,
            hint: 'Description',
            fillColor: AppColors.background,
            readOnly: isReadOnly,
            maxLines: 3,
            minLines: 3,
            maxLength: isReadOnly ? null : 500,
            showCharCount: !isReadOnly,
          ),

          SizedBox(height: 14.sp),

          // Note AR
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              label: 'ملاحظة',
              controller: noteArCtrl,
              hint: 'اكتب هنا',
              fillColor: AppColors.background,
              readOnly: isReadOnly,
              maxLines: 3,
              minLines: 3,
              maxLength: isReadOnly ? null : 500,
              showCharCount: !isReadOnly,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return customButtonWithSvg(
      title: FormatHelper.localizedString(
        englishName: 'Edit',
        arabicName: 'تعديل',
      ),
      image: AppAssets.edit,
      widthImage: 14.sp,
      heightImage: 14.sp,
      colorBorder: Colors.transparent,
      color: AppColors.primary,
      textStyle: StyleText.fontSize14Weight500.copyWith(
        fontWeight: FontWeight.bold,
      ),
      function: onEditTap!,
    );
  }
}
