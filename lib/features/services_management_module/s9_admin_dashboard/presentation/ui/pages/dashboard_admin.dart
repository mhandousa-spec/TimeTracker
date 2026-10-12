// ******************* FILE INFO *******************
// File Name: dashboard_admin.dart
// Description: Main UI page for Admin Dashboard — thin view, delegates all logic to cubit
// Module: services_management_module / presentation / s9_admin_dashboard / ui / services_management_module
// Created by: Amr Mesbah
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';


import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_service_grid.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_charts_section.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_department_filter.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_status_cards.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_table_action_bar.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/pages/dashboard_mobile.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/pages/dashboard_details_admin_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_tab_bar.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';



class AdminDashBoardMasterTablet extends StatelessWidget {
  const AdminDashBoardMasterTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardAdminCubit(
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
      )..bootstrap(),
      child: const _AdminDashBoardView(),
    );
  }
}

class _AdminDashBoardView extends StatelessWidget {
  const _AdminDashBoardView();

  @override
  Widget build(BuildContext context) {
    return SlideInContent(from: SlideFrom.bottom, child: BlocBuilder<DashboardAdminCubit, DashboardAdminState>(
      builder: (context, state) {
        if (!state.bootstrapped) {
          return Scaffold(
            body: SideFrameMasterServices(
              titleText: S.of(context).services,
              onFirstTap: () => Navigator.pop(context),
              // Bug report p.26: the breadcrumb reads "Admin Dashboard" in every
              // state (it said "Dashboard" while loading and on the details page).
              secondTitle: S.of(context).adminDashboard,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(child: CircleProgressMaster()),
              ),
            ),
          );
        }

        final isMobile = ContextExtension(context).isPhone;
        final lightMode = Theme.of(context).brightness == Brightness.light;

        return Scaffold(
          body: SafeArea(
            child: SideFrameMasterServices(
              titleText: S.of(context).services,
              onFirstTap: () => navigateTo(context, LayoutScreenServices()),
              secondTitle: S.of(context).adminDashboard,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Department Filter ──────────────────────────────────────
                    DashboardDepartmentFilter(state: state),
                    SizedBox(height: 20.sp),
            
                    // ── Service Grid (filtered dept only) ──────────────────────
                    if (!state.isServiceListLoading &&
                        state.selectStatus != "All" &&
                        state.allServices.isNotEmpty)
                      DashboardServiceGrid(state: state),
            
                    if (state.selectStatus != "All") SizedBox(height: 32.sp),
            
                    // ── Status Cards ───────────────────────────────────────────
                    DashboardStatusCards(
                      statusCounts: state.statusCounts,
                      isMobile: isMobile,
                      lightMode: lightMode,
                    ),
            
                    SizedBox(height: 20.sp),
            
                    // ── Charts (All only) ──────────────────────────────────────
                    if (state.selectStatus == "All") ...[
                      DashboardChartsSection(state: state),
                      SizedBox(height: 20.sp),
                    ],
            
                    // ── Table / Stats (All) ────────────────────────────────────
                    if (state.selectStatus == "All") ...[
                      DashboardFilterableRequestsTable(
                        state: state,
                        isMobile: isMobile,
                      ),
                    ],
            
                    if (state.selectStatus != "All") SizedBox(height: 20.sp),
            
                    // ── Table / Stats (Filtered dept) ──────────────────────────
                    if (state.selectStatus != "All")
                      _buildFilteredDeptSection(context, state, isMobile, lightMode),
            
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  Widget _buildFilteredDeptSection(
      BuildContext context,
      DashboardAdminState state,
      bool isMobile,
      bool lightMode,
      ) {
    final cubit = context.read<DashboardAdminCubit>();

    return Column(
      children: [
        DashboardTabBar(
          showRequests: state.showRequests,
          onRequestsTap: () => cubit.toggleShowRequests(true),
          onStatisticsTap: () => cubit.toggleShowRequests(false),
        ),
        SizedBox(height: 20.sp),
        // The Statistics tab brings its own search/filter/export bar, so the
        // requests bar is only drawn on the Requests tab.
        if (state.showRequests)
          DashboardFilterableRequestsTable(
            state: state,
            isMobile: isMobile,
          )
        else
          DashBoardMasterMobile(
            isAdmin: true,
            adminSelectedDepartment: state.selectStatus,
          ),
      ],
    );
  }
}
