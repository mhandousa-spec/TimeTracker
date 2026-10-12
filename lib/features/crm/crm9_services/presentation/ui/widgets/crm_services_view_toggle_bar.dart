// ****************** FILE INFO ******************
// File Name: crm_services_view_toggle_bar.dart
// Purpose: View mode switchers (Table / Grid) and Export action bar for Services module using shared CrmViewModeToggleBar.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_view_mode_toggle_bar.dart';

class CrmServicesViewToggleBar extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onViewModeChanged;
  final VoidCallback onExportTap;

  const CrmServicesViewToggleBar({
    super.key,
    required this.isGridView,
    required this.onViewModeChanged,
    required this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    return CrmViewModeToggleBar(
      isGridView: isGridView,
      onViewModeChanged: onViewModeChanged,
      showExport: true,
      onExport: onExportTap,
      unselectedColor: AppColors.card,
    );
  }
}
