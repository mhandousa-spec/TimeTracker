// ****************** FILE INFO ******************
// File Name: crm_merge_select_duplicates_section.dart
// Purpose: Step 1 view displaying Group Details and Matching Criteria matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merge_group_details_header.dart';

class CrmMergeSelectDuplicatesSection extends StatelessWidget {
  final CrmDuplicatePairModel pair;

  const CrmMergeSelectDuplicatesSection({
    super.key,
    required this.pair,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 1. Group Details Metric Header
        CrmMergeGroupDetailsHeader(pair: pair),
        SizedBox(height: 20.sp),

        // 2. Matching Criteria Section
        Text(
          FormatHelper.localizedString(
            englishName: 'Matching Criteria',
            arabicName: 'معايير التطابق',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCriteriaRow(
                label: FormatHelper.localizedString(
                  englishName: 'Full Name',
                  arabicName: 'الاسم الكامل',
                ),
                value: pair.record1.name,
              ),
              SizedBox(height: 12.sp),
              _buildCriteriaRow(
                label: FormatHelper.localizedString(
                  englishName: 'Email',
                  arabicName: 'البريد الإلكتروني',
                ),
                value: pair.record1.email,
              ),
              SizedBox(height: 12.sp),
              _buildCriteriaRow(
                label: FormatHelper.localizedString(
                  englishName: 'Phone',
                  arabicName: 'رقم الهاتف',
                ),
                value: pair.record1.phone,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaRow({required String label, required String value}) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.check,
          color: AppColors.primary,
          size: 16.sp,
        ),
        SizedBox(width: 8.sp),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '$label: ',
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: StyleText.fontSize12Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
