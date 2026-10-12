// ****************** FILE INFO ******************
// File Name: crm_deal_activities_filter_badges_bar.dart
// Purpose: Status count filter tabs for Deal Activities using standard StatusChipFilter from 8-custom_filter_app.dart
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_activity_model.dart';

class CrmDealActivitiesFilterBadgesBar extends StatelessWidget {
  final CrmDealActivityStatus selectedStatus;
  final ValueChanged<CrmDealActivityStatus> onStatusSelected;
  final int allCount;
  final int scheduledCount;
  final int inProgressCount;
  final int completedCount;
  final int cancelledCount;

  const CrmDealActivitiesFilterBadgesBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    this.allCount = 200,
    this.scheduledCount = 20,
    this.inProgressCount = 20,
    this.completedCount = 20,
    this.cancelledCount = 20,
  });

  @override
  Widget build(BuildContext context) {
    final List<StatusChipItem> items = <StatusChipItem>[
      StatusChipItem(
        key: CrmDealActivityStatus.all.name,
        label: FormatHelper.localizedString(
          englishName: 'All',
          arabicName: 'الكل',
        ),
        count: allCount,
        labelColor: AppColors.text,
      ),
      StatusChipItem(
        key: CrmDealActivityStatus.scheduled.name,
        label: FormatHelper.localizedString(
          englishName: 'Scheduled',
          arabicName: 'مجدول',
        ),
        count: scheduledCount,
        labelColor: const Color(0xFF2563EB),
      ),
      StatusChipItem(
        key: CrmDealActivityStatus.inProgress.name,
        label: FormatHelper.localizedString(
          englishName: 'In Progress',
          arabicName: 'قيد التنفيذ',
        ),
        count: inProgressCount,
        labelColor: const Color(0xFFFF7A00),
      ),
      StatusChipItem(
        key: CrmDealActivityStatus.completed.name,
        label: FormatHelper.localizedString(
          englishName: 'Completed',
          arabicName: 'مكتمل',
        ),
        count: completedCount,
        labelColor: const Color(0xFF16A34A),
      ),
      StatusChipItem(
        key: CrmDealActivityStatus.cancelled.name,
        label: FormatHelper.localizedString(
          englishName: 'Cancelled',
          arabicName: 'ملغي',
        ),
        count: cancelledCount,
        labelColor: const Color(0xFF6B7280),
      ),
    ];

    return StatusChipFilter(
      items: items,
      selectedKey: selectedStatus.name,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.card,
      onSelected: (String key) {
        final CrmDealActivityStatus match =
            CrmDealActivityStatus.values.firstWhere(
          (CrmDealActivityStatus s) => s.name == key,
          orElse: () => CrmDealActivityStatus.all,
        );
        onStatusSelected(match);
      },
    );
  }
}
