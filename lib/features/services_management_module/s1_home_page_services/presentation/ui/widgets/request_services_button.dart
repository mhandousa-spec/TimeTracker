// ******************* FILE INFO *******************
// File Name: request_services_button
// Description: Request services button.
// Module: services_management_module / presentation/s1_home_page_services/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';


import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/pages/employee_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s8_dashboard/presentation/ui/pages/dashboard_management_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/widgets/home_services_action_button_metrics.dart';



Widget approvalAndServicesRequest(BuildContext context) {
  final isTablet = ContextExtension(context).isTablet;
  final isMobile = ContextExtension(context).isPhone;
  final isLandscape = ContextExtension(context).isLandscape;
  return Row(
    mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.start,
    children: [


      // Service Requests
      if (ServicesModuleAccess.canRequestService) ...[
        customButton(
          title: S.of(context).serviceRequests,
          function: () {
            // W28: use the shared navigation helper instead of inline Navigator.push.
            navigateTo(context, RequestServicesToggle());
          },
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          width: isMobile ? 160.w : 160.w,
          height: 38.h,
          radius: 8.r,
          color: AppColors.primary,
        ),

        SizedBox(width: 15.sp),
      ],

      // Req Services
      isMobile || !ServicesModuleAccess.canViewRequestedServices
          ? SizedBox()
          : Row(
          children: [
            customButton(
              title: S.of(context).requestedServices,
              function: () {
                navigateTo(context, EmployeeLayoutScreenServices());
              },
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              height: 38.h,
              radius: 8.r,
              color: AppColors.primary,
            ),
            SizedBox(width: 10.w),
          ],
        ),



      Spacer(),



      // ✅ FIX: Dashboard/Approvals sit directly under Bulk Upload/Admin
      // Dashboard and both rows are right-aligned, so the four buttons read as
      // a 2x2 grid. They used to carry their own widths (134/135 vs 135/170)
      // and a `.sp` gutter against the other row's `.w` one, leaving the
      // columns visibly stepped. Shared metrics keep the edges flush.
      if (ServicesModuleAccess.canViewDepartmentDashboard) ...[
        customButton(
          title: S.of(context).dashboard,
          function: () {
            navigateTo(context, DashBordLayout());
          },
          textStyle: HomeServicesActionButtons.labelStyle(context),
          // exactWidth, not width — customButton discards `width`.
          exactWidth:
              isMobile ? null : HomeServicesActionButtons.leadingWidth(context),
          color: AppColors.primary,
        ),

        isMobile
            ? const SizedBox.shrink()
            : SizedBox(width: HomeServicesActionButtons.columnGap),
      ],

     // Approval
     !isMobile && ServicesModuleAccess.canApproveAndReject
         ?   customButton(
        title: S.of(context).approvals,
        function: () {
          navigateTo(context, ApprovalToggle());
        },
        textStyle: HomeServicesActionButtons.labelStyle(context),
        exactWidth: HomeServicesActionButtons.trailingWidth(context),
        color: AppColors.primary,
      ) : const SizedBox.shrink(),
    ],
  );
}
