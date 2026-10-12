// ignore_for_file: dangling_library_doc_comments

/// Module: Policy Management
/// Description: Handles uploading Policy images and Policy/Control documents
///              to Firebase Storage, returning public download URLs to be
///              stored in the Firestore document fields.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: firebase_storage
/// Revision History: 2025-01-15 - Initial creation
///                   2026-07-14 - Migrated to the new schema: Policy and
///                                Control documents are now split into
///                                separate En/Ar fields, so uploads take a
///                                [DocumentLanguage] and are stored under
///                                per-language subfolders (Mohamed Magdy
///                                Abdelkhalek)

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

/// class name: [DocumentLanguage]
///
/// purpose: distinguish which localized document variant (English or
///          Arabic) a Policy/Control document upload belongs to, matching
///          the `_En` / `_Ar` suffixed fields in the new schema
///          (Policy_Document_En/Ar, Controls_Document_En/Ar).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 14/7/2026
enum DocumentLanguage {
  en,
  ar;

  /// the folder segment used when building the Storage path for this
  /// language, e.g. ".../Documents/En/...".
  String get folderName {
    switch (this) {
      case DocumentLanguage.en:
        return 'En';
      case DocumentLanguage.ar:
        return 'Ar';
    }
  }
}

/// ************************* FILE INFO *************************** ///
/// File Name: policy_storage_data_source.dart
/// Purpose: Contains the PolicyStorageDataSource class responsible for
///          uploading and deleting Policy images and documents on Firebase
///          Storage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyStorageDataSource]
///
/// purpose: upload Policy images and documents (Policy_Document_En/Ar,
///          Controls_Document_En/Ar) to Firebase Storage and return their
///          public download URLs, which are then saved inside the
///          corresponding Firestore fields. Each upload is stored under a
///          structured path that keeps policy and control files, and their
///          English/Arabic variants, separated.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyStorageDataSource {
  PolicyStorageDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  // Storage folder structure:
  // Policies_Files/
  //   └── {policyId}/
  //         ├── Images/                  ← policy image
  //         ├── Documents/
  //         │     ├── En/                ← policy document (English)
  //         │     └── Ar/                ← policy document (Arabic)
  //         └── Controls/
  //               └── {controlId}/
  //                     └── Documents/
  //                           ├── En/     ← control document (English)
  //                           └── Ar/     ← control document (Arabic)
  static String get _rootFolder => GrcFirebasePaths.policiesFilesFolder;

  // ------------------------------------------------------------------
  // POLICY IMAGE
  // ------------------------------------------------------------------

  /// function name: [uploadPolicyImage]
  ///
  /// purpose: upload a Policy image file to Firebase Storage and return
  ///          its public download URL. The URL is what should be passed
  ///          as the [policyImage] field in [PolicyModel.create] or
  ///          [PolicyModel.copyWithUpdate].
  ///
  /// parameters:
  ///            [String] policyId: id of the Policy the image belongs to
  ///            [File] imageFile: the local image file to upload
  ///
  /// return type: [Future<String>] - the download URL of the uploaded image, or throws an Exception on failure
  Future<String> uploadPolicyImage({
    required String policyId,
    required File imageFile,
  }) async {
    try {
      final fileName = _buildFileName(imageFile);
      final ref =
          _storage.ref('$_rootFolder/$policyId/Images/$fileName');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Policy image: $e');
    }
  }

  // ------------------------------------------------------------------
  // POLICY DOCUMENT
  // ------------------------------------------------------------------

  /// function name: [uploadPolicyDocument]
  ///
  /// purpose: upload a Policy document file (English or Arabic variant) to
  ///          Firebase Storage and return its public download URL. The URL
  ///          is what should be passed as the [policyDocumentEn] or
  ///          [policyDocumentAr] field in [PolicyModel.create] or
  ///          [PolicyModel.copyWithUpdate], depending on [language].
  ///
  /// parameters:
  ///            [String] policyId: id of the Policy the document belongs to
  ///            [File] documentFile: the local document file to upload
  ///            [DocumentLanguage] language: which localized field this upload is for (En/Ar)
  ///
  /// return type: [Future<String>] - the download URL of the uploaded document, or throws an Exception on failure
  Future<String> uploadPolicyDocument({
    required String policyId,
    required File documentFile,
    required DocumentLanguage language,
  }) async {
    try {
      final fileName = _buildFileName(documentFile);
      final ref = _storage.ref(
        '$_rootFolder/$policyId/Documents/${language.folderName}/$fileName',
      );
      final uploadTask = await ref.putFile(documentFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Policy document: $e');
    }
  }

  // ------------------------------------------------------------------
  // CONTROL DOCUMENT
  // ------------------------------------------------------------------

  /// function name: [uploadControlDocument]
  ///
  /// purpose: upload a Control document file (English or Arabic variant) to
  ///          Firebase Storage and return its public download URL. The URL
  ///          is what should be passed as the [controlsDocumentEn] or
  ///          [controlsDocumentAr] field when building a [ControlModel],
  ///          depending on [language]. Files are stored under the policy's
  ///          folder to keep all related assets together.
  ///
  /// parameters:
  ///            [String] policyId: id of the Policy that owns this Control
  ///            [String] controlId: id of the Control the document belongs to
  ///            [File] documentFile: the local document file to upload
  ///            [DocumentLanguage] language: which localized field this upload is for (En/Ar)
  ///
  /// return type: [Future<String>] - the download URL of the uploaded control document, or throws an Exception on failure
  Future<String> uploadControlDocument({
    required String policyId,
    required String controlId,
    required File documentFile,
    required DocumentLanguage language,
  }) async {
    try {
      final fileName = _buildFileName(documentFile);
      final ref = _storage.ref(
        '$_rootFolder/$policyId/Controls/$controlId/Documents/${language.folderName}/$fileName',
      );
      final uploadTask = await ref.putFile(documentFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Control document: $e');
    }
  }

  // ------------------------------------------------------------------
  // ASSIGNMENT CONTROL EVIDENCE
  // ------------------------------------------------------------------

  /// function name: [uploadAssignmentEvidence]
  ///
  /// purpose: upload a Control Champion's submitted evidence file to
  ///          Firebase Storage and return its public download URL, to be
  ///          stored as one revision of AssignmentControlModel's
  ///          submissionDocument history list. Stored under a top-level
  ///          folder (not under Policies_Files) since Assignment_Controls
  ///          documents live directly under the Module, not under a Policy.
  ///
  /// parameters:
  ///            [String] moduleId: id of the GRC Module the assignment belongs to
  ///            [String] controlId: id of the Control the evidence is for
  ///            [String] championEmail: email of the champion submitting
  ///            [File] documentFile: the local evidence file to upload
  ///
  /// return type: [Future<String>] - the download URL of the uploaded evidence file, or throws an Exception on failure
  Future<String> uploadAssignmentEvidence({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required File documentFile,
  }) async {
    try {
      final fileName = _buildFileName(documentFile);
      final ref = _storage.ref(
        '${GrcFirebasePaths.assignmentControlsFilesFolder}/$moduleId/$controlId/$championEmail/$fileName',
      );
      final uploadTask = await ref.putFile(documentFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Assignment Control evidence: $e');
    }
  }

  // ------------------------------------------------------------------
  // DELETE (shared for any file)
  // ------------------------------------------------------------------

  /// function name: [deleteFile]
  ///
  /// purpose: delete any previously uploaded file from Firebase Storage
  ///          using its download URL. Used to clean up old images or
  ///          documents when they are replaced by newer uploads.
  ///
  /// parameters:
  ///            [String] fileUrl: the download URL of the file to delete
  ///
  /// return type: [Future<void>] - completes when the deletion has finished, or throws an Exception on failure
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete the file from Storage: $e');
    }
  }

  // ------------------------------------------------------------------
  // PRIVATE HELPERS
  // ------------------------------------------------------------------

  /// function name: [_buildFileName]
  ///
  /// purpose: generate a unique file name by prefixing the original file
  ///          name with the current timestamp in milliseconds, preventing
  ///          name collisions on Storage when the same file is uploaded
  ///          multiple times.
  ///
  /// parameters:
  ///            [File] file: the local file whose name will be used as suffix
  ///
  /// return type: [String] - the generated unique file name
  String _buildFileName(File file) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final originalName = file.uri.pathSegments.last;
    return '${timestamp}_$originalName';
  }
}