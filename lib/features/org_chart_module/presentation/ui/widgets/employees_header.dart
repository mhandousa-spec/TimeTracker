import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/settings/mode_changer.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';

import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_hr_components/buttons_beside_title_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeesHeader extends StatelessWidget {
  EmployeesHeader({super.key});
  OrgChartEmployeeController employeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: isTablet
              ? isPortrait
                  ? 0.0.h
                  : 0.015.h
              : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).orgChart,
            style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: isTablet
                    ? isPortrait
                        ? FontConstants.fontSize030.h
                        : FontConstants.fontSize038.h
                    : FontConstants.fontSize026.h,
                fontWeight: FontWeight.w600,
                letterSpacing:
                    Get.locale.toString().contains('en') ? 1.1 : null,
                color: Theme.of(context).colorScheme.inverseSurface),
          ),
          Mode.hr || Mode.owner
              ? ButtonsBesideTitle(
                  chartSelected: employeeController.chartSelected,
                  chartSelectedState: (value) {
                    employeeController.chartSelected = value;
                    employeeController.update();
                  },
                  orgSelected: employeeController.orgSelected,
                  orgSelectedState: (value) {
                    employeeController.orgSelected = value;
                    employeeController.update();
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
