// ****************** FILE INFO ******************
// File Name: crm_duplicates_empty_state.dart
// Purpose: Responsive empty state widget with merge-empty-page.svg illustration matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class CrmDuplicatesEmptyState extends StatelessWidget {
  final bool isSearchEmpty;
  final bool isMergeHistory;

  const CrmDuplicatesEmptyState({
    super.key,
    this.isSearchEmpty = false,
    this.isMergeHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.sp, horizontal: 24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Empty State SVG Illustration from assets
            CustomSvgImage(
              assetPath: AppAssets.crmMergeEmptyPage,
              width: 220.sp,
              height: 180.sp,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.sp),

            // Title
            Text(
              isSearchEmpty
                  ? FormatHelper.localizedString(
                      englishName: 'No Results Found',
                      arabicName: 'لم يتم العثور على نتائج',
                    )
                  : isMergeHistory
                      ? FormatHelper.localizedString(
                          englishName: 'No Merge Records Found',
                          arabicName: 'لا توجد عمليات دمج',
                        )
                      : FormatHelper.localizedString(
                          englishName: 'No Duplicates Found',
                          arabicName: 'لا توجد سجلات مكررة',
                        ),
              style: StyleText.fontSize16Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.sp),

            // Subtitle
            SizedBox(
              width: 360.sp,
              child: Text(
                isSearchEmpty
                    ? FormatHelper.localizedString(
                        englishName:
                            'No duplicate pairs match your search query or active filter criteria. Try adjusting your search keywords.',
                        arabicName:
                            'لا توجد سجلات تطابق عبارة البحث أو الفلتر المختار. يرجى تجربة كلمات بحث أخرى.',
                      )
                    : isMergeHistory
                        ? FormatHelper.localizedString(
                            englishName:
                                'Completed merge operations will appear here.',
                            arabicName: 'ستظهر هنا عمليات الدمج المكتملة.',
                          )
                        : FormatHelper.localizedString(
                            englishName:
                                'Your client database is clean and organized! We will continuously monitor incoming records for potential duplicates.',
                            arabicName:
                                'قاعدة بيانات العملاء لديك نظيفة ومنظمة! سنستمر في المتابعة التلقائية لرصد أي سجلات مكررة محتملة.',
                          ),
                style: StyleText.fontSize14Weight600.copyWith(color: AppColors.darkGrey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
