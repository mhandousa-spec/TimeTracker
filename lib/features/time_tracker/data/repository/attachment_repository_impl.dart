/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_repository_impl.dart
/// Purpose: Declares `AttachmentRepositoryImpl` — validates and uploads one
///          request / transaction file through
///          `TimeTrackerStorageRemoteDataSource`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
/// Updated: 9/10/2026 - phase 3: group pictures (`Group_Images` folder).
///
/// Refuses empty files, files over 10 MB and a missing email BEFORE any
/// bytes travel; Firebase failures become clean `Exception`s.

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_storage_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';

class AttachmentRepositoryImpl implements AttachmentBaseRepository {
  AttachmentRepositoryImpl({
    required TimeTrackerStorageRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final TimeTrackerStorageRemoteDataSource _remote;

  /// Message of the size refusal (the UI shows its own localized text).
  static const String tooLarge = 'The file is larger than 10 MB.';

  @override
  Future<String> uploadGroupImage({
    required String uploaderEmail,
    required String fileName,
    required List<int> bytes,
  }) async {
    if (bytes.isEmpty) throw Exception('The file is empty.');
    if (bytes.length > AttachmentBaseRepository.maxSizeBytes) {
      throw Exception(tooLarge);
    }
    try {
      final StoredFile stored = await _remote.upload(
        emailKey: TimeTrackerFirestorePaths.emailKey(uploaderEmail),
        fileName: fileName,
        bytes: bytes,
        now: DateTime.now(),
        folder: TimeTrackerFirestorePaths.groupImagesStorage,
      );
      return stored.url;
    } catch (error) {
      throw _clean(error);
    }
  }

  @override
  Future<RequestAttachment> uploadRequestAttachment({
    required String employeeEmail,
    required String fileName,
    required List<int> bytes,
  }) async {
    if (bytes.isEmpty) throw Exception('The file is empty.');
    if (bytes.length > AttachmentBaseRepository.maxSizeBytes) {
      throw Exception(tooLarge);
    }
    try {
      final DateTime now = DateTime.now();
      final StoredFile stored = await _remote.upload(
        emailKey: TimeTrackerFirestorePaths.emailKey(employeeEmail),
        fileName: fileName,
        bytes: bytes,
        now: now,
      );
      return RequestAttachment(
        name: fileName,
        url: stored.url,
        sizeBytes: stored.sizeBytes,
        uploadedAt: now,
      );
    } catch (error) {
      throw _clean(error);
    }
  }

  static Exception _clean(Object error) {
    if (error is FirebaseException) {
      return Exception('Could not upload the file (${error.code}).');
    }
    if (error is StateError) return Exception(error.message);
    if (error is Exception) return error;
    return Exception('Could not upload the file: $error');
  }
}
