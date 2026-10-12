import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/results_permissions.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
class SwitchCardWidget extends StatelessWidget {
  const SwitchCardWidget({super.key});

  bool _hasUsersPermission() {
    return Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.formBuilder,
      section: FormPermissionsSections.resultsPermissions,
      permission: ResultsPermissions.users,
    );
  }

  bool _hasAnalyticsPermission() {
    return Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.formBuilder,
      section: FormPermissionsSections.resultsPermissions,
      permission: ResultsPermissions.analytics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUsersPermission = _hasUsersPermission();
    final hasAnalyticsPermission = _hasAnalyticsPermission();

    // If neither permission is available, don't show the widget
    if (!hasUsersPermission && !hasAnalyticsPermission) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        // Determine the current view based on permissions
        bool shouldShowUsers = state.isUser;

        // If user doesn't have permission for current view, switch to the allowed one
        if (state.isUser && !hasUsersPermission && hasAnalyticsPermission) {
          // If trying to show users but no permission, force analytics
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cubit.onChangeSwitch(false);
          });
          shouldShowUsers = false;
        } else if (!state.isUser && !hasAnalyticsPermission && hasUsersPermission) {
          // If trying to show analytics but no permission, force users
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cubit.onChangeSwitch(true);
          });
          shouldShowUsers = true;
        }

        // If only one permission is available, don't show the switch widget
        if (hasUsersPermission && !hasAnalyticsPermission) {
          return const SizedBox.shrink();
        }
        if (!hasUsersPermission && hasAnalyticsPermission) {
          return const SizedBox.shrink();
        }

        // Both permissions available, show the switch
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 41.h,
          decoration: ShapeDecoration(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => cubit.onChangeSwitch(true),
                child: buildChip('Users', shouldShowUsers),
              ),
              GestureDetector(
                onTap: () => cubit.onChangeSwitch(false),
                child: buildChip('Analytics', !shouldShowUsers),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildChip(String text, bool isSelected) {
    return Container(
      height: 27.h,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          text,
          style: StyleText.fontSize16Weight500.copyWith(
            color: isSelected ? AppColors.textButton : null,
          ),
        ),
      ),
    );
  }
}