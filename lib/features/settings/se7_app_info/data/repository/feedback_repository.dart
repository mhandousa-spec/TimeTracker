/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_repository.dart
/// Purpose: Implements [FeedbackBaseRepository] over the remote data source.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
/// Updated: 1/9/2026 - Added [listForEmployee].
///
/// The raw Firestore error is converted to a [Failure] here so the controller
/// never sees a `FirebaseException` and cannot interpolate it into a
/// user-facing message.

import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/data_source/remote_data_source/feedback_attachment_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/data_source/remote_data_source/feedback_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/base_repository/feedback_base_repository.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';

class FeedbackRepository implements FeedbackBaseRepository {
  FeedbackRepository({
    FeedbackRemoteDataSource? remoteDataSource,
    FeedbackAttachmentRemoteDataSource? attachmentDataSource,
  })  : _remoteDataSource = remoteDataSource ?? FeedbackRemoteDataSource(),
        _attachmentDataSource =
            attachmentDataSource ?? FeedbackAttachmentRemoteDataSource();

  final FeedbackRemoteDataSource _remoteDataSource;
  final FeedbackAttachmentRemoteDataSource _attachmentDataSource;

  @override
  Future<Either<Failure, void>> submit(AppFeedback feedback) async {
    if (feedback.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure('Cannot send: no feedback was entered.'),
      );
    }

    try {
      await _remoteDataSource.submit(feedback);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<FeedbackStatus, int>>> countsByStatus(
    String employeeId,
  ) async {
    if (employeeId.isEmpty) {
      return Left<Failure, Map<FeedbackStatus, int>>(
        FeatureFailure('No employee id available to count feedback for.'),
      );
    }

    try {
      return Right<Failure, Map<FeedbackStatus, int>>(
        await _remoteDataSource.countsByStatus(employeeId),
      );
    } catch (e) {
      return Left<Failure, Map<FeedbackStatus, int>>(
        FirebaseFailure(e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, List<FeedbackRequest>>> listForEmployee(
    String employeeId,
  ) async {
    // Left, not an empty Right: an empty id means the employee record has not
    // loaded, which is a different thing from "this person has submitted
    // nothing". The cubit shows the empty state for the second and keeps the
    // list untouched for the first.
    if (employeeId.isEmpty) {
      return Left<Failure, List<FeedbackRequest>>(
        FeatureFailure('No employee id available to read feedback for.'),
      );
    }

    try {
      return Right<Failure, List<FeedbackRequest>>(
        await _remoteDataSource.listForEmployee(employeeId),
      );
    } catch (e) {
      return Left<Failure, List<FeedbackRequest>>(
        FirebaseFailure(e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, FeedbackAttachment>> uploadAttachment({
    required FeedbackKind kind,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    if (bytes.isEmpty) {
      return Left<Failure, FeedbackAttachment>(
        FeatureFailure('That file is empty.'),
      );
    }

    try {
      final FeedbackAttachment attachment = await _attachmentDataSource.upload(
        kind: kind,
        fileName: fileName,
        bytes: bytes,
        // Passed in rather than read inside the data source so the storage
        // path is deterministic under test.
        now: DateTime.now(),
        contentType: contentType,
      );
      return Right<Failure, FeedbackAttachment>(attachment);
    } on StateError catch (e) {
      // The size ceiling — a message the user can act on, unlike a raw
      // FirebaseException.
      return Left<Failure, FeedbackAttachment>(FeatureFailure(e.message));
    } catch (e) {
      return Left<Failure, FeedbackAttachment>(FirebaseFailure(e.toString()));
    }
  }
}
