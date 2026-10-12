// ******************* FILE INFO *******************
// File Name: comparison_chart.dart
// Description: Monthly comparison chart for canceled vs rejected services by department
// Created by: Amr Mesbah
// ✅ UPDATED: Bars centered under month labels using Row-based layout
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/DashBoard_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'comparison_chart_part2.dart';

class MonthlyComparisonChart extends StatefulWidget {
  final ChartOrientation orientation;
  final bool lightMode;

  const MonthlyComparisonChart({
    Key? key,
    this.orientation = ChartOrientation.vertical,
    required this.lightMode,
  }) : super(key: key);

  @override
  State<MonthlyComparisonChart> createState() => _MonthlyComparisonChartState();
}
