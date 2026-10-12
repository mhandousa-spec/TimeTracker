/// Module: Control Champion Management
/// Description: Domain-layer repository contract for Control Champion
///              operations. Knows only about Entities and Failures.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, ChampionEntity, ChampionStatus, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';

abstract class ChampionRepository {
  Future<Either<Failure, ChampionEntity>> createChampion({
    required String moduleId,
    required String championEmail,
    required List<AssigningControlEntity> assigningControls,
    required String editorId,
  });

  Future<Either<Failure, ChampionEntity>> getChampion(
    String championEmail, {
    required String moduleId,
  });

  Future<Either<Failure, List<ChampionEntity>>> getAllChampions({
    required String moduleId,
    bool includeRemoved = false,
  });

  Future<Either<Failure, ChampionEntity>> updateChampion({
    required String championEmail,
    required String moduleId,
    required String editorId,
    List<AssigningControlEntity>? assigningControls,
    ChampionStatus? status,
  });
}
