/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_repository_main_core.dart
/// Purpose: Notification reads for the app shell.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_remote_data_source.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_model_core.dart';


class NotificationRepository {
  NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSource();
  Future<Either<Failure, dynamic>> addNotifications({
    required String titleEnglish,
    required String titleArabic,
    required String bodyEnglish,
    required String bodyArabic,
    required String type,
    required List<String> emails,
    required String currentUserEmail,
    required Map<String, dynamic> payLoad,
  }) async {
    NotificationModel model = NotificationModel(
      notificationId:
          currentUserEmail + Timestamp.now().microsecondsSinceEpoch.toString(),
      titleEnglish: titleEnglish,
      bodyEnglish: bodyEnglish,
      titleArabic: titleArabic,
      bodyArabic: bodyArabic,
      type: type,
      seen: false,
      timestamp: Timestamp.now(),
      payLoad: payLoad,
    );

    return await notificationRemoteDataSource.addNotificationToFirebase(
        model: model, emails: emails, currentUserEmail: currentUserEmail);
  }
}
