// ******************* FILE INFO *******************
// File Name: approval_cycle_widget
// Description: Approval cycle widget.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/48-custom_approval_shape.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/approval.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';


import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/approvals.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ApprovalCycleWidgetServices extends StatelessWidget {
  const ApprovalCycleWidgetServices({required this.approvalCycle, super.key});
  final List<EmployeeEntityModell> approvalCycle;

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    if (isMobile) {
      return buildApprovalCycle(context, approvalCycle, "assets/icons_assets/main_icons_assets/male_avatar.svg");
    } else {
      return approvalCycleViewTablet(approvalCycle, context);
    }
  }
}

Widget buildApprovalCycle(BuildContext context, List<EmployeeEntityModell> innerApprovalList, String? imagePerson) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final approvalList = innerApprovalList ?? [];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(approvalList.length, (index) {
      final item = approvalList[index];
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index != 0)
                Padding(
                  padding: EdgeInsets.only(left: 25.sp, right: 25.sp, bottom: 0.sp),
                  child: CustomPaint(
                    size: Size(0, 60),
                    painter: CurvedArrowPainter(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.whiteShadow,
                        isArabic: isArabic,
                    ),
                  ),
                )
              else
                SizedBox(width: 2.sp),
              Padding(
                padding: EdgeInsets.only(top: 10.sp),
                child: ClipOval(
                  child: SvgPicture.asset(
                    imagePerson!,
                    semanticsLabel: 'Dart Logo',
                    fit: BoxFit.scaleDown,
                    width: 25.sp,
                    height: 25.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Padding(
                padding: EdgeInsets.only(top: 12.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(isArabic
                          ? "${item.firstNameInArabic ?? ''} ${item.lastNameInArabic ?? ''}"
                          : "${item.firstName ?? ''} ${item.lastName ?? ''}"),
                      style: StyleText.fontSize12Weight500.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.blackButton
                              : AppColors.white),
                    ),
                    SizedBox(height: 3.sp),
                    Text(
                        FormatHelper.capitalize(isArabic ? item.titleInArabic ?? '' : item.title ?? ''),
                        style: StyleText.fontSize10Weight400.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.secondaryText
                                : AppColors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }),
  );
}

