/// Module: knowledge_hub / presentation / cubit / create_comment_cubit/create_knowledge_state.dart
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import '../../../main_controller/data/models/create_knowledge_new_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_state.dart
/// Purpose: Contains all the states of viewing knowledge hub departments and files.
/// Author: Youssef Khaled
/// Created At: 11/10/2025


abstract class CreateKnowledgeState {}

class CreateKnowledgeInitial extends CreateKnowledgeState {}

class ChangedIndexSuccessState extends CreateKnowledgeState {
  final int index;
  ChangedIndexSuccessState(this.index);
}

class FetchingKnowledgeLoadingState extends CreateKnowledgeState {}

class FetchingKnowledgeSuccessState extends CreateKnowledgeState {
  final List<CreateKnowledgeModel> knowledgeList;
  FetchingKnowledgeSuccessState(this.knowledgeList);
}

class FetchingKnowledgeEmptyState extends CreateKnowledgeState {}

class FetchingKnowledgeErrorState extends CreateKnowledgeState {
  final String error;
  FetchingKnowledgeErrorState(this.error);
}

class FetchingDepartmentLoadingState extends CreateKnowledgeState {}

class FetchingDepartmentSuccessState extends CreateKnowledgeState {
  final List<DepartmentModelPro> departmentList;
  FetchingDepartmentSuccessState(this.departmentList);
}

class FetchingDepartmentErrorState extends CreateKnowledgeState {
  final String error;
  FetchingDepartmentErrorState(this.error);
}

class FetchingKnowledgeByIdLoadingState extends CreateKnowledgeState {}

class FetchingKnowledgeByIdSuccessState extends CreateKnowledgeState {
  final CreateKnowledgeModel knowledge;
  
  FetchingKnowledgeByIdSuccessState(this.knowledge);
}

class FetchingKnowledgeByIdErrorState extends CreateKnowledgeState {
  final String error;
  
  FetchingKnowledgeByIdErrorState(this.error);
}

class ChangedInnerIndexSuccessState extends CreateKnowledgeState {
  final int index;
  
  ChangedInnerIndexSuccessState(this.index);
}