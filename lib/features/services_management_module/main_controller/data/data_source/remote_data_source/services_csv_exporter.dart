// ******************* FILE INFO *******************
// File Name: services_csv_exporter
// Description: Builds and writes the services CSV export (data-layer logic).
// Module: services_management_module / data / helper
// *************************************************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';

/// Owns the CSV-export business/IO logic that previously lived inside the
/// export dialog widget. Keeping it here (data layer) means the widget no
/// longer needs try/catch or file access (§11.2 / §3).
class ServicesCsvExporter {
  const ServicesCsvExporter();

  /// Builds the CSV for [items] and saves it where the user can open it,
  /// through the app-wide [CSVHelper.exportForUser] (Downloads on desktop,
  /// the system save sheet on phones).
  ///
  /// FIX 25/9/2026 (bug report p9 "Export doesn't export the file"): this used
  /// to write into `getApplicationDocumentsDirectory()` — the sandbox
  /// container on macOS, never seen by the user — and any exception thrown
  /// while building the rows escaped through `whenComplete`, so the dialog
  /// just stayed open with nothing saved and nothing reported.
  ///
  /// Returns Left = error message; Right = saved path, or
  /// [CSVHelper.exportCancelled] when the user dismissed the save sheet.
  Future<Either<String, String>> export({
    required List<dynamic> items,
    required Map<dynamic, dynamic> selectedProviders,
    required String fileName,
  }) async {
    final String content;
    try {
      content = buildCsv(items, selectedProviders);
    } catch (e, st) {
      debugPrint('ServicesCsvExporter.buildCsv failed: $e\n$st');
      return Left('$e');
    }
    return CSVHelper().exportForUser(fileName: fileName, csvContent: content);
  }

  String buildCsv(List<dynamic> items, Map<dynamic, dynamic> selectedProviders) {
    final csvContent = StringBuffer();

    csvContent.write('No,');
    csvContent.write('Service Name (EN),');
    csvContent.write('Service Name (AR),');
    csvContent.write('Description (EN),');
    csvContent.write('Description (AR),');
    csvContent.write('Status,');
    csvContent.write('Duration,');
    csvContent.write('Time Unit,');
    csvContent.write('Department,');
    csvContent.write('Limit Availability,');
    csvContent.write('Requires Approval,');
    csvContent.write('Start Date,');
    csvContent.writeln('Service Provider');

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      final serviceId = (item.currentId ?? '').toString();
      final providerName = _providerName(serviceId, selectedProviders);
      final startDate = _startDate(item);

      final serviceNameEn = _safeGet(item.currentServiceNameEnglish);
      final serviceNameAr = _safeGet(item.currentServiceNameArabic);
      final descEn = _safeGet(item.currentServiceDescriptionEnglish);
      final descAr = _safeGet(item.currentServiceDescriptionArabic);
      final status = _safeGet(item.currentState ?? 'Active');
      final duration = _safeGet(item.currentDurationOfServices);
      final timeUnit = _safeGet(item.currentSelectedDurationUnit);
      final departments = _extractDepartments(item);
      final limitAvailability = _hasItems(item.currentSelectDepartment) ? 'Yes' : 'No';
      final requiresApproval = _hasItems(item.currentApprovalCycle) ? 'Yes' : 'No';

      csvContent.write('${i + 1},');
      csvContent.write('${_escapeCsvValue(serviceNameEn)},');
      csvContent.write('${_escapeCsvValue(serviceNameAr)},');
      csvContent.write('${_escapeCsvValue(descEn)},');
      csvContent.write('${_escapeCsvValue(descAr)},');
      csvContent.write('${_escapeCsvValue(status)},');
      csvContent.write('${_escapeCsvValue(duration)},');
      csvContent.write('${_escapeCsvValue(timeUnit)},');
      csvContent.write('${_escapeCsvValue(departments)},');
      csvContent.write('$limitAvailability,');
      csvContent.write('$requiresApproval,');
      csvContent.write('${_escapeCsvValue(startDate)},');
      csvContent.writeln(_escapeCsvValue(providerName));
    }

    return csvContent.toString();
  }

  String _providerName(String serviceId, Map<dynamic, dynamic> selectedProviders) {
    if (serviceId.isEmpty) return 'No Provider';
    final provider = selectedProviders[serviceId];
    if (provider is! Map) return 'No Provider';

    const firstKeys = ['firstName', 'first_name', 'FirstName', 'firstname', 'FIRSTNAME'];
    const lastKeys = ['lastName', 'last_name', 'LastName', 'lastname', 'LASTNAME'];

    String pick(List<String> keys) {
      for (final key in keys) {
        if (provider.containsKey(key)) return provider[key]?.toString() ?? '';
      }
      return '';
    }

    final firstName = pick(firstKeys);
    final lastName = pick(lastKeys);

    if (firstName.isEmpty && lastName.isEmpty) {
      final email = provider['email']?.toString() ?? '';
      return email.isNotEmpty ? email : 'No Provider';
    }
    return '$firstName $lastName'.trim();
  }

  String _startDate(dynamic item) {
    final state = (item.currentState?.toLowerCase()?.trim() ?? '').toString();
    if (state == 'draft') return '-';

    final timestamps = item.timestamps;
    if (timestamps is List && timestamps.isNotEmpty) {
      final value = timestamps[0];
      if (value is int) {
        return _formatDateEnglish(Timestamp.fromMillisecondsSinceEpoch(value));
      } else if (value is Timestamp) {
        return _formatDateEnglish(value);
      }
    }
    if (item.durationOfServicesTimestamp != null) {
      return _formatDateEnglish(item.durationOfServicesTimestamp);
    }
    return '-';
  }

  /// Always formats in English (used for CSV regardless of UI locale).
  String _formatDateEnglish(dynamic date) {
    if (date == null) return '-';
    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return '-';
    }
    return DateFormat('MMM dd, yyyy', 'en_US').format(dateTime);
  }

  String _extractDepartments(dynamic item) {
    final departments = item.currentSelectDepartment;
    if (departments is! List || departments.isEmpty) return '-';

    final names = <String>[];
    for (final dept in departments) {
      String deptName = '';
      if (dept is Map) {
        deptName = dept['departmentName']?.toString() ??
            dept['name']?.toString() ??
            dept['department']?.toString() ??
            '';
      } else if (dept is String) {
        deptName = dept;
      }
      if (deptName.isNotEmpty) names.add(deptName.trim());
    }
    return names.isEmpty ? '-' : names.join('; ');
  }

  bool _hasItems(dynamic value) => value is List && value.isNotEmpty;

  String _safeGet(dynamic value) => value == null ? '' : value.toString().trim();

  String _escapeCsvValue(String value) {
    if (value.isEmpty) return '';
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
