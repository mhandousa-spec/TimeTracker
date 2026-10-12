/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/analytics_tab/document_utilization_chart.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_utilization_chart.dart
/// Purpose: Document utilization chart — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';

Widget buildDocumentUtilizationChart(
    BuildContext context,
    bool lightMode, {
      required int totalViews,
      required int totalDownloads,
    }) {
  final total = totalViews + totalDownloads;

  // Prepare data for DonutChartCard.
  //
  // FIXED 22/9/2026 — counts, not percentages. The legend here showed
  // "Views 33 / Downloads 66" beside a centre total of 6, because
  // [DonutChartCard] prints `ChartData.value` as the legend amount and this
  // passed the percentage. The ring is identical either way (it divides each
  // value by their sum), so only the legend changes. See the fuller note in
  // departments_chart.dart.
  final chartData = [
    ChartData(
      label: S.of(context).views,
      value: totalViews.toDouble(),
      color: KnowledgeHubColors.chartYellow,
    ),
    ChartData(
      label: S.of(context).downloads,
      value: totalDownloads.toDouble(),
      color: AppColors.colorGrey,
    ),
  ];

  // Prepare value labels (counts)
  final valueLabels = [
    totalViews.toString(),
    totalDownloads.toString(),
  ];

  return DonutChartCard(
           title: S.of(context).document_utilization,
           dotIcon: "assets/icons_assets/main_icons_assets/assets_status.svg",
           centerValue: total.toString(),
           centerLabel: S.of(context).total,
           sections: chartData,
         );
}
