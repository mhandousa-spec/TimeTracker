/// Module: Control Champion Management
/// Description: Use case for creating a new Control Champion.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, ChampionEntity, ChampionRepository, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/repository/champion_repository.dart';

class CreateChampionParams {
  final String moduleId;
  final String championEmail;
  final List<AssigningControlEntity> assigningControls;
  final String editorId;

  const CreateChampionParams({
    required this.moduleId,
    required this.championEmail,
    required this.assigningControls,
    required this.editorId,
  });
}

class CreateChampionUseCase {
  const CreateChampionUseCase(this._repository);

  final ChampionRepository _repository;

  Future<Either<Failure, ChampionEntity>> call(CreateChampionParams params) {
    return _repository.createChampion(
      moduleId: params.moduleId,
      championEmail: params.championEmail,
      assigningControls: params.assigningControls,
      editorId: params.editorId,
    );
  }
}
