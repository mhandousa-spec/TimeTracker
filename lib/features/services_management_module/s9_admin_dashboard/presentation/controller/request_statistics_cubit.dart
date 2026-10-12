/// Module: services_management_module
/// Description: Business logic for the Admin Dashboard Details page —
///              filtered request items, status/department/monthly counts,
///              and provider resolution. All Firestore access goes through
///              CreateServicesRepository, injected via the constructor.
/// Author: Amr Mesbah / Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, CreateServicesRepository, CreateServicesHelper
/// Revision History: 2026-07-02 (Knowticed Team) — audit fix item 4: removed
///                    the `?? GetServiceRepositoryImpl(...)` default; the
///                    repository is now required via the constructor (the
///                    one call site, AdminDashBoardDetailsTablet, constructs
///                    it explicitly).
import 'package:get/get.dart';

import 'dart:convert';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_state.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

part 'request_statistics_cubit_ext.dart';

const String _otherKey = "Other";

class DashboardDetailsCubit extends Cubit<DashboardDetailsState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  // Audit fix item 4: repository is now required via the constructor — no
  // more silent `GetServiceRepositoryImpl(firestore: FirebaseFirestore.instance)`
  // default. The single call site (AdminDashBoardDetailsTablet) now
  // constructs the repository explicitly and passes it in.
  final CreateServicesRepository _repository;

  /// Department lookups are injected; this cubit has no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  DashboardDetailsCubit({
    required CreateServicesRepository repository,
    required this.departmentCubit,
  })  : _repository = repository,
        super(DashboardDetailsState.initial());

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> bootstrap({required String selectedServiceName}) async {
    emit(state.copyWith(bootstrapping: true));
    _initializeDepartmentData();
    try {
      await _loadFilteredItems(selectedServiceName: selectedServiceName);
      await Future.wait([
        _loadServiceStatusData(),
        _fetchMonthlyServiceCounts(selectedServiceName: selectedServiceName),
        _fetchDepartmentCounts(selectedServiceName: selectedServiceName),
      ]);
    } catch (e, st) {
    } finally {
      emit(state.copyWith(bootstrapping: false, bootstrapped: true));
    }
  }

  void toggleTab(bool showRequested) =>
      emit(state.copyWith(showRequestedServices: showRequested));

  void toggleChartMode(bool showCount, {required String selectedServiceName}) {
    emit(state.copyWith(showServiceCount: showCount, isLoading: true));
    if (showCount) {
      _fetchMonthlyServiceCounts(selectedServiceName: selectedServiceName);
    } else {
      _fetchMonthlyDurationInHours(selectedServiceName: selectedServiceName);
    }
  }

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
    emit(next);
    emit(next.copyWith(displayedItems: _computeDisplayedItems(next)));
  }

  void onSearchChanged(String query) {
    final next = state.copyWith(searchQuery: query);
    emit(next.copyWith(displayedItems: _computeDisplayedItems(next)));
  }

  // ─── Provider Stats (called from UI widgets) ───────────────────────────────

  List<String> getUniqueProviderNames(List<Map<String, dynamic>> items) {
    final Set<String> names = {};
    for (final item in items) {
      final provider = item['provider']?.toString() ?? '';
      if (provider.isNotEmpty) names.add(provider);
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

      final status = item['status']?.toString().toLowerCase() ?? '';
      if (status == 'done') done++;
      if (status == 'breached sla' || status == 'branchsla') breached++;

      final val = double.tryParse(item['duration']?.toString() ?? '0') ?? 0;
      final unit = item['unit']?.toString().toLowerCase() ?? 'minutes';
      totalMinutes += switch (unit) {
        'minutes' => val,
        'hours'   => val * 60,
        'days'    => val * 1440,
        'weeks'   => val * 10080,
        _         => 0,
      };

      name ??= item['provider'];
      department ??= item['department'];
      jobTitle ??= item['jobTitleRequester'];
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

  double getPercentage(String key) {
    final total = state.statusCounts.values.fold<int>(0, (a, b) => a + b);
    final value = state.statusCounts[key] ?? 0;
    return total == 0 ? 0.0 : (value / total) * 100.0;
  }

  Map<String, int> getTop5Departments() {
    final sorted = state.departmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  void _initializeDepartmentData() {
    try {
      final departmentController = departmentCubit;
      final Map<String, String> enToAr = {};
      final List<String> known = [];

      for (final id in departmentController.departmentIds) {
        final en = departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: id);
        final ar = departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: id);
        if (en != null && ar != null) {
          enToAr[en] = ar;
          known.add(en);
        }
      }

      enToAr[_otherKey] = MainCoreDepartmentCubit.otherAr;

      emit(state.copyWith(enToArDepartments: enToAr, knownDepartments: known));
    } catch (e) {
      emit(state.copyWith(enToArDepartments: {_otherKey: MainCoreDepartmentCubit.otherAr}, knownDepartments: []));
    }
  }

  // ─── Private: Data loading ─────────────────────────────────────────────────

  Future<void> _loadFilteredItems({required String selectedServiceName}) async {

    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    // C06: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final List<Map<String, dynamic>> results = [];

    for (int i = 0; i < docs.length; i++) {
      final data = docs[i].value;
      final docId = docs[i].key;

      try {
        // ── Email_Requester ──────────────────────────────────────────────────
        final emailRequester = _extractValue(data['Email_Requester']);
        if (emailRequester.isEmpty) continue;

        // ── Service name ─────────────────────────────────────────────────────
        String serviceNameEn = _extractValue(data['Service_Name_English']);
        String serviceNameAr = _extractValue(data['Service_Name_Arabic']);
        final parentServiceId = _extractValue(data['Parent_Service_Id']);

        if ((serviceNameEn.isEmpty || serviceNameAr.isEmpty) && parentServiceId.isNotEmpty) {
          final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
            parentServiceId: parentServiceId,
            emailRequester: emailRequester,
          );
          if (serviceNameEn.isEmpty) serviceNameEn = details['serviceNameEnglish'] ?? '';
          if (serviceNameAr.isEmpty) serviceNameAr = details['serviceNameArabic'] ?? '';
        }

        if (serviceNameEn != selectedServiceName) continue;

        // ── Requester data ───────────────────────────────────────────────────
        final employee = employeeController.mapOfEmployeesWithEmailKey[emailRequester];
        if (employee == null) continue;

        final normalizedDepartment = (employee.departmentId?.isNotEmpty == true)
            ? (departmentController.getEnglishDepartmentNameFromDepartmentId(
            departmentId: employee.departmentId!) ??
            '')
            : '';

        // ── Provider data (5-method resolution) ─────────────────────────────
        final providerData = _resolveProvider(
          data: data,
          emailRequester: emailRequester,
          employeeController: employeeController,
        );
        final selectedProvider = providerData['map'] as Map<String, dynamic>;
        final firstNameProvider = providerData['firstName'] as String;
        final lastNameProvider = providerData['lastName'] as String;
        final firstNameProviderAr = providerData['firstNameArabic'] as String;
        final lastNameProviderAr = providerData['lastNameArabic'] as String;

        // ── Status ───────────────────────────────────────────────────────────
        final status = _resolveFinalState(data);

        // ── Timestamp ────────────────────────────────────────────────────────
        Timestamp requestTimestamp = Timestamp.now();
        final tsArray = data['timestamps'];
        if (tsArray is List && tsArray.isNotEmpty) {
          final ts = tsArray.last;
          if (ts is int) requestTimestamp = Timestamp.fromMillisecondsSinceEpoch(ts);
        }

        // ── Duration ─────────────────────────────────────────────────────────
        String durationStr = '0';
        String unit = 'minutes';
        if (parentServiceId.isNotEmpty) {
          final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
            parentServiceId: parentServiceId,
            emailRequester: emailRequester,
          );
          durationStr = details['duration'] ?? '0';
          unit = details['unit'] ?? 'minutes';
        }

        results.add({
          'no': results.length + 1,
          'department': normalizedDepartment,
          'serviceName': serviceNameEn,
          'serviceNameArabic': serviceNameAr,
          'gender': employee.gender ?? '',
          'requestor': '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
          'requestorArabic': '${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}'.trim(),
          'firstNameRequester': employee.firstName ?? '',
          'lastNameRequester': employee.lastName ?? '',
          'firstNameRequesterArabic': employee.firstNameInArabic ?? '',
          'lastNameRequesterArabic': employee.lastNameInArabic ?? '',
          'jobTitleRequester': employee.title ?? '',
          'jobTitleRequesterArabic': employee.titleInArabic ?? '',
          'requestDate': requestTimestamp,
          'status': status,
          'provider': '$firstNameProvider $lastNameProvider'.trim(),
          'firstNameProvider': firstNameProvider,
          'lastNameProvider': lastNameProvider,
          'firstNameProviderArabic': firstNameProviderAr,
          'lastNameProviderArabic': lastNameProviderAr,
          'docId': docId,
          'raw': data,
          'selectedProvider': selectedProvider,
          'duration': durationStr,
          'unit': unit,
        });

      } catch (e, st) {
      }
    }

    emit(state.copyWith(
      filteredItems: results,
      displayedItems: results,
    ));
  }

  Future<void> _loadServiceStatusData() async {
    final Map<String, int> counts = {
      'done': 0,
      'approved': 0,
      'pending': 0,
      'inprogress': 0,
      'branchsla': 0,
      'rejected': 0,
      'canceled': 0,
    };

    for (final item in state.filteredItems) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      if (counts.containsKey(status)) counts[status] = (counts[status] ?? 0) + 1;
    }

    emit(state.copyWith(
      statusCounts: counts,
      isLoadingFirst: false,
    ));
  }

  Future<void> _fetchMonthlyServiceCounts({required String selectedServiceName}) async {
    // C06: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<int, double> counts = {for (int i = 0; i < 12; i++) i: 0};

    for (final doc in docs) {
      try {
        final data = doc.value;
        String serviceNameEn = _extractValue(data['Service_Name_English']);

        if (serviceNameEn.isEmpty) {
          final parentServiceId = _extractValue(data['Parent_Service_Id']);
          final emailRequester = _extractValue(data['Email_Requester']);
          if (parentServiceId.isNotEmpty && emailRequester.isNotEmpty) {
            final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
              parentServiceId: parentServiceId,
              emailRequester: emailRequester,
            );
            serviceNameEn = details['serviceNameEnglish'] ?? '';
          }
        }

        if (serviceNameEn != selectedServiceName) continue;

        int? tsValue;
        final tsArray = data['timestamps'];
        if (tsArray is List && tsArray.isNotEmpty) {
          final last = tsArray.last;
          if (last is int) tsValue = last;
          else if (last is Timestamp) tsValue = last.millisecondsSinceEpoch;
          else if (last is String) tsValue = int.tryParse(last);
        }

        if (tsValue != null) {
          final month = DateTime.fromMillisecondsSinceEpoch(tsValue).month - 1;
          counts[month] = (counts[month] ?? 0) + 1;
        }
      } catch (e) {
      }
    }

    emit(state.copyWith(monthCounts: counts, isLoading: false));
  }

  Future<void> _fetchMonthlyDurationInHours({required String selectedServiceName}) async {
    // C06: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<int, num> hours = {for (int i = 0; i < 12; i++) i: 0};

    for (final doc in docs) {
      try {
        final data = doc.value;
        String serviceNameEn = _extractValue(data['Service_Name_English']);

        if (serviceNameEn.isEmpty) {
          final parentServiceId = _extractValue(data['Parent_Service_Id']);
          final emailRequester = _extractValue(data['Email_Requester']);
          if (parentServiceId.isNotEmpty && emailRequester.isNotEmpty) {
            final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
              parentServiceId: parentServiceId,
              emailRequester: emailRequester,
            );
            serviceNameEn = details['serviceNameEnglish'] ?? '';
          }
        }

        if (serviceNameEn != selectedServiceName) continue;

        final parentServiceId = _extractValue(data['Parent_Service_Id']);
        final emailRequester = _extractValue(data['Email_Requester']);
        if (parentServiceId.isEmpty || emailRequester.isEmpty) continue;

        final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
          parentServiceId: parentServiceId,
          emailRequester: emailRequester,
        );

        final val = double.tryParse(details['duration'] ?? '') ?? 0;
        final unit = (details['unit'] ?? '').toLowerCase();
        if (val <= 0 || unit.isEmpty) continue;

        final h = switch (unit) {
          'minutes' => val / 60,
          'hours'   => val,
          'days'    => val * 24,
          'weeks'   => val * 168,
          _         => 0.0,
        };
        if (h <= 0) continue;

        int? tsValue;
        final tsArray = data['timestamps'];
        if (tsArray is List && tsArray.isNotEmpty) {
          final last = tsArray.last;
          if (last is int) tsValue = last;
        }
        if (tsValue == null) continue;

        final month = DateTime.fromMillisecondsSinceEpoch(tsValue).month - 1;
        hours[month] = (hours[month] ?? 0) + h;
      } catch (e) {
      }
    }

    emit(state.copyWith(monthHours: hours, isLoading: false));
  }

  Future<void> _fetchDepartmentCounts({required String selectedServiceName}) async {
    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    // C06: request docs come from the repository, not Firestore directly.
    final docs = await _repository.getAllRequestServiceDocs();

    final Map<String, int> counts = {
      for (final dept in state.knownDepartments) dept: 0,
      _otherKey: 0,
    };

    for (final doc in docs) {
      try {
        final data = doc.value;
        String serviceNameEn = _extractValue(data['Service_Name_English']);

        if (serviceNameEn.isEmpty) {
          final parentServiceId = _extractValue(data['Parent_Service_Id']);
          final emailRequester = _extractValue(data['Email_Requester']);
          if (parentServiceId.isNotEmpty && emailRequester.isNotEmpty) {
            final details = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
              parentServiceId: parentServiceId,
              emailRequester: emailRequester,
            );
            serviceNameEn = details['serviceNameEnglish'] ?? '';
          }
        }

        if (serviceNameEn != selectedServiceName) continue;

        final emailRequester = _extractValue(data['Email_Requester']);
        final employee = employeeController.mapOfEmployeesWithEmailKey[emailRequester];

        String dept = '';
        if (employee != null && employee.departmentId?.isNotEmpty == true) {
          dept = departmentController.getEnglishDepartmentNameFromDepartmentId(
              departmentId: employee.departmentId!) ??
              '';
        }

        final key = _normalizeDepartmentKey(dept);
        counts[key] = (counts[key] ?? 0) + 1;
      } catch (e) {
      }
    }

    emit(state.copyWith(departmentCounts: counts, isLoadingDepartments: false));
  }

  // ─── Private: Filter / search ──────────────────────────────────────────────

  List<Map<String, dynamic>> _computeDisplayedItems(DashboardDetailsState s) {
    final query = s.searchQuery.toLowerCase().trim();

    return s.filteredItems.where((item) {
      final matchesQuery = query.isEmpty ||
          [
            item['department'],
            item['serviceName'],
            item['serviceNameArabic'],
            item['requestor'],
            item['requestorArabic'],
            item['status'],
            item['provider'],
          ].join(' ').toLowerCase().contains(query);

      final matchesDept = s.activeDepartment == null ||
          s.activeDepartment!.isEmpty ||
          item['department'] == s.activeDepartment;

      final matchesStatus = s.activeStatus == null ||
          s.activeStatus!.isEmpty ||
          item['status']?.toString().toLowerCase() == s.activeStatus!.toLowerCase();

      final ts = item['requestDate'] as Timestamp;
      final modelDate = ts.toDate();
      final matchesDate = s.activeDate == null ||
          (modelDate.year == s.activeDate!.year &&
              modelDate.month == s.activeDate!.month &&
              modelDate.day == s.activeDate!.day);

      return matchesQuery && matchesDept && matchesStatus && matchesDate;
    }).toList();
  }

  // ─── Private: Provider resolution (5 methods, mirrors admin_cubit.dart) ────

  Map<String, dynamic> _resolveProvider({
    required Map<String, dynamic> data,
    required String emailRequester,
    required MainCoreEmployeeController employeeController,
  }) {
    Map<String, dynamic> selectedProvider = {};
    String firstName = '';
    String lastName = '';
    String firstNameAr = '';
    String lastNameAr = '';

    // Method 1: selectedServiceProvider map
    if (data['selectedServiceProvider'] is Map) {
      final map = Map<String, dynamic>.from(data['selectedServiceProvider'] as Map);
      selectedProvider = map;
      firstName = map['firstName']?.toString() ?? '';
      lastName = map['lastName']?.toString() ?? '';
      firstNameAr = map['firstNameInArabic']?.toString() ?? '';
      lastNameAr = map['lastNameInArabic']?.toString() ?? '';
    }

    // Method 2: Provider_Services JSON
    if (selectedProvider.isEmpty && data['Provider_Services'] is List) {
      final list = data['Provider_Services'] as List;
      if (list.isNotEmpty) {
        final last = list.last;
        String? raw;
        if (last is String) raw = last;
        else if (last is Map) raw = jsonEncode(last);

        if (raw != null) {
          try {
            final decoded = jsonDecode(raw);
            Map<String, dynamic>? provMap;
            if (decoded is List && decoded.isNotEmpty) {
              provMap = Map<String, dynamic>.from(decoded.first as Map);
            } else if (decoded is Map) {
              provMap = Map<String, dynamic>.from(decoded);
            }
            if (provMap != null) {
              final email = provMap['email']?.toString() ?? provMap['providerEmail']?.toString() ?? '';
              final emp = email.isNotEmpty ? employeeController.mapOfEmployeesWithEmailKey[email] : null;
              if (emp != null) {
                selectedProvider = _buildProviderMap(emp);
                firstName = emp.firstName ?? '';
                lastName = emp.lastName ?? '';
                firstNameAr = emp.firstNameInArabic ?? '';
                lastNameAr = emp.lastNameInArabic ?? '';
              }
            }
          } catch (_) {}
        }
      }
    }

    // Method 3: Assigned_Provider_Email
    if (selectedProvider.isEmpty && data['Assigned_Provider_Email'] != null) {
      final assignedEmails = data['Assigned_Provider_Email'];
      String? providerEmail;
      if (assignedEmails is List && assignedEmails.isNotEmpty) {
        providerEmail = assignedEmails[0]?.toString();
        if (providerEmail == null || providerEmail.isEmpty || providerEmail == emailRequester) {
          if (assignedEmails.length > 1) providerEmail = assignedEmails[1]?.toString();
        }
      }
      if (providerEmail != null && providerEmail.isNotEmpty && providerEmail != emailRequester) {
        final emp = employeeController.mapOfEmployeesWithEmailKey[providerEmail];
        if (emp != null) {
          selectedProvider = _buildProviderMap(emp);
          firstName = emp.firstName ?? '';
          lastName = emp.lastName ?? '';
          firstNameAr = emp.firstNameInArabic ?? '';
          lastNameAr = emp.lastNameInArabic ?? '';
        }
      }
    }

    // Method 4: state array — scan providerEmail / assignedTo / provider fields
    if (selectedProvider.isEmpty && data['state'] is List) {
      final stateList = data['state'] as List;
      for (final entry in stateList) {
        if (entry is Map) {
          final email = (entry['providerEmail'] ?? entry['assignedTo'] ?? entry['provider'])?.toString() ?? '';
          if (email.isNotEmpty && email != emailRequester) {
            final emp = employeeController.mapOfEmployeesWithEmailKey[email];
            if (emp != null) {
              selectedProvider = _buildProviderMap(emp);
              firstName = emp.firstName ?? '';
              lastName = emp.lastName ?? '';
              firstNameAr = emp.firstNameInArabic ?? '';
              lastNameAr = emp.lastNameInArabic ?? '';
              break;
            }
          }
        }
      }
    }

    // Method 5: approvalCycle map
    if (selectedProvider.isEmpty && data['approvalCycle'] != null) {
      final cycle = data['approvalCycle'];
      List cycleList = [];
      if (cycle is List) cycleList = cycle;
      else if (cycle is Map) cycleList = [cycle];

      for (final entry in cycleList) {
        if (entry is Map) {
          final email = (entry['email'] ?? entry['approverEmail'])?.toString() ?? '';
          if (email.isNotEmpty && email != emailRequester) {
            final emp = employeeController.mapOfEmployeesWithEmailKey[email];
            if (emp != null) {
              selectedProvider = _buildProviderMap(emp);
              firstName = emp.firstName ?? '';
              lastName = emp.lastName ?? '';
              firstNameAr = emp.firstNameInArabic ?? '';
              lastNameAr = emp.lastNameInArabic ?? '';
              break;
            }
          }
        }
      }
    }

    // Safety: ensure gender key always exists
    if (!selectedProvider.containsKey('gender')) {
      selectedProvider['gender'] = '';
    }

    return {
      'map': selectedProvider,
      'firstName': firstName,
      'lastName': lastName,
      'firstNameArabic': firstNameAr,
      'lastNameArabic': lastNameAr,
      'name': '$firstName $lastName'.trim(),
    };
  }

  Map<String, dynamic> _buildProviderMap(dynamic emp) => {
    'firstName': emp.firstName ?? '',
    'lastName': emp.lastName ?? '',
    'firstNameInArabic': emp.firstNameInArabic ?? '',
    'lastNameInArabic': emp.lastNameInArabic ?? '',
    'email': emp.email ?? '',
    'gender': emp.gender ?? '',
    'title': emp.title ?? '',
    'titleInArabic': emp.titleInArabic ?? '',
    'departmentId': emp.departmentId ?? '',
  };

  // ─── Private: State resolution ─────────────────────────────────────────────

}
