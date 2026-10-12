/// Module: services_management_module
/// Description: Approval-details page — status/icon/label helpers and the
///              model-refresh flow (delegates to ApprovalRequestDetailsCubit
///              for all Firestore reads).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: ApprovalRequestDetailsCubit
/// Revision History: 2026-07-02 — renamed from approval_request_details.logic_a.dart
///                    (audit fix item 5d) and moved every direct Firestore
///                    call into ApprovalRequestDetailsCubit (audit fix item 1).

part of 'approval_request_details.dart';

// Auto-extracted to keep files under 600 lines.
extension _ApprovalLogicA on _ApprovalDetailsScreenState {
  String getStatusIcon(String stateLabel) {
    if (stateLabel.toLowerCase().contains('approved') ||
        stateLabel.contains('موافقة')) {
      return 'assets/icons_assets/main_icons_assets/status_approved_check_green.svg';
    } else if (stateLabel.toLowerCase().contains('rejected') ||
        stateLabel.contains('مرفوض')) {
      return 'assets/icons_assets/services_assets/rejected_x_white.svg';
    } else {
      return '';
    }
  }

  String _getLabel(String state) {
    switch (state.toLowerCase()) {
      case 'done':
        return 'Done';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancel':
        return 'Canceled';
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'Inprogress';
      case 'breached sla':
        return 'Breached SLA';
      default:
        return FormatHelper.capitalize(state);
    }
  }

  Color _getBorderColor(String state) {
    switch (state.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'done':
        return AppColors.lightGreen;
      case 'approved':
        return AppColors.lightGreen;
      case 'rejected':
        return AppColors.darkRed!;
      case 'cancel':
        return AppColors.block;
      case 'inprogress':
        return AppColors.secondaryPrimary;
      case 'breached sla':
        return AppColors.block;
      default:
        return AppColors.lightGrey!;
    }
  }

  String _getIconAsset(String state) {
    switch (state.toLowerCase()) {
      case 'approved':
        return 'assets/icons_assets/main_icons_assets/status_approved_check_green.svg';
      case 'done':
        return 'assets/icons_assets/main_icons_assets/status_approved_check_green.svg';
      case 'rejected':
        return 'assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg';
      case 'cancel':
        return 'assets/icons_assets/services_assets/cancel_x_circle_red.svg';
      case 'pending':
        return 'assets/icons_assets/main_icons_assets/status_pending_check_cross_orange.svg';
      case 'inprogress':
        return 'assets/icons_assets/services_assets/work_in_progress_badge_yellow.svg';
      case 'breached sla':
        return 'assets/icons_assets/services_assets/sla_breached_clock_white.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/status_pending_check_cross_orange.svg';
    }
  }

  String getOverallStatus() {
    final approvalCycle = widget.approvalModel.currentApprovalCycle;
    final docState = currentState?.toLowerCase();

    if (docState == 'cancel') {
      return 'cancel';
    }

    if (docState == 'inprogress' ||
        docState == 'breached sla' ||
        docState == 'done') {
      return docState!;
    }

    for (final approver in approvalCycle) {
      final state = approver.state?.toLowerCase();
      if (state == 'rejected' || state == 'cancel') return state!;
    }

    for (final approver in approvalCycle) {
      if (approver.state?.toLowerCase() == 'pending') return 'pending';
    }

    if (approvalCycle.isNotEmpty &&
        approvalCycle.every((e) => e.state?.toLowerCase() == 'approved')) {
      return 'approved';
    }

    return 'pending';
  }

  List<EmployeeEntityModell> _adjustCycleStates(List<EmployeeEntityModell> list) {
    final adjusted = List<EmployeeEntityModell>.from(list);
    bool foundPending = false;

    for (int i = 0; i < adjusted.length; i++) {
      final originalState = adjusted[i].state?.toLowerCase();

      if (originalState == 'approved' ||
          originalState == 'rejected' ||
          originalState == 'cancel') {
        continue;
      }

      if (!foundPending) {
        adjusted[i] = adjusted[i].copyWith(state: 'pending');
        foundPending = true;
      } else {
        adjusted[i] = adjusted[i].copyWith(state: 'normal');
      }
    }

    return adjusted;
  }

  Color getArrowColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'approved':
        return AppColors.lightGreen;
      case 'rejected':
        return AppColors.block;
      case 'inprogress':
        return AppColors.secondaryPrimary;
      default:
        return AppColors.text;
    }
  }

  /// Refreshes `_currentModel` from Firestore via the cubit — used on load
  /// and after a provider is assigned from the details screen.
  Future<void> _refreshModelFromFirestore() async {
    final cubit = context.read<ApprovalRequestDetailsCubit>();
    final refreshed = await cubit.refreshModelFromFirestore();
    if (refreshed != null && mounted) {
      setState(() {
        _currentModel = refreshed;
      });
    }
  }

  Future<void> loadRequesterData() async {
    final prefs = await SharedPreferences.getInstance();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    setState(() {
      globalEmailRequester = prefs.getString("emailRequester") ?? '';
      globalGenderRequester = prefs.getString("genderRequester") ?? '';
      globalPhoneRequester = prefs.getString("phoneRequester") ?? '';
      globalDepartmentRequester = prefs.getString("departmentRequester") ?? '';

      globalFirstNameRequester = isArabic
          ? prefs.getString("firstNameRequesterArabic") ?? ''
          : prefs.getString("firstNameRequester") ?? '';

      globalLastNameRequester = isArabic
          ? prefs.getString("lastNameRequesterArabic") ?? ''
          : prefs.getString("lastNameRequester") ?? '';

      globalJobTitleRequester = isArabic
          ? prefs.getString("jobTitleRequesterArabic") ?? ''
          : prefs.getString("jobTitleRequester") ?? '';
    });
  }
}
