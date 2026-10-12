// ****************** FILE INFO ******************
// File Name: crm_client_card.dart
// Purpose: Extracted client record card widget for the CRM clients grid
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';

/// Grid card for a dynamic [CrmClientRecordModel]. Shows the primary display
/// value (name), secondary value (email/phone), creation date, and status.
class CrmClientCard extends StatelessWidget {
  final CrmClientRecordModel record;
  final CrmClientTypeModel? clientType;
  final VoidCallback? onTap;

  const CrmClientCard({
    super.key,
    required this.record,
    this.clientType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String? name = record.primaryDisplayValue;
    final String creationDate =
        FormatHelper.formatDate(record.audit.createdAt, _locale);

    final String clientId =
        (record.valueFor(null, 'id') ?? record.id).toString();
    final String phone = (record.valueFor(null, 'phone_number') ??
            record.valueFor(null, 'phone') ??
            '01148568444')
        .toString();
    final String email = (record.valueFor(null, 'email') ??
            record.valueFor(null, 'email_address') ??
            'Amrahmed@.com')
        .toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Client avatar container
            Container(
              width: 48.sp,
              height: 48.sp,
              decoration: BoxDecoration(
                color: AppColors.grey,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: clientType?.svgAsset ?? AppAssets.crmPerson,
                width: 26.sp,
                height: 26.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 12.sp),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Row: Client Name + Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name ?? S.current.crmAddNewClient,
                          style:
                              StyleText.fontSize14Weight600.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      _StatusBadge(status: record.status),
                    ],
                  ),
                  SizedBox(height: 6.sp),

                  // 2-Column Details (Screenshot 5)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: ID & Phone
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoItem(
                              iconPath: AppAssets.crmPerson,
                              label: 'ID',
                              value: clientId.length > 10
                                  ? clientId.substring(0, 10)
                                  : clientId,
                            ),
                            SizedBox(height: 4.sp),
                            _buildInfoItem(
                              iconPath: AppAssets.phone,
                              label: S.current.crmPhone,
                              value: phone,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      // Column 2: Business Date & Email
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoItem(
                              iconPath: AppAssets.calendar,
                              label: FormatHelper.localizedString(
                                englishName: 'Business Date',
                                arabicName: 'تاريخ العمل',
                              ),
                              value: creationDate,
                            ),
                            SizedBox(height: 4.sp),
                            _buildInfoItem(
                              iconPath: AppAssets.email,
                              label: S.current.crmEmail,
                              value: email,
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

  Widget _buildInfoItem({
    required String iconPath,
    required String label,
    required String value,
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
                    color: AppColors.darkGrey,
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

  String get _locale => Get.locale.toString().contains('ar') ? 'ar' : 'en';
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final String normalized = status.toLowerCase().trim();
    final Color color;
    final String label;

    switch (normalized) {
      case 'active':
        color = AppColors.green;
        label = S.current.crmActive;
        break;
      case 'inactive':
        color = AppColors.orange;
        label = S.current.crmInactive;
        break;
      case 'archived':
        color = AppColors.grey;
        label = S.current.crmArchived;
        break;
      case 'prospect':
        color = AppColors.blue;
        label = S.current.crmProspect;
        break;
      default:
        color = AppColors.green;
        label = status.isNotEmpty ? status : S.current.crmActive;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        label,
        style: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
