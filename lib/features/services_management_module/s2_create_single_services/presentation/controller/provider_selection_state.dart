// ******************* FILE INFO *******************
// File Name: provider_selection_state
// Description: Provider selection state.
// Module: services_management_module / presentation/s2_create_single_services/controller
// *************************************************

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/data/provider_selection_data.dart';

abstract class ProviderSelectionState {
  const ProviderSelectionState();
}

class ProviderSelectionInitial extends ProviderSelectionState {
  const ProviderSelectionInitial();
}

class ProviderSelectionLoading extends ProviderSelectionState {
  const ProviderSelectionLoading();
}

class ProviderSelectionLoaded extends ProviderSelectionState {
  final ProviderSelectionData data;
  final List<EmployeeEntityPro> allEmployees;
  final List<EmployeeEntityPro> filteredEmployees;
  final String searchQuery;

  const ProviderSelectionLoaded({
    required this.data,
    required this.allEmployees,
    required this.filteredEmployees,
    this.searchQuery = '',
  });

  ProviderSelectionLoaded copyWith({
    ProviderSelectionData? data,
    List<EmployeeEntityPro>? allEmployees,
    List<EmployeeEntityPro>? filteredEmployees,
    String? searchQuery,
  }) {
    return ProviderSelectionLoaded(
      data: data ?? this.data,
      allEmployees: allEmployees ?? this.allEmployees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProviderSelectionError extends ProviderSelectionState {
  final String message;
  const ProviderSelectionError(this.message);
}

class ProviderSelectionSaved extends ProviderSelectionState {
  const ProviderSelectionSaved();
}

/// 🔥 NEW: State for when draft is being saved to Firebase
/// 🔥 NEW: State for when draft is being saved to Firebase
class ProviderSelectionSaving extends ProviderSelectionState {
  final ProviderSelectionData data;
  final List<EmployeeEntityPro> allEmployees;

  const ProviderSelectionSaving({
    required this.data,
    required this.allEmployees,
  });
}

/// 🔥 NEW: State for when draft is successfully saved to Firebase
class ProviderSelectionSavedToFirebase extends ProviderSelectionState {
  final String draftId;

  const ProviderSelectionSavedToFirebase({required this.draftId});
}

class ProviderSelectionNavigateToDetails extends ProviderSelectionState {
  final ServicesHistoryModel completeModel;
  final String? docId;

  const ProviderSelectionNavigateToDetails({
    required this.completeModel,
    this.docId,
  });
}

class ProviderSelectionNavigateBack extends ProviderSelectionState {
  const ProviderSelectionNavigateBack();
}

class ProviderSelectionShowWarning extends ProviderSelectionState {
  final String message;
  const ProviderSelectionShowWarning(this.message);
}

class ProviderSelectionProviderUpdated extends ProviderSelectionState {
  const ProviderSelectionProviderUpdated();
}
