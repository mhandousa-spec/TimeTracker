/// Module: knowledge_hub / presentation / s6_approvals / widgets/approvals_document_card.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_document_card.dart
/// Purpose: Approvals document card — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
// ADDED 2/9/2026 — the Approve / Reject tier check.
import '../../../../main_controller/helper/knowledge_hub_permissions.dart';

Widget approvalsDocumentCard(
    BuildContext context, {
      required String status,
      required Color statusColor,
      required String fileExtension,
      String? fileImage,
      required String fileName,
      required String department,
      required String requestedBy,
      required String jobTitle,
      DateTime? uploadDate,
      DateTime? lastEditDate,
      VoidCallback? onApprove,
      VoidCallback? onReject,
    }) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  String getFileIcon(String extension) {
    final ext = extension.toLowerCase().trim();

    switch (ext) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
      case 'doc':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'docx':
        return 'assets/icons_assets/knowledge_hub_assets/docx_icon.svg';
      case 'xls':
      case 'xlsx':
      case 'csv':
        return 'assets/icons_assets/knowledge_hub_assets/xls_icon.svg';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      default:
        return 'assets/icons_assets/knowledge_hub_assets/view_icon.svg';
    }
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    debugPrint('🔍 DEBUG _getStatusInfo:');
    debugPrint('   Received status: "$status"');

    String statusLower = status.toLowerCase().trim();

    switch (statusLower) {
      case 'rejected':
        return {
          'text': S.of(context)!.rejected,
          'color': AppColors.red,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/assets_reject.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

    // ✅ CHANGED: Show "Approved" for published status
      case 'published':
      case 'approved':
        return {
          'text': S.of(context)!.approved,  // Show "Approved" not "Published"
          'color': AppColors.lightGreen,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/images_approve.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'pending_approval':
      case 'pending':
      case 'scheduled':
        return {
          'text': S.of(context)!.pending,
          'color': AppColors.orange,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/state_pending.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'removed':
        return {
          'text': S.of(context)!.removed,
          'color': KnowledgeHubColors.redCrimson,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/removed.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      default:
        return {
          'text': status,
          'color': AppColors.primary,
          'widget': Icon(Icons.info, color: AppColors.primary, size: 24.sp),
        };
    }
  }

  // Format date
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  final statusInfo = _getStatusInfo(status);
  final isMobile = ResponsivePage.isMobile(context);

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4.r),
      color: lightMode ? AppColors.white : AppColors.chatBackground,
    ),
    padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File icon and name
        Row(
          children: [
            fileImage == null
                ? CustomSvgImage(
              assetPath: getFileIcon(fileExtension),
              height: 50.h,
              width: 50.w,
              fit: BoxFit.cover,
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                height: 50.h,
                width: 50.w,
                child: Image.network(
                  fileImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return CustomSvgImage(
                      assetPath: getFileIcon(fileExtension),
                      height: 50.h,
                      width: 50.w,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                fileName,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.sp),

        // Requested By
        Row(
          children: [
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/details_User Plus.svg',
              height: 16.sp,
              width: 16.sp,
              fit: BoxFit.cover,
                color:  AppColors.secondaryText.withOpacity(.7)
            ),
            SizedBox(width: 3.w),
            Text(
              '${S.of(context)!.requestedBy}: ',
              style: StyleText.fontSize14Weight400.copyWith(
                color:  AppColors.secondaryText.withOpacity(.7)
              ),
            ),
            Expanded(
              child: Text(
                requestedBy,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),

        // Date Requested
        Row(
          children: [
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
              height: 16.h,
              width: 16.w,
              fit: BoxFit.cover,
                color:  AppColors.secondaryText.withOpacity(.7)

            ),
            SizedBox(width: 3.w),
            Text(
              '${S.of(context)!.requestedDate}: ',
              style: StyleText.fontSize14Weight400.copyWith(
                  color:  AppColors.secondaryText.withOpacity(.7)

              ),
            ),
            Text(
              formatDate(uploadDate),
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),

        // Department
        Row(
          children: [
            CustomSvgImage(
              assetPath: 'assets/icons_assets/knowledge_hub_assets/departments_analytics_icon.svg',
              height: 16.h,
              width: 16.w,
              fit: BoxFit.cover,
                color:  AppColors.secondaryText.withOpacity(.7)

            ),
            SizedBox(width: 3.w),
            Text(
              '${S.of(context).department}: ',
              style: StyleText.fontSize14Weight400.copyWith(
                  color:  AppColors.secondaryText.withOpacity(.7)

              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Text(
                department,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),

        // Job Title
        Row(
          children: [
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/svg_Case.svg',
              height: 16.h,
              width: 16.w,
              fit: BoxFit.cover,
                color:  AppColors.secondaryText.withOpacity(.7)

            ),
            SizedBox(width: 3.w),
            Text(
              '${FormatHelper.capitalize(S.of(context).jobTitle)}: ',
              style: StyleText.fontSize14Weight400.copyWith(
                  color:  AppColors.secondaryText.withOpacity(.7)

              ),
            ),
            Expanded(
              child: Text(
                FormatHelper.capitalize(jobTitle),
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.sp),

        // Status
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/assets_status.svg',
              height: 16.h,
              width: 16.w,
              fit: BoxFit.cover,
                color:  AppColors.secondaryText.withOpacity(.7)

            ),
            SizedBox(width: 3.w),
            Text(
              '${S.of(context)!.status}: ',
              style: StyleText.fontSize14Weight400.copyWith(
                  color:  AppColors.secondaryText.withOpacity(.7)

              ),
            ),
            Text(
              statusInfo['text'],
              style: StyleText.fontSize14Weight400.copyWith(
                color: statusInfo['color'],
              ),
            ),
          ],
        ),

        SizedBox(height: 10.sp),

        // Action buttons or status badge
        //
        // GATED 2/9/2026 on [KnowledgeHubAccess.approvalAccess] as well as the
        // status. The status test alone offered Approve and Reject on every
        // pending card to anyone who could open the approvals list, which is
        // why the role editor's two approval switches appeared to do nothing.
        //
        // `canApprove` guards the whole row: on the approve-only tier Reject is
        // dropped and Approve takes the full width; on `none` no row is built.
        if (KnowledgeHubAccess.approvalAccess.canApprove &&
            (status.toLowerCase() == 'pending' || status.toLowerCase() == 'pending_approval' || status.toLowerCase() == 'scheduled'))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (KnowledgeHubAccess.approvalAccess.canReject) ...[
              Expanded(
                child: customButtonWithSvg(
                  title: S.of(context).reject,
                  function: onReject ?? () {},
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.red,
                  ),
                  height: 36,
                  space: 8.w,
                  radius: 8.r,
                  color: lightMode
                      ? AppColors.white
                      : AppColors.chatBackground,
                  image: 'assets/icons_assets/knowledge_hub_assets/assets_reject.svg',
                  widthImage: 24.w,
                  heightImage: 24.h,
                  colorBorder: AppColors.red,
                  width: isMobile ? 150.sp : !ContextExtension(context).isTabletLandscape ? 140.w : 125.w,
                ),
              ),
              SizedBox(width: 10.w),
              ],
              Expanded(
                child: customButtonWithSvg(
                  title: S.of(context)!.approve,
                  function: onApprove ?? () {},
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.lightGreen,
                  ),
                  height: 36,
                  space: 8.w,
                  radius: 8.r,
                  color: lightMode
                      ? AppColors.white
                      : AppColors.chatBackground,
                  image: 'assets/icons_assets/knowledge_hub_assets/images_approve.svg',
                  widthImage: 24.w,
                  heightImage: 24.h,
                  colorBorder: AppColors.lightGreen,
                ),
              ),
            ],
          )
        else
// ✅ Status badge for non-pending items
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: lightMode
                  ? AppColors.white
                  : AppColors.chatBackground,
              border: Border.all(color: statusInfo['color'], width: 2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // ✅ DEBUG: Always show icon to test
                Container(
                  width: 24.sp,
                  height: 24.sp,
                  child: statusInfo['widget'],
                ),
                SizedBox(width: 8.w),
                // ✅ Status text
                Text(
                  statusInfo['text'],
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: statusInfo['color'],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}