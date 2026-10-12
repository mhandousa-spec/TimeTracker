// ******************* FILE INFO *******************
// File Name: details_table_section.dart
// Description: Table (tablet) or Cards (mobile) for Dashboard Details
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/table.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_state.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/build_services_card.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DetailsTableSection extends StatelessWidget {
  final DashboardDetailsState state;
  final DashboardDetailsCubit cubit;
  final String locale;

  const DetailsTableSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    if (state.showRequestedServices) {
      if (isMobile) {
        return ServiceRequestMobileCard(
          displayedItems: state.displayedItems,
          locale: locale,
          enToArDepartments: state.enToArDepartments,
          onTap: (item) {},
        );
      }
      return ServiceRequestTableWidget(
        filteredItems: state.displayedItems,
        locale: locale,
        enToArDepartments: state.enToArDepartments,
        onRowTap: (item) {},
      );
    }

    return EmployeeStatsCard(
      filteredItems: state.filteredItems,
      locale: locale,
      enToArDepartments: state.enToArDepartments,
      getUniqueProviderEmails: cubit.getUniqueProviderNames,
      calculateProviderStats: cubit.calculateProviderStats,
    );
  }
}
