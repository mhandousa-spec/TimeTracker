// ******************* FILE INFO *******************
// File Name: master_upload_upload_file_details_toggle.dart
// Description: Toggle for upload file details — passes uploadFn callback
//   so MasterUploadScreen can hold Step 1 upload until Step 2 is ready.
// Created by: Amr Mesbah
///
/// CHANGE LOG:
/// - onActivated signature updated: uploadFn now returns Future<Map<String,String>>
///   (serviceName → firestoreDocId) instead of Future<void>.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/upload_file_details.dart' show UploadFileDetailsTabletMaster;

class ToggleUploadFileDetailsMaster extends StatelessWidget {
  const ToggleUploadFileDetailsMaster({
    super.key,
    required this.formData,
    required this.validationErrors,
    this.selectedFileName,
    this.onActivated,
  });

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;

  /// Called after the user confirms Step 1 activation.
  /// Receives uploadToFirebase fn — MasterUploadScreen stores it and calls it
  /// together with Step 2's upload when the user confirms Step 2.
  /// The fn returns Map<String, String> (serviceName → firestoreDocId).
  final Future<void> Function(Future<Map<String, String>> Function() uploadFn)? onActivated;

  @override
  Widget build(BuildContext context) {
    return UploadFileDetailsTabletMaster(
      formData: formData,
      validationErrors: validationErrors,
      selectedFileName: selectedFileName,
      onActivated: onActivated,
    );
  }
}
