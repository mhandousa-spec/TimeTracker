/// Module: roles / r1_role_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: role_details_page.dart
/// Purpose: Declares `RoleDetailsPage`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// FRAME 8/9/2026: `pagination_app_bar.dart` replaced by the shared side frame,
// so this page wears the same breadcrumb as the rest of the roles module.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/adding_new_role.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/role_management_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/module_permissions_widget.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/modules_granted.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/role_information.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/dialog.dart';

import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

class RoleDetailsPage extends StatefulWidget {
  RoleDetailsPage({super.key});

  @override
  State<RoleDetailsPage> createState() => _RoleDetailsPageState();
}

class _RoleDetailsPageState extends State<RoleDetailsPage> {
  late RoleCubit controller;
  late bool isTablet;

  @override
  void initState() {
    super.initState();
    controller = context.read<RoleCubit>();
    RoleLogService.log(RoleLogService.pageRoleDetails);
  }

  @override
  Widget build(BuildContext context) {
    // No local HapticController: CustomEditIcon/CustomDeleteIcon fire their
    // own (medium / high) haptics, and firing here too double-buzzed the tap.
    isTablet = MediaQuery.of(context).size.width >= 600;

    // FRAME 8/9/2026: header + horizontal padding now come from
    // SideFrameMasterServices; the page-level Padding and PaginationAppBar it
    // replaced are gone. SideFrameBoundedBody gives the `Expanded` below a
    // bounded height on the frame's phone (scrolling) branch.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => popFrameRoutes(context, 1),
          secondTitle: S.of(context).roleDetails,
          child: SideFrameBoundedBody(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20.sp,
            children: [
              if (controller.selectedRole!.currentRoleName.toLowerCase() !=
                  'master admin')
                Row(
                  spacing: 10.sp,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppControllers.employee.isHasPermission(
                      module: Modules.roles,
                      section: RolePermissionsSections.roleManagement,
                      permission: RoleManagement.editRole,
                    )
                        // Shared core action buttons — they own their own
                        // sizing, svg and haptics, so the page no longer
                        // hand-rolls an edit/delete customButton pair.
                        ? CustomEditIcon(
                      title: S.of(context).edit,
                      onTap: () {
                        context
                            .read<RoleCubit>()
                            .selectRole(controller.selectedRole!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            BlocProvider<RoleCubit>.value(
                              value: controller,
                              child: AddingNewRole(),
                            ),
                          ),
                        );
                      },
                    )
                        : const SizedBox(),
                    AppControllers.employee.isHasPermission(
                      module: Modules.roles,
                      section: RolePermissionsSections.roleManagement,
                      permission: RoleManagement.deleteRole,
                    )
                        ? CustomDeleteIcon(
                      color: AppColors.red,
                      svgColor: AppColors.white,
                      textStyle: StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.white),
                      title: S.of(context).delete,
                      // Confirm → delete → success → back to the roles home,
                      // all in the shared RoleDialogs flow (same as the draft
                      // Delete on AddingNewRole).
                      //
                      // FIXED 28/8/2026: this used the plain ConfirmDialog (no
                      // success message) and then `pushAndRemoveUntil` a FRESH
                      // RoleScreen — which re-ran its full async init and left
                      // the user staring at that screen's blank loading spinner.
                      // showDeleteRoleDialog pops back to the roles home that is
                      // already built underneath instead, so there is no
                      // re-built page and no spinner, and it shows the missing
                      // confirmation dialog.
                      onTap: () {
                        RoleDialogs.showDeleteRoleDialog(
                          context: context,
                          controller: controller,
                        );
                      },
                    )
                        : const SizedBox(),
                  ],
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 20.sp,
                    children: [
                      RoleInformation(),
                      ModulesGranted(),
                      ModulePermissionsWidget(),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}