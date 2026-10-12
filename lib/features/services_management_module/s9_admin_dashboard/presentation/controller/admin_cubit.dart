// ******************* FILE INFO *******************
// File Name: admin_cubit.dart
// Description: Business logic for Admin Dashboard
// Module: services_management_module / presentation / s9_admin_dashboard / controller
// Created by: Amr Mesbah
import 'package:get/get.dart';

import 'dart:convert';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

part 'admin_cubit_helpers.dart';

class DashboardAdminCubit extends Cubit<DashboardAdminState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Department lookups are injected; this cubit has no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  DashboardAdminCubit({required this.departmentCubit})
      : super(DashboardAdminState.initial());

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> bootstrap() async {
    emit(state.copyWith(bootstrapping: true));
    try {
      await Future.wait([
        loadServiceStatusData(),
        fetchDepartmentCountsFilter(),
        fetchMonthlyServiceCounts(),
        fetchServiceUsageCounts(),
        fetchDepartmentCounts(),
        loadServiceStatusDataFilter(),
        loadFilteredServices(),
        loadRequestsData(),
      ]);
    } catch (e, st) {
    } finally {
      emit(state.copyWith(bootstrapping: false, bootstrapped: true, tableDataLoaded: true));
    }
  }

  Future<void> onDepartmentChanged(String newStatus) async {
    emit(state.copyWith(
      selectStatus: newStatus,
      isServiceListLoading: true,
      isLoadingRequests: true,
      isLoading: true,
      isLoadingServicesName: true,
      allServices: [],
      displayedItems: [],
      monthCounts: {},
      monthHours: {},
      monthCountss: {},
      serviceNames: [],
      serviceNamesArabic: [],
    ));

    try {
      await Future.wait([
        loadServiceStatusDataFilter(),
        loadFilteredServices(),
        loadRequestsData(),
        fetchServiceUsageCounts(),
        fetchMonthlyServiceCounts(),
        fetchMonthlyDurationInHours(),
      ]);
    } catch (e, st) {
    }
  }

  void toggleShowAll() => emit(state.copyWith(showAll: !state.showAll));

  void toggleServiceCount(bool showCount) {
    emit(state.copyWith(showServiceCount: showCount, isLoading: true));
    if (showCount) {
      fetchMonthlyServiceCounts();
    } else {
      fetchMonthlyDurationInHours();
    }
  }

  void toggleShowRequests(bool show) => emit(state.copyWith(showRequests: show));

  // ─── Data Loading ──────────────────────────────────────────────────────────

  Future<void> loadRequestsData() async {
    emit(state.copyWith(isLoadingRequests: true, displayedItems: []));
    // Bug report p.24 (the table's spinner under Filter never went away):
    // any throw before the final emit — the Firestore read, a department
    // lookup — left isLoadingRequests at true for good. Always clear it.
    try {
      await _loadRequestsDataInner();
    } catch (e, st) {
      debugPrint('[AdminCubit] loadRequestsData failed: $e\n$st');
      if (!isClosed) {
        emit(state.copyWith(isLoadingRequests: false));
      }
    }
  }

  Future<void> _loadRequestsDataInner() async {
    final firestore = FirebaseFirestore.instance;
    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    final servicesSnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    final List<Map<String, dynamic>> results = [];
    // One lookup per (parent service, requester) pair instead of one per
    // request document: repeat requests re-read the same parent service.
    final Map<String, Future<Map<String, String>>> serviceDetailsCache = {};

    for (int i = 0; i < servicesSnapshot.docs.length; i++) {
      final doc = servicesSnapshot.docs[i];
      final data = doc.data();
      final docId = doc.id;

      try {
        final emailRequester = _extractValue(data['Email_Requester']);
        if (emailRequester.isEmpty) continue;

        final employee = employeeController.mapOfEmployeesWithEmailKey[emailRequester];
        if (employee == null) continue;

        String normalizedDepartment = '';
        if (employee.departmentId != null && employee.departmentId!.isNotEmpty) {
          normalizedDepartment = departmentController
              .getEnglishDepartmentNameFromDepartmentId(
              departmentId: employee.departmentId!) ??
              '';
        }

        if (state.selectStatus != "All" && normalizedDepartment != state.selectStatus) continue;

        String serviceNameEnglish = _extractValue(data['Service_Name_English']);
        String serviceNameArabic = _extractValue(data['Service_Name_Arabic']);
        final parentServiceId = _extractValue(data['Parent_Service_Id']);

        if ((serviceNameEnglish.isEmpty || serviceNameArabic.isEmpty) &&
            parentServiceId.isNotEmpty) {
          final serviceDetails = await serviceDetailsCache.putIfAbsent(
            '$parentServiceId|$emailRequester',
            () => CreateServicesHelper.getServiceDetailsFromCreateServices(
              departments: departmentCubit,
              parentServiceId: parentServiceId,
              emailRequester: emailRequester,
            ),
          );
          if (serviceNameEnglish.isEmpty)
            serviceNameEnglish = serviceDetails['serviceNameEnglish'] ?? '';
          if (serviceNameArabic.isEmpty)
            serviceNameArabic = serviceDetails['serviceNameArabic'] ?? '';
        }

        final providerData = _resolveProvider(data, emailRequester, employeeController);

        final finalState = resolveFinalStateFromData(data);
        final requestDate = _resolveRequestDate(data);

        results.add({
          "no": results.length + 1,
          "department": normalizedDepartment,
          "serviceName": serviceNameEnglish,
          "serviceNameArabic": serviceNameArabic,
          "gender": employee.gender ?? '',
          "requestor": '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
          "firstNameRequester": employee.firstName ?? '',
          "lastNameRequester": employee.lastName ?? '',
          "firstNameRequesterArabic": employee.firstNameInArabic ?? '',
          "lastNameRequesterArabic": employee.lastNameInArabic ?? '',
          "provider": providerData['name'],
          "firstNameProvider": providerData['firstName'],
          "lastNameProvider": providerData['lastName'],
          "firstNameProviderArabic": providerData['firstNameArabic'],
          "lastNameProviderArabic": providerData['lastNameArabic'],
          "jobTitleRequester": employee.title ?? '',
          "jobTitleRequesterArabic": employee.titleInArabic ?? '',
          "requestDate": requestDate,
          "status": finalState,
          "docId": docId,
          "raw": data,
          "selectedProvider": providerData['map'],
        });
      } catch (e, st) {
      }
    }

    if (isClosed) return;
    emit(state.copyWith(displayedItems: results, isLoadingRequests: false));
  }

  Future<void> loadServiceStatusData() async {
    final counts = await calculateServiceStatesFilter();
    emit(state.copyWith(statusCounts: counts, isLoadingFirst: false));
  }

  Future<void> loadServiceStatusDataFilter() async {
    final filter =
    (state.selectStatus != "All") ? state.selectStatus : null;
    final counts =
    await calculateServiceStatesFilter(filterDepartment: filter);
    emit(state.copyWith(statusCounts: counts, isLoadingFirst: false));
  }

  Future<void> fetchMonthlyServiceCounts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    Map<int, double> counts = {for (int i = 0; i < 12; i++) i: 0};
    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();

        // ✅ FIX (bug report p8): only approved services are counted.
        //
        // Every request doc was counted regardless of its state, so pending
        // and rejected requests inflated the "Number Of Services" chart.
        if (resolveFinalStateFromData(data) != 'approved') continue;

        if (state.selectStatus != "All") {
          final email = _extractValue(data['Email_Requester']);
          if (email.isEmpty) continue;
          final emp = employeeController.mapOfEmployeesWithEmailKey[email];
          if (emp == null) continue;
          String dept = '';
          if (emp.departmentId?.isNotEmpty == true) {
            dept = departmentController.getEnglishDepartmentNameFromDepartmentId(
                departmentId: emp.departmentId!) ??
                '';
          }
          if (dept != state.selectStatus) continue;
        }

        final ts = _extractLatestTimestamp(data);
        if (ts != null) {
          final month = DateTime.fromMillisecondsSinceEpoch(ts).month - 1;
          counts[month] = (counts[month] ?? 0) + 1;
        }
      } catch (e) {
      }
    }

    emit(state.copyWith(monthCounts: counts, isLoading: false));
  }

  Future<void> fetchMonthlyDurationInHours() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    Map<int, double> durationPerMonth = {for (int i = 0; i < 12; i++) i: 0};
    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();

        // ✅ FIX (bug report p8): match the counts series — hours are only
        // accumulated for approved services, so the two toggle views agree.
        if (resolveFinalStateFromData(data) != 'approved') continue;

        if (state.selectStatus != "All") {
          final email = _extractValue(data['Email_Requester']);
          if (email.isEmpty) continue;
          final emp = employeeController.mapOfEmployeesWithEmailKey[email];
          if (emp == null) continue;
          String dept = '';
          if (emp.departmentId?.isNotEmpty == true) {
            dept = departmentController.getEnglishDepartmentNameFromDepartmentId(
                departmentId: emp.departmentId!) ??
                '';
          }
          if (dept != state.selectStatus) continue;
        }

        final parentServiceId = _extractValue(data['Parent_Service_Id']);
        final emailRequester = _extractValue(data['Email_Requester']);
        if (parentServiceId.isEmpty || emailRequester.isEmpty) continue;

        final serviceDetails =
        await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
          parentServiceId: parentServiceId,
          emailRequester: emailRequester,
        );

        final durationStr = serviceDetails['duration'] ?? '';
        final unit = serviceDetails['unit']?.toLowerCase() ?? '';
        if (durationStr.isEmpty || unit.isEmpty) continue;

        double value = double.tryParse(durationStr) ?? 0;
        if (value <= 0) continue;

        double hours = _toHours(value, unit);
        if (hours <= 0) continue;

        final ts = _extractLatestTimestamp(data);
        if (ts == null) continue;

        final month = DateTime.fromMillisecondsSinceEpoch(ts).month - 1;
        durationPerMonth[month] = (durationPerMonth[month] ?? 0) + hours;
      } catch (e) {
      }
    }

    emit(state.copyWith(monthHours: durationPerMonth, isLoading: false));
  }

  Future<void> fetchServiceUsageCounts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    Map<String, double> serviceIdToCount = {};
    Map<String, String> serviceIdToNameEn = {};
    Map<String, String> serviceIdToNameAr = {};

    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();

        if (state.selectStatus != "All") {
          final email = _extractValue(data['Email_Requester']);
          if (email.isEmpty) continue;
          final emp = employeeController.mapOfEmployeesWithEmailKey[email];
          if (emp == null) continue;
          String dept = '';
          if (emp.departmentId?.isNotEmpty == true) {
            dept = departmentController.getEnglishDepartmentNameFromDepartmentId(
                departmentId: emp.departmentId!) ??
                '';
          }
          if (dept != state.selectStatus) continue;
        }

        final parentServiceId = _getSafeString(data['Parent_Service_Id']);
        if (parentServiceId == null || parentServiceId.isEmpty) continue;

        serviceIdToCount[parentServiceId] =
            (serviceIdToCount[parentServiceId] ?? 0) + 1;

        final nameEn = _getSafeString(data['Service_Name_English']);
        final nameAr = _getSafeString(data['Service_Name_Arabic']);

        if ((nameEn == null || nameEn.isEmpty) &&
            (nameAr == null || nameAr.isEmpty)) {
          if (!serviceIdToNameEn.containsKey(parentServiceId)) {
            final email = _getSafeString(data['Email_Requester']);
            if (email != null && email.isNotEmpty) {
              final details =
              await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
                parentServiceId: parentServiceId,
                emailRequester: email,
              );
              serviceIdToNameEn[parentServiceId] =
                  details['serviceNameEnglish'] ?? '';
              serviceIdToNameAr[parentServiceId] =
                  details['serviceNameArabic'] ?? '';
            }
          }
        } else {
          serviceIdToNameEn[parentServiceId] = nameEn ?? '';
          serviceIdToNameAr[parentServiceId] = nameAr ?? '';
        }
      } catch (e) {
      }
    }

    List<String> tempNames = [];
    List<String> tempNamesAr = [];
    Map<int, double> tempCounts = {};

    int index = 0;
    for (var entry in serviceIdToCount.entries) {
      final nameEn = serviceIdToNameEn[entry.key] ?? '';
      final nameAr = serviceIdToNameAr[entry.key] ?? '';
      if (nameEn.isNotEmpty && !tempNames.contains(nameEn)) {
        tempNames.add(nameEn);
        tempNamesAr.add(nameAr);
        tempCounts[index] = entry.value;
        index++;
      }
    }

    emit(state.copyWith(
      serviceNames: tempNames,
      serviceNamesArabic: tempNamesAr,
      monthCountss: tempCounts,
      isLoadingServicesName: false,
    ));
  }

  Future<void> fetchDepartmentCounts() async {
    final counts = await _countDepartments();
    // ✅ FIX (bug report p5): keep the "All" chip in step with the department
    // chips. This emitted departmentCounts only, leaving totalServices at
    // whatever a previous load had set — so the All chip could read 4 while
    // the per-department chips beneath it summed to something else entirely.
    emit(state.copyWith(
      departmentCounts: counts,
      totalServices: counts.values.fold(0, (s, v) => s! + v),
      isLoadingDepartments: false,
    ));
  }

  Future<void> fetchDepartmentCountsFilter() async {
    final firestore = FirebaseFirestore.instance;
    final departmentController = departmentCubit;
    final employeeController = AppControllers.employee;
    final departments = departmentController.departmentsEnglishName;

    final Map<String, int> counts = {for (var d in departments) d: 0};

    try {
      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .get();

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final email = _extractValue(data['Email_Requester']);
          if (email.isEmpty) continue;

          final emp = employeeController.mapOfEmployeesWithEmailKey[email];
          if (emp == null || emp.departmentId == null || emp.departmentId!.isEmpty)
            continue;

          final deptName = departmentController
              .getEnglishDepartmentNameFromDepartmentId(
              departmentId: emp.departmentId!);

          if (deptName != null && counts.containsKey(deptName)) {
            counts[deptName] = counts[deptName]! + 1;
          }
        } catch (e) {
        }
      }
    } catch (e) {
    }

    // ✅ Emit dynamic departmentCounts map + totalServices
    //
    // ✅ FIX (bug report p5): drop departments with no services. `counts` is
    // seeded with every department at 0, so without this every department in
    // the tenant rendered as a chip even when it owned nothing.
    final nonEmptyCounts = {
      for (final entry in counts.entries)
        if (entry.value > 0) entry.key: entry.value,
    };

    emit(state.copyWith(
      departmentCounts: nonEmptyCounts,
      totalServices: nonEmptyCounts.values.fold(0, (s, v) => s! + v),
    ));
  }

  Future<void> loadFilteredServices() async {
    emit(state.copyWith(isServiceListLoading: true));

    final firestore = FirebaseFirestore.instance;
    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    final createServicesSnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .get();

    Map<String, Map<String, dynamic>> createServicesMap = {};
    Map<String, String> serviceNameToDocId = {};
    List<Map<String, dynamic>> allServicesData = [];

    for (var serviceDoc in createServicesSnapshot.docs) {
      try {
        final data = serviceDoc.data();
        final email = _extractValue(data['Email_Requester']);
        String department = '';

        if (email.isNotEmpty) {
          final emp = employeeController.mapOfEmployeesWithEmailKey[email];
          if (emp != null && emp.departmentId?.isNotEmpty == true) {
            department = departmentController
                .getEnglishDepartmentNameFromDepartmentId(
                departmentId: emp.departmentId!) ??
                '';
          }
        }

        if (state.selectStatus != "All" && department != state.selectStatus)
          continue;

        final nameEn = _extractValue(data['Service_Name_English']);
        final nameAr = _extractValue(data['Service_Name_Arabic']);
        final durationStr = _extractValue(data['Duration_Of_Services']);
        final unit = _extractValue(data['Selected_Duration_Unit']).toLowerCase();
        final earliestTs = _extractEarliestTimestamp(data);

        createServicesMap[serviceDoc.id] = {
          'nameEn': nameEn,
          'nameAr': nameAr,
          'durationStr': durationStr,
          'unit': unit,
          'earliestTimestamp': earliestTs,
          'department': department,
        };

        if (nameEn.isNotEmpty) {
          serviceNameToDocId[nameEn] = serviceDoc.id;
          allServicesData.add({
            'docId': serviceDoc.id,
            'nameEn': nameEn,
            'nameAr': nameAr,
            'durationStr': durationStr,
            'unit': unit,
            'earliestTimestamp': earliestTs,
          });
        }
      } catch (e) {
      }
    }

    final requestServicesSnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    Map<String, Map<String, dynamic>> requestStats = {};

    for (var doc in requestServicesSnapshot.docs) {
      try {
        final data = doc.data();
        String nameEn = _extractValue(data['Service_Name_English']);

        if (nameEn.isEmpty) {
          final parentId = _extractValue(data['Parent_Service_Id']);
          if (parentId.isNotEmpty && createServicesMap.containsKey(parentId)) {
            nameEn = createServicesMap[parentId]!['nameEn'] ?? '';
          }
        }

        if (nameEn.isEmpty) continue;

        requestStats.putIfAbsent(nameEn, () => {
          'doneCount': 0,
          'totalHours': 0.0,
          'earliestTimestamp': null,
        });

        final finalState = resolveFinalStateFromData(data);

        if (finalState == 'done' || finalState == 'branchsla') {
          requestStats[nameEn]!['doneCount']++;

          String durationStr = _extractValue(data['Duration_Of_Services']);
          String unit = _extractValue(data['Selected_Duration_Unit']).toLowerCase();

          if (durationStr.isEmpty || unit.isEmpty) {
            final parentId = _extractValue(data['Parent_Service_Id']);
            if (parentId.isNotEmpty && createServicesMap.containsKey(parentId)) {
              durationStr = createServicesMap[parentId]!['durationStr'] ?? '';
              unit = createServicesMap[parentId]!['unit'] ?? '';
            }
            if ((durationStr.isEmpty || unit.isEmpty) &&
                serviceNameToDocId.containsKey(nameEn)) {
              final csDocId = serviceNameToDocId[nameEn]!;
              durationStr = createServicesMap[csDocId]!['durationStr'] ?? '';
              unit = createServicesMap[csDocId]!['unit'] ?? '';
            }
          }

          if (durationStr.isNotEmpty && unit.isNotEmpty) {
            final double dur = double.tryParse(durationStr) ?? 0;
            final hours = _toHours(dur, unit);
            requestStats[nameEn]!['totalHours'] =
                (requestStats[nameEn]!['totalHours'] as double) + hours;
          }
        }

        final docTs = _extractEarliestTimestamp(data);
        if (docTs != null) {
          final current = requestStats[nameEn]!['earliestTimestamp'] as int?;
          if (current == null || docTs < current) {
            requestStats[nameEn]!['earliestTimestamp'] = docTs;
          }
        }
      } catch (e, st) {
      }
    }

    List<Map<String, dynamic>> result = [];

    for (var sd in allServicesData) {
      final nameEn = sd['nameEn'] as String;
      final nameAr = sd['nameAr'] as String;
      if (nameEn.isEmpty) continue;

      final stats = requestStats[nameEn];
      final int doneCount = stats?['doneCount'] ?? 0;
      final double totalHours = (stats?['totalHours'] ?? 0.0) as double;

      int? earliestTs = stats?['earliestTimestamp'] as int?;
      earliestTs ??= sd['earliestTimestamp'] as int?;

      String startDate = 'N/A';
      if (earliestTs != null) {
        try {
          startDate = DateFormat('dd MMM yyyy')
              .format(DateTime.fromMillisecondsSinceEpoch(earliestTs));
        } catch (_) {}
      }

      result.add({
        'title': nameEn,
        'titleEnglish': nameEn,
        'titleArabic': nameAr,
        'startDate': startDate,
        'done': doneCount.toString(),
        'total': totalHours.toStringAsFixed(1),
      });
    }

    emit(state.copyWith(allServices: result, isServiceListLoading: false));
  }

  Future<Map<String, int>> calculateServiceStatesFilter({
    String? filterDepartment,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final employeeController = AppControllers.employee;
    final departmentController = departmentCubit;

    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    int done = 0,
        inProgress = 0,
        approved = 0,
        rejected = 0,
        pending = 0,
        cancel = 0,
        branchSla = 0;

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();
        final email = _extractValue(data['Email_Requester']);
        String department = '';

        if (email.isNotEmpty) {
          final emp = employeeController.mapOfEmployeesWithEmailKey[email];
          if (emp != null && emp.departmentId?.isNotEmpty == true) {
            department = departmentController
                .getEnglishDepartmentNameFromDepartmentId(
                departmentId: emp.departmentId!) ??
                '';
          }
        }

        if (filterDepartment != null &&
            filterDepartment != "All" &&
            department != filterDepartment) continue;

        switch (resolveFinalStateFromData(data)) {
          case 'done':       done++;       break;
          case 'inprogress': inProgress++; break;
          case 'approved':   approved++;   break;
          case 'rejected':   rejected++;   break;
          case 'pending':    pending++;    break;
          case 'cancel':     cancel++;     break;
          case 'branchsla':  branchSla++;  break;
        }
      } catch (e) {
      }
    }

    return {
      'done': done,
      'inprogress': inProgress,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'cancel': cancel,
      'branchsla': branchSla,
    };
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Current user email, resolved from the module's employee controller.
  /// Keeps the module self-contained (no dependency on the settings screen).
  String get _currentUserEmail {
    try {
      final controller = AppControllers.employee;
      return controller.employeeEntity?.email ?? '';
    } catch (e) {
      return '';
    }
  }

}
