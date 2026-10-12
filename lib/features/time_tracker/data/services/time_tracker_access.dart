/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_access.dart
/// Purpose: Declares `TimeTrackerAccess` — the single place the Time Tracker
///          module asks "who is signed in" and "may they do X" — and
///          `TimeTrackerIdentity`, the signed-in employee's keys.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Three layers must all say yes (same as `TodoAccess`):
///   1. the company is licensed for Time Tracker (drawer / nav bar enforce it),
///   2. Knowticed Admin's ceiling in `Demo_Permissions/{cid}.time_tracker`,
///   3. the role's grant in `time_tracker_module_permissions/{roleId}`.
/// Layers 2+3 are merged by `MainCoreEmployeeController`'s permission cache;
/// this class only asks it. Fail-closed: anything missing reads as "no".
///
/// Section gating (FINAL SPEC §1): a child switch counts only when its
/// section's master switch is ALSO on. Scope rules: an "All Departments"
/// switch OFF limits the view to the viewer's own department and hides the
/// Department filter. Company-has-HR: the Locations section and the assign /
/// reassign / remove switches are ignored (HR owns them) — callers pass
/// `companyHasHr` (from `CompanyModulesService`).
/// Updated: 9/10/2026 - phase 3: the Employees tab (assignments + groups) is
/// hidden too when the company has HR.
/// Updated: 9/10/2026 - phase 4: [mayActOnStep] takes the requester's
/// department (HR step in scope without "All Departments"); [approverView]
/// (who the Approvals tab is for).
/// Updated: 9/10/2026 - code review: the HR step is for "All Departments"
/// holders ONLY (FINAL SPEC) and never for whoever decided the manager step
/// of the same round ([mayActOnStep] `steps`); an HR approver may act on a
/// BLOCKED manager step (finding 7); [readsCompanyRequests] (finding 9 —
/// only approvers / HR dashboard holders read the company's requests).
///
/// The permission reader and the identity are injectable so the gating can
/// be unit-tested without GetX controllers.

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_sections_enum.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/name_case.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

typedef _P = TimeTrackerPermissions;

/// Answers one switch: [permission] null = the section's master switch.
typedef TimeTrackerPermissionReader = bool Function(
  TimeTrackerPermissionsSections section,
  TimeTrackerPermissions? permission,
);

/// The signed-in employee's keys (all '' before login) and, since phase 2
/// (8/10/2026), the profile shown on the main-page card (name, department,
/// job title, photo).
class TimeTrackerIdentity {
  const TimeTrackerIdentity({
    this.email = '',
    this.employeeId = '',
    this.departmentId = '',
    this.nameEn = '',
    this.nameAr = '',
    this.jobTitleEn = '',
    this.jobTitleAr = '',
    this.departmentName = '',
    this.photo = '',
  });

  /// Lower-cased.
  final String email;
  final String employeeId;
  final String departmentId;
  final String nameEn;
  final String nameAr;
  final String jobTitleEn;
  final String jobTitleAr;

  /// In the app language at sign-in time ('' when unknown).
  final String departmentName;

  /// A network URL, or an app asset path for the default avatar ('' = none).
  final String photo;

  /// Function Name: [name] / [jobTitle]
  ///
  /// Purpose: The value for [isArabic], falling back to the other language.
  ///
  /// Return type: [String]
  /// 9/10/2026 (owner 14:17 #3): proper case through the module helper.
  String name({required bool isArabic}) =>
      NameCase.proper(_pick(isArabic ? nameAr : nameEn, isArabic ? nameEn : nameAr));
  String jobTitle({required bool isArabic}) =>
      NameCase.proper(_pick(isArabic ? jobTitleAr : jobTitleEn, isArabic ? jobTitleEn : jobTitleAr));

  /// The department in proper case (9/10/2026).
  String get department => NameCase.proper(departmentName);

  static String _pick(String first, String fallback) =>
      first.trim().isNotEmpty ? first.trim() : fallback.trim();
}

typedef TimeTrackerIdentityReader = TimeTrackerIdentity Function();

