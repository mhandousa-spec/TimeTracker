/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: add_new_users_access.dart
/// Purpose: Declares `AddNewUsersAccess`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/68-confirm_dialog.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
// FRAME 8/9/2026: `pagination_app_bar.dart` replaced by the shared side frame.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/access_details.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/access_search_and_filter.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/person_state_view.dart';
// ADDED 9/10/2026 — per-module user limits.
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_limit_usage_panel.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
class AddNewUsersAccess extends StatelessWidget {
  AddNewUsersAccess({super.key});

  /// Shared width for this page's action buttons.
  ///
  /// ADDED 8/9/2026. Passed as `width:`, which is the parameter `customButton`
  /// actually honours — its own source says `exactWidth` and `fullWidth` are
  /// still discarded ("remain broken"), so passing those silently fell back to
  /// the 135.sp / 170.sp default and is what pushed the export dialog's row
  /// 10px over. 120.sp on mobile, 150 on tablet.
  // Role QA p.28: 120 on a phone was too narrow for "Granted Access", which
  // wrapped onto two lines and spilled out of the button.
  double _actionButtonWidth(bool isTablet) => isTablet ? 150 : 150.sp;
  late UserManagementAccessCubit controller;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    controller = context.read<UserManagementAccessCubit>();
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      // FRAME 8/9/2026: header + horizontal padding come from
      // SideFrameMasterServices, replacing PaginationAppBar and this page's own
      // Padding. SideFrameBoundedBody bounds the employee grid's `Expanded` on
      // the frame's phone (scrolling) branch.
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => popFrameRoutes(context, 1),
          secondTitle: S.of(context).addingNewAccess,
          child: SideFrameBoundedBody(
            child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccessDetails(),
                // 9/10/2026 — "Time Tracker: 8 of 10 users", "Users: 18 of
                // 20", and why the selection below cannot be granted.
                const UserLimitUsagePanel(),
                SizedBox(height: 20.sp),
                Text(S.of(context).employees,style: StyleText.fontSize16Weight500.copyWith(
                    color:AppColors.text
                ),),
                SizedBox(height: 10.sp),
                AccessSearchAndFilter(),
                SizedBox(height: 20.sp),


                BlocBuilder<UserManagementAccessCubit,
                    UserManagementAccessState>(
                  builder: (context, state) {
                    return Expanded(
                      child: GridView.builder(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: CrossAxisCountHelper
                                .getCrossAxisCountForDefaultTablet2(context),
                            // RAISED 28/8/2026 from 70.sp. The card carries
                            // three lines — name, department, job title — and
                            // 70.sp left no room for the last two, which is why
                            // PersonStateView had to squeeze them into
                            // `Expanded` and their glyphs came out clipped.
                            // 90.sp fits all three at their natural height,
                            // Arabic descenders included.
                            mainAxisExtent: 80.sp,
                            mainAxisSpacing: 10.sp,
                            crossAxisSpacing: 10.sp,
                          ),
                          itemCount:
                          controller.filteredEmployeeToGiveAccess.length,
                          itemBuilder: (context, index) {
                            return PersonStateView(
                                onTap: () {
                                  controller.selectUserToChangeAccess(controller
                                      .filteredEmployeeToGiveAccess[index]
                                      .employeeId);
                                },
                                color: AppColors.card,
                                isSelected: controller
                                    .selectedUsersIdToChangeAccess
                                    .contains(controller
                                    .filteredEmployeeToGiveAccess[index]
                                    .employeeId),
                                person: controller
                                    .filteredEmployeeToGiveAccess[index]);
                          }),
                    );
                  },
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      width: _actionButtonWidth(isTablet),
                      function: () {
                        Navigator.of(context).pop();
                      },
                      title: S.of(context).discard,
                      color: AppColors.secondaryButton,
                      textStyle: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton
                      ),),
                    BlocBuilder<UserManagementAccessCubit,
                        UserManagementAccessState>(
                      buildWhen: (_, state) {
                        return true;
                      },
                      builder: (context, state) {
                        // Check all required conditions
                        bool isRoleSelected = controller.newAccessSelectedRole != null;
                        bool isEmployeeSelected = controller.selectedUsersIdToChangeAccess.isNotEmpty;
                        // 9/10/2026 — the selection must also fit the user
                        // limits Knowticed Admin set; until it does (or while
                        // the limits are still loading / could not be read)
                        // the button stays disabled and explains why.
                        final String? limitMessage =
                            isRoleSelected && isEmployeeSelected
                                ? controller.selectionLimitMessage
                                : null;
                        bool isAllConditionsMet = isRoleSelected &&
                            isEmployeeSelected &&
                            limitMessage == null;

                        return customButton(
                          width: _actionButtonWidth(isTablet),
                          function: () {
                            if (limitMessage != null) {
                              // 9/10/2026 — a failed read is retried on tap.
                              if (controller.licenceUsageFailed) {
                                controller.loadLicenceUsage();
                              }
                              CustomDialogManager.showSuccess(
                                context: context,
                                lottiePath:
                                    'assets/lottie_assets/main_lottie_assets/warning.json',
                                title: limitMessage,
                              );
                              return;
                            }
                            if (!isAllConditionsMet) {
                              // Show warning dialog if conditions not met
                              String warningMessage = '';
                              if (!isRoleSelected && !isEmployeeSelected) {
                                warningMessage = S.of(context).selectRoleAndEmployee;
                              } else if (!isRoleSelected) {
                                warningMessage = S.of(context).selectRoleType;
                              } else if (!isEmployeeSelected) {
                                warningMessage = S.of(context).selectAtLeastOneEmployee;
                              }

                              CustomDialogManager.showSuccess(
                                context: context,
                                lottiePath:
                                    'assets/lottie_assets/main_lottie_assets/warning.json',
                                title: warningMessage,
                              );
                            } else {
                              // Proceed with normal flow
                              if (formKey.currentState!.validate()) {
                                ConfirmDialog().show(context,
                                    title: S.of(context).addAccess,
                                    subtitle:
                                    S.of(context).confirmAddUsersAccess,
                                    icon: 'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
                                    onCancel: () {},
                                    onConfirm: () async {
                                      RoleLogService.log(RoleLogService.actionGrantAccess);
                                      // Role QA p.10: loading indicator
                                      // while the access is written.
                                      await CustomDialogManager.runWithLoading(
                                        context,
                                        () => controller
                                            .updateSelectedMembersAccess(),
                                      );
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                              }
                            }
                          },
                          title: S.of(context).grantedAccess,
                          color: isAllConditionsMet
                              ? AppColors.primary
                              : AppColors.darkGrey,
                          textStyle: StyleText.fontSize16Weight600.copyWith(
                            color: isAllConditionsMet
                                ? AppColors.textButton
                                : AppColors.black,
                          ),);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}