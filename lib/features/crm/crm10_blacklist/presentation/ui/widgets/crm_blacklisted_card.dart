// ****************** FILE INFO ******************
// File Name: crm_blacklisted_card.dart
// Purpose: Grid card for blacklisted clients matching the Figma card design.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/data/models/crm_blacklist_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmBlacklistedCard extends StatelessWidget {
  final CrmBlacklistItemModel item;
  final bool showStatusBadge;
  final VoidCallback? onTap;

  const CrmBlacklistedCard({
    super.key,
    required this.item,
    this.showStatusBadge = false,
    this.onTap,
  });

  Color _typeColor(String type) {
    final String t = type.toLowerCase();
    if (t.contains('company')) return AppColors.green;
    if (t.contains('government')) return AppColors.yellow;
    if (t.contains('person') || t.contains('client')) return AppColors.blue;
    return AppColors.primary;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.orange;
      case 'approved':
        return AppColors.green;
      case 'rejected':
        return AppColors.red;
      case 'blocked':
      default:
        return AppColors.red;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FormatHelper.localizedString(
          englishName: 'Pending',
          arabicName: 'قيد الانتظار',
        );
      case 'approved':
        return FormatHelper.localizedString(
          englishName: 'Approved',
          arabicName: 'تمت الموافقة',
        );
      case 'rejected':
        return FormatHelper.localizedString(
          englishName: 'Rejected',
          arabicName: 'مرفوض',
        );
      case 'blocked':
      default:
        return FormatHelper.localizedString(
          englishName: 'Blocked',
          arabicName: 'محظور',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String typeLabel = FormatHelper.localizedString(
      englishName: 'Type',
      arabicName: 'النوع',
    );
    final String dateLabel = FormatHelper.localizedString(
      englishName: 'Date',
      arabicName: 'التاريخ',
    );
    final String reasonLabel = FormatHelper.localizedString(
      englishName: 'Reason',
      arabicName: 'السبب',
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. Avatar / Logo circle
            Container(
              width: 46.sp,
              height: 46.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greyDark,
                image: item.photoUrl != null && item.photoUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.photoUrl == null || item.photoUrl!.isEmpty
                  ? Center(
                      child: Text(
                        item.displayName.isNotEmpty
                            ? item.displayName[0].toUpperCase()
                            : 'C',
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10.sp),

            // 2. Info Columns
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Row 1: Client Name + Status Badge (if enabled)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.displayName,
                          style:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showStatusBadge) ...<Widget>[
                        SizedBox(width: 6.sp),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.sp,
                            vertical: 2.sp,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(item.status),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            _statusLabel(item.status),
                            style: StyleText.fontSize10Weight400.copyWith(color: AppColors.lightGrey)
                                .copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.sp),

                  // Row 2: Type & Date
                  Row(
                    children: <Widget>[
                      // Type
                      CustomSvgImage(
                        assetPath: AppAssets.crmGroup,
                        width: 12.sp,
                        height: 12.sp,
                        color: AppColors.darkGrey,
                      ),
                      SizedBox(width: 4.sp),
                      Text(
                        '$typeLabel: ',
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          item.clientType,
                          style:
                              StyleText.fontSize12Weight600.copyWith(
                            color: _typeColor(item.clientType),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 10.sp),

                      // Date
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11.sp,
                        color: AppColors.darkGrey,
                      ),
                      SizedBox(width: 3.sp),
                      Text(
                        '$dateLabel: ${item.date}',
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.darkGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 3.sp),

                  // Row 3: Reason
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.description_outlined,
                        size: 11.sp,
                        color: AppColors.darkGrey,
                      ),
                      SizedBox(width: 4.sp),
                      Expanded(
                        child: Text(
                          '$reasonLabel: ${item.reason}',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.darkGrey,
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
          ],
        ),
      ),
    );
  }
}
