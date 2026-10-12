part of 'policy_bulk_upload_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_state.dart
/// Purpose: Contains all state classes emitted by [PolicyBulkUploadCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

sealed class PolicyBulkUploadState {}

/// State while the user is reviewing/editing rows (also emitted after
/// every row-management action, to trigger a table rebuild).
final class PolicyBulkUploadEditing extends PolicyBulkUploadState {}

/// State while [PolicyBulkUploadCubit.submit] is running.
final class PolicyBulkUploadSubmitting extends PolicyBulkUploadState {}

/// State emitted once [PolicyBulkUploadCubit.submit] finishes. Rows that
/// succeeded have already been removed from [PolicyBulkUploadCubit.rowsData];
/// [failed] is parallel, in order, to the rows that remain.
final class PolicyBulkUploadSubmitResult extends PolicyBulkUploadState {
  final int succeededCount;
  final List<PolicyBulkRowFailure> failed;

  PolicyBulkUploadSubmitResult({
    required this.succeededCount,
    required this.failed,
  });
}

/// One row's create-policy failure reason, in [PolicyBulkUploadSubmitResult.failed].
class PolicyBulkRowFailure {
  final String reason;
  const PolicyBulkRowFailure({required this.reason});
}
