import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:knowticed_plus/features/grc/approval/domain/repository/approval_repository.dart';

class DecideApprovalParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final String status;
  final String? reasonOfRejection;
  final String? approvalComment;
  final String editorEmail;

  const DecideApprovalParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.status,
    this.reasonOfRejection,
    this.approvalComment,
    required this.editorEmail,
  });
}

class DecideApprovalUseCase {
  const DecideApprovalUseCase(this._repository);

  final ApprovalRepository _repository;

  Future<Either<Failure, ApprovalEntity>> call(DecideApprovalParams params) {
    return _repository.decide(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      status: params.status,
      reasonOfRejection: params.reasonOfRejection,
      approvalComment: params.approvalComment,
      editorEmail: params.editorEmail,
    );
  }
}
