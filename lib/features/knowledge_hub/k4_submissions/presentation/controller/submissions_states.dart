/// Module: knowledge_hub / presentation / cubit / submissions_cubit/submissions_states.dart

import '../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../main_controller/data/models/create_new_comment_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: submissions_states.dart
/// Purpose: Contains all the states of Submissions screen.
/// Author: Youssef Khaled
/// Created At: 14/10/2025

abstract class SubmissionsStates {}

class SubmissionsInitial extends SubmissionsStates {}

class ChangeIndexSuccessState extends SubmissionsStates {
  final int index;
  ChangeIndexSuccessState(this.index);
}

class ChangeInnerIndexSuccessState extends SubmissionsStates {
  final int index;
  ChangeInnerIndexSuccessState(this.index);
}

class FetchingSubmissionsLoadingState extends SubmissionsStates {}

class FetchingSubmissionsSuccessState extends SubmissionsStates {
  final List<CreateKnowledgeModel> knowledgeList;
  FetchingSubmissionsSuccessState(this.knowledgeList);
}

class FetchingSubmissionsEmptyState extends SubmissionsStates {}

class FetchingSubmissionsErrorState extends SubmissionsStates {
  final String error;
  FetchingSubmissionsErrorState(this.error);
}

// ✅ ADD THESE NEW STATES FOR COMMENTS
class FetchingCommentsLoadingState extends SubmissionsStates {}

class FetchingCommentsSuccessState extends SubmissionsStates {
  final List<CreateNewCommentModel> comments;
  FetchingCommentsSuccessState(this.comments);
}

class FetchingCommentsEmptyState extends SubmissionsStates {}

class FetchingCommentsErrorState extends SubmissionsStates {
  final String error;
  FetchingCommentsErrorState(this.error);
}

class AddingCommentLoadingState extends SubmissionsStates {}

class AddingCommentSuccessState extends SubmissionsStates {}

class AddingCommentErrorState extends SubmissionsStates {
  final String error;
  AddingCommentErrorState(this.error);
}

class RecordFileActionLoading extends SubmissionsStates {}

class RecordFileActionSuccess extends SubmissionsStates {
  final String typeOfAction;

  RecordFileActionSuccess(this.typeOfAction);
}

class RecordFileActionFailure extends SubmissionsStates {
  final String error;

  RecordFileActionFailure(this.error);
}

class UpdatingCommentLoadingState extends SubmissionsStates {}

class UpdatingCommentSuccessState extends SubmissionsStates {}

class UpdatingCommentErrorState extends SubmissionsStates {
  final String error;
  UpdatingCommentErrorState(this.error);
}

// ============= DELETE COMMENT STATES =============
class DeletingCommentLoadingState extends SubmissionsStates {}

class DeletingCommentSuccessState extends SubmissionsStates {}

class DeletingCommentErrorState extends SubmissionsStates {
  final String error;
  DeletingCommentErrorState(this.error);
}
