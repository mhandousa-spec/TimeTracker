/// Module: core/constants
///
///*************************** FILE INFO ****************************///
/// File Name: firebase_collections.dart
/// Purpose: Single source of truth for Firestore collection names.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added per the code review: collection names were being typed inline at the
/// call site (`collection(FirebaseCollections.demoRequests)`) in several cubits, which is how
/// the drawer and the nav bar ended up disagreeing about whether the name was
/// `Demo_Requests` or `Demo Requests`. Add new collections here rather than
/// inlining the string.
///
/// Note: `ApiConstants` still holds the REST base-URL constants and a few
/// legacy collection names. New collection names belong in this class.
abstract final class FirebaseCollections {
  const FirebaseCollections._();

  /// Per-company demo/licence document. The document id is the company id.
  ///
  /// Underscored spelling confirmed against the live call sites in
  /// `nav_bar_cubit` and `app_drawer_cubit` before this constant was extracted.
  static const String demoRequests = 'Demo_Requests';

  /// Key inside a demo-request document holding the nested detail map.
  static const String demoDetailsKey = 'Demo_Details';

  /// Key holding the per-module licence map, found either at the document root
  /// or nested under [demoDetailsKey].
  static const String modulesKey = 'Modules';

  /// Key holding a module's licence history; the last entry is the current one.
  static const String moduleValuesKey = 'Values';

  // ── Collections extracted from inline literals ─────────────────────────
  // These were typed as string literals at ~80 call sites. Names are copied
  // verbatim, including the inconsistencies (a leading slash on two of them,
  // spaces in the Qiyas names, mixed casing) — normalising them here would
  // silently repoint reads and writes at collections that do not exist.
  // Fixing the names is a data-migration decision, not a refactor.

  static const String demo = 'Demo';
  static const String demoPermissions = 'Demo_Permissions';
  static const String roles = 'Roles';
  static const String employees = 'employees';
  static const String departments = 'departments';
  static const String notifications = 'Notifications';
  // 24/9/2026: About / Terms / Privacy templates live at
  // /Admin/Company_Data/{about_this_app|terms_and_conditions|privacy_policy}/{templateId}
  // ([adminRoot] collection → [companyData] document → policy-type collection).
  static const String adminRoot = 'Admin';
  static const String companyData = 'Company_Data';
  static const String templates = 'templates';
  static const String createKnowledge = 'Create_Knowledge';
  static const String creatingTask = 'Creating_Task';
  static const String employeesRequest = 'Employees_Request';
  static const String userRequests = 'User_Requests';
  static const String requestServices = 'RequestServices';

  /// Sub-collection of `{baseUri}/Modules/settings` holding one document per
  /// feedback submission from the comments-and-feedback screen.
  ///
  /// Added 13/8/2026: that screen had no persistence of any kind — the submit
  /// button collected three text bodies and dropped them. New collection, so
  /// it needs a matching Firestore security rule before it will accept writes.
  static const String appFeedback = 'App_Feedback';

  /// Sub-collection of `{baseUri}/Modules/roles` holding the inquiry and
  /// comment thread of the employee change requests — one document per
  /// comment, tagged with the `Request_Id` it belongs to.
  ///
  /// Added 23/8/2026 for the inquiries-and-comments block on the request
  /// details screen. New collection, so it needs a matching Firestore security
  /// rule before it will accept writes.
  static const String employeesRequestComments = 'Employees_Request_Comments';

  /// Note the leading slash — preserved from the original call sites.
  static const String requests = '/Requests';

  /// Note the leading slash — preserved from the original call sites.
  static const String wrongEmployeesProfile = '/Wrong_Employees_Profile';

  /// Note the spaces — preserved from the original call sites.
  static const String qiyasControlChampions = 'Qiyas Control Champions';

  /// Note the spaces — preserved from the original call sites.
  static const String qiyasEvidenceSubmissions = 'Qiyas Evidence Submissions';
}
