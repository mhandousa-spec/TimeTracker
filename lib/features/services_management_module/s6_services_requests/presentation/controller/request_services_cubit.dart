// ******************* FILE INFO *******************
// File Name: request_services_cubit
// Description: Request services cubit.
// Module: services_management_module / presentation/s6_services_requests/controller
// *************************************************
import 'package:get/get.dart';

import 'dart:async';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart' hide RequestServicesError, RequestServicesLoaded, RequestServicesLoading;
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_services_state.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/helper_function.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/data/department_count_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/data/service_filter_model.dart';

class RequestServicesCubit extends Cubit<RequestServicesState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Department lookups are injected; this cubit has no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  RequestServicesCubit({required this.departmentCubit})
      : super(RequestServicesInitial());

  static RequestServicesCubit get(context) => BlocProvider.of(context);

  // Core Data
  List<ServicesHistoryModel> _allServices = [];
  List<ServicesHistoryModel> _filteredServices = [];
  ServiceFilterModel _filterModel = ServiceFilterModel.initial();
  DepartmentCountModel _departmentCounts = DepartmentCountModel.empty();

  // Cache
  Map<String, Map<String, dynamic>?> _providerCache = {};
  Timer? _searchDebounce;

  // Translations
  final Map<String, String> _departmentTranslations = {
    "Marketing": "التسويق",
    "Sales": "المبيعات",
    "HR": "شؤون الموظفين",
    "Executive": "الإدارة التنفيذية",
    "Customer Support": "دعم العملاء",
    "Operations": "العمليات",
    "Finance": "المالية",
    "Information Technology": "تقنية المعلومات",
    "Human Resources": "الموارد البشرية",
    "Data Management": "إدارة البيانات",
    "Compliance & Legal": "الامتثال والقانون",
    "Software": "البرمجيات",
  };

  // Getters
  List<ServicesHistoryModel> get filteredServices => _filteredServices;
  ServiceFilterModel get filterModel => _filterModel;
  DepartmentCountModel get departmentCounts => _departmentCounts;
  Map<String, Map<String, dynamic>?> get providerCache => _providerCache;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  // Initialize
  Future<void> initialize(context) async {
    emit(RequestServicesLoading());

    try {

      // Load user data
      await _loadUserData();

      // Fetch services
      await ServicesManagerCubit.get(context).getAllRequestServices();

    } catch (e) {
      emit(RequestServicesError(e.toString()));
    }
  }

  // ✅ FIXED - Load User Data
  Future<void> _loadUserData() async {
    try {
      // ✅ FIX: Get email directly from MainCoreEmployeeController instead
      final employeeController = AppControllers.employee;
      final userEmail = employeeController.employeeEntity?.email ?? '';

      String userDepartment = '';

      if (userEmail.isNotEmpty) {
        try {
          userDepartment = employeeController.getEmployeeDepartmentName(userEmail);
        } catch (e) {
        }
      }

      _filterModel = _filterModel.copyWith(
        userEmail: userEmail,
        userDepartment: userDepartment,
      );
    } catch (e) {
    }
  }

  // Load Services
  void loadServices(List<ServicesHistoryModel> services) {
    _allServices = services;
    applyFilters();
  }

  // Apply Filters
  void applyFilters() {

    try {
      final query = _filterModel.searchQuery.toLowerCase().trim();
      final selectedDept = _filterModel.selectedDepartment;
      final selectedKeyCanonical = selectedDept == "All" ? "All" : _normalizeDepartment(selectedDept);

      // Filter services
      _filteredServices = _applyAllFilters(_allServices, query, selectedKeyCanonical);

      // Recount departments
      _recountDepartments(_allServices);

      emit(RequestServicesLoaded(
        filteredServices: _filteredServices,
        departmentCounts: _departmentCounts,
        filterModel: _filterModel,
      ));
    } catch (e) {
      emit(RequestServicesError(e.toString()));
    }
  }

