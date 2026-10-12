// ******************* FILE INFO *******************
// File Name: my_request_details_toggle.dart
// Description: toggle in All Platform of this screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';



import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request_details.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MyRequestDetailsServicesToggle extends StatelessWidget {
  const MyRequestDetailsServicesToggle({
    required this.myRequestDetailsModel,
    super.key,
  });

  final ServicesHistoryModel myRequestDetailsModel;

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;

    return Scaffold(
      body: isTablet
          ? (isLandscape
      // Tablet • Landscape
          ? MyRequestDetails(myRequestDetailsModel: myRequestDetailsModel)
      // Tablet • Portrait
          : MyRequestDetails(myRequestDetailsModel: myRequestDetailsModel))
          : (isLandscape
      // Phone • Landscape
          ? MyRequestDetails(myRequestDetailsModel: myRequestDetailsModel)
      // Phone • Portrait
          : MyRequestDetails(myRequestDetailsModel: myRequestDetailsModel)),
    );
  }
}
