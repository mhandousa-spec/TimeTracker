// ******************* FILE INFO *******************
// File Name: first_section_pie_chart_with_labels
// Description: First section pie chart with labels.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardChartsSection extends StatelessWidget {
  final Map<String, int> departmentCounts;
  final Map<String, int> statusCounts;
  final Map<String, String> enToArDepartments;

  final bool isLoadingDepartments;
  final bool isLoadingStatus;

  final String departmentText;
  final String statusOfServicesText;
  final String doneText;
  final String approvedText;
  final String pendingText;
  final String inprogressText;
  final String breachedSLAText;
  final String rejectedText;
  final String canceledText;

  final Widget loadingWidget;
  final Widget Function(
      String headerImage,
      String title,
      String total,
      List<String> numberList,
      List<(String, Color, double)> data,
      ) pieChartBuilder;

  final Color? loadingBackgroundColor;
  final Map<String, Color>? departmentColors;
  final Map<String, Color>? statusColors;

  const DashboardChartsSection({
    Key? key,
    required this.departmentCounts,
    required this.statusCounts,
    required this.enToArDepartments,
    required this.isLoadingDepartments,
    required this.isLoadingStatus,
    required this.departmentText,
    required this.statusOfServicesText,
    required this.doneText,
    required this.approvedText,
    required this.pendingText,
    required this.inprogressText,
    required this.breachedSLAText,
    required this.rejectedText,
    required this.canceledText,
    required this.loadingWidget,
    required this.pieChartBuilder,
    this.loadingBackgroundColor,
    this.departmentColors,
    this.statusColors,
  }) : super(key: key);

  /// Normalize department counts (convert IDs to names)
  Map<String, int> _normalizeDepartmentCounts(
      BuildContext context, Map<String, int> rawCounts) {

    try {
      final departmentController = context.read<MainCoreDepartmentCubit>();
      final Map<String, int> normalizedCounts = {};

      rawCounts.forEach((key, value) {
        String normalizedKey = key;

        if (int.tryParse(key) != null) {
          final departmentName =
          departmentController.getEnglishDepartmentNameFromDepartmentId(
            departmentId: key,
          );
          if (departmentName != null && departmentName.isNotEmpty) {
            normalizedKey = departmentName;
          }
        }

        normalizedCounts[normalizedKey] =
            (normalizedCounts[normalizedKey] ?? 0) + value;
      });

      return normalizedCounts;
    } catch (e) {
      return rawCounts;
    }
  }

  /// ✅ NEW: Sort by count descending and take top 5
  Map<String, int> _getTop5Departments(Map<String, int> normalizedCounts) {
    final sorted = normalizedCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top5 = sorted.take(5).toList();

    return Map.fromEntries(top5);
  }

  double _getPercentage(Map<String, int> counts, String key) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final value = counts[key] ?? 0;
    return total == 0 ? 0.0 : (value / total) * 100.0;
  }

  Color _getDepartmentColor(String key) {
    if (departmentColors != null && departmentColors!.containsKey(key)) {
      return departmentColors![key]!;
    }
    return AppColors.grey!;
  }

  Map<String, Color> _getStatusColors() {
    return statusColors ??
        {
          'done': AppColors.lightGreen,
          'approved': AppColors.green,
          'pending': AppColors.pending,
          'inprogress': AppColors.secondaryPrimary,
          'branchsla': AppColors.red,
          'rejected': AppColors.block,
          'cancel':  AppColors.chartDarkRed,
        };
  }

  Widget _buildDepartmentChart(BuildContext context) {
    if (isLoadingDepartments) {
      return _buildLoadingContainer(context, isMobile: _isMobile(context));
    }

    final locale = Localizations.localeOf(context).languageCode;

    // Step 1: Normalize (IDs → names)
    final normalizedCounts = _normalizeDepartmentCounts(context, departmentCounts);

    // Step 2: ✅ Get top 5 sorted by count descending
    final top5Counts = _getTop5Departments(normalizedCounts);

    // Step 3: Total is from ALL departments (not just top 5)
    final totalAll =
    normalizedCounts.values.fold(0, (a, b) => a + b).toString();

    return pieChartBuilder(
      "assets/icons_assets/main_icons_assets/Case.svg",
      departmentText,
      totalAll,
      top5Counts.entries.map((e) => e.value.toString()).toList(),
      top5Counts.entries.map((e) {
        final color = _getDepartmentColor(e.key);
        // ✅ Percentage calculated relative to ALL departments total
        final total = normalizedCounts.values.fold<int>(0, (a, b) => a + b);
        final percent = total == 0 ? 0.0 : (e.value / total) * 100.0;
        final displayLabel =
        locale == 'ar' ? (enToArDepartments[e.key] ?? e.key) : e.key;

        return (displayLabel, color, percent);
      }).toList(),
    );
  }

  Widget _buildStatusChart(BuildContext context) {
    if (isLoadingStatus) {
      return _buildLoadingContainer(context, isMobile: _isMobile(context));
    }

    final colors = _getStatusColors();

    return pieChartBuilder(
      "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
      statusOfServicesText,
      statusCounts.values.fold(0, (a, b) => a + b).toString(),
      [
        statusCounts['done']?.toString() ?? '0',
        statusCounts['approved']?.toString() ?? '0',
        statusCounts['pending']?.toString() ?? '0',
        statusCounts['inprogress']?.toString() ?? '0',
        statusCounts['branchsla']?.toString() ?? '0',
        statusCounts['rejected']?.toString() ?? '0',
        statusCounts['cancel']?.toString() ?? '0',
      ],
      [
        (doneText, colors['done']!, _getPercentage(statusCounts, 'done')),
        (approvedText, colors['approved']!,
        _getPercentage(statusCounts, 'approved')),
        (pendingText, colors['pending']!,
        _getPercentage(statusCounts, 'pending')),
        (inprogressText, colors['inprogress']!,
        _getPercentage(statusCounts, 'inprogress')),
        (breachedSLAText, colors['branchsla']!,
        _getPercentage(statusCounts, 'branchsla')),
        (rejectedText, colors['rejected']!,
        _getPercentage(statusCounts, 'rejected')),
        (canceledText, colors['cancel']!,
        _getPercentage(statusCounts, 'cancel')),
      ],
    );
  }

  Widget _buildLoadingContainer(BuildContext context,
      {required bool isMobile}) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final bgColor = loadingBackgroundColor ??
        (lightMode
            ? AppColors.white
            : AppColors.chatBackground);

    return Container(
      width: isMobile ? 304.sp : MediaQuery.of(context).size.width * .4,
      height: isMobile ? 283.sp : 235.sp,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(child: loadingWidget),
    );
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          _buildDepartmentChart(context),
          SizedBox(height: 15.sp),
          _buildStatusChart(context),
        ],
      );
    } else {
      // ✅ FIX: both cards take the height of the taller one.
      //
      // A plain Row centres its children and lets each Expanded size to its own
      // content, so the card with fewer legend rows (Status Of Services has 7,
      // Department has 5) rendered shorter and floated in the middle. Wrapping
      // in IntrinsicHeight and stretching the cross axis gives both a single
      // shared height.
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildDepartmentChart(context)),
            SizedBox(width: 15.sp),
            Expanded(child: _buildStatusChart(context)),
          ],
        ),
      );
    }
  }
}