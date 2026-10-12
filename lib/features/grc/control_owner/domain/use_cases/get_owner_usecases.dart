// lib/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart
/// Module: Control Owner Management
/// Description: Use cases for reading a single/all Control Owner records.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, OwnerEntity, OwnerRepository

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/repository/owner_repository.dart';

class GetOwnerUseCase {
  const GetOwnerUseCase(this._repository);

  final OwnerRepository _repository;

  Future<Either<Failure, OwnerEntity>> call(
    String ownerEmail, {
    required String moduleId,
  }) {
    return _repository.getOwner(ownerEmail, moduleId: moduleId);
  }
}

class GetAllOwnersUseCase {
  const GetAllOwnersUseCase(this._repository);

  final OwnerRepository _repository;

  Future<Either<Failure, List<OwnerEntity>>> call({
    required String moduleId,
    bool includeRemoved = false,
  }) {
    return _repository.getAllOwners(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
  }
}
