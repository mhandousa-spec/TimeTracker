/// Module: roles / r5_system_logs / data / data_source / remote_data_source
///
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';

///****************** FILE INFO ********************///
/// FILE NAME: system_logs_remote_data_source.dart
/// PURPOSE: handle all network request of module.
/// Author: Amr Mesbah
/// CREATED AT: 2/2/2025

class SystemLogsRemoteDataSource {
  /// Method Name: [addActivityLog]
  ///
  /// Description: this method will add the activity log to the system logs.
  ///
  /// Parameters:
  ///           [SystemLogsModel] systemLogsModel: the model that will be added to the system logs.
  ///
  /// Return Value: [Future<Either<Failure,dynamic>>] the result of the operation.
  addActivityLog(SystemLogsModel systemLogsModel) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.systemLogs,
        data: systemLogsModel.toMap(),
        documentId: Timestamp.now().toString() + systemLogsModel.userEmail!);
  }

  /// Method Name: [getSystemLogs]
  ///
  /// Description: this method will get the most recent 500 system log entries,
  ///              ordered by timestamp descending, to avoid loading the entire collection.
  ///
  /// Return Value: [Future<Either<Failure, dynamic>>] the result of the operation.
  getSystemLogs() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(ApiConstants.systemLogs)
          .orderBy(SystemLogsModel.TIMESTAMP, descending: true)
          .limit(500)
          .get();
      final List<Map<String, dynamic>> data = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return Right<Failure, dynamic>(data);
    } catch (e) {
      return Left<Failure, dynamic>(FirebaseFailure(e.toString()));
    }
  }
}
