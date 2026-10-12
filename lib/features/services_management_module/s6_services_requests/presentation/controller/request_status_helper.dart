// ******************* FILE INFO *******************
// File Name: request_status_helper
// Description: Pure (context-free) status helpers for request details: English
//              labels, border colors, state icons, approval-cycle inspection
//              and normalization. Extracted from MyRequestDetails.
// Module: services_management_module / presentation/s6_services_requests/controller
// *************************************************

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

String getRequestStateLabel(String state) {
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

Color getRequestBorderColor(String state) {
  switch (state.toLowerCase()) {
    case 'pending':
      return AppColors.pending;
    case 'done':
      return AppColors.lightGreen;
    case 'approved':
      return AppColors.lightGreen;
    case 'rejected':
    case 'cancel':
      return AppColors.block;
    case 'inprogress':
      return AppColors.yellow;
    case 'breached sla':
      return AppColors.block;
    default:
      return AppColors.lightGrey!;
  }
}

String getRequestIconAsset(String state) {
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
      return 'assets/icons_assets/services_assets/status_in_progress_chart_yellow.svg';
    case 'breached sla':
      return 'assets/icons_assets/services_assets/sla_breached_clock_white.svg';
    default:
      return 'assets/icons_assets/main_icons_assets/status_pending_check_cross_orange.svg';
  }
}

/// Normalizes a copy of [list] so exactly the first non-finalized approver is
/// 'pending' and the rest become 'normal' (finalized states are preserved).
List<EmployeeEntityModell> adjustCycleStates(List<EmployeeEntityModell> list) {
  final adjusted = <EmployeeEntityModell>[];
  bool foundPending = false;

  for (int i = 0; i < list.length; i++) {
    final originalState = list[i].state?.toLowerCase();

    if (originalState == 'approved' ||
        originalState == 'rejected' ||
        originalState == 'cancel') {
      adjusted.add(list[i]);
      continue;
    }

    if (!foundPending) {
      adjusted.add(list[i].copyWith(state: 'pending'));
      foundPending = true;
    } else {
      adjusted.add(list[i].copyWith(state: 'normal'));
    }
  }

  return adjusted;
}

bool hasRejectionInApprovalCycle(List<EmployeeEntityModell> approvalCycle) {
  for (var approver in approvalCycle) {
    final state = approver.state?.toLowerCase();
    if (state == 'rejected' || state == 'cancel') {
      return true;
    }
  }
  return false;
}

bool hasSpecificStateInApprovalCycle(
    List<EmployeeEntityModell> approvalCycle, String targetState) {
  for (var approver in approvalCycle) {
    if (approver.state?.toLowerCase() == targetState.toLowerCase()) {
      return true;
    }
  }
  return false;
}

bool areAllApproversApproved(List<EmployeeEntityModell> approvalCycle) {
  for (var approver in approvalCycle) {
    if (approver.state?.toLowerCase() != 'approved') {
      return false;
    }
  }
  return approvalCycle.isNotEmpty;
}

List<String> extractStatesFromValueList(List<dynamic>? valueList) {
  List<String> states = [];

  if (valueList != null && valueList.isNotEmpty) {
    for (var item in valueList) {
      final state = (item['state'] ?? '').toString().toLowerCase();
      states.add(state);
    }
  }

  return states;
}
