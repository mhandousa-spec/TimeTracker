// ******************* FILE INFO *******************
// File Name: my_request_state
// Description: My request state.
// Module: services_management_module / presentation/s6_services_requests/controller
// *************************************************

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

abstract class MyRequestState extends Equatable {
  const MyRequestState();

  @override
  List<Object?> get props => [];
}

class MyRequestInitial extends MyRequestState {
  const MyRequestInitial();
}

class MyRequestLoading extends MyRequestState {
  const MyRequestLoading();
}

class MyRequestLoaded extends MyRequestState {
  final List<ServicesHistoryModel> services;
  final List<Map<String, dynamic>> displayedItems;
  final List<ServicesHistoryModel> filteredModel;
  final String selectedStatus;
  final List<String> selectedDepartmentKeys;
  final String selectedSortOption;
  final String searchQuery;

  // Statistics
  final int totalServices;
  final int pendingCount;
  final int approvedCount;
  final int cancelCount;
  final int rejectedCount;
  final int inProgressCount;
  final int branchSlaCount;
  final int doneCount;

  const MyRequestLoaded({
    required this.services,
    required this.displayedItems,
    required this.filteredModel,
    this.selectedStatus = "All",
    this.selectedDepartmentKeys = const [],
    this.selectedSortOption = 'Date Requested',
    this.searchQuery = '',
    this.totalServices = 0,
    this.pendingCount = 0,
    this.approvedCount = 0,
    this.cancelCount = 0,
    this.rejectedCount = 0,
    this.inProgressCount = 0,
    this.branchSlaCount = 0,
    this.doneCount = 0,
  });

  MyRequestLoaded copyWith({
    List<ServicesHistoryModel>? services,
    List<Map<String, dynamic>>? displayedItems,
    List<ServicesHistoryModel>? filteredModel,
    String? selectedStatus,
    List<String>? selectedDepartmentKeys,
    String? selectedSortOption,
    String? searchQuery,
    int? totalServices,
    int? pendingCount,
    int? approvedCount,
    int? cancelCount,
    int? rejectedCount,
    int? inProgressCount,
    int? branchSlaCount,
    int? doneCount,
  }) {
    return MyRequestLoaded(
      services: services ?? this.services,
      displayedItems: displayedItems ?? this.displayedItems,
      filteredModel: filteredModel ?? this.filteredModel,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDepartmentKeys: selectedDepartmentKeys ?? this.selectedDepartmentKeys,
      selectedSortOption: selectedSortOption ?? this.selectedSortOption,
      searchQuery: searchQuery ?? this.searchQuery,
      totalServices: totalServices ?? this.totalServices,
      pendingCount: pendingCount ?? this.pendingCount,
      approvedCount: approvedCount ?? this.approvedCount,
      cancelCount: cancelCount ?? this.cancelCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      branchSlaCount: branchSlaCount ?? this.branchSlaCount,
      doneCount: doneCount ?? this.doneCount,
    );
  }

  @override
  List<Object?> get props => [
    services,
    displayedItems,
    filteredModel,
    selectedStatus,
    selectedDepartmentKeys,
    selectedSortOption,
    searchQuery,
    totalServices,
    pendingCount,
    approvedCount,
    cancelCount,
    rejectedCount,
    inProgressCount,
    branchSlaCount,
    doneCount,
  ];
}

class MyRequestError extends MyRequestState {
  final String message;

  const MyRequestError(this.message);

  @override
  List<Object?> get props => [message];
}
