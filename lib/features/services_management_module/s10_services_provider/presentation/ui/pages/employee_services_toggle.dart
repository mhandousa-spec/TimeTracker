// ******************* FILE INFO *******************
// File Name: employee_services_toggle.dart
// Description: toggle in All Platform of this screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/pages/employee_services.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EmployeeLayoutScreenServices extends StatelessWidget {
  const EmployeeLayoutScreenServices({super.key});

  @override
  Widget build(BuildContext context) {

    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;

          // TEMP DIAGNOSTIC 31/8/2026. All four branches return the same
          // widget; this line only proves the toggle was reached and with what
          // measurements.
          debugPrint('SVCDIAG >>> EmployeeLayoutScreenServices.build '
              'isTablet=$isTablet isLandscape=$isLandscape '
              'size=${width}x$height');

          if (isTablet && isLandscape) {
            return EmployeeServicesScreenTablet(); // //
          } else if (isTablet && !isLandscape) {
            return EmployeeServicesScreenTablet(); // //
          } else if (!isTablet && isLandscape) {
            return EmployeeServicesScreenTablet(); // Mobil
          } else {
            return EmployeeServicesScreenTablet(); // Mobil
          }
        },
      ),
    );
  }

}

