/// Module: roles / r1_role_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: role_permission_switches.dart
/// Purpose: Declares `RolePermissionSwitches`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
// FRAME 8/9/2026: `pagination_app_bar.dart` replaced by the shared side frame.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/dialog.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/module_switches_builder.dart';
import './settings_switches_page.dart';

class RolePermissionSwitches extends StatelessWidget {
  RolePermissionSwitches({super.key});

  /// Shared width for this page's action buttons.
  ///
  /// ADDED 8/9/2026. Passed as `width:`, which is the parameter `customButton`
  /// actually honours — its own source says `exactWidth` and `fullWidth` are
  /// still discarded ("remain broken"), so passing those silently fell back to
  /// the 135.sp / 170.sp default and is what pushed the export dialog's row
  /// 10px over. 120.sp on mobile, 150 on tablet.
  double get _actionButtonWidth => isTablet ? 150 : 130.sp;
  late bool isTablet;
  late RoleCubit controller;

  @override
  Widget build(BuildContext context) {
    controller = context.read<RoleCubit>();
    isTablet = MediaQuery.of(context).size.width > 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final s = S.of(context);

    // FRAME 8/9/2026: the breadcrumb is now SideFrameMasterServices, which also
    // owns the horizontal padding this page used to apply itself. The crumb
    // taps pop the matching number of routes: the wizard is one route deeper
    // when editing (RoleDetails → AddingNewRole → here) than when creating.
    final bool editing = controller.isEditing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: SideFrameMasterServices(
            titleText: s.platformControlsAndManagement,
            onFirstTap: () => popFrameRoutes(context, editing ? 3 : 2),
            secondTitle: editing ? s.roleDetails : s.addingNewRole,
            onSecondTap: () => popFrameRoutes(context, editing ? 2 : 1),
            // Role QA p.5: on a phone the page title read "Role Permissions";
            // it is still the Adding New Role wizard, so that stays the title
            // and "Permission Controls" labels the section below instead.
            thirdTitle: editing
                ? s.editingRole
                : (MediaQuery.of(context).size.width < 600
                    ? null
                    : s.rolePermissions),
            onThirdTap: editing ? () => popFrameRoutes(context, 1) : null,
            fourthTitle: editing ? s.editRolePermissions : null,
            child: SideFrameBoundedBody(
              child: BlocBuilder<RoleCubit, RoleState>(
              buildWhen: (previous, current) =>
              current is RoleSwitchToggled ||
                  current is RoleSelected ||
                  current is RolePermissionLoaded ||
                  current is RolePermissionUpdated,
              builder: (context, state) {
                // Was a private switch on this page whose `default` returned
                // Modules.employees — an unknown module silently rendered as
                // "employees". RoleCubit owns the single name -> enum map and
                // drops names it cannot render.
                List<Modules> selectedModulesAsEnum =
                    controller.moduleEnumsFor(controller.selectedModules);

                List<Modules> modulesWithPermissions = selectedModulesAsEnum
                    .where((module) => Modules.modulesHasPermission.contains(module))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 15.sp,
                            children: [
                              if (!editing &&
                                  MediaQuery.of(context).size.width < 600)
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    s.permissionControls,
                                    style: StyleText.fontSize18Weight500
                                        .copyWith(color: AppColors.text),
                                  ),
                                ),
                              if (modulesWithPermissions.isEmpty)
                                Container(
                                  padding: EdgeInsets.all(20.sp),
                                  margin: EdgeInsets.symmetric(vertical: 20.sp),
                                  decoration: BoxDecoration(
                                    color: AppColors.field,
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.info_outline, size: 48, color: AppColors.primary),
                                      SizedBox(height: 16),
                                      Text(
                                        '${s.selectedModules}: ${controller.selectedModules.join(", ")}',
                                        style: StyleText.fontSize16Weight400,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        s.noPermissionNeeded,
                                        style: StyleText.fontSize14Weight400,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        s.clickNextToContinue,
                                        style: StyleText.fontSize16Weight400.copyWith(
                                          color: AppColors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                              for (Modules module in modulesWithPermissions)
                                ModuleSwitchesBuilder(module: module),
                            ],
                          ),
                        )),
                    SizedBox(height: 20.sp),
                    // BUTTON WIDTH 8/9/2026: all three share one width so the
                    // column lines up — see _actionButtonWidth.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          spacing: 5.sp,
                          children: [
                            customButton(
                              title: s.back,
                              color: AppColors.secondaryButton,
                              textStyle: StyleText.fontSize16Weight400.copyWith(
                                color: AppColors.blackButton
                              ),
                              width: _actionButtonWidth,
                              function: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            if (!controller.isEditing)
                              customButton(
                                title: s.saveForLater,
                                color: AppColors.secondaryButton,
                                textStyle: StyleText.fontSize16Weight400.copyWith(
                                    color: AppColors.blackButton
                                ),
                                width: _actionButtonWidth,
                                function: () {
                                  RoleLogService.log(RoleLogService.actionCreateRole);
                                  RoleDialogs.showSaveForLaterDialog(
                                    context: context,
                                    controller: controller,
                                    pagesToPop: 2,
                                  );
                                },
                              )
                          ],
                        ),
                        customButton(
                          title: s.next,
                          width: _actionButtonWidth,
                          function: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BlocProvider<RoleCubit>.value(
                                  value: controller,
                                  child: SettingsSwitchesPage(),
                                )));
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 20.sp),
                  ],
                );
              },
              ),
            ),
          )),
    );
  }

  // REMOVED 12/8/2026: private `_stringToModuleEnum` — a third drifted copy
  // of RoleCubit.stringToModuleEnum, and the only one whose `default` mapped
  // unknown names to Modules.employees instead of skipping them.

}