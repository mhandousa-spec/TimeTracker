/// Module: services_management_module
/// Description: Cubit owning all I/O for the service-request comment thread
///              (load / send text / send attachment / edit / delete). All
///              Firestore + Storage access goes through ChatRepositoryImpl —
///              the widget only calls these methods and reacts to ChatState.
///              Attachment picking goes through MediaPickerService, not
///              file_picker/image_picker directly (audit fix #2).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, shared_preferences, MediaPickerService,
///               ChatRepositoryImpl, ChatState
/// Revision History: Initial version — extracted from chat.dart (audit fix #2/#3).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/chat_repository_impl.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/chat_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final ChatRepository repository;
  final MediaPickerService mediaPicker;
  final String modelId;

  ChatCubit({
    required this.modelId,
    ChatRepository? repository,
    MediaPickerService? mediaPicker,
  })  : repository = repository ?? ChatRepositoryImpl(),
        mediaPicker = mediaPicker ?? MediaPickerService(),
        super(const ChatInitial());

  Future<void> loadComments() async {
    emit(const ChatLoading());
    try {
      final messages = await repository.loadComments(modelId);
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError('Error loading comments: $e'));
    }
  }

  Future<Map<String, String>> _currentSenderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstNameRequester') ?? '';
    final lastName = prefs.getString('lastNameRequester') ?? '';
    final jobTitle = prefs.getString('jobTitleRequester') ?? '';
    return {
      'fullName': '$firstName $lastName'.trim(),
      'jobTitle': jobTitle,
    };
  }

  Future<void> sendTextMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    try {
      final sender = await _currentSenderInfo();
      final now = DateTime.now();

      await repository.sendComment(
        modelId: modelId,
        senderName: sender['fullName']!,
        senderTitle: sender['jobTitle']!,
        text: trimmed,
        timestamp: now,
      );

      await loadComments();
    } catch (e) {
      emit(ChatError('Error sending message: $e'));
      emit(current);
    }
  }

  /// Shows no UI — returns the chosen source string, or null if the caller
  /// should fall back to document picking. Widget presents the dialog and
  /// calls [sendImageMessage] / [sendDocumentMessage] based on the choice.
  Future<void> sendImageMessage({required bool fromCamera}) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    emit(current.copyWith(isBusy: true));

    try {
      final picked = await mediaPicker.pickImage(fromCamera: fromCamera);
      if (picked == null || picked.path == null) {
        emit(current.copyWith(isBusy: false));
        return;
      }
      await _uploadAndSend(filePath: picked.path!, fileName: picked.name);
    } catch (e) {
      emit(ChatError('Error uploading image: $e'));
      emit(current.copyWith(isBusy: false));
    }
  }

  Future<void> sendDocumentMessage() async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    emit(current.copyWith(isBusy: true));

    try {
      final picked = await mediaPicker.pickDocument();
      if (picked == null || picked.path == null) {
        emit(current.copyWith(isBusy: false));
        return;
      }
      await _uploadAndSend(filePath: picked.path!, fileName: picked.name);
    } catch (e) {
      emit(ChatError('Error uploading document: $e'));
      emit(current.copyWith(isBusy: false));
    }
  }

  Future<void> _uploadAndSend({
    required String filePath,
    required String fileName,
  }) async {
    final sender = await _currentSenderInfo();
    final downloadUrl = await repository.uploadAttachment(
      fileName: fileName,
      filePath: filePath,
    );

    final now = DateTime.now();
    await repository.sendAttachmentComment(
      modelId: modelId,
      senderName: sender['fullName']!,
      senderTitle: sender['jobTitle']!,
      text: fileName,
      imagePath: downloadUrl,
      timestamp: now,
    );

    await loadComments();
  }

  Future<void> editMessage({required String docId, required String newText}) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;

    try {
      await repository.editComment(modelId: modelId, docId: docId, newText: trimmed);
      await loadComments();
    } catch (e) {
      emit(ChatError('Error editing message: $e'));
      emit(current);
    }
  }

  Future<void> deleteMessage(String docId) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    try {
      await repository.deleteComment(modelId: modelId, docId: docId);
      await loadComments();
    } catch (e) {
      emit(ChatError('Error deleting message: $e'));
      emit(current);
    }
  }
}
