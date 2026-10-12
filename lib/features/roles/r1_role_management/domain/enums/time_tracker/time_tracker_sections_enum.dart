/// Module: roles / r1_role_management / domain / enums / time_tracker
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_sections_enum.dart
/// Purpose: Declares `TimeTrackerPermissionsSections` — the 10 switch groups
///          (each with its master toggle) the Time Tracker block is built
///          from.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Same double-implement as `TodoPermissionsSections`: every section is both a
/// container of permissions AND a permission itself, so its master toggle can
/// be queried with `permission: null`. When a master is OFF the section's
/// tab/feature is hidden and every child reads as OFF (FINAL SPEC §1).
///
/// Column split (8/10/2026): left = the everyday flows (check in, dashboard,
/// attendance, requests, approvals — 5 sections / 21 switches); right = the
/// set-up screens (request types, locations, employees, groups, vacation
/// balance — 5 sections / 27 switches).
///
/// ⚠️ [getDataBaseName] values are stored in Firestore and mirrored in the
/// admin app. Never rename them.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'time_tracker_permissions_enum.dart';

typedef _P = TimeTrackerPermissions;

enum TimeTrackerPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  checkIn('Check_In_Permissions'),
  dashboard('Time_Tracker_Dashboard_Permissions'),
  attendance('Attendance_Permissions'),
  requests('Time_Tracker_Request_Permissions'),
  approvals('Approval_Permissions'),
  requestTypes('Request_Type_Permissions'),
  locations('Location_Permissions'),
  employees('Time_Tracker_Employee_Permissions'),
  groups('Group_Permissions'),
  vacationBalance('Vacation_Balance_Permissions');

  const TimeTrackerPermissionsSections(this.storageKey);

  /// The master key stored in Firestore.
  final String storageKey;

  @override
  String get getName {
    final S s = S.current;
    switch (this) {
      case TimeTrackerPermissionsSections.checkIn:
        return s.timeTrackerCheckInPermissions;
      case TimeTrackerPermissionsSections.dashboard:
        return s.timeTrackerDashboardPermissions;
      case TimeTrackerPermissionsSections.attendance:
        return s.timeTrackerAttendancePermissions;
      case TimeTrackerPermissionsSections.requests:
        return s.timeTrackerRequestPermissions;
      case TimeTrackerPermissionsSections.approvals:
        return s.timeTrackerApprovalPermissions;
      case TimeTrackerPermissionsSections.requestTypes:
        return s.timeTrackerRequestTypePermissions;
      case TimeTrackerPermissionsSections.locations:
        return s.timeTrackerLocationPermissions;
      case TimeTrackerPermissionsSections.employees:
        return s.timeTrackerEmployeePermissions;
      case TimeTrackerPermissionsSections.groups:
        return s.timeTrackerGroupPermissions;
      case TimeTrackerPermissionsSections.vacationBalance:
        return s.timeTrackerVacationBalancePermissions;
    }
  }

  @override
  String get getDataBaseName => storageKey;

  @override
  String get getUiName => getName;

  @override
  bool get isChild => false;

  @override
  List<Enum> get sectionPermissions => children;

  /// The child switches of this section, in display order.
  List<TimeTrackerPermissions> get children {
    switch (this) {
      case TimeTrackerPermissionsSections.checkIn:
        return const <_P>[_P.checkInAndOut, _P.workFromDifferentLocation];
      case TimeTrackerPermissionsSections.dashboard:
        return const <_P>[
          _P.personalDashboard,
          _P.hrDashboard,
          _P.hrDashboardAllDepartments,
          _P.hrDashboardFilterByEmployee,
        ];
      case TimeTrackerPermissionsSections.attendance:
        return const <_P>[
          _P.viewAttendance,
          _P.requestTransaction,
          _P.cancelTransaction,
          _P.exportAttendance,
        ];
      case TimeTrackerPermissionsSections.requests:
        return const <_P>[
          _P.viewRequests,
          _P.createRequest,
          _P.cancelRequest,
          _P.sendRequestReminder,
          _P.commentOnRequests,
          _P.exportRequests,
        ];
      case TimeTrackerPermissionsSections.approvals:
        return const <_P>[
          _P.viewApprovals,
          _P.approveAndReject,
          _P.cancelRequestAfterApproving,
          _P.approvalsAllDepartments,
          _P.commentOnApprovals,
        ];
      case TimeTrackerPermissionsSections.requestTypes:
        return const <_P>[
          _P.viewRequestTypes,
          _P.createRequestType,
          _P.editRequestType,
          _P.changeRequestTypeStatus,
          _P.removeRequestType,
          _P.exportRequestTypes,
        ];
      case TimeTrackerPermissionsSections.locations:
        return const <_P>[
          _P.viewLocations,
          _P.createLocation,
          _P.editLocation,
          _P.changeLocationStatus,
          _P.deleteLocation,
          _P.exportLocations,
          _P.importLocations,
        ];
      case TimeTrackerPermissionsSections.employees:
        return const <_P>[
          _P.viewEmployees,
          _P.employeesAllDepartments,
          _P.assignEmployee,
          _P.reassignEmployeeLocation,
          _P.removeEmployeeAssignment,
          _P.exportEmployees,
        ];
      case TimeTrackerPermissionsSections.groups:
        return const <_P>[
          _P.viewGroups,
          _P.createGroup,
          _P.editGroup,
          _P.deleteGroup,
        ];
      case TimeTrackerPermissionsSections.vacationBalance:
        return const <_P>[
          _P.viewVacationBalances,
          _P.editVacationBalance,
          _P.importVacationBalances,
          _P.exportVacationBalances,
        ];
    }
  }

  /// Function Name: [sectionOf]
  ///
  /// Purpose: The section a child switch belongs to.
  ///
  /// Parameters:
  ///   [TimeTrackerPermissions] permission
  ///
  /// Return type: [TimeTrackerPermissionsSections]
  static TimeTrackerPermissionsSections sectionOf(
    TimeTrackerPermissions permission,
  ) =>
      TimeTrackerPermissionsSections.values.firstWhere(
        (TimeTrackerPermissionsSections s) => s.children.contains(permission),
      );

  /// Left column — the everyday flows.
  static List<Enum> get firstColumnValues => const <Enum>[
        TimeTrackerPermissionsSections.checkIn,
        TimeTrackerPermissionsSections.dashboard,
        TimeTrackerPermissionsSections.attendance,
        TimeTrackerPermissionsSections.requests,
        TimeTrackerPermissionsSections.approvals,
      ];

  /// Right column — the set-up screens.
  static List<Enum> get lastColumnValues => const <Enum>[
        TimeTrackerPermissionsSections.requestTypes,
        TimeTrackerPermissionsSections.locations,
        TimeTrackerPermissionsSections.employees,
        TimeTrackerPermissionsSections.groups,
        TimeTrackerPermissionsSections.vacationBalance,
      ];
}
