// ******************* FILE INFO *******************
// File Name: dashboard_mobile.dart
// Description: Refactored DashBoard Master Mobile UI — uses Cubit + sub-widgets
// Created by: Amr Mesbah
// *************************************************
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';


import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/dashboard_master_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/master_action_bar.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/master_charts_section.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/master_tab_bar.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/master_table_section.dart';
import 'package:knowticed_plus/generated/l10n.dart';


import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class DashBoardMasterMobile extends StatefulWidget {
  final String? header;
  final bool? isAdmin;
  final String? adminSelectedDepartment;

  const DashBoardMasterMobile({
    super.key,
    this.header,
    this.isAdmin,
    this.adminSelectedDepartment,
  });

  @override
  State<DashBoardMasterMobile> createState() => _DashBoardMasterMobileState();
}

class _DashBoardMasterMobileState extends State<DashBoardMasterMobile> {
  late final DashboardMasterCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  bool get _isAdmin => widget.isAdmin == true;

  @override
  void initState() {
    super.initState();
    _cubit = DashboardMasterCubit(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
    );
    _bootstrap();
  }

  @override
  void didUpdateWidget(DashBoardMasterMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isAdmin &&
        widget.adminSelectedDepartment != oldWidget.adminSelectedDepartment) {
      _bootstrap();
    }
  }

  void _bootstrap() {
    _cubit.bootstrap(
      isAdmin: _isAdmin,
      adminSelectedDepartment: widget.adminSelectedDepartment,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  // ── Chart settings icon ────────────────────────────────────────────────────


  // ── Helpers forwarded from old widget ─────────────────────────────────────

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 &&
        MediaQuery.of(context).orientation == Orientation.landscape;
  }

  String _formatDate(dynamic rawDate, String locale) {
    try {
      if (rawDate == null) return '-';
      DateTime date;
      if (rawDate is Timestamp) {
        date = rawDate.toDate();
      } else if (rawDate is DateTime) {
        date = rawDate;
      } else if (rawDate is String) {
        date = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else {
        return '-';
      }
      final formatted = DateFormat('d MMM y', locale).format(date);
      final parts = formatted.split(' ');
      if (parts.length >= 2) {
        parts[1] = parts[1][0].toUpperCase() + parts[1].substring(1);
      }
      return parts.join(' ');
    } catch (_) {
      return '-';
    }
  }

  Color _getStatusColor(String status, BuildContext context) {
    final key = status.trim().toLowerCase().replaceAll('_', ' ');
    final map = <String, Color>{
      // Was AppColors.header — near-invisible on the dark table (bug report
      // p27). Green matches Done everywhere else in the module.
      'done': AppColors.green,
      'approved': AppColors.lightGreen,
      'inprogress': AppColors.yellow,
      'pending': AppColors.orange,
      'rejected': AppColors.red,
      'breached sla': AppColors.red,
      'cancel': AppColors.red,
      'canceled': AppColors.red,
      'cancelled': AppColors.red,
    };
    return map[key] ??
        (Theme.of(context).brightness == Brightness.light
            ? AppColors.mediumGrey
            : AppColors.lightGrey);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SlideInContent(from: SlideFrom.bottom, child: BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<DashboardMasterCubit, DashboardMasterState>(
        builder: (context, state) {
          if (!state.bootstrapped) return  CircleProgressMaster();

          return _isAdmin
              ? _buildAdminLayout(context, state)
              : _buildEmployeeLayout(context, state);
        },
      ),
    ));
  }

  // ── Admin layout ───────────────────────────────────────────────────────────

  Widget _buildAdminLayout(BuildContext context, DashboardMasterState state) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            MasterChartsSection(
              state: state,
              cubit: _cubit,
              isAdmin: true,
              adminSelectedDepartment: widget.adminSelectedDepartment,
              isArabic: isArabic,
            ),
            SizedBox(height: 20.sp),
          ],
        ),
      ),
    );
  }

  // ── Employee layout ────────────────────────────────────────────────────────

  Widget _buildEmployeeLayout(BuildContext context, DashboardMasterState state) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: SideFrameMasterServices(
        titleText: S.of(context).services,
        onFirstTap: () => navigateTo(context, LayoutScreenServices()),
        // Bug report p.26: the breadcrumb reads "Admin Dashboard" in every
        // state (it said "Dashboard" while loading and on the details page).
        secondTitle: S.of(context).adminDashboard,
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15.sp),

                // ── Charts ──────────────────────────────────────────────────
                MasterChartsSection(
                  state: state,
                  cubit: _cubit,
                  isAdmin: false,
                  adminSelectedDepartment: widget.adminSelectedDepartment,
                  isArabic: isArabic,
                ),

                SizedBox(height: 20.sp),

                // ── Tab bar ─────────────────────────────────────────────────
                MasterTabBar(
                  state: state,
                  onToggle: () => _cubit.toggleTab(!state.showRequestedServices),
                ),

                SizedBox(height: 12.sp),

                // ── Search / Filter / Export ────────────────────────────────
                MasterActionBar(
                  state: state,
                  cubit: _cubit,
                  searchController: _searchController,
                  locale: locale,
                  showExport: state.showRequestedServices,
                ),

                SizedBox(height: 14.sp),

                // ── Table / Cards / Employee cards ──────────────────────────
                MasterTableSection(
                  state: state,
                  cubit: _cubit,
                  locale: locale,
                  isTabletLandscape: _isTabletLandscape(context),
                  formatDate: _formatDate,
                  getStatusColor: _getStatusColor,
                ),

                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