// Filter Logic
  List<ServicesHistoryModel> _applyAllFilters(
      List<ServicesHistoryModel> services,
      String query,
      String selectedKeyCanonical,
      ) {

    final employeeController = AppControllers.employee;
    final deptController = departmentCubit;

    List<ServicesHistoryModel> filtered = [];

    for (final service in services) {
      // ✅ CRITICAL FIX: Check BOTH status and state fields
      final statusLower = service.currentStatus.toLowerCase();
      final stateLower = service.currentState.toLowerCase();

      // ✅ Skip if status is NOT "active" OR state is "draft"
      if (statusLower != 'active' || stateLower == 'draft') {
        continue;
      }

      // ✅ FILTER 2: Check name match
      final nameEn = service.currentServiceNameEnglish.toLowerCase();
      final nameAr = service.currentServiceNameArabic.toLowerCase();
      final matchesName = query.isEmpty || nameEn.contains(query) || nameAr.contains(query);

      if (!matchesName) {
        continue;
      }

      // ✅ FILTER 3: Check permission
      if (!_canUserSeeService(service)) {
        continue;
      }

      // ✅ FILTER 4: Check department using email requester
      if (selectedKeyCanonical != "All") {
        final emailRequester = service.currentEmailRequester;

        if (emailRequester.isEmpty) {
          continue;
        }

        final employee = employeeController.mapOfEmployeesWithEmailKey[emailRequester];

        if (employee == null) {
          continue;
        }

        final departmentId = employee.departmentId;

        if (departmentId == null || departmentId.isEmpty) {
          continue;
        }

        final serviceDeptName = deptController.getEnglishDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        );

        if (serviceDeptName == null || serviceDeptName.isEmpty) {
          continue;
        }

        final serviceDeptCanonical = _normalizeDepartment(serviceDeptName);

        if (serviceDeptCanonical != selectedKeyCanonical) {
          continue;
        }
      }

      // ✅ Service passed all filters
      filtered.add(service);
    }

    return filtered;
  }

