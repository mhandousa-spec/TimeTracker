import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildDateInfo(
  BuildContext context,
  String label,
  String date,
  bool lightMode,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
          color: lightMode
              ? AppColors.secondaryText
              : AppColors.grey,
        ),
      ),
      Text(
        date,
        style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
