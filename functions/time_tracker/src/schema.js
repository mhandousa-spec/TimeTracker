'use strict';
/**
 * Firestore paths and field names, mirrored from the app
 * (`TimeTrackerFirestorePaths`, the *Model classes) and the 9 Oct target
 * schema (target.json). Each field lists [name the app writes TODAY, target
 * name]; readers take the first one present (see fields.js), writers use the
 * name the stored document already uses, else the app's current name.
 */

const { COMPANY_ROOT } = require('./config');

const company = (cid) => `${COMPANY_ROOT}/${cid}`;
const moduleDoc = (cid) => `${company(cid)}/Modules/time_tracker`;

const PATHS = Object.freeze({
  companies: () => COMPANY_ROOT,
  moduleDoc,
  attendance: (cid) => `${moduleDoc(cid)}/Attendance`,
  requests: (cid) => `${moduleDoc(cid)}/Requests`,
  locations: (cid) => `${moduleDoc(cid)}/Locations`,
  locationAssignments: (cid) => `${moduleDoc(cid)}/Location_Assignments`,
  groups: (cid) => `${moduleDoc(cid)}/Groups`,
  notificationLog: (cid) => `${moduleDoc(cid)}/Notification_Log`,
  settingsDoc: (cid) => `${moduleDoc(cid)}/Settings/general`,
  hrShifts: (cid) => `${company(cid)}/Modules/hr/Shifts`,
  hrShiftAssignments: (cid) => `${company(cid)}/Modules/hr/Shift_Assignments`,
  hrLocations: (cid) => `${company(cid)}/Modules/hr/Locations`,
  employeesInfo: (cid) => `${company(cid)}/Employees_Info`,
  notifications: (cid) => `${company(cid)}/Notifications`,
  templates: (cid) => `${company(cid)}/Modules/notification/notification_templates`,
  roles: (cid) => `${company(cid)}/Roles`,
  subscriptionAdmin: (cid) => `${company(cid)}/Subscription_Admin`,
  rolePermissions: (cid) => `${company(cid)}/time_tracker_module_permissions`,
  licenceDoc: (cid) => `Demo_Requests/${cid}`,
  /**
   * The company record, company-scoped only:
   *   1. `Demo/{cid}/Companys/{cid}` — where it lives today (the app's
   *      Settings reads `ApiConstants.company`; the Admin writes it there);
   *   2. `Demo/{cid}/Companies/{cid}` — the approved rename (migration not
   *      done yet).
   * Top-level `Companys/` / `Companies/` copies are NOT read (not company-scoped).
   */
  companyRecordCandidates: (cid) => [`${company(cid)}/Companys/${cid}`, `${company(cid)}/Companies/${cid}`],
});

