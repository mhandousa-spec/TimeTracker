/// Module: messaging / chat / presentation/controller/message_types_controllers/document_message_cubit.dart
import 'dart:io';

import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import 'package:pdfx/pdfx.dart';

import '../../../data/models/message/doc_message_model.dart';
import '../../../domain/entity/new_message_content_entity.dart';
import '../../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../../../../../core/helper/message_module/main_helper/chat_constants.dart';

// State class
class DocumentMessageState {
  final bool isPickingDocument;
  final bool isSendingDocument;
  final List<File> selectedDocuments;
  final String? error;
  final int uploadProgress;

  DocumentMessageState({
    this.isPickingDocument = false,
    this.isSendingDocument = false,
    this.selectedDocuments = const [],
    this.error,
    this.uploadProgress = 0,
  });

  DocumentMessageState copyWith({
    bool? isPickingDocument,
    bool? isSendingDocument,
    List<File>? selectedDocuments,
    String? Function()? error,
    int? uploadProgress,
  }) {
    return DocumentMessageState(
      isPickingDocument: isPickingDocument ?? this.isPickingDocument,
      isSendingDocument: isSendingDocument ?? this.isSendingDocument,
      selectedDocuments: selectedDocuments ?? this.selectedDocuments,
      error: error != null ? error() : this.error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

// Cubit
class DocumentMessageCubit extends Cubit<DocumentMessageState> {
  final MasterChatCubit masterChatCubit;
  final BaseChatRepository chatRepository;

  DocumentMessageCubit({
    required this.masterChatCubit,
    required this.chatRepository,
  }) : super(DocumentMessageState());

  /// ✅ Pick documents → add to preview queue (NO immediate send)
  Future<void> pickDoc({required BuildContext context}) async {
    emit(state.copyWith(isPickingDocument: true, error: () => null));

    try {
      // Picker owned by MediaPickerService — cubit no longer touches FilePicker (§16).
      final paths = await MediaPickerService()
          .pickFilePaths(allowedExtensions: ChatConstants.docExtensions);

      emit(state.copyWith(isPickingDocument: false));

      if (paths.isNotEmpty) {
        final files = paths.map((p) => File(p)).toList();

        // ✅ Store in local state
        final updated = List<File>.from(state.selectedDocuments)..addAll(files);
        emit(state.copyWith(selectedDocuments: updated));

        // ✅ Add to master preview queue
        masterChatCubit.addSelectedDocPaths(paths);
      }
    } catch (e) {
      emit(state.copyWith(
        isPickingDocument: false,
        error: () => 'Failed to pick documents. Please try again.',
      ));
    }
  }

  /// ✅ Send documents from path list (called from MasterChatCubit.applySelectedMessageAction)
  Future<void> sendMultipleDocumentsFromPaths(List<String> paths) async {
    emit(state.copyWith(isSendingDocument: true, error: () => null));

    try {
      for (int i = 0; i < paths.length; i++) {
        final file = File(paths[i]);
        if (!file.existsSync()) {
          continue;
        }

        await sendDocumentMessage(doc: file);

        final progress = ((i + 1) / paths.length * 100).round();
        emit(state.copyWith(uploadProgress: progress));
      }

      emit(state.copyWith(
        isSendingDocument: false,
        selectedDocuments: [],
        uploadProgress: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSendingDocument: false,
        error: () => 'Failed to send some documents. Please try again.',
      ));
    }
  }

  /// Legacy: send from File list directly
  Future<void> sendMultipleDocuments(List<File> documents) async {
    final paths = documents.map((f) => f.path).toList();
    await sendMultipleDocumentsFromPaths(paths);
  }

  Future<void> docUploadListener(DocMessageModel model) async {
    // CHANGED 29/9/2026 (bug report p.13/p.14 — "loading too much to upload
    // document", the spinner kept turning after the message had appeared).
    // This used to RENDER page 1 at half size and store the raw image bytes
    // in the message document as a Firestore ARRAY OF INTEGERS — tens of
    // thousands of array elements per message, so the batch commit took
    // ages (and could hit the 1 MB document limit). The preview it fed is
    // commented out in DocBubble, so nothing ever showed it. Only the page
    // count is read now; non-PDF files skip even that.
    if (!model.docPath.toLowerCase().endsWith('.pdf')) return;
    try {
      final doc = await PdfDocument.openFile(model.docPath);
      model.totalPages = doc.pagesCount;
      await doc.close();
    } catch (e) {
      debugPrint('[DocumentMessageCubit] page count failed: $e');
    }
  }

  Future<void> sendDocumentMessage({required File doc}) async {
    try {
      DocMessageModel docMessageModel = DocMessageModel(docPath: doc.path);

      await docUploadListener(docMessageModel);

      NewMessageContentEntity messageContent =
      DocumentMessageContentEntity(documentMessageModel: docMessageModel);

      final currentUser = masterChatCubit.state.currentUser;
      final otherConnectionSide = masterChatCubit.state.otherConnectionSide;

      if (currentUser == null || otherConnectionSide == null) {
        throw Exception('Missing user or connection data');
      }

      await chatRepository.sendNewMessage(
        currentUser: currentUser,
        otherConnectionSide: otherConnectionSide,
        messageContent: messageContent,
      );
    } catch (e) {
      rethrow;
    }
  }

  void clearError() {
    emit(state.copyWith(error: () => null));
  }

  void reset() {
    emit(DocumentMessageState());
  }

  void cancelSending() {
    emit(state.copyWith(
      isSendingDocument: false,
      selectedDocuments: [],
      uploadProgress: 0,
    ));
  }
}