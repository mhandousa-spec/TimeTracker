/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: platform_roles_header.dart
/// Purpose: Declares `PlatformRolesHeader`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Search field replaced by the shared `AppSearchTextField`.
///
/// The header hand-rolled its search box out of `CustomTextField`, which is the
/// pattern `AppSearchTextField` exists to end (see its `suffixIcon` note, dated
/// 16/8/2026 — the screens that hand-rolled a search field "must all go through
/// this widget now"). This one had drifted: its own magnifier at 14sp instead of
/// 16sp, its own padding and value style, and a hardcoded
/// `context.isArabic ? 'بحث' : 'Search'` hint in place of `S.of(context).search`.
///
/// `AppSearchTextField` returns an `Expanded` itself, so it is a DIRECT child of
/// the Row here — wrapping it in another `Expanded`, as the old
/// `CustomTextField` needed, would throw.

import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/role_management_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/adding_new_role.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

class PlatformRolesHeader extends StatefulWidget {
  const PlatformRolesHeader({super.key});

  @override
  State<PlatformRolesHeader> createState() => _PlatformRolesHeaderState();
}

class _PlatformRolesHeaderState extends State<PlatformRolesHeader> {
  late RoleCubit controller;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      controller.filterRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = AppControllers.haptic;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    controller = context.read<RoleCubit>();
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocBuilder<RoleCubit, RoleState>(
      buildWhen: (previous, current) =>
      current is RoleFetched ||
          current is RoleFiltered ||
          current is RoleAdded ||
          current is RoleUpdated ||
          current is RoleDeleted ||
          current is RoleDraftSaved ||
          current is RoleActivated,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role QA p.2: the "Platform Roles" caption is removed on phones
            // (the tab above already says Role Management).
            if (!context.isPhone) ...[
              Text(
                S.of(context).platformRoles,
                style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.text
                ),
              ),
              SizedBox(height: 8.sp),
            ],
            Row(
              spacing: AppControllers.employee.isHasPermission(
                module: Modules.roles,
                section: RolePermissionsSections.roleManagement,
                permission: RoleManagement.createRoleManagement,
              ) ? 15 : 0.sp,
              children: [
                // Already an Expanded — do NOT wrap it in another one.
                // Hint, magnifier, height, padding and radius all come from the
                // shared widget; only the clear button is passed in.
                AppSearchTextField(
                  controller: controller.searchController,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  suffixIcon: controller.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.filterRoles();
                          },
                        )
                      : null,
                ),
                AppControllers.employee.isHasPermission(
                  module: Modules.roles,
                  section: RolePermissionsSections.roleManagement,
                  permission: RoleManagement.createRoleManagement,
                )
                    ? customButtonWithSvg(
                  image: 'assets/icons_assets/watermark/role.svg',
                  svgColor: AppColors.textButton,
                  color: AppColors.primary,
                  widthImage: 14.sp,
                  space: context.isPhone ? 0.sp : 8.sp,
                  heightImage: 22.sp,
                  colorBorder: Colors.transparent,
                  width: isTablet ? 100 : 38,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton
                  ),
                  title: context.isPhone ? "" : S.of(context).role,
                  function: () {
                    hapticController.triggerHapticFeedback(
                        vibration: VibrateType.mediumImpact,
                        hapticFeedback: HapticFeedback.mediumImpact
                    );

                    context.read<RoleCubit>().initAddingRoleController();
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => BlocProvider<RoleCubit>.value(
                              value: controller,
                              child: AddingNewRole(),
                            )
                        )
                    );
                  },
                )
                    : SizedBox()
              ],
            )
          ],
        );
      },
    );
  }
}