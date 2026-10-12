// ****************** FILE INFO ******************
// File Name: crm_merge_history_remote_data_source.dart
// Purpose: Persists CRM merge history and undo snapshots in Firestore
// Author: Mohand Adel
// Created At: 28/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmMergeHistoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmMergeHistoryRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Either<Failure, List<CrmMergeHistoryModel>>> getMergeHistory() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.mergeHistory).get();
      final List<CrmMergeHistoryModel> history = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) {
        return CrmMergeHistoryModel.fromMap(<String, dynamic>{
          ...document.data(),
          'id': document.id,
        });
      }).toList()
        ..sort((CrmMergeHistoryModel first, CrmMergeHistoryModel second) =>
            second.mergedAt.compareTo(first.mergedAt));
      return Right(history);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> saveMergeHistory({
    required CrmMergeHistoryModel history,
  }) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.mergeHistory)
          .doc(history.id)
          .set(history.toMap());
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }
}
