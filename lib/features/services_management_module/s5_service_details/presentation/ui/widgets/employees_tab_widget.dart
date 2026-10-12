// ******************* FILE INFO *******************
// File Name: employees_tab_widget
// Description: Employees tab widget.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/calc_state_method.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/controller/details_services_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/controller/details_services_state.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/employee_card_mobile_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/employee_card_tablet_widget.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EmployeesTabWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ServicesHistoryModel createServicesModel;

  const EmployeesTabWidget({
    required this.searchController,
    required this.createServicesModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = DetailsServicesCubit.get(context);
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return BlocBuilder<DetailsServicesCubit, DetailsServicesState>(
      builder: (context, state) {
        final allEmployees = cubit.allEmployees;

        if (state is DetailsServicesLoading || allEmployees.isEmpty) {
          return _buildLoadingShimmer(context, isMobile, lightMode);
        }
        List<Map<String, dynamic>> rawStats = allEmployees
            .map((emp) => calculateStatsForEmployee(
          emp,
          context,
          cubit.filteredItems,
          parentDuration: createServicesModel.currentDurationOfServices,
          parentDurationUnit: createServicesModel.currentSelectedDurationUnit,
        ))
            .toList();

        final searchQuery = searchController.text.toLowerCase().trim();
        if (searchQuery.isNotEmpty) {
          rawStats = rawStats.where((emp) {
            final name = (emp['name'] ?? '').toLowerCase();
            final dept = (emp['department'] ?? '').toLowerCase();
            final title = (emp['title'] ?? '').toLowerCase();
            return name.contains(searchQuery) || dept.contains(searchQuery) || title.contains(searchQuery);
          }).toList();
        }

        final statsList = _sortEmployeeStats(rawStats);

        if (statsList.isEmpty) {
          return _buildEmptyState(context, isMobile, lightMode);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(statsList.length, (index) {
            final providerStats = statsList[index];

            return Padding(
              padding: EdgeInsets.only(bottom: 15.sp),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 10.sp),
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.chatBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: index == 0 && (int.tryParse(providerStats["done"]?.toString() ?? '0') ?? 0) > 0
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Stack(
                  children: [
                    if (index < 3 && (int.tryParse(providerStats["done"]?.toString() ?? '0') ?? 0) > 0) ...[

                    ],
                    isMobile
                        ? EmployeeCardMobileWidget(providerStats: providerStats)
                        : EmployeeCardTabletWidget(providerStats: providerStats),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  List<Map<String, dynamic>> _sortEmployeeStats(List<Map<String, dynamic>> stats) {
    final sortedStats = List<Map<String, dynamic>>.from(stats);

    sortedStats.sort((a, b) {
      final doneA = (a['done'] as int?) ?? 0;
      final doneB = (b['done'] as int?) ?? 0;

      if (doneA != doneB) {
        return doneB.compareTo(doneA);
      }

      final hoursA = (a['hours'] as double?) ?? 0.0;
      final hoursB = (b['hours'] as double?) ?? 0.0;

      if (hoursA != hoursB) {
        return hoursB.compareTo(hoursA);
      }

      final nameA = (a['name'] as String?) ?? '';
      final nameB = (b['name'] as String?) ?? '';

      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return sortedStats;
  }

  Widget _buildLoadingShimmer(BuildContext context, bool isMobile, bool lightMode) {
    return Column(
      children: List.generate(
        3,
            (index) => Padding(
          padding: EdgeInsets.only(bottom: 15.sp),
          child: Container(
            height: isMobile ? 120.sp : 80.sp,
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Shimmer.fromColors(
              baseColor: lightMode
                  ? AppColors.secondaryText.withOpacity(0.3)
                  : AppColors.grey.withOpacity(0.3),
              highlightColor: lightMode ? AppColors.background : AppColors.background.withOpacity(0.5),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: lightMode
                      ? AppColors.secondaryText.withOpacity(0.1)
                      : AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isMobile, bool lightMode) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: lightMode ? AppColors.white : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/icons_assets/main_icons_assets/image_placeholder_large.svg",
            width: 60.sp,
            height: 60.sp,
            color: lightMode ? AppColors.secondaryText : AppColors.grey,
          ),
          SizedBox(height: 10.sp),
          Text(
            "No employees match your search",
            style: StyleText.fontSize16Weight500.copyWith(
              color: lightMode ? AppColors.secondaryText : AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
