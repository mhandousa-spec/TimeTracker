import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/repository/my_audit_repository.dart';

class CreateOrUpdatePendingMyAuditParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final String editorEmail;

  const CreateOrUpdatePendingMyAuditParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.editorEmail,
  });
}

class CreateOrUpdatePendingMyAuditUseCase {
  const CreateOrUpdatePendingMyAuditUseCase(this._repository);

  final MyAuditRepository _repository;

  Future<Either<Failure, MyAuditEntity>> call(
    CreateOrUpdatePendingMyAuditParams params,
  ) {
    return _repository.createOrUpdatePending(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      editorEmail: params.editorEmail,
    );
  }
}
