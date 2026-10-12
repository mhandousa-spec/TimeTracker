/// Module: knowledge_hub / presentation / cubit / create_comment_cubit/create_comment_states.dart
import '../../../main_controller/data/models/create_new_comment_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: comments_state.dart
/// Purpose: Contains all states for comments management
/// Author: Youssef Khaled
/// Created At: 12/10/2025


abstract class CommentsState {}

/// Initial State
class CommentsInitial extends CommentsState {}

/// Loading States
class CommentsLoading extends CommentsState {}

class CreateCommentLoading extends CommentsState {}

class UploadAttachmentLoading extends CommentsState {}

/// Success States
class CommentsLoadedSuccess extends CommentsState {
  final List<CreateNewCommentModel> comments;

  CommentsLoadedSuccess(this.comments);
}

class CreateCommentSuccess extends CommentsState {
  final CreateNewCommentModel comment;

  CreateCommentSuccess(this.comment);
}

class UploadAttachmentSuccess extends CommentsState {
  final Map<String, dynamic> attachmentData;

  UploadAttachmentSuccess(this.attachmentData);
}

class DeleteCommentSuccess extends CommentsState {}

/// Failure States
class CommentsLoadedFailure extends CommentsState {
  final String error;

  CommentsLoadedFailure(this.error);
}

class CreateCommentFailure extends CommentsState {
  final String error;

  CreateCommentFailure(this.error);
}

class UploadAttachmentFailure extends CommentsState {
  final String error;

  UploadAttachmentFailure(this.error);
}

class DeleteCommentFailure extends CommentsState {
  final String error;

  DeleteCommentFailure(this.error);
}

/// File Action States
class RecordFileActionLoading extends CommentsState {}

class RecordFileActionSuccess extends CommentsState {
  final String actionType; // 'download' or 'view'

  RecordFileActionSuccess(this.actionType);
}

class RecordFileActionFailure extends CommentsState {
  final String error;

  RecordFileActionFailure(this.error);
}
