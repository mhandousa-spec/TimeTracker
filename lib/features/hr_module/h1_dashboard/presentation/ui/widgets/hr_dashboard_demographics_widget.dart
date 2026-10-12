// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_demographics_widget.dart
// Purpose: Arranges demographic dashboard charts responsively.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'hr_dashboard_gender_widget.dart';
import 'hr_dashboard_marital_status_widget.dart';

class HRDashboardDemographicsWidget extends StatelessWidget {
  const HRDashboardDemographicsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final charts = [
          const HRDashboardGenderWidget(),
          const HRDashboardMaritalStatusWidget(),
        ];
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              charts[0],
              SizedBox(height: 16.h),
              charts[1],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: charts[0]),
            SizedBox(width: 16.w),
            Expanded(child: charts[1]),
          ],
        );
      },
    );
  }
}
