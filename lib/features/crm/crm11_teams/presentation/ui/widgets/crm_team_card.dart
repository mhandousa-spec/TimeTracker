// ****************** FILE INFO ******************
// File Name: crm_team_card.dart
// Purpose: Extracted card widget for displaying CRM Team in grid view matching Figma UI using CrmCardInfoItem.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_card_info_row.dart';
import 'package:intl/intl.dart';

class CrmTeamCard extends StatelessWidget {
  final CrmTeamModel team;
  final VoidCallback onTap;

  const CrmTeamCard({
    super.key,
    required this.team,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('d MMM yyyy').format(team.createdAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. Left Icon Container
            Container(
              width: 58.sp,
              height: 58.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmGroup,
                width: 32.sp,
                height: 32.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 14.sp),

            // 2. Team Information and Metadata
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Header: Team Name & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          team.displayName,
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      _buildStatusBadge(),
                    ],
                  ),
                  SizedBox(height: 8.sp),

                  // Metadata Row 1: Types & Manager
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CrmCardInfoItem(
                          svgAsset: AppAssets.crmCategoryIcon,
                          label:
                              '${FormatHelper.localizedString(englishName: 'Types', arabicName: 'النوع')}:',
                          value: team.teamType,
                          iconSize: 14.sp,
                          fontSize: 12.sp,
                        ),
                      ),
                   
                      Expanded(
                        child: CrmCardInfoItem(
                          svgAsset: AppAssets.crmPerson,
                          label:
                              '${FormatHelper.localizedString(englishName: 'Manager', arabicName: 'المدير')}:',
                          value: team.manager?.name ?? '—',
                          iconSize: 14.sp,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.sp),

                  // Metadata Row 2: Members & Creation Date
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CrmCardInfoItem(
                          svgAsset: AppAssets.crmGroup,
                          label:
                              '${FormatHelper.localizedString(englishName: 'Members', arabicName: 'الأعضاء')}:',
                          value: team.membersCount.toString(),
                          iconSize: 14.sp,
                          fontSize: 12.sp,
                        ),
                      ), 
                     
                      Expanded(
                        child: CrmCardInfoItem(
                          svgAsset: AppAssets.calendar,
                          label:
                              '${FormatHelper.localizedString(englishName: 'Creation Date', arabicName: 'تاريخ الإنشاء')}:',
                          value: formattedDate,
                          iconSize: 14.sp,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool isActive = team.isActive;
    final Color badgeColor = isActive ? AppColors.green : AppColors.orange;
    final String label = isActive
        ? FormatHelper.localizedString(
            englishName: 'Active',
            arabicName: 'نشط',
          )
        : FormatHelper.localizedString(
            englishName: 'Inactive',
            arabicName: 'غير نشط',
          );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
