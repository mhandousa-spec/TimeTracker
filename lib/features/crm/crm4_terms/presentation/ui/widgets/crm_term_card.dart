// ****************** FILE INFO ******************
// File Name: crm_term_card.dart
// Purpose: Display card for CRM Terms matching Relationship card structure and UI
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_card_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTermCard extends StatelessWidget {
  final CrmTermModel term;
  final VoidCallback? onTap;

  const CrmTermCard({
    super.key,
    required this.term,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String title = isArabic ? term.nameAr : term.nameEn;
    final bool isActive = term.status.toLowerCase() == 'active';
    final String lastUpdate = term.audit != null
        ? DateFormat('d/M/yyyy').format(term.audit!.updatedAt)
        : '7/12/2026';
    final String creator = term.audit != null
        ? CrmCardHelper.resolveCreatorName(term.audit!.updatedBy,
            isArabic: isArabic)
        : (term.editorName.isNotEmpty ? term.editorName : 'Aya Ahmed');

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
                // Left: Icon rounded box
                Container(
                  width: 48.sp,
                  height: 48.sp,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  alignment: Alignment.center,
                  child: CustomSvgImage(
                    assetPath: AppAssets.crmTablerContract,
                    width: 24.sp,
                    height: 24.sp,
                    color: AppColors.secondaryBlack,
                  ),
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
                          title.isNotEmpty ? title : 'Terms',
                          style:
                              StyleText.fontSize16Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      // Meta Info Row
                      CrmCardHelper.buildCardMetaRow(
                        context: context,
                        countLabel: S.current.crmTermsCount,
                        countValue: '${term.termsCount}',
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
