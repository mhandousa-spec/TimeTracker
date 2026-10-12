// ****************** FILE INFO ******************
// File Name: crm_client_documents_state.dart
// Purpose: UI state for client documents.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_document_model.dart';

class CrmClientDocumentsState {
  final bool isLoading;
  final bool isUploading;
  final bool isGrid;
  final bool isEditMode;
  final String query;
  final String? sort;
  final String sourceFilter;
  final String? error;
  final String? successMessage;
  final List<CrmClientDocumentModel> documents;

  const CrmClientDocumentsState({
    this.isLoading = false,
    this.isUploading = false,
    this.isGrid = true,
    this.isEditMode = false,
    this.query = '',
    this.sort = 'newest',
    this.sourceFilter = 'All',
    this.error,
    this.successMessage,
    this.documents = const [],
  });

  CrmClientDocumentsState copyWith({
    bool? isLoading,
    bool? isUploading,
    bool? isGrid,
    bool? isEditMode,
    String? query,
    String? sort,
    bool clearSort = false,
    String? sourceFilter,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    List<CrmClientDocumentModel>? documents,
  }) {
    return CrmClientDocumentsState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      isGrid: isGrid ?? this.isGrid,
      isEditMode: isEditMode ?? this.isEditMode,
      query: query ?? this.query,
      sort: clearSort ? null : (sort ?? this.sort),
      sourceFilter: sourceFilter ?? this.sourceFilter,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      documents: documents ?? this.documents,
    );
  }
}
