/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_attachment_remote_data_source.dart
/// Purpose: Uploads one feedback attachment to Firebase Storage.
/// Author: Knowticed Plus team
/// Created at: 24/8/2026
///
/// Separate from `feedback_remote_data_source.dart` because it talks to a
/// different backend: that one writes Firestore documents, this one writes
/// bytes to the storage bucket. The Firestore document only ever holds the
/// descriptor this returns.

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';

class FeedbackAttachmentRemoteDataSource {
  FeedbackAttachmentRemoteDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Root folder in the bucket. One sub-folder per feedback kind, so bug
  /// screenshots and feature-request mockups do not end up in one heap.
  static const String _root = 'app_feedback';

  /// Hard ceiling on a single upload.
  ///
  /// Enforced in the UI as well, but repeated here because this is the layer
  /// that would actually spend the user's bandwidth. Bytes are held in memory
  /// (see [FeedbackBaseRepository.uploadAttachment] on why), so an unbounded
  /// file would be an unbounded allocation.
  static const int maxSizeInBytes = 10 * 1024 * 1024;

  /// Function Name: [upload]
  ///
  /// Purpose: Store [bytes] and return where they landed.
  ///
  /// The stored name is prefixed with a timestamp so two people uploading
  /// `screenshot.png` do not overwrite each other — Storage has no
  /// auto-generated id the way `collection().doc()` does.
  Future<FeedbackAttachment> upload({
    required FeedbackKind kind,
    required String fileName,
    required Uint8List bytes,
    required DateTime now,
    String? contentType,
  }) async {
    if (bytes.lengthInBytes > maxSizeInBytes) {
      throw StateError('Attachment is larger than the ${maxSizeInBytes ~/ (1024 * 1024)}MB limit.');
    }

    final String safeName = _sanitise(fileName);
    final String path =
        '$_root/${kind.wireValue}/${now.millisecondsSinceEpoch}_$safeName';

    final Reference ref = _storage.ref().child(path);

    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    return FeedbackAttachment(
      url: await ref.getDownloadURL(),
      name: fileName,
      sizeInBytes: bytes.lengthInBytes,
      contentType: contentType,
      storagePath: path,
    );
  }

  /// Strips anything that would create an accidental folder or an unreadable
  /// object name. A `/` in the picked name would silently nest the file.
  String _sanitise(String fileName) {
    final String cleaned =
        fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'attachment' : cleaned;
  }
}
