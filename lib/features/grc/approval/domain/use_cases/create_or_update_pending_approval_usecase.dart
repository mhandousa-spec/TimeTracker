import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:knowticed_plus/features/grc/approval/domain/repository/approval_repository.dart';

class CreateOrUpdatePendingApprovalParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final String editorEmail;

  const CreateOrUpdatePendingApprovalParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.editorEmail,
  });
}

class CreateOrUpdatePendingApprovalUseCase {
  const CreateOrUpdatePendingApprovalUseCase(this._repository);

  final ApprovalRepository _repository;

  Future<Either<Failure, ApprovalEntity>> call(
    CreateOrUpdatePendingApprovalParams params,
  ) {
    return _repository.createOrUpdatePending(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      editorEmail: params.editorEmail,
    );
  }
}
