part of 'approval_cubit.dart';

sealed class ApprovalState {}

final class ApprovalInitial extends ApprovalState {}

final class ApprovalLoading extends ApprovalState {}

final class ApprovalListLoaded extends ApprovalState {
  final List<ApprovalItem> items;
  ApprovalListLoaded(this.items);
}

final class ApprovalActionSuccess extends ApprovalState {
  final ApprovalEntity approval;
  ApprovalActionSuccess(this.approval);
}

final class ApprovalFailure extends ApprovalState {
  final String message;
  ApprovalFailure(this.message);
}
