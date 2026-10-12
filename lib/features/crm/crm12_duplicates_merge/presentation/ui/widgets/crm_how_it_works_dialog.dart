// ****************** FILE INFO ******************
// File Name: crm_how_it_works_dialog.dart
// Purpose: Informational dialog explaining duplicate detection and merge mechanics matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmHowItWorksDialog extends StatelessWidget {
  const CrmHowItWorksDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CrmHowItWorksDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      backgroundColor: AppColors.card,
      child: Container(
        width: 520.sp,
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CustomSvgImage(
                      assetPath: AppAssets.crmHowItWork,
                      width: 22.sp,
                      height: 22.sp,
                      color: AppColors.text,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      FormatHelper.localizedString(
                        englishName: 'How Duplicate & Merge Works',
                        arabicName: 'كيف تعمل ميزة مراجعة ودمج المكررات',
                      ),
                      style: StyleText.fontSize16Weight500.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 16.sp),

            // Step 1 Description
            _buildExplanationItem(
              number: '1',
              title: FormatHelper.localizedString(
                englishName: 'Automated Detection',
                arabicName: 'الرصد التلقائي',
              ),
              description: FormatHelper.localizedString(
                englishName:
                    'Our system analyzes client records across phone numbers, emails, and company names to compute confidence similarity scores.',
                arabicName:
                    'يقوم النظام بتحليل أرقام الهواتف والبريد الإلكتروني والأسماء لتحديد درجات التطابق والتشابه بدقة.',
              ),
            ),
            SizedBox(height: 12.sp),

            // Step 2 Description
            _buildExplanationItem(
              number: '2',
              title: FormatHelper.localizedString(
                englishName: 'Select Master & Fields',
                arabicName: 'اختيار السجل الرئيسي والحقول',
              ),
              description: FormatHelper.localizedString(
                englishName:
                    'You choose which record becomes the primary Master, and pick individual values (e.g. latest phone, preferred note) from either record.',
                arabicName:
                    'تحدد السجل الذي ترغب بأن يكون رئيسياً، وتختار القيم الفردية لكل حقل من أي من السجلين حسب رغبتك.',
              ),
            ),
            SizedBox(height: 12.sp),

            // Step 3 Description
            _buildExplanationItem(
              number: '3',
              title: FormatHelper.localizedString(
                englishName: 'Safe Merging & Audit History',
                arabicName: 'دمج آمن مع سجل تدقيق',
              ),
              description: FormatHelper.localizedString(
                englishName:
                    'All deals, activities, and communication history are seamlessly transferred to the Master record. Merges can be reviewed or rolled back anytime in History.',
                arabicName:
                    'يتم نقل كافة الصفقات والأنشطة وسجلات التواصل تلقائياً إلى السجل الرئيسي، مع إمكانية مراجعة العمليات والتراجع عنها من سجل الدمج.',
              ),
            ),
            SizedBox(height: 24.sp),

            // Close Button
            Align(
              alignment: Alignment.centerRight,
              child: customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Got It',
                  arabicName: 'فهمت ذلك',
                ),
                color: AppColors.primary,
                textColor: AppColors.text,
                function: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 28.sp,
            height: 28.sp,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: StyleText.fontSize12Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  description,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
