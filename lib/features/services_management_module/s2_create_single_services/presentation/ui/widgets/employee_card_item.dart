// ******************* FILE INFO *******************
// File Name: employee_card_item
// Description: Employee card item.
// Module: services_management_module / presentation/s2_create_single_services/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.isSelected,
    required this.isLightMode,
    required this.name,
  });

  final dynamic employee;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isLightMode;
  final String name;

  String _getDisplayJobTitle(bool isEnglish) {
    final titleEn = (employee.title ?? '').trim();
    final titleAr = (employee.titleInArabic ?? '').trim();

    String title = isEnglish
        ? (titleEn.isNotEmpty ? FormatHelper.capitalize(titleEn) : titleAr)
        : (titleAr.isNotEmpty ? titleAr : titleEn);

    final abbreviationRegex = RegExp(r'\(([^)]+)\)\s*$');
    final match = abbreviationRegex.firstMatch(title);

    if (match != null) {
      return match.group(1) ?? title;
    }

    return title;
  }

  // Add this method to get department name
  String _getDepartmentName(BuildContext context, bool isEnglish) {
    final departmentController = context.read<MainCoreDepartmentCubit>();
    final departmentId = employee.departmentId ?? employee.department ?? '';

    if (departmentId.isEmpty) return '';

    return departmentController.getDepartmentName(departmentId, isEnglish);
  }

  @override
  Widget build(BuildContext context) {
    var isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return MediaQuery.withClampedTextScaling(
      // Keeps the card's height in sync with employeeCardExtent().
      maxScaleFactor: kEmployeeCardMaxTextScale,
      child: InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            // Was a hard-coded 77.sp, which is less than the three text lines
            // + padding actually need (~81.sp), hence the bottom overflow.
            // The grid tile supplies the real height via employeeCardExtent().
            constraints: BoxConstraints(minHeight: employeeCardExtent(context)),
            padding: EdgeInsets.only(left: 0, top: 10.sp, bottom: 10.sp, right: 10.sp),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: SvgPicture.asset(
                      (employee.gender ?? '').toString().toLowerCase() == 'male'
                          ? 'assets/icons_assets/main_icons_assets/male_avatar.svg'
                          : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
                      semanticsLabel: 'Gender Icon',
                      fit: BoxFit.cover,
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: _EmployeeTexts(
                    name: isEnglish
                        ? FormatHelper.capitalize("${employee.firstName} ${employee.lastName}")
                        : FormatHelper.capitalize("${employee.firstNameInArabic} ${employee.lastNameInArabic}"),
                    department: _getDepartmentName(context, isEnglish), // ✅ Pass department here
                    jobTitle: _getDisplayJobTitle(isEnglish),
                    isLightMode: isLightMode,
                  ),
                ),

              ],
            ),
          ),
          Positioned(
            top: 10.sp,
            right: 10.sp,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.only(bottom: 30.sp),
                child: CustomCheckBox(
                  isSelected: isSelected,
                  size: 20.sp,
                  borderColor: AppColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Height an [EmployeeCard] actually needs: 10.sp padding top/bottom around a
/// 14.sp name line and two 12.sp detail lines separated by 3.sp gaps.
///
/// Use this for the grid's `mainAxisExtent` instead of a magic number — the
/// text lines grow with both ScreenUtil's font scale and the device's
/// text-size setting, so a fixed value only ever fits one configuration.
double employeeCardExtent(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context)
      .scale(1.0)
      .clamp(1.0, kEmployeeCardMaxTextScale);

  const lineFactor = 1.45; // Cairo line-height
  final nameLine = 14.sp * lineFactor * scale;
  final detailLine = 12.sp * lineFactor * scale;

  final content = nameLine + 3.sp + detailLine + 3.sp + detailLine;
  const safety = 2.0; // sub-pixel rounding

  return 10.sp + content + 10.sp + safety;
}

/// Cap on the system font scale for employee cards, so an accessibility
/// setting can't push the card past the height the grid reserved.
const double kEmployeeCardMaxTextScale = 1.3;

class _EmployeeTexts extends StatelessWidget {
  const _EmployeeTexts({
    required this.name,
    required this.department, // ✅ Add department parameter
    required this.jobTitle,
    required this.isLightMode,
  });

  final String name;
  final String department; // ✅ Add this field
  final String jobTitle;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 3.sp),
        Text(
          department, // ✅ Now this is defined
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(height: 3.sp),
        Text(
          jobTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
