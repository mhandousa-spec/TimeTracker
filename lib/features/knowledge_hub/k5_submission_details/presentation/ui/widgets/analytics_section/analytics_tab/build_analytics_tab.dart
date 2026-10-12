/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/analytics_tab/build_analytics_tab.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_analytics_tab.dart
/// Purpose: Build analytics tab — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as dev;

import 'package:knowticed_plus/generated/l10n.dart';
import '../../../../../../main_controller/helper/responsive_helper.dart';
import '../../../../controller/analytics_cubit.dart';
import '../../../../controller/analytics_states.dart';
import './departments_bar_chart.dart';
import './departments_chart.dart';
import './document_utilization_chart.dart';
import './downloads_chart.dart';

Widget buildAnalyticsTab(
    BuildContext context,
    bool lightMode,
    String knowledgeId,
    ) {
  final isMobile = ResponsiveHelper.isMobile(context);

  return BlocBuilder<AnalyticsCubit, AnalyticsStates>(
    builder: (context, state) {
      // ✅ Debug logging
      dev.log('=== Analytics Tab State ===', name: 'AnalyticsTab');
      dev.log('State type: ${state.runtimeType}', name: 'AnalyticsTab');

      // Show loading
      if (state is FetchingAnalyticsLoadingState) {
        dev.log('Status: LOADING', name: 'AnalyticsTab');
        return Center(child: CircleProgressMaster());
      }

      // Show error
      if (state is FetchingAnalyticsErrorState) {
        dev.log('Status: ERROR - ${state.error}', name: 'AnalyticsTab');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.red),
              SizedBox(height: 16),
              Text(S.of(context)!.errorLoadingAnalytics, style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                state.error,
                style: TextStyle(fontSize: 12, color: AppColors.colorGrey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // ✅ CHANGED: Show dashboard with zero data for both Empty and Success states
      if (state is FetchingAnalyticsEmptyState || state is FetchingAnalyticsSuccessState) {
        final cubit = context.read<AnalyticsCubit>();

        // Get data (will be empty maps/lists if no data exists)
        final topDepts = cubit.getTopDepartments(5);
        // CHANGED 28/9/2026 (Knowledge Hub bug report p.21 — "where all
        // month"): 6 → 12, so the chart runs a full year instead of stopping
        // at the last six months.
        final downloadsData = cubit.getLastNMonthsDownloads(12);
        final viewsData = cubit.getLastNMonthsViews(12);

        // Get totals (will be 0 if empty state)
        final totalDownloads = state is FetchingAnalyticsSuccessState ? state.totalDownloads : 0;
        final totalViews = state is FetchingAnalyticsSuccessState ? state.totalViews : 0;
        final totalActions = cubit.totalActions;

        // ✅ Debug logging
        dev.log('Status: ${state is FetchingAnalyticsEmptyState ? "EMPTY" : "SUCCESS"}', name: 'AnalyticsTab');
        dev.log('Total Downloads: $totalDownloads', name: 'AnalyticsTab');
        dev.log('Total Views: $totalViews', name: 'AnalyticsTab');
        dev.log('Total Actions: $totalActions', name: 'AnalyticsTab');
        dev.log('All Actions Count: ${cubit.allActions.length}', name: 'AnalyticsTab');
        dev.log('Department Data: $topDepts', name: 'AnalyticsTab');
        dev.log('Downloads Data (last 6 months): $downloadsData', name: 'AnalyticsTab');
        dev.log('Views Data (last 6 months): $viewsData', name: 'AnalyticsTab');

        return SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
           //   SizedBox(height: 15.h),

              // Top Row/Column - Departments and Document Utilization (responsive)
              isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDepartmentsChart(
                    context,
                    lightMode,
                    departmentData: topDepts,
                    totalCount: totalActions,
                    enToArDepartments: null,
                  ),
                  SizedBox(height: 15.h),
                  buildDocumentUtilizationChart(
                    context,
                    lightMode,
                    totalViews: totalViews,
                    totalDownloads: totalDownloads,
                  ),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: buildDepartmentsChart(
                      context,
                      lightMode,
                      departmentData: topDepts,
                      totalCount: totalActions,
                      enToArDepartments: null,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: buildDocumentUtilizationChart(
                      context,
                      lightMode,
                      totalViews: totalViews,
                      totalDownloads: totalDownloads,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15.h),

              // Number of Downloads/Views Chart
              buildDownloadsChart(
                lightMode,
                downloadsData: downloadsData,
                viewsData: viewsData,
              ),

              SizedBox(height: 15.h),

              // Departments Bar Chart
              buildDepartmentsBarChart(
                context,
                lightMode,
                departmentData: topDepts,
              ),
              SizedBox(height: 15.h),
            ],
          ),
        );
      }

      // Default state (Initial state)
      dev.log('Status: UNKNOWN/INITIAL - ${state.runtimeType}', name: 'AnalyticsTab');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleProgressMaster(),
            SizedBox(height: 16),
            Text('Loading analytics...'),
            SizedBox(height: 8),
            Text(
              'State: ${state.runtimeType}',
              style: TextStyle(fontSize: 12, color: AppColors.colorGrey),
            ),
          ],
        ),
      );
    },
  );
}