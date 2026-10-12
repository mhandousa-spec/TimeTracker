/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: grc_notification_pages.dart
/// Module:    GRC
/// Purpose:   Target pages a GRC notification can navigate to (Firestore
///            field `name_of_page`).
/// Author: Knowticed Plus team
/// Created at: 13/9/2026
///
/// Pattern: one `<module>_module/` folder per module holding every enum that
/// module owns (events + pages) — mirrors
/// `services_module/services_notification_pages.dart` and
/// `knowledge_hub_module/knowledge_hub_notification_pages.dart`.
///
/// ⚠️ RULE: never write a page name as a raw string. Always use this enum.
///
/// ⚠️ [key] is stored in Firestore. Renaming a live value orphans the
/// `name_of_page` of every notification already written with it.

enum GrcNotificationPage {
  /// The module list — Governance, Risk, and Compliance home.
  grcModules('GrcModules'),

  /// One module's detail page (policies / champions / owners tabs).
  grcModuleDetails('GrcModuleDetails'),

  /// The previous-owners history of a single module.
  grcPreviousModuleOwners('GrcPreviousModuleOwners'),

  /// A single policy's details page — where every policy-level notification
  /// should land when tapped.
  grcPolicyDetails('GrcPolicyDetails'),

  /// The Policy Weight Issue screen, for the two weight-issue events.
  grcPolicyWeightIssue('GrcPolicyWeightIssue'),

  // ADDED 16/9/2026 — the Control / Champion / Owner / Evidence groups.

  /// A single control's details page.
  grcControlDetails('GrcControlDetails'),

  /// The Control Weight Issue screen, for the two control weight-issue events.
  grcControlWeightIssue('GrcControlWeightIssue'),

  /// A Control Champion's details (assigned controls).
  grcControlChampionDetails('GrcControlChampionDetails'),

  /// A Control Owner's details (assigned controls).
  grcControlOwnerDetails('GrcControlOwnerDetails'),

  /// The module's Requests list (reassignment requests awaiting a decision).
  grcRequests('GrcRequests'),

  /// A single reassignment request.
  grcRequestDetails('GrcRequestDetails'),

  /// The champion's Assignment Controls (evidence submission) list.
  grcAssignmentControls('GrcAssignmentControls'),

  /// The department manager's Approvals list.
  grcApprovals('GrcApprovals'),

  /// The control owner's My Audits list (final review + score).
  grcMyAudits('GrcMyAudits');

  const GrcNotificationPage(this.key);

  /// Stored verbatim in Firestore as `name_of_page`.
  final String key;

  static GrcNotificationPage? fromKey(String key) {
    for (final GrcNotificationPage page in values) {
      if (page.key == key) return page;
    }
    return null;
  }
}
