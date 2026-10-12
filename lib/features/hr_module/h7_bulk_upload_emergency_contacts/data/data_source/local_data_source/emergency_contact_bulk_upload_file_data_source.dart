// ***************************** FILE INFO ***************************** //
// File Name: emergency_contact_bulk_upload_file_data_source.dart
// Purpose: Selects and parses emergency-contact workbooks.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/bulk_upload/bulk_upload_file_data_source.dart';
import '../../../utils/emergency_contact_bulk_upload_headers.dart';

/// Local file boundary for the emergency-contact upload flow.
class EmergencyContactBulkUploadFileDataSource {
  const EmergencyContactBulkUploadFileDataSource();
  Future<PlatformFile?> pickFile() =>
      const BulkUploadFileDataSource().pickFile();
  BulkUploadParseResult parse(
          {required String fileName, required Uint8List bytes}) =>
      const BulkUploadFileDataSource().parse(
          fileName: fileName,
          bytes: bytes,
          template: EmergencyContactBulkUploadHeaders.template);
}
