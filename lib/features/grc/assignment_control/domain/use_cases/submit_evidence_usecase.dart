import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class SubmitEvidenceParams {
  final String moduleId;
  final String policyId;
  final String controlId;
  final String championEmail;
  final String? controlOwnerEmail;
  final String? departmentManagerEmail;
  final File documentFile;
  final String note;
  final String editorEmail;

  const SubmitEvidenceParams({
    required this.moduleId,
    required this.policyId,
    required this.controlId,
    required this.championEmail,
    required this.controlOwnerEmail,
    required this.departmentManagerEmail,
    required this.documentFile,
    required this.note,
    required this.editorEmail,
  });
}

class SubmitEvidenceUseCase {
  const SubmitEvidenceUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity>> call(
    SubmitEvidenceParams params,
  ) {
    return _repository.submitEvidence(
      moduleId: params.moduleId,
      policyId: params.policyId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      controlOwnerEmail: params.controlOwnerEmail,
      departmentManagerEmail: params.departmentManagerEmail,
      documentFile: params.documentFile,
      note: params.note,
      editorEmail: params.editorEmail,
    );
  }
}
