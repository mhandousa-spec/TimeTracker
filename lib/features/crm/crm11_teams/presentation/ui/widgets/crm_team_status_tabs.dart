// ****************** FILE INFO ******************
// File Name: crm_team_status_tabs.dart
// Purpose: Status count filter tabs (All, Active, Inactive) for CRM Teams using StatusChipFilter.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class CrmTeamStatusTabs extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CrmTeamStatusTabs({
    super.key,
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final String selectedKey = selectedIndex == 1
        ? 'Active'
        : selectedIndex == 2
            ? 'Inactive'
            : 'All';

    final List<StatusChipItem> items = <StatusChipItem>[
      StatusChipItem(
        key: 'All',
        label: FormatHelper.localizedString(
          englishName: 'All',
          arabicName: 'الكل',
        ),
        count: totalCount,
      ),
      StatusChipItem(
        key: 'Active',
        label: FormatHelper.localizedString(
          englishName: 'Active',
          arabicName: 'نشط',
        ),
        count: activeCount,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: 'Inactive',
        label: FormatHelper.localizedString(
          englishName: 'Inactive',
          arabicName: 'غير نشط',
        ),
        count: inactiveCount,
        labelColor: AppColors.orange,
      ),
    ];

    return StatusChipFilter(
      selectedKey: selectedKey,
      onSelected: (String key) {
        if (key == 'Active') {
          onTabSelected(1);
        } else if (key == 'Inactive') {
          onTabSelected(2);
        } else {
          onTabSelected(0);
        }
      },
      items: items,
    );
  }
}
