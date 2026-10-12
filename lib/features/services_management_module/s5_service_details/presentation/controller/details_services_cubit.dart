// ******************* FILE INFO *******************
// File Name: details_services_cubit
// Description: Details services cubit.
// Module: services_management_module / presentation/s5_service_details/controller
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/data/service_stats_model.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/controller/details_services_state.dart';

class DetailsServicesCubit extends Cubit<DetailsServicesState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  DetailsServicesCubit() : super(DetailsServicesInitial());

  static DetailsServicesCubit get(BuildContext context) => BlocProvider.of(context);

  // Core Data
  List<Map<String, dynamic>> _filteredItems = [];
  List<Map<String, dynamic>> _displayedItems = [];
  List<EmployeeEntityModell> _allEmployees = [];
  List<Map<String, dynamic>> _displayedStats = [];
  ServiceStatsModel _stats = ServiceStatsModel.empty();

  // ✅ Filter State - Multi-select support
  List<String>? _filterDepartments;
  List<String>? _filterStatuses;
  DateTime? _filterDate;
  String? _filterSortBy; // ✅ NEW: For employees tab sorting

  // Tab State
  bool _isEmployeesTab = false;

  // Getters
  List<Map<String, dynamic>> get filteredItems => _filteredItems;
  List<Map<String, dynamic>> get displayedItems => _displayedItems;
  List<EmployeeEntityModell> get allEmployees => _allEmployees;
  ServiceStatsModel get stats => _stats;
  bool get isEmployeesTab => _isEmployeesTab;

  // ✅ Filter state getters
  List<String>? get selectedDepartments => _filterDepartments;
  List<String>? get selectedStatuses => _filterStatuses;
  DateTime? get selectedDate => _filterDate;
  String? get selectedSortBy => _filterSortBy; // ✅ NEW

  Future<void> initialize(String serviceId, ServicesHistoryModel serviceModel, BuildContext context) async {
    emit(DetailsServicesLoading());

    try {
      await Future.wait([
        _loadEmployees(),
        _loadFilteredItems(serviceId, serviceModel, context),
        ServicesManagerCubit.get(context).loadProviderPerDocument(),
      ]);

      emit(DetailsServicesLoaded(
        filteredItems: _filteredItems,
        displayedItems: _displayedItems,
        allEmployees: _allEmployees,
        displayedStats: _displayedStats,
        stats: _stats,
      ));
    } catch (e) {
      emit(DetailsServicesError(e.toString()));
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final controller = AppControllers.employee;
      final employees = await controller.getAllNewEmployees();

      if (employees != null) {
        _allEmployees = _convertEmployees(employees);
      }
    } catch (e) {
    }
  }

  List<EmployeeEntityModell> _convertEmployees(List<EmployeeEntityPro> employees) {
    return employees.map((pro) {
      return EmployeeEntityModell(
        id: pro.id,
        state: pro.status,
        firstName: pro.firstName,
        middleName: pro.middleName,
        lastName: pro.lastName,
        firstNameInArabic: pro.firstNameInArabic,
        middleNameInArabic: pro.middleNameInArabic,
        lastNameInArabic: pro.lastNameInArabic,
        nationalId: pro.nationalId,
        nationalIdExpirationDate: pro.nationalIdExpirationDate,
        nationality: pro.nationality,
        passport: pro.passport,
        passportExpirationDate: pro.passportExpirationDate,
        email: pro.email,
        mobilePhone: pro.mobilePhone != null
            ? ServicesMobilePhoneEntity(
          phone: pro.mobilePhone!.phone,
          countryCode: pro.mobilePhone!.countryCode,
          countryApp: pro.mobilePhone!.countryApp,
        )
            : null,
        officePhone: pro.officePhone,
        homePhone: pro.homePhone,
        extension: pro.extension,
        birthDay: pro.birthDay,
        gender: pro.gender,
        country: pro.country,
        province: pro.province,
        city: pro.city,
        postalCode: pro.postalCode,
        street: pro.street,
        maritalStatus: pro.maritalStatus,
        language: pro.language,
        departmentId: pro.departmentId,
        supervisor: pro.supervisor,
        role: pro.role,
        title: pro.title,
        titleInArabic: pro.titleInArabic,
        workLocation: pro.workLocation,
        drivingLicenseId: pro.drivingLicenseId,
        carPlates: pro.carPlates,
        academicHistory: pro.academicHistory != null
            ? AcademicHistoryEntity(
          gpa: pro.academicHistory!.gpa,
          graduateFrom: pro.academicHistory!.graduateFrom,
          university: pro.academicHistory!.university,
          yearOfGraduation: pro.academicHistory!.yearOfGraduation,
          graduateFromStatus: pro.academicHistory!.graduateFromStatus,
          universityStatus: pro.academicHistory!.universityStatus,
          yearOfGraduationStatus: pro.academicHistory!.yearOfGraduationStatus,
          gpaStatus: pro.academicHistory!.gpaStatus,
        )
            : null,
        bio: pro.bio,
        photo: pro.photo,
        skills: pro.skills,
        hobbies: pro.hobbies,
        status: pro.status,
        firstLogin: pro.firstLogin,
        lastLogin: pro.lastLogin,
        deactivationDate: pro.deactivationDate,
        activationDate: pro.activationDate,
      );
    }).toList();
  }

  Future<void> _loadFilteredItems(String serviceId, ServicesHistoryModel serviceModel, BuildContext context) async {
    try {
      final result = await ServicesManagerCubit.get(context).loadFilteredItems(
        parentServiceId: serviceId,
        context: context,
        parentService: serviceModel,
      );

      _filteredItems = result['filteredItems'] as List<Map<String, dynamic>>;
      _displayedItems = _filteredItems;
      _allEmployees = result['allEmployees'] as List<EmployeeEntityModell>;
      _displayedStats = result['displayedStats'] as List<Map<String, dynamic>>;
      _stats = ServiceStatsModel.fromMap(result['localStats'] as Map<String, int>);

    } catch (e) {
      throw e;
    }
  }

  void applySearch(String query) {
    final searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      _displayedItems = _filteredItems;
      emit(DetailsServicesSearchApplied());
      return;
    }

    if (_isEmployeesTab) {
      emit(DetailsServicesSearchApplied());
      return;
    }

    _displayedItems = _filteredItems.where((item) {
      final model = item["model"] as ServicesHistoryModel;

      // ✅ FIX: Extract actual values from lists
      String extractFromList(dynamic value) {
        if (value == null) return "";
        if (value is List) {
          // Join non-empty values from the list
          return value.where((e) => e != null && e.toString().trim().isNotEmpty)
              .map((e) => e.toString())
              .join(" ");
        }
        return value.toString();
      }

      final firstName = extractFromList(model.firstNameRequester).toLowerCase();
      final lastName = extractFromList(model.lastNameRequester).toLowerCase();
      final firstNameAr = extractFromList(model.firstNameRequesterArabic).toLowerCase();
      final lastNameAr = extractFromList(model.lastNameRequesterArabic).toLowerCase();
      final department = extractFromList(model.departmentRequester).toLowerCase();
      final departmentAr = extractFromList(model.departmentRequesterArabic).toLowerCase();
      final email = extractFromList(model.currentEmailRequester).toLowerCase();

      // Combine all searchable text
      final searchableText = [
        firstName,
        lastName,
        firstNameAr,
        lastNameAr,
        department,
        departmentAr,
        email,
      ].join(" ").toLowerCase();

      return searchableText.contains(searchQuery);
    }).toList();

    emit(DetailsServicesSearchApplied());
  }

  // ✅ UPDATED: Multi-select filter + sorting support
  void applyFilter({
    List<String>? departments,
    List<String>? statuses,
    DateTime? date,
    String? sortBy, // ✅ NEW parameter
  }) {
    _filterDepartments = departments;
    _filterStatuses = statuses;
    _filterDate = date;
    _filterSortBy = sortBy; // ✅ NEW

    if (_isEmployeesTab) {
      // EMPLOYEES TAB: Filter by department only
      _displayedItems = _filteredItems.where((item) {
        final matchesDepartment = _filterDepartments == null ||
            _filterDepartments!.isEmpty ||
            _filterDepartments!.contains(item["department"]);

        return matchesDepartment;
      }).toList();

      // ✅ Apply sorting for employees
      if (_filterSortBy != null && _filterSortBy!.isNotEmpty) {
        _displayedItems.sort((a, b) {
          final statusA = (a["status"]?.toString() ?? "").toLowerCase();
          final statusB = (b["status"]?.toString() ?? "").toLowerCase();

          if (_filterSortBy == "Done") {
            if (statusA == "done" && statusB != "done") return -1;
            if (statusA != "done" && statusB == "done") return 1;
            return 0;
          } else if (_filterSortBy == "Breached SLA") {
            final isBreachedA = statusA == "breached sla" || statusA == "branchsla";
            final isBreachedB = statusB == "breached sla" || statusB == "branchsla";

            if (isBreachedA && !isBreachedB) return -1;
            if (!isBreachedA && isBreachedB) return 1;
            return 0;
          }
          return 0;
        });
      }
    } else {
      // REQUESTED SERVICES TAB: Filter by department, status, and date
      _displayedItems = _filteredItems.where((item) {
        final model = item["model"] as ServicesHistoryModel;

        final matchesDepartment = _filterDepartments == null ||
            _filterDepartments!.isEmpty ||
            _filterDepartments!.contains(item["department"]);

        final matchesStatus = _filterStatuses == null ||
            _filterStatuses!.isEmpty ||
            _filterStatuses!.any((status) =>
            item["status"]?.toString().toLowerCase() == status.toLowerCase());

        final DateTime? modelDate = model.currentDurationOfServicesTimestamp?.toDate();

        final matchesDate = _filterDate == null ||
            (modelDate != null &&
                modelDate.year == _filterDate!.year &&
                modelDate.month == _filterDate!.month &&
                modelDate.day == _filterDate!.day);

        return matchesDepartment && matchesStatus && matchesDate;
      }).toList();
    }

    emit(DetailsServicesFilterApplied(_displayedItems));
  }

  void clearFilters() {
    _filterDepartments = null;
    _filterStatuses = null;
    _filterDate = null;
    _filterSortBy = null;
    _displayedItems = _filteredItems;
    emit(DetailsServicesFilterApplied(_displayedItems));
  }

  // ✅ UPDATED: Include sortBy in active filters check
  bool get hasActiveFilters =>
      (_filterDepartments?.isNotEmpty ?? false) ||
          (_filterStatuses?.isNotEmpty ?? false) ||
          _filterDate != null ||
          (_filterSortBy?.isNotEmpty ?? false);

  void changeTab(bool isEmployees) {
    _isEmployeesTab = isEmployees;
    clearFilters(); // ✅ Clear filters when switching tabs
    emit(DetailsServicesTabChanged(isEmployees));
  }

  Future<void> refresh(String serviceId, ServicesHistoryModel serviceModel, BuildContext context) async {
    await initialize(serviceId, serviceModel, context);
  }
}
