part of 'control_bulk_upload_cubit.dart';

sealed class ControlBulkUploadState {}

/// State while the user is reviewing/editing rows (also emitted after
/// every row-management action, to trigger a table rebuild).
final class ControlBulkUploadEditing extends ControlBulkUploadState {}

/// State while [ControlBulkUploadCubit.submit] is running.
final class ControlBulkUploadSubmitting extends ControlBulkUploadState {}

/// State emitted once [ControlBulkUploadCubit.submit] finishes. Rows that
/// succeeded have already been removed from
/// [ControlBulkUploadCubit.rowsData]; [failed] is parallel, in order, to
/// the rows that remain.
final class ControlBulkUploadSubmitResult extends ControlBulkUploadState {
  final int succeededCount;
  final List<ControlBulkRowFailure> failed;

  ControlBulkUploadSubmitResult({
    required this.succeededCount,
    required this.failed,
  });
}

/// One row's create-control failure reason.
class ControlBulkRowFailure {
  final String reason;
  const ControlBulkRowFailure({required this.reason});
}
