// ****************** FILE INFO ******************
// File Name: crm_client_activity_repository.dart
// Purpose: Repository for client activity records.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/data_source/crm_client_activity_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';

class CrmClientActivityRepository {
  final CrmClientActivityRemoteDataSource _source;
  CrmClientActivityRepository({CrmClientActivityRemoteDataSource? source})
      : _source = source ?? CrmClientActivityRemoteDataSource();
  Stream<List<CrmClientActivityModel>> watch(String clientId) =>
      _source.watch(clientId);
  Future<void> save(CrmClientActivityModel activity) => _source.save(activity);
  Future<void> remove({required String clientId, required String activityId}) =>
      _source.remove(clientId: clientId, activityId: activityId);
}
