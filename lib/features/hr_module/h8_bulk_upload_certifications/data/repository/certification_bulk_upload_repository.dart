// ***************************** FILE INFO ***************************** //
// File Name: certification_bulk_upload_repository.dart
// Purpose: Coordinates certification workbook preflight and commits.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../data_source/remote_data_source/certification_bulk_upload_remote_data_source.dart';
import '../models/certification_bulk_upload_models.dart';

/// Repository boundary for certification workbook persistence.
class CertificationBulkUploadRepository {
  CertificationBulkUploadRepository(
      {CertificationBulkUploadRemoteDataSource? remote})
      : _remote = remote ?? CertificationBulkUploadRemoteDataSource();

  final CertificationBulkUploadRemoteDataSource _remote;

  /// Method Name: [loadPreflight]
  ///
  /// Purpose: Loads employees used to validate workbook identity columns.
  Future<CertificationBulkUploadPreflight> loadPreflight() async =>
      CertificationBulkUploadPreflight(await _remote.loadEmployees());

  /// Method Name: [commitRows]
  ///
  /// Purpose: Commits each valid workbook row independently.
  Future<CertificationBulkUploadCommitResult> commitRows(
      List<BulkUploadRow> rows) async {
    final updated = <BulkUploadRow>[];
    final failures = <CertificationBulkUploadFailedRow>[];
    for (final row in rows) {
      try {
        await _remote.appendCertification(row: row);
        updated.add(row);
      } catch (error) {
        failures.add(CertificationBulkUploadFailedRow(
          row: row,
          message: error.toString(),
        ));
      }
    }
    return CertificationBulkUploadCommitResult(
      updatedRows: updated,
      failedRows: failures,
    );
  }
}
