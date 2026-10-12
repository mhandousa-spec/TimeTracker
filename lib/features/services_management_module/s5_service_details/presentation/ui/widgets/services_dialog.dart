// ******************* FILE INFO *******************
// File Name: services_dialog
// Description: Services dialog.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class OurServicesDialog extends StatelessWidget {
  const OurServicesDialog({
    super.key,
    required this.color,
    required this.image,
    required this.title,
    required this.number,
    this.crossAxisAlignment = CrossAxisAlignment.center, // ✅ Added parameter with default
  });

  final Color color;
  final String image;
  final String title;
  final String number;
  final CrossAxisAlignment crossAxisAlignment; // ✅ New parameter

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    return Row(
      crossAxisAlignment: crossAxisAlignment, // ✅ Use the parameter
      children: [
        SvgPicture.asset(
          image,
          width: 30.w,
          height: 30.h,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 8.w),
        Container(
          width: isMobile ? 70.w : 130.w,
          child: Text(
            FormatHelper.capitalize(title),
            style: isMobile
                ? StyleText.fontSize12Weight500.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.secondaryText
                  : AppColors.grey,
            )
                : StyleText.fontSize16Weight500.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),
          ),
        ),
        Spacer(),
        Text(
          FormatHelper.capitalize(number),
          style: isMobile
              ? StyleText.fontSize20Weight600.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.blackButton
                : AppColors.white,
          )
              : StyleText.fontSize22Weight600.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
      ],
    );
  }
}
