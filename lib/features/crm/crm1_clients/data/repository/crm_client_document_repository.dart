// ****************** FILE INFO ******************
// File Name: crm_client_document_repository.dart
// Purpose: Repository for client document operations.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/data_source/crm_client_documents_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_document_model.dart';

class CrmClientDocumentRepository {
  final CrmClientDocumentsRemoteDataSource _source;

  CrmClientDocumentRepository({CrmClientDocumentsRemoteDataSource? source})
      : _source = source ?? CrmClientDocumentsRemoteDataSource();

  Stream<List<CrmClientDocumentModel>> watch(String clientId) =>
      _source.watch(clientId);

  Future<CrmClientDocumentModel> uploadFile({
    required String clientId,
    required List<int> bytes,
    required String fileName,
    required String uploadedBy,
    required String uploadedByName,
  }) =>
      _source.uploadFile(
        clientId: clientId,
        bytes: bytes,
        fileName: fileName,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
      );

  Future<void> remove({
    required String clientId,
    required String documentId,
  }) =>
      _source.remove(clientId: clientId, documentId: documentId);
}
