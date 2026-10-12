// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_bulk_upload_repository.dart
// Purpose: Owns health-insurance bulk-upload persistence.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../data_source/remote_data_source/health_insurance_bulk_upload_remote_data_source.dart';
import '../models/health_insurance_bulk_upload_models.dart';
import '../../utils/health_insurance_bulk_upload_headers.dart';

/// Repository boundary for independent insurance-row commits.
class HealthInsuranceBulkUploadRepository {
  HealthInsuranceBulkUploadRepository(
      {HealthInsuranceBulkUploadRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? HealthInsuranceBulkUploadRemoteDataSource();

  final HealthInsuranceBulkUploadRemoteDataSource _remoteDataSource;

  Future<HealthInsuranceBulkUploadPreflight> loadPreflight() =>
      _remoteDataSource.loadPreflight();

  /// Method Name: [commitRows]
  ///
  /// Purpose: Commits every validated row separately so failures remain isolated.
  Future<HealthInsuranceBulkUploadCommitResult> commitRows(
      List<BulkUploadRow> rows) async {
    var updated = 0;
    final failures = <HealthInsuranceBulkUploadFailedRow>[];
    for (final row in rows) {
      try {
        await _remoteDataSource.appendInsurance(
          employeeId: row.value(HealthInsuranceBulkUploadHeaders.employeeId),
          insuranceName:
              row.value(HealthInsuranceBulkUploadHeaders.insuranceName),
          policyNumber:
              row.value(HealthInsuranceBulkUploadHeaders.policyNumber),
          providerContact:
              row.value(HealthInsuranceBulkUploadHeaders.providerContact),
        );
        updated++;
      } catch (_) {
        failures.add(HealthInsuranceBulkUploadFailedRow(
          excelRowNumber: row.excelRowNumber,
          employeeId: row.value(HealthInsuranceBulkUploadHeaders.employeeId),
          message: 'commit',
        ));
      }
    }
    return HealthInsuranceBulkUploadCommitResult(
        updatedCount: updated, failedRows: failures);
  }
}
