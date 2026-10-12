/// Module: knowledge_hub / presentation / cubit / approvals_cubit/approvals_states.dart
import '../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../main_controller/data/models/create_new_comment_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: approvals_states.dart
/// Purpose: States for ApprovalsCubit
/// Author: Youssef Khaled

abstract class ApprovalsStates {}

class ApprovalsInitial extends ApprovalsStates {}

// ==================== Fetching Approvals States ====================
class FetchingApprovalsLoadingState extends ApprovalsStates {}

class FetchingApprovalsSuccessState extends ApprovalsStates {
  final List<CreateKnowledgeModel> approvals;
  FetchingApprovalsSuccessState(this.approvals);
}

class FetchingApprovalsEmptyState extends ApprovalsStates {}

class FetchingApprovalsErrorState extends ApprovalsStates {
  final String error;
  FetchingApprovalsErrorState(this.error);
}

// ==================== Status Index States ====================
class ChangeIndexSuccessState extends ApprovalsStates {
  final int index;
  ChangeIndexSuccessState(this.index);
}

// ==================== Comments States ====================
class FetchingCommentsLoadingState extends ApprovalsStates {}

class FetchingCommentsSuccessState extends ApprovalsStates {
  final List<CreateNewCommentModel> comments;
  FetchingCommentsSuccessState(this.comments);
}

class FetchingCommentsEmptyState extends ApprovalsStates {}

class FetchingCommentsErrorState extends ApprovalsStates {
  final String error;
  FetchingCommentsErrorState(this.error);
}

// ==================== Adding Comment States ====================
class AddingCommentLoadingState extends ApprovalsStates {}

class AddingCommentSuccessState extends ApprovalsStates {}

class AddingCommentErrorState extends ApprovalsStates {
  final String error;
  AddingCommentErrorState(this.error);
}

// ==================== File Action States ====================
class RecordFileActionLoading extends ApprovalsStates {}

class RecordFileActionSuccess extends ApprovalsStates {
  final String typeOfAction;
  RecordFileActionSuccess({required this.typeOfAction});
}

class RecordFileActionFailure extends ApprovalsStates {
  final String error;
  RecordFileActionFailure(this.error);
}

// ==================== Approve Knowledge States ====================
class ApprovingKnowledgeLoadingState extends ApprovalsStates {}

class ApprovingKnowledgeSuccessState extends ApprovalsStates {}

class ApprovingKnowledgeErrorState extends ApprovalsStates {
  final String error;
  ApprovingKnowledgeErrorState(this.error);
}

// ==================== Reject Knowledge States ====================
class RejectingKnowledgeLoadingState extends ApprovalsStates {}

class RejectingKnowledgeSuccessState extends ApprovalsStates {}

class RejectingKnowledgeErrorState extends ApprovalsStates {
  final String error;
  RejectingKnowledgeErrorState(this.error);
}