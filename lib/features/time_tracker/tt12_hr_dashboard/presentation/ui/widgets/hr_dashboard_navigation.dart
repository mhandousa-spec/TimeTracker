/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_navigation.dart
/// Purpose: Declares `HrDashboardNavigation` — where a tap on the HR view
///          leads: the Approvals tab filtered to Pending (optionally
///          transactions only), one request's approver details, or one
///          employee's dashboard.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Gates: the Approvals tab only when the user may see it
/// (`View_Approvals`); a request opens as the APPROVER only when it is in
/// the viewer's Approvals (`ApprovalInbox.involves` — otherwise the details
/// page would read "not available"), else the requester's dashboard opens
/// (HR may always see that, the request is in their dashboard scope).
/// Pages are pushed inside the module's nested Navigator (rail / nav bar
/// stay). LOW haptic (cards / navigation standard).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/pages/employee_dashboard_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/pages/request_details_page.dart';

class HrDashboardNavigation {
  const HrDashboardNavigation._();

  static TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  /// Function Name: [canOpenApprovals]
  ///
  /// Return type: [bool] — the Approvals tab is one of the user's tabs.
  static bool canOpenApprovals(BuildContext context) =>
      _access.canViewApprovals &&
      context.read<TimeTrackerHomeCubit>().state.tabs.contains(TimeTrackerTab.approvals);

  /// Function Name: [openApprovals]
  ///
  /// Purpose: Switch to the Approvals tab on its Pending counter (all
  /// employees; [transactionsOnly] = the Filter's "Transaction" type).
  ///
  /// Return type: [void]
  static void openApprovals(BuildContext context, {bool transactionsOnly = false}) {
    if (!canOpenApprovals(context)) return;
    HapticController.low();
    final RequestsCubit feed = context.read<RequestsCubit>();
    feed.setBucket(RequestScope.approvals, RequestBucket.pending);
    feed.setEmployee('');
    feed.setFilter(
      RequestScope.approvals,
      transactionsOnly ? const RequestFilter(kind: RequestKind.transaction) : RequestFilter.none,
    );
    context.read<TimeTrackerHomeCubit>().selectTab(TimeTrackerTab.approvals);
  }

  /// Function Name: [openRequest]
  ///
  /// Purpose: [request]'s approver details when it is in the viewer's
  /// Approvals, else the requester's dashboard.
  ///
  /// Return type: [void]
  static void openRequest(BuildContext context, TimeTrackerRequest request, TimeTrackerEmployee requester) {
    if (_access.canViewApprovals && ApprovalInbox.involves(request, _access.approverView)) {
      HapticController.low();
      Navigator.of(context).push<void>(MaterialPageRoute<void>(
        builder: (_) => RequestDetailsPage(requestId: request.id, asApprover: true),
      ));
      return;
    }
    openEmployee(context, requester);
  }

  /// Function Name: [openEmployee]
  ///
  /// Purpose: [employee]'s dashboard (Figma `661:96459`).
  ///
  /// Return type: [void]
  static void openEmployee(BuildContext context, TimeTrackerEmployee employee) {
    HapticController.low();
    Navigator.of(context).push<void>(MaterialPageRoute<void>(
      builder: (_) => EmployeeDashboardPage(employee: employee),
    ));
  }
}
