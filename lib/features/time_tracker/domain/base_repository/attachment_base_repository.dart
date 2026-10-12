/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_base_repository.dart
/// Purpose: Declares `AttachmentBaseRepository` — uploads one request /
///          transaction file ("Transaction Document", "Request Attachments")
///          and returns its `RequestAttachment` descriptor.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
/// Updated: 9/10/2026 - phase 3: group pictures (`Group_Images` folder).
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show.

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';

abstract class AttachmentBaseRepository {
  /// Largest file accepted (same 10 MB ceiling as the app's feedback upload).
  static const int maxSizeBytes = 10 * 1024 * 1024;

  /// Function Name: [uploadRequestAttachment]
  ///
  /// Purpose: Store [bytes] for [employeeEmail]'s request.
  ///
  /// Parameters:
  ///   [String] employeeEmail: the requester (folder key).
  ///   [String] fileName: the picked file's name.
  ///   [List<int>] bytes: its content (≤ [maxSizeBytes]).
  ///
  /// Return type: [Future<RequestAttachment>] — name, download URL, size and
  /// upload time.
  Future<RequestAttachment> uploadRequestAttachment({
    required String employeeEmail,
    required String fileName,
    required List<int> bytes,
  });

  /// Function Name: [uploadGroupImage]
  ///
  /// Purpose: Store a group picture (phase 3, 9/10/2026) under
  /// `Modules/time_tracker/Group_Images/{uploader}/`.
  ///
  /// Parameters:
  ///   [String] uploaderEmail · [String] fileName · [List<int>] bytes (≤ 10 MB)
  ///
  /// Return type: [Future<String>] — the download URL.
  Future<String> uploadGroupImage({
    required String uploaderEmail,
    required String fileName,
    required List<int> bytes,
  });
}
