// ****************** FILE INFO ******************
// File Name: crm_client_documents_cubit.dart
// Purpose: Business logic and state management for client documents.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'dart:async';
import 'dart:io';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_document_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/repository/crm_client_document_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_documents_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CrmClientDocumentsCubit extends Cubit<CrmClientDocumentsState> {
  final String clientId;
  final CrmClientDocumentRepository _repository;
  final MediaPickerService _mediaPickerService;
  StreamSubscription? _documentsSub;

  CrmClientDocumentsCubit({
    required this.clientId,
    CrmClientDocumentRepository? repository,
    MediaPickerService? mediaPickerService,
  })  : _repository = repository ?? CrmClientDocumentRepository(),
        _mediaPickerService = mediaPickerService ?? MediaPickerService(),
        super(const CrmClientDocumentsState());

  /// Function Name: init
  ///
  /// Purpose: Initializes the cubit by subscribing to the live stream of client documents.
  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _documentsSub = _repository.watch(clientId).listen(
      (List<CrmClientDocumentModel> items) {
        if (!isClosed) {
          emit(state.copyWith(documents: items, isLoading: false));
        }
      },
      onError: (Object e) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, error: e.toString()));
        }
      },
    );
  }

  /// Returns documents filtered by search query and source filter, sorted by active criteria.
  List<CrmClientDocumentModel> get visibleDocuments {
    final String q = state.query.trim().toLowerCase();
    final List<CrmClientDocumentModel> items =
        state.documents.where((CrmClientDocumentModel doc) {
      final bool matchesQuery = q.isEmpty ||
          doc.name.toLowerCase().contains(q) ||
          doc.uploadedByName.toLowerCase().contains(q) ||
          doc.extension.toLowerCase().contains(q);

      final bool matchesSource = state.sourceFilter == 'All' ||
          (state.sourceFilter == 'Client' && doc.uploadedBy.isEmpty) ||
          (state.sourceFilter == 'Staff' && doc.uploadedBy.isNotEmpty);

      return matchesQuery && matchesSource;
    }).toList();

    switch (state.sort) {
      case 'oldest':
        items.sort((a, b) => a.uploadedAt.compareTo(b.uploadedAt));
        break;
      case 'name_asc':
        items.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_desc':
        items.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'size_desc':
        items.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
      case 'size_asc':
        items.sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
        break;
      case 'newest':
      default:
        items.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        break;
    }

    return items;
  }

  /// Function Name: uploadCustomDocument
  ///
  /// Purpose: Handles file upload from the Adding Attachment dialog with a custom title.
  Future<bool> uploadCustomDocument({
    required PlatformFile file,
    required String customTitle,
  }) async {
    try {
      List<int>? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        final File localFile = File(file.path!);
        if (await localFile.exists()) {
          bytes = await localFile.readAsBytes();
        }
      }
      if (bytes == null || bytes.isEmpty) return false;

      emit(state.copyWith(
          isUploading: true, clearError: true, clearSuccess: true));

      String userEmail = '';
      String userName = 'Staff';
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final emp = Get.find<MainCoreEmployeeController>().employeeEntity;
        userEmail = emp?.email ?? '';
        final String nameParts = [emp?.firstName, emp?.lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        userName = nameParts.isNotEmpty ? nameParts : 'Staff';
      }

      String finalName = customTitle.trim();
      if (finalName.isEmpty) {
        finalName = file.name;
      } else if (file.extension != null &&
          file.extension!.isNotEmpty &&
          !finalName.contains('.')) {
        finalName = '$finalName.${file.extension}';
      }

      await _repository.uploadFile(
        clientId: clientId,
        bytes: bytes,
        fileName: finalName,
        uploadedBy: userEmail,
        uploadedByName: userName,
      );

      if (!isClosed) {
        emit(state.copyWith(
          isUploading: false,
          successMessage: 'Document uploaded successfully',
        ));
      }
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isUploading: false,
          error: e.toString(),
        ));
      }
      return false;
    }
  }

  /// Function Name: pickAndUploadDocument
  ///
  /// Purpose: Quick upload via native picker.
  Future<bool> pickAndUploadDocument() async {
    try {
      final PickedFileData? picked = await _mediaPickerService.pickAnyFile();
      if (picked == null || picked.bytes.isEmpty) return false;

      emit(state.copyWith(
          isUploading: true, clearError: true, clearSuccess: true));

      String userEmail = '';
      String userName = 'Staff';
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final emp = Get.find<MainCoreEmployeeController>().employeeEntity;
        userEmail = emp?.email ?? '';
        final String nameParts = [emp?.firstName, emp?.lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        userName = nameParts.isNotEmpty ? nameParts : 'Staff';
      }

      await _repository.uploadFile(
        clientId: clientId,
        bytes: picked.bytes,
        fileName: picked.name,
        uploadedBy: userEmail,
        uploadedByName: userName,
      );

      if (!isClosed) {
        emit(state.copyWith(
          isUploading: false,
          successMessage: 'Document uploaded successfully',
        ));
      }
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isUploading: false,
          error: e.toString(),
        ));
      }
      return false;
    }
  }

  /// Function Name: removeDocument
  ///
  /// Purpose: Removes (soft deletes) a document from the client profile.
  Future<bool> removeDocument(String documentId) async {
    try {
      await _repository.remove(clientId: clientId, documentId: documentId);
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(error: e.toString()));
      }
      return false;
    }
  }

  void toggleEditMode() {
    if (!isClosed) emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void setEditMode(bool value) {
    if (!isClosed) emit(state.copyWith(isEditMode: value));
  }

  void setSourceFilter(String source) {
    if (!isClosed) emit(state.copyWith(sourceFilter: source));
  }

  void setQuery(String value) {
    if (!isClosed) emit(state.copyWith(query: value));
  }

  void setSort(String? value) {
    if (!isClosed) emit(state.copyWith(sort: value, clearSort: value == null));
  }

  void setGrid(bool value) {
    if (!isClosed) emit(state.copyWith(isGrid: value));
  }

  void clearMessages() {
    if (!isClosed) emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  @override
  Future<void> close() async {
    await _documentsSub?.cancel();
    return super.close();
  }
}
