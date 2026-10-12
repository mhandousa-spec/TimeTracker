// ****************** FILE INFO ******************
// File Name: crm_blacklist_status_bar.dart
// Purpose: Status count chips bar for the Blacklist Requests tab matching templates client style.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CrmBlacklistStatusBar extends StatelessWidget {
  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final String selectedStatus; // 'all', 'pending', 'approved', 'rejected'
  final ValueChanged<String> onStatusSelected;

  const CrmBlacklistStatusBar({
    super.key,
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StatusChipFilter(
      selectedKey: selectedStatus,
      onSelected: onStatusSelected,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.card,
      items: <StatusChipItem>[
        StatusChipItem(
          key: 'all',
          count: totalCount,
          label: FormatHelper.localizedString(
            englishName: 'All',
            arabicName: 'الكل',
          ),
          labelColor: AppColors.text,
        ),
        StatusChipItem(
          key: 'pending',
          count: pendingCount,
          label: FormatHelper.localizedString(
            englishName: 'Pending',
            arabicName: 'قيد الانتظار',
          ),
          labelColor: AppColors.orange,
        ),
        StatusChipItem(
          key: 'approved',
          count: approvedCount,
          label: FormatHelper.localizedString(
            englishName: 'Approved',
            arabicName: 'تمت الموافقة',
          ),
          labelColor: AppColors.green,
        ),
        StatusChipItem(
          key: 'rejected',
          count: rejectedCount,
          label: FormatHelper.localizedString(
            englishName: 'Rejected',
            arabicName: 'مرفوض',
          ),
          labelColor: AppColors.red,
        ),
      ],
    );
  }
}
