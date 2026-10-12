import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/repository/my_audit_repository.dart';

class ApplyMyAuditScoreParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final double score;
  final String? justification;
  final String editorEmail;

  const ApplyMyAuditScoreParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.score,
    this.justification,
    required this.editorEmail,
  });
}

class ApplyMyAuditScoreUseCase {
  const ApplyMyAuditScoreUseCase(this._repository);

  final MyAuditRepository _repository;

  Future<Either<Failure, MyAuditEntity>> call(ApplyMyAuditScoreParams params) {
    return _repository.applyScore(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      score: params.score,
      justification: params.justification,
      editorEmail: params.editorEmail,
    );
  }
}
