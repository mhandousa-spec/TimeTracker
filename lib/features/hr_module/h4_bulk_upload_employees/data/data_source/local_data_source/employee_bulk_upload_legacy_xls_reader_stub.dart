// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_legacy_xls_reader_stub.dart
// Purpose: Keeps web builds safe when the native BIFF reader is unavailable.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'dart:typed_data';

/// Platform-neutral values extracted from one legacy worksheet.
class EmployeeBulkUploadLegacySheet {
  const EmployeeBulkUploadLegacySheet({
    required this.name,
    required this.rows,
    required this.firstRowIndex,
  });

  final String name;
  final List<List<Object?>> rows;
  final int firstRowIndex;
}

/// Method Name: [readEmployeeBulkUploadLegacyXls]
///
/// Purpose: Reports that BIFF decoding is unavailable in a web build.
///
/// Returns: Never returns normally on this platform.
EmployeeBulkUploadLegacySheet? readEmployeeBulkUploadLegacyXls(
  Uint8List bytes,
) {
  throw UnsupportedError('Legacy XLS parsing is unavailable on web.');
}
