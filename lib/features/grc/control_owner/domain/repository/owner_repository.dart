// lib/features/grc/control_owner/domain/repository/owner_repository.dart
/// Module: Control Owner Management
/// Description: Domain-layer repository contract for Control Owner
///              operations. Knows only about Entities and Failures.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, OwnerEntity, OwnerStatus, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';

abstract class OwnerRepository {
  Future<Either<Failure, OwnerEntity>> createOwner({
    bool canGiveScore = true,
    required String moduleId,
    required String ownerEmail,
    required List<AssigningControlEntity> assigningControls,
    required String editorId,
  });

  Future<Either<Failure, OwnerEntity>> getOwner(
    String ownerEmail, {
    required String moduleId,
  });

  Future<Either<Failure, List<OwnerEntity>>> getAllOwners({
    required String moduleId,
    bool includeRemoved = false,
  });

  Future<Either<Failure, OwnerEntity>> updateOwner({
    required String ownerEmail,
    required String moduleId,
    required String editorId,
    List<AssigningControlEntity>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    OwnerStatus? status,
  });

  Future<Either<Failure, List<ControlOwnerHistoryEntry>>> getControlOwnerHistory({
    required String moduleId,
    required String policyId,
    required String controlId,
  });
}
