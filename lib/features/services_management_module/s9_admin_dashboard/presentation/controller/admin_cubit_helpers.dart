part of 'admin_cubit.dart';

// Methods extracted from admin_cubit.dart to keep it <700 LOC.
// Kept as an extension (not top-level functions) so they retain access to the
// cubit's instance members (e.g. _currentUserEmail).
extension DashboardAdminCubitPart on DashboardAdminCubit {
  String resolveFinalStateFromData(Map<String, dynamic> data) {
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
      'done', 'inprogress', 'cancel', 'canceled', 'branchsla',
      'breached sla', 'approved', 'pending', 'rejected'
    ];

    if (actualState.isNotEmpty && finalStates.contains(actualState)) {
      if (actualState == 'cancel' || actualState == 'canceled') return 'cancel';
      return actualState;
    }

    if (data['Approval_Cycle'] is List) {
      final approvalList = data['Approval_Cycle'] as List;
      if (approvalList.isNotEmpty) {
        final lastValue = approvalList.last;
        if (lastValue is String) {
          try {
            final decoded = jsonDecode(lastValue);
            if (decoded is List) {
              final states = decoded
                  .map((e) => (e['state']?.toString().trim().toLowerCase() ?? ''))
                  .where((s) => s.isNotEmpty)
                  .toList();
              if (states.contains('cancel') || states.contains('canceled'))
                return 'cancel';
              if (states.contains('rejected')) return 'rejected';
              if (states.contains('done')) return 'done';
              if (states.every((s) => s == 'approved')) return 'approved';
              if (states.contains('inprogress')) return 'inprogress';
              if (states.contains('pending')) return 'pending';
            }
          } catch (_) {}
        }
      }
    }

    if (data['approvalCycle'] is Map<String, dynamic>) {
      final approvalMap = data['approvalCycle'] as Map<String, dynamic>;
      final valueList = approvalMap['value'];
      if (valueList is List) {
        final states = valueList
            .map((e) => (e['state']?.toString().trim().toLowerCase() ?? ''))
            .where((s) => s.isNotEmpty)
            .toList();
        if (states.contains('cancel') || states.contains('canceled'))
          return 'cancel';
        if (states.contains('rejected')) return 'rejected';
        if (states.isNotEmpty && states.every((s) => s == 'approved'))
          return 'approved';
        if (states.contains('pending')) return 'pending';
      }
    }

