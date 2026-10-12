// ******************* FILE INFO *******************
// File Name: data_upload_upload_file_details_toggle.dart
// Description: toggle in All Platform of this screen
// Module: services_management_module / presentation / s4_bulk_upload_services / ui / services_management_module
// Created by: Amr Mesbah
// Last Update: 30/8/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/upload_file_details.dart';

class ToggleUploadFileDetails extends StatelessWidget {
  const ToggleUploadFileDetails({
    super.key,
    required this.formData,
    required this.validationErrors,
    this.selectedFileName,
  });

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (context, constrain){
            if (constrain.maxWidth >= 1200) {
              return UploadFileDetailsTabletMaster(
                formData: formData,
                validationErrors: validationErrors,
                selectedFileName: selectedFileName,  // ✅ ADD THIS LINE
              );
            } else if (constrain.maxWidth >= 900) {
              return UploadFileDetailsTabletMaster(
                formData: formData,
                validationErrors: validationErrors,
                selectedFileName: selectedFileName,  // ✅ ADD THIS LINE
              ); // Horizontal tablet
            } else if (constrain.maxWidth >= 600) {
              return UploadFileDetailsTabletMaster(
                formData: formData,
                validationErrors: validationErrors,
                selectedFileName: selectedFileName,
              ); // tablet
            } else {
              return Center(child: Text("// mobile"),); // mobile
            }
          }),
    );
  }
}
