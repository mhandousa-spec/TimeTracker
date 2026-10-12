/// Module: Assignment Controls (Control Champion)
/// Description: Data-layer implementation of [AssignmentControlRepository].
///              Maps between AssignmentControlModel (persistence) and
///              AssignmentControlEntity (domain), uploads evidence files via
///              [PolicyStorageDataSource], and wraps every result in
///              Either&lt;Failure, T&gt;.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/data_source/assignment_control_data_source.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/models/assignment_control_model.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';
import 'package:knowticed_plus/features/grc/policy/data/data_source/policy_storage_data_source.dart';

class AssignmentControlRepositoryImpl implements AssignmentControlRepository {
  AssignmentControlRepositoryImpl({
    required AssignmentControlDataSource dataSource,
    required PolicyStorageDataSource storageDataSource,
  })  : _dataSource = dataSource,
        _storageDataSource = storageDataSource;

  final AssignmentControlDataSource _dataSource;
  final PolicyStorageDataSource _storageDataSource;

  String _docId({required String controlId, required String championEmail}) =>
      '${controlId}_$championEmail';

  @override
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControl({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) async {
    try {
      final model = await _dataSource.get(
        _docId(controlId: controlId, championEmail: championEmail),
        moduleId: moduleId,
      );
      return Right(model?.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControlById({
    required String moduleId,
    required String id,
  }) async {
    try {
      final model = await _dataSource.get(id, moduleId: moduleId);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentControlEntity>> applyManagerDecision({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required AssignmentControlStatus newStatus,
    String? rejectionReason,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('Assignment Control not found (id: $id)'));
      }
      final model = current.copyWithUpdate(
        status: newStatus.value,
        departmentManagerRejectionReason: rejectionReason,
        editorEmail: editorEmail,
      );
      final saved = await _dataSource.update(model, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentControlEntity>> applyOwnerScore({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required double score,
    String? justification,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('Assignment Control not found (id: $id)'));
      }
      final model = current.copyWithUpdate(
        status: AssignmentControlStatus.approved.value,
        controlScore: score,
        controlOwnerJustification: justification,
        editorEmail: editorEmail,
      );
      final saved = await _dataSource.update(model, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentControlEntity>> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String? controlOwnerEmail,
    required String? departmentManagerEmail,
    required File documentFile,
    required String note,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final documentUrl = await _storageDataSource.uploadAssignmentEvidence(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        documentFile: documentFile,
      );
      final current = await _dataSource.get(id, moduleId: moduleId);

      final AssignmentControlModel saved;
      if (current == null) {
        final model = AssignmentControlModel.create(
          submissionId: id,
          controlChampionEmail: championEmail,
          policyId: policyId,
          controlId: controlId,
          controlOwner: controlOwnerEmail,
          departmentManager: departmentManagerEmail,
          submissionDocument: documentUrl,
          submissionNote: note,
          editorEmail: editorEmail,
        );
        saved = await _dataSource.create(model, moduleId: moduleId);
      } else {
        final model = current.copyWithUpdate(
          submissionDocument: documentUrl,
          submissionNote: note,
          status: AssignmentControlStatus.submitted.value,
          // FIXED 28/9/2026 (GRC bug report p7): these were only written when
          // the doc was first created, so a stale or empty Department
          // Manager stuck forever and the evidence never reached the
          // supervisor's Approvals. Refresh them on every (re)submission.
          controlOwner: controlOwnerEmail,
          departmentManager: departmentManagerEmail,
          editorEmail: editorEmail,
        );
        saved = await _dataSource.update(model, moduleId: moduleId);
      }
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubmissionHistoryEntry>>> getSubmissionHistory({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final model = await _dataSource.get(id, moduleId: moduleId);
      return Right(model?.toSubmissionHistory() ?? const []);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
