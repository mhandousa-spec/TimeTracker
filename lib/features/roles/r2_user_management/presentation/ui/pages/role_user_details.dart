/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: role_user_details.dart
/// Purpose: Declares `RoleUserDetails`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

// FRAME 8/9/2026: `pagination_app_bar.dart` replaced by the shared side frame.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/access_info.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/access_search_and_filter.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/person_state_view.dart';
import './edit_role_user_access.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RoleUserDetails extends StatelessWidget {
  late UserManagementAccessCubit controller;
  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();
    // REMOVED 8/9/2026: a local `isTablet` that only fed the page padding the
    // frame now owns. The Edit button reads ContextExtension directly.
    // FRAME 8/9/2026: header + horizontal padding come from
    // SideFrameMasterServices, replacing PaginationAppBar and this page's own
    // Padding. SideFrameBoundedBody bounds the grid's `Expanded` on the frame's
    // phone (scrolling) branch.
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => popFrameRoutes(context, 1),
          secondTitle: S.of(context).userAccessDetails,
          child: SideFrameBoundedBody(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  customButtonWithSvg(
                    // Empty title on phone → renders as a square icon-only button.
                    title: ContextExtension(context).isTablett ? S.of(context).Edit : '',
                    function: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              BlocProvider<UserManagementAccessCubit>.value(
                            value: controller,
                            child: EditRoleUserAccess(),
                          ),
                        ),
                      );
                    },
                    image: 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                    widthImage: 20.sp,
                    heightImage: 20.sp,
                    space: 10.sp,
                    color: AppColors.primary,
                    svgColor: AppColors.textButton,
                    colorBorder: AppColors.transparent,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.sp),
              AccessInfo(),
              SizedBox(height: 20.sp),
              Row(
                children: [
                  AccessSearchAndFilter(),
                ],
              ),
              SizedBox(height: 10.sp),
              BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
                builder: (context, state) {
                  return Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: CrossAxisCountHelper
                              .getCrossAxisCountForDefaultTablet2(context),
                          mainAxisExtent: 96.sp,
                          mainAxisSpacing: 10.sp,
                          crossAxisSpacing: 10.sp,
                        ),
                        itemCount:
                            controller.filteredEmployeeToGiveAccess.length,
                        itemBuilder: (context, index) {
                          return PersonStateView(
                              showAccessDates: true,
                              onTap: null,
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
            ],
            ),
          ),
        ),
      ),
    );
  }
}
