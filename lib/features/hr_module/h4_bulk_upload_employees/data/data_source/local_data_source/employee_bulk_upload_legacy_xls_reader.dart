// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_legacy_xls_reader.dart
// Purpose: Selects the platform-safe legacy XLS byte reader implementation.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

export 'employee_bulk_upload_legacy_xls_reader_stub.dart'
    if (dart.library.io) 'employee_bulk_upload_legacy_xls_reader_io.dart';
