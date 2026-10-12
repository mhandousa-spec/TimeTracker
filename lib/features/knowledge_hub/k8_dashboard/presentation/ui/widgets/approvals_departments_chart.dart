/// Module: knowledge_hub / presentation / s8_dashboard / widgets/approvals_departments_chart.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_departments_chart.dart
/// Purpose: Approvals departments chart — Dashboard (S8) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

Widget approvalsDepartmentsChart(
  BuildContext context,
  bool lightMode, {
  required Map<String, int> departmentData,
  required int totalCount,
  required Map<String, String>? enToArDepartments,
}) {
  // Dynamic color assignment based on available departments
  final defaultColors = [
    KnowledgeHubColors.goldBright,
    KnowledgeHubColors.sand,
    KnowledgeHubColors.yellowBright,
    KnowledgeHubColors.olive,
    KnowledgeHubColors.gold,
    KnowledgeHubColors.khakiGrey,
    KnowledgeHubColors.grey8d,
    KnowledgeHubColors.greyCaca,
    KnowledgeHubColors.brownMauve,
    KnowledgeHubColors.brown,
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
    Colors.teal.shade300,
  ];

  // Calculate percentages
  double _getPercentage(Map<String, int> data, String key) {
    final total = data.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return 0;
    return (data[key]! / total) * 100;
  }

  // Get locale for language-specific labels
  final locale = Localizations.localeOf(context).languageCode;

  // Assign colors dynamically to departments
  int colorIndex = 0;
  final departmentColors = <String, Color>{};
  for (var key in departmentData.keys) {
    departmentColors[key] = defaultColors[colorIndex % defaultColors.length];
    colorIndex++;
  }

  return DonutChartCard(
           title: S.of(context).department,
           dotIcon: "assets/icons_assets/knowledge_hub_assets/departments_analytics_icon.svg",
           centerValue: totalCount.toString(),
           sections: departmentData.entries.map((e) {
      final color = departmentColors[e.key] ?? AppColors.colorGreyDark!;
      final percent = _getPercentage(departmentData, e.key);
      final displayLabel = locale == 'ar'
          ? (enToArDepartments?[e.key] ?? e.key)
          : e.key;
      return ChartData(label: displayLabel, color: color, value: percent);
    }).toList(),
         );
}
