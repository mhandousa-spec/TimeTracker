part of 'assignment_control_cubit.dart';

sealed class AssignmentControlState {}

final class AssignmentControlInitial extends AssignmentControlState {}

final class AssignmentControlLoading extends AssignmentControlState {}

final class AssignmentControlListLoaded extends AssignmentControlState {
  final List<AssignmentControlItem> items;
  AssignmentControlListLoaded(this.items);
}

final class AssignmentControlActionSuccess extends AssignmentControlState {
  final AssignmentControlEntity assignment;
  AssignmentControlActionSuccess(this.assignment);
}

final class AssignmentControlFailure extends AssignmentControlState {
  final String message;
  AssignmentControlFailure(this.message);
}
