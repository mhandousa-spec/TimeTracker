// ****************** FILE INFO ******************
// File Name: crm_blacklist_repository.dart
// Purpose: Repository for managing CRM blacklisted clients and requests.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/repository/crm_clients_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/repository/crm_controls_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:get/get.dart';

class CrmBlacklistRepository {
  final CrmClientsBaseRepository _clientsRepository;
  final CrmControlsBaseRepository _controlsRepository;

  CrmBlacklistRepository({
    CrmClientsBaseRepository? clientsRepository,
    CrmControlsBaseRepository? controlsRepository,
  })  : _clientsRepository = clientsRepository ??
            (Get.isRegistered<CrmClientsBaseRepository>()
                ? Get.find<CrmClientsBaseRepository>()
                : (Get.isRegistered<CrmClientsRepository>()
                    ? Get.find<CrmClientsRepository>()
                    : CrmClientsRepository())),
        _controlsRepository = controlsRepository ??
            (Get.isRegistered<CrmControlsBaseRepository>()
                ? Get.find<CrmControlsBaseRepository>()
                : (Get.isRegistered<CrmControlsRepository>()
                    ? Get.find<CrmControlsRepository>()
                    : CrmControlsRepository()));

  /// Watch all client records in real-time.
  Stream<Either<Failure, List<CrmClientRecordModel>>> watchAllClientRecords() {
    return _clientsRepository.watchClientRecords();
  }

  /// Watch client types for type name resolution.
  Stream<Either<Failure, List<CrmClientTypeModel>>> watchClientTypes() {
    return _controlsRepository.watchClientTypes();
  }

  /// Unblock / remove a client from the blacklist.
  Future<Either<Failure, void>> unblockClient({
    required String recordId,
    required String reason,
    String userEmail = 'staff@knowticed.com',
  }) {
    return _clientsRepository.updateClientBlacklist(
      recordId: recordId,
      reason: reason,
      isRemovalRequest: true,
      userEmail: userEmail,
    );
  }
}
