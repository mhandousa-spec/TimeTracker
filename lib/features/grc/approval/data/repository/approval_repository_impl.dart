/// Module: Approvals (Department Manager)
/// Description: Data-layer implementation of ApprovalRepository. Maps
///              between ApprovalModel (persistence) and ApprovalEntity
///              (domain), and wraps every result in `Either<Failure, T>`.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/approval/data/data_source/approval_data_source.dart';
import 'package:knowticed_plus/features/grc/approval/data/models/approval_model.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:knowticed_plus/features/grc/approval/domain/repository/approval_repository.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  ApprovalRepositoryImpl({required ApprovalDataSource dataSource})
      : _dataSource = dataSource;

  final ApprovalDataSource _dataSource;

  String _docId({required String controlId, required String championEmail}) =>
      '${controlId}_$championEmail';

  @override
  Future<Either<Failure, List<ApprovalEntity>>> getAllApprovals({
    required String moduleId,
  }) async {
    try {
      final models = await _dataSource.getAll(moduleId: moduleId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApprovalEntity>> createOrUpdatePending({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);

      final ApprovalModel saved;
      if (current == null) {
        final model = ApprovalModel.create(
          requestId: id,
          submissionId: id,
          editorEmail: editorEmail,
        );
        saved = await _dataSource.create(model, moduleId: moduleId);
      } else {
        final model = current.copyWithUpdate(
          status: 'Pending',
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
  Future<Either<Failure, ApprovalEntity>> decide({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String status,
    String? reasonOfRejection,
    String? approvalComment,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('Approval not found (id: $id)'));
      }
      final model = current.copyWithUpdate(
        status: status,
        reasonOfRejection: reasonOfRejection,
        approvalComment: approvalComment,
        editorEmail: editorEmail,
      );
      final saved = await _dataSource.update(model, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
