/// Module: knowledge_hub / presentation / cubit / dashboard_cubit/dashboard_cubit.dart
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_cubit.dart
/// Purpose: Manages dashboard data and analytics
/// Author: Youssef Khaled
/// Created At: 28/10/2025
/// Updated: Filter all charts to show only published documents + Department filtering

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../main_controller/data/services/dashboard_firebase_services.dart';
import '../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../main_controller/data/models/document_utilization_model.dart';
import './dashboard_states.dart';


part './dashboard_cubit.part.1.dart';
part './dashboard_cubit.part.2.dart';

class DashboardCubit extends Cubit<DashboardStates> {

  final DashboardFirebaseServices _dashboardServices;


  List<CreateKnowledgeModel> _allDocuments = [];

  List<CreateKnowledgeModel> _publishedDocuments = []; // ✅ Only published documents
  List<DocumentUtilizationModel> _allUtilization = [];

  Map<String, String> _departmentNames = {};


  DashboardCubit(this._dashboardServices) : super(DashboardInitial());
}
