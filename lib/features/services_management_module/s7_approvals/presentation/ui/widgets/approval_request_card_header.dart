/// Module: services_management_module
/// Description: Header block for ApprovalRequestCard — service image/name
///              row plus the requester/date/department/job-title/duration
///              info rows. Pure display widget, no I/O. Extracted from
///              approval_request_card.dart to keep the parent file under
///              800 LOC (audit fix item 2).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: none beyond Flutter/ScreenUtil/AppColors/StyleText
/// Revision History: Initial version — extracted from
///                    approval_request_card.dart's `build()` method.
library;
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/widgets/build_info_row.dart';

/// Lines reserved for the department value. Kept next to the height
/// calculation below so the two can't drift apart.
const int kApprovalDepartmentMaxLines = 2;

/// Cap on the system font scale for approval cards.
const double kApprovalCardMaxTextScale = 1.3;

/// Real height of an [ApprovalRequestCard], for the grid's `mainAxisExtent`.
///
/// A hard-coded 245.sp assumed every info row was one line; the department
/// row wraps to two, which is where the 39px overflow came from.
double approvalCardExtent(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context)
      .scale(1.0)
      .clamp(1.0, kApprovalCardMaxTextScale);

  const lineFactor = 1.45; // Cairo line-height
  final line = 14.sp * lineFactor * scale;

  // 5 info rows (department gets kApprovalDepartmentMaxLines), each with
  // 4.sp bottom padding, separated by 5.h gaps.
  final infoRows = (4 * line) + (kApprovalDepartmentMaxLines * line);
  final rowPadding = 5 * 4.sp;
  final rowGaps = 4 * 5.h;

  final header = 40.sp; // service image + name row
  const safety = 4.0;

  return 15.h // container top padding
      + header
      + 10.h // two stacked SizedBox(height: 5.h)
      + infoRows
      + rowPadding
      + rowGaps
      + 8.h // trailing gap in the header column
      + (38.sp * scale) // action buttons / state badge
      + 15.h // breathing room at the bottom (container has no bottom padding)
      + safety;
}

class ApprovalRequestCardHeader extends StatelessWidget {
  final String? imageUrl;
  final String displayServiceName;
  final String displayRequesterName;
  final String displayDepartment;
  final String displayJobTitle;
  final String displayDuration;
  final DateTime dateRequested;
  final bool isArabic;

  const ApprovalRequestCardHeader({
    super.key,
    required this.imageUrl,
    required this.displayServiceName,
    required this.displayRequesterName,
    required this.displayDepartment,
    required this.displayJobTitle,
    required this.displayDuration,
    required this.dateRequested,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40.sp,
              height: 40.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        width: 40.sp,
                        height: 40.sp,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.secondaryText.withOpacity(.3),
                          highlightColor: AppColors.background.withOpacity(.5),
                          child: Container(
                            width: 40.sp,
                            height: 40.sp,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryText.withOpacity(.3),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return SvgPicture.asset(
                            'assets/icons_assets/services_assets/clock_dashed.svg',
                            width: 16.sp,
                            height: 16.sp,
                            color: AppColors.secondaryText,
                            fit: BoxFit.scaleDown,
                          );
                        },
                      ),
                    )
                  : SvgPicture.asset(
                      "assets/icons_assets/services_assets/headset_support.svg",
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.secondaryText,
                      fit: BoxFit.scaleDown,
                      semanticsLabel: 'Service Icon',
                    ),
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: Text(
                FormatHelper.capitalize(displayServiceName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        SizedBox(height: 5.h),
        InfoRowApproval(
          "assets/icons_assets/main_icons_assets/person_outline.svg",
          // ✅ FIX (bug report p37): the card labelled the person who raised the
          // request "Service Requester"; the approvals list calls this
          // "Requested By".
          "${S.of(context).requestedBy}: ",
          displayRequesterName,
        ),
        SizedBox(height: 5.h),
        InfoRowApproval(
          "assets/icons_assets/roles_assets/calendar.svg",
          "${S.of(context).DateRequested}: ",
          DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(dateRequested),
        ),
        SizedBox(height: 5.h),
        InfoRowApproval(
          "assets/icons_assets/services_assets/department_hierarchy_people.svg",
          "${S.of(context).Department}: ",
          displayDepartment,
          // Department names are long ("Information Technology") — allow a
          // second line. approvalCardExtent() reserves room for it.
          maxLines: kApprovalDepartmentMaxLines,
        ),
        SizedBox(height: 5.h),
        InfoRowApproval(
          "assets/icons_assets/main_icons_assets/Case.svg",
          "${S.of(context).jobTitle}: ",
          displayJobTitle,
        ),
        SizedBox(height: 5.h),
        InfoRowApproval(
          "assets/icons_assets/services_assets/clock_dashed.svg",
          "${S.of(context).durationOfService}: ",
          displayDuration,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
