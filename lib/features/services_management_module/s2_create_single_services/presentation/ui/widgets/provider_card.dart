// ******************* FILE INFO *******************
// File Name: provider_card
// Description: Provider card.
// Module: services_management_module / presentation/s2_create_single_services/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderCard extends StatelessWidget {
  final EmployeeEntityPro employee;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEditMode; // ✅ NEW


  const ProviderCard({
    super.key,
    required this.employee,
    required this.isSelected,
    required this.onTap,
    this.isEditMode = false, // ✅ NEW — default false
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final departmentController = context.read<MainCoreDepartmentCubit>();

    final displayName = _getDisplayName(isArabic);
    final displayDepartment = _getDisplayDepartment(departmentController, isArabic);
    final displayRole = _getDisplayJobTitle(isArabic);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
      //    border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        padding: EdgeInsets.only(right: 10.sp, left: 0.sp, top: 10.sp, bottom: 10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(color: AppColors.text),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 3.sp),
                  Text(
                    displayDepartment,
                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(color: AppColors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 3.sp),
                  Text(
                    displayRole,
                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(color: AppColors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            _buildCheckbox(isArabic),
            SizedBox(width: isArabic ? 10.sp : 0.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 30.r,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: SvgPicture.asset(
          employee.gender == "male" ? 'assets/icons_assets/main_icons_assets/male_avatar.svg' : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
          fit: BoxFit.cover,
          width: 40.sp,
          height: 40.sp,
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isArabic) {
    // ✅ Hide checkbox in editProvider (single-select) mode
    if (isEditMode) return const SizedBox.shrink();

    return CustomCheckBox(
      isSelected: isSelected,
      size: 20.sp,
      borderColor: AppColors.secondaryText,
    );
  }

  String _getDisplayName(bool isArabic) {
    final nameEn = [employee.firstName, employee.lastName]
        .where((x) => (x ?? '').trim().isNotEmpty)
        .join(' ')
        .trim();
    final nameAr = [employee.firstNameInArabic, employee.lastNameInArabic]
        .where((x) => (x ?? '').trim().isNotEmpty)
        .join(' ')
        .trim();

    return isArabic
        ? (nameAr.isNotEmpty ? nameAr : nameEn)
        : (nameEn.isNotEmpty ? FormatHelper.capitalize(nameEn) : nameAr);
  }

  String _getDisplayDepartment(MainCoreDepartmentCubit controller, bool isArabic) {
    if (employee.departmentId == null || employee.departmentId!.isEmpty) {
      return isArabic ? 'القسم غير محدد' : 'Department not specified';
    }
    // 035: no try/catch in widget (§11.2) — resolving the id is the controller's job.
    return controller.getDepartmentName(employee.departmentId!, !isArabic);
  }

  String _getDisplayJobTitle(bool isArabic) {
    final titleEn = (employee.title ?? '').trim();
    final titleAr = (employee.titleInArabic ?? '').trim();

    String title = isArabic
        ? (titleAr.isNotEmpty ? titleAr : titleEn)
        : (titleEn.isNotEmpty ? FormatHelper.capitalize(titleEn) : titleAr);

    // Extract abbreviation from parentheses at the end
    final abbreviationRegex = RegExp(r'\(([^)]+)\)\s*$');
    final match = abbreviationRegex.firstMatch(title);

    if (match != null) {
      // Return only what's inside the parentheses
      return match.group(1) ?? title;
    }

    return title;
  }
}
