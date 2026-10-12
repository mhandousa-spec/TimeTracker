/// Module: knowledge_hub / presentation / s8_dashboard / dashboard_screen.dart
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_screen.dart
/// Purpose: Dashboard screen — Dashboard (S8) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/k8_dashboard/presentation/ui/widgets/monthly_comparison_knowledge_chart.dart';
import 'package:knowticed_plus/features/knowledge_hub/k8_dashboard/presentation/ui/widgets/approvals_downloads_chart.dart';
import 'package:knowticed_plus/features/knowledge_hub/k8_dashboard/presentation/ui/widgets/department_filter.dart';
import 'package:knowticed_plus/features/knowledge_hub/k8_dashboard/presentation/ui/widgets/knowledge_hub_resources.dart';
import 'package:knowticed_plus/features/knowledge_hub/k8_dashboard/presentation/ui/widgets/uploaded_documents_chart.dart';

import 'package:lottie/lottie.dart';



import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import '../../controller/dashboard_cubit.dart';
import '../../controller/dashboard_states.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';

/// Rewrite the ASCII digits in [value] as Arabic-Indic numerals (٠١٢…) when
/// [arabic] is true, so the dashboard's status counts and donut totals read in
/// Arabic figures under the Arabic locale.
String _localizeDigits(String value, bool arabic) {
  if (!arabic) return value;
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var out = value;
  for (var i = 0; i < western.length; i++) {
    out = out.replaceAll(western[i], eastern[i]);
  }
  return out;
}

class DashboardScreenKnow extends StatefulWidget {
  const DashboardScreenKnow({super.key});

  @override
  State<DashboardScreenKnow> createState() => _DashboardScreenKnowState();
}

class _DashboardScreenKnowState extends State<DashboardScreenKnow> {
  List<String> selectedDepartmentFilter = [];
  late MainCoreDepartmentCubit deptController;

  @override
  void initState() {
    super.initState();
    try {
      deptController = Get.find<MainCoreDepartmentCubit>();
    } catch (e) {
      deptController = Get.put(MainCoreDepartmentCubit());
    }

    // Fetch dashboard data on initialization
    context.read<DashboardCubit>().fetchDashboardData();
  }

  Color _getDepartmentColor(String departmentKey) {
    final colors = [
      KnowledgeHubColors.grey8d,
      KnowledgeHubColors.yellowBright,
      KnowledgeHubColors.gold,
      KnowledgeHubColors.neutralGrey,
      KnowledgeHubColors.slateBlueGrey,
      KnowledgeHubColors.slateBlueGrey,
      KnowledgeHubColors.slateBlueGrey,
      KnowledgeHubColors.slateBlueGrey,
    ];

    final index = departmentKey.hashCode.abs() % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          secondTitle: S.of(context)!.dashboard,
          onFirstTap: () => Navigator.pop(context),
          child: BlocBuilder<DashboardCubit, DashboardStates>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return Center(
                  child: CircleProgressMaster(),
                );
              }
        
