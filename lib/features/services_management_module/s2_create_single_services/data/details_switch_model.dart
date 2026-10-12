// ******************* FILE INFO *******************
// File Name: details_switch_model.dart
// Description: Data model for Details Switch Screen
// Created by: Amr Mesbah
// Last Update: 01/12/2025

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/employee_card_item.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

class DetailsSwitchModel {
  bool limitAvailability = false;
  bool requireApproval = false;
  // ✅ `shouldPreventAutoRequester` removed alongside the auto-select of the
  // current user as first approver — there is no auto-selection left to guard
  // against, so the flag had nothing to prevent.
  bool didInitFromEditModel = false;
  bool navigated = false;
  bool isLoading = true;

  List<String> selectedDepartments = [];
  List<EmployeeEntityPro> allEmployees = [];
  List<EmployeeEntityPro> filteredEmployees = [];
  List<EmployeeEntityPro> selectedEmployees = [];

  final ServicesHistoryModel? editingModel;
  final String? docId;
  final bool isEditMode;

  DetailsSwitchModel({
    this.editingModel,
    this.docId,
  }) : isEditMode = editingModel != null;
}
