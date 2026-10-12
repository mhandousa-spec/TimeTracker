/// ******************* FILE INFO *******************
/// File Name: custom_button_with_image.dart
/// Description: this is custom Button with image for reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

Widget customButtonWithImage({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width,
  double? height,
  double? space,
  double? radius,
  Color? color,
  required String image,
  double? widthImage,
  double? heightImage,
  Color? colorBorder,
  Color? svgColor, // ✅ optional color
}) {
  return GestureDetector(
    onTap: function,
    child: Container(
      width: width ?? 135.sp,
      height: height ?? 38.sp,
      decoration: BoxDecoration(
        color: color,

        borderRadius: BorderRadius.circular(radius ?? 8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              image,
              height: heightImage?.h?? 20.sp,
              width: widthImage?.w?? 20.sp,
              color: svgColor ?? AppColors.textButton,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(width: space ?? 8.sp),
          Text(title, style: textStyle),
        ],
      ),
    ),
  );
}