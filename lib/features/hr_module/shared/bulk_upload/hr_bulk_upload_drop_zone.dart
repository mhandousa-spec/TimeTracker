// ***************************** FILE INFO ***************************** //
// File Name: hr_bulk_upload_drop_zone.dart
// Purpose: Exposes the shared HR workbook file-selection surface.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/h4_bulk_upload_employees/presentation/ui/widgets/employee_bulk_upload_drop_zone.dart';

/// Reusable HR alias for the established drag-and-drop workbook surface.
class HrBulkUploadDropZone extends EmployeeBulkUploadDropZone {
  const HrBulkUploadDropZone({
    required super.onBrowse,
    required super.onDiscard,
    required super.onDropped,
    required super.onNoFilesDropped,
    required super.onUnsupportedFile,
    required super.onFileReadFailure,
    required super.isProcessing,
    super.key,
  });
}
