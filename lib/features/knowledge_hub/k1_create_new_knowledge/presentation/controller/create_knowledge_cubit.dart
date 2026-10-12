/// Module: knowledge_hub / presentation / cubit / create_knowledge_cubit.dart
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_cubit.dart (DEBUG VERSION)
/// Purpose: Contains all the functions to view knowledge departments and files.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
///
/// ⚠️ DEBUG VERSION - Enhanced with detailed print statements to track filtering
///
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// CHANGED 1/9/2026 — submission notifications no longer go through FCM and a
// hand-written Firestore map from this cubit. `notification_page_config.dart`
// (NotificationServiceApp), `notification_data_model.dart` and
// `api_constants.dart` were imported only for that and are gone with it.
import '../../../main_controller/data/notifications/knowledge_hub_notification_service.dart';
import '../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../main_controller/data/services/knowledge_hub_firebase_services.dart';
import './cons.dart';
import '../../../k3_view_knowledge_details/presentation/controller/create_knowledge_state.dart';


part './create_knowledge_cubit.part.1.dart';
part './create_knowledge_cubit.part.2.dart';

class CreateKnowledgeCubit extends Cubit<CreateKnowledgeState> {

  final KnowledgeHubFirebaseServices _firebaseServices;


  List<CreateKnowledgeModel> allKnowledge = [];

  List<DepartmentModelPro> allDepartments = [];

  List<CreateKnowledgeModel> filteredKnowledge = [];

  int selectedDepartmentIndex = 0;

  String? selectedDocumentType;

  String? selectedOwningDepartment;

  String searchQuery = '';

  int selectedInnerIndex = 0;

  String? selectedInnerCategory;

  String? selectedOwningStatus;

  /// ADDED 28/8/2026 — publish-date range filter, set from FilterSearchDialog.
  /// Either end may be null: from-only means "published on or after", to-only
  /// means "published on or before", both null means the filter is off. Both
  /// hold a DAY (time 00:00); applyFilters widens the `to` end to the end of
  /// its day so a document published at 14:30 is not dropped by a `to` set to
  /// that same date.
  DateTime? selectedPublishFromDate;

  DateTime? selectedPublishToDate;


  String? currentUserDepartment;

  String? currentUserEmail;


  CreateKnowledgeModel? currentKnowledgeDocument;


  CreateKnowledgeCubit(this._firebaseServices)
      : super(CreateKnowledgeInitial());


  Map<String, String> departmentIdToNameMap = {};
}
