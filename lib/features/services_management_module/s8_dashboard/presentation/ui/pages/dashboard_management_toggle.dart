// ******************* FILE INFO *******************
// File Name: dashboard_management_toggle.dart
// Description: toggle in All Platform of this screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/pages/dashboard_mobile.dart';

class DashBordLayout extends StatelessWidget {
  const DashBordLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // S8-011/T01: every responsive branch resolved to the same widget — the
    // variant router was dead code (§17).
    return Scaffold(
      body: DashBoardMasterMobile(),
    );
  }
}

/*
return Scaffold(
body: LayoutBuilder(
builder: (context, constrain) {
if (constrain.maxWidth >= 1200) {
return DashBoardMasterFullScreen(); // Desktop
} else if (constrain.maxWidth >= 900) {
return DashBoardMasterDesktop(); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return DashBoardMasterTablet(); // // tablet
} else {
return DashBoardMasterMobile(); // mobile
}
},
),
);
 */
