import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';

import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

// ignore: must_be_immutable
class CustomChartDataRow extends StatefulWidget {
  CustomChartDataRow(
      {super.key,
      required this.dataColor,
      required this.textData,
      required this.valueData,
      required this.isHorizontal,
      this.isPerformanceScreen,
      this.isSmallContainer,
      this.width});
  Color dataColor;
  String textData;
  bool isHorizontal;
  bool? isPerformanceScreen;
  bool? isSmallContainer;
  double? width;
  double valueData;

  @override
  State<CustomChartDataRow> createState() => _CustomChartDataRowState();
}

class _CustomChartDataRowState extends State<CustomChartDataRow> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsetsDirectional.only(
          start: isTablet
              ? isPortrait
                  ? 0.015.h
                  : 0.02.h
              : 0.02.h),
      child: Row(
        children: [
          if (isTablet)
            const CircleAvatar(
              backgroundColor: AppColors.transparent,
              radius: 13,
            ),
          SizedBox(
            width: isTablet ? 138 : 110,
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 7,
                  backgroundColor: widget.dataColor,
                ),
                horizontalSpace(8),
                Expanded(
                  child: Text(
                    widget.textData,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.spanText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(widget.valueData.toInt().formatNumber(),
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
