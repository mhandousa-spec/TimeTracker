/// Module: services_management_module
/// Description: Cubit owning I/O for the services-dashboard monthly
///              canceled/rejected chart: fetches CreateServices (for the
///              service-name dropdown) and RequestServices (for the
///              per-month canceled/rejected counts) via
///              CreateServicesRepository, resolves each request's
///              department/parent-service name, and buckets counts by
///              month. All Firestore access goes through
///              CreateServicesRepository — the UI only calls `loadData()`
///              and reacts to state.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, CreateServicesRepository,
///               MainCoreDepartmentCubit, MainCoreEmployeeController
/// Revision History: Initial version — extracted from
///                    MonthlyComparisonServicesChart's `_loadData()` (audit
///                    fix item 3: move I/O out of s8 UI).
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s8_dashboard/presentation/controller/services_dashboard_state.dart';

class ServicesDashboardCubit extends Cubit<ServicesDashboardState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;

  ServicesDashboardCubit({required this.repository})
      : super(const ServicesDashboardLoading());

  /// Mirrors the original widget's `_loadData()`: fetches all CreateServices
  /// docs (for the dropdown), fetches all RequestServices docs, resolves
  /// department + parent-service name per doc, filters by [userDepartmentName]
  /// and [selectedServiceName] (English or Arabic name match), and buckets
  /// canceled/rejected counts by month.
  Future<void> loadData({
    required MainCoreDepartmentCubit departmentController,
    required MainCoreEmployeeController employeeController,
    String? userDepartmentName,
    String? selectedServiceName,
  }) async {
    emit(const ServicesDashboardLoading());

    // STEP 1: all CreateServices docs, for the dropdown.
    final createServicesDocs = await repository.getAllCreateServiceDocs();

    final Set<String> allServicesSetEnglish = {};
    final Set<String> allServicesSetArabic = {};

    for (final data in createServicesDocs) {
      final nameEN = _extractValue(data['Service_Name_English']);
      final nameAR = _extractValue(data['Service_Name_Arabic']);
      if (nameEN.isNotEmpty) allServicesSetEnglish.add(nameEN);
      if (nameAR.isNotEmpty) allServicesSetArabic.add(nameAR);
    }

    // STEP 2: all RequestServices docs, for the chart data.
    final requestDocs = await repository.getAllRequestServiceDocs();

    final Map<int, Map<String, int>> monthlyData = {
      for (int i = 1; i <= 12; i++) i: {'canceled': 0, 'rejected': 0},
    };

    // Cache to avoid duplicate Firestore calls for the same Parent_Service_Id.
    final Map<String, Map<String, String>> serviceNameCache = {};

    for (final entry in requestDocs) {
      final docId = entry.key;
      final docData = entry.value;
      final model = ServicesHistoryModel.fromJson(docData, docId);

      // Department filter.
      String department = _normalizeDepartmentValue(
        docData['departmentRequester'],
        departmentController,
      );
      if (department.isEmpty) {
        final emailRequester = _extractValue(docData['Email_Requester']);
        if (emailRequester.isNotEmpty) {
          final employeeData =
              employeeController.mapOfEmployeesWithEmailKey[emailRequester];
          if (employeeData?.departmentId != null) {
            department = departmentController.getEnglishDepartmentNameFromDepartmentId(
                  departmentId: employeeData!.departmentId!,
                ) ??
                '';
          }
        }
      }

      // ✅ FIX (bug report p7): compare case- and whitespace-insensitively. An
      // exact `!=` meant a stored "compliance & legal" never matched the
      // controller's "Compliance & Legal", so the filter silently passed
      // everything through and other departments' services showed up.
      if (userDepartmentName != null &&
          department.trim().toLowerCase() !=
              userDepartmentName.trim().toLowerCase()) {
        continue;
      }

      // Get service name (with cache).
      String serviceNameEnglish = model.currentServiceNameEnglish;
      String serviceNameArabic = model.currentServiceNameArabic;

      if (serviceNameEnglish.isEmpty) {
        final parentId = _extractValue(docData['Parent_Service_Id']);
        if (parentId.isNotEmpty) {
          if (serviceNameCache.containsKey(parentId)) {
            serviceNameEnglish = serviceNameCache[parentId]!['en']!;
            serviceNameArabic = serviceNameCache[parentId]!['ar']!;
          } else {
            final createDocData = await repository
                .getCreateServiceDocByIdUnderTenantRoot(parentId);
            if (createDocData != null) {
              serviceNameEnglish = _extractValue(createDocData['Service_Name_English']);
              serviceNameArabic = _extractValue(createDocData['Service_Name_Arabic']);
              serviceNameCache[parentId] = {
                'en': serviceNameEnglish,
                'ar': serviceNameArabic,
              };
            }
          }
        }
      }

      if (serviceNameEnglish.isEmpty) serviceNameEnglish = 'Unknown Service';
      if (serviceNameArabic.isEmpty) serviceNameArabic = 'خدمة غير معروفة';

      // Filter by selected service.
      if (selectedServiceName != null && selectedServiceName.isNotEmpty) {
        if (serviceNameEnglish != selectedServiceName &&
            serviceNameArabic != selectedServiceName) {
          continue;
        }
      }

      final status = _getFinalStateFromModel(model).toLowerCase();
      if ((status == 'cancel' || status == 'canceled' || status == 'rejected') &&
          model.currentTimestamp != null) {
        final month = DateTime.fromMillisecondsSinceEpoch(model.currentTimestamp!).month;
        if (status == 'cancel' || status == 'canceled') {
          monthlyData[month]!['canceled'] = (monthlyData[month]!['canceled'] ?? 0) + 1;
        } else {
          monthlyData[month]!['rejected'] = (monthlyData[month]!['rejected'] ?? 0) + 1;
        }
      }
    }

    final sortedEN = allServicesSetEnglish.toList()..sort();
    final sortedAR = allServicesSetArabic.toList()..sort();

    emit(ServicesDashboardLoaded(ServicesDashboardData(
      monthlyData: monthlyData,
      allServicesEnglish: sortedEN,
      allServicesArabic: sortedAR,
    )));
  }

  String _normalizeDepartmentValue(
    dynamic departmentValue,
    MainCoreDepartmentCubit departmentController,
  ) {
    if (departmentValue == null) return '';
    String value = '';

    if (departmentValue is List && departmentValue.isNotEmpty) {
      value = departmentValue.last?.toString().trim() ?? '';
    } else {
      value = departmentValue.toString().trim();
    }

    if (value.isEmpty) return '';

    // Check if it's a department ID (numeric).
    if (int.tryParse(value) != null) {
      final departmentName = departmentController.getEnglishDepartmentNameFromDepartmentId(
        departmentId: value,
      );
      if (departmentName != null && departmentName.isNotEmpty) {
        return departmentName;
      }
    }

    // ✅ FIX (bug report p7): non-numeric values were returned verbatim, so a
    // doc storing the plain department name was compared against the canonical
    // name produced by getDepartmentName() — any difference in casing, spacing
    // or abbreviation made the comparison fail and the department filter let
    // other departments' services through.
    //
    // Resolve the name back to its id and out to the canonical English name so
    // both sides of the comparison are in the same form.
    final resolvedId =
        departmentController.getDepartmentIdFromDepartmentName(departmentName: value);
    if (resolvedId != null) {
      final canonical = departmentController
          .getEnglishDepartmentNameFromDepartmentId(departmentId: resolvedId);
      if (canonical != null && canonical.isNotEmpty) {
        return canonical;
      }
    }

    return value;
  }

  String _extractValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      if (value.isEmpty) return '';
      return value[0]?.toString() ?? '';
    }
    return value.toString();
  }

  String _getFinalStateFromModel(ServicesHistoryModel service) {
    final outerState = service.currentState.toLowerCase().trim();
    const knownStates = [
      'done', 'inprogress', 'branchsla', 'breached sla', 'cancel',
      'canceled', 'pending', 'approved', 'rejected',
    ];

    if (knownStates.contains(outerState)) {
      return outerState;
    }

    final approvalList = service.currentApprovalCycle;
    if (approvalList.isEmpty) return 'pending';

    final states = <String>[];
    for (final approval in approvalList) {
      final state = (approval.state ?? '').toString().toLowerCase();
      if (state.isNotEmpty) states.add(state);
    }

    if (states.isEmpty) return 'pending';
    if (states.contains('cancel') || states.contains('canceled')) return 'cancel';
    if (states.contains('rejected')) return 'rejected';
    if (states.contains('pending')) return 'pending';
    if (states.contains('inprogress')) return 'inprogress';
    if (states.isNotEmpty && states.every((s) => s == 'approved')) return 'approved';

    return 'pending';
  }
}
