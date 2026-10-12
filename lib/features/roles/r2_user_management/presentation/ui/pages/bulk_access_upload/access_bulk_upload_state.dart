part of 'access_bulk_upload_cubit.dart';

sealed class AccessBulkUploadState {}

final class AccessBulkUploadEditing extends AccessBulkUploadState {}

final class AccessBulkUploadSubmitting extends AccessBulkUploadState {}

/// [failures] holds one "employee: reason" line per row that did not save.
/// Those rows are still in the table; the saved ones have been removed.
final class AccessBulkUploadResult extends AccessBulkUploadState {
  final int succeeded;
  final List<String> failures;

  AccessBulkUploadResult({required this.succeeded, required this.failures});
}
