// ****************** FILE INFO ******************
// File Name: crm_client_documents_remote_data_source.dart
// Purpose: Remote Firestore and Firebase Storage data source for CRM client documents.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_document_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmClientDocumentsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CrmClientDocumentsRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _ref(String clientId) =>
      _firestore.collection(CrmFirestorePaths.clientDocuments(clientId));

  /// Stream of all active non-deleted documents for a client.
  Stream<List<CrmClientDocumentModel>> watch(String clientId) {
    return _ref(clientId).snapshots().map((snapshot) {
      final List<CrmClientDocumentModel> items = snapshot.docs
          .map((doc) => CrmClientDocumentModel.fromMap(<String, dynamic>{
                ...doc.data(),
                'Id': doc.id,
                'Client_Id': clientId
              }))
          .where((item) => !item.isDeleted)
          .toList();
      items.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return items;
    });
  }

  /// Uploads file bytes to Firebase Storage and writes metadata to Firestore.
  Future<CrmClientDocumentModel> uploadFile({
    required String clientId,
    required List<int> bytes,
    required String fileName,
    required String uploadedBy,
    required String uploadedByName,
  }) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String sanitizedFileName =
        fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final String storagePath = CrmFirestorePaths.clientDocumentFileStoragePath(
      clientId,
      '${timestamp}_$sanitizedFileName',
    );

    final Reference ref = _storage.ref().child(storagePath);
    final SettableMetadata metadata = SettableMetadata(
      customMetadata: <String, String>{
        'clientId': clientId,
        'uploadedBy': uploadedBy,
        'uploadedByName': uploadedByName,
        'originalName': fileName,
      },
    );

    final UploadTask task = ref.putData(Uint8List.fromList(bytes), metadata);
    final TaskSnapshot snapshot = await task;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    String ext = '';
    if (fileName.contains('.')) {
      ext = fileName.split('.').last.toLowerCase();
    }

    final DocumentReference<Map<String, dynamic>> docRef = _ref(clientId).doc();
    final CrmClientDocumentModel model = CrmClientDocumentModel(
      id: docRef.id,
      clientId: clientId,
      name: fileName,
      url: downloadUrl,
      sizeBytes: bytes.length,
      extension: ext,
      uploadedBy: uploadedBy,
      uploadedByName: uploadedByName,
      uploadedAt: DateTime.now(),
      storagePath: storagePath,
      isDeleted: false,
      audit: CrmAuditModel.now(userEmail: uploadedBy),
    );

    await docRef.set(model.toMap());
    return model;
  }

  /// Soft deletes a document record in Firestore.
  Future<void> remove({
    required String clientId,
    required String documentId,
  }) async {
    await _ref(clientId).doc(documentId).update(<String, dynamic>{
      'Is_Deleted': true,
      'Status': 'deleted',
    });
  }
}
