// ****************** FILE INFO ******************
// File Name: crm_relationship_card.dart
// Purpose: Display card for CRM Relationship Categories using shared CrmCardHelper
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_card_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmRelationshipCard extends StatelessWidget {
  final CrmRelationshipCategoryModel category;
  final VoidCallback? onTap;

  const CrmRelationshipCard({
    required this.category,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String title = isArabic ? category.nameAr : category.nameEn;
    final bool isActive = category.status.toLowerCase() == 'active';
    final String lastUpdate = category.audit != null
        ? DateFormat('d/M/yyyy').format(category.audit!.updatedAt)
        : '7/12/2026';
    final String creator = category.audit != null
        ? CrmCardHelper.resolveCreatorName(category.audit!.updatedBy,
            isArabic: isArabic)
        : 'Aya Ahmed';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(14.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Left: Icon rounded box / background image
                Container(
                  width: 48.sp,
                  height: 48.sp,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(8.sp),
                    image: category.iconUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(category.iconUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: category.iconUrl.isEmpty
                      ? CustomSvgImage(
                          assetPath: AppAssets.crmRelationship,
                          width: 24.sp,
                          height: 24.sp,
                          color: AppColors.secondaryBlack,
                        )
                      : null,
                ),
                SizedBox(width: 14.sp),

                // Middle: Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: isArabic ? 0 : 65.sp,
                          left: isArabic ? 65.sp : 0,
                        ),
                        child: Text(
                          title.isNotEmpty ? title : 'Organization',
                          style:
                              StyleText.fontSize16Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      // Row of sub-items using CrmCardHelper
                      CrmCardHelper.buildCardMetaRow(
                        context: context,
                        countLabel: S.current.crmTypesCount,
                        countValue: '${category.types.length}',
                        countIcon: AppAssets.crmSections,
                        creator: creator,
                        lastUpdate: lastUpdate,
                        isArabic: isArabic,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Positioned Status Chip
          CrmCardHelper.buildPositionedStatusChip(
            isActive: isActive,
            isArabic: isArabic,
          ),
        ],
      ),
    );
  }
}
