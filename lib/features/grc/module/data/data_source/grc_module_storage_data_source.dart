/// Module: GRC Module Management
/// Description: Handles uploading GRC Module images to Firebase Storage and
///              returning the public download URL to be stored in the
///              Firestore document (Image field).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: firebase_storage
/// Revision History: 2026-06-30 - Initial creation

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_storage_data_source.dart
/// Purpose: Contains the GRCModuleStorageDataSource class responsible for
///          uploading/deleting GRC Module images on Firebase Storage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleStorageDataSource]
///
/// purpose: upload a GRC Module image file to Firebase Storage and return
///          its download URL, which is then saved inside the model's
///          [GRCModuleModel.image] field (NOT the raw file). Also supports
///          removing an image file from Storage when needed.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleStorageDataSource {
  GRCModuleStorageDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static String get _storageFolder => GrcFirebasePaths.moduleImagesFolder;

  /// function name: [uploadImage]
  ///
  /// purpose: upload an image file to Firebase Storage under a path unique
  ///          to the given module id, then return its public download URL.
  ///          The returned URL is what should be passed to
  ///          [GRCModuleModel.create] or [GRCModuleModel.copyWithUpdate] as
  ///          the `image` value.
  ///
  /// parameters:
  ///            [String] moduleId: id of the GRC Module the image belongs to
  ///            [File] imageFile: the local image file to upload
  ///
  /// return type: [Future<String>] - the download URL of the uploaded image, or throws an Exception on failure
  Future<String> uploadImage({
    required String moduleId,
    required File imageFile,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
      final ref = _storage.ref('$_storageFolder/$moduleId/$fileName');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload the GRC Module image: $e');
    }
  }

  /// function name: [deleteImage]
  ///
  /// purpose: delete a previously uploaded image from Firebase Storage using
  ///          its download URL.
  ///
  /// parameters:
  ///            [String] imageUrl: the download URL of the image to delete
  ///
  /// return type: [Future<void>] - completes when the deletion has finished, or throws an Exception on failure
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete the GRC Module image: $e');
    }
  }
}