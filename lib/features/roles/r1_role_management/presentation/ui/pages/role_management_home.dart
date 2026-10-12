/// Module: roles / r1_role_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: role_management_home.dart
/// Purpose: Declares `PlatFormRoleContainer`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/role_overview.dart';
import 'package:flutter/services.dart';

import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/export_role_widget.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/grid_table_export.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/platform_roles_header.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/roles_filter_row.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/table_widget.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class PlatFormRoleContainer extends StatefulWidget {
  const PlatFormRoleContainer.RoleManagementHome({super.key});

  @override
  State<PlatFormRoleContainer> createState() => _PlatFormRoleContainerState();
}

class _PlatFormRoleContainerState extends State<PlatFormRoleContainer> {
  bool isGridView = true; // Default to grid view

  @override
  void initState() {
    super.initState();

    // CLEAR SEARCH WHEN PAGE LOADS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleCubit>().searchController.clear();
      context.read<RoleCubit>().getUnDeletedRoles(); // CHANGED: Call getUnDeletedRoles instead of filterRoles
      RoleLogService.log(RoleLogService.pageRoleManagementHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = AppControllers.haptic;
    RoleCubit controller = context.read<RoleCubit>();

    return BlocBuilder<RoleCubit, RoleState>(
        buildWhen: (previous, current) =>
        current is RoleLoading ||        // ADD THIS
            current is RoleStatusSelected ||
            current is RoleFetched ||
            current is RoleFiltered ||
            current is RoleError,            // ADD THIS
        builder: (context, state) {

          // ADD THIS LOADING CHECK
          if (state is RoleLoading) {
            return Column(
              spacing: 15.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlatformRolesHeader(),
                Row(
                  children: [
                    RolesFilterRow(),
                    Spacer(),
                    ViewToggleButtons(
                      isGridView: isGridView,
                      onTableViewTap: () {
                        setState(() {
                          isGridView = false;
                        });
                      },
                      onGridViewTap: () {
                        setState(() {
                          isGridView = true;
                        });
                      },
                      showExport: true,
                      onExportTap: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.heavyImpact,
                            hapticFeedback: HapticFeedback.heavyImpact
                        );

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => RoleExportDialog(
                            roles: controller.filteredRoles,
                          ),
                        );
                      },
                    )
                  ],
                ),
                Expanded(
                  child: CircleProgressMaster(),
                )
              ],
            );
          }

          return Column(
            spacing: 15.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlatformRolesHeader(),
              Row(
                children: [
                  RolesFilterRow(),
                  Spacer(),
                  ViewToggleButtons(
                    isGridView: isGridView,
                    onTableViewTap: () {
                      setState(() {
                        isGridView = false;
                      });
                    },
                    onGridViewTap: () {
                      setState(() {
                        isGridView = true;
                      });
                    },
                    showExport: true,
                    onExportTap: () {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.heavyImpact,
                          hapticFeedback: HapticFeedback.heavyImpact
                      );

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => RoleExportDialog(
                          roles: controller.filteredRoles,
                        ),
                      );
                    },
                  )
                ],
              ),
              Expanded(
                child: controller.filteredRoles.isEmpty
                    ? LayoutBuilder(
                  builder: (context, constraints) {
                    // FIXED 8/9/2026: the animation was pinned to 400.sp square
                    // with BoxFit.fill. Whatever height Expanded had left after
                    // the header, filter row and any active search chips, this
                    // asked for 400.sp anyway — "A RenderFlex overflowed by 53
                    // pixels on the bottom". It now takes the smaller of 400.sp
                    // and the space actually available, so it shrinks instead
                    // of overflowing.
                    final double size = [
                      400.sp,
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ].reduce((a, b) => a < b ? a : b);

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/lottie_assets/notification_lottie_assets/empty.json',
                            width: size,
                            height: size,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : isGridView
                    ? _buildGridView(controller.filteredRoles)
                    : _buildTableView(controller.filteredRoles),
              )
            ],
          );
        });
  }

  Widget _buildGridView(List<RoleHistoryModel> roles) {
    return SingleChildScrollView(
      child: Column(
        spacing: 10.sp,
        children: [
          for (RoleHistoryModel role in roles) RoleOverview(role: role)
        ],
      ),
    );
  }

  Widget _buildTableView(List<RoleHistoryModel> roles) {
    return SingleChildScrollView(
      child: RoleTableView(
        roles: roles,
        locale: context.languageCode,
      ),
    );
  }
}