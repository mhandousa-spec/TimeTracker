import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/repository/my_audit_repository.dart';

class DecideMyAuditParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final String status;
  final String? reasonOfRejection;
  final String editorEmail;

  const DecideMyAuditParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.status,
    this.reasonOfRejection,
    required this.editorEmail,
  });
}

class DecideMyAuditUseCase {
  const DecideMyAuditUseCase(this._repository);

  final MyAuditRepository _repository;

  Future<Either<Failure, MyAuditEntity>> call(DecideMyAuditParams params) {
    return _repository.decide(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      status: params.status,
      reasonOfRejection: params.reasonOfRejection,
      editorEmail: params.editorEmail,
    );
  }
}
