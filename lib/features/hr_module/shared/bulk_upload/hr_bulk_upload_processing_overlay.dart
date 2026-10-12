// ***************************** FILE INFO ***************************** //
// File Name: hr_bulk_upload_processing_overlay.dart
// Purpose: Displays a blocking progress surface for HR workbook operations.
// Author: Mohamed Elrashidy
// Created At: 2026-08-21
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/custom/66-circle_progress.dart';

/// Blocking overlay shared by HR bulk-upload workflows.
class HrBulkUploadProcessingOverlay extends StatelessWidget {
  const HrBulkUploadProcessingOverlay({
    required this.message,
    super.key,
  });

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
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircleProgressMaster(),
                    ),
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
