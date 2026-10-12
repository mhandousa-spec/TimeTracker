/// Module: roles / r1_role_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: settings_switches_page.dart
/// Purpose: Declares `SettingsSwitchesPage`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Save/Create now runs the shared confirm → success →
///                      navigate flow (RoleDialogs.showSaveRoleDialog).

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/permission_label.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// FRAME 8/9/2026: `pagination_app_bar.dart` replaced by the shared side frame.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_switches_controllers.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
// REMOVED 25/8/2026: `68-confirm_dialog.dart`, `83-loading.dart` and
// `role_status.dart` — the save flow they served moved into RoleDialogs.
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/dialog.dart';
import 'package:flutter/services.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/role_restricted_countries_field.dart';
class SettingsSwitchesPage extends StatelessWidget {
  SettingsSwitchesPage({super.key});

  /// Shared width for this page's action buttons.
  ///
  /// ADDED 8/9/2026. Passed as `width:`, which is the parameter `customButton`
  /// actually honours — its own source says `exactWidth` and `fullWidth` are
  /// still discarded ("remain broken"), so passing those silently fell back to
  /// the 135.sp / 170.sp default and is what pushed the export dialog's row
  /// 10px over. 120.sp on mobile, 150 on tablet.
  double get _actionButtonWidth => isTablet ? 150 : 130.sp;
  late RoleCubit controller;
  late bool isTablet;

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = AppControllers.haptic;

    controller = context.read<RoleCubit>();
    isTablet = MediaQuery.of(context).size.width > 600;

