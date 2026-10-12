// Module: knowledge_hub_module / notifications/knowledge_hub_notification_events.dart
//
//*************************** FILE INFO ****************************///
// File Name: knowledge_hub_notification_events.dart
// Purpose: RETIRED 1/9/2026 — this file is intentionally empty of code.
// Author: Knowticed Plus team
//
// ─── WHY IT IS EMPTY ─────────────────────────────────────────────────────
//
// This file used to declare a SECOND `KnowledgeHubNotificationEvent` enum,
// generated from an older pass over the specification document. The
// canonical one lives with every other module's:
//
//     lib/features/notification/domain/enums/knowledge_hub_module/
//         knowledge_hub_events.dart
//
// Only that one implements `NotificationEvent`, and only that one is
// registered in `NotificationCatalog`. `NotificationCatalog` is what the
// Notification Control screen lists, what `NotificationTemplateService` uses
// to build a default template, and what "Reset to default" restores.
//
// The two enums did NOT agree on their keys, and since the key is half of
// the Firestore template id (`<module>_<key>`), the difference was not
// cosmetic — sending against the copy in this file would have written to
// template ids no template document exists for, and
// `AppNotificationSender.sendFromTemplate` would have logged
// "no template and no catalog default" and sent nothing:
//
//     this file (retired)          notification/domain/enums (canonical)
//     ─────────────────────        ───────────────────────────────────────
//     document_expiring_soon   →   document_expiring_in_14_days
//     inquiry_submitted        →   inquiry_or_comment_submitted
//     review_reminder          →   review_reminder_issued
//     review_request_assigned  →   review_request_received
//
// Keeping two same-named enums one import away from each other is a trap
// with no upside, so the declaration is gone rather than deprecated: an
// `@Deprecated` enum still compiles at a call site and still sends to the
// wrong template id.
//
// The file itself is kept (rather than deleted) so this explanation sits
// where anyone following an old import or an old code review comment will
// look for it.
//
// ⚠️ Use `KnowledgeHubNotificationEvent` from
// `features/notification/domain/enums/knowledge_hub_module/
// knowledge_hub_events.dart`, and prefer the intent-named methods on
// `KnowledgeHubNotificationService` over touching the enum at all.
