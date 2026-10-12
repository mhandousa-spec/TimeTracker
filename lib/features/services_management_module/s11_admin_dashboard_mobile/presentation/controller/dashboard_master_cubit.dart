// ******************* FILE INFO *******************
// File Name: dashboard_master_cubit.dart
// Description: Business logic for DashBoard Master (Mobile + Admin)
// Created by: Amr Mesbah
// *************************************************
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/service_repository_impl.dart';

part 'dashboard_master_cubit_ext.dart';

class DashboardMasterCubit extends Cubit<DashboardMasterState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  // 002/102: repository injected (default preserves existing no-arg call sites).
  final CreateServicesRepository _repository;

  /// Department lookups are injected; this cubit has no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  DashboardMasterCubit({
    required this.departmentCubit,
    CreateServicesRepository? repository,
  })  : _repository = repository ??
            GetServiceRepositoryImpl(firestore: FirebaseFirestore.instance),
        super(DashboardMasterState.initial());

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> bootstrap({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    emit(state.copyWith(bootstrapping: true));
    _initializeDepartmentData();

    try {
      final departmentController = departmentCubit;
      await departmentController.getAllDepartments();

      await Future.wait([
        loadServiceStatusData(isAdmin: isAdmin, adminSelectedDepartment: adminSelectedDepartment),
        fetchMonthlyServiceCounts(isAdmin: isAdmin, adminSelectedDepartment: adminSelectedDepartment),
        fetchServiceUsageCounts(isAdmin: isAdmin, adminSelectedDepartment: adminSelectedDepartment),
        fetchDepartmentCounts(isAdmin: isAdmin, adminSelectedDepartment: adminSelectedDepartment),
        loadFilteredItems(isAdmin: isAdmin, adminSelectedDepartment: adminSelectedDepartment),
        fetchMonthlyRejectedCounts(isAdmin: isAdmin, adminSelectedDepartment: adminSelectedDepartment),
        fetchMonthlyCanceledCounts(isAdmin: isAdmin, adminSelectedDepartment: adminSelectedDepartment),
        _loadChartSettings(),
      ]);
    } catch (e, st) {
    } finally {
      emit(state.copyWith(bootstrapping: false, bootstrapped: true));
    }
  }

  void toggleTab(bool showRequested) =>
      emit(state.copyWith(showRequestedServices: showRequested));

  Future<void> toggleChartMode({
    required bool showCount,
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    // ✅ FIXED: Save the toggle choice in state BEFORE setting isLoading
    // This way isHoursMode survives the widget rebuild during loading
    emit(state.copyWith(
      isHoursMode: !showCount, // showCount=true means NOT hours
      isLoading: true,
    ));
    if (showCount) {
      await fetchMonthlyServiceCounts(
        isAdmin: isAdmin,
        adminSelectedDepartment: adminSelectedDepartment,
      );
    } else {
      await fetchMonthlyDurationInHours(
        isAdmin: isAdmin,
        adminSelectedDepartment: adminSelectedDepartment,
      );
    }
  }

  Future<void> reloadChartSettings() => _loadChartSettings();

  void applyFilters({
    String? department,
    String? status,
    DateTime? date,
    bool clearDepartment = false,
    bool clearStatus = false,
    bool clearDate = false,
    String? searchQuery,
  }) {
    final next = state.copyWith(
      activeDepartment: department,
      activeStatus: status,
      activeDate: date,
      clearActiveDepartment: clearDepartment,
      clearActiveStatus: clearStatus,
      clearActiveDate: clearDate,
      searchQuery: searchQuery,
    );
    emit(next.copyWith(displayedItems: _computeDisplayedItems(next)));
  }

  void onSearchChanged(String query) {
    final next = state.copyWith(searchQuery: query);
    emit(next.copyWith(displayedItems: _computeDisplayedItems(next)));
  }

  ChartOrientation getChartOrientation(String chartId) {
    if (state.chartOrientations.containsKey(chartId)) {
      return state.chartOrientations[chartId]!;
    }
    // Fixed defaults; the ChartRegistry / per-user settings service was removed
    // in favour of the core chart cards.
    // ✅ Every chart defaults to vertical bars — 'services_offered' used to be
    // the one exception and rendered horizontally, which read differently from
    // the Department chart right above it. It now uses the same
    // CustomVerticalBarChartWidget as the rest of the dashboard.
    return ChartOrientation.vertical;
  }

  double getPercentage(String key) {
    final total = state.statusCounts.values.fold<int>(0, (a, b) => a + b);
    final value = state.statusCounts[key] ?? 0;
    return total == 0 ? 0.0 : (value / total) * 100.0;
  }

  // ─── Provider Stats ────────────────────────────────────────────────────────

  List<String> getUniqueProviderNames(List<Map<String, dynamic>> items) {
    final Set<String> names = {};
    for (final item in items) {
      final provider = item['provider']?.toString() ?? '';
      if (provider.isNotEmpty && provider != 'N/A') names.add(provider);
    }
    return names.toList();
  }

  Map<String, dynamic> calculateProviderStats(String providerName) {
    int done = 0;
    int breached = 0;
    double totalMinutes = 0;
    String? name;
    String? department;
    String? jobTitle;

    for (final item in state.filteredItems) {
      if ((item['provider'] ?? '') != providerName) continue;

      final model = item['model'] as ServicesHistoryModel;
      final stateField = model.currentState.toLowerCase();

      if (stateField == 'done') done++;
      if (stateField == 'breached sla' || stateField == 'branchsla') breached++;

      if (stateField == 'done') {
        final val = double.tryParse(model.currentDurationOfServices) ?? 0;
        final unit = model.currentSelectedDurationUnit.toLowerCase();
        totalMinutes += switch (unit) {
          'minutes' => val,
          'hours'   => val * 60,
          'days'    => val * 1440,
          'weeks'   => val * 10080,
          _         => 0,
        };
      }

      name ??= item['provider'];
      department ??= item['department'];
      jobTitle ??= model.currentJobTitleRequester;
    }

    return {
      'name': name ?? 'N/A',
      'department': department ?? 'N/A',
      'jobTitle': jobTitle ?? 'N/A',
      'done': done,
      'breached': breached,
      'hours': done > 0 ? totalMinutes / 60 : 0.0,
    };
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  void _initializeDepartmentData() {
    try {
      final dc = departmentCubit;
      final en = dc.departmentsEnglishName;
      final ar = dc.departmentsArabicName;

      final Map<String, String> enToAr = {};
      final Map<String, Color> colors = {};

      const colorList = [
        AppColors.chartGoldDeep, AppColors.chartGoldPale, AppColors.chartGoldBright,
        AppColors.chartOlive, AppColors.chartAmberDeep, AppColors.chartGreyOlive,
        AppColors.chartGrey, AppColors.chartLightGrey, AppColors.chartTaupe,
        AppColors.chartMocha, AppColors.chartYellow,
      ];

      for (int i = 0; i < en.length; i++) {
        if (i < ar.length) enToAr[en[i]] = ar[i];
        colors[en[i]] = colorList[i % colorList.length];
      }

      emit(state.copyWith(
        enToArDepartments: enToAr,
        departmentColors: colors,
        knownDepartments: en,
        knownDepartmentsArabic: ar,
      ));
    } catch (e) {
    }
  }

  // ─── Department filter helper ──────────────────────────────────────────────

  String? _getFilterDepartment({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) {
    if (isAdmin) {
      if (adminSelectedDepartment == null || adminSelectedDepartment == 'All') return null;
      return adminSelectedDepartment;
    }
    final dc = departmentCubit;
    final ec = AppControllers.employee;
    final deptId = ec.employeeEntity?.departmentId;
    if (deptId == null) return null;
    return dc.getDepartmentName(deptId, true);
  }

  // ─── Data Loading ──────────────────────────────────────────────────────────

  Future<void> loadFilteredItems({
    required bool isAdmin,
    required String? adminSelectedDepartment,
    int limit = 300,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    final employeeController = AppControllers.employee;

    // 002/102: recent request docs come from the repository.
    final docs = await _repository.getRecentRequestServiceDocs(limit: limit * 2);

    final List<Map<String, dynamic>> results = [];

    for (int i = 0; i < docs.length; i++) {
      if (results.length >= limit) break;

      final data = docs[i].value;
      final docId = docs[i].key;

      try {
        // ── Department ───────────────────────────────────────────────────────
        String normalizedDepartment = _normalizeDepartmentValue(data['departmentRequester']);

        // ── Service names ────────────────────────────────────────────────────
        String serviceNameEn = _extractValue(data['Service_Name_English']);
        String serviceNameAr = _extractValue(data['Service_Name_Arabic']);
        String firstNameRequester = _extractValue(data['firstNameRequester']);
        String lastNameRequester = _extractValue(data['lastNameRequester']);
        String firstNameRequesterAr = _extractValue(data['firstNameRequesterArabic']);
        String lastNameRequesterAr = _extractValue(data['lastNameRequesterArabic']);
        String genderRequester = _extractValue(data['genderRequester']);
        String jobTitleRequester = _extractValue(data['jobTitleRequester']);
        String jobTitleRequesterAr = _extractValue(data['jobTitleRequesterArabic']);

        // ── Enrich from CreateServices if needed ─────────────────────────────
        final needsFetch = normalizedDepartment.isEmpty ||
            (serviceNameEn.isEmpty && serviceNameAr.isEmpty) ||
            (firstNameRequester.isEmpty && lastNameRequester.isEmpty) ||
            genderRequester.isEmpty ||
            jobTitleRequester.isEmpty;

        if (needsFetch) {
          final parentServiceId = _extractValue(data['Parent_Service_Id']);
          final emailRequester = _extractValue(data['Email_Requester']);

          if (parentServiceId.isNotEmpty && emailRequester.isNotEmpty) {
            final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
              parentServiceId: parentServiceId,
              emailRequester: emailRequester,
            );
            if (serviceNameEn.isEmpty) serviceNameEn = details['serviceNameEnglish'] ?? '';
            if (serviceNameAr.isEmpty) serviceNameAr = details['serviceNameArabic'] ?? '';
            if (firstNameRequester.isEmpty) {
              final parts = (details['requesterName'] ?? '').split(' ');
              firstNameRequester = parts.isNotEmpty ? parts.first : '';
              lastNameRequester = parts.length > 1 ? parts.skip(1).join(' ') : '';
            }
            if (firstNameRequesterAr.isEmpty) {
              final partsAr = (details['requesterNameArabic'] ?? '').split(' ');
              firstNameRequesterAr = partsAr.isNotEmpty ? partsAr.first : '';
              lastNameRequesterAr = partsAr.length > 1 ? partsAr.skip(1).join(' ') : '';
            }
            if (jobTitleRequester.isEmpty) jobTitleRequester = details['jobTitle'] ?? '';
            if (jobTitleRequesterAr.isEmpty) jobTitleRequesterAr = details['jobTitleArabic'] ?? '';
            if (genderRequester.isEmpty) genderRequester = details['gender'] ?? '';
            if (normalizedDepartment.isEmpty) normalizedDepartment = details['department'] ?? '';
          }
        }

        // ── Department filter ────────────────────────────────────────────────
        if (filterDepartment != null && normalizedDepartment != filterDepartment) continue;

        // ── Provider resolution ──────────────────────────────────────────────
        final emailRequester = _extractValue(data['Email_Requester']);
        final providerData = _resolveProvider(
          data: data,
          emailRequester: emailRequester,
          employeeController: employeeController,
        );
        final selectedProvider = providerData['map'] as Map<String, dynamic>;
        final providerName = providerData['name'] as String;

        // ── Status + Timestamp ───────────────────────────────────────────────
        final model = ServicesHistoryModel.fromJson(data, docId);
        final status = getFinalStateFromModel(model);
        final requestTimestamp = model.currentTimestamp != null
            ? Timestamp.fromMillisecondsSinceEpoch(model.currentTimestamp!)
            : null;

        results.add({
          'no': results.length + 1,
          'department': normalizedDepartment,
          'serviceName': serviceNameEn,
          'serviceNameArabic': serviceNameAr,
          'gender': genderRequester,
          'requestor': '$firstNameRequester $lastNameRequester'.trim(),
          'requestorArabic': '$firstNameRequesterAr $lastNameRequesterAr'.trim(),
          'requestDate': requestTimestamp,
          'status': status,
          'provider': providerName.isNotEmpty ? providerName : 'N/A',
          'docId': docId,
          'model': model,
          'raw': data,
          'selectedProvider': selectedProvider,
          'jobTitleRequester': jobTitleRequester,
          'jobTitleRequesterArabic': jobTitleRequesterAr,
        });
      } catch (e, st) {
      }
    }

    emit(state.copyWith(
      filteredItems: results,
      displayedItems: results,
    ));
  }

  Future<void> loadServiceStatusData({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    // 002/102: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<String, int> counts = {
      'done': 0, 'approved': 0, 'pending': 0, 'inprogress': 0,
      'branchsla': 0, 'rejected': 0, 'cancel': 0,
    };

    for (final doc in docs) {
      final data = doc.value;
      String dept = _normalizeDepartmentValue(data['departmentRequester']);
      if (dept.isEmpty) {
        final email = _extractValue(data['Email_Requester']);
        if (email.isNotEmpty) {
          dept = CreateServicesHelper.getRequesterInfo(emailRequester: email, departments: departmentCubit)['department'] ?? '';
        }
      }
      if (filterDepartment != null && !_sameDepartment(dept, filterDepartment)) continue;

      final model = ServicesHistoryModel.fromJson(data, doc.key);
      final key = getFinalStateFromModel(model).toLowerCase().replaceAll(' ', '');
      if (counts.containsKey(key)) counts[key] = counts[key]! + 1;
    }

    emit(state.copyWith(statusCounts: counts, isLoadingFirst: false));
  }

  Future<void> fetchMonthlyServiceCounts({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    // 002/102: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<int, double> counts = {for (int i = 0; i < 12; i++) i: 0};

    for (final doc in docs) {
      final data = doc.value;
      String dept = _normalizeDepartmentValue(data['departmentRequester']);
      if (dept.isEmpty) {
        final email = _extractValue(data['Email_Requester']);
        if (email.isNotEmpty) {
          dept = CreateServicesHelper.getRequesterInfo(emailRequester: email, departments: departmentCubit)['department'] ?? '';
        }
      }
      if (filterDepartment != null && !_sameDepartment(dept, filterDepartment)) continue;

      final model = ServicesHistoryModel.fromJson(data, doc.key);
      if (model.currentTimestamp != null) {
        final month = DateTime.fromMillisecondsSinceEpoch(model.currentTimestamp!).month - 1;
        counts[month] = (counts[month] ?? 0) + 1;
      }
    }

    emit(state.copyWith(monthCounts: counts, isLoading: false));
  }

  Future<void> fetchMonthlyDurationInHours({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    // 002/102: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<int, double> hours = {for (int i = 0; i < 12; i++) i: 0};

    for (final doc in docs) {
      final data = doc.value;
      try {
        String dept = _normalizeDepartmentValue(data['departmentRequester']);
        if (dept.isEmpty) {
          final email = _extractValue(data['Email_Requester']);
          if (email.isNotEmpty) {
            dept = CreateServicesHelper.getRequesterInfo(emailRequester: email, departments: departmentCubit)['department'] ?? '';
          }
        }
        if (filterDepartment != null && !_sameDepartment(dept, filterDepartment)) continue;

        final model = ServicesHistoryModel.fromJson(data, doc.key);
        if (model.currentState.toLowerCase().trim() != 'done') continue;

        final val = double.tryParse(model.currentDurationOfServices) ?? 0;
        final unit = model.currentSelectedDurationUnit.toLowerCase();
        if (val <= 0 || unit.isEmpty) continue;

        final h = _toHours(val, unit);
        if (h <= 0) continue;

        final date = model.currentDurationOfServicesTimestamp.toDate();
        hours[date.month - 1] = (hours[date.month - 1] ?? 0) + h;
      } catch (e) {
      }
    }

    emit(state.copyWith(monthHours: hours, isLoading: false));
  }

  Future<void> fetchMonthlyRejectedCounts({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    // 002/102: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<int, double> counts = {for (int i = 0; i < 12; i++) i: 0};

    for (final doc in docs) {
      final data = doc.value;
      String dept = _normalizeDepartmentValue(data['departmentRequester']);
      if (dept.isEmpty) {
        final email = _extractValue(data['Email_Requester']);
        if (email.isNotEmpty) {
          dept = CreateServicesHelper.getRequesterInfo(emailRequester: email, departments: departmentCubit)['department'] ?? '';
        }
      }
      if (filterDepartment != null && !_sameDepartment(dept, filterDepartment)) continue;

      final model = ServicesHistoryModel.fromJson(data, doc.key);
      if (getFinalStateFromModel(model).toLowerCase() == 'rejected' &&
          model.currentTimestamp != null) {
        final month = DateTime.fromMillisecondsSinceEpoch(model.currentTimestamp!).month - 1;
        counts[month] = (counts[month] ?? 0) + 1;
      }
    }

    emit(state.copyWith(monthRejected: counts, isLoadingRejectedCanceled: false));
  }

  Future<void> fetchMonthlyCanceledCounts({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    // 002/102: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<int, double> counts = {for (int i = 0; i < 12; i++) i: 0};

    for (final doc in docs) {
      final data = doc.value;
      String dept = _normalizeDepartmentValue(data['departmentRequester']);
      if (dept.isEmpty) {
        final email = _extractValue(data['Email_Requester']);
        if (email.isNotEmpty) {
          dept = CreateServicesHelper.getRequesterInfo(emailRequester: email, departments: departmentCubit)['department'] ?? '';
        }
      }
      if (filterDepartment != null && !_sameDepartment(dept, filterDepartment)) continue;

      final model = ServicesHistoryModel.fromJson(data, doc.key);
      if (getFinalStateFromModel(model).toLowerCase() == 'cancel' &&
          model.currentTimestamp != null) {
        final month = DateTime.fromMillisecondsSinceEpoch(model.currentTimestamp!).month - 1;
        counts[month] = (counts[month] ?? 0) + 1;
      }
    }

    emit(state.copyWith(monthCanceled: counts, isLoadingRejectedCanceled: false));
  }

  Future<void> fetchServiceUsageCounts({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    // 002/102: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<String, double> serviceIdToCount = {};
    final Map<String, String> serviceIdToNameEn = {};
    final Map<String, String> serviceIdToNameAr = {};

    for (final doc in docs) {
      final data = doc.value;
      String dept = _normalizeDepartmentValue(data['departmentRequester']);
      if (dept.isEmpty) {
        final email = _extractValue(data['Email_Requester']);
        if (email.isNotEmpty) {
          dept = _getDepartmentFromEmail(email) ?? '';
        }
      }
      if (filterDepartment != null && !_sameDepartment(dept, filterDepartment)) continue;

      final parentServiceId = _getSafeString(data['Parent_Service_Id']);
      if (parentServiceId == null || parentServiceId.isEmpty) continue;

      serviceIdToCount[parentServiceId] = (serviceIdToCount[parentServiceId] ?? 0) + 1;
      if (serviceIdToNameEn.containsKey(parentServiceId)) continue;

      final nameEn = _getSafeString(data['Service_Name_English']);
      final nameAr = _getSafeString(data['Service_Name_Arabic']);

      if (nameEn != null && nameEn.isNotEmpty) {
        serviceIdToNameEn[parentServiceId] = nameEn;
        serviceIdToNameAr[parentServiceId] = nameAr ?? '';
      } else {
        final emailRequester = _getSafeString(data['Email_Requester']);
        if (emailRequester != null && emailRequester.isNotEmpty) {
          final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
            parentServiceId: parentServiceId,
            emailRequester: emailRequester,
          );
          final fetchedEn = details['serviceNameEnglish'] ?? '';
          serviceIdToNameEn[parentServiceId] =
          fetchedEn.isNotEmpty ? fetchedEn : 'Service $parentServiceId';
          serviceIdToNameAr[parentServiceId] = details['serviceNameArabic'] ?? '';
        }
      }
    }

    final List<String> names = [];
    final List<String> namesAr = [];
    final Map<int, double> counts = {};

    int index = 0;
    for (final entry in serviceIdToCount.entries) {
      names.add(serviceIdToNameEn[entry.key] ?? 'Unknown');
      namesAr.add(serviceIdToNameAr[entry.key] ?? '');
      counts[index] = entry.value;
      index++;
    }

    emit(state.copyWith(
      serviceNames: names,
      serviceNamesArabic: namesAr,
      monthCountss: counts,
      isLoadingServicesName: false,
    ));
  }

  Future<void> fetchDepartmentCounts({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    final filterDepartment = _getFilterDepartment(
      isAdmin: isAdmin,
      adminSelectedDepartment: adminSelectedDepartment,
    );

    final dc = departmentCubit;
    final dynamicDepts = dc.departmentsEnglishName;

    if (filterDepartment != null && filterDepartment.isNotEmpty) {
      // 002/102: request docs come from the repository.
      final docs = await _repository.getAllRequestServiceDocs();

      final Map<String, int> counts = {for (var d in dynamicDepts) d: 0};

      for (final doc in docs) {
        final data = doc.value;
        String dept = _normalizeDepartmentValue(data['departmentRequester']);
        if (dept.isEmpty) {
          final email = _extractValue(data['Email_Requester']);
          if (email.isNotEmpty) dept = _getDepartmentFromEmail(email) ?? '';
        }
        if (counts.containsKey(dept)) counts[dept] = (counts[dept] ?? 0) + 1;
      }

      emit(state.copyWith(departmentCounts: counts, isLoadingDepartments: false));
    } else {
      emit(state.copyWith(
        departmentCounts: {for (var d in dynamicDepts) d: 0},
        isLoadingDepartments: false,
      ));
    }
  }

  // ─── Chart Settings ────────────────────────────────────────────────────────

  Future<void> _loadChartSettings() async {
    try {
      final email = employeeFunctionHelper.email;
      if (email == null) {
        emit(state.copyWith(isLoadingChartSettings: false));
        return;
      }
      emit(state.copyWith(isLoadingChartSettings: false));
    } catch (e) {
      emit(state.copyWith(isLoadingChartSettings: false));
    }
  }

  // ─── Status resolution ─────────────────────────────────────────────────────

}
