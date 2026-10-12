/// Module: Control Champion Management
/// Description: Use cases for reading a single/all Control Champion records.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, ChampionEntity, ChampionRepository

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/repository/champion_repository.dart';

class GetChampionUseCase {
  const GetChampionUseCase(this._repository);

  final ChampionRepository _repository;

  Future<Either<Failure, ChampionEntity>> call(
    String championEmail, {
    required String moduleId,
  }) {
    return _repository.getChampion(championEmail, moduleId: moduleId);
  }
}

class GetAllChampionsUseCase {
  const GetAllChampionsUseCase(this._repository);

  final ChampionRepository _repository;

  Future<Either<Failure, List<ChampionEntity>>> call({
    required String moduleId,
    bool includeRemoved = false,
  }) {
    return _repository.getAllChampions(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
  }
}
