part of 'dashboard_master_cubit.dart';

// Methods extracted from dashboard_master_cubit.dart to keep it <700 LOC.
extension DashboardMasterCubitPart on DashboardMasterCubit {
  String getFinalStateFromModel(ServicesHistoryModel service) {
    final stateArray = service.state;

    if (stateArray.isNotEmpty) {
      final lastState = stateArray.last.toLowerCase().trim();
      if (['rejected', 'cancel', 'done', 'approved', 'inprogress', 'branchsla', 'breached sla']
          .contains(lastState)) {
        return lastState;
      }
    }

    final approvalCycle = service.currentApprovalCycle;
    if (approvalCycle.isNotEmpty) {
      final states = approvalCycle
          .map((e) => e.state?.toLowerCase().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      if (states.contains('rejected')) return 'rejected';
      if (states.contains('cancel')) return 'cancel';
      if (states.contains('pending')) return 'pending';
      if (states.every((s) => s == 'approved')) {
        if (stateArray.isEmpty) return 'approved';
        return stateArray.last.toLowerCase().trim();
      }
    }

    if (stateArray.isEmpty) return 'pending';
    return stateArray.last.toLowerCase().trim();
  }

  // ─── Private: Filter ──────────────────────────────────────────────────────

  List<Map<String, dynamic>> _computeDisplayedItems(DashboardMasterState s) {
    final query = s.searchQuery.toLowerCase().trim();

    return s.filteredItems.where((item) {
      final matchesQuery = query.isEmpty ||
          [
            item['department'], item['serviceName'], item['serviceNameArabic'],
            item['requestor'], item['requestorArabic'], item['status'], item['provider'],
          ].join(' ').toLowerCase().contains(query);

      final matchesDept = s.activeDepartment == null ||
          s.activeDepartment!.isEmpty ||
          item['department'] == s.activeDepartment;

      final matchesStatus = s.activeStatus == null ||
          s.activeStatus!.isEmpty ||
          item['status']?.toString().toLowerCase() == s.activeStatus!.toLowerCase();

      final ts = item['requestDate'] as Timestamp?;
      final modelDate = ts?.toDate();
      final matchesDate = s.activeDate == null ||
          (modelDate != null &&
              modelDate.year == s.activeDate!.year &&
              modelDate.month == s.activeDate!.month &&
              modelDate.day == s.activeDate!.day);

      return matchesQuery && matchesDept && matchesStatus && matchesDate;
    }).toList();
  }

  // ─── Private: Provider resolution ─────────────────────────────────────────

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
      if (map.isNotEmpty) {
        selectedProvider = map;
        firstName = map['firstName']?.toString() ?? '';
        lastName = map['lastName']?.toString() ?? '';
        firstNameAr = map['firstNameInArabic']?.toString() ?? '';
        lastNameAr = map['lastNameInArabic']?.toString() ?? '';
      }
    }

    // Method 2: Provider_Services JSON
    if (selectedProvider.isEmpty && data['Provider_Services'] != null) {
      try {
        final raw = data['Provider_Services'];
        String? jsonStr;
        if (raw is List && raw.isNotEmpty) jsonStr = raw.first.toString();
        else if (raw is String) jsonStr = raw;

        if (jsonStr != null && jsonStr.startsWith('[{')) {
          jsonStr = jsonStr.substring(1, jsonStr.length - 1);
          final provMap = jsonDecode(jsonStr) as Map<String, dynamic>;
          if (provMap.isNotEmpty) {
            selectedProvider = provMap;
            firstName = provMap['firstName']?.toString() ?? '';
            lastName = provMap['lastName']?.toString() ?? '';
            firstNameAr = provMap['firstNameInArabic']?.toString() ?? '';
            lastNameAr = provMap['lastNameInArabic']?.toString() ?? '';
          }
        }
      } catch (_) {}
    }

    // Method 3: Assigned_Provider_Email
    if (selectedProvider.isEmpty && data['Assigned_Provider_Email'] != null) {
      String? providerEmail;
      final raw = data['Assigned_Provider_Email'];
      if (raw is List && raw.isNotEmpty) {
        providerEmail = raw[0]?.toString();
        if (providerEmail == null || providerEmail.isEmpty || providerEmail == emailRequester) {
          providerEmail = raw.length > 1 ? raw[1]?.toString() : null;
        }
      } else if (raw is String && raw.isNotEmpty && raw != emailRequester) {
        providerEmail = raw;
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

    // Method 4: state array
    if (selectedProvider.isEmpty && data['state'] is List) {
      for (final s in (data['state'] as List)) {
        if (s is Map) {
          final email = (s['providerEmail'] ?? s['assignedTo'] ?? s['provider'])?.toString();
          if (email != null && email.isNotEmpty && email != emailRequester) {
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

    // Method 5: approvalCycle
    if (selectedProvider.isEmpty && data['approvalCycle'] is Map) {
      final valueList = (data['approvalCycle'] as Map)['value'];
      if (valueList is List) {
        for (final approval in valueList) {
          if (approval is Map) {
            final email = (approval['email'] ?? approval['approverEmail'])?.toString();
            if (email != null && email.isNotEmpty && email != emailRequester) {
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
    }

    if (!selectedProvider.containsKey('gender')) selectedProvider['gender'] = '';

    return {
      'map': selectedProvider,
      'name': (firstName.isNotEmpty || lastName.isNotEmpty)
          ? '$firstName $lastName'.trim()
          : 'N/A',
      'firstName': firstName,
      'lastName': lastName,
      'firstNameArabic': firstNameAr,
      'lastNameArabic': lastNameAr,
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

  // ─── Private: Helpers ──────────────────────────────────────────────────────

  String _extractValue(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.isEmpty ? '' : (value[0]?.toString() ?? '');
    return value.toString();
  }

  String? _getSafeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is List) {
      if (value.isEmpty) return null;
      final s = value.first?.toString() ?? '';
      return s.isEmpty ? null : s;
    }
    return value.toString();
  }

  /// Compares two department names tolerantly.
  ///
  /// ✅ FIX (bug report p33): every chart fetch filtered with a bare
  /// `dept != filterDepartment`, so a stored "compliance & legal" never matched
  /// the controller's "Compliance & Legal" and the loop skipped every document
  /// — the Service Status chart came back empty even though the status cards on
  /// the same dashboard showed a rejected request. Same defect as the services
  /// dashboard department filter.
  bool _sameDepartment(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  String _normalizeDepartmentValue(dynamic departmentValue) {
    if (departmentValue == null) return '';
    final dc = departmentCubit;
    String value = '';

    if (departmentValue is List && departmentValue.isNotEmpty) {
      value = departmentValue.last?.toString().trim() ?? '';
    } else {
      value = departmentValue.toString().trim();
    }

    if (value.isEmpty) return '';

    if (int.tryParse(value) != null) {
      return dc.getEnglishDepartmentNameFromDepartmentId(departmentId: value) ?? value;
    }

    return value;
  }

  String? _getDepartmentFromEmail(String email) {
    final ec = AppControllers.employee;
    final dc = departmentCubit;
    final emp = ec.mapOfEmployeesWithEmailKey[email];
    if (emp?.departmentId == null) return null;
    return dc.getEnglishDepartmentNameFromDepartmentId(departmentId: emp!.departmentId!);
  }

  double _toHours(double value, String unit) => switch (unit) {
    'minutes' => value / 60,
    'hours'   => value,
    'days'    => value * 24,
    'weeks'   => value * 168,
    _         => 0,
  };
}
