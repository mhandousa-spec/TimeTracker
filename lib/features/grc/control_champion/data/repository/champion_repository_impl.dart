/// Module: Control Champion Management
/// Description: Data-layer implementation of [ChampionRepository]. Maps
///              between Models (persistence) and Entities (domain), and
///              wraps every result in Either<Failure, T>.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, ChampionRepository, ChampionFirebaseDataSource, ChampionModel

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/data/models/assigning_control_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_champion/data/data_source/champion_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/control_champion/data/models/champion_model.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/repository/champion_repository.dart';

class ChampionRepositoryImpl implements ChampionRepository {
  ChampionRepositoryImpl({required ChampionFirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  final ChampionFirebaseDataSource _firebaseDataSource;

  List<AssigningControlModel> _toModels(List<AssigningControlEntity> entities) {
    return entities
        .map((a) => AssigningControlModel(policyId: a.policyId, controlId: a.controlId))
        .toList();
  }

  @override
  Future<Either<Failure, ChampionEntity>> createChampion({
    required String moduleId,
    required String championEmail,
    required List<AssigningControlEntity> assigningControls,
    required String editorId,
  }) async {
    try {
      final model = ChampionModel.create(
        championEmail: championEmail,
        initialAssigningControls: _toModels(assigningControls),
        modifierEmail: editorId,
      );
      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChampionEntity>> getChampion(
    String championEmail, {
    required String moduleId,
  }) async {
    try {
      final model = await _firebaseDataSource.get(championEmail, moduleId: moduleId);
      if (model == null) {
        return Left(ValidationError('Control Champion not found (email: $championEmail)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChampionEntity>>> getAllChampions({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeRemoved: includeRemoved,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChampionEntity>> updateChampion({
    required String championEmail,
    required String moduleId,
    required String editorId,
    List<AssigningControlEntity>? assigningControls,
    ChampionStatus? status,
  }) async {
    try {
      final current = await _firebaseDataSource.get(championEmail, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('Control Champion not found (email: $championEmail)'));
      }
      final updated = current.copyWithUpdate(
        assigningControls:
            assigningControls != null ? _toModels(assigningControls) : null,
        status: status?.value,
        modifierEmail: editorId,
      );
      final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
