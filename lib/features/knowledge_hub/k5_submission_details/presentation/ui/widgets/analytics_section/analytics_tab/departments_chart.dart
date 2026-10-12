/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/analytics_tab/departments_chart.dart
/// ************************* FILE INFO *************************** ///
/// File Name: departments_chart.dart
/// Purpose: Departments chart — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';

Widget buildDepartmentsChart(
    BuildContext context,
    bool lightMode, {
      required Map<String, int> departmentData,
      required int totalCount,
      Map<String, String>? enToArDepartments, // ✅ Can keep for backwards compatibility but won't use
    }) {
  // ✅ Get department controller and check language
  final departmentController = Get.find<MainCoreDepartmentCubit>();
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  // Dynamic color assignment based on available departments
  final defaultColors = KnowledgeHubColors.departmentChartPalette;

  // Assign colors dynamically to departments
  int colorIndex = 0;
  final departmentColors = <String, Color>{};
  for (var key in departmentData.keys) {
    departmentColors[key] = defaultColors[colorIndex % defaultColors.length];
    colorIndex++;
  }

  // ✅ Helper function to localize department name
  String _getLocalizedDepartmentName(String departmentName) {
    try {
      String? departmentId = departmentController.getDepartmentIdFromDepartmentName(
        departmentName: departmentName.toLowerCase(),
      );

      if (departmentId != null) {
        if (isArabic) {
          return departmentController.getArabicDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ?? departmentName;
        } else {
          return departmentController.getEnglishDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ?? departmentName;
        }
      }
    } catch (e) {
      debugPrint('Error localizing department: $e');
    }
    return departmentName;
  }

  // Prepare data for DonutChartCard.
  //
  // FIXED 22/9/2026 — the legend printed PERCENTAGES where the counts belong.
  // A card reading "Total 6" listed "Marketing 83 / Information Technology 16",
  // because `value` was set to `_getPercentage(...)` and [DonutChartCard]
  // prints `s.value` as the legend amount. The ring was right either way: it
  // derives each segment from `s.value / total`, which is the same proportion
  // whether the values are counts or percentages of those counts.
  //
  // So the RAW COUNT goes in: the ring is unchanged and the legend now agrees
  // with the centre total. The local `_getPercentage` helper went with it —
  // the ring still prints a percentage on each segment, but the card works
  // that out itself from the values it is given.
  final chartData = departmentData.entries.map((e) {
    final color = departmentColors[e.key] ?? AppColors.colorGreyDark!;
    final displayLabel = _getLocalizedDepartmentName(e.key); // ✅ Use localized name

    return ChartData(
      label: displayLabel,
      value: e.value.toDouble(),
      color: color,
    );
  }).toList();

  // Prepare value labels (counts)
  final valueLabels = departmentData.entries
      .map((e) => e.value.toString())
      .toList();

  return DonutChartCard(
           title: S.of(context).department,
           dotIcon: "assets/icons_assets/knowledge_hub_assets/departments_analytics_icon.svg",
           centerValue: totalCount.toString(),
           centerLabel: S.of(context).total,
           sections: chartData,
         );
}

// Helper function to format count (if needed elsewhere)
String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}
