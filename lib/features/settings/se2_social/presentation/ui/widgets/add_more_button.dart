/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: add_more_button.dart
/// Purpose: The "+ More" button that appends a row to the skills, hobbies and
///          academic-history lists.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N17. The same button was copy-pasted into three
/// widgets, each with a raw `Colors.black` container, a raw `Colors.white` icon
/// and an inline `TextStyle(color: …, fontSize: 14.sp, …)` instead of a theme
/// text style. One copy now, routed through AppColors and StyleText.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AddMoreButton extends StatelessWidget {
  const AddMoreButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isPhone ?  15.sp : 0.sp),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 6.sp),
          decoration: BoxDecoration(
            color: AppColors.chipDark,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.add, color: AppColors.white, size: 18.sp),
              SizedBox(width: 8.sp),
              Text(
                S.of(context).more,
                style:
                    StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
