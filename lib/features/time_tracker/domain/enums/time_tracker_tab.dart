/// Module: time_tracker / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_tab.dart
/// Purpose: Declares `TimeTrackerTab` — the tabs of the module's main page,
///          in Figma order.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner rule (8/10/2026): Employee and HR are the SAME module; the role's
/// switches decide which tabs appear (Screen Inventory §3). Which tabs a user
/// sees is decided by `TimeTrackerAccess.visibleTabs`. Groups are a sub-view
/// of the Employees tab (Figma `661:94406`), so they have no tab of their own.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';

enum TimeTrackerTab {
  dashboard,
  attendance,
  requests,
  approvals,
  requestTypes,
  locations,
  employees,
  vacationBalances;

  /// Function Name: [label]
  ///
  /// Purpose: Localised tab title. The dashboard tab is called "Overview"
  /// when the user can see the HR dashboard (Figma HR strip), "Dashboard"
  /// otherwise.
  ///
  /// Parameters:
  ///   [BuildContext] context: used to resolve `S.of(context)`.
  ///   [bool] hasHrDashboard: the user may open the HR dashboard.
  ///
  /// Return type: [String]
  String label(BuildContext context, {bool hasHrDashboard = false}) {
    final S s = S.of(context);
    switch (this) {
      case TimeTrackerTab.dashboard:
        return hasHrDashboard ? s.timeTrackerTabOverview : s.timeTrackerTabDashboard;
      case TimeTrackerTab.attendance:
        return s.timeTrackerTabAttendance;
      case TimeTrackerTab.requests:
        return s.timeTrackerTabRequests;
      case TimeTrackerTab.approvals:
        return s.timeTrackerTabApprovals;
      case TimeTrackerTab.requestTypes:
        return s.timeTrackerTabRequestTypes;
      case TimeTrackerTab.locations:
        return s.timeTrackerTabLocations;
      case TimeTrackerTab.employees:
        return s.timeTrackerTabEmployees;
      case TimeTrackerTab.vacationBalances:
        return s.timeTrackerTabVacationBalances;
    }
  }
}