    return 'pending';
  }

  String _extractValue(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.isEmpty ? '' : (value[0]?.toString() ?? '');
    return value.toString();
  }

  String? _getSafeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) {
      return value.isNotEmpty && value.first is String
          ? value.first as String
          : null;
    }
    return value.toString();
  }

  int? _extractLatestTimestamp(Map<String, dynamic> data) {
    int? latest;

    void consider(dynamic raw) {
      int? val;
      if (raw is int) val = raw;
      else if (raw is double) val = raw.toInt();
      else if (raw is Timestamp) val = raw.millisecondsSinceEpoch;
      if (val != null && (latest == null || val > latest!)) latest = val;
    }

    final ts = data['timestamps'];
    if (ts is List) {
      for (var t in ts) consider(t);
    } else {
      consider(ts);
    }

    final dts = data['Duration_Of_Services_Timestamp'];
    if (dts is List) {
      for (var t in dts) consider(t);
    } else {
      consider(dts);
    }

    consider(data['createdDate']);
    return latest;
  }

  int? _extractEarliestTimestamp(Map<String, dynamic> data) {
    int? earliest;

    void consider(dynamic raw) {
      int? val;
      if (raw is int) val = raw;
      else if (raw is double) val = raw.toInt();
      else if (raw is Timestamp) val = raw.millisecondsSinceEpoch;
      if (val != null && (earliest == null || val < earliest!)) earliest = val;
    }

    final ts = data['timestamps'];
    if (ts is List) {
      for (var t in ts) consider(t);
    } else {
      consider(ts);
    }

    final dts = data['Duration_Of_Services_Timestamp'];
    if (dts is List) {
      for (var t in dts) consider(t);
    } else {
      consider(dts);
    }

    consider(data['createdDate']);
    return earliest;
  }

  String _resolveRequestDate(Map<String, dynamic> data) {
    final format = DateFormat('yyyy-MM-dd – kk:mm');

    final ts = data['timestamps'];
    if (ts is List && ts.isNotEmpty && ts.last is int) {
      return format.format(DateTime.fromMillisecondsSinceEpoch(ts.last as int));
    }

    final dts = data['Duration_Of_Services_Timestamp'];
    if (dts is List && dts.isNotEmpty && dts.last is int) {
      return format.format(DateTime.fromMillisecondsSinceEpoch(dts.last as int));
    }

    final cd = data['createdDate'];
    if (cd is Timestamp) return format.format(cd.toDate());

    return 'N/A';
  }

  Map<String, dynamic> _resolveProvider(
      Map<String, dynamic> data,
      String emailRequester,
      MainCoreEmployeeController employeeController,
      ) {
    Map<String, dynamic> selectedProvider = {};
    String firstName = '', lastName = '', firstNameAr = '', lastNameAr = '';

    // Method 1: selectedServiceProvider
    if (data['selectedServiceProvider'] is Map) {
      selectedProvider =
      Map<String, dynamic>.from(data['selectedServiceProvider'] as Map);
      firstName = selectedProvider['firstName']?.toString() ?? '';
      lastName = selectedProvider['lastName']?.toString() ?? '';
      firstNameAr = selectedProvider['firstNameInArabic']?.toString() ?? '';
      lastNameAr = selectedProvider['lastNameInArabic']?.toString() ?? '';
    }

    // Method 2: Provider_Services
    if (selectedProvider.isEmpty && data['Provider_Services'] != null) {
      try {
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
        }
      } catch (_) {}
    }

    // Method 3: Assigned_Provider_Email
    if (selectedProvider.isEmpty && data['Assigned_Provider_Email'] != null) {
      String? providerEmail;
      final raw = data['Assigned_Provider_Email'];

      if (raw is List && raw.isNotEmpty) {
        providerEmail = raw[0]?.toString();
        if (providerEmail == null ||
            providerEmail.isEmpty ||
            providerEmail == emailRequester) {
          providerEmail =
          raw.length > 1 ? raw[1]?.toString() : null;
        }
      } else if (raw is String && raw.isNotEmpty && raw != emailRequester) {
        providerEmail = raw;
      }

      if (providerEmail != null && providerEmail.isNotEmpty) {
        final emp = employeeController.mapOfEmployeesWithEmailKey[providerEmail];
        if (emp != null) {
          selectedProvider = {
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
          firstName = emp.firstName ?? '';
          lastName = emp.lastName ?? '';
          firstNameAr = emp.firstNameInArabic ?? '';
          lastNameAr = emp.lastNameInArabic ?? '';
        }
      }
    }

    // Method 4: state array
    if (selectedProvider.isEmpty && data['state'] is List) {
      for (var s in (data['state'] as List)) {
        if (s is Map) {
          String? email = (s['providerEmail'] ?? s['assignedTo'] ?? s['provider'])?.toString();
          if (email != null && email.isNotEmpty && email != emailRequester) {
            final emp = employeeController.mapOfEmployeesWithEmailKey[email];
            if (emp != null) {
              selectedProvider = {
                'firstName': emp.firstName ?? '',
                'lastName': emp.lastName ?? '',
                'firstNameInArabic': emp.firstNameInArabic ?? '',
                'lastNameInArabic': emp.lastNameInArabic ?? '',
                'email': emp.email ?? '',
              };
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
        for (var approval in valueList) {
          if (approval is Map) {
            String? email =
            (approval['email'] ?? approval['approverEmail'])?.toString();
            if (email != null && email.isNotEmpty && email != emailRequester) {
              final emp = employeeController.mapOfEmployeesWithEmailKey[email];
              if (emp != null) {
                selectedProvider = {
                  'firstName': emp.firstName ?? '',
                  'lastName': emp.lastName ?? '',
                  'firstNameInArabic': emp.firstNameInArabic ?? '',
                  'lastNameInArabic': emp.lastNameInArabic ?? '',
                  'email': emp.email ?? '',
                };
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
    };
  }

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
    try {
      return jsonDecode(json.substring(0, endIndex + 1)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  double _toHours(double value, String unit) {
    return switch (unit) {
      'minutes' => value / 60,
      'hours'   => value,
      'days'    => value * 24,
      'weeks'   => value * 168,
      _         => 0,
    };
  }

  /// Counts services per department, keyed by canonical English department
  /// name. Only departments that actually own at least one service appear.
  ///
  /// ✅ FIX (bug report p5): this used to seed a hardcoded list — Operations,
  /// Finance, Sales, Marketing, Software — plus a catch-all 'Other', all
  /// starting at 0. The result was that the dashboard always rendered those
  /// six chips regardless of the tenant's real departments or whether any of
  /// them had services, and anything outside the hardcoded five was swallowed
  /// into 'Other'.
  /// ✅ FIX: the chips and the status cards must count the same thing.
  ///
  /// The "All" chip read 12 while Done+Pending+Rejected+Canceled summed to 15,
  /// because this method and loadServiceStatusData disagreed on all three of:
  ///
  ///   1. Population — this filtered `.where("Email_Requester", arrayContains:
  ///      _currentUserEmail)`, i.e. only requests raised by the logged-in user,
  ///      while the status cards scan every request doc in the tenant. On an
  ///      admin dashboard the tenant-wide scope is the correct one.
  ///   2. Department source — this used the *service's* selected departments;
  ///      the cards use the *requester's* department.
  ///   3. Cardinality — currentSelectDepartment is a list, so one request
  ///      serving two departments incremented two chips. A request is one
  ///      request; it must contribute exactly 1.
  ///
  /// This now mirrors loadServiceStatusData exactly, so the chips always sum to
  /// the same total as the status cards.
  Future<Map<String, int>> _countDepartments() async {
    final firestore = FirebaseFirestore.instance;
    final departmentController = departmentCubit;
    final employeeController = AppControllers.employee;

    final Map<String, int> departmentCount = {};

    final querySnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    for (var doc in querySnapshot.docs) {
      try {
        final data = doc.data();
        final email = _extractValue(data['Email_Requester']);
        if (email.isEmpty) continue;

        final emp = employeeController.mapOfEmployeesWithEmailKey[email];
        if (emp == null ||
            emp.departmentId == null ||
            emp.departmentId!.isEmpty) {
          continue;
        }

        final canonical =
            departmentController.getEnglishDepartmentNameFromDepartmentId(
          departmentId: emp.departmentId!,
        );
        if (canonical == null || canonical.isEmpty) continue;

        // Exactly one increment per request document.
        departmentCount[canonical] = (departmentCount[canonical] ?? 0) + 1;
      } catch (e) {
      }
    }

    return departmentCount;
  }

  Map<String, int> _buildDeptBreakdown(
      Map<String, int> counts,
      MainCoreDepartmentCubit deptController,
      ) {
    final result = <String, int>{};
    for (var name in deptController.departmentsEnglishName) {
      result[name] = counts[name] ?? 0;
    }
    return result;
  }
}
