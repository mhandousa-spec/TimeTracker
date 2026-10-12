/// Module: GRC shared widgets
/// Description: The outlined request-status pill (icon + label) MAGDY draws
///              on the GRC Requests cards. Shared so the Requests list and
///              the Request Details page show the exact same status UI.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
/// Dependencies: CustomSvgImage (32), grc_approval_status_style, grc_l10n
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_approval_status_style.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';

/// class name: [GrcRequestStatusPill]
///
/// purpose: white pill with a coloured border, the status icon and the
///          translated status name (Approved / Pending / Rejected /
///          Canceled), 95 wide.
class GrcRequestStatusPill extends StatelessWidget {
  final ApprovalStatus status;

  /// The Request Details size: 200×36, 8 padding, 8 spacing, radius 8,
  /// 1px border -- the MAGDY spec. False keeps the 95-wide card pill.
  final bool large;

  const GrcRequestStatusPill({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = status.color;
    final String? icon = switch (status) {
      ApprovalStatus.approved =>
        'assets/icons_assets/main_icons_assets/status_approved_check_green.svg',
      ApprovalStatus.rejected =>
        'assets/icons_assets/main_icons_assets/status_blocked_circle_red.svg',
      ApprovalStatus.pending =>
        'assets/icons_assets/main_icons_assets/status_pending_check_cross_orange.svg',
      _ => null,
    };
    return Container(
      width: large ? 200.w : 95.w,
      height: large ? 36.h : null,
      padding: large
          ? EdgeInsets.all(8.sp)
          : EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(
          color: color,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(large ? 8.r : 5.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            CustomSvgImage(
              assetPath: icon,
              width: large ? 20.sp : 14.sp,
              height: large ? 20.sp : 14.sp,
            ),
            SizedBox(width: large ? 8.w : 6.w),
          ],
          Flexible(
            child: Text(
              grcTr(context, status.getName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (large
                      ? StyleText.fontSize14Weight400
                      : StyleText.fontSize10Weight400)
                  .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