const F = Object.freeze({
  // Attendance/{email}_{yyyy-MM-dd}
  attendanceId: ['Attendance_Id'],
  employeeEmail: ['Employee_Email'],
  attendanceDate: ['Attendance_Date'],
  sessions: ['Sessions'],
  attendanceStatus: ['Attendance_Status'],
  lateMinutes: ['Late_Minutes'],
  breakMinutes: ['Break_Minutes'],
  pausedMinutes: ['Paused_Minutes'],
  totalWorkMinutes: ['Total_Work_Minutes'],
  isCorrected: ['Is_Corrected_By_Transaction'],
  sourceRequestId: ['Source_Request_Id', 'Correction_Request_Id'],
  alerts: ['Alerts'],
  // keys inside one session map
  checkIn: ['Check_In_Date_Time', 'Check_In_At'],
  checkOut: ['Check_Out_Date_Time', 'Check_Out_At'],
  workLocationId: ['Work_Location_Id'],
  isAutoCheckOut: 'Is_Auto_Check_Out',
  pauses: 'Pauses',
  breaks: 'Breaks',
  intervalStart: 'Start',
  intervalEnd: 'End',
  // keys inside one alert map
  alertType: 'Alert_Type',
  alertAt: 'At',
  alertMinutesOver: 'Minutes_Over',

  // Locations/{id} (no-HR companies) and Modules/hr/Locations/{id}
  nameEn: ['Name_En', 'Name_English', 'Name'],
  nameAr: ['Name_Ar', 'Name_Arabic'],
  workStart: ['Work_Start_Time', 'Work_Start_Minutes', 'Start_Minutes'],
  workEnd: ['Work_End_Time', 'Work_End_Minutes', 'End_Minutes'],
  workingDays: ['Working_Days'],
  lateAfter: ['Late_After_Minutes'],
  isBreakAllowed: ['Is_Break_Allowed'],
  // target name first; the app's legacy `Break_Minutes` (allowed length) as fallback
  allowedBreakMinutes: ['Allowed_Break_Minutes', 'Break_Minutes'],
  isPauseAllowed: ['Is_Pause_Allowed'],
  allowedPauseMinutes: ['Allowed_Pause_Minutes'],
  locationStatus: ['Location_Status', 'Status'],
  timeZone: ['Time_Zone'],

  // Location_Assignments/{email} and Groups/{id}
  locationId: ['Location_Id'],
  startDate: ['Start_Date'],
  groupId: ['Group_Id'],
  // approved schema: optional history map `Custom_Rules` = {Is_Custom, Is_Break_Allowed,
  // Allowed_Break_Minutes, Is_Pause_Allowed, Allowed_Pause_Minutes}
  customRules: ['Custom_Rules'],
  customIsCustom: 'Is_Custom',
  // the app's legacy flat override flag (fallback only)
  isCustomRules: ['Is_Custom_Rules'],
  isDeleted: ['Is_Deleted'],
  isDifferentLocationAllowed: ['Is_Different_Location_Allowed'],
  allowedLocationIds: ['Allowed_Location_Ids'],

  // Modules/hr
  hrShiftId: ['Shift_Id'],
  hrEmployeeId: ['Employee_Id'],
  hrLocationIds: ['Location_Ids'],
  hrStartMinutes: ['Start_Minutes'],
  hrEndMinutes: ['End_Minutes'],

  // Requests/{id}
  requesterEmail: ['Requester_Email'],
  isTransaction: ['Is_Transaction'],
  requestStatus: ['Request_Status', 'Status'],
  approvalSteps: ['Approval_Steps'],
  currentStep: ['Current_Step'],
  start: ['Start_Date_Time', 'Start_At'],
  end: ['End_Date_Time', 'End_At'],
  isAllDay: ['Is_All_Day'],
  lastReminder: ['Last_Reminder_Date_Time'],
  reminders: ['Reminders'],
  requestedAt: ['Creation_Date', 'Requested_At', 'Created_At'],
  updatedAt: ['Updated_At'],
  modifiedBy: ['Modified_By', 'Updated_By'],
  // keys inside one approval step
  step: 'Step',
  approverEmail: 'Approver_Email',
  decision: 'Decision',
  decidedAt: ['Decision_Date_Time', 'Decided_At'],
  isCancellationStep: 'Is_Cancellation_Step',

  // Settings/general (approved schema: this field only)
  autoCheckOutAfter: ['Auto_Check_Out_After_Minutes'],
  // company record (Demo/{cid}/Companys/{cid}) — nested per-field history like the app writes
  companyTimeZone: ['Time_Zone', 'timeZone'],
});

/** Attendance statuses an approved leave writes (`AttendanceStatus.isLeave`). */
const LEAVE_STATUSES = Object.freeze(['vacation', 'sick_leave', 'excused']);

/** `name_of_page` values (`TimeTrackerNotificationPage`). */
const PAGES = Object.freeze({
  requestDetails: 'TimeTrackerRequestDetails',
  approvalDetails: 'TimeTrackerApprovalDetails',
  mainPage: 'TimeTrackerMainPage',
});

/** Role-permission switch keys (`TimeTrackerPermissionsSections` / `TimeTrackerPermissions`). */
const PERMISSIONS = Object.freeze({
  checkInSection: 'Check_In_Permissions',
  checkInAndOut: 'Check_In_And_Out',
  approvalsSection: 'Approval_Permissions',
  viewApprovals: 'View_Approvals',
  approveAndReject: 'Approve_And_Reject',
  approvalsAllDepartments: 'Approvals_All_Departments',
});

module.exports = { PATHS, F, LEAVE_STATUSES, PAGES, PERMISSIONS };
