/// Module: My Audits (Control Owner)
/// Description: Data-layer implementation of [MyAuditRepository]. Maps
///              between MyAuditModel (persistence) and MyAuditEntity
///              (domain), and wraps every result in Either&lt;Failure, T&gt;.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/my_audit/data/data_source/my_audit_data_source.dart';
import 'package:knowticed_plus/features/grc/my_audit/data/models/my_audit_model.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/repository/my_audit_repository.dart';

class MyAuditRepositoryImpl implements MyAuditRepository {
  MyAuditRepositoryImpl({required MyAuditDataSource dataSource})
      : _dataSource = dataSource;

  final MyAuditDataSource _dataSource;

  String _docId({required String controlId, required String championEmail}) =>
      '${controlId}_$championEmail';

  @override
  Future<Either<Failure, List<MyAuditEntity>>> getAllMyAudits({
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
  Future<Either<Failure, MyAuditEntity>> createOrUpdatePending({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);

      final MyAuditModel saved;
      if (current == null) {
        final model = MyAuditModel.create(
          auditId: id,
          requestId: id,
          submissionId: id,
          editorEmail: editorEmail,
        );
        saved = await _dataSource.create(model, moduleId: moduleId);
      } else {
        final model = current.copyWithUpdate(status: 'Pending', editorEmail: editorEmail);
        saved = await _dataSource.update(model, moduleId: moduleId);
      }
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyAuditEntity>> decide({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String status,
    String? reasonOfRejection,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('My Audit not found (id: $id)'));
      }
      final model = current.copyWithUpdate(
        status: status,
        controlOwnerReasonOfRejection: reasonOfRejection,
        editorEmail: editorEmail,
      );
      final saved = await _dataSource.update(model, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyAuditEntity>> applyScore({
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
        return Left(ValidationError('My Audit not found (id: $id)'));
      }
      final model = current.copyWithUpdate(
        status: 'Scored',
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
}
