/// Module: services_management_module
/// Description: Monthly comparison chart showing canceled vs rejected
///              services across 12 months, with a service-name filter
///              dropdown. All Firestore I/O lives in ServicesDashboardCubit
///              (data/repository/department+parent-service resolution); this
///              widget only reads cubit state and renders the fl_chart bars.
/// Author: Amr Mesbah / Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, ServicesDashboardCubit, fl_chart
/// Revision History: 17/01/2026 (Amr Mesbah) — changed from collectionGroup
///                    to RequestServices collection.
///                    2026-07-02 (Knowticed Team) — audit fix item 3: moved
///                    `_loadData()` (CreateServices + RequestServices reads,
///                    department/parent-service resolution) into
///                    ServicesDashboardCubit.
library;
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/service_repository_impl.dart';
import 'package:knowticed_plus/features/services_management_module/s8_dashboard/presentation/controller/services_dashboard_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s8_dashboard/presentation/controller/services_dashboard_state.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'services_dashboard_part2.dart';

class MonthlyComparisonServicesChart extends StatefulWidget {
  final ChartOrientation orientation;
  final bool lightMode;

  const MonthlyComparisonServicesChart({
    Key? key,
    this.orientation = ChartOrientation.vertical,
    required this.lightMode,
  }) : super(key: key);

  @override
  State<MonthlyComparisonServicesChart> createState() => _MonthlyComparisonServicesChartState();
}
