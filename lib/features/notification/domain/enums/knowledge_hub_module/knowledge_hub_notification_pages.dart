/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_notification_pages.dart
/// Module:    Knowledge Hub
/// Purpose:   Target pages a Knowledge Hub notification can navigate to
///            (Firestore field `name_of_page`).
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
///
/// Pattern: one `<module>_module/` folder per module holding every enum that
/// module owns (events + pages) — mirrors
/// `services_module/services_notification_pages.dart`.
///
/// Knowledge Hub was the last module still writing its landing page as a raw
/// literal: `'name_of_page': 'ViewKnowledgeHub'` appeared inline in
/// `approvals_cubit.part.1.dart` and `create_knowledge_cubit.part.1.dart`,
/// so an approval notification and a submission notification both dropped the
/// reader on the module's home list regardless of what the notification was
/// about. Each event now names the screen that can actually action it.
///
/// ⚠️ RULE: never write a page name as a raw string. Always use this enum.
///
/// ⚠️ [key] is stored in Firestore. Renaming a live value orphans the
/// `name_of_page` of every notification already written with it.

enum KnowledgeHubNotificationPage {
  /// The module home / published-documents list (K2).
  viewKnowledgeHub('ViewKnowledgeHub'),

  /// A single published document with its comments thread (K3).
  viewKnowledgeDetails('ViewKnowledgeDetails'),

  /// The author's own submissions list (K4).
  submissions('Submissions'),

  /// One submission with its status history (K5).
  submissionDetails('SubmissionDetails'),

  /// The approver's queue (K6) — where a review request is actioned.
  approvals('Approvals'),

  /// One document open for approve / reject / return-for-revision (K7).
  approvalsDetails('ApprovalsDetails');

  const KnowledgeHubNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  static KnowledgeHubNotificationPage? fromKey(String key) {
    for (final KnowledgeHubNotificationPage p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
