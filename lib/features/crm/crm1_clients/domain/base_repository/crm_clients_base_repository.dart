// ****************** FILE INFO ******************
// File Name: crm_clients_base_repository.dart
// Purpose: Abstract contract for the CRM client records repository. Cubits
//          depend on this interface instead of the concrete repository.
// Author: Mohand Adel
// Created At: 12/08/2026

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';

/// Feature-facing contract for CRM client record operations.
///
/// The concrete [CrmClientsRepository] implements this contract and owns
/// data-source orchestration; presentation never instantiates it directly.
abstract class CrmClientsBaseRepository {
  Stream<Either<Failure, List<CrmClientRecordModel>>> watchClientRecords({
    String? clientTypeId,
    String? templateId,
  });

  Stream<Either<Failure, CrmClientRecordModel?>> watchClientRecord({
    required String recordId,
  });

  Future<Either<Failure, CrmClientRecordModel>> saveClientRecord({
    required CrmClientRecordModel record,
  });

  Future<Either<Failure, void>> updateClientStatus({
    required String recordId,
    required String status,
    required String userEmail,
  });

  Future<Either<Failure, void>> updateClientBlacklist({
    required String recordId,
    required String reason,
    required bool isRemovalRequest,
    required String userEmail,
  });

  Future<Either<Failure, void>> softDeleteClientRecord({
    required String recordId,
    required String userEmail,
  });

  Future<Either<Failure, String>> uploadClientFile({
    required File file,
    required String recordId,
    required String fieldId,
  });
}