    return BlocBuilder<RoleCubit, RoleState>(
      buildWhen: (previous, current) => current is RoleSwitchToggled,
      builder: (context, state) {
        // FRAME 8/9/2026: breadcrumb + horizontal padding now come from
        // SideFrameMasterServices. The frame carries four crumbs, so the edit
        // path drops its "Role details" step and keeps the root plus the three
        // wizard steps — the same trail, one link shorter. Each crumb pops the
        // number of routes that actually sit between it and this page.
        final bool editing = controller.isEditing;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SideFrameMasterServices(
              titleText: S.of(context).platformControlsAndManagement,
              onFirstTap: () => popFrameRoutes(context, editing ? 4 : 3),
              secondTitle: editing
                  ? S.of(context).editingRole
                  : S.of(context).addingNewRole,
              onSecondTap: () => popFrameRoutes(context, 2),
              thirdTitle: editing
                  ? S.of(context).editRolePermissions
                  : S.of(context).addingNewRolePermissions,
              onThirdTap: () => popFrameRoutes(context, 1),
              fourthTitle: editing
                  ? S.of(context).editRoleSettingsPermissions
                  : S.of(context).settingsPermission,
              child: SideFrameBoundedBody(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: modulePermissionsBuilder(Modules.settings),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        spacing: 5.sp,
                        children: [
                          customButton(
                            title: S.of(context).back,
                            color: AppColors.secondaryButton,
                            textStyle: StyleText.fontSize16Weight400.copyWith(color: AppColors.blackButton),

                            width: _actionButtonWidth,
                            function: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          if (!controller.isEditing)
                            customButton(
                              title: S.of(context).saveForLater,
                              color: AppColors.secondaryButton,
                              textStyle: StyleText.fontSize16Weight400.copyWith(color: AppColors.blackButton),
                              width: _actionButtonWidth,
                              function: () {
                                RoleDialogs.showSaveForLaterDialog(
                                  context: context,
                                  controller: controller,
                                  pagesToPop: 3,

                                );
                              },
                            )
                        ],
                      ),
                      customButton(
                        title: controller.isEditing ? S.of(context).save : S.of(context).create,
                        width: _actionButtonWidth,
                        // REWORKED 25/8/2026: this used to be a `ConfirmDialog`
                        // whose onConfirm popped straight out of the wizard the
                        // moment the write returned — the user never saw a
                        // success dialog, and a FAILED save navigated away in
                        // exactly the same way. The confirm → save → success →
                        // navigate sequence now lives in RoleDialogs next to
                        // "save for later", and the pops run only after the
                        // success dialog has closed.
                        function: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.heavyImpact,
                              hapticFeedback: HapticFeedback.heavyImpact
                          );
                          RoleDialogs.showSaveRoleDialog(
                            context: context,
                            controller: controller,
                          );
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 20.sp),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget modulePermissionsBuilder(Modules module) {
    return Column(
      spacing: 15.sp,
      children: [
        if (isTablet)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 20.sp,
            children: [
              Expanded(child: firstColumnBuilder(module)),
              Expanded(child: lastColumnBuilder(module)),
            ],
          ),
        if (!isTablet)
          Column(
            children: [
              firstColumnBuilder(module),
              SizedBox(height: 10.sp),
              lastColumnBuilder(module),
            ],
          )
      ],
    );
  }

  Widget firstColumnBuilder(Modules module) {
    return Column(
      spacing: 10.sp,
      children: [
        for (Enum permissionSection in module.moduleFirstColumnPermissions)
          buildPermissionSection(
            permissionSection as ModulePermissionsSections,
            module,
          ),
      ],
    );
  }

  Widget lastColumnBuilder(Modules module) {
    return Column(
      spacing: 10.sp,
      children: [
        for (Enum permissionSection in module.moduleLastColumnPermissions)
          buildPermissionSection(
            permissionSection as ModulePermissionsSections,
            module,
          ),
      ],
    );
  }

  Widget buildPermissionSection(
      ModulePermissionsSections permissionSection,
      Modules module,
      ) {
    if (permissionSection.sectionPermissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      spacing: 10.sp,
      children: [
        Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            spacing: 10.sp,
            children: [
              Row(
                spacing: 5.sp,
                children: [
                  CircleAvatar(
                    radius: 12.5.r,
                    backgroundColor: AppColors.primary,
                    child: Padding(
                      padding: EdgeInsets.all(4.sp),
                      child: CustomSvgImage(assetPath: 
                        (permissionSection.getName ==
                            SettingsPermissionsSections.settings.getName)
                            ? 'assets/icons_assets/roles_assets/settings.svg'
                            : 'assets/icons_assets/roles_assets/scoial_permission.svg',
                        colorFilter: ColorFilter.mode(
                          AppColors.textButton,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    // Builder supplies the BuildContext: this class is a
                    // StatelessWidget, so `context` is only in scope inside
                    // build(), not in these helper methods. Same idiom the
                    // sibling module_switches_builder.dart uses here.
                    child: Builder(
                      builder: (BuildContext context) => Text(
                        PermissionLabel.of(context, permissionSection.getName),
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                      ),
                    ),
                  ),
                ],
              ),
              for (int permissionIndex = 0;
              permissionIndex <
                  permissionSection.sectionPermissions.length;
              permissionIndex++)
                _buildPermissionRow(
                  permissionSection.sectionPermissions[permissionIndex]
                  as ModulePermissionsSectionsPermission,
                  permissionSection,
                  module,
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPermissionRow(
      ModulePermissionsSectionsPermission permission,
      ModulePermissionsSections section,
      Modules module,
      ) {
    final HapticController hapticController = AppControllers.haptic;

    // ✅ Check if this permission exists in Firebase
    String moduleName = controller.moduleEnumToString(module);

    bool hasPermission = false;
    if (controller.modulePermissions.containsKey(moduleName)) {
      Map<String, bool> modulePerms = controller.modulePermissions[moduleName]!;

      // Try multiple possible keys for permission
      // NOT localized on purpose: uiName feeds `possibleKeys` below, which
      // are matched against Firestore permission keys ('Change_Theme').
      // Translating it here would make every lookup miss and silently
      // report the permission as absent. Only the Text() further down —
      // the actual label — goes through PermissionLabel.
      String uiName = permission.getUiName;
      List<String> possibleKeys = [
        uiName,                              // "Change Theme"
        uiName.replaceAll(' ', '_'),        // "Change_Theme"
        uiName.replaceAll(' ', ''),         // "ChangeTheme"
        permission.getDataBaseName,
        permission.getDataBaseName.replaceAll(' ', '_'),
      ];

      for (String key in possibleKeys) {
        if (modulePerms.containsKey(key)) {
          hasPermission = true;
          break;
        }
      }
    }

    final Widget row = Row(
      children: [
        // Indent for child permissions
        if (permission.isChild) SizedBox(width: 20.sp),

        // Permission name
        Expanded(
          // See the note in buildPermissionSection — no `context` in scope here.
          child: Builder(
            builder: (BuildContext context) => Text(
              PermissionLabel.of(context, permission.getUiName),
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        SizedBox(width: 8.sp),

        // ✅ Only show switch if permission exists in Firebase
        if (hasPermission)
          DefaultSwitchButton(
            value: controller.isSwitchActive(module, section, permission),
            onChanged: (value) {

              hapticController.triggerHapticFeedback(
                  vibration: VibrateType.mediumImpact,
                  hapticFeedback: HapticFeedback.mediumImpact
              );
              controller.toggleSwitchState(
                module: module,
                section: section,
                permission: permission,
              );
            },
          )
        else
        // Show empty space where switch would be
          SizedBox(width: 40.sp),
      ],
    );

    // ADDED 28/9/2026 — Restricted Location moved here from the Settings page.
    // While its switch is on, the countries this role may open the app from
    // are picked right under it; they are saved with the role and enforced for
    // every employee holding it (see RoleRestrictedCountriesField).
    final bool showCountries = hasPermission &&
        permission == SettingsPermissions.restrictedLocation &&
        controller.isSwitchActive(module, section, permission);
    if (!showCountries) return row;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        RoleRestrictedCountriesField(controller: controller),
      ],
    );
  }
}