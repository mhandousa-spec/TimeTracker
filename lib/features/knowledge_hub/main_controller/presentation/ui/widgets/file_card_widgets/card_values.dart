import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildInfoRow(
  BuildContext context, {
  required String label,
  required String value,
  required bool lightMode,
}) {
  return Row(
    children: [
      Text(
        label,
        style: StyleText.fontSize10Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
      ),
      // CHANGED 22/9/2026 — the VALUE drops to 8 while the label stays at 10.
      // Reported as "decrease size of the white words": on a card the value is
      // the long part (a department name), it is the high-contrast one in dark
      // mode, and at the same size as its label it crowded the row and pushed
      // longer department names into the ellipsis.
      Text(
        value,
        style: StyleText.fontSize8Weight400.copyWith(
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
