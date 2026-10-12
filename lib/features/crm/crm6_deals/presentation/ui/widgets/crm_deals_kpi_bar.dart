// ****************** FILE INFO ******************
// File Name: crm_deals_kpi_bar.dart
// Purpose: Status chip filter tabs for Deals Controls (All, Active, Inactive)
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDealsKpiBar extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  const CrmDealsKpiBar({
    super.key,
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<StatusChipItem> items = <StatusChipItem>[
      StatusChipItem(
        key: 'All',
        label: S.current.crmAll,
        count: totalCount,
      ),
      StatusChipItem(
        key: 'Active',
        label: S.current.crmActive,
        count: activeCount,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: 'Inactive',
        label: S.current.crmInactive,
        count: inactiveCount,
        labelColor: AppColors.orange,
      ),
    ];

    return StatusChipFilter(
      selectedKey: selectedStatus,
      onSelected: onStatusSelected,
      items: items,
    );
  }
}
