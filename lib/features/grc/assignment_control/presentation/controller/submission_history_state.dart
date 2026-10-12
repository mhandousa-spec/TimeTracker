part of 'submission_history_cubit.dart';

sealed class SubmissionHistoryState {}

final class SubmissionHistoryInitial extends SubmissionHistoryState {}

final class SubmissionHistoryLoading extends SubmissionHistoryState {}

final class SubmissionHistoryLoaded extends SubmissionHistoryState {
  final List<SubmissionHistoryEntry> entries;
  SubmissionHistoryLoaded(this.entries);
}

final class SubmissionHistoryFailure extends SubmissionHistoryState {
  final String message;
  SubmissionHistoryFailure(this.message);
}
