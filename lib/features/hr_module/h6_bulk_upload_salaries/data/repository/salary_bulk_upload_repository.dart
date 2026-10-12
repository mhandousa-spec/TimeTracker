// ***************************** FILE INFO ***************************** //
// File Name: salary_bulk_upload_repository.dart
// Purpose: Coordinates independent salary bulk-upload commits.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/h6_bulk_upload_salaries/data/models/salary_bulk_upload_models.dart';
import 'package:knowticed_plus/features/hr_module/shared/bulk_upload/bulk_upload_template.dart';
import '../data_source/remote_data_source/salary_bulk_upload_remote_data_source.dart';
import '../../utils/salary_bulk_upload_headers.dart';

/// Persists validated salary rows without coupling presentation to Firestore.
class SalaryBulkUploadRepository {
  SalaryBulkUploadRepository({SalaryBulkUploadRemoteDataSource? remote})
      : _remote = remote ?? SalaryBulkUploadRemoteDataSource();
  final SalaryBulkUploadRemoteDataSource _remote;
  Future<SalaryBulkUploadPreflight> loadPreflight() async {
    return SalaryBulkUploadPreflight(await _remote.loadEmployees());
  }

  Future<SalaryBulkUploadCommitResult> commitRows(
      List<BulkUploadRow> rows) async {
    final latest = await loadPreflight();
    final updatedRows = <BulkUploadRow>[];
    final failedRows = <SalaryBulkUploadFailedRow>[];
    for (final row in rows) {
      final employeeId = row.value(SalaryBulkUploadHeaders.employeeId);
      if (!latest.employeesById.containsKey(employeeId)) {
        failedRows.add(
            SalaryBulkUploadFailedRow(row: row, message: 'employee-not-found'));
        continue;
      }
      try {
        await _remote.appendSalary(
          employeeId: employeeId,
          jobType: row.value(SalaryBulkUploadHeaders.jobType),
          currency: row.value(SalaryBulkUploadHeaders.currency),
          salary: row.value(SalaryBulkUploadHeaders.salary),
          daysOff: row.value(SalaryBulkUploadHeaders.workDays),
          startTime: row.value(SalaryBulkUploadHeaders.startTime),
          endTime: row.value(SalaryBulkUploadHeaders.endTime),
        );
        updatedRows.add(row);
      } catch (error) {
        failedRows.add(
            SalaryBulkUploadFailedRow(row: row, message: error.toString()));
      }
    }
    return SalaryBulkUploadCommitResult(
        updatedRows: updatedRows, failedRows: failedRows);
  }
}
