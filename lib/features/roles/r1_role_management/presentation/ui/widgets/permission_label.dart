/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: permission_label.dart
/// Purpose: Render a permission / section identifier as localized display text.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
///
/// The permission enums under `r1_role_management/domain/enums/` return
/// hardcoded English from `getName` and `getUiName` — 100+ literals across 21
/// files — which is why every switch label, section header and role-detail chip
/// stayed English with the app in Arabic.
///
/// Those getters are deliberately NOT translated. `getName` is used as a
/// **Firestore map key** as well as display text (`role_model.dart` around
/// lines 201/389/401/424 and `module_permission_model.dart` 44/48 read and
/// write role documents keyed by it), so localizing it would repoint the
/// permission map of every saved role. `getDataBaseName` is likewise on-disk
/// vocabulary. The English identifier stays canonical; translation happens
/// here, at the render site, exactly as `RequestSectionLabel` does for
/// settings/se6.
///
/// Firestore permission keys (`Take_Screen_Shot`) resolve through the same
/// table after [fromStorageKey] turns them back into their spaced form.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';

abstract final class PermissionLabel {
  const PermissionLabel._();

  /// Function Name: [of]
  ///
  /// Purpose: The display name for a permission or section identifier, in the
  ///          active locale.
  ///
  /// Falls back to [name] unchanged when the table has no entry — a permission
  /// added to an enum without a matching l10n key keeps rendering its English
  /// text rather than disappearing.
  static String of(BuildContext context, String? name) {
    final String key = (name ?? '').trim();
    if (key.isEmpty) return '';

    final S s = S.of(context);
    switch (_normalize(key)) {
      case 'academic history':
        return s.academicHistory;
      case 'active directory':
        return s.activeDirectory;
      case 'active directory module':
        return s.activeDirectoryModule;
      case 'admin dashboard':
        return s.adminDashboard;
      case 'analytics':
        return s.analytics;
      case 'animation':
        return s.animation;
      case 'approval':
        return s.Approval;
      case 'approval permissions':
        return s.approvalPermissions;
      case 'approval permissions module':
        return s.approvalPermissionsModule;
      case 'approve and reject':
        return s.approveAndReject;
      case 'approved and rejected':
        return s.approvedAndRejected;
      case 'approved and rejected request':
        return s.approvedAndRejectedRequest;
      case 'approved only':
        return s.approvedOnly;
      case 'biometrics for login':
        return s.biometricsForLogin;
      case 'branding':
        return s.brandingPermission;
      case 'bulk upload':
        return s.bulkUpload;
      case 'cancel service':
        return s.cancelService;
      case 'certificates':
        return s.certificatesPermission;
      case 'change default password':
        return s.changeDefaultPassword;
      case 'change expiration date':
        return s.changeExpirationDate;
      case 'change role status':
        return s.changeRoleStatus;
      case 'change service status':
        return s.changeServiceStatus;
      // ADDED 31/8/2026 — SettingsPermissions.commentAndFeedback. Sorts before
      // 'company information': "comment" < "company".
      case 'comment and feedback':
        return s.commentAndFeedback;
      case 'company information':
        return s.companyInformation;
      case 'convert to pdf':
        return s.convertToPdf;
      case 'create group permissions':
        return s.createGroupPermissions;
      case 'create group permissions module':
        return s.createGroupPermissionsModule;
      case 'create new form':
        return s.createNewForm;
      case 'create role management':
        return s.createRoleManagement;
      case 'create service':
        return s.createService;
      case 'dashboard':
        return s.dashboard;
      case 'dashboard permissions':
        return s.dashboardPermissions;
      case 'dashboard permissions module':
        return s.dashboardPermissionsModule;
      case 'deactivate user':
        return s.deactivateUser;
      case 'delete form':
        return s.deleteForm;
      case 'delete role':
        return s.deleteRole;
      case 'delete service':
        return s.deleteService;
      case 'department dashboard':
        return s.departmentDashboard;
      case 'download form digital assets':
        return s.downloadFormDigitalAssets;
      case 'download submissions':
        return s.downloadSubmissions;
      case 'duplicate form':
        return s.duplicateForm;
      case 'edit access':
        return s.editAccess;
      case 'edit permission':
        return s.editPermission;
      case 'edit role':
        return s.editRole;
      case 'edit service':
        return s.editService;
      case 'edit uploaded document':
        return s.editUploadedDocument;
      case 'editing form':
        return s.editingForm;
      case 'export analytics data':
        return s.exportAnalyticsData;
      case 'export data':
        return s.exportData;
      case 'export requested services':
        return s.exportRequestedServices;
      case 'export role data':
        return s.exportRoleData;
      case 'export service':
        return s.exportService;
      case 'export submission data':
        return s.exportSubmissionData;
      case 'export users data':
        return s.exportUsersData;
      case 'fill out form':
        return s.fillOutForm;
      case 'form permissions':
        return s.formPermissions;
      case 'form permissions module':
        return s.formPermissionsModule;
      case 'give access':
        return s.giveAccess;
      // ADDED 31/8/2026 — SettingsPermissions.haptic. The enum says "Haptic",
      // the Settings row it hides says "Haptic Feedback"; one l10n key serves
      // both so the two screens cannot drift apart.
      case 'haptic':
        return s.hapticFeedback;
      case 'import users data':
        return s.importUsersData;
      case 'master bulk upload':
        return s.masterBulkUpload;
      case 'pending submissions':
        return s.pendingSubmissions;
      case 'reactive user':
        return s.reactiveUser;
      case 'remove access':
        return s.remove_access;
      case 'remove employee':
        return s.removeEmployee;
      case 'request service':
        return s.RequestService;
      case 'request service permissions':
        return s.requestServicePermissions;
      case 'request service permissions module':
        return s.requestServicePermissionsModule;
      case 'requested services':
        return s.RequestedServices;
      case 'requested services module':
        return s.requestedServicesModule;
      case 'restore data':
        return s.restoreData;
      case 'restore form':
        return s.restoreForm;
      case 'restricted location':
        return s.restrictedLocation;
      case 'results permissions':
        return s.resultsPermissions;
      case 'results permissions module':
        return s.resultsPermissionsModule;
      case 'role management':
        return s.roleManagement;
      case 'role management module':
        return s.roleManagementModule;
      case 'schedule to deactivate':
        return s.scheduleToDeactivate;
      case 'schedule to reactivate':
        return s.scheduleToReactivate;
      case 'screen share':
        return s.screenShare;
      case 'services permissions':
        return s.servicesPermissions;
      case 'services permissions module':
        return s.servicesPermissionsModule;
      case 'settings':
        return s.settings;
      case 'settings module':
        return s.settingsModule;
      case 'share':
        return s.share;
      case 'share cellphones in social data in bio':
        return s.shareCellphonesInSocialDataInBio;
      case 'share emails and social data in bio':
        return s.shareEmailsAndSocialDataInBio;
      case 'share social information':
        return s.shareSocialInformation;
      case 'skills hobbies':
        return s.skillsHobbies;
      case 'social permissions':
        return s.socialPermissions;
      case 'social permissions module':
        return s.socialPermissionsModule;
      case 'statistics':
        return s.Statistics;
      case 'status requested':
        return s.statusRequested;
      case 'submissions':
        return s.submissions;
      case 'systems logs':
        return s.systemsLogs;
      case 'take screen shot':
        return s.takeScreenShot;
      case 'unlock user account':
        return s.unlockUserAccount;
      case 'upload document':
        return s.uploadDocument;
      case 'user access':
        return s.userAccess;
      case 'user access module':
        return s.userAccessModule;
      case 'user management':
        return s.userManagement;
      case 'user management module':
        return s.userManagementModule;
      case 'users':
        return s.usersPermission;
      case 'users requests':
        return s.usersRequests;
      case 'view requesters':
        return s.viewRequesters;
      case 'view submissions':
        return s.viewSubmissions;
      case 'add employee':
        return s.addEmployee;
      case 'add product':
        return s.addProduct;
      case 'allows removing documents owned by anyone':
        return s.allowsRemovingDocumentsOwnedByAnyone;
      case 'approve leave requests':
        return s.approveLeaveRequests;
      case 'assign lead':
        return s.assignLead;
      case 'bulk upload employees':
        return s.bulkUploadEmployees;
      case 'crm module':
        return s.crmModule;
      case 'change deal stage':
        return s.changeDealStage;
      case 'conduct performance reviews':
        return s.conductPerformanceReviews;
      case 'configure crm settings':
        return s.configureCRMSettings;
      case 'convert lead':
        return s.convertLead;
      case 'create account':
        return s.createAccount;
      case 'create contact':
        return s.createContact;
      case 'create deal':
        return s.createDeal;
      case 'create group':
        return s.createGroup;
      case 'create knowledge hub':
        return s.createKnowledgeHub;
      case 'create lead':
        return s.createLead;
      case 'create order':
        return s.createOrder;
      case 'delete account':
        return s.deleteAccount;
      case 'delete contact':
        return s.deleteContact;
      case 'delete deal':
        return s.deleteDeal;
      case 'delete employee':
        return s.deleteEmployee;
      case 'delete lead':
        return s.deleteLead;
      case 'delete message':
        return s.deleteMessage;
      case 'delete qiyas':
        return s.deleteQiyas;
      case 'document management':
        return s.documentManagement;
      case 'download documents':
        return s.downloadDocuments;
      case 'edit account':
        return s.editAccount;
      case 'edit contact':
        return s.editContact;
      case 'edit deal':
        return s.editDeal;
      case 'edit document with approval':
        return s.editDocumentWithApproval;
      case 'edit document without approval':
        return s.editDocumentWithoutApproval;
      case 'edit employee':
        return s.editEmployee;
      case 'edit form':
        return s.editForm;
      case 'edit lead':
        return s.editLead;
      case 'edit message':
        return s.editMessage;
      case 'edit product information':
        return s.editProductInformation;
      case 'edit qiyas details':
        return s.editQiyasDetails;
      case 'employee self service':
        return s.employeeSelfService;
      case 'export crm reports':
        return s.exportCRMReports;
      case 'export contacts':
        return s.exportContacts;
      case 'export employee data':
        return s.exportEmployeeData;
      case 'export hr reports':
        return s.exportHRReports;
      case 'export statistics table':
        return s.exportStatisticsTable;
      case 'forward messages':
        return s.forwardMessages;
      case 'hr module':
        return s.hrModule;
      case 'import contacts':
        return s.importContacts;
      case 'inquiries and comments':
        return s.inquiriesAndComments;
      case 'knowledge hub permissions':
        return s.knowledgeHubPermissions;
      case 'lock geographical':
        return s.lockGeographical;
      case 'log activity':
        return s.logActivity;
      case 'manage attendance':
        return s.manageAttendance;
      case 'manage benefits':
        return s.manageBenefits;
      case 'manage departments':
        return s.manageDepartments;
      case 'manage job positions':
        return s.manageJobPositions;
      case 'manage offboarding':
        return s.manageOffboarding;
      case 'manage onboarding':
        return s.manageOnboarding;
      case 'manage payroll':
        return s.managePayroll;
      case 'manage pipeline':
        return s.managePipeline;
      case 'manage training':
        return s.manageTraining;
      // ADDED 31/8/2026 — SettingsPermissions.notification. Distinct from
      // 'notification module' below, which names the whole module.
      case 'notification':
        return s.notification;
      case 'notification module':
        return s.notificationModule;
      case 'process payroll':
        return s.processPayroll;
      case 'remove documents':
        return s.removeDocuments;
      case 'select owning department':
        return s.selectOwningDepartment;
      case 'set crm permissions':
        return s.setCRMPermissions;
      case 'show crm notifications':
        return s.showCRMNotifications;
      case 'show database notifications':
        return s.showDatabaseNotifications;
      case 'show employees notifications':
        return s.showEmployeesNotifications;
      case 'show events notifications':
        return s.showEventsNotifications;
      case 'show grc notifications':
        return s.showGRCNotifications;
      case 'show hr notifications':
        return s.showHRNotifications;
      case 'show inventory notifications':
        return s.showInventoryNotifications;
      case 'show knowledge hub notifications':
        return s.showKnowledgeHubNotifications;
      case 'show messages notifications':
        return s.showMessagesNotifications;
      case 'show notes notifications':
        return s.showNotesNotifications;
      case 'show qiyas notifications':
        return s.showQiyasNotifications;
      case 'show requests notifications':
        return s.showRequestsNotifications;
      case 'show roles notifications':
        return s.showRolesNotifications;
      case 'show services notifications':
        return s.showServicesNotifications;
      case 'show settings notifications':
        return s.showSettingsNotifications;
      case 'show tasks notifications':
        return s.showTasksNotifications;
      case 'show todo notifications':
        return s.showTodoNotifications;
      case 'show tracking notifications':
        return s.showTrackingNotifications;
      case 'show services app notifications':
        return s.showServicesAppNotifications;
      case 'take screenshot':
        return s.takeScreenshot;
      case 'view access':
        return s.viewAccess;
      case 'view accounts':
        return s.viewAccounts;
      case 'view activities':
        return s.viewActivities;
      case 'view attendance reports':
        return s.viewAttendanceReports;
      case 'view crm reports':
        return s.viewCRMReports;
      case 'view contacts':
        return s.viewContacts;
      case 'view deals':
        return s.viewDeals;
      case 'view documents':
        return s.viewDocuments;
      case 'view employee records':
        return s.viewEmployeeRecords;
      case 'view hr analytics':
        return s.viewHRAnalytics;
      case 'view leads':
        return s.viewLeads;
      case 'view only':
        return s.viewOnly;
      case 'view payroll reports':
        return s.viewPayrollReports;
      case 'view performance reviews':
        return s.viewPerformanceReviews;
      case 'view pipeline':
        return s.viewPipeline;
      case 'view storage locations':
        return s.viewStorageLocations;
      case 'view training reports':
        return s.viewTrainingReports;
      // ADDED 31/8/2026 — SettingsPermissions.watermark.
      case 'watermark':
        return s.watermark;
      // ADDED 7/10/2026 — To-Do (TodoPermissionsSections / TodoPermissions).
      // `To_Do_Permissions` folds to 'to do permissions', `View_To_Do` to
      // 'view to do', etc.
      case 'to do permissions':
        return s.toDoPermissions;
      case 'view to do':
        return s.viewToDo;
      case 'create to do':
        return s.createToDo;
      case 'edit to do':
        return s.editToDo;
      case 'delete to do':
        return s.deleteToDo;
      case 'restore to do':
        return s.restoreToDo;
      // ADDED 8/10/2026 — Time Tracker (TimeTrackerPermissionsSections /
      // TimeTrackerPermissions). Keys already labelled above for another
      // module keep that label: Approval_Permissions, Approve_And_Reject, Create_Group.
      case 'check in permissions':
        return s.timeTrackerCheckInPermissions;
      case 'check in and out':
        return s.timeTrackerCheckInAndOut;
      case 'work from different location':
        return s.timeTrackerWorkFromDifferentLocation;
      case 'time tracker dashboard permissions':
        return s.timeTrackerDashboardPermissions;
      case 'personal dashboard':
        return s.timeTrackerPersonalDashboard;
      case 'hr dashboard':
        return s.timeTrackerHrDashboard;
      case 'hr dashboard all departments':
        return s.timeTrackerHrDashboardAllDepartments;
      case 'hr dashboard filter by employee':
        return s.timeTrackerHrDashboardFilterByEmployee;
      case 'attendance permissions':
        return s.timeTrackerAttendancePermissions;
      case 'view attendance':
        return s.timeTrackerViewAttendance;
      case 'request transaction':
        return s.timeTrackerRequestTransaction;
      case 'cancel transaction':
        return s.timeTrackerCancelTransaction;
      case 'export attendance':
        return s.timeTrackerExportAttendance;
      case 'time tracker request permissions':
        return s.timeTrackerRequestPermissions;
      case 'view time tracker requests':
        return s.timeTrackerViewRequests;
      case 'create time tracker request':
        return s.timeTrackerCreateRequest;
      case 'cancel time tracker request':
        return s.timeTrackerCancelRequest;
      case 'send request reminder':
        return s.timeTrackerSendRequestReminder;
      case 'comment on requests':
        return s.timeTrackerCommentOnRequests;
      case 'export time tracker requests':
        return s.timeTrackerExportRequests;
      case 'view approvals':
        return s.timeTrackerViewApprovals;
      case 'cancel request after approving':
        return s.timeTrackerCancelRequestAfterApproving;
      case 'approvals all departments':
        return s.timeTrackerApprovalsAllDepartments;
      case 'comment on approvals':
        return s.timeTrackerCommentOnApprovals;
      case 'request type permissions':
        return s.timeTrackerRequestTypePermissions;
      case 'view request types':
        return s.timeTrackerViewRequestTypes;
      case 'create request type':
        return s.timeTrackerCreateRequestType;
      case 'edit request type':
        return s.timeTrackerEditRequestType;
      case 'change request type status':
        return s.timeTrackerChangeRequestTypeStatus;
      case 'remove request type':
        return s.timeTrackerRemoveRequestType;
      case 'export request types':
        return s.timeTrackerExportRequestTypes;
      case 'location permissions':
        return s.timeTrackerLocationPermissions;
      case 'view locations':
        return s.timeTrackerViewLocations;
      case 'create location':
        return s.timeTrackerCreateLocation;
      case 'edit location':
        return s.timeTrackerEditLocation;
      case 'change location status':
        return s.timeTrackerChangeLocationStatus;
      case 'delete location':
        return s.timeTrackerDeleteLocation;
      case 'export locations':
        return s.timeTrackerExportLocations;
      case 'import locations':
        return s.timeTrackerImportLocations;
      case 'time tracker employee permissions':
        return s.timeTrackerEmployeePermissions;
      case 'view time tracker employees':
        return s.timeTrackerViewEmployees;
      case 'employees all departments':
        return s.timeTrackerEmployeesAllDepartments;
      case 'assign employee':
        return s.timeTrackerAssignEmployee;
      case 'reassign employee location':
        return s.timeTrackerReassignEmployeeLocation;
      case 'remove employee assignment':
        return s.timeTrackerRemoveEmployeeAssignment;
      case 'export time tracker employees':
        return s.timeTrackerExportEmployees;
      case 'group permissions':
        return s.timeTrackerGroupPermissions;
      case 'view groups':
        return s.timeTrackerViewGroups;
      case 'edit group':
        return s.timeTrackerEditGroup;
      case 'delete group':
        return s.timeTrackerDeleteGroup;
      case 'vacation balance permissions':
        return s.timeTrackerVacationBalancePermissions;
      case 'view vacation balances':
        return s.timeTrackerViewVacationBalances;
      case 'edit vacation balance':
        return s.timeTrackerEditVacationBalance;
      case 'import vacation balances':
        return s.timeTrackerImportVacationBalances;
      case 'export vacation balances':
        return s.timeTrackerExportVacationBalances;
      default:
        return key;
    }
  }

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Localize a raw Firestore permission key such as
  ///          `Take_Screen_Shot` or `CRM_Module`.
  ///
  /// `module_switches_builder` builds its row labels straight off the document
  /// keys, so it never touches the enums at all — it needs the underscore form
  /// folded back to the spaced form before the lookup.
  /// Function Name: [_normalize]
  ///
  /// Purpose: Fold an identifier to a stable lookup form — lowercase, with
  ///          underscores and repeated spaces collapsed.
  ///
  /// HARDENED 13/8/2026: the switch matched identifiers exactly, which is too
  /// brittle for values that arrive from three different places. The enums say
  /// `CRM Module`, `role_overview._formatPermissionName` title-cases the
  /// Firestore key into `Crm Module`, and the raw document key is
  /// `CRM_Module` — three spellings of one permission, only one of which
  /// matched. All three now resolve.
  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static String fromStorageKey(BuildContext context, String storageKey) {
    final String spaced = storageKey
        .replaceAll('_', ' ')
        .replaceAll('  ', ' ')
        .trim();
    return of(context, spaced);
  }
}
