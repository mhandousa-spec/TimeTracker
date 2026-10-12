/// Module: services_management_module
/// Description: Admin Dashboard Details — thin UI shell (no business logic).
///              Constructs DashboardDetailsCubit with an explicit
///              CreateServicesRepository and delegates all data/section
///              rendering to child widgets.
/// Author: Amr Mesbah / Knowticed Team
/// Date: 2026-03-05
/// Dependencies: flutter_bloc, DashboardDetailsCubit, GetServiceRepositoryImpl
/// Revision History: 2026-03-05 (Amr Mesbah) — thin-shell refactor.
///                    2026-07-02 (Knowticed Team) — audit fix item 4:
///                    construct the repository explicitly at this call site
///                    now that DashboardDetailsCubit requires it.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/service_repository_impl.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_state.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/details_action_bar.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/details_pie_charts_section.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/details_tab_bar.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/details_table_section.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_admin_details_export_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/number_of_services.dart';

import 'package:knowticed_plus/generated/l10n.dart';


import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/info_text.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';


class AdminDashBoardDetailsTablet extends StatelessWidget {
  final String? header;
  final String? selectedServiceName;

  const AdminDashBoardDetailsTablet({
    super.key,
    this.header,
    this.selectedServiceName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardDetailsCubit(
        repository: GetServiceRepositoryImpl(firestore: FirebaseFirestore.instance),
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
      )..bootstrap(selectedServiceName: selectedServiceName ?? ''),
      child: _AdminDashBoardDetailsView(
        selectedServiceName: selectedServiceName,
      ),
    );
  }
}

// ─── View ──────────────────────────────────────────────────────────────────────

class _AdminDashBoardDetailsView extends StatefulWidget {
  final String? selectedServiceName;

  const _AdminDashBoardDetailsView({this.selectedServiceName});

  @override
  State<_AdminDashBoardDetailsView> createState() => _AdminDashBoardDetailsViewState();
}

class _AdminDashBoardDetailsViewState extends State<_AdminDashBoardDetailsView> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceRequestExportHelper _exportHelper = ServiceRequestExportHelper();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideInContent(from: SlideFrom.bottom, child: BlocBuilder<DashboardDetailsCubit, DashboardDetailsState>(
      builder: (context, state) {
        final cubit = context.read<DashboardDetailsCubit>();
        final locale = Localizations.localeOf(context).languageCode;

        if (state.bootstrapping || !state.bootstrapped) {
          return const Scaffold(body: Center(child: CircleProgressMaster()));
        }

        return Scaffold(
          body: SafeArea(
            child: SideFrameMasterServices(
              titleText: S.of(context).service,
              onFirstTap: () => Navigator.pop(context),
              // Bug report p.26: the breadcrumb reads "Admin Dashboard" in every
              // state (it said "Dashboard" while loading and on the details page).
              secondTitle: S.of(context).adminDashboard,
              onSecondTap: () => Navigator.pop(context),
              thirdTitle: _resolveDisplayName(state, locale),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Pie Charts ──────────────────────────────────────────
                    DetailsPieChartsSection(
                      state: state,
                      cubit: cubit,
                      locale: locale,
                    ),

                    SizedBox(height: 15.sp),

                    // ── Monthly Chart ───────────────────────────────────────
                    ServicesChartCard(
                      monthCounts: state.monthCounts,
                      monthHours: state.monthHours,
                      isLoading: state.isLoading,
                      onToggleToServiceCount: () => cubit.toggleChartMode(
                        true,
                        selectedServiceName: widget.selectedServiceName ?? '',
                      ),
                      onToggleToTotalHours: () => cubit.toggleChartMode(
                        false,
                        selectedServiceName: widget.selectedServiceName ?? '',
                      ),
                    ),

                    SizedBox(height: 20.sp),

                    // ── Tab Bar ─────────────────────────────────────────────
                    DetailsTabBar(
                      showRequestedServices: state.showRequestedServices,
                      onTabChanged: cubit.toggleTab,
                    ),

                    SizedBox(height: 12.sp),

                    // ── Search + Filter + Export ────────────────────────────
                    DetailsActionBar(
                      state: state,
                      searchController: _searchController,
                      onSearchChanged: cubit.onSearchChanged,
                      onFilterApplied: () {},
                      onFilterResult: ({
                        String? department,
                        String? status,
                        DateTime? date,
                        bool clearDepartment = false,
                        bool clearStatus = false,
                        bool clearDate = false,
                      }) {
                        cubit.applyFilters(
                          department: department,
                          status: status,
                          date: date,
                          clearDepartment: clearDepartment,
                          clearStatus: clearStatus,
                          clearDate: clearDate,
                        );
                      },
                      locale: locale,
                      exportHelper: _exportHelper,
                    ),

                    SizedBox(height: 14.sp),

                    // ── Table / Employee Cards ──────────────────────────────
                    DetailsTableSection(
                      state: state,
                      cubit: cubit,
                      locale: locale,
                    ),

                    SizedBox(height: 20.sp),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  String _resolveDisplayName(DashboardDetailsState state, String locale) {
    if (widget.selectedServiceName == null || widget.selectedServiceName!.isEmpty) {
      return '';
    }
    if (locale == 'ar' && state.serviceNamesArabic.isNotEmpty) {
      final index = state.serviceNames.indexOf(widget.selectedServiceName!);
      if (index >= 0 && index < state.serviceNamesArabic.length) {
        return state.serviceNamesArabic[index];
      }
    }
    return widget.selectedServiceName ?? '';
  }
}
