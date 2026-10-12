// ****************** FILE INFO ******************
// File Name: crm_merge_group_details_header.dart
// Purpose: Group Details summary header with 4 metric cards matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:intl/intl.dart';

class CrmMergeGroupDetailsHeader extends StatelessWidget {
  final CrmDuplicatePairModel pair;

  const CrmMergeGroupDetailsHeader({
    super.key,
    required this.pair,
  });

  @override
  Widget build(BuildContext context) {
    final String dateA =
        DateFormat('MMM d, yyyy').format(pair.record1.createdAt);
    final String dateB =
        DateFormat('MMM d, yyyy').format(pair.record2.createdAt);
    final Color scoreColor = _getScoreColor(pair.matchScore);
    final String scoreLabel = _getScoreLabel(pair.matchScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Group Details',
            arabicName: 'تفاصيل المجموعة',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),

        // 4 Responsive Cards Row
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isNarrow = constraints.maxWidth < 800;

            if (isNarrow) {
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildRecordCard(
                          letter: 'A',
                          tag: 'Master',
                          tagColor: AppColors.primary,
                          tagTextColor: AppColors.text,
                          title: 'Record A',
                          subtitle: 'Created on $dateA',
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: _buildRecordCard(
                          letter: 'A',
                          tag: 'Duplicate',
                          tagColor: AppColors.grey,
                          tagTextColor: AppColors.darkGrey,
                          title: 'Record B',
                          subtitle: 'Created on $dateB',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.sp),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildScoreCard(
                          scoreColor: scoreColor,
                          scoreLabel: scoreLabel,
                          scoreValue: '${pair.matchScore}%',
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: _buildCountCard(
                          countText: '2 Records in this group',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: <Widget>[
                // Card 1: Record A
                Expanded(
                  child: _buildRecordCard(
                    letter: 'A',
                    tag: 'Master',
                    tagColor: AppColors.primary,
                    tagTextColor: AppColors.text,
                    title: 'Record A',
                    subtitle: 'Created on $dateA',
                  ),
                ),
                SizedBox(width: 12.sp),

                // Card 2: Record B
                Expanded(
                  child: _buildRecordCard(
                    letter: 'A',
                    tag: 'Duplicate',
                    tagColor: AppColors.grey,
                    tagTextColor: AppColors.darkGrey,
                    title: 'Record B',
                    subtitle: 'Created on $dateB',
                  ),
                ),
                SizedBox(width: 12.sp),

                // Card 3: Confidence Score
                Expanded(
                  child: _buildScoreCard(
                    scoreColor: scoreColor,
                    scoreLabel: scoreLabel,
                    scoreValue: '${pair.matchScore}%',
                  ),
                ),
                SizedBox(width: 12.sp),

                // Card 4: Records Count
                Expanded(
                  child: _buildCountCard(
                    countText: '2 Records in this group',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecordCard({
    required String letter,
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 72.sp,
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          // Avatar Letter
          Container(
            width: 36.sp,
            height: 36.sp,
            decoration: BoxDecoration(
              color: AppColors.darkGrey.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10.sp),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.sp, vertical: 1.5.sp),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        tag,
                        style:
                            StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                          fontSize: 9.sp,
                          color: tagTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.sp),
                Text(
                  title,
                  style: StyleText.fontSize12Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required Color scoreColor,
    required String scoreLabel,
    required String scoreValue,
  }) {
    return Container(
      height: 72.sp,
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CustomSvgImage(
                assetPath: AppAssets.crmConfidence,
                width: 20.sp,
                height: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.sp),
              Text(
                FormatHelper.localizedString(
                  englishName: 'Score',
                  arabicName: 'الدرجة',
                ),
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: scoreColor, width: 1.sp),
                ),
                child: Text(
                  scoreValue,
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 2.sp),
              Text(
                scoreLabel,
                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard({required String countText}) {
    return Container(
      height: 72.sp,
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CustomSvgImage(
                assetPath: AppAssets.crmRecord,
                width: 20.sp,
                height: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.sp),
              Text(
                FormatHelper.localizedString(
                  englishName: 'Records',
                  arabicName: 'السجلات',
                ),
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '2',
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.green;
    if (score >= 70) return AppColors.orange;
    return AppColors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) {
      return FormatHelper.localizedString(
        englishName: 'Very Likely',
        arabicName: 'مرجح جداً',
      );
    }
    if (score >= 70) {
      return FormatHelper.localizedString(
        englishName: 'Possible',
        arabicName: 'محتمل',
      );
    }
    return FormatHelper.localizedString(
      englishName: 'Unlikely',
      arabicName: 'غير مرجح',
    );
  }
}
