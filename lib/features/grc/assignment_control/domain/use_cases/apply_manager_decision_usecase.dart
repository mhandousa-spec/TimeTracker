import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class ApplyManagerDecisionParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final AssignmentControlStatus newStatus;
  final String? rejectionReason;
  final String editorEmail;

  const ApplyManagerDecisionParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.newStatus,
    this.rejectionReason,
    required this.editorEmail,
  });
}

class ApplyManagerDecisionUseCase {
  const ApplyManagerDecisionUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity>> call(
    ApplyManagerDecisionParams params,
  ) {
    return _repository.applyManagerDecision(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      newStatus: params.newStatus,
      rejectionReason: params.rejectionReason,
      editorEmail: params.editorEmail,
    );
  }
}
