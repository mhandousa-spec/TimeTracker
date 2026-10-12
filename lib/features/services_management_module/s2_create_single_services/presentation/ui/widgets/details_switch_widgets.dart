// ******************* FILE INFO *******************
// File Name: details_switch_widgets.dart
// Description: All widgets for Details Switch Screen
// Created by: Amr Mesbah
// Last Update: 01/12/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/core/custom/48-custom_approval_shape.dart';
import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/custom_select_chip.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/employee_card_item.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';


part 'details_switch_widgets_part2.dart';

class ValidationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String lottiePath;

  const ValidationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.lottiePath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottiePath,
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20.sp),
              Text(
                title,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String lottiePath;
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final String noText;
  final String yesText;

  const ConfirmationDialog({
    super.key,
    required this.lottiePath,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.noText,
    required this.yesText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: SizedBox(
          width: 411.sp,
          height: 210.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottiePath,
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20.sp),
              Text(
                title,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton(
                      title: noText,
                      function: () {
                        Navigator.pop(context);
                      },
                      textStyle: StyleText.fontSize15Weight400.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      width: 120.sp,
                      height: 38.sp,
                      radius: 4.r,
                      color: AppColors.secondaryAction,
                    ),
                    SizedBox(width: 15.sp),
                    customButton(
                      title: yesText,
                      function: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      textStyle: StyleText.fontSize15Weight400.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 120.sp,
                      height: 38.sp,
                      radius: 4.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApprovalPerson extends StatelessWidget {
  final EmployeeEntityPro employee;
  final bool isEnglish;

  const ApprovalPerson({
    super.key,
    required this.employee,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: CircleAvatar(
            radius: 25.r,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: SvgPicture.asset(
                employee.gender == "male" ? 'assets/icons_assets/main_icons_assets/male_avatar.svg' : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
                semanticsLabel: 'Gender Icon',
                fit: BoxFit.cover,
                width: 35.sp,
                height: 35.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FormatHelper.capitalize(
                '${isEnglish ? employee.firstName ?? '' : employee.firstNameInArabic ?? ''} ${isEnglish ? employee.lastName ?? '' : employee.lastNameInArabic ?? ''}',
              ),
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
            Text(
              FormatHelper.capitalize(
                isEnglish ? employee.title ?? '' : employee.titleInArabic ?? '',
              ),
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LimitAvailabilitySection extends StatelessWidget {
  final bool limitAvailability;
  final bool isArabic;
  final ValueChanged<bool> onToggle;
  final List<String> selectedDepartments;
  final List<String> departments;
  final double width;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const LimitAvailabilitySection({
    super.key,
    required this.limitAvailability,
    required this.isArabic,
    required this.onToggle,
    required this.selectedDepartments,
    required this.departments,
    required this.width,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: isMobile ? null : 200.sp,
                    child: Text(
                      FormatHelper.capitalize(
                        S.of(context).limitServiceAvailability,
                      ),
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Spacer(),
                  Transform(
                    alignment: Alignment.center,
                    transform: isArabic
                        ? Matrix4.rotationY(3.14159)
                        : Matrix4.identity(),
                    child: FlutterSwitch(
                      activeColor: AppColors.secondaryPrimary,
                      height: 22.sp,
                      width: 38.sp,
                      padding: 3.sp,
                      borderRadius: 20.sp,
                      toggleSize: 22.sp,
                      value: limitAvailability,
                      onToggle: onToggle,
                    ),
                  ),
                ],
              ),
              if (limitAvailability) ...[
                SizedBox(height: 15.sp),
                SelectChip(
                  departments: departments,
                  selectedDepartments: selectedDepartments,
                  width: isMobile
                      ? MediaQuery.sizeOf(context).width
                      : MediaQuery.sizeOf(context).width * .3,
                  triggerHeight: 36.sp,
                  color: AppColors.background,
                  onAdd: onAdd,
                  onRemove: onRemove,
                ),
              ],
            ],
          ),
        ),
        isMobile ? SizedBox() : Expanded(flex: 2, child: Column()),
      ],
    );
  }
}

class RequireApprovalSection extends StatelessWidget {
  final bool requireApproval;
  final bool isArabic;
  final ValueChanged<bool> onToggle;

  const RequireApprovalSection({
    super.key,
    required this.requireApproval,
    required this.isArabic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    return Row(
      children: [
        SizedBox(
          width: isMobile ? null : 200.sp,
          child: Text(
            FormatHelper.capitalize(
              S.of(context).requiresApprovals,
            ),
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
        Spacer(),
        Transform(
          alignment: Alignment.center,
          transform: Directionality.of(context) == TextDirection.rtl
              ? Matrix4.rotationY(3.14159)
              : Matrix4.identity(),
          child: FlutterSwitch(
            activeColor: AppColors.secondaryPrimary,
            height: 22.sp,
            width: 38.sp,
            padding: 3.sp,
            borderRadius: 20.sp,
            toggleSize: 22.sp,
            value: requireApproval,
            onToggle: onToggle,
          ),
        ),
      ],
    );
  }
}
