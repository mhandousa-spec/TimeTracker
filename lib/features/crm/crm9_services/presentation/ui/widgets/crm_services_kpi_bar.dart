// ****************** FILE INFO ******************
// File Name: crm_services_kpi_bar.dart
// Purpose: Status chip filter tabs for Services module (All, Active, Inactive)
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmServicesKpiBar extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  const CrmServicesKpiBar({
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
