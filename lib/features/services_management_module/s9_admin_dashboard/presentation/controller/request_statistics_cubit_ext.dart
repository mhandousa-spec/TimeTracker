part of 'request_statistics_cubit.dart';

// Methods extracted from request_statistics_cubit.dart to keep it <700 LOC.
extension DashboardDetailsCubitPart on DashboardDetailsCubit {
  String _resolveFinalState(Map<String, dynamic> data) {
    const finalStates = [
      'done', 'inprogress', 'cancel', 'canceled', 'cancelled',
      'branchsla', 'breached sla', 'approved', 'pending', 'rejected',
    ];

    String _normalize(String s) {
      if (s == 'cancel' || s == 'cancelled') return 'canceled';
      return s;
    }

    // Step 1: outer state field
    String outerState = '';
    if (data['state'] is List) {
      final list = data['state'] as List;
      outerState = list.isNotEmpty ? (list.last?.toString().trim().toLowerCase() ?? '') : '';
    } else if (data['state'] != null) {
      outerState = data['state'].toString().trim().toLowerCase();
    }

    if (outerState.isNotEmpty && finalStates.contains(outerState)) {
      return _normalize(outerState);
    }

    // Step 2: Approval_Cycle JSON
    if (data['Approval_Cycle'] is List) {
      final approvalList = data['Approval_Cycle'] as List;
      if (approvalList.isNotEmpty && approvalList.last is String) {
        try {
          final decoded = jsonDecode(approvalList.last as String);
          List items = decoded is List ? decoded : (decoded is Map ? [decoded] : []);
          final states = items
              .map((e) => (e['state']?.toString().trim().toLowerCase() ?? ''))
              .where((s) => s.isNotEmpty)
              .toList();

          for (final priority in ['cancel', 'canceled', 'cancelled', 'rejected', 'done']) {
            if (states.contains(priority)) return _normalize(priority);
          }
          if (states.every((s) => s == 'approved')) return 'approved';
          if (states.contains('inprogress')) return 'inprogress';
          if (states.contains('pending')) return 'pending';
        } catch (_) {}
      }
    }

    // Step 3: Provider_Services JSON
    if (data['Provider_Services'] is List) {
      final list = data['Provider_Services'] as List;
      if (list.isNotEmpty && list.last is String) {
        try {
          final decoded = jsonDecode(list.last as String);
          List items = decoded is List ? decoded : (decoded is Map ? [decoded] : []);
          final states = items
              .map((e) => (e['state']?.toString().trim().toLowerCase() ?? ''))
              .where((s) => s.isNotEmpty)
              .toList();

          for (final priority in ['cancel', 'canceled', 'cancelled', 'rejected', 'done', 'inprogress', 'pending']) {
            if (states.contains(priority)) return _normalize(priority);
          }
        } catch (_) {}
      }
    }

    // Step 4: status field fallback
    if (data['status'] != null) {
      String statusField = '';
      if (data['status'] is List) {
        final list = data['status'] as List;
        statusField = list.isNotEmpty ? (list.last?.toString().trim().toLowerCase() ?? '') : '';
      } else {
        statusField = data['status'].toString().trim().toLowerCase();
      }
      if (statusField.isNotEmpty && finalStates.contains(statusField)) {
        return _normalize(statusField);
      }
    }

    return 'pending';
  }

  // ─── Private: Helpers ──────────────────────────────────────────────────────

  String _extractValue(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.isEmpty ? '' : (value[0]?.toString() ?? '');
    return value.toString();
  }

  String _normalizeDepartmentKey(String? raw) {
    final dept = (raw ?? '').trim();
    if (dept.isEmpty) return _otherKey;

    final lower = dept.toLowerCase();
    for (final k in state.knownDepartments) {
      if (k.toLowerCase() == lower) return k;
    }

    try {
      final departmentController = departmentCubit;
      final en = departmentController.getDepartmentEnglishNameFromArabicName(arabicName: dept);
      if (en != null && state.knownDepartments.contains(en)) return en;
    } catch (_) {}

    return _otherKey;
  }
}
