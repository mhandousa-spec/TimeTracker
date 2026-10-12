/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_access_test.dart
/// Purpose: Unit tests for the permission contract — the 10 masters + 48
///          switches are byte-identical to FINAL SPEC §1, and
///          `TimeTrackerAccess` gates fail-closed by section, applies the
///          "All Departments" scope, and hides Locations / assignment
///          switches when the company has HR.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_sections_enum.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';

import '../_support/time_tracker_test_fakes.dart';

/// FINAL SPEC §1, copied verbatim: section key -> child keys.
const Map<String, List<String>> _spec = <String, List<String>>{
  'Check_In_Permissions': <String>['Check_In_And_Out', 'Work_From_Different_Location'],
  'Time_Tracker_Dashboard_Permissions': <String>[
    'Personal_Dashboard',
    'HR_Dashboard',
    'HR_Dashboard_All_Departments',
    'HR_Dashboard_Filter_By_Employee',
  ],
  'Attendance_Permissions': <String>[
    'View_Attendance',
    'Request_Transaction',
    'Cancel_Transaction',
    'Export_Attendance',
  ],
  'Time_Tracker_Request_Permissions': <String>[
    'View_Time_Tracker_Requests',
    'Create_Time_Tracker_Request',
    'Cancel_Time_Tracker_Request',
    'Send_Request_Reminder',
    'Comment_On_Requests',
    'Export_Time_Tracker_Requests',
  ],
  'Approval_Permissions': <String>[
    'View_Approvals',
    'Approve_And_Reject',
    'Cancel_Request_After_Approving',
    'Approvals_All_Departments',
    'Comment_On_Approvals',
  ],
  'Request_Type_Permissions': <String>[
    'View_Request_Types',
    'Create_Request_Type',
    'Edit_Request_Type',
    'Change_Request_Type_Status',
    'Remove_Request_Type',
    'Export_Request_Types',
  ],
  'Location_Permissions': <String>[
    'View_Locations',
    'Create_Location',
    'Edit_Location',
    'Change_Location_Status',
    'Delete_Location',
    'Export_Locations',
    'Import_Locations',
  ],
  'Time_Tracker_Employee_Permissions': <String>[
    'View_Time_Tracker_Employees',
    'Employees_All_Departments',
    'Assign_Employee',
    'Reassign_Employee_Location',
    'Remove_Employee_Assignment',
    'Export_Time_Tracker_Employees',
  ],
  'Group_Permissions': <String>['View_Groups', 'Create_Group', 'Edit_Group', 'Delete_Group'],
  'Vacation_Balance_Permissions': <String>[
    'View_Vacation_Balances',
    'Edit_Vacation_Balance',
    'Import_Vacation_Balances',
    'Export_Vacation_Balances',
  ],
};

