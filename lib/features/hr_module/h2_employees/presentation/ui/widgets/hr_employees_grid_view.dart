// ***************************** FILE INFO ***************************** //
// File Name: hr_employees_grid_view.dart
// Purpose: Displays shared HR employees as responsive grid cards.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/custom/19-Custom_Employee_Card.dart';
import '../../../../../../core/custom/34-custom_gridview_with_animation.dart';
import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/custom/6-custom_button_with_svg.dart';
import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/helper/hr/hr_routes.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../controller/cubit/hr_employee_cubit.dart';
import '../../controller/cubit/hr_employee_state.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class HrEmployeesGridView extends StatelessWidget {
  const HrEmployeesGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HrEmployeeCubit, HrEmployeeState>(
      builder: (context, state) {
        final employees = state.employees;
        if (state is HrEmployeeInitial && employees.isEmpty ||
            state is HrEmployeeLoading && employees.isEmpty) {
          return const CircleProgressMaster();
        }
        if (state is HrEmployeeError && employees.isEmpty) {
          return Center(
            child: Text(FormatHelper.capitalize(state.message)),
          );
        }
        if (employees.isEmpty) {
          return Center(
            child: Text(FormatHelper.capitalize(S.of(context).noResults)),
          );
        }

        return AnimatedCustomGridView(
          margin: EdgeInsets.only(
            top: 16.sp,
            bottom: 16.sp,
          ),
          itemCount: employees.length,
          crossAxisCount: CrossAxisCountHelperResponsive
              .getCrossAxisCountForDefaultTabletResponsive(context),
          mainAxisExtent: 75.sp,
          mainAxisSpacing: 16.sp,
          crossAxisSpacing: 16.sp,
          shrinkWrap: false,
          itemBuilder: (_, index) => HrEmployeeGridCard(
            employee: employees[index],
          ),
        );
      },
    );
  }
}

class HrEmployeeGridCard extends StatelessWidget {
  const HrEmployeeGridCard({required this.employee, super.key});

  final HrEmployeeEntity employee;

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        HRRoutes.hrModuleEmployeeDetailsPage,
        arguments: employee,
      ),
      borderRadius: BorderRadius.circular(8.r),
      child: PersonChipCard(
        width: double.infinity,
        name: isEnglish
            ? FormatHelper.capitalize(employee.getFirstAndLastName())
            : FormatHelper.capitalize(employee.getFirstAndLastNameArabic()),
        subtitle1: FormatHelper.capitalize(
            (isEnglish ? employee.title : employee.titleInArabic) ?? ""),
        subtitle2: FormatHelper.capitalize(_departmentName(isEnglish)),
        avatar: _avatarOf(employee.photo),
        showCheckBox: false,
        trailing: customButtonWithSvg(
            title: FormatHelper.capitalize(S.of(context).message),
            function: () {},
            textStyle: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.textButton,
            ),
            color: AppColors.primary,
            image: AppAssets.message,
            widthImage: 16.sp,
            heightImage: 16.sp,
            colorBorder: AppColors.transparent,
            svgColor: AppColors.textButton,
            space: 4.sp,
            width: 100.sp),
      ),
    );
  }

  /// Method Name: [_departmentName]
  ///
  /// Purpose: Resolves the employee department label through the shared cubit.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether to resolve the English department name.
  ///
  /// Returns: The localized department label or an empty value when unavailable.
  String _departmentName(bool isEnglish) {
    final departmentId = employee.departmentId;
    if (departmentId == null || departmentId.isEmpty) return '';
    return Get.find<MainCoreDepartmentCubit>()
        .getDepartmentName(departmentId, isEnglish);
  }

  /// Method Name: [_avatarOf]
  ///
  /// Purpose: Resolves a supported employee image provider.
  ///
  /// Parameters:
  /// - [photo]: Stored asset path or remote employee image URL.
  ///
  /// Returns: An image provider or null for the card fallback avatar.
  ImageProvider? _avatarOf(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    return photo.startsWith('assets/')
        ? AssetImage(photo)
        : NetworkImage(photo);
  }
}