              if (state is DashboardError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                      SizedBox(height: 16.h),
                      Text(
                        S.of(context)!.errorLoadingDashboard,
                        style: StyleText.fontSize18Weight500,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.error,
                        style: StyleText.fontSize14Weight400,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<DashboardCubit>().fetchDashboardData();
                        },
                        child: Text(S.of(context)!.retry),
                      ),
                    ],
                  ),
                );
              }
        
              if (state is DashboardEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_empty.json')],
                  ),
                );
              }
        
              if (state is DashboardLoaded) {
                // ✅ Apply department filter to ALL data
                final filteredState = context.read<DashboardCubit>().filterDashboardByDepartment(
                  state,
                  selectedDepartmentFilter,
                  deptController,
                );
        
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // ✅ Department Filter Dropdown
                      buildDepartmentFilterDropdown(
                        context: context,
                        departments: deptController.departmentModels,
                        onChanged: (value) {
                          setState(() {
                            selectedDepartmentFilter = value;
                          });
                        },
                        lightMode: lightMode,
                        selectedDepartments: selectedDepartmentFilter,
                      ),
        
                      SizedBox(height: 15.h),
        
                      // Status Cards Section (not filtered)
                      _buildStatusCards(
                        isMobile: isMobile,
                        lightMode: lightMode,
                        state: filteredState, // ✅ Use filtered state
                      ),
                      SizedBox(height: 15.h),
        
                      // Department Chart & Document Utilization (✅ FILTERED)
                      // Mirrors the services dashboard "Pie charts (Dept + Status)"
                      // layout (master_charts_section → DashboardChartsSection): two
                      // DonutChartCards that share the taller card's height via
                      // IntrinsicHeight + stretch on tablet/desktop (so neither
                      // overflows or floats), and stack in a Column on mobile.
                      // Replaces the old fixed-height Container(250.sp).
                      Builder(
                        builder: (context) {
                          final int departmentTotal = filteredState
                              .departmentCounts.values
                              .fold<int>(0, (sum, count) => sum + count);

                          final Widget departmentCard = DonutChartCard(
                            title: S.of(context).departments,
                            dotIcon:
                                'assets/icons_assets/main_icons_assets/svg_Case.svg',
                            centerValue: _localizeDigits(
                                departmentTotal.toString(), isArabic),
                            centerLabel: S.of(context)!.total,
                            sections: filteredState.departmentCounts.entries
                                .map((entry) {
                              return ChartData(
                                label: filteredState.departmentNames[entry.key] ??
                                    entry.key,
                                value: entry.value.toDouble(),
                                color: _getDepartmentColor(entry.key),
                              );
                            }).toList(),
                            chartSize: 130,
                          );

                          final Widget utilizationCard = DonutChartCard(
                            title: S.of(context).documentUtilization,
                            dotIcon:
                                'assets/icons_assets/main_icons_assets/assets_status.svg',
                            centerValue: _localizeDigits(
                                (filteredState.totalViews +
                                        filteredState.totalDownloads)
                                    .toString(),
                                isArabic),
                            centerLabel: S.of(context)!.total,
                            sections: [
                              ChartData(
                                label: S.of(context)!.views,
                                value: filteredState.totalViews.toDouble(),
                                color: KnowledgeHubColors.grey8d,
                              ),
                              ChartData(
                                label: S.of(context)!.downloads,
                                value: filteredState.totalDownloads.toDouble(),
                                color: KnowledgeHubColors.gold,
                              ),
                            ],
                            chartSize: 130,
                          );

                          if (isMobile) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                departmentCard,
                                SizedBox(height: 20.h),
                                utilizationCard,
                              ],
                            );
                          }

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: departmentCard),
                                SizedBox(width: 15.w),
                                Expanded(child: utilizationCard),
                              ],
                            ),
                          );
                        },
                      ),
        
                      SizedBox(height: 15.h),
        
                      // ✅ Uploaded Documents Chart (FILTERED)
                      uploadedDocumentsChart(
                        lightMode,
                        publishedData: filteredState.monthlyPublished,
                        removedData: filteredState.monthlyRemoved,
                      ),
                      SizedBox(height: 15.h),
        
                      // ✅ Downloads/Views Chart (FILTERED)
                      approvalsDownloadsChart(
                        lightMode,
                        downloadsData: filteredState.monthlyDownloads,
                        viewsData: filteredState.monthlyViews,
                      ),
                      SizedBox(height: 15.h),
        
                      // ✅ Knowledge Hub Resources (FILTERED)
                      knowledgeHubResources(
                        context,
                        lightMode: lightMode,
                        extensionData: filteredState.extensionCounts,
                      ),
                      SizedBox(height: 15.h),

                      MonthlyComparisonKnowledgeChart(
                        orientation: ChartOrientation.vertical,
                        lightMode: lightMode,
                        selectedDepartments: selectedDepartmentFilter, // ✅ Pass the filter
                      ),

                      SizedBox(height: 15.h),

                    ],
                  ),
                );
              }
        
              // Default/Initial state
              return Center(
                child: Text(
                  '${S.of(context)!.loadingDashboard}...',
                  style: StyleText.fontSize16Weight500,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCards({
    required bool isMobile,
    required bool lightMode,
    required DashboardLoaded state,
  })
  {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ Approved count
    final approvedCount = state.statusCounts['approved'] ?? 0;
    final pendingCount = state.statusCounts['pending_approval'] ?? 0;
    final rejectedCount = state.statusCounts['rejected'] ?? 0;
    final removedCount = state.statusCounts['removed'] ?? 0;

    return isMobile
        ? Container(
      decoration: BoxDecoration(
        color: lightMode ? AppColors.white : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(10.sp),
      child: Column(
        children: [
          buildStatusRow(
            title: S.of(context)!.approved,
            value: _localizeDigits(approvedCount.toString(), isArabic),
            lightMode: lightMode,
            icon: 'assets/icons_assets/main_icons_assets/status_approved_check_green.svg',
            color: AppColors.lightGreen,
          ),
          SizedBox(height: 14.h),
          buildStatusRow(
            title: S.of(context)!.pending,
            value: _localizeDigits(pendingCount.toString(), isArabic),
            lightMode: lightMode,
            icon: 'assets/icons_assets/main_icons_assets/state_icon_pending_icon.svg',
            color: KnowledgeHubColors.statusOrange,
          ),
          SizedBox(height: 14.h),
          buildStatusRow(
            title: S.of(context)!.rejected,
            value: _localizeDigits(rejectedCount.toString(), isArabic),
            lightMode: lightMode,
            icon: 'assets/icons_assets/main_icons_assets/state_icon_rejected_icon.svg',
            color: KnowledgeHubColors.redBright,
          ),
          SizedBox(height: 14.h),
          buildStatusRow(
            title: S.of(context)!.removed,
            value: _localizeDigits(removedCount.toString(), isArabic),
            lightMode: lightMode,
            icon: 'assets/icons_assets/knowledge_hub_assets/remove_icon.svg',
            color: KnowledgeHubColors.redDark,
          ),
        ],
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.all(10.sp),
            child: Column(
              children: [
                buildStatusRow(
                  title: S.of(context)!.approved,
                  value: _localizeDigits(approvedCount.toString(), isArabic),
                  lightMode: lightMode,
                  icon: 'assets/icons_assets/main_icons_assets/status_approved_check_green.svg',
                  color: KnowledgeHubColors.greenAccent,
                ),
                SizedBox(height: 14.h),
                buildStatusRow(
                  title: S.of(context)!.pending,
                  value: _localizeDigits(pendingCount.toString(), isArabic),
                  lightMode: lightMode,
                  icon: 'assets/icons_assets/main_icons_assets/state_icon_pending_icon.svg',
                  color: KnowledgeHubColors.statusOrange,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.all(10.sp),
            child: Column(
              children: [
                buildStatusRow(
                  title: S.of(context)!.rejected,
                  value: _localizeDigits(rejectedCount.toString(), isArabic),
                  lightMode: lightMode,
                  icon: 'assets/icons_assets/main_icons_assets/state_icon_rejected_icon.svg',
                  color: KnowledgeHubColors.redBright,
                ),
                SizedBox(height: 14.h),
                buildStatusRow(
                  title: S.of(context)!.removed,
                  value: _localizeDigits(removedCount.toString(), isArabic),
                  lightMode: lightMode,
                  icon: "assets/icons_assets/knowledge_hub_assets/remove_icon.svg",
                  color: KnowledgeHubColors.redDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatusRow({
    required String title,
    required String value,
    required bool lightMode,
    required String icon,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomSvgImage(
              assetPath: icon,
              height: 35.h,
              width: 35.w,
              fit: BoxFit.fill,
            ),
            SizedBox(width: 5.w),
            Text(
              title,
              style: StyleText.fontSize16Weight500.copyWith(
                color: lightMode ? AppColors.secondaryText : AppColors.grey,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: StyleText.fontSize22Weight600.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
      ],
    );
  }
}
