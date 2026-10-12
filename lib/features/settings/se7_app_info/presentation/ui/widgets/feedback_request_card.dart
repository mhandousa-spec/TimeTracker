/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_request_card.dart
/// Purpose: One row of the "Request Details" list — what was submitted, when,
///          and where it stands.
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
///
/// Figma: MESBAH 7628:8180, the 265×91 card repeated four times. Icon and
/// title on the first line, "Date Requested: <date>" on the second, the status
/// on the third.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class FeedbackRequestCard extends StatelessWidget {
  const FeedbackRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  final FeedbackRequest request;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = FeedbackDisplay.statusColor(request.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CustomSvgImage(
                    assetPath: "assets/icons_assets/settings_assets/feedback_stamp.svg",
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    FeedbackDisplay.kindLabel(context, request.kind),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text),
                  ),
                ),
                if (request.attachments.isNotEmpty) ...<Widget>[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.attach_file_rounded,
                    size: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: <Widget>[
                CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                  width: 14.sp,
                  height: 14.sp,
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: 6.w),
                // 21/9/2026 — Settings bug report p.19: the date VALUE is
                // full-strength text (white in dark mode); only the label
                // stays secondary, like "Status:" below it.
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${S.of(context).dateRequested}: ',
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText),
                      children: <InlineSpan>[
                        TextSpan(
                          text: _formattedDate(context),
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.text),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: <Widget>[
                // ADDED 8/9/2026 — the status line was the only one of the
                // three without a leading icon, so its text started flush left
                // while the title and the date above it were both indented by
                // one. Same 14.sp size, secondaryText tint and 6.w gap as the
                // calendar icon directly above, so the two rows line up.
                CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/assets_status.svg',
                  width: 14.sp,
                  height: 14.sp,
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${S.of(context).status}: ',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
                Text(
                  FeedbackDisplay.statusLabel(context, request.status),
                  style:
                      StyleText.fontSize12Weight600.copyWith(color: statusColor),
                ),
                if (request.priority != null) ...<Widget>[
                  const Spacer(),
                  Text(
                    FeedbackDisplay.priorityLabel(context, request.priority!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The submission date, or a dash.
  ///
  /// A null `createdAt` is a server timestamp that has not resolved yet — the
  /// document was written seconds ago. Showing `DateTime.now()` there would
  /// print a date the server never agreed to; the dash is honest and resolves
  /// itself on the next read.
  String _formattedDate(BuildContext context) {
    final DateTime? createdAt = request.createdAt;
    if (createdAt == null) return '—';
    // `LocalizedDate.of` renders Arabic-Indic digits under an Arabic locale,
    // which the plain DateFormat the older cards use does not.
    return LocalizedDate.of(context, createdAt);
  }
}
