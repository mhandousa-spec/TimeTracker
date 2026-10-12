/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: grid_table_export.dart
/// Purpose: Declares `ViewToggleButtons`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/role_management_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_management_permission.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

class ViewToggleButtons extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onTableViewTap;
  final VoidCallback onGridViewTap;
  final bool showExport;
  final VoidCallback? onExportTap;

  /// ADDED 21/9/2026 (bug report p.1, Figma 4717:33513): an Import button
  /// drawn left of Export, in the same style. Shown only when a callback is
  /// given — the caller decides the permission.
  final VoidCallback? onImportTap;

  const ViewToggleButtons({
    super.key,
    required this.isGridView,
    required this.onTableViewTap,
    required this.onGridViewTap,
    this.showExport = false,
    this.onExportTap,
    this.onImportTap,
  });

  /// Import button — the Export button's exact geometry (labelled in tablet
  /// landscape, icon-only otherwise).
  Widget _importButton(BuildContext context) {
    final bool labelled = isTabletLandscape(context);
    final Widget icon = CustomSvgImage(
      // Role QA p.7: was the knowledge-hub book icon.
      assetPath: 'assets/icons_assets/watermark/upload.svg',
      fit: BoxFit.scaleDown,
      width: 20.sp,
      height: 20.sp,
      color: AppColors.textButton,
      semanticsLabel: 'Import',
    );

    return GestureDetector(
      onTap: onImportTap,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 8.sp),
        child: Container(
          height: 38.sp,
          width: labelled ? null : 38.sp,
          padding: labelled
              ? EdgeInsets.symmetric(horizontal: 14.sp)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: labelled
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).import,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                  ],
                )
              : Center(child: icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    var isMobile = ContextExtension(context).isPhone;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onImportTap != null) _importButton(context),
        if (showExport ||
            AppControllers.employee.isHasPermission(
              module: Modules.roles,
              section: RolePermissionsSections.roleManagement,
              permission: RoleManagement.exportRoleData,
            )|| AppControllers.employee.isHasPermission(
          module: Modules.roles,
          section: RolePermissionsSections.userManagement,
          permission: UserManagement.exportUsersData,
        ))

        GestureDetector(
            onTap: onExportTap,
            child: Padding(
              padding: isMobile
                  ? EdgeInsets.symmetric(horizontal: 0.sp)
                  : EdgeInsets.symmetric(horizontal: 8.sp),
              child: Container(
                width: isTabletLandscape(context) ? 100.sp : 38.sp,
                height: 38.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: isTabletLandscape(context)
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CustomSvgImage(assetPath: 
                        "assets/icons_assets/watermark/export.svg",
                        fit: BoxFit.scaleDown,
                        width: 20.sp,
                        height: 20.sp,
                        color: AppColors.textButton,
                        semanticsLabel: 'Export',
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).export,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton
                      ),
                    )
                  ],
                )
                    // Role QA p.2 / p.7: the phone used the share-arrow icon;
                    // it now uses the same export icon as the tablet button.
                    : Center(
                  child: CustomSvgImage(assetPath:
                    "assets/icons_assets/watermark/export.svg",
                    fit: BoxFit.scaleDown,
                    width: 20.sp,
                    height: 20.sp,
                    color: AppColors.textButton,
                    semanticsLabel: 'Export',
                  ),
                ),
              ),
            ),
          ),
        // Table / grid toggles use the shared core buttons. Colours are passed
        // explicitly so the selected/unselected look matches what was here
        // before (the core defaults are transparent + white icon).
        isMobile
            ? SizedBox()
            : customTableButton(
                function: onTableViewTap,
                isSelected: !isGridView,
                color: AppColors.card,
                selectedColor: AppColors.primary,
                svgColor: lightMode ? AppColors.blackButton : AppColors.white,
                selectedSvgColor: AppColors.textButton,
              ),
        isMobile ? SizedBox() : SizedBox(width: 8.sp),
        isMobile
            ? SizedBox()
            : customGridButton(
                function: onGridViewTap,
                isSelected: isGridView,
                 color: AppColors.card,
                selectedColor: AppColors.primary,
                svgColor:lightMode ? AppColors.blackButton : AppColors.white,
                selectedSvgColor: AppColors.textButton,
              ),
      ],
    );
  }
  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }
}