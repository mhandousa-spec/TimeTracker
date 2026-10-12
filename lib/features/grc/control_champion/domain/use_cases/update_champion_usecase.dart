/// Module: Control Champion Management
/// Description: Use case for updating an existing Control Champion (also
///              covers soft-delete/restore via status).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, ChampionEntity, ChampionStatus, ChampionRepository, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/repository/champion_repository.dart';

class UpdateChampionParams {
  final String championEmail;
  final String moduleId;
  final String editorId;
  final List<AssigningControlEntity>? assigningControls;
  final ChampionStatus? status;

  const UpdateChampionParams({
    required this.championEmail,
    required this.moduleId,
    required this.editorId,
    this.assigningControls,
    this.status,
  });
}

class UpdateChampionUseCase {
  const UpdateChampionUseCase(this._repository);

  final ChampionRepository _repository;

  Future<Either<Failure, ChampionEntity>> call(UpdateChampionParams params) {
    return _repository.updateChampion(
      championEmail: params.championEmail,
      moduleId: params.moduleId,
      editorId: params.editorId,
      assigningControls: params.assigningControls,
      status: params.status,
    );
  }
}
