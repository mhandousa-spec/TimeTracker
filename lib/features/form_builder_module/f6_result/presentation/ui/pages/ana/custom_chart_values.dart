import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
// ignore: must_be_immutable
class CustomChartDataValues extends StatefulWidget {
  CustomChartDataValues(
      {super.key,
      this.detailsProgress,
      this.isHorizontal,
      required this.valueText,
      this.isPerformanceScreen,
      this.isSmall});
  bool? detailsProgress;
  bool? isHorizontal;
  String valueText;
  bool? isPerformanceScreen;
  bool? isSmall;

  @override
  State<CustomChartDataValues> createState() => _CustomChartDataValuesState();
}

class _CustomChartDataValuesState extends State<CustomChartDataValues> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Row(
      children: [
        isTablet
            ? SizedBox(width: isPortrait? 0.025.w:0.025.h)
            : Icon(
                Icons.circle,
                size: 0.012.h,
                color: AppColors.transparent,
              ),
        isTablet ? const SizedBox.shrink() : SizedBox(width: isPortrait? 0.01.h:0.01.w),
        Text(
          Get.locale.toString().contains('en')
              ? widget.valueText
              : ArabicDigits(
                  widget.valueText).toArabicNumbers(), //widget.values[i] + ' Projects'.tr,
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack),
        ),
      ],
    );
  }
}
