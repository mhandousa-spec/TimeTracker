import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class ApplyOwnerScoreParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final double score;
  final String? justification;
  final String editorEmail;

  const ApplyOwnerScoreParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.score,
    this.justification,
    required this.editorEmail,
  });
}

class ApplyOwnerScoreUseCase {
  const ApplyOwnerScoreUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity>> call(ApplyOwnerScoreParams params) {
    return _repository.applyOwnerScore(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      score: params.score,
      justification: params.justification,
      editorEmail: params.editorEmail,
    );
  }
}
