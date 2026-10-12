/// Module: services_management_module
/// Description: Cubit owning all I/O for the s10 employee-action comment
///              thread (load / send text / send attachment / edit / delete).
///              Mirrors s6's ChatCubit pattern but keeps its own Firestore
///              queries because this screen resolves the parent request
///              document by scanning `emailRequester` (array-contains the
///              current employee's email) rather than a direct `.doc(id)`
///              lookup, so it does not fit the module-root ChatRepositoryImpl
///              shape as-is. Attachment picking goes through
///              MediaPickerService, not file_picker/image_picker directly.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, cloud_firestore, firebase_storage,
///               shared_preferences, MediaPickerService, ChatState,
///               employeeFunctionHelper (data/helper/csv_helper.dart)
/// Revision History: Initial version — extracted from
///                    s10_services_provider/ui/widgets/chat.dart (audit fix 1a).
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final MediaPickerService mediaPicker;
  final String modelId;

  ChatCubit({
    required this.modelId,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    MediaPickerService? mediaPicker,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance,
        mediaPicker = mediaPicker ?? MediaPickerService(),
        super(const ChatInitial());

  /// Resolves the parent request document the same way the original widget
  /// did: scan requests where the current employee's email appears in
  /// `emailRequester`, then match by [modelId].
  Future<DocumentReference<Map<String, dynamic>>> _requestDocRef() async {
    final requestQuerySnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("emailRequester", arrayContains: employeeFunctionHelper.email)
        .get();

    final requestDoc = requestQuerySnapshot.docs.firstWhere(
      (doc) => doc.id == modelId,
      orElse: () => throw Exception("Request document not found"),
    );
    return requestDoc.reference;
  }

  CollectionReference<Map<String, dynamic>> _commentsOf(
    DocumentReference<Map<String, dynamic>> requestDoc,
  ) {
    return requestDoc.collection('comments');
  }

  Future<void> loadComments() async {
    emit(const ChatLoading());
    try {
      final requestDoc = await _requestDocRef();
      final querySnapshot =
          await _commentsOf(requestDoc).orderBy('timestamp').get();

      final loadedMessages = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessageModel(
          senderName: data['senderName'] ?? '',
          senderTitle: data['senderTitle'] ?? '',
          avatarPath: 'assets/icons_assets/main_icons_assets/person_outline.png',
          text: data['text'],
          imagePath: data['imagePath'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          docId: doc.id,
        );
      }).toList();

      emit(ChatLoaded(messages: loadedMessages));
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

      final requestDoc = await _requestDocRef();
      await _commentsOf(requestDoc).add({
        'senderName': sender['fullName'],
        'senderTitle': sender['jobTitle'],
        'text': trimmed,
        'timestamp': now,
      });

      await loadComments();
    } catch (e) {
      emit(ChatError('Error sending message: $e'));
      emit(current);
    }
  }

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
    final ref = storage.ref(
      '${getBaseUrl(FirestoreCollections.commentsAttachmentsStorage)}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );
    await ref.putFile(File(filePath));
    final downloadUrl = await ref.getDownloadURL();

    final now = DateTime.now();
    final requestDoc = await _requestDocRef();
    await _commentsOf(requestDoc).add({
      'senderName': sender['fullName'],
      'senderTitle': sender['jobTitle'],
      'text': fileName,
      'imagePath': downloadUrl,
      'timestamp': now,
    });

    await loadComments();
  }

  Future<void> editMessage({
    required String docId,
    required String newText,
  }) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;

    try {
      final requestDoc = await _requestDocRef();
      await _commentsOf(requestDoc).doc(docId).update({'text': trimmed});
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
      final requestDoc = await _requestDocRef();
      await _commentsOf(requestDoc).doc(docId).delete();
      await loadComments();
    } catch (e) {
      emit(ChatError('Error deleting message: $e'));
      emit(current);
    }
  }
}
