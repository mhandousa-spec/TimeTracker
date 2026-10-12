/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/analytics_tab/departments_bar_chart.dart
/// ************************* FILE INFO *************************** ///
/// File Name: departments_bar_chart.dart
/// Purpose: Departments bar chart — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildDepartmentsBarChart(
    BuildContext context,
    bool lightMode, {
      required Map<String, int> departmentData,
    }) {
  // ✅ Get department controller and check language
  final departmentController = Get.find<MainCoreDepartmentCubit>();
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  // ✅ Localize department names
  final localizedDepartments = departmentData.keys.map((department) {
    String localizedName = department;
    try {
      String? departmentId = departmentController.getDepartmentIdFromDepartmentName(
        departmentName: department.toLowerCase(),
      );

      if (departmentId != null) {
        if (isArabic) {
          localizedName = departmentController.getArabicDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ?? department;
        } else {
          localizedName = departmentController.getEnglishDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ?? department;
        }
      }
    } catch (e) {
      debugPrint('Error localizing department: $e');
    }
    return localizedName;
  }).toList();

  final values = departmentData.values.map((v) => v.toDouble()).toList();

  return Container(
    decoration: BoxDecoration(
        color: lightMode
            ? AppColors.white
            : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(8.r)
    ),
    // FIXED 12/9/2026 — "BOTTOM OVERFLOWED BY 77 PIXELS" on a phone.
    //
    // Two things fought here. `chartHeight: 280.h` below is scaled TWICE —
    // [BarChartCard.chartHeight] is documented as a raw design number and the
    // card applies `.h` itself — so the plot asked for ~325 rather than 280.
    // Add the card's header, its 12 gap and 16+16 padding and the content
    // wanted ~400 inside a box pinned to 300.h (~323). The difference is the 77.
    //
    // On a phone the box is now unpinned (the card is as tall as it needs to be
    // — the analytics tab scrolls) and the raw 280 is passed through once.
    //
    // CHANGED 22/9/2026 — desktop is unpinned too. 280.h of plot plus the
    // header and the card's own padding wants ~350, so pinning the box to
    // 300.h was asking the content to fit in less than it needs; the same
    // "fixed height cannot be right" argument that freed the phone applies
    // here. Unpinned, the card is exactly as tall as its content and the
    // analytics tab (a scrolling column) absorbs the difference.
    height: null,
    child: BarChartCard(
             title: S.of(context).departments,
             dotIcon: 'assets/icons_assets/knowledge_hub_assets/departments_chart_icon.svg',
             dotColor: AppColors.primary,
             bars: List.generate(
               localizedDepartments.length,
               (i) => ChartData(
                 label: localizedDepartments[i],
                 value: values[i],
               ),
             ),
             chartHeight: ContextExtension(context).isPhone ? 280 : 280.h,
             barWidth: 40,
             barColor: AppColors.primary,
           ),
  );
}
