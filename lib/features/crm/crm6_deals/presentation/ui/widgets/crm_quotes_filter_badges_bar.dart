// ****************** FILE INFO ******************
// File Name: crm_quotes_filter_badges_bar.dart
// Purpose: Status count filter tabs for Deal Quotes using standard StatusChipFilter matching other features
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';

class CrmQuotesFilterBadgesBar extends StatelessWidget {
  final CrmQuoteStatus selectedStatus;
  final ValueChanged<CrmQuoteStatus> onStatusSelected;
  final int allCount;
  final int pendingCount;
  final int approvedCount;
  final int adjustmentCount;
  final int rejectCount;
  final int expiredCount;

  const CrmQuotesFilterBadgesBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    this.allCount = 200,
    this.pendingCount = 20,
    this.approvedCount = 20,
    this.adjustmentCount = 20,
    this.rejectCount = 20,
    this.expiredCount = 20,
  });

  @override
  Widget build(BuildContext context) {
    final List<StatusChipItem> items = <StatusChipItem>[
      StatusChipItem(
        key: CrmQuoteStatus.all.name,
        label: FormatHelper.localizedString(
          englishName: 'All',
          arabicName: 'الكل',
        ),
        count: allCount,
        labelColor: AppColors.text,
      ),
      StatusChipItem(
        key: CrmQuoteStatus.pending.name,
        label: FormatHelper.localizedString(
          englishName: 'Pending',
          arabicName: 'معلق',
        ),
        count: pendingCount,
        labelColor: AppColors.orange,
      ),
      StatusChipItem(
        key: CrmQuoteStatus.approved.name,
        label: FormatHelper.localizedString(
          englishName: 'Approved',
          arabicName: 'معتمد',
        ),
        count: approvedCount,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: CrmQuoteStatus.adjustment.name,
        label: FormatHelper.localizedString(
          englishName: 'Adjustment',
          arabicName: 'تعديل',
        ),
        count: adjustmentCount,
        labelColor: const Color(0xFF2563EB),
      ),
      StatusChipItem(
        key: CrmQuoteStatus.reject.name,
        label: FormatHelper.localizedString(
          englishName: 'Reject',
          arabicName: 'مرفوض',
        ),
        count: rejectCount,
        labelColor: AppColors.red,
      ),
      StatusChipItem(
        key: CrmQuoteStatus.expired.name,
        label: FormatHelper.localizedString(
          englishName: 'Expired',
          arabicName: 'منتهي',
        ),
        count: expiredCount,
        labelColor: AppColors.darkGrey,
      ),
    ];

    return StatusChipFilter(
      items: items,
      selectedKey: selectedStatus.name,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.card,
      onSelected: (String key) {
        final CrmQuoteStatus match = CrmQuoteStatus.values.firstWhere(
          (CrmQuoteStatus s) => s.name == key,
          orElse: () => CrmQuoteStatus.all,
        );
        onStatusSelected(match);
      },
    );
  }
}
