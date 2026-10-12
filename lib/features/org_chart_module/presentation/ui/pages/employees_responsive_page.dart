import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/ui/pages/mobile/employees_screen_mobile.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';

import 'package:knowticed_plus/features/org_chart_module/presentation/ui/pages/tablet/employees_screen.dart';
GlobalKey employeesNavKey = GlobalKey();

class EmployeesResponsivePage extends StatelessWidget {
   EmployeesResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    return ResponsiveHelper(
        mobileWidget: EmployeesScreenMobile(), tabletWidget:
     Navigator(
       key: employeesNavKey,
      onGenerateRoute: (settings) {

        return MaterialPageRoute(
          builder: (context) => EmployeesScreen(),
        );
      },
     )
    );
  }
}
