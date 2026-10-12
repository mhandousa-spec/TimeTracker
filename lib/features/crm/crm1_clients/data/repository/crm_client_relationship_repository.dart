// ****************** FILE INFO ******************
// File Name: crm_client_relationship_repository.dart
// Purpose: Repository implementation for client relationship management
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/data_source/crm_client_relationship_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';

class CrmClientRelationshipRepository {
  final CrmClientRelationshipRemoteDataSource _remoteDataSource;

  CrmClientRelationshipRepository(
      {CrmClientRelationshipRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? CrmClientRelationshipRemoteDataSource();

  Stream<List<CrmRelationshipCategoryModel>> watchCategories() {
    return _remoteDataSource.watchCategories();
  }

  Stream<List<CrmClientRelationshipModel>> watchClientRelationships(
      String clientId) {
    return _remoteDataSource.watchClientRelationships(clientId);
  }

  Future<Either<Failure, bool>> createRelationship({
    required String clientId,
    required CrmClientRelationshipModel relationship,
    required CrmAuditModel audit,
  }) async {
    final bool success = await _remoteDataSource.createRelationship(
      clientId: clientId,
      relationship: relationship,
      audit: audit,
    );
    if (success) {
      return const Right(true);
    }
    return const Left(
      FirebaseFailure(
        'Failed to create relationship',
      ),
    );
  }

  Future<Either<Failure, bool>> updateRelationship({
    required String clientId,
    required CrmClientRelationshipModel relationship,
    required CrmAuditModel audit,
  }) async {
    final bool success = await _remoteDataSource.updateRelationship(
      clientId: clientId,
      relationship: relationship,
      audit: audit,
    );
    if (success) {
      return const Right(true);
    }
    return const Left(
      FirebaseFailure(
        'Failed to update relationship',
      ),
    );
  }

  Future<Either<Failure, bool>> deleteRelationship({
    required String clientId,
    required String relationshipId,
    required CrmAuditModel audit,
  }) async {
    final bool success = await _remoteDataSource.deleteRelationship(
      clientId: clientId,
      relationshipId: relationshipId,
      audit: audit,
    );
    if (success) {
      return const Right(true);
    }
    return const Left(
      FirebaseFailure(
        'Failed to delete relationship',
      ),
    );
  }
}
