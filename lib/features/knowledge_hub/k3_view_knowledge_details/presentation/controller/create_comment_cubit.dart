/// Module: knowledge_hub / presentation / cubit / create_comment_cubit/create_comment_cubit.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comments_cubit.dart
/// Purpose: Manages comments state and business logic
/// Author: Youssef Khaled
/// Created At: 12/10/2025
/// Updated: Refactored to match simplified comment model

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

// ADDED 1/9/2026 — a new comment raises §1.1 "New Inquiry Received" to the
// document's owner. The owner and the document's bilingual names are not on
// the comment record, so the knowledge document is looked up to find them.
import '../../../main_controller/data/notifications/knowledge_hub_notification_service.dart';
import '../../../main_controller/data/services/knowledge_hub_firebase_services.dart';
import '../../../main_controller/data/services/create_comment_firebase_service.dart';
import '../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../main_controller/data/models/create_new_comment_model.dart';
import '../../../main_controller/data/models/document_utilization_model.dart';
import '../../../main_controller/data/models/employee_data.dart';
import './create_comment_states.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final CommentsFirebaseServices _commentsServices;

  List<CreateNewCommentModel> _commentsList = [];
  Map<String, dynamic>? _attachmentData;
  List<DocumentUtilizationModel> _fileActionsList = [];

  // ✅ Cache for user data to avoid repeated fetches
  Map<String, EmployeeData> _usersCache = {};

  CommentsCubit(this._commentsServices) : super(CommentsInitial());

  List<CreateNewCommentModel> get commentsList => _commentsList;
  Map<String, dynamic>? get attachmentData => _attachmentData;
  List<DocumentUtilizationModel> get fileActionsList => _fileActionsList;
  Map<String, EmployeeData> get usersCache => _usersCache;

  /// Fetch comments for a specific knowledge document
  Future<void> fetchComments(String knowledgeId) async {
    emit(CommentsLoading());
    try {
      final comments = await _commentsServices.fetchCommentsByKnowledgeId(
        knowledgeId,
      );
      _commentsList = comments;

      // ✅ Fetch user data for all comment creators
      await _fetchUsersForComments(comments);

      emit(CommentsLoadedSuccess(comments));
    } catch (e) {
      log('Error in fetchComments: $e');
      emit(CommentsLoadedFailure(e.toString()));
    }
  }

  /// ✅ Helper: Fetch user data for all comments
  Future<void> _fetchUsersForComments(
    List<CreateNewCommentModel> comments,
  ) async {
    try {
      // Extract unique user IDs
      final userIds = comments
          .map((c) => c.currentCreatedById)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();

      if (userIds.isEmpty) return;

      // Batch fetch user data
      final newUsers = await _commentsServices.fetchMultipleUserData(userIds);

      // Add to cache
      _usersCache.addAll(newUsers);

      log('Cached ${newUsers.length} user records');
    } catch (e) {
      log('Error fetching users for comments: $e');
    }
  }

  /// Get user data for a specific userId (from cache or fetch)
  Future<EmployeeData?> getUserData(String userId) async {
    // Check cache first
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }

    // Fetch if not in cache
    try {
      final userData = await _commentsServices.fetchUserDataByUserId(userId);
      if (userData != null) {
        _usersCache[userId] = userData;
      }
      return userData;
    } catch (e) {
      log('Error fetching user data for $userId: $e');
      return null;
    }
  }

  /// Listen to comments stream for real-time updates
  void listenToComments(String knowledgeId) {
    _commentsServices
        .streamCommentsByKnowledgeId(knowledgeId)
        .listen(
          (comments) async {
            _commentsList = comments;

            // ✅ Fetch user data for any new users
            await _fetchUsersForComments(comments);

            emit(CommentsLoadedSuccess(comments));
          },
          onError: (error) {
            log('Error in listenToComments: $error');
            emit(CommentsLoadedFailure(error.toString()));
          },
        );
  }

  /// Upload attachment for comment
  Future<void> uploadAttachment(File file) async {
    emit(UploadAttachmentLoading());
    try {
      final attachmentData = await _commentsServices.uploadCommentAttachment(
        file,
      );

      if (attachmentData != null) {
        _attachmentData = attachmentData;
        emit(UploadAttachmentSuccess(attachmentData));
      } else {
        emit(UploadAttachmentFailure('Failed to upload attachment'));
      }
    } catch (e) {
      log('Error in uploadAttachment: $e');
      emit(UploadAttachmentFailure(e.toString()));
    }
  }

  /// Clear attachment data
  void clearAttachment() {
    _attachmentData = null;
  }

  /// Create a new comment
  /// Note: Only createdById and createdByEmail are stored in comment
  /// User details (name, photo, etc.) are fetched when displaying
  Future<void> createComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
  }) async {
    emit(CreateCommentLoading());
    try {
      final success = await _commentsServices.createComment(
        knowledgeId: knowledgeId,
        commentText: commentText,
        createdById: createdById,
        createdByEmail: createdByEmail,
        attachmentExtension: _attachmentData?['extension'],
        attachmentSize: _attachmentData?['size'],
      );

      if (success) {
        // Clear attachment after successful creation
        final tempAttachmentData = _attachmentData;
        _attachmentData = null;

        // Create a temporary comment model for immediate display
        final newComment = CreateNewCommentModel.createNew(
          commentId: DateTime.now().millisecondsSinceEpoch.toString(),
          commentText: commentText,
          createdById: createdById,
          createdByEmail: createdByEmail,
          attachmentExtension: tempAttachmentData?['extension'],
          attachmentSize: tempAttachmentData?['size'],
        );

        emit(CreateCommentSuccess(newComment));

        // ADDED 1/9/2026 — §1.1 "New Inquiry Received".
        //
        // A comment on a Knowledge Hub document is the spec's "Inquiry or
        // Comment Submitted" trigger, and nothing raised it: someone could
        // ask a question on a policy and its owner would only find out by
        // opening the document and scrolling. The template existed in
        // Notification Control with no sender behind it.
        //
        // Fire-and-forget, AFTER the success state is emitted: the comment is
        // already saved, and the reader should not wait on a document lookup
        // and a notification round trip to see their own comment appear.
        // `notifyOwnerOfInquiry` drops the self-notification when the
        // commenter IS the owner.
        unawaited(
          _notifyDocumentOwnerOfInquiry(
            knowledgeId: knowledgeId,
            commenterEmail: createdByEmail,
          ),
        );

        // Refresh comments list
        await fetchComments(knowledgeId);
      } else {
        emit(CreateCommentFailure('Failed to create comment'));
      }
    } catch (e) {
      log('Error in createComment: $e');
      emit(CreateCommentFailure(e.toString()));
    }
  }

  /// Function Name: [_notifyDocumentOwnerOfInquiry]
  ///
  /// Purpose: Resolve the commented-on document, then tell its owner a new
  /// inquiry arrived (§1.1 "New Inquiry Received").
  ///
  /// ADDED 1/9/2026. The comment record stores only `knowledgeId` and the
  /// commenter, so the owner and the document's two names have to be looked
  /// up. `createdByEmail` on a knowledge document is a HISTORY array — the
  /// author is `.first`; `.last` is whoever most recently acted on it, which
  /// for a removed or re-approved document is somebody else entirely.
  ///
  /// Never throws: a notification failure must not surface as a comment
  /// failure, since the comment itself was saved before this runs.
  Future<void> _notifyDocumentOwnerOfInquiry({
    required String knowledgeId,
    required String commenterEmail,
  }) async {
    try {
      final CreateKnowledgeModel? document =
          await KnowledgeHubFirebaseServices()
              .fetchKnowledgeByKnowledgeId(knowledgeId);
      if (document == null) return;

      final String ownerEmail = document.createdByEmail.isNotEmpty
          ? document.createdByEmail.first
          : document.currentCreatedByEmail;
      if (ownerEmail.isEmpty) return;

      await KnowledgeHubNotificationService.notifyOwnerOfInquiry(
        commenterEmail: commenterEmail,
        ownerEmail: ownerEmail,
        documentNameEn: document.currentNameEnglish,
        documentNameAr: document.currentNameArabic,
        isArabic: Get.locale?.languageCode == 'ar',
      );
    } catch (e) {
      log('⚠️ [KH-NOTIFY] inquiry notification failed: $e');
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId, String knowledgeId) async {
    try {
      final success = await _commentsServices.deleteComment(commentId);

      if (success) {
        emit(DeleteCommentSuccess());
        // Refresh comments list
        await fetchComments(knowledgeId);
      } else {
        emit(DeleteCommentFailure('Failed to delete comment'));
      }
    } catch (e) {
      log('Error in deleteComment: $e');
      emit(DeleteCommentFailure(e.toString()));
    }
  }

  /// Get comment count
  Future<int> getCommentCount(String knowledgeId) async {
    try {
      return await _commentsServices.getCommentCount(knowledgeId);
    } catch (e) {
      log('Error in getCommentCount: $e');
      return 0;
    }
  }

  /// Record file action (download or view)
  Future<void> recordFileAction({
    required String knowledgeId,
    required String typeOfAction, // 'download' or 'view'
    required String userId,
  }) async {
    emit(RecordFileActionLoading());
    try {
      final success = await _commentsServices.recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: typeOfAction,
        userId: userId,
      );

      if (success) {
        emit(RecordFileActionSuccess(typeOfAction));
      } else {
        emit(RecordFileActionFailure('Failed to record $typeOfAction action'));
      }
    } catch (e) {
      log('Error in recordFileAction: $e');
      emit(RecordFileActionFailure(e.toString()));
    }
  }

  // 3️⃣ Replace fetchFileActions method
  /// Fetch file actions history
  /// ✅ Also fetches user data for all actions
  Future<List<DocumentUtilizationModel>> fetchFileActions(
    String knowledgeId,
  ) async {
    try {
      final actions = await _commentsServices.fetchFileActionsByKnowledgeId(
        knowledgeId,
      );
      _fileActionsList = actions;

      // ✅ Fetch user data for all action performers
      await _fetchUsersForFileActions(actions);

      return actions;
    } catch (e) {
      log('Error in fetchFileActions: $e');
      return [];
    }
  }

  // 4️⃣ Add new helper method (add this after fetchFileActions)
  /// ✅ Helper: Fetch user data for all file actions
  Future<void> _fetchUsersForFileActions(
    List<DocumentUtilizationModel> actions,
  ) async {
    try {
      // Extract unique user IDs from actions
      final userIds = actions
          .map((action) => action.currentUserId)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();

      if (userIds.isEmpty) return;

      // Batch fetch user data
      final newUsers = await _commentsServices.fetchMultipleUserData(userIds);

      // Add to cache
      _usersCache.addAll(newUsers);

      log('Cached ${newUsers.length} user records for file actions');
    } catch (e) {
      log('Error fetching users for file actions: $e');
    }
  }

  // 5️⃣ Replace listenToFileActions method
  /// Listen to file actions stream for real-time updates
  /// ✅ Also fetches user data when new actions arrive
  void listenToFileActions(String knowledgeId) {
    _commentsServices
        .streamFileActionsByKnowledgeId(knowledgeId)
        .listen(
          (actions) async {
            _fileActionsList = actions;

            // ✅ Fetch user data for any new users
            await _fetchUsersForFileActions(actions);

            log('File actions updated: ${actions.length} actions');
          },
          onError: (error) {
            log('Error in listenToFileActions: $error');
          },
        );
  }

  /// Clear the users cache (useful when user logs out or switches accounts)
  void clearUsersCache() {
    _usersCache.clear();
  }
}
