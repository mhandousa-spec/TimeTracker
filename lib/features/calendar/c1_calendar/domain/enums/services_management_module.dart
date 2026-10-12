/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: services_management_module.dart
/// Purpose: Service-request status and history enums used by the calendar.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N03: moved out of `data/models/enum/` into `domain/enums/`.

import 'dart:convert';

/// Lightweight, self-contained services-history model for the CALENDAR feature.
///
/// The calendar reads `RequestServices` documents and only needs a handful of
/// fields. It used to import `ServicesHistoryModel` from the services module,
/// which broke the calendar whenever that module was removed from the app.
///
/// This local copy keeps the calendar independent of the services module: it
/// parses the same Firestore shape (history lists where the "current" value is
/// the last entry) for just the fields the calendar uses. The type is only used
/// internally inside `calendar_data_service.dart`, so it never meets the
/// module's own model and cannot conflict with it.
class ServicesHistoryModel {
  final List<String> _state;
  final List<String> _emailRequester;
  final List<String> _assignedProviderEmail;
  final List<String> _serviceNameEnglish;
  final List<String> _serviceNameArabic;
  final List<String> _approvalCycle;

  ServicesHistoryModel({
    required List<String> state,
    required List<String> emailRequester,
    required List<String> assignedProviderEmail,
    required List<String> serviceNameEnglish,
    required List<String> serviceNameArabic,
    required List<String> approvalCycle,
  })  : _state = state,
        _emailRequester = emailRequester,
        _assignedProviderEmail = assignedProviderEmail,
        _serviceNameEnglish = serviceNameEnglish,
        _serviceNameArabic = serviceNameArabic,
        _approvalCycle = approvalCycle;

  factory ServicesHistoryModel.fromJson(Map<String, dynamic> json,
      [String? docId]) {
    return ServicesHistoryModel(
      state: _parseStringList(json['state']),
      emailRequester: _parseStringList(json['Email_Requester']),
      assignedProviderEmail: _parseStringList(json['Assigned_Provider_Email']),
      serviceNameEnglish: _parseStringList(json['Service_Name_English']),
      serviceNameArabic: _parseStringList(json['Service_Name_Arabic']),
      approvalCycle: _parseApprovalCycle(json['Approval_Cycle']),
    );
  }

  // "current" value = last entry of the history list (mirrors the module model).
  String get currentState => _state.isNotEmpty ? _state.last : '';
  String get currentEmailRequester =>
      _emailRequester.isNotEmpty ? _emailRequester.last : '';
  String get currentAssignedProviderEmail =>
      _assignedProviderEmail.isNotEmpty ? _assignedProviderEmail.last : '';
  String get currentServiceNameEnglish =>
      _serviceNameEnglish.isNotEmpty ? _serviceNameEnglish.last : '';
  String get currentServiceNameArabic =>
      _serviceNameArabic.isNotEmpty ? _serviceNameArabic.last : '';

  /// Decodes the latest approval-cycle snapshot into entries exposing `state`.
  List<ApprovalCycleEntry> get currentApprovalCycle {
    try {
      final jsonStr = _approvalCycle.isNotEmpty ? _approvalCycle.last : '[]';
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => ApprovalCycleEntry(e['state']?.toString()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── parse helpers (mirror the module model's list handling) ───────────────

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    if (value is Map && value['values'] is List) {
      return (value['values'] as List).map((e) => e?.toString() ?? '').toList();
    }
    if (value is Map && value.containsKey('value')) {
      return [value['value']?.toString() ?? ''];
    }
    return [value.toString()];
  }

  /// Normalises Approval_Cycle into a history list of JSON strings, where the
  /// last entry is the current snapshot of employee maps.
  static List<String> _parseApprovalCycle(dynamic value) {
    String encodeMaps(List list) => jsonEncode(
        list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList());

    if (value == null) return [];
    if (value is String) return [value];
    if (value is Map && value['values'] is List) {
      return (value['values'] as List).map((e) {
        if (e is String) return e;
        if (e is List) return encodeMaps(e);
        return e.toString();
      }).toList();
    }
    if (value is List) {
      // A single snapshot: a flat list of employee maps.
      return [encodeMaps(value)];
    }
    return [];
  }
}

/// Minimal approval-cycle entry — only the `state` field is needed here.
class ApprovalCycleEntry {
  final String? state;
  ApprovalCycleEntry(this.state);
}
