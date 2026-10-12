// ***************************** FILE INFO ***************************** //
// File Name: emergency_contact_bulk_upload_repository.dart
// Purpose: Coordinates validated emergency-contact row commits.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../data_source/remote_data_source/emergency_contact_bulk_upload_remote_data_source.dart';
import '../models/emergency_contact_bulk_upload_models.dart';
import '../../utils/emergency_contact_bulk_upload_headers.dart';

/// Repository boundary for independent emergency-contact updates.
class EmergencyContactBulkUploadRepository {
  EmergencyContactBulkUploadRepository(
      {EmergencyContactBulkUploadRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? EmergencyContactBulkUploadRemoteDataSource();
  final EmergencyContactBulkUploadRemoteDataSource _remoteDataSource;

  Future<EmergencyContactBulkUploadPreflight> loadPreflight() =>
      _remoteDataSource.loadPreflight();

  Future<EmergencyContactBulkUploadCommitResult> commitRows(
      List<BulkUploadRow> rows) async {
    final latest = await loadPreflight();
    var updated = 0;
    final failures = <EmergencyContactBulkUploadFailedRow>[];
    for (final row in rows) {
      final id = row.value(EmergencyContactBulkUploadHeaders.employeeId);
      if (!latest.employeeIds.contains(id)) {
        failures.add(EmergencyContactBulkUploadFailedRow(
            rowNumber: row.excelRowNumber,
            employeeId: id,
            message: 'employee-not-found'));
        continue;
      }
      try {
        await _remoteDataSource.appendEmergencyContact(row: row);
        updated++;
      } catch (error) {
        failures.add(EmergencyContactBulkUploadFailedRow(
            rowNumber: row.excelRowNumber,
            employeeId: id,
            message: error.toString()));
      }
    }
    return EmergencyContactBulkUploadCommitResult(
        updatedCount: updated, failedRows: failures);
  }
}
