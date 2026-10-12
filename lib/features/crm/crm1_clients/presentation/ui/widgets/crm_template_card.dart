// ****************** FILE INFO ******************
// File Name: crm_template_card.dart
// Purpose: Extracted template card widget matching Image 1 design specs
// Author: Mohand Adel
// Created At: 02/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:get/get.dart';

/// Card representing a single CRM template in the clients templates grid matching Image 1.
class CrmTemplateCard extends StatelessWidget {
  final CrmTemplateModel template;
  final CrmClientTypeModel? clientType;
  final int clientsCount;
  final VoidCallback? onTap;

  const CrmTemplateCard({
    super.key,
    required this.template,
    this.clientType,
    this.clientsCount = 0,
    this.onTap,
  });

  bool get _isArabic => Get.locale.toString().contains('ar');

  @override
  Widget build(BuildContext context) {
    final String lastUpdateDate =
        FormatHelper.formatDate(template.audit.updatedAt, _locale);
    final String creationDate =
        FormatHelper.formatDate(template.audit.createdAt, _locale);
    final String name = FormatHelper.localizedString(
      englishName: template.nameEn,
      arabicName: template.nameAr,
    );

    final String lastUpdateLabel = S.current.crmLastUpdate;
    final String dateLabel = S.current.crmCreationDateLabel;
    final String clientsLabel = S.current.crmClients;
    final String statusLabel = S.current.crmStatus;

    final String statusText = template.status.isNotEmpty
        ? template.status[0].toUpperCase() + template.status.substring(1)
        : 'Draft';
    final Color statusColor = template.status.toLowerCase() == 'active'
        ? AppColors.green
        : AppColors.orange;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          children: [
            // Left Icon Container (Image 1)
            Container(
              width: 54.sp,
              height: 54.sp,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmTemplate,
                width: 34.sp,
                height: 34.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 12.sp),

            // Right Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Temp Name',
                    style: StyleText.fontSize14Weight600.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Last Update & Creation Date
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              iconPath: AppAssets.calendar,
                              label: lastUpdateLabel,
                              value: lastUpdateDate,
                            ),
                            SizedBox(height: 4.sp),
                            _buildInfoRow(
                              iconPath: AppAssets.calendar,
                              label: dateLabel,
                              value: creationDate,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      // Right Column: Clients & Status
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              iconPath: AppAssets.crmPerson,
                              label: clientsLabel,
                              value: '$clientsCount',
                            ),
                            SizedBox(height: 4.sp),
                            _buildInfoRow(
                              iconPath: AppAssets.crmStatus,
                              label: statusLabel,
                              value: statusText,
                              valueColor: statusColor,
                            ),
                          ],
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

  Widget _buildInfoRow({
    required String iconPath,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomSvgImage(
          assetPath: iconPath,
          width: 12.sp,
          height: 12.sp,
          color: AppColors.black,
        ),
        SizedBox(width: 4.sp),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: StyleText.fontSize12Weight400.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
                    fontSize: 11.sp,
                    color: valueColor ?? AppColors.darkGrey,
                    fontWeight: valueColor != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String get _locale => _isArabic ? 'ar' : 'en';
}
