// ******************* FILE INFO *******************
// File Name: dashboard_details_admin_toggle.dart
// Description: toggle in All Platform of this screen
// Module: services_management_module / presentation / s9_admin_dashboard / ui / services_management_module
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/pages/dashboard_details_admin.dart';

class AdminDashBordDetailsLayout extends StatelessWidget {
  const AdminDashBordDetailsLayout({super.key, required this.selectedServiceName});

  final String selectedServiceName;

  @override
  Widget build(BuildContext context) {
    // S9-P07/016: every responsive branch resolved to the same widget — the
    // variant router was dead code (§17).
    return Scaffold(
      body: AdminDashBoardDetailsTablet(selectedServiceName: selectedServiceName),
    );
  }
}

/*
return Scaffold(
body: LayoutBuilder(
builder: (context, constrain) {
if (constrain.maxWidth >= 1200) {
return AdminDashBoardDetailsTablet(selectedServiceName: selectedServiceName); // Desktop
} else if (constrain.maxWidth >= 900) {
return AdminDashBoardDetailsTablet(selectedServiceName: selectedServiceName);// Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return AdminDashBoardDetailsTablet(selectedServiceName: selectedServiceName,); // tablet
} else {
return AdminDashBoardMasterDeatilsMobile(name: selectedServiceName,); // mobile
}
},
),
);
 */
