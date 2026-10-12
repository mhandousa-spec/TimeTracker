/// Module: GRC Module Management
/// Description: Provides the status toggle row shown above the form in edit
///              mode, allowing the user to switch a GRC Module between Active
///              and Inactive.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, FlutterSwitch
/// Revision History: 2026-06-29 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_status_switch.dart
/// Purpose: Contains GrcStatusSwitch, a small row widget with a FlutterSwitch
///          for toggling GRC Module status in edit mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcStatusSwitch]
///
/// purpose: renders a labeled toggle row for the GRC Module status field.
///          Shown only in edit mode; tapping the switch triggers [onToggle]
///          so the parent can show a confirmation dialog before committing.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
class GrcStatusSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onToggle;

  /// The record's ACTUAL status, shown beside the toggle.
  ///
  /// The toggle is two-state but the status is four-state, and 'Scheduled'
  /// now reads as ON alongside 'Active' (see _isEnabledStatus in
  /// grc_details_page.dart — Scheduled is active-pending, not inactive).
  /// Without this label an ON switch is ambiguous: the user cannot tell a
  /// module that is live from one that starts next week.
  ///
  /// Optional, so any caller that has not got a status to hand renders exactly
  /// what it did before.
  final String? statusLabel;

  const GrcStatusSwitch({
    super.key,
    required this.value,
    required this.onToggle,
    this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset('assets/icons_assets/data_grc_assets/icons_status.svg'),
            SizedBox(width: 10.w),
            Text(S.of(context).status,  style: StyleText.fontSize14Weight600
                .copyWith(color: AppColors.secondaryText),),
            // if (statusLabel != null) ...[
            //   SizedBox(width: 6.w),
            //   Text(
            //     statusLabel!,
            //     style: StyleText.fontSize14Weight600
            //         .copyWith(color: AppColors.secondaryText),
            //   ),
            // ],
            SizedBox(width: 10.w),
            FlutterSwitch(
              width: 38.sp,
              height: 22.sp,
              padding: 3.sp,
              borderRadius: 20.sp,
              toggleSize: 16.sp,
              activeColor: AppColors.secondaryPrimary,
              inactiveColor: Colors.grey.withOpacity(.16),
              value: value,
              onToggle: onToggle,
            ),
          ],
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
