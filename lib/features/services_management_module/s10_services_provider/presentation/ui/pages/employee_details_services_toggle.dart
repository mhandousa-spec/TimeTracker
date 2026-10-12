// ******************* FILE INFO *******************
// File Name: employee_details_services_toggle.dart
// Description: toggle in All Platform of this screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/pages/employee_details_services.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EmployeeDetailsServicesToggle extends StatelessWidget {
  const EmployeeDetailsServicesToggle({super.key, required this.approvalModel, required this.index});
  final ServicesHistoryModel approvalModel ;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {

          final isTablet = ContextExtension(context).isTablet;
          final isLandscape = ContextExtension(context).isLandscape;
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;

          // TEMP DIAGNOSTIC 31/8/2026 — tracing why the details page does not
          // open. Every branch below returns the SAME widget, so if this line
          // prints and nothing appears, the toggle is not the problem and the
          // next print to look for is
          // `EmployeeDetailsServicesScreenTablet.initState`. If this line does
          // NOT print, the route was never pushed.
          debugPrint('SVCDIAG >>> EmployeeDetailsServicesToggle.build '
              'isTablet=$isTablet isLandscape=$isLandscape '
              'size=${width}x$height requestId=${approvalModel.currentId} '
              'index=$index');

          if (isTablet && isLandscape) {
            return EmployeeDetailsServicesScreenTablet(approvalModel:approvalModel , index: index,); //  tablet

          } else if (isTablet && !isLandscape) {
            return EmployeeDetailsServicesScreenTablet(approvalModel:approvalModel , index: index,); //  tablet

          } else if (!isTablet && isLandscape) {
            return EmployeeDetailsServicesScreenTablet(approvalModel:approvalModel , index: index,);  // mobile

          } else {
            return EmployeeDetailsServicesScreenTablet(approvalModel:approvalModel , index: index,);  // mobile

          }
        },
      ),
    );
  }
//CreatingNewServiceMobile()
//CreatingNewServiceScreen()
//CreatingNewServiceDesktop()
}

/*
return Scaffold(
body: LayoutBuilder(
builder: (context, constrain){
if (constrain.maxWidth >= 1200) {
return EmployeeDetailsServicesScreenFullScreen(approvalModel:approvalModel , index: index,); // Desktop
} else if (constrain.maxWidth >= 900) {
return EmployeeDetailsServicesScreenDesktop(approvalModel:approvalModel , index: index,); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return EmployeeDetailsServicesScreenTablet(approvalModel:approvalModel , index: index,); //  tablet
} else {
return EmployeeDetailsServicesScreenMobile(approvalModel:approvalModel , index: index,);  // mobile
}

}),
);
 */