// Recount Departments
  void _recountDepartments(List<ServicesHistoryModel> services) {

    final deptController = departmentCubit;
    final employeeController = AppControllers.employee;
    final dynamicDepartments = deptController.departmentsEnglishName;

    final Map<String, int> counts = {for (final dept in dynamicDepartments) dept: 0};
    var total = 0;

    for (final service in services) {
      // ✅ CRITICAL FIX: Check BOTH status and state
      final statusLower = service.currentStatus.toLowerCase();
      final stateLower = service.currentState.toLowerCase();

      // ✅ Skip if NOT active OR is draft
      if (statusLower != 'active' || stateLower == 'draft') {
        continue;
      }

      if (!_canUserSeeService(service)) continue;

      final emailRequester = service.currentEmailRequester;

      if (emailRequester.isEmpty) {
        continue;
      }

      final employee = employeeController.mapOfEmployeesWithEmailKey[emailRequester];

      if (employee == null) {
        continue;
      }

      final departmentId = employee.departmentId;

      if (departmentId == null || departmentId.isEmpty) {
        continue;
      }

      final serviceDeptName = deptController.getEnglishDepartmentNameFromDepartmentId(
        departmentId: departmentId,
      );

      if (serviceDeptName == null || serviceDeptName.isEmpty) {
        continue;
      }

      final sDept = _normalizeDepartment(serviceDeptName);

      if (counts.containsKey(sDept)) {
        counts[sDept] = (counts[sDept] ?? 0) + 1;
        total++;
      }
    }

    counts.forEach((dept, count) {
    });

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _departmentCounts = DepartmentCountModel(
      total: total,
      departmentCounts: Map.fromEntries(sortedEntries),
    );

  }

  // Permission Check
  bool _canUserSeeService(ServicesHistoryModel service) {
    // If not limited, everyone can see
    if (service.currentLimitAvailability != true) return true;

    // Check if user department is in allowed list
    final userDept = _normalizeDepartment(_filterModel.userDepartment);
    final selectDepartment = service.currentSelectDepartment;

    if (selectDepartment.isNotEmpty) {
      List<String> allowedDepartments = [];
      for (var dept in selectDepartment) {
        final normalized = _normalizeDepartment(dept.toString());
        if (normalized.isNotEmpty) {
          allowedDepartments.add(normalized);
        }
      }
      return allowedDepartments.contains(userDept);
    }

    return false;
  }

  // Search with Debounce
  void searchServices(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _filterModel = _filterModel.copyWith(searchQuery: query);
      applyFilters();
    });
  }

  // Change Department Filter
  void changeDepartmentFilter(String department) {
    _filterModel = _filterModel.copyWith(selectedDepartment: department);
    applyFilters();
  }

  // Normalize Department
  String _normalizeDepartment(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';

    final k = raw.trim().toLowerCase();

    if (k == 'executive' || k.contains('executive')) return 'Executive';
    if (k == 'customer support' || (k.contains('customer') && k.contains('support'))) {
      return 'Customer Support';
    }
    if (k == 'operations' || k.contains('operation')) return 'Operations';
    if (k == 'finance' || k.contains('financ')) return 'Finance';
    if (k == 'information technology' || k == 'it' || k.contains('information') || k.contains('technology')) {
      return 'Information Technology';
    }
    if (k == 'human resources' || k == 'hr' || k.contains('human') || k.contains('resource')) {
      return 'Human Resources';
    }
    if (k == 'marketing' || k.contains('marketing') || k.startsWith('market') || k.startsWith('mark')) {
      return 'Marketing';
    }
    if (k == 'sales' || k.contains('sales') || k == 'salse' || k.startsWith('sale')) {
      return 'Sales';
    }
    if (k == 'data management' || (k.contains('data') && k.contains('management'))) {
      return 'Data Management';
    }
    if (k == 'compliance & legal' || k.contains('compliance') || k.contains('legal')) {
      return 'Compliance & Legal';
    }
    if (k == 'software' || k.contains('software')) return 'Software';

    // Arabic variants
    if (k.contains('التنفيذي')) return 'Executive';
    if (k.contains('دعم العملاء')) return 'Customer Support';
    if (k.contains('العمليات')) return 'Operations';
    if (k.contains('المالية')) return 'Finance';
    if (k.contains('تقنية المعلومات') || k == 'it') return 'Information Technology';
    if (k.contains('الموارد البشرية')) return 'Human Resources';
    if (k.contains('التسويق')) return 'Marketing';
    if (k.contains('المبيعات')) return 'Sales';
    if (k.contains('إدارة البيانات')) return 'Data Management';
    if (k.contains('الامتثال') || k.contains('القانون')) return 'Compliance & Legal';
    if (k.contains('البرمجيات')) return 'Software';

    return raw.trim();
  }

  // Get Localized Department
  String _getLocalizedDepartment(String departmentId, bool isArabic) {
    final deptController = departmentCubit;

    if (!departmentId.contains(RegExp(r'^[0-9]+$'))) {
      final deptId = deptController.getDepartmentIdFromDepartmentName(
        departmentName: departmentId.toLowerCase(),
      );

      if (deptId != null && deptId != "none") {
        return deptController.getDepartmentName(deptId, !isArabic);
      }

      return isArabic ? (_departmentTranslations[departmentId] ?? departmentId) : departmentId;
    }

    return deptController.getDepartmentName(departmentId, !isArabic);
  }

  // Cache Provider
  Future<Map<String, dynamic>?> getCachedServiceProvider(String serviceId) async {
    if (_providerCache.containsKey(serviceId)) {
      return _providerCache[serviceId];
    }

    final provider = await selectServiceProvider(serviceId);
    _providerCache[serviceId] = provider;
    return provider;
  }
}
