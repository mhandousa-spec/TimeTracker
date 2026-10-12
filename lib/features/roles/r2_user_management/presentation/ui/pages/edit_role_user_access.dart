/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_role_user_access.dart
/// Purpose: Declares `EditRoleUserAccess`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/68-confirm_dialog.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
// FRAME 8/9/2026: `pagination_app_bar.dart` replaced by the shared side frame.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/access_info.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/access_search_and_filter.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/person_state_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EditRoleUserAccess extends StatelessWidget {
  EditRoleUserAccess({super.key});

  late UserManagementAccessCubit controller;
  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();
    // REMOVED 8/9/2026: a local `isTablet` that only fed the page padding the
    // frame now owns.
    // FRAME 8/9/2026: header + horizontal padding come from
    // SideFrameMasterServices, replacing PaginationAppBar and this page's own
    // Padding. SideFrameBoundedBody bounds the grid's `Expanded` on the frame's
    // phone (scrolling) branch.
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => popFrameRoutes(context, 2),
          secondTitle: S.of(context).userAccessDetails,
          onSecondTap: () => popFrameRoutes(context, 1),
          thirdTitle: S.of(context).Editing,
          child: SideFrameBoundedBody(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccessInfo(),
              SizedBox(height: 20.sp),
              AccessSearchAndFilter(),
              SizedBox(height: 10.sp),
              BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
                builder: (context, state) {
                  List<UserPermissionEntity> userPermissions = [];
                  for (UserPermissionEntity permission
                      in controller.filteredEmployeeToGiveAccess) {
                    if (!controller.selectedUsersIdToChangeAccess
                        .contains(permission.employeeId)) {
                      userPermissions.add(permission);
                    }
                  }

                  return Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: CrossAxisCountHelper
                              .getCrossAxisCountForDefaultTablet2(context),
                          mainAxisExtent: 100.sp,
                          mainAxisSpacing: 10.sp,
                          crossAxisSpacing: 10.sp,
                        ),
                        itemCount: userPermissions.length,
                        itemBuilder: (context, index) {
                          return PersonStateView(
                              onTap: () {

                                ConfirmDialog().show(context,
                                    title: S.of(context).remove_access,
                                    subtitle:
                                    S.of(context).areYouSureYouWantToRemoveThisAccess,
                                    icon: 'assets/lottie_assets/roles_lottie_assets/delete.json',
                                    onCancel: () {}, onConfirm: () async {
                                      RoleLogService.log(RoleLogService.actionRevokeAccess);
                                      showLoadingIndicator();
                                      controller.selectUserToChangeAccess(
                                          userPermissions[index].employeeId);
                                      await controller.removeUserAccess(userPermissions[index]);
                                      hideLoadingIndicator();

                                    });
                              },
                              showAccessDates: true,
                              isEdit: true,
                              isSelected: controller
                                  .selectedUsersIdToChangeAccess
                                  .contains(userPermissions[index].employeeId),
                              person: userPermissions[index]);
                        }),
                  );
                },
              )
            ],
            ),
          ),
        ),
      ),
    );
  }
}
