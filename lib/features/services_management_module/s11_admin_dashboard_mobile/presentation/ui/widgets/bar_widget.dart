// ******************* FILE INFO *******************
// File Name: bar_widget
// Description: Bar widget.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

BarChartGroupData buildBarGroups(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        width: 30.sp,
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6.r),
      ),
    ],
    showingTooltipIndicators: [0],
  );
}
