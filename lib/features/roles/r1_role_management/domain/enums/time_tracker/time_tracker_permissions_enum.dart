/// Module: roles / r1_role_management / domain / enums / time_tracker
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_permissions_enum.dart
/// Purpose: Declares `TimeTrackerPermissions` — the 48 child switches of the
///          Time Tracker block on the "Adding New Role" screen.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Source: "Time Tracker — FINAL SPEC (permissions + Firebase)" §1 (owner
/// rounds 1–2, 8/10/2026): 10 sections / 48 switches. Each constant belongs to
/// exactly one section in `TimeTrackerPermissionsSections.sectionPermissions`.
///
/// ⚠️ [getDataBaseName] is the exact key stored in
/// `Demo_Permissions/{cid}.time_tracker` (written by Knowticed Admin) and in
/// `time_tracker_module_permissions/{roleId}`. It must stay byte-identical to
/// the FINAL SPEC and to the admin app — the client compares keys with an
/// exact `containsKey`. Renaming a constant is free; renaming its key orphans
/// every role already saved.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum TimeTrackerPermissions implements ModulePermissionsSectionsPermission {
  // 1 · Check_In_Permissions
  checkInAndOut('Check_In_And_Out'),
  workFromDifferentLocation('Work_From_Different_Location'),

  // 2 · Time_Tracker_Dashboard_Permissions
  personalDashboard('Personal_Dashboard'),
  hrDashboard('HR_Dashboard'),
  hrDashboardAllDepartments('HR_Dashboard_All_Departments'),
  hrDashboardFilterByEmployee('HR_Dashboard_Filter_By_Employee'),

  // 3 · Attendance_Permissions
  viewAttendance('View_Attendance'),
  requestTransaction('Request_Transaction'),
  cancelTransaction('Cancel_Transaction'),
  exportAttendance('Export_Attendance'),

  // 4 · Time_Tracker_Request_Permissions
  viewRequests('View_Time_Tracker_Requests'),
  createRequest('Create_Time_Tracker_Request'),
  cancelRequest('Cancel_Time_Tracker_Request'),
  sendRequestReminder('Send_Request_Reminder'),
  commentOnRequests('Comment_On_Requests'),
  exportRequests('Export_Time_Tracker_Requests'),

  // 5 · Approval_Permissions
  viewApprovals('View_Approvals'),
  approveAndReject('Approve_And_Reject'),
  cancelRequestAfterApproving('Cancel_Request_After_Approving'),
  approvalsAllDepartments('Approvals_All_Departments'),
  commentOnApprovals('Comment_On_Approvals'),

  // 6 · Request_Type_Permissions
  viewRequestTypes('View_Request_Types'),
  createRequestType('Create_Request_Type'),
  editRequestType('Edit_Request_Type'),
  changeRequestTypeStatus('Change_Request_Type_Status'),
  removeRequestType('Remove_Request_Type'),
  exportRequestTypes('Export_Request_Types'),

  // 7 · Location_Permissions (no-HR companies)
  viewLocations('View_Locations'),
  createLocation('Create_Location'),
  editLocation('Edit_Location'),
  changeLocationStatus('Change_Location_Status'),
  deleteLocation('Delete_Location'),
  exportLocations('Export_Locations'),
  importLocations('Import_Locations'),

  // 8 · Time_Tracker_Employee_Permissions
  viewEmployees('View_Time_Tracker_Employees'),
  employeesAllDepartments('Employees_All_Departments'),
  assignEmployee('Assign_Employee'),
  reassignEmployeeLocation('Reassign_Employee_Location'),
  removeEmployeeAssignment('Remove_Employee_Assignment'),
  exportEmployees('Export_Time_Tracker_Employees'),

  // 9 · Group_Permissions
  viewGroups('View_Groups'),
  createGroup('Create_Group'),
  editGroup('Edit_Group'),
  deleteGroup('Delete_Group'),

  // 10 · Vacation_Balance_Permissions
  viewVacationBalances('View_Vacation_Balances'),
  editVacationBalance('Edit_Vacation_Balance'),
  importVacationBalances('Import_Vacation_Balances'),
  exportVacationBalances('Export_Vacation_Balances');

  const TimeTrackerPermissions(this.storageKey);

  /// The Firestore key (see the file header warning).
  final String storageKey;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName => storageKey;

  @override
  String get getUiName {
    final S s = S.current;
    switch (this) {
      case checkInAndOut:
        return s.timeTrackerCheckInAndOut;
      case workFromDifferentLocation:
        return s.timeTrackerWorkFromDifferentLocation;
      case personalDashboard:
        return s.timeTrackerPersonalDashboard;
      case hrDashboard:
        return s.timeTrackerHrDashboard;
      case hrDashboardAllDepartments:
        return s.timeTrackerHrDashboardAllDepartments;
      case hrDashboardFilterByEmployee:
        return s.timeTrackerHrDashboardFilterByEmployee;
      case viewAttendance:
        return s.timeTrackerViewAttendance;
      case requestTransaction:
        return s.timeTrackerRequestTransaction;
      case cancelTransaction:
        return s.timeTrackerCancelTransaction;
      case exportAttendance:
        return s.timeTrackerExportAttendance;
      case viewRequests:
        return s.timeTrackerViewRequests;
      case createRequest:
        return s.timeTrackerCreateRequest;
      case cancelRequest:
        return s.timeTrackerCancelRequest;
      case sendRequestReminder:
        return s.timeTrackerSendRequestReminder;
      case commentOnRequests:
        return s.timeTrackerCommentOnRequests;
      case exportRequests:
        return s.timeTrackerExportRequests;
      case viewApprovals:
        return s.timeTrackerViewApprovals;
      case approveAndReject:
        return s.timeTrackerApproveAndReject;
      case cancelRequestAfterApproving:
        return s.timeTrackerCancelRequestAfterApproving;
      case approvalsAllDepartments:
        return s.timeTrackerApprovalsAllDepartments;
      case commentOnApprovals:
        return s.timeTrackerCommentOnApprovals;
      case viewRequestTypes:
        return s.timeTrackerViewRequestTypes;
      case createRequestType:
        return s.timeTrackerCreateRequestType;
      case editRequestType:
        return s.timeTrackerEditRequestType;
      case changeRequestTypeStatus:
        return s.timeTrackerChangeRequestTypeStatus;
      case removeRequestType:
        return s.timeTrackerRemoveRequestType;
      case exportRequestTypes:
        return s.timeTrackerExportRequestTypes;
      case viewLocations:
        return s.timeTrackerViewLocations;
      case createLocation:
        return s.timeTrackerCreateLocation;
      case editLocation:
        return s.timeTrackerEditLocation;
      case changeLocationStatus:
        return s.timeTrackerChangeLocationStatus;
      case deleteLocation:
        return s.timeTrackerDeleteLocation;
      case exportLocations:
        return s.timeTrackerExportLocations;
      case importLocations:
        return s.timeTrackerImportLocations;
      case viewEmployees:
        return s.timeTrackerViewEmployees;
      case employeesAllDepartments:
        return s.timeTrackerEmployeesAllDepartments;
      case assignEmployee:
        return s.timeTrackerAssignEmployee;
      case reassignEmployeeLocation:
        return s.timeTrackerReassignEmployeeLocation;
      case removeEmployeeAssignment:
        return s.timeTrackerRemoveEmployeeAssignment;
      case exportEmployees:
        return s.timeTrackerExportEmployees;
      case viewGroups:
        return s.timeTrackerViewGroups;
      case createGroup:
        return s.timeTrackerCreateGroup;
      case editGroup:
        return s.timeTrackerEditGroup;
      case deleteGroup:
        return s.timeTrackerDeleteGroup;
      case viewVacationBalances:
        return s.timeTrackerViewVacationBalances;
      case editVacationBalance:
        return s.timeTrackerEditVacationBalance;
      case importVacationBalances:
        return s.timeTrackerImportVacationBalances;
      case exportVacationBalances:
        return s.timeTrackerExportVacationBalances;
    }
  }
}
