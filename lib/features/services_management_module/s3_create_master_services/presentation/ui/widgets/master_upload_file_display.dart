/// Module: services_management_module
/// Description: "Uploaded file" card (file name/size + edit/delete actions +
///              stat rows) shown once a step's Excel file has been parsed on
///              the master upload screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: CustomSvgImage, CustomEditIcon, CustomDeleteIcon, AppColors,
///              StyleText
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from master_upload.dart
///     (fix item 5 — page LOC reduction).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MasterUploadFileDisplay extends StatelessWidget {
  final String fileName;
  final String totalServicesLabel;
  final String totalServicesValue;
  final String totalDepartmentsLabel;
  final String totalDepartmentsValue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MasterUploadFileDisplay({
    super.key,
    required this.fileName,
    required this.totalServicesLabel,
    required this.totalServicesValue,
    required this.totalDepartmentsLabel,
    required this.totalDepartmentsValue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 280.w,
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.secondaryText.withOpacity(.5)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 50.sp,
                      height: 50.sp,
                      decoration: BoxDecoration(
                        color: AppColors.darkBackGround.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: CustomSvgImage(
                          assetPath:
                              'assets/icons_assets/form_builder_assets/excel_logo.svg',
                          width: 43.w,
                          height: 43.h,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.text,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Text(
                            '62 KB',
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            CustomEditIcon(
              color: AppColors.primary,
              borderColor: Colors.transparent,
              svgColor: AppColors.textButton,
              title: S.of(context).edit,
              textStyle: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.textButton,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              onTap: onEdit,
            ),
            SizedBox(width: 10.sp),
            CustomDeleteIcon(
              color: AppColors.red,
              borderColor: Colors.transparent,
              svgColor: AppColors.white,
              title: S.of(context).delete,
              textStyle: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              onTap: onDelete,
            ),
          ],
        ),
        SizedBox(height: 28.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatItem(
              icon: 'assets/icons_assets/services_assets/totoal services.svg',
              label: totalServicesLabel,
              value: totalServicesValue,
            ),
            SizedBox(height: 28.sp),
            _StatItem(
              icon:
                  'assets/icons_assets/services_assets/department_hierarchy_people.svg',
              label: totalDepartmentsLabel,
              value: totalDepartmentsValue,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(icon, width: 22.sp, height: 22.sp, color: AppColors.primary),
        SizedBox(width: 10.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "$label: ",
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
