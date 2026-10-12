// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/ana/custom_employee_doughnut_chart.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class StatisticsManagerTablet extends StatefulWidget {
  const StatisticsManagerTablet({super.key});

  @override
  State<StatisticsManagerTablet> createState() =>
      _StatisticsManagerTabletState();
}

class _StatisticsManagerTabletState extends State<StatisticsManagerTablet> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      children: [
        if (!orientation)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 0.3.w,
                      height: 0.32.h,
                      child: const CustomEmployeeDoughnutChart(
                        imagePath: "assets/icons_assets/main_icons_assets/dots_vertical.svg",
                        isTransparent: true,
                        title: 'Departments',
                        chartsData: [],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 0.02.w,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 0.3.w,
                      height: 0.32.h,
                      child: CustomEmployeeDoughnutChart(
                        imagePath: "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                        isTransparent: true,
                        title: S.of(context).servicesOffered,
                       chartsData: [],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (orientation)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: orientation ? 0.3.h : 0.3.w,
                      height: orientation ? 0.32.w : .32.h,
                      child: const CustomEmployeeDoughnutChart(
                        imagePath: "assets/icons_assets/main_icons_assets/dots_vertical.svg",
                        isTransparent: true,
                        title: 'Departments',
                       chartsData: [],

                      ),
                    ),
                  ),
                  SizedBox(
                    width: orientation ? 0.02.h : .02.w,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: orientation ? 0.3.h : 0.3.w,
                      height: orientation ? 0.32.w : 0.32.h,
                      child: CustomEmployeeDoughnutChart(
                        imagePath: "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                        isTransparent: true,
                        title: S.of(context).servicesOffered,
                      chartsData: [],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        SizedBox(
          height: orientation ? 0.015.w : 0.015.h,
        ),
      ],
    );
  }
}
