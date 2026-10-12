// ****************** FILE INFO ******************
// File Name: crm_client_activity_remote_data_source.dart
// Purpose: Firestore persistence for client activities.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmClientActivityRemoteDataSource {
  final FirebaseFirestore _firestore;
  CrmClientActivityRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _ref(String clientId) => _firestore
      .collection('${CrmFirestorePaths.clientRecords}/$clientId/Activities');
  Stream<List<CrmClientActivityModel>> watch(String clientId) =>
      _ref(clientId).snapshots().map((snapshot) => snapshot.docs
          .map((doc) => CrmClientActivityModel.fromMap(
              <String, dynamic>{...doc.data(), 'Id': doc.id}))
          .where((item) => !item.isDeletedRecord)
          .toList());
  Future<void> save(CrmClientActivityModel activity) async {
    final DocumentReference<Map<String, dynamic>> doc = activity.id.isEmpty
        ? _ref(activity.clientId).doc()
        : _ref(activity.clientId).doc(activity.id);
    await doc.set(activity.copyWith(id: doc.id).toMap());
  }

  Future<void> remove({required String clientId, required String activityId}) =>
      _ref(clientId)
          .doc(activityId)
          .update(<String, dynamic>{'Is_Deleted': true, 'Status': 'deleted'});
}
