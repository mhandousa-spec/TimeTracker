// lib/features/grc/my_audit/presentation/controller/my_audit_state.dart
part of 'my_audit_cubit.dart';

sealed class MyAuditState {}

final class MyAuditInitial extends MyAuditState {}

final class MyAuditLoading extends MyAuditState {}

final class MyAuditListLoaded extends MyAuditState {
  final List<MyAuditItem> items;
  MyAuditListLoaded(this.items);
}

final class MyAuditActionSuccess extends MyAuditState {
  final MyAuditEntity audit;
  MyAuditActionSuccess(this.audit);
}

final class MyAuditFailure extends MyAuditState {
  final String message;
  MyAuditFailure(this.message);
}
