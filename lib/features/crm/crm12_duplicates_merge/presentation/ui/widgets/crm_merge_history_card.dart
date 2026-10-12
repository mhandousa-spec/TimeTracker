// ****************** FILE INFO ******************
// File Name: crm_merge_history_card.dart
// Purpose: History card displaying past merge audit record matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:intl/intl.dart';

class CrmMergeHistoryCard extends StatelessWidget {
  final CrmMergeHistoryModel history;
  final VoidCallback onTap;

  const CrmMergeHistoryCard({
    super.key,
    required this.history,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('d MMM yyyy, h:mm a').format(history.mergedAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Top Row: Client Name & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      CustomSvgImage(
                        assetPath: AppAssets.crmMerge,
                        width: 18.sp,
                        height: 18.sp,
                        color: AppColors.text,
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          '${history.masterClientName} ← ${history.mergedClientName}',
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.sp),
                _buildStatusBadge(),
              ],
            ),
            SizedBox(height: 10.sp),

            // Metadata Attributes
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildMetaItem(
                      label: FormatHelper.localizedString(
                        englishName: 'Merged By',
                        arabicName: 'تم الدمج بواسطة',
                      ),
                      value: history.mergedBy,
                    ),
                  ),
                  Expanded(
                    child: _buildMetaItem(
                      label: FormatHelper.localizedString(
                        englishName: 'Date & Time',
                        arabicName: 'التاريخ والوقت',
                      ),
                      value: formattedDate,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.sp),

            // Fields updated tags
            if (history.fieldsUpdated.isNotEmpty)
              Row(
                children: <Widget>[
                  Text(
                    '${FormatHelper.localizedString(englishName: 'Updated Fields', arabicName: 'الحقول المحدثة')}: ',
                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      history.fieldsUpdated.join(', '),
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool isRolledBack = history.isRolledBack;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: isRolledBack ? AppColors.orange : AppColors.green,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        isRolledBack
            ? FormatHelper.localizedString(
                englishName: 'Rolled Back',
                arabicName: 'تم التراجع',
              )
            : FormatHelper.localizedString(
                englishName: 'Merged',
                arabicName: 'مدمج',
              ),
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetaItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(height: 2.sp),
        Text(
          value,
          style: StyleText.fontSize12Weight400.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
