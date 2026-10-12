// ******************* FILE INFO *******************
// File Name: dashboard_table_section.dart
// Description: Table section — delegates to RequestedServicesAndStatistics (tablet) or
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
//              RequestsListWidget (mobile). Zero logic here.
// Created by: Amr Mesbah
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/calc_state_method.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/request_statistics.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/requests_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardTableSection extends StatelessWidget {
  final String selectStatus;
  final String searchQuery;
  final List<String> activeDepartments;
  final List<String> activeStatuses;
  final DateTime? activeDate;

  // Mobile-only params
  final bool isMobile;
  final List<Map<String, dynamic>> displayedItems;
  final bool isLoadingRequests;

  const DashboardTableSection({
    super.key,
    required this.selectStatus,
    required this.searchQuery,
    required this.activeDepartments,
    required this.activeStatuses,
    required this.activeDate,
    this.isMobile = false,
    this.displayedItems = const [],
    this.isLoadingRequests = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return RequestsListWidget(
        isLoadingRequests: isLoadingRequests,
        displayedItems: displayedItems,
        stateTranslationsAr: _stateTranslationsAr,
        enToArDepartments: context.read<MainCoreDepartmentCubit>().enToAr,
        onItemTap: (_) {},
      );
    }

    return RequestedServicesAndStatistics(
      selectedDepartment: selectStatus,
      searchQuery: searchQuery,
      activeDepartments: activeDepartments,
      activeStatuses: activeStatuses,
      activeDate: activeDate,
    );
  }

  static const Map<String, String> _stateTranslationsAr = {
    'pending':      'قيد الانتظار',
    'done':         'مكتمل',
    'approved':     'موافق عليه',
    'rejected':     'مرفوض',
    'cancel':       'ملغي',
    'inprogress':   'قيد التنفيذ',
    'breached sla': 'تجاوز الوقت المحدد',
    'branchsla':    'تجاوز الوقت المحدد',
  };
}
