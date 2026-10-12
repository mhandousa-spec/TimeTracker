/// Module: knowledge_hub / presentation / cubit / approvals_cubit/approvals_cubit.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_cubit.dart
/// Purpose: Contains all the functions to view Submitted files with filtering.
/// Author: Youssef Khaled
/// Created At: 14/10/2025
/// Updated: Supervisor-based approval system

import 'dart:developer';
import 'package:get/get.dart'; // ✅ Add this at the top of your file
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
// CHANGED 1/9/2026 — the approvals cubit no longer talks to FCM or Firestore
// to send a notification. `notification_page_config.dart`
// (NotificationServiceApp), `api_constants.dart` (to build the Notifications
// path by hand) and `knowledge_hub_firebase_services.dart` (to write the
// record) were imported for exactly that and are gone with it. Everything
// goes through the module's own notification service, which is the rule the
// rest of the app already follows.
import '../../../main_controller/data/notifications/knowledge_hub_notification_service.dart';
import '../../../main_controller/data/services/approvals_firebase_services.dart';
import '../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../main_controller/data/models/create_new_comment_model.dart';
import '../../../main_controller/data/models/employee_data.dart';
import './approvals_states.dart';
// ADDED 2/9/2026 — the permission guards in approvals_cubit.part.2.dart.
import '../../../main_controller/helper/knowledge_hub_permissions.dart';


part './approvals_cubit.part.1.dart';
part './approvals_cubit.part.2.dart';

class ApprovalsCubit extends Cubit<ApprovalsStates> {

  final ApprovalsFirebaseServices _firebaseServices;


  int selectedStatusIndex = 0;

  int selectedInnerStatusIndex = 0;

  String? selectedDocumentType;

  String? selectedStatus; // Upper category status

  /// Whether the FILTER DIALOG has anything applied — what lights the Filter
  /// button up.
  ///
  /// ADDED 12/9/2026. The button used to read [selectedStatus] & friends
  /// directly, but [selectedStatus] is ALSO written by the category tab row
  /// above the list (filterByStatus / filterByStatusKey set it to 'All',
  /// 'Pending', …). So the button came up primary the moment the screen
  /// opened, before the user had opened the dialog at all, let alone picked
  /// anything in its dropdowns — it read as "filters are on" permanently and
  /// so meant nothing.
  ///
  /// This is set ONLY by [ApprovalsCubitPart1.applyFilters] (the dialog's
  /// Apply) and cleared by [ApprovalsCubitPart2.resetFilters], so it answers
  /// the question the button is actually asking. Tapping a category tab does
  /// not touch it.
  bool dialogFilterActive = false;
  String? selectedInnerStatus; // Inner status filter
  DateTime? selectedStartDate;

  DateTime? selectedEndDate;

  List<CreateKnowledgeModel> allKnowledge = [];

  List<CreateKnowledgeModel> filteredKnowledge = [];

  List<CreateKnowledgeModel> upperCategoryFiltered = []; // Stores upper category results
  String searchQuery = '';

  List<CreateNewCommentModel> currentComments = [];

  String? currentKnowledgeId;


  // ✅ Current logged-in user email
  String? currentUserEmail;


  // ✅ Cache for user data to avoid repeated fetches
  Map<String, EmployeeData> _usersCache = {};


  // ✅ Cache for department names to avoid repeated fetches
  Map<String, String> _departmentsCache = {};


  // Status counts for UI
  Map<String, int> statusCounts = {
    'All': 0,
    'Approved': 0,
    'Pending': 0,
    'Rejected': 0,
    'Removed': 0,
    'Archive': 0,
  };





  ApprovalsCubit(this._firebaseServices) : super(ApprovalsInitial());


  Map<String, EmployeeData> get usersCache => _usersCache;

  Map<String, String> get departmentsCache => _departmentsCache;
}