void main() {
  group('permission keys (contract with the admin app)', () {
    test('10 sections / 48 switches, byte-identical to FINAL SPEC §1', () {
      expect(TimeTrackerPermissionsSections.values, hasLength(10));
      expect(TimeTrackerPermissions.values, hasLength(48));
      expect(
        <String, List<String>>{
          for (final TimeTrackerPermissionsSections s
              in TimeTrackerPermissionsSections.values)
            s.getDataBaseName: <String>[
              for (final TimeTrackerPermissions p in s.children) p.getDataBaseName,
            ],
        },
        _spec,
      );
    });

    test('every switch belongs to exactly one section', () {
      for (final TimeTrackerPermissions p in TimeTrackerPermissions.values) {
        final int owners = TimeTrackerPermissionsSections.values
            .where((TimeTrackerPermissionsSections s) => s.children.contains(p))
            .length;
        expect(owners, 1, reason: p.storageKey);
      }
      expect(
        TimeTrackerPermissionsSections.sectionOf(TimeTrackerPermissions.importLocations),
        TimeTrackerPermissionsSections.locations,
      );
    });

    test('two columns of five sections cover every section once', () {
      expect(TimeTrackerPermissionsSections.firstColumnValues, hasLength(5));
      expect(TimeTrackerPermissionsSections.lastColumnValues, hasLength(5));
      expect(
        <Enum>{
          ...TimeTrackerPermissionsSections.firstColumnValues,
          ...TimeTrackerPermissionsSections.lastColumnValues,
        },
        TimeTrackerPermissionsSections.values.toSet(),
      );
    });
  });

  group('fail-closed section gating', () {
    test('nothing on → nothing allowed, module closed', () {
      final TimeTrackerAccess access = accessWith(<String>{});
      expect(access.canCheckInAndOut, isFalse);
      expect(access.visibleTabs(companyHasHr: false), isEmpty);
      expect(access.canView, isFalse);
    });

    test('a child switch without its master is OFF', () {
      final TimeTrackerAccess access =
          accessWith(<String>{'View_Attendance', 'Create_Time_Tracker_Request'});
      expect(access.canViewAttendance, isFalse);
      expect(access.canCreateRequest, isFalse);
    });

    test('a master without the child is OFF too', () {
      final TimeTrackerAccess access = accessWith(<String>{'Attendance_Permissions'});
      expect(access.isSectionOn(TimeTrackerPermissionsSections.attendance), isTrue);
      expect(access.canViewAttendance, isFalse);
    });

    test('master + child → allowed', () {
      final TimeTrackerAccess access =
          accessWith(<String>{'Check_In_Permissions', 'Check_In_And_Out'});
      expect(access.canCheckInAndOut, isTrue);
      expect(access.canWorkFromDifferentLocation, isFalse);
      expect(access.canView, isTrue);
    });

    test('everything on → every getter true (no HR)', () {
      final TimeTrackerAccess access = accessWith(allKeys());
      for (final TimeTrackerPermissions p in TimeTrackerPermissions.values) {
        expect(access.allows(p), isTrue, reason: p.storageKey);
      }
      expect(access.visibleTabs(companyHasHr: false), TimeTrackerTab.values);
    });
  });

  group('"All Departments" scope', () {
    test('OFF → own department only, Department filter hidden', () {
      final TimeTrackerAccess access = accessWith(<String>{
        'Time_Tracker_Dashboard_Permissions',
        'HR_Dashboard',
        'Approval_Permissions',
        'View_Approvals',
        'Time_Tracker_Employee_Permissions',
        'View_Time_Tracker_Employees',
      });
      expect(access.hrDashboardCovers('dep-1'), isTrue);
      expect(access.hrDashboardCovers('dep-2'), isFalse);
      expect(access.approvalsCover('dep-2'), isFalse);
      expect(access.employeesCover('dep-2'), isFalse);
      expect(access.showHrDashboardDepartmentFilter, isFalse);
      expect(access.showEmployeesDepartmentFilter, isFalse);
    });

    test('ON → every department, filter shown', () {
      final TimeTrackerAccess access = accessWith(allKeys());
      expect(access.hrDashboardCovers('dep-2'), isTrue);
      expect(access.approvalsCover('dep-2'), isTrue);
      expect(access.employeesCover('dep-9'), isTrue);
      expect(access.showHrDashboardDepartmentFilter, isTrue);
    });

    test('an "All Departments" child alone does not open the view', () {
      final TimeTrackerAccess access = accessWith(<String>{
        'Time_Tracker_Dashboard_Permissions',
        'HR_Dashboard_All_Departments',
      });
      expect(access.canViewHrDashboard, isFalse);
      expect(access.hrDashboardAllDepartments, isFalse);
    });

    test('an unknown viewer department never matches', () {
      final TimeTrackerAccess access = accessWith(<String>{
        'Approval_Permissions',
        'View_Approvals',
      }, departmentId: '');
      expect(access.approvalsCover(''), isFalse);
    });

    test('approval steps: manager step needs the manager; HR step needs all depts',
        () {
      const RequestApprovalStep manager = RequestApprovalStep(
        step: ApprovalStepKind.manager,
        approverEmail: 'me@co.com',
      );
      const RequestApprovalStep hr = RequestApprovalStep(step: ApprovalStepKind.hr);
      final TimeTrackerAccess own = accessWith(<String>{
        'Approval_Permissions',
        'Approve_And_Reject',
      });
      expect(own.mayActOnStep(manager, requesterEmail: 'r@co.com'), isTrue);
      expect(own.mayActOnStep(hr, requesterEmail: 'r@co.com'), isFalse);
      final TimeTrackerAccess other = accessWith(<String>{
        'Approval_Permissions',
        'Approve_And_Reject',
      }, email: 'someone@co.com');
      expect(other.mayActOnStep(manager, requesterEmail: 'r@co.com'), isFalse);
      final TimeTrackerAccess hrAccess = accessWith(allKeys());
      expect(hrAccess.mayActOnStep(hr, requesterEmail: 'r@co.com'), isTrue);
    });
  });

  group('company has HR', () {
    final TimeTrackerAccess access = accessWith(allKeys());

    test('Locations section and assign / reassign / remove are ignored', () {
      expect(access.canViewLocations(companyHasHr: true), isFalse);
      expect(access.canCreateLocation(companyHasHr: true), isFalse);
      expect(access.canImportLocations(companyHasHr: true), isFalse);
      expect(access.canAssignEmployee(companyHasHr: true), isFalse);
      expect(access.canReassignEmployeeLocation(companyHasHr: true), isFalse);
      expect(access.canRemoveEmployeeAssignment(companyHasHr: true), isFalse);
      expect(access.canViewLocations(companyHasHr: false), isTrue);
      expect(access.canAssignEmployee(companyHasHr: false), isTrue);
    });

    // Updated 9/10/2026 (phase 3): with HR the Employees tab (assignments +
    // groups) is hidden too — HR owns them (decision 14).
    test('Locations + Employees tabs hidden; the rest stay', () {
      final List<TimeTrackerTab> tabs = access.visibleTabs(companyHasHr: true);
      expect(tabs, isNot(contains(TimeTrackerTab.locations)));
      expect(tabs, isNot(contains(TimeTrackerTab.employees)));
      expect(tabs, contains(TimeTrackerTab.requestTypes));
      expect(tabs, contains(TimeTrackerTab.vacationBalances));
      expect(access.canViewEmployees, isTrue);
      expect(access.canCreateGroup, isTrue);
    });
  });

  test('Groups alone open the Employees tab', () {
    final TimeTrackerAccess access =
        accessWith(<String>{'Group_Permissions', 'View_Groups'});
    expect(access.visibleTabs(companyHasHr: false), <TimeTrackerTab>[
      TimeTrackerTab.employees,
    ]);
  });

  test('identity comes from the injected reader', () {
    final TimeTrackerAccess access = accessWith(<String>{}, email: 'x@co.com');
    expect(access.currentUserEmail, 'x@co.com');
    expect(const TimeTrackerIdentity().email, '');
  });
}
