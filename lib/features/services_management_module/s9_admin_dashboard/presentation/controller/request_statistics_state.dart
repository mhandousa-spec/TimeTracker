// ******************* FILE INFO *******************
// File Name: request_statistics_state.dart
// Description: State model for Admin Dashboard Details Cubit
// Module: services_management_module / presentation / s9_admin_dashboard / controller
// Created by: Amr Mesbah
// *************************************************

import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardDetailsState {
  // ── Bootstrap ──────────────────────────────────────────────────────────────
  final bool bootstrapping;
  final bool bootstrapped;

  // ── Loading flags ──────────────────────────────────────────────────────────
  final bool isLoading;
  final bool isLoadingFirst;
  final bool isLoadingDepartments;
  final bool isLoadingServicesName;

  // ── Tab toggle ─────────────────────────────────────────────────────────────
  final bool showRequestedServices;

  // ── Chart toggle ───────────────────────────────────────────────────────────
  final bool showServiceCount;

  // ── Data ───────────────────────────────────────────────────────────────────
  final Map<String, int> statusCounts;
  final Map<int, double> monthCounts;
  final Map<int, num> monthHours;
  final Map<String, int> departmentCounts;

  // ── Service names (for display name lookup) ────────────────────────────────
  final List<String> serviceNames;
  final List<String> serviceNamesArabic;

  // ── Table data ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> filteredItems;
  final List<Map<String, dynamic>> displayedItems;

  // ── Filters ────────────────────────────────────────────────────────────────
  final String? activeDepartment;
  final String? activeStatus;
  final DateTime? activeDate;
  final String searchQuery;

  // ── Dynamic department maps ────────────────────────────────────────────────
  final Map<String, String> enToArDepartments;
  final List<String> knownDepartments;

  const DashboardDetailsState({
    required this.bootstrapping,
    required this.bootstrapped,
    required this.isLoading,
    required this.isLoadingFirst,
    required this.isLoadingDepartments,
    required this.isLoadingServicesName,
    required this.showRequestedServices,
    required this.showServiceCount,
    required this.statusCounts,
    required this.monthCounts,
    required this.monthHours,
    required this.departmentCounts,
    required this.serviceNames,
    required this.serviceNamesArabic,
    required this.filteredItems,
    required this.displayedItems,
    required this.activeDepartment,
    required this.activeStatus,
    required this.activeDate,
    required this.searchQuery,
    required this.enToArDepartments,
    required this.knownDepartments,
  });

  factory DashboardDetailsState.initial() => const DashboardDetailsState(
    bootstrapping: false,
    bootstrapped: false,
    isLoading: true,
    isLoadingFirst: true,
    isLoadingDepartments: true,
    isLoadingServicesName: true,
    showRequestedServices: true,
    showServiceCount: true,
    statusCounts: {},
    monthCounts: {},
    monthHours: {},
    departmentCounts: {},
    serviceNames: [],
    serviceNamesArabic: [],
    filteredItems: [],
    displayedItems: [],
    activeDepartment: null,
    activeStatus: null,
    activeDate: null,
    searchQuery: '',
    enToArDepartments: {},
    knownDepartments: [],
  );

  DashboardDetailsState copyWith({
    bool? bootstrapping,
    bool? bootstrapped,
    bool? isLoading,
    bool? isLoadingFirst,
    bool? isLoadingDepartments,
    bool? isLoadingServicesName,
    bool? showRequestedServices,
    bool? showServiceCount,
    Map<String, int>? statusCounts,
    Map<int, double>? monthCounts,
    Map<int, num>? monthHours,
    Map<String, int>? departmentCounts,
    List<String>? serviceNames,
    List<String>? serviceNamesArabic,
    List<Map<String, dynamic>>? filteredItems,
    List<Map<String, dynamic>>? displayedItems,
    String? activeDepartment,
    String? activeStatus,
    DateTime? activeDate,
    bool clearActiveDate = false,
    bool clearActiveDepartment = false,
    bool clearActiveStatus = false,
    String? searchQuery,
    Map<String, String>? enToArDepartments,
    List<String>? knownDepartments,
  }) {
    return DashboardDetailsState(
      bootstrapping: bootstrapping ?? this.bootstrapping,
      bootstrapped: bootstrapped ?? this.bootstrapped,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFirst: isLoadingFirst ?? this.isLoadingFirst,
      isLoadingDepartments: isLoadingDepartments ?? this.isLoadingDepartments,
      isLoadingServicesName: isLoadingServicesName ?? this.isLoadingServicesName,
      showRequestedServices: showRequestedServices ?? this.showRequestedServices,
      showServiceCount: showServiceCount ?? this.showServiceCount,
      statusCounts: statusCounts ?? this.statusCounts,
      monthCounts: monthCounts ?? this.monthCounts,
      monthHours: monthHours ?? this.monthHours,
      departmentCounts: departmentCounts ?? this.departmentCounts,
      serviceNames: serviceNames ?? this.serviceNames,
      serviceNamesArabic: serviceNamesArabic ?? this.serviceNamesArabic,
      filteredItems: filteredItems ?? this.filteredItems,
      displayedItems: displayedItems ?? this.displayedItems,
      activeDepartment: clearActiveDepartment ? null : (activeDepartment ?? this.activeDepartment),
      activeStatus: clearActiveStatus ? null : (activeStatus ?? this.activeStatus),
      activeDate: clearActiveDate ? null : (activeDate ?? this.activeDate),
      searchQuery: searchQuery ?? this.searchQuery,
      enToArDepartments: enToArDepartments ?? this.enToArDepartments,
      knownDepartments: knownDepartments ?? this.knownDepartments,
    );
  }
}