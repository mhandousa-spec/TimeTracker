/// Module: services_management_module
/// Description: Standalone approval-cycle mock widget — a static 5-step
///              placeholder chain (no real approval-cycle data wired in;
///              see w2_approval_cycle usage elsewhere / approvals.dart for
///              the real, model-backed approval cycle rendering).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: AppColors, StyleText, S (l10n)
/// Revision History: Replaced raw TextStyle(fontSize: 10.sp) with
///                    StyleText.fontSize10Weight400 and hardcoded
///                    "Ahmed Abd el Rahman" with a named mock-data constant
///                    (audit fix item 4b/4c) — TODO: promote to a real
///                    localized/model-backed name if this widget is wired
///                    to live data.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApprovalCycleWidget extends StatelessWidget {
  const ApprovalCycleWidget({super.key});

  // TODO(l10n): mock display name — this widget has no real
  // approval-cycle data source wired in yet (see file header).
  static const String _mockApproverName = 'Ahmed Abd el Rahman';

  @override
  Widget build(BuildContext context) {
    return approvalCycleView(context);
  }
  Widget approvalCycleView(BuildContext context) {
    final items = List.generate(5, (index) => index);
    final itemsPerRow = 3;

    // Break items into rows
    final rows = <List<int>>[];
    for (var i = 0; i < items.length; i += itemsPerRow) {
      rows.add(items.sublist(i, (i + itemsPerRow).clamp(0, items.length)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows.length, (rowIndex) {
        final rowItems = rows[rowIndex];

        return Padding(
          padding: EdgeInsets.only(top: rowIndex == 0.h ? 0.h : 10.h, left: rowIndex == 0.w ? 0.w : 30.w),
          child: Row(
            children: List.generate(rowItems.length, (i) {
              final index = rowItems[i];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(image: AssetImage('assets/icons_assets/services_assets/images_Ellipse 225.png'),width: 35.w,height: 35.h,fit: BoxFit.fill,),
                  SizedBox(width: 4.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_mockApproverName, style: StyleText.fontSize10Weight400),
                      Text(S.of(context).department_hr, style: StyleText.fontSize14Weight400.copyWith(fontSize: 10.sp, color: AppColors.red)),
                    ],
                  ),
                  if (index != items.length - 1) // skip arrow after last
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Icon(Icons.arrow_forward, size: 30.sp),
                    ),
                ],
              );
            }),
          ),
        );
      }),
    );
  }
}
