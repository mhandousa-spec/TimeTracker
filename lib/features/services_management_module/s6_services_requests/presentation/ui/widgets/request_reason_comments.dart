// ******************* FILE INFO *******************
// File Name: request_reason_comments
// Description: Displays the cancellation / rejection / approval reason rows for
//              a request (each shown only when its text is present). Extracted
//              from MyRequestDetails.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

class RequestReasonComments extends StatelessWidget {
  final String? cancelReason;
  final String rejectCommentText;
  final String approveCommentText;
  final bool isMobile;

  const RequestReasonComments({
    Key? key,
    required this.cancelReason,
    required this.rejectCommentText,
    required this.approveCommentText,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cancelReason != null && cancelReason!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 5.sp),
                  child: SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                    width: 16.sp,
                    height: 16.sp,
                    fit: BoxFit.cover,
                    color: AppColors.red,
                  ),
                ),
                SizedBox(width: 6.sp),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.red
                            : AppColors.whiteShadow,
                      ),
                      children: [
                        TextSpan(
                          text: "${S.of(context).ReasonOfCancelation}: ",
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.red,
                          ),
                        ),
                        TextSpan(
                          text: FormatHelper.capitalize(cancelReason!),
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness ==
                                    Brightness.light
                                ? AppColors.blackButton
                                : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (rejectCommentText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                  width: isMobile ? 12.sp : 16.sp,
                  height: isMobile ? 12.sp : 16.sp,
                  color: AppColors.red,
                ),
                SizedBox(width: 6.sp),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.red,
                      ),
                      children: [
                        TextSpan(
                          text: "${S.of(context).ReasonOfRejection}: ",
                          style: isMobile
                              ? StyleText.fontSize12Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.red)
                              : StyleText.fontSize14Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.red),
                        ),
                        TextSpan(
                          text: FormatHelper.capitalize(rejectCommentText),
                          style: isMobile
                              ? StyleText.fontSize12Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text)
                              : StyleText.fontSize14Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (approveCommentText.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                  width: isMobile ? 12.sp : 16.sp,
                  height: isMobile ? 12.sp : 16.sp,
                  color: AppColors.lightGreen,
                ),
                SizedBox(width: 6.sp),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.lightGreen,
                      ),
                      children: [
                        TextSpan(
                          text: "${S.of(context).ReasonOfApprove}: ",
                          style: isMobile
                              ? StyleText.fontSize12Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green)
                              : StyleText.fontSize14Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green),
                        ),
                        TextSpan(
                          text: FormatHelper.capitalize(approveCommentText),
                          style: isMobile
                              ? StyleText.fontSize12Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text)
                              : StyleText.fontSize14Weight500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
