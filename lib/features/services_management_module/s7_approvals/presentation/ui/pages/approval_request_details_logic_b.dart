/// Module: services_management_module
/// Description: Approval-details page — pure display/formatting helpers
///              (department label, duration unit localization, status label,
///              final-state resolution). No Firestore access.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: none (pure helpers)
/// Revision History: 2026-07-02 — renamed from approval_request_details.logic_b.dart
///                    (audit fix item 5d); moved requester-language-lookup,
///                    approver-name-lookup, notification-sending and
///                    reject/approve-comment fetch (all Firestore) into
///                    ApprovalRequestDetailsCubit (audit fix item 1) since
///                    the page now loads comments via cubit.initialize().
part of 'approval_request_details.dart';

// Auto-extracted to keep files under 600 lines.
extension _ApprovalLogicB on _ApprovalDetailsScreenState {
  String getLocalizedDepartment(BuildContext context, String? departmentId) {
    if (departmentId == null || departmentId.isEmpty) {
      return '-';
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    String? result;

    if (isArabic) {
      result = departmentController.getArabicDepartmentNameFromDepartmentId(
          departmentId: departmentId);
    } else {
      result = departmentController.getEnglishDepartmentNameFromDepartmentId(
          departmentId: departmentId);
    }

    if (result == null || result.isEmpty) {
      return departmentId;
    }

    return result;
  }

  String getLocalizedDurationUnit(String? unit, bool isArabic, {num? quantity}) {
    if (unit == null || unit.isEmpty) return '';

    final lowerUnit = unit.toLowerCase().trim();
    final isSingular = (quantity == null) ? false : (quantity == 1);

    if (!isArabic) {
      final map = {
        'days': isSingular ? 'day' : 'days',
        'day': 'day',
        'weeks': isSingular ? 'week' : 'weeks',
        'week': 'week',
        'hours': isSingular ? 'hour' : 'hours',
        'hour': 'hour',
        'minutes': isSingular ? 'minute' : 'minutes',
        'minute': 'minute',
        'months': isSingular ? 'month' : 'months',
        'month': 'month',
        'years': isSingular ? 'year' : 'years',
        'year': 'year',
      };
      return map[lowerUnit] ?? unit;
    } else {
      final map = {
        'days': isSingular ? 'يوم' : 'أيام',
        'day': 'يوم',
        'weeks': isSingular ? 'أسبوع' : 'أسابيع',
        'week': 'أسبوع',
        'hours': isSingular ? 'ساعة' : 'ساعات',
        'hour': 'ساعة',
        'minutes': isSingular ? 'دقيقة' : 'دقائق',
        'minute': 'دقيقة',
        'months': isSingular ? 'شهر' : 'أشهر',
        'month': 'شهر',
        'years': isSingular ? 'سنة' : 'سنوات',
        'year': 'سنة',
      };
      return map[lowerUnit] ?? unit;
    }
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  String getLocalizedStatus(String status) {
    final result = switch (status.toLowerCase()) {
      'done' => S.of(context).Done,
      'approved' => S.of(context).Approved,
      'pending' => S.of(context).Pending,
      'rejected' => S.of(context).Rejected,
      'cancel' => S.of(context).Canceled,
      'inprogress' => S.of(context).Inprogress,
      'branchsla' || 'breached sla' => S.of(context).BreachedSLA,
      _ => S.of(context).Pending,
    };
    return result;
  }

  String getFinalStateFromModel(ServicesHistoryModel service) {
    final stateField = (service.currentState ?? '').toString().toLowerCase();

    if (stateField == 'done') {
      return 'done';
    }

    if (stateField == 'cancel') {
      return 'cancel';
    }

    if (['inprogress', 'branchsla', 'breached sla'].contains(stateField)) {
      return stateField;
    }

    final approvalList = service.currentApprovalCycle;

    final states =
    approvalList.map((item) => item.state?.toLowerCase() ?? '').toList();

    final filtered =
    states.where((s) => s.isNotEmpty && s != 'normal').toList();
    if (filtered.contains('cancel')) return 'cancel';
    if (filtered.contains('rejected')) return 'rejected';
    if (filtered.isNotEmpty && filtered.every((s) => s == 'approved'))
      return 'approved';
    if (filtered.contains('pending')) return 'pending';

    if (stateField.isNotEmpty) {
      return stateField;
    }

    return 'N/A';
  }
}
