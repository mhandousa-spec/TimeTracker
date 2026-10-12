part of 'assignee_bulk_upload_cubit.dart';

sealed class AssigneeBulkUploadState {}

/// State while the user is reviewing/editing rows (also emitted after every
/// row-management action, to trigger a table rebuild).
final class AssigneeBulkUploadEditing extends AssigneeBulkUploadState {}

/// State while [AssigneeBulkUploadCubit.submit] is running.
final class AssigneeBulkUploadSubmitting extends AssigneeBulkUploadState {}

/// State emitted once [AssigneeBulkUploadCubit.submit] finishes. Rows that
/// succeeded have already been removed from
/// [AssigneeBulkUploadCubit.rowsData]; [failed] is parallel, in order, to
/// the rows that remain.
final class AssigneeBulkUploadSubmitResult extends AssigneeBulkUploadState {
  final int succeededCount;
  final List<AssigneeBulkRowFailure> failed;

  AssigneeBulkUploadSubmitResult({
    required this.succeededCount,
    required this.failed,
  });
}

/// One row's create failure reason, in [AssigneeBulkUploadSubmitResult.failed].
class AssigneeBulkRowFailure {
  final String reason;
  const AssigneeBulkRowFailure({required this.reason});
}
