/// Module: knowledge_hub / presentation / cubit / submissions_cubit/submissions_cubit.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submissions_cubit.dart
/// Purpose: Contains all the functions to view Submitted files with filtering.
/// Author: Youssef Khaled
/// Created At: 14/10/2025
/// Updated: Added user-specific filtering - only show current user's documents

import 'dart:convert';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/services/knowledge_hub_firebase_services.dart';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/controller/submissions_states.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';

import '../../../../../core/network/api_constants.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../main_controller/domain/constants/constant.dart';
import '../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../main_controller/data/models/create_new_comment_model.dart';
import '../../../main_controller/data/models/employee_data.dart';
import '../../../main_controller/data/services/submissions_firebase_service.dart';


part './submissions_cubit.part.1.dart';
part './submissions_cubit.part.2.dart';
part './submissions_cubit.part.3.dart';

class SubmissionsCubit extends Cubit<SubmissionsStates> {

  final SubmissionsFirebaseServices _firebaseServices;


  int selectedStatusIndex = 0;

  int selectedInnerStatusIndex = 0;

  String? selectedDocumentType;

  String? selectedStatus;

  String? selectedInnerStatus;

  String? selectedDepartment;

  DateTime? selectedStartDate;

  DateTime? selectedEndDate;

  List<CreateKnowledgeModel> allKnowledge = [];

  List<CreateKnowledgeModel> filteredKnowledge = [];

  List<CreateKnowledgeModel> upperCategoryFiltered = [];

  String searchQuery = '';

  List<CreateNewCommentModel> currentComments = [];

  String? currentKnowledgeId;


  Map<String, EmployeeData> _usersCache = {};


  Map<String, int> statusCounts = {
    'All': 0,
    'Published': 0,
    'Approved': 0,
    'Pending': 0,
    'Rejected': 0,
    'Removed': 0,
    'Archive': 0,
  };


  List<String> availableDepartments = [];


  // ✅ NEW: Current user email for filtering
  String? _currentUserEmail;


  SubmissionsCubit(this._firebaseServices) : super(SubmissionsInitial());


  Map<String, EmployeeData> get usersCache => _usersCache;
}
