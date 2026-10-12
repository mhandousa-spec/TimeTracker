// ******************* FILE INFO *******************
// File Name: request_statistics.dart
// Description: Loads and displays filtered service requests table
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Fix: Full 5-method provider resolution (matching admin_cubit.dart)
//      + gender field always populated so avatar never shows null
/// Created by: Amr Mesbah
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'dart:convert';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/safe_json.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestedServicesAndStatistics extends StatefulWidget {
  const RequestedServicesAndStatistics({
    super.key,
    this.selectedDepartment,
    this.searchQuery = '',
    this.activeDepartments = const [],
    this.activeStatuses = const [],
    this.activeDate,
  });

  final String? selectedDepartment;
  final String searchQuery;
  final List<String> activeDepartments;
  final List<String> activeStatuses;
  final DateTime? activeDate;

  @override
  State<RequestedServicesAndStatistics> createState() =>
      _RequestedServicesAndStatisticsState();
}

class _RequestedServicesAndStatisticsState
    extends State<RequestedServicesAndStatistics> {
  bool isLoadingTable = true;
  List<Map<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    loadFilteredItems();
  }

  @override
  void didUpdateWidget(covariant RequestedServicesAndStatistics oldWidget) {
    super.didUpdateWidget(oldWidget);

    final departmentsChanged =
        widget.activeDepartments.length != oldWidget.activeDepartments.length ||
            !widget.activeDepartments
                .every((d) => oldWidget.activeDepartments.contains(d));

    final statusesChanged =
        widget.activeStatuses.length != oldWidget.activeStatuses.length ||
            !widget.activeStatuses
                .every((s) => oldWidget.activeStatuses.contains(s));

    if (widget.selectedDepartment != oldWidget.selectedDepartment ||
        widget.searchQuery != oldWidget.searchQuery ||
        departmentsChanged ||
        statusesChanged ||
        widget.activeDate != oldWidget.activeDate) {
      setState(() {
        isLoadingTable = true;
        filteredItems = [];
      });
      loadFilteredItems();
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _extractValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      if (value.isEmpty) return '';
      return value.last?.toString() ?? '';
    }
    return value.toString();
  }

  // ─── State Resolution (mirrors admin_cubit.dart exactly) ──────────────────

  String resolveFinalState(Map<String, dynamic> data) {
    String actualState = '';

    if (data['state'] is List) {
      final list = data['state'] as List;
      actualState =
      list.isNotEmpty ? (list.last?.toString().trim().toLowerCase() ?? '') : '';
    } else if (data['state'] is String) {
      actualState = (data['state'] as String).trim().toLowerCase();
    } else if (data['state'] != null) {
      actualState = data['state'].toString().trim().toLowerCase();
    }

    const finalStates = [
      'done', 'inprogress', 'cancel', 'canceled', 'cancelled',
      'branchsla', 'breached sla', 'approved', 'pending', 'rejected'
    ];

    if (actualState.isNotEmpty && finalStates.contains(actualState)) {
      if (actualState == 'cancel' ||
          actualState == 'canceled' ||
          actualState == 'cancelled') {
        return 'canceled';
      }
      return actualState;
    }

    // Check Approval_Cycle
    if (data['Approval_Cycle'] is List) {
      final approvalList = data['Approval_Cycle'] as List;
      if (approvalList.isNotEmpty) {
        final lastValue = approvalList.last;
        if (lastValue is String) {
          // W04: safeJsonDecode returns null instead of throwing (no try/catch).
          final decoded = safeJsonDecode(lastValue);
          if (decoded is List) {
            final states = decoded
                .map((e) =>
            (e['state']?.toString().trim().toLowerCase() ?? ''))
                .where((s) => s.isNotEmpty)
                .toList();

            if (states.contains('cancel') ||
                states.contains('canceled') ||
                states.contains('cancelled')) return 'canceled';
            if (states.contains('rejected')) return 'rejected';
            if (states.contains('done')) return 'done';
            if (states.every((s) => s == 'approved')) return 'approved';
            if (states.contains('inprogress')) return 'inprogress';
            if (states.contains('pending')) return 'pending';
          }
        }
      }
    }

    // Check Provider_Services
    if (data['Provider_Services'] is List) {
      final providerServices = data['Provider_Services'] as List;
      if (providerServices.isNotEmpty) {
        final lastProvider = providerServices.last;
        if (lastProvider is String) {
          // W04: safeJsonDecode returns null instead of throwing (no try/catch).
          final decoded = safeJsonDecode(lastProvider);
          if (decoded is List && decoded.isNotEmpty) {
            final states = decoded
                .map((e) =>
            (e['state']?.toString().trim().toLowerCase() ?? ''))
                .where((s) => s.isNotEmpty)
                .toList();

            if (states.contains('cancel') ||
                states.contains('canceled') ||
                states.contains('cancelled')) return 'canceled';
            if (states.contains('rejected')) return 'rejected';
            if (states.contains('done')) return 'done';
            if (states.contains('inprogress')) return 'inprogress';
          }
        }
      }
    }

    return 'pending';
  }

  // ─── ✅ FIXED: Full 5-method provider resolution ──────────────────────────

  /// Resolves provider data using all 5 methods, identical to admin_cubit.dart.
  /// Returns a map with keys: map, name, firstName, lastName,
  ///   firstNameArabic, lastNameArabic, gender
  /// Gender is always populated so the avatar never falls back to null.
  Map<String, dynamic> _resolveProvider(
      Map<String, dynamic> data,
      String emailRequester,
      MainCoreEmployeeController employeeController,
      ) {
    Map<String, dynamic> selectedProvider = {};
    String firstName = '', lastName = '', firstNameAr = '', lastNameAr = '';
    String gender = '';

    // ── Method 1: selectedServiceProvider ────────────────────────────────────
    if (data['selectedServiceProvider'] is Map) {
      selectedProvider =
      Map<String, dynamic>.from(data['selectedServiceProvider'] as Map);
      firstName = selectedProvider['firstName']?.toString() ?? '';
      lastName = selectedProvider['lastName']?.toString() ?? '';
      firstNameAr = selectedProvider['firstNameInArabic']?.toString() ?? '';
      lastNameAr = selectedProvider['lastNameInArabic']?.toString() ?? '';
      gender = selectedProvider['gender']?.toString() ?? '';
    }

    // ── Method 2: Provider_Services ──────────────────────────────────────────
    if (selectedProvider.isEmpty && data['Provider_Services'] != null) {
      // W04: guarded parsing (no try/catch); _parseFirstJsonObject is null-safe.
      final raw = data['Provider_Services'];
      Map<String, dynamic>? providerMap;

      if (raw is Map) {
        providerMap = Map<String, dynamic>.from(raw);
      } else if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is Map) {
          providerMap = Map<String, dynamic>.from(first);
        } else if (first is String) {
          providerMap = _parseFirstJsonObject(first);
        }
      } else if (raw is String) {
        providerMap = _parseFirstJsonObject(raw);
      }

      if (providerMap != null && providerMap.isNotEmpty) {
        selectedProvider = providerMap;
        firstName = providerMap['firstName']?.toString() ?? '';
        lastName = providerMap['lastName']?.toString() ?? '';
        firstNameAr = providerMap['firstNameInArabic']?.toString() ?? '';
        lastNameAr = providerMap['lastNameInArabic']?.toString() ?? '';
        gender = providerMap['gender']?.toString() ?? '';
      }
    }

    // ── Method 3: Assigned_Provider_Email ────────────────────────────────────
    if (selectedProvider.isEmpty && data['Assigned_Provider_Email'] != null) {
      String? providerEmail;
      final raw = data['Assigned_Provider_Email'];

      if (raw is List && raw.isNotEmpty) {
        providerEmail = raw[0]?.toString();
        if (providerEmail == null ||
            providerEmail.isEmpty ||
            providerEmail == emailRequester) {
          providerEmail = raw.length > 1 ? raw[1]?.toString() : null;
        }
      } else if (raw is String &&
          raw.isNotEmpty &&
          raw != emailRequester) {
        providerEmail = raw;
      }

      if (providerEmail != null && providerEmail.isNotEmpty) {
        final emp =
        employeeController.mapOfEmployeesWithEmailKey[providerEmail];
        if (emp != null) {
          // ✅ FIX: always populate gender from employee model
          selectedProvider = {
            'firstName': emp.firstName ?? '',
            'lastName': emp.lastName ?? '',
            'firstNameInArabic': emp.firstNameInArabic ?? '',
            'lastNameInArabic': emp.lastNameInArabic ?? '',
            'email': emp.email ?? '',
            'gender': emp.gender ?? '',        // ← was missing before
            'title': emp.title ?? '',
            'titleInArabic': emp.titleInArabic ?? '',
            'departmentId': emp.departmentId ?? '',
          };
          firstName = emp.firstName ?? '';
          lastName = emp.lastName ?? '';
          firstNameAr = emp.firstNameInArabic ?? '';
          lastNameAr = emp.lastNameInArabic ?? '';
          gender = emp.gender ?? '';           // ← was missing before
        }
      }
    }

    // ── Method 4: state array ────────────────────────────────────────────────
    if (selectedProvider.isEmpty && data['state'] is List) {
      for (var s in (data['state'] as List)) {
        if (s is Map) {
          final email =
          (s['providerEmail'] ?? s['assignedTo'] ?? s['provider'])
              ?.toString();
          if (email != null &&
              email.isNotEmpty &&
              email != emailRequester) {
            final emp =
            employeeController.mapOfEmployeesWithEmailKey[email];
            if (emp != null) {
              selectedProvider = {
                'firstName': emp.firstName ?? '',
                'lastName': emp.lastName ?? '',
                'firstNameInArabic': emp.firstNameInArabic ?? '',
                'lastNameInArabic': emp.lastNameInArabic ?? '',
                'email': emp.email ?? '',
                'gender': emp.gender ?? '',
              };
              firstName = emp.firstName ?? '';
              lastName = emp.lastName ?? '';
              firstNameAr = emp.firstNameInArabic ?? '';
              lastNameAr = emp.lastNameInArabic ?? '';
              gender = emp.gender ?? '';
              break;
            }
          }
        }
      }
    }

    // ── Method 5: approvalCycle ──────────────────────────────────────────────
    if (selectedProvider.isEmpty && data['approvalCycle'] is Map) {
      final valueList = (data['approvalCycle'] as Map)['value'];
      if (valueList is List) {
        for (var approval in valueList) {
          if (approval is Map) {
            final email =
            (approval['email'] ?? approval['approverEmail'])?.toString();
            if (email != null &&
                email.isNotEmpty &&
                email != emailRequester) {
              final emp =
              employeeController.mapOfEmployeesWithEmailKey[email];
              if (emp != null) {
                selectedProvider = {
                  'firstName': emp.firstName ?? '',
                  'lastName': emp.lastName ?? '',
                  'firstNameInArabic': emp.firstNameInArabic ?? '',
                  'lastNameInArabic': emp.lastNameInArabic ?? '',
                  'email': emp.email ?? '',
                  'gender': emp.gender ?? '',
                };
                firstName = emp.firstName ?? '';
                lastName = emp.lastName ?? '';
                firstNameAr = emp.firstNameInArabic ?? '';
                lastNameAr = emp.lastNameInArabic ?? '';
                gender = emp.gender ?? '';
                break;
              }
            }
          }
        }
      }
    }

    // ── If still empty, ensure gender key exists so avatar doesn't crash ─────
    if (!selectedProvider.containsKey('gender')) {
      selectedProvider['gender'] = '';
    }

    final name = (firstName.isNotEmpty || lastName.isNotEmpty)
        ? '$firstName $lastName'.trim()
        : 'N/A';

    return {
      'map': selectedProvider,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'firstNameArabic': firstNameAr,
      'lastNameArabic': lastNameAr,
      'gender': gender,
    };
  }

  /// Parses the first complete JSON object from a raw string (e.g. "[{...},{...}]")
  Map<String, dynamic>? _parseFirstJsonObject(String raw) {
    String json = raw.trim();
    if (json.startsWith('[')) json = json.substring(1, json.length - 1);

    int braceCount = 0, endIndex = -1;
    bool inString = false;

    for (int i = 0; i < json.length; i++) {
      final c = json[i];
      if (c == '"' && (i == 0 || json[i - 1] != '\\')) inString = !inString;
      if (!inString) {
        if (c == '{') braceCount++;
        if (c == '}') {
          braceCount--;
          if (braceCount == 0) {
            endIndex = i;
            break;
          }
        }
      }
    }

    if (endIndex <= 0) return null;
    // W04: safeJsonDecode returns null instead of throwing (no try/catch).
    final decoded = safeJsonDecode(json.substring(0, endIndex + 1));
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  // ─── Main data loader ─────────────────────────────────────────────────────

  Future<void> loadFilteredItems() async {
    setState(() {
      isLoadingTable = true;
      filteredItems = [];
    });

    // W03/002: request docs come from the repository, not Firestore directly.
    final employeeController = AppControllers.employee;
    final departmentController = context.read<MainCoreDepartmentCubit>();

    final requestDocs =
        await ServicesManagerCubit.get(context).repository.getAllRequestServiceDocs();

    final List<Map<String, dynamic>> results = [];

    for (int i = 0; i < requestDocs.length; i++) {
      final data = requestDocs[i].value;
      final docId = requestDocs[i].key;

      try {
        // STEP 1: Email_Requester
        final emailRequester = _extractValue(data['Email_Requester']);
        if (emailRequester.isEmpty) continue;

        // STEP 2: Employee data from controller
        final employee =
        employeeController.mapOfEmployeesWithEmailKey[emailRequester];
        if (employee == null) continue;

        String normalizedDepartment = '';
        if (employee.departmentId != null &&
            employee.departmentId!.isNotEmpty) {
          normalizedDepartment = departmentController
              .getEnglishDepartmentNameFromDepartmentId(
              departmentId: employee.departmentId!) ??
              '';
        }

        // STEP 3: Department filter
        if (widget.selectedDepartment != null &&
            widget.selectedDepartment != 'All' &&
            normalizedDepartment != widget.selectedDepartment) {
          continue;
        }

        // STEP 4: Service names
        String serviceNameEnglish = _extractValue(data['Service_Name_English']);
        String serviceNameArabic = _extractValue(data['Service_Name_Arabic']);
        final parentServiceId = _extractValue(data['Parent_Service_Id']);

        if ((serviceNameEnglish.isEmpty || serviceNameArabic.isEmpty) &&
            parentServiceId.isNotEmpty) {
          final serviceDetails =
          await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: context.read<MainCoreDepartmentCubit>(),
            parentServiceId: parentServiceId,
            emailRequester: emailRequester,
          );
          if (serviceNameEnglish.isEmpty) {
            serviceNameEnglish = serviceDetails['serviceNameEnglish'] ?? '';
          }
          if (serviceNameArabic.isEmpty) {
            serviceNameArabic = serviceDetails['serviceNameArabic'] ?? '';
          }
        }

        // STEP 5: ✅ FIXED — full 5-method provider resolution
        final providerData =
        _resolveProvider(data, emailRequester, employeeController);

        // STEP 6: State
        final status = resolveFinalState(data);

        // STEP 7: Timestamp
        Timestamp? requestTimestamp;

        final tsArray = data['timestamps'];
        if (tsArray is List && tsArray.isNotEmpty) {
          final ts = tsArray.last;
          if (ts is int) {
            requestTimestamp = Timestamp.fromMillisecondsSinceEpoch(ts);
          } else if (ts is Timestamp) {
            requestTimestamp = ts;
          }
        }

        if (requestTimestamp == null) {
          final dtsArray = data['Duration_Of_Services_Timestamp'];
          if (dtsArray is List && dtsArray.isNotEmpty) {
            final ts = dtsArray.last;
            if (ts is int) {
              requestTimestamp = Timestamp.fromMillisecondsSinceEpoch(ts);
            } else if (ts is Timestamp) {
              requestTimestamp = ts;
            }
          }
        }

        if (requestTimestamp == null) {
          final cd = data['createdDate'];
          if (cd is Timestamp) requestTimestamp = cd;
        }

        // STEP 8: Search filter
        if (widget.searchQuery.isNotEmpty) {
          final q = widget.searchQuery.toLowerCase();
          final matches = serviceNameEnglish.toLowerCase().contains(q) ||
              serviceNameArabic.toLowerCase().contains(q) ||
              (employee.firstName ?? '').toLowerCase().contains(q) ||
              (employee.lastName ?? '').toLowerCase().contains(q) ||
              normalizedDepartment.toLowerCase().contains(q) ||
              status.toLowerCase().contains(q);
          if (!matches) continue;
        }

        // STEP 9: Multi-select filters
        if (widget.activeDepartments.isNotEmpty &&
            !widget.activeDepartments.contains(normalizedDepartment)) {
          continue;
        }

        if (widget.activeStatuses.isNotEmpty &&
            !widget.activeStatuses.contains(status)) {
          continue;
        }

        if (widget.activeDate != null && requestTimestamp != null) {
          final docDate = requestTimestamp.toDate();
          if (docDate.year != widget.activeDate!.year ||
              docDate.month != widget.activeDate!.month ||
              docDate.day != widget.activeDate!.day) {
            continue;
          }
        }

        // STEP 10: Build result item
        // ✅ FIX: populate individual provider fields AND the selectedProvider
        //    map with gender so ServiceRequestTableWidget can read it correctly
        final providerMap = providerData['map'] as Map<String, dynamic>;

        results.add({
          'no': results.length + 1,
          'department': normalizedDepartment,
          'serviceName': serviceNameEnglish,
          'serviceNameArabic': serviceNameArabic,
          'gender': employee.gender ?? '',
          'requestor':
          '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
          'firstNameRequester': employee.firstName ?? '',
          'lastNameRequester': employee.lastName ?? '',
          'firstNameRequesterArabic': employee.firstNameInArabic ?? '',
          'lastNameRequesterArabic': employee.lastNameInArabic ?? '',
          // ✅ top-level provider fields (used by _getProviderName)
          'provider': providerData['name'],
          'firstNameProvider': providerData['firstName'],
          'lastNameProvider': providerData['lastName'],
          'firstNameProviderArabic': providerData['firstNameArabic'],
          'lastNameProviderArabic': providerData['lastNameArabic'],
          // ✅ selectedProvider map (used by _getProviderGender for avatar)
          'selectedProvider': providerMap,
          'jobTitleRequester': employee.title ?? '',
          'jobTitleRequesterArabic': employee.titleInArabic ?? '',
          'requestDate': requestTimestamp,
          'status': status,
          'docId': docId,
          'raw': data,
        });
      } catch (e, stackTrace) {
      }
    }

    if (mounted) {
      setState(() {
        filteredItems = results;
        isLoadingTable = false;
      });
    }
  }

  // ─── Department name map ───────────────────────────────────────────────────

  static const Map<String, String> enToArDepartments = {
    'Executive': 'الإدارة التنفيذية',
    'Customer Support': 'دعم العملاء',
    'Finance': 'المالية',
    'Operations': 'العمليات',
    'Information Technology': 'تقنية المعلومات',
    'Human Resources': 'الموارد البشرية',
    'Marketing': 'التسويق',
    'Sales': 'المبيعات',
    'Data Management': 'إدارة البيانات',
    'Compliance & Legal': 'الامتثال والشؤون القانونية',
    'Software': 'البرمجيات',
  };

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoadingTable) {
      return Center(child: CircleProgressMaster());
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Lottie.asset(
          'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
          width: 350.sp,
          height: 350.sp,
          fit: BoxFit.fill,
          repeat: true,
          animate: true,
        ),
      );
    }

    return ServiceRequestTableWidget(
      filteredItems: filteredItems,
      locale: Localizations.localeOf(context).languageCode,
      enToArDepartments: enToArDepartments,
      selectStatus: widget.selectedDepartment,
      onRowTap: (item) {},
    );
  }
}
