// ******************* FILE INFO *******************
// File Name: create_new_services_toggle.dart
// Description: toggle in All Platform of this screen
// Module: services_management_module / presentation / s4_bulk_upload_services / ui / services_management_module
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
// ✅ UPDATED: Import the new refactored screen instead of the old one
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/create_new_services.dart'; // Remove this if no longer needed
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CreateNewServicesLayout extends StatelessWidget {
  final ServicesHistoryModel? editingModel;
  final String? docId;

  const CreateNewServicesLayout({
    super.key,
    this.editingModel,
    this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;

          // ✅ SIMPLIFIED: All conditions return the same new screen
          // You can simplify this since all branches are identical
          return CreateServiceScreen(
            editingModel: editingModel,
            docId: docId,
          );
        },
      ),
    );
  }
}
