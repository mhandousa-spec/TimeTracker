// ******************* FILE INFO *******************
// File Name: build_info_row
// Description: Build info row.
// Module: services_management_module / presentation/s7_approvals/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';


class InfoRowApproval extends StatelessWidget {
  final String? image;
  final String? title;
  final String? value;

  /// How many lines the value may occupy before it ellipsises.
  ///
  /// Defaults to 1. This used to be unbounded, so a long value (e.g. an
  /// "Information Technology" department) silently wrapped onto a second line
  /// and pushed the card past the grid's fixed mainAxisExtent.
  /// Any caller allowing >1 must be reflected in approvalCardExtent().
  final int maxLines;

  const InfoRowApproval(
      this.image,
      this.title,
      this.value, {
        super.key,
        this.maxLines = 1,
      });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.sp),
      child: Row(
        children: [
          if (image != null)
            SvgPicture.asset(
              image!,
              width: 16.sp,
              height: 16.sp,
              color: AppColors.secondaryText,
            ),
          if (image != null) SizedBox(width: 6.sp),
          if (title != null)
            Text(
              "$title ",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode ? AppColors.secondaryText : AppColors.grey,
              ),
            ),
          Expanded(
            child: Text(
              FormatHelper.capitalize(value ?? "-"),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode ? AppColors.blackButton : AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
