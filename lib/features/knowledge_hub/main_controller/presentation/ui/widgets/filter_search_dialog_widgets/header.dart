import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

Widget buildHeader(BuildContext context, bool lightMode) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 15.r,
          child: CustomSvgImage( color: AppColors.textButton ,assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_filter.svg', width: 16.w, height: 16.h),
        ),
        SizedBox(width: 12.w,),
        Text(
          S.of(context).filter,
          style: StyleText.fontSize16Weight500.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
      ],
    );
  }