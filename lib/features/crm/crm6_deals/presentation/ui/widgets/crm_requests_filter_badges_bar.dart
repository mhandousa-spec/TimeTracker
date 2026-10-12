// ****************** FILE INFO ******************
// File Name: crm_requests_filter_badges_bar.dart
// Purpose: Status count filter tabs for Deal Requests using standard StatusChipFilter from 8-custom_filter_app.dart
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';

class CrmRequestsFilterBadgesBar extends StatelessWidget {
  final CrmRequestStatus selectedStatus;
  final ValueChanged<CrmRequestStatus> onStatusSelected;
  final int allCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectCount;

  const CrmRequestsFilterBadgesBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    this.allCount = 200,
    this.pendingCount = 20,
    this.approvedCount = 20,
    this.rejectCount = 20,
  });

  @override
  Widget build(BuildContext context) {
    final List<StatusChipItem> items = <StatusChipItem>[
      StatusChipItem(
        key: CrmRequestStatus.all.name,
        label: FormatHelper.localizedString(
          englishName: 'All',
          arabicName: 'الكل',
        ),
        count: allCount,
        labelColor: AppColors.text,
      ),
      StatusChipItem(
        key: CrmRequestStatus.pending.name,
        label: FormatHelper.localizedString(
          englishName: 'Pending',
          arabicName: 'معلق',
        ),
        count: pendingCount,
        labelColor: AppColors.orange,
      ),
      StatusChipItem(
        key: CrmRequestStatus.approved.name,
        label: FormatHelper.localizedString(
          englishName: 'Approved',
          arabicName: 'معتمد',
        ),
        count: approvedCount,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: CrmRequestStatus.reject.name,
        label: FormatHelper.localizedString(
          englishName: 'Reject',
          arabicName: 'مرفوض',
        ),
        count: rejectCount,
        labelColor: AppColors.red,
      ),
    ];

    return StatusChipFilter(
      items: items,
      selectedKey: selectedStatus.name,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.card,
      onSelected: (String key) {
        final CrmRequestStatus match = CrmRequestStatus.values.firstWhere(
          (CrmRequestStatus s) => s.name == key,
          orElse: () => CrmRequestStatus.all,
        );
        onStatusSelected(match);
      },
    );
  }
}