class TimeTrackerAccess {
  const TimeTrackerAccess({
    TimeTrackerPermissionReader reader = _readEmployeeCache,
    TimeTrackerIdentityReader identity = _readSignedInEmployee,
  })  : _reader = reader,
        _identity = identity;

  final TimeTrackerPermissionReader _reader;
  final TimeTrackerIdentityReader _identity;

  // ── Identity ──────────────────────────────────────────────────────────────

  TimeTrackerIdentity get identity => _identity();

  /// Lower-cased email of the signed-in employee, or '' before login.
  String get currentUserEmail => identity.email;

  // ── Generic gate ──────────────────────────────────────────────────────────

  /// Function Name: [isSectionOn]
  ///
  /// Purpose: The section's master switch.
  ///
  /// Return type: [bool]
  bool isSectionOn(TimeTrackerPermissionsSections section) =>
      _reader(section, null);

  /// Function Name: [allows]
  ///
  /// Purpose: [permission] AND its section master are both on.
  ///
  /// Return type: [bool]
  bool allows(TimeTrackerPermissions permission) {
    final TimeTrackerPermissionsSections section =
        TimeTrackerPermissionsSections.sectionOf(permission);
    return isSectionOn(section) && _reader(section, permission);
  }

  // ── 1 · Check in ──────────────────────────────────────────────────────────
  bool get canCheckInAndOut => allows(_P.checkInAndOut);
  bool get canWorkFromDifferentLocation => allows(_P.workFromDifferentLocation);

  // ── 2 · Dashboard ─────────────────────────────────────────────────────────
  bool get canViewPersonalDashboard => allows(_P.personalDashboard);
  bool get canViewHrDashboard => allows(_P.hrDashboard);

  /// The HR dashboard covers every department and shows the Department filter.
  bool get hrDashboardAllDepartments =>
      canViewHrDashboard && allows(_P.hrDashboardAllDepartments);
  bool get canFilterHrDashboardByEmployee =>
      canViewHrDashboard && allows(_P.hrDashboardFilterByEmployee);

  // ── 3 · Attendance ────────────────────────────────────────────────────────
  bool get canViewAttendance => allows(_P.viewAttendance);
  bool get canRequestTransaction => allows(_P.requestTransaction);
  bool get canCancelTransaction => allows(_P.cancelTransaction);
  bool get canExportAttendance => allows(_P.exportAttendance);

  // ── 4 · Requests ──────────────────────────────────────────────────────────
  bool get canViewRequests => allows(_P.viewRequests);
  bool get canCreateRequest => allows(_P.createRequest);
  bool get canCancelRequest => allows(_P.cancelRequest);
  bool get canSendRequestReminder => allows(_P.sendRequestReminder);
  bool get canCommentOnRequests => allows(_P.commentOnRequests);
  bool get canExportRequests => allows(_P.exportRequests);

  // ── 5 · Approvals ─────────────────────────────────────────────────────────
  bool get canViewApprovals => allows(_P.viewApprovals);
  bool get canApproveAndReject => allows(_P.approveAndReject);
  bool get canCancelAfterApproving => allows(_P.cancelRequestAfterApproving);
  bool get approvalsAllDepartments => allows(_P.approvalsAllDepartments);

  /// ADDED 9/10/2026 — the signed-in user is HR (decides the HR step for
  /// every department). Their OWN requests go to their manager only.
  bool get isHrApprover => canApproveAndReject && approvalsAllDepartments;
  bool get canCommentOnApprovals => allows(_P.commentOnApprovals);

  // ── 6 · Request types ─────────────────────────────────────────────────────
  bool get canViewRequestTypes => allows(_P.viewRequestTypes);
  bool get canCreateRequestType => allows(_P.createRequestType);
  bool get canEditRequestType => allows(_P.editRequestType);
  bool get canChangeRequestTypeStatus => allows(_P.changeRequestTypeStatus);
  bool get canRemoveRequestType => allows(_P.removeRequestType);
  bool get canExportRequestTypes => allows(_P.exportRequestTypes);

