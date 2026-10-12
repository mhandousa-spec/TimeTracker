/// Module: time_tracker / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_storage_remote_data_source.dart
/// Purpose: Declares `TimeTrackerStorageRemoteDataSource` — the only class
///          that writes Time Tracker files to Firebase Storage.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
/// Updated: 9/10/2026 - phase 3: group pictures (`Group_Images` folder).
///
/// Same pattern as the app's feedback attachment upload
/// (settings/se7_app_info, `putData` + `getDownloadURL`): the stored name is
/// prefixed with a timestamp so two files called "scan.pdf" never overwrite
/// each other, and anything that could create a folder is replaced. Path:
/// `Demo/{cid}/Modules/time_tracker/Request_Attachments/{email}/{ms}_{name}`.
/// Refuses an empty company (same guard as the Firestore data sources).
/// Throws on failure (no try/catch — repository's job).

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';

/// Where one uploaded file landed.
class StoredFile {
  const StoredFile({required this.url, required this.sizeBytes});

  final String url;
  final int sizeBytes;
}

class TimeTrackerStorageRemoteDataSource {
  TimeTrackerStorageRemoteDataSource({FirebaseStorage? storage})
      : _storage = storage;

  /// Lazily resolved so constructing the data source (DI, tests) never
  /// touches Firebase.
  final FirebaseStorage? _storage;

  FirebaseStorage get _bucket => _storage ?? FirebaseStorage.instance;

  /// Function Name: [upload]
  ///
  /// Purpose: Store [bytes] under the employee's folder.
  ///
  /// Parameters:
  ///   [String] emailKey: lower-cased email (folder).
  ///   [String] fileName
  ///   [List<int>] bytes
  ///   [DateTime] now: the name prefix.
  ///   [String] folder: the module folder (9/10/2026 — group pictures use
  ///   `groupImagesStorage`; default = request attachments).
  ///
  /// Return type: [Future<StoredFile>]
  Future<StoredFile> upload({
    required String emailKey,
    required String fileName,
    required List<int> bytes,
    required DateTime now,
    String folder = TimeTrackerFirestorePaths.requestAttachmentsStorage,
  }) async {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the file '
        'cannot be stored.',
      );
    }
    final String safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    final String path = getBaseUrl(
      '$folder/$emailKey/'
      '${now.millisecondsSinceEpoch}_$safeName',
    );
    final Reference ref = _bucket.ref().child(path);
    final Uint8List data = Uint8List.fromList(bytes);
    await ref.putData(data);
    return StoredFile(url: await ref.getDownloadURL(), sizeBytes: data.lengthInBytes);
  }

  /// Function Name: [deleteByUrl]
  ///
  /// Purpose: ADDED 9/10/2026 — delete the stored file behind a download
  /// [url]. Used ONLY by the debug "Remove demo data" tool for the PDFs it
  /// uploaded itself. Throws on failure.
  ///
  /// Return type: [Future<void>]
  Future<void> deleteByUrl(String url) => _bucket.refFromURL(url).delete();
}
