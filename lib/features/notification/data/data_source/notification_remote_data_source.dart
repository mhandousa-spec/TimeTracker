/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_remote_data_source.dart
/// Purpose: Firestore access for notification documents.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import '../models/notification_model_core.dart' show NotificationModel;

class NotificationRemoteDataSource {
  WriteBatch _batch = FirebaseFirestore.instance.batch();

  addNotificationToFirebase({
    required NotificationModel model,
    required List<String> emails,
    required String currentUserEmail,
  }) async {
    _batch = FirebaseFirestore.instance.batch();

    for (String email in emails) {
      FirebaseRepository.setDocumentWithIdWithBatch(
          collection: getBaseUrl('Notifications/$email/Notifications'),
          data: model.toMap(),
          documentId: model.notificationId,
          batch: _batch);
    }
    Either<Failure, dynamic> result;
    try {
      result = await FirebaseRepository.commitBatch(batch: _batch);
    } catch (e) {
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }
}
