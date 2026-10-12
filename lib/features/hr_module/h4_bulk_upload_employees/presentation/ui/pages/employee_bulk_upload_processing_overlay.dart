// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_processing_overlay.dart
// Purpose: Displays the blocking workbook-processing state.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Blocking in-page processing surface for workbook parsing.
class EmployeeBulkUploadProcessingOverlay extends StatelessWidget {
  const EmployeeBulkUploadProcessingOverlay({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Stack(
          children: [
            const ModalBarrier(dismissible: false, color: Colors.black54),
            Center(
              child: AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(width: 20.sp),
                    Flexible(child: Text(message)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
