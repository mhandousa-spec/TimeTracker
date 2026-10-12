import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class GetSubmissionHistoryUseCase {
  const GetSubmissionHistoryUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, List<SubmissionHistoryEntry>>> call({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) {
    return _repository.getSubmissionHistory(
      moduleId: moduleId,
      controlId: controlId,
      championEmail: championEmail,
    );
  }
}
