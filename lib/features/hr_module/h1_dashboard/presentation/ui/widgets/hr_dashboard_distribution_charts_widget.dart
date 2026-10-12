// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_distribution_charts_widget.dart
// Purpose: Groups HR dashboard distribution chart widgets.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'hr_dashboard_employees_per_location_widget.dart';
import 'hr_dashboard_nationalities_widget.dart';
import 'hr_dashboard_department_employees_widget.dart';

class HRDashboardDistributionChartsWidget extends StatelessWidget {
  const HRDashboardDistributionChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HRDashboardEmployeesPerLocationWidget(),
        SizedBox(height: 16.h),
        const HRDashboardNationalitiesWidget(),
        SizedBox(height: 16.h),
        const HRDashboardDepartmentEmployeesWidget(),
      ],
    );
  }
}
