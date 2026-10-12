// ******************* FILE INFO *******************
// File Name: details_switch_screen_toggle.dart
// Description: toggle in All Platform of this screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';



import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/pages/details_switch_screen.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DetailsToggleScreen extends StatelessWidget {
  final ServicesHistoryModel? editingModel;
  final String? docId;

  const DetailsToggleScreen({super.key, this.editingModel, this.docId});

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {


          if (isTablet && isLandscape) { // desktop
            return DetailsSwitchScreenTablet(editingModel: editingModel, docId: docId);

          } else if (isTablet && !isLandscape) { // tablet
            return DetailsSwitchScreenTablet(editingModel: editingModel, docId: docId);


          } else if (!isTablet && isLandscape) {
            return DetailsSwitchScreenTablet(editingModel: editingModel, docId: docId);

          } else {
            return DetailsSwitchScreenTablet(editingModel: editingModel, docId: docId);

          }
        },
      ),
    );



  }
}

