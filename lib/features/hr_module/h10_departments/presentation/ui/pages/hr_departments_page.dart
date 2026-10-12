// ***************************** FILE INFO ***************************** //
// File Name: hr_departments_page.dart
// Purpose: Renders the HR Departments locations page shell.
// Author: Mohamed Elrashidy
// Created At: 2026-08-26
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/9-filter_tab_with_container.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../widgets/department_action_rows.dart';
import '../widgets/department_locations_content.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Hosts the first visual shell for the HR Departments feature.
class HrDepartmentsPage extends StatelessWidget {
  const HrDepartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  localization.humanResources,
                  localization.departments,
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildViewSwitch(localization),
                        SizedBox(height: 16.h),
                        const DepartmentActionRows(),
                        SizedBox(height: 24.h),
                        const DepartmentLocationsContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Method Name: [_buildViewSwitch]
  ///
  /// Purpose: Renders the Locations/Structure switch shown above the actions.
  ///
  /// Parameters:
  /// - [localization]: Localized labels for the two visual tabs.
  ///
  /// Returns: A non-operational segmented switch for the first shell.
  Widget _buildViewSwitch(S localization) {
    return CustomSegmentedTabs(
      tabs: [localization.locations, localization.structure],
      selectedIndex: 0,
      onTabSelected: (_) {},
      containerPadding: EdgeInsets.all(4.sp),
      containerColor: AppColors.card,
      borderRadius: 8.r,
      spacing: 0,
      tabHorizontalPadding: 12.w,
      tabVerticalPadding: 8.h,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.card,
      selectedTextColor: AppColors.textButton,
      unselectedTextColor: AppColors.secondaryText,
      textStyle: StyleText.fontSize14Weight500,
    );
  }
}