  // ── 7 · Locations (ignored when the company has HR) ───────────────────────
  bool canViewLocations({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.viewLocations);
  bool canCreateLocation({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.createLocation);
  bool canEditLocation({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.editLocation);
  bool canChangeLocationStatus({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.changeLocationStatus);
  bool canDeleteLocation({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.deleteLocation);
  bool canExportLocations({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.exportLocations);
  bool canImportLocations({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.importLocations);

  // ── 8 · Employees (assign / reassign / remove ignored with HR) ────────────
  bool get canViewEmployees => allows(_P.viewEmployees);
  bool get employeesAllDepartments =>
      canViewEmployees && allows(_P.employeesAllDepartments);
  bool canAssignEmployee({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.assignEmployee);
  bool canReassignEmployeeLocation({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.reassignEmployeeLocation);
  bool canRemoveEmployeeAssignment({required bool companyHasHr}) =>
      !companyHasHr && allows(_P.removeEmployeeAssignment);
  bool get canExportEmployees => allows(_P.exportEmployees);

  // ── 9 · Groups ────────────────────────────────────────────────────────────
  bool get canViewGroups => allows(_P.viewGroups);
  bool get canCreateGroup => allows(_P.createGroup);
  bool get canEditGroup => allows(_P.editGroup);
  bool get canDeleteGroup => allows(_P.deleteGroup);

  // ── 10 · Vacation balance ─────────────────────────────────────────────────
  bool get canViewVacationBalances => allows(_P.viewVacationBalances);
  bool get canEditVacationBalance => allows(_P.editVacationBalance);
  bool get canImportVacationBalances => allows(_P.importVacationBalances);
  bool get canExportVacationBalances => allows(_P.exportVacationBalances);

  // ── Scope rules ───────────────────────────────────────────────────────────

  /// Function Name: [hrDashboardCovers] / [approvalsCover] / [employeesCover]
  ///
  /// Purpose: Whether a record of [departmentId] is inside the viewer's
  /// scope: everything with the "All Departments" switch, else only the
  /// viewer's own department (an unknown department never matches).
  ///
  /// Return type: [bool]
  bool hrDashboardCovers(String departmentId) =>
      hrDashboardAllDepartments || _isOwnDepartment(departmentId);
  bool approvalsCover(String departmentId) =>
      approvalsAllDepartments || _isOwnDepartment(departmentId);
  bool employeesCover(String departmentId) =>
      employeesAllDepartments || _isOwnDepartment(departmentId);

  /// The Department filter is shown only with "All Departments" on.
  bool get showHrDashboardDepartmentFilter => hrDashboardAllDepartments;
  bool get showEmployeesDepartmentFilter => employeesAllDepartments;
  bool get showApprovalsDepartmentFilter => approvalsAllDepartments;

  /// Function Name: [mayActOnStep]
  ///
  /// Purpose: Whether the viewer may approve / reject [step] of a request by
  /// [requesterEmail] (see `ApprovalRouter.mayAct`: the manager step only by
  /// the requester's direct manager stored on it — decision 18, 8/10/2026).
  ///
  /// Parameters:
  ///   [RequestApprovalStep] step
  ///   [String] requesterEmail
  ///   [String] requesterDepartmentId: '' = unknown (never in scope).
  ///
  /// Return type: [bool]
  bool mayActOnStep(
    RequestApprovalStep step, {
    required String requesterEmail,
    String requesterDepartmentId = '',
    List<RequestApprovalStep> steps = const <RequestApprovalStep>[],
    bool managerStepBlocked = false,
  }) =>
      ApprovalRouter.mayAct(
        step: step,
        viewerEmail: currentUserEmail,
        requesterEmail: requesterEmail,
        canApproveAndReject: canApproveAndReject,
        approvalsAllDepartments: approvalsAllDepartments,
        steps: steps,
        managerStepBlocked: managerStepBlocked,
      );

  /// ADDED 9/10/2026 (code review finding 9): the user may read the
  /// company's requests (approvals or the HR dashboard need them); everyone
  /// else only reads their own (`RequestBaseRepository.watchRequestsOf`).
  bool get readsCompanyRequests => canViewApprovals || canViewHrDashboard;

  /// Function Name: [approverView]
  ///
  /// Purpose: The signed-in user as an approver (Approvals tab membership —
  /// `ApprovalInbox.involves`).
  ///
  /// Return type: [ApproverView]
  ApproverView get approverView => ApproverView(
        email: currentUserEmail,
        departmentId: identity.departmentId,
        canApproveAndReject: canApproveAndReject,
        allDepartments: approvalsAllDepartments,
        canCancelAfterApproving: canCancelAfterApproving,
        // 9/10/2026 (code review): no View_Approvals → involved in nothing.
        canViewApprovals: canViewApprovals,
      );

  // ── Tabs / module gate ────────────────────────────────────────────────────

  /// Function Name: [visibleTabs]
  ///
  /// Purpose: The main-page tabs this user may see, in Figma order. Groups
  /// live inside the Employees tab, so either switch opens it.
  ///
  /// Parameters:
  ///   [bool] companyHasHr: hides Locations and Employees / Groups (HR
  ///   owns them — decisions 12, 14).
  ///
  /// Return type: [List<TimeTrackerTab>]
  List<TimeTrackerTab> visibleTabs({required bool companyHasHr}) =>
      List<TimeTrackerTab>.unmodifiable(<TimeTrackerTab>[
        if (canViewPersonalDashboard || canViewHrDashboard)
          TimeTrackerTab.dashboard,
        if (canViewAttendance) TimeTrackerTab.attendance,
        if (canViewRequests) TimeTrackerTab.requests,
        if (canViewApprovals) TimeTrackerTab.approvals,
        if (canViewRequestTypes) TimeTrackerTab.requestTypes,
        if (canViewLocations(companyHasHr: companyHasHr))
          TimeTrackerTab.locations,
        // Phase 3 (9/10/2026): with HR, assignments and groups are HR's
        // (decision 14), so the Employees tab is hidden like Locations.
        if ((canViewEmployees || canViewGroups) && !companyHasHr)
          TimeTrackerTab.employees,
        if (canViewVacationBalances) TimeTrackerTab.vacationBalances,
      ]);

  /// The module opens at all: the user can check in, or sees at least one
  /// tab (Locations counted as if the company had no HR — the exact tab list
  /// is decided once the licence is known).
  bool get canView =>
      canCheckInAndOut || visibleTabs(companyHasHr: false).isNotEmpty;

  bool _isOwnDepartment(String departmentId) {
    final String own = identity.departmentId.trim();
    return own.isNotEmpty && own == departmentId.trim();
  }

  // ── Defaults (the real app) ───────────────────────────────────────────────

  static bool _readEmployeeCache(
    TimeTrackerPermissionsSections section,
    TimeTrackerPermissions? permission,
  ) {
    if (!AppControllers.isEmployeeRegistered) return false;
    return AppControllers.employee.isHasPermission(
      module: Modules.timeTracker,
      section: section,
      permission: permission,
    );
  }

  static TimeTrackerIdentity _readSignedInEmployee() {
    if (!AppControllers.isEmployeeRegistered) return const TimeTrackerIdentity();
    // Type inferred (EmployeeEntityPro?) — no roles-feature import needed.
    final employee = AppControllers.employee.employeeEntity;
    if (employee == null) return const TimeTrackerIdentity();
    final String rawEmail = (employee.email ?? '').trim();
    String join(String? a, String? b) =>
        '${(a ?? '').trim()} ${(b ?? '').trim()}'.trim();
    final String department =
        AppControllers.employee.getEmployeeDepartmentName(rawEmail);
    return TimeTrackerIdentity(
      email: rawEmail.toLowerCase(),
      employeeId: employee.id ?? '',
      departmentId: employee.departmentId ?? '',
      nameEn: join(employee.firstName, employee.lastName),
      nameAr: join(employee.firstNameInArabic, employee.lastNameInArabic),
      jobTitleEn: (employee.title ?? '').trim(),
      jobTitleAr: (employee.titleInArabic ?? '').trim(),
      // The controller answers "no department" when it has none.
      departmentName: department == 'no department' ? '' : department,
      photo: AppControllers.employee.getEmployeePhoto(rawEmail),
    );
  }
}
