/// Module: knowledge_hub / presentation / s8_dashboard / widgets/approvals_document_utilizations.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_document_utilizations.dart
/// Purpose: Approvals document utilizations — Dashboard (S8) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

Widget approvalsDocumentUtilizationChart(
  BuildContext context,
  bool lightMode, {
  required int totalViews,
  required int totalDownloads,
}) {
  final total = totalViews + totalDownloads;

  // Calculate percentages
  final viewsPercent = total > 0 ? (totalViews / total) * 100 : 0.0;
  final downloadsPercent = total > 0 ? (totalDownloads / total) * 100 : 0.0;

  return DonutChartCard(
           title: "documentUtilization",
           dotIcon: "assets/icons_assets/main_icons_assets/assets_status.svg",
           centerValue: total.toString(),
           sections: [
      ChartData(label: S.of(context)!.views, color: Colors.yellow.shade700, value: viewsPercent),
      ChartData(label: S.of(context)!.downloads, color: AppColors.colorGrey, value: downloadsPercent),
    ],
         );
}
