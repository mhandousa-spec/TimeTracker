// ******************* FILE INFO *******************
// File Name: my_request_cubit
// Description: My request cubit.
// Module: services_management_module / presentation/s6_services_requests/controller
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';

import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/my_request_state.dart';

class MyRequestCubit extends Cubit<MyRequestState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final BuildContext context;
  late final MainCoreDepartmentCubit departmentController;
  final MainCoreEmployeeController employeeController;

  TextEditingController searchController = TextEditingController();

  // Cache for counts so they persist across filters
  int _totalServices = 0;
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _cancelCount = 0;
  int _rejectedCount = 0;
  int _inProgressCount = 0;
  int _branchSlaCount = 0;
  int _doneCount = 0;

  MyRequestCubit(
      this.context, {
        MainCoreDepartmentCubit? departmentController,
        MainCoreEmployeeController? employeeController,
      })  : employeeController = employeeController ?? AppControllers.employee,
        super(const MyRequestInitial()) {
    this.departmentController =
        departmentController ?? context.read<MainCoreDepartmentCubit>();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (state is MyRequestLoaded) {
      filterServices(searchQuery: searchController.text);
    }
  }

  Future<void> loadAllData() async {
    emit(const MyRequestLoading());

    try {
      departmentController.getAllDepartments();

      final cubit = ServicesManagerCubit.get(context);
      final services = await cubit.repository.getMyRequestServices();
      cubit.myRequestModel = services;

      // Fetch counts first and cache them
      await _fetchAndCacheCounts(services);

      // Then apply initial filter (show all)
      filterServices(
        services: services,
        searchQuery: '',
        selectedStatus: 'All',
        selectedDepartmentKeys: const [],
        selectedSortOption: 'Date Requested',
      );
    } catch (e) {
      emit(MyRequestError('Error loading services: $e'));
    }
  }

  Future<void> _fetchAndCacheCounts(List<ServicesHistoryModel> services) async {
    final email = employeeController.employeeEntity!.email;

    // I/O goes through the repository, never Firestore directly from the cubit.
    final requestModels = await ServicesManagerCubit.get(context)
        .repository
        .getMyRequestServicesByRequester(email);

    _totalServices = 0;
    _pendingCount = 0;
    _approvedCount = 0;
    _cancelCount = 0;
    _doneCount = 0;
    _rejectedCount = 0;
    _inProgressCount = 0;
    _branchSlaCount = 0;

    for (final model in requestModels) {
      final finalState = getFinalStateFromModel(model);

      _totalServices++;

      switch (finalState.toLowerCase()) {
        case 'pending':
          _pendingCount++;
          break;
        case 'approved':
          _approvedCount++;
          break;
        case 'cancel':
          _cancelCount++;
          break;
        case 'rejected':
          _rejectedCount++;
          break;
        case 'inprogress':
        case 'in progress':
          _inProgressCount++;
          break;
        case 'branchsla':
        case 'breached sla':
          _branchSlaCount++;
          break;
        case 'done':
          _doneCount++;
          break;
      }
    }
  }

  void filterServices({
    List<ServicesHistoryModel>? services,
    String? searchQuery,
    String? selectedStatus,
    List<String>? selectedDepartmentKeys,
    String? selectedSortOption,
  }) {
    final currentState = state is MyRequestLoaded
        ? state as MyRequestLoaded
        : null;

    final model = services ?? currentState?.services ?? [];
    final query = (searchQuery ?? currentState?.searchQuery ?? '').toLowerCase();
    final status = selectedStatus ?? currentState?.selectedStatus ?? 'All';
    final deptKeys = selectedDepartmentKeys ?? currentState?.selectedDepartmentKeys ?? [];
    final sortOption = selectedSortOption ?? currentState?.selectedSortOption ?? 'Date Requested';

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final statusMap = {
      S.of(context).Pending.toLowerCase(): 'pending',
      S.of(context).Approved.toLowerCase(): 'approved',
      S.of(context).Rejected.toLowerCase(): 'rejected',
      S.of(context).Canceled.toLowerCase(): 'cancel',
      S.of(context).Done.toLowerCase(): 'done',
      S.of(context).Inprogress.toLowerCase(): 'In Progress',
      S.of(context).BreachedSLA.toLowerCase(): 'breached sla',
      S.of(context).all.toLowerCase(): 'all',
    };

    final selectedRawStatus = statusMap[status.toLowerCase()] ?? 'all';

    final filtered = <ServicesHistoryModel>[];
    int totalProcessed = 0;

    for (var service in model) {
      totalProcessed++;
      final providerServices = service.currentProviderServices;
      final contactName = providerServices.isNotEmpty
          ? "${providerServices.first.firstName ?? ''} ${providerServices.first.lastName ?? ''}".toLowerCase()
          : '';
      final serviceName = isArabic
          ? service.currentServiceNameArabic
          : service.currentServiceNameEnglish;

      // Search filter
      final matchesSearch = query.isEmpty ||
          contactName.contains(query) ||
          serviceName.toLowerCase().contains(query);

      // Status filter
      final statusFromModel = getFinalStateFromModel(service).toLowerCase().trim();
      bool matchesStatus;

      if (selectedRawStatus == 'all') {
        matchesStatus = true;
      } else if (selectedRawStatus == 'cancel') {
        matchesStatus = (statusFromModel == 'cancel' || statusFromModel == 'canceled');
      } else if (selectedRawStatus == 'breached sla') {
        matchesStatus = (statusFromModel == 'breached sla' || statusFromModel == 'branchsla');
      } else if (selectedRawStatus.toLowerCase() == 'in progress') {
        matchesStatus = (statusFromModel == 'in progress' || statusFromModel == 'inprogress');
      } else {
        matchesStatus = (statusFromModel == selectedRawStatus);
      }

      // Department filter
      final serviceDeptId = service.currentDepartmentRequester?.trim() ?? '';
      bool matchesDepartment = deptKeys.isEmpty;

      if (!matchesDepartment && serviceDeptId.isNotEmpty) {
        for (var selectedDeptId in deptKeys) {
          if (serviceDeptId == selectedDeptId) {
            matchesDepartment = true;
            break;
          }
        }

        if (!matchesDepartment) {
          for (var selectedDeptId in deptKeys) {
            final englishName = departmentController.getEnglishDepartmentNameFromDepartmentId(
              departmentId: selectedDeptId,
            );
            final arabicName = departmentController.getArabicDepartmentNameFromDepartmentId(
              departmentId: selectedDeptId,
            );

            final matchesEnglish = englishName != null &&
                serviceDeptId.toLowerCase() == englishName.toLowerCase();
            final matchesArabic = arabicName != null && serviceDeptId == arabicName;

            if (matchesEnglish || matchesArabic) {
              matchesDepartment = true;
              break;
            }
          }
        }
      }

      if (matchesSearch && matchesStatus && matchesDepartment) {
        filtered.add(service);
      }
    }

    // Sort
    List<ServicesHistoryModel> toDisplay = List<ServicesHistoryModel>.from(filtered);

    if (sortOption.isNotEmpty) {
      switch (sortOption) {
        case 'Date Requested':
          toDisplay.sort((a, b) => _dateRequestedOf(b).compareTo(_dateRequestedOf(a)));
          break;
        case 'Duration':
          toDisplay.sort((a, b) => _modelDurationSeconds(b).compareTo(_modelDurationSeconds(a)));
          break;
        case 'Last Update':
          toDisplay.sort((a, b) => _lastUpdateOf(b).compareTo(_lastUpdateOf(a)));
          break;
      }
    }

    final displayedItems = _buildDisplayedItems(toDisplay, isArabic);

    // Emit new state with cached counts
    emit(MyRequestLoaded(
      services: model,
      displayedItems: displayedItems,
      filteredModel: filtered,
      selectedStatus: status,
      selectedDepartmentKeys: deptKeys,
      selectedSortOption: sortOption,
      searchQuery: query,
      totalServices: _totalServices,
      pendingCount: _pendingCount,
      approvedCount: _approvedCount,
      cancelCount: _cancelCount,
      rejectedCount: _rejectedCount,
      inProgressCount: _inProgressCount,
      branchSlaCount: _branchSlaCount,
      doneCount: _doneCount,
    ));
  }

  List<Map<String, dynamic>> _buildDisplayedItems(List<ServicesHistoryModel> services, bool isArabic) {
    List<Map<String, dynamic>> items = [];

    for (var service in services) {
      final departmentId = service.currentDepartmentRequester;
      final departmentName = _getLocalizedDepartmentName(departmentId);

      items.add({
        "model": service,
        "department": departmentName,
        "status": getFinalStateFromModel(service),
      });
    }

    return items;
  }

  String _getLocalizedDepartmentName(String? departmentId) {
    if (departmentId == null || departmentId.isEmpty) return '-';

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    String? result;

    if (isArabic) {
      result = departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: departmentId);
    } else {
      result = departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);
    }

    if (result == null || result.isEmpty) {
      if (!RegExp(r'^\d+$').hasMatch(departmentId)) {
        return departmentId;
      }
      return departmentId;
    }

    return result;
  }

  // Public methods to update filters
  void updateStatus(String status) {
    filterServices(selectedStatus: status);
  }

  void updateDepartments(List<String> departments) {
    filterServices(selectedDepartmentKeys: departments);
  }

  void updateSort(String sortOption) {
    filterServices(selectedSortOption: sortOption);
  }

  void applyMobileFilter({
    String? selectedDepartment,
    String? selectedStatus,
    DateTime? selectedDate,
  }) {
    final currentState = state as MyRequestLoaded;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final items = _buildFilteredDisplayItems(
      currentState.services,
      isArabic,
      selectedDepartment,
      selectedStatus,
      selectedDate,
    );

    emit(MyRequestLoaded(
      services: currentState.services,
      displayedItems: items,
      filteredModel: currentState.filteredModel,
      selectedStatus: currentState.selectedStatus,
      selectedDepartmentKeys: currentState.selectedDepartmentKeys,
      selectedSortOption: currentState.selectedSortOption,
      searchQuery: currentState.searchQuery,
      totalServices: _totalServices,
      pendingCount: _pendingCount,
      approvedCount: _approvedCount,
      cancelCount: _cancelCount,
      rejectedCount: _rejectedCount,
      inProgressCount: _inProgressCount,
      branchSlaCount: _branchSlaCount,
      doneCount: _doneCount,
    ));
  }

  List<Map<String, dynamic>> _buildFilteredDisplayItems(
      List<ServicesHistoryModel> services,
      bool isArabic,
      String? selectedDepartment,
      String? selectedStatus,
      DateTime? selectedDate,
      ) {
    List<Map<String, dynamic>> items = [];

    for (var service in services) {
      final deptId = service.currentDepartmentRequester ?? '';
      final dept = _getLocalizedDepartmentName(deptId);
      final status = getFinalStateFromModel(service);

      final DateTime requestDate = service.timestamps.isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(service.timestamps.first)
          : DateTime.now();

      final bool matchesDepartment = selectedDepartment == null ||
          selectedDepartment.isEmpty ||
          (dept.toLowerCase() == selectedDepartment.toLowerCase());

      final bool matchesStatus = selectedStatus == null ||
          selectedStatus.isEmpty ||
          status.toLowerCase() == selectedStatus.toLowerCase();

      final bool matchesDate = selectedDate == null ||
          (requestDate.year == selectedDate.year &&
              requestDate.month == selectedDate.month &&
              requestDate.day == selectedDate.day);

      if (matchesDepartment && matchesStatus && matchesDate) {
        items.add({
          "model": service,
          "department": dept,
          "status": status,
        });
      }
    }

    return items;
  }

  // Helper methods
  DateTime _dateRequestedOf(ServicesHistoryModel m) {
    if (m.timestamps.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(m.timestamps.first);
  }

  // ✅ FIX: Last update should be LAST element in timestamps array
  DateTime _lastUpdateOf(ServicesHistoryModel m) {
    if (m.timestamps.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(m.timestamps.last);
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int _modelDurationSeconds(ServicesHistoryModel m) {
    final value = _toDouble(m.currentDurationOfServices);
    final unit = m.currentSelectedDurationUnit.toLowerCase().trim();

    if (unit.startsWith('s')) return (value).round();
    if (unit.startsWith('min')) return (value * 60).round();
    if (unit == 'm') return (value * 60).round();
    if (unit.startsWith('h')) return (value * 3600).round();
    if (unit.startsWith('d')) return (value * 86400).round();
    if (unit.startsWith('w')) return (value * 604800).round();

    return (value * 60).round();
  }

  List<String> _extractStatesFromEmployeeModels(List<EmployeeEntityModell> approvalList) {
    List<String> states = [];
    for (var item in approvalList) {
      if (item.state != null) {
        states.add(item.state!.toLowerCase());
      }
    }
    return states;
  }

  String getFinalStateFromModel(ServicesHistoryModel service) {
    final outerState = service.currentState.toLowerCase().trim();

    if (outerState == 'cancel' || outerState == 'canceled') return 'cancel';
    if (outerState == 'done') return 'done';
    if (outerState == 'inprogress' || outerState == 'in progress') return 'In Progress';
    if (outerState == 'breached sla' || outerState == 'branchsla') return 'breached sla';

    final approvalList = service.currentApprovalCycle;
    if (approvalList.isNotEmpty) {
      final states = _extractStatesFromEmployeeModels(approvalList);

      if (states.contains('cancel') || states.contains('canceled')) return 'cancel';
      if (states.contains('rejected')) return 'rejected';
      if (states.every((s) => s == 'approved')) {
      //   updateServiceStateIfAllApproved(service);
        return 'approved';
      }
      if (states.contains('pending')) return 'pending';
    }

    if (outerState.isNotEmpty) return outerState;
    return 'pending';
  }

  Future<void> updateServiceStateIfAllApproved(ServicesHistoryModel service) async {
    final approvalList = service.currentApprovalCycle;
    if (approvalList.isEmpty) return;

    final states = _extractStatesFromEmployeeModels(approvalList);

    if (states.isNotEmpty && states.every((s) => s == 'approved')) {
      try {
        await ServicesManagerCubit.get(context).repository.appendRequestState(
              serviceId: service.currentId,
              requesterEmail: employeeController.employeeEntity!.email,
              newState: service.currentState,
            );
      } catch (e) {
        // swallow: best-effort state sync
      }
    }
  }

  String getLocalizedStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return S.of(context).status_pending;
      case 'approved':
        return S.of(context).status_approved;
      case 'done':
        return S.of(context).status_done;
      case 'rejected':
        return S.of(context).status_rejected;
      case 'cancel':
        return S.of(context).status_cancel;
      case 'inprogress':
        return S.of(context).status_inprogress;
      case 'breached sla':
        return S.of(context).status_breached;
      case 'all':
        return S.of(context).all;
      default:
        return status;
    }
  }

  String getLocalizedDurationUnit(
      BuildContext context,
      String? rawUnit, {
        num? quantity,
      }) {
    final localizer = S.of(context);
    if (rawUnit == null) return '';

    final k = rawUnit.trim().toLowerCase();
    final isPlural = quantity != null && quantity != 1;

    String canonical;
    switch (k) {
      case 'h':
      case 'hr':
      case 'hrs':
      case 'hour':
      case 'hours':
        canonical = 'hours';
        break;
      case 'm':
      case 'min':
      case 'mins':
      case 'minute':
      case 'minutes':
        canonical = 'minutes';
        break;
      case 's':
      case 'sec':
      case 'secs':
      case 'second':
      case 'seconds':
        canonical = 'seconds';
        break;
      case 'w':
      case 'wk':
      case 'wks':
      case 'week':
      case 'weeks':
        canonical = 'week';
        break;
      case 'd':
      case 'day':
      case 'days':
        canonical = 'day';
        break;
      case 'mo':
      case 'month':
      case 'months':
        canonical = 'month';
        break;
      case 'y':
      case 'yr':
      case 'yrs':
      case 'year':
      case 'years':
        canonical = 'year';
        break;
      default:
        return rawUnit;
    }

    switch (canonical) {
      case 'hours':
        return isPlural ? localizer.hours : localizer.hour;
      case 'minutes':
        return isPlural ? localizer.minutes : localizer.minute;
      case 'seconds':
        return isPlural ? localizer.seconds : localizer.second;
      case 'week':
        return isPlural ? localizer.weeks : localizer.week;
      case 'day':
        return isPlural ? localizer.days : localizer.day;
      case 'month':
        return isPlural ? localizer.months : localizer.month;
      case 'year':
        return isPlural ? localizer.years : localizer.year;
      default:
        return rawUnit;
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
