// ****************** FILE INFO ******************
// File Name: crm_clients_repository.dart
// Purpose: Repository facade for CRM client record operations
// Author: Mohand Adel
// Created At: 08/08/2026

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/data_source/crm_clients_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';

/// Stable feature-facing API for CRM client records. Presentation code must
/// depend on this repository (or the cubits) and never touch Firestore or
/// construct paths directly.
class CrmClientsRepository implements CrmClientsBaseRepository {
  final CrmClientsRemoteDataSource remoteDataSource;

  CrmClientsRepository({CrmClientsRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? CrmClientsRemoteDataSource();

  @override
  Stream<Either<Failure, List<CrmClientRecordModel>>> watchClientRecords({
    String? clientTypeId,
    String? templateId,
  }) {
    return remoteDataSource.watchClientRecords(
      clientTypeId: clientTypeId,
      templateId: templateId,
    );
  }

  @override
  Stream<Either<Failure, CrmClientRecordModel?>> watchClientRecord({
    required String recordId,
  }) {
    return remoteDataSource.watchClientRecord(recordId: recordId);
  }

  @override
  Future<Either<Failure, CrmClientRecordModel>> saveClientRecord({
    required CrmClientRecordModel record,
  }) {
    return remoteDataSource.saveClientRecord(record: record);
  }

  @override
  Future<Either<Failure, void>> updateClientStatus({
    required String recordId,
    required String status,
    required String userEmail,
  }) {
    return remoteDataSource.updateClientStatus(
      recordId: recordId,
      status: status,
      userEmail: userEmail,
    );
  }

  @override
  Future<Either<Failure, void>> updateClientBlacklist({
    required String recordId,
    required String reason,
    required bool isRemovalRequest,
    required String userEmail,
  }) {
    return remoteDataSource.updateClientBlacklist(
      recordId: recordId,
      reason: reason,
      isRemovalRequest: isRemovalRequest,
      userEmail: userEmail,
    );
  }

  @override
  Future<Either<Failure, void>> softDeleteClientRecord({
    required String recordId,
    required String userEmail,
  }) {
    return remoteDataSource.softDeleteClientRecord(
      recordId: recordId,
      userEmail: userEmail,
    );
  }

  @override
  Future<Either<Failure, String>> uploadClientFile({
    required File file,
    required String recordId,
    required String fieldId,
  }) {
    return remoteDataSource.uploadClientFile(
      file: file,
      recordId: recordId,
      fieldId: fieldId,
    );
  }
}
