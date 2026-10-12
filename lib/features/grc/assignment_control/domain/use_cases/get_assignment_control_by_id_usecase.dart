import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class GetAssignmentControlByIdUseCase {
  const GetAssignmentControlByIdUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity?>> call({
    required String moduleId,
    required String id,
  }) {
    return _repository.getAssignmentControlById(moduleId: moduleId, id: id);
  }
}
