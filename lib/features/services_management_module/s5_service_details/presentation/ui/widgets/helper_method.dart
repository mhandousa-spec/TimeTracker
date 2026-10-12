// ******************* FILE INFO *******************
// File Name: helper_method
// Description: Helper method.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************

// ----------------------------- 🧪 Helper Methods -----------------------------
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';


String getFinalStateFromModelEmp(ServicesHistoryModel service) {
  final statusField = service.currentStatus.toLowerCase(); // ✅ Use currentStatus getter

  if (statusField == 'cancel') return 'cancel';
  if ([
    'inprogress',
    'done',
    'branchsla',
    'breached sla',
  ].contains(statusField)) {
    return statusField;
  }

  // Optional: fallback to approvalCycle
  final approvalCycleList = service.currentApprovalCycle;
  if (approvalCycleList.isNotEmpty) {
    final rejected = approvalCycleList.any(
          (e) => (e.state?.toLowerCase() ?? '') == 'rejected',
    );
    if (rejected) return 'rejected';

    final pending = approvalCycleList.any(
          (e) => (e.state?.toLowerCase() ?? '') == 'pending',
    );
    if (pending) return 'pending';
  }

  return 'N/A';
}

String getFullArabicName(ServicesHistoryModel model) {
  final parts = [
    model.currentFirstNameRequesterArabic,
    model.currentLastNameRequesterArabic,
  ];

  return parts
      .where((part) => part.trim().isNotEmpty)
      .join(' ');
}

String getFullEnglishName(ServicesHistoryModel model) {
  final parts = [
    model.currentFirstNameRequester,
    model.currentLastNameRequester,
  ];

  return parts
      .where((part) => part.trim().isNotEmpty)
      .join(' ');
}

Map<String, dynamic> calculateProviderStats(ServicesHistoryModel model) {
  final stateField = model.currentState.toLowerCase();
  final statusField = model.currentStatus.toLowerCase();

  // Count done and breached per entry
  final isDone = statusField == 'done' || stateField == 'done';
  final isBreached = statusField == 'breached sla' ||
      statusField == 'branchsla' ||
      stateField == 'breached sla' ||
      stateField == 'branchsla';

  // Duration calculation for this entry
  double totalMinutes = 0;
  if (['inprogress', 'done', 'branchsla'].contains(statusField) ||
      ['inprogress', 'done', 'branchsla'].contains(stateField)) {
    final durationStr = model.currentDurationOfServices;
    final unit = model.currentSelectedDurationUnit.toLowerCase();

    final double val = double.tryParse(durationStr) ?? 0;
    totalMinutes = switch (unit) {
      "minutes" => val,
      "hours" => val * 60,
      "days" => val * 1440,
      "weeks" => val * 10080,
      _ => 0,
    };
  }

  return {
    "nameEn": getFullEnglishName(model),
    "nameAr": getFullArabicName(model),
    "departmentEn": model.currentDepartmentRequester,
    "departmentAr": model.currentDepartmentRequesterArabic,
    "jobTitleEn": model.currentJobTitleRequester,
    "jobTitleAr": model.currentJobTitleRequesterArabic,
    "done": isDone ? 1 : 0,
    "breached": isBreached ? 1 : 0,
    "hours": totalMinutes / 60,
  };
}

List<String> getUniqueProviderEmails(List<ServicesHistoryModel> services) {
  final Set<String> emails = {};
  for (final service in services) {
    final provider = service.currentAssignedProviderEmail;
    if (provider.isNotEmpty) {
      emails.add(provider);
    }
  }
  return emails.toList();
}

String getLocalizedDurationUnit(BuildContext context, String? unit) {
  switch (unit?.toLowerCase()) {
    case 'hours':
      return S.of(context).duration_unit_hours;
    case 'minutes':
      return S.of(context).duration_unit_minutes;
    case 'seconds':
      return S.of(context).duration_unit_seconds;
    case 'week':
      return S.of(context).duration_unit_week;
    default:
      return unit ?? '';
  }
}

String formatStartDate(dynamic timestampOrDateTime) {
  if (timestampOrDateTime == null) return '-';

  DateTime date;

  if (timestampOrDateTime is Timestamp) {
    date = timestampOrDateTime.toDate();
  } else if (timestampOrDateTime is DateTime) {
    date = timestampOrDateTime;
  } else {
    return '-';
  }

  final formatted = DateFormat('dd MMM yyyy').format(date);
  return formatted;
}

// ✅ NEW: Localized date formatting function
String formatStartDateLocalized(BuildContext context, dynamic timestampOrDateTime) {
  if (timestampOrDateTime == null) return '-';

  DateTime date;

  if (timestampOrDateTime is Timestamp) {
    date = timestampOrDateTime.toDate();
  } else if (timestampOrDateTime is DateTime) {
    date = timestampOrDateTime;
  } else {
    return '-';
  }

  final formatted = DateFormat.yMMMMd(
    Localizations.localeOf(context).languageCode,
  ).format(date);
  return formatted;
}
