/// Module: knowledge_hub_module / notifications/knowledge_hub_notification_service.dart
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_notification_service.dart
/// Purpose:   ALL notifications sent by the Knowledge Hub module, as
///            intent-named methods. UI pages, widgets and cubits must NOT
///            build `NotificationModelSystem`, call `NotificationServiceApp`
///            or write to the `Notifications` collection directly — they call
///            this service.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 1/9/2026 — RE-ENABLED. See the note below.
///
/// ─── WHY THIS FILE WAS DEAD, AND WHAT REPLACED IT ────────────────────────
///
/// Every method here used to `return false` unconditionally. The header said
/// the module could not be restored because it needed
/// `core/notifications/enums/notification_module.dart`, which this app does
/// not have. That file was replaced long ago by `core/enums/app_module.dart`
/// (`AppModule.knowledgeHub`) — the stub was simply never revisited, so
/// Knowledge Hub was the one module whose notifications were switched off at
/// the source.
///
/// With the service inert, two screens had grown their own private
/// notification code instead: `approvals_cubit.part.1.dart` and
/// `create_knowledge_cubit.part.1.dart` each hand-built a title and body in
/// Dart, pushed straight through `NotificationServiceApp.sendNotification`,
/// and wrote a raw map to Firestore. Those paths were wrong in four ways that
/// no test would catch:
///
///   1. `'Name_of_module': 'knowledgeHub'` — camelCase. Every AppModule key is
///      snake_case (`knowledge_hub`), and `NotificationRouting
///      .moduleForStoredKey` resolves the module from that string, so tapping
///      one of those cards fell through to `default: return null` and showed
///      "Error occurred".
///   2. Only ONE language was stored, chosen by the SENDER's locale. An
///      approver working in Arabic sent Arabic text to an English reader with
///      no way back — the exact bug `notification_data_model.dart` documents
///      and that `AppNotificationSender` fixed by storing both renderings.
///   3. The wording was invented locally ("Approval Granted", "Review in
///      Progress") rather than taken from the spec, so it did not match
///      §1.1 of "Knowticed Plus — Notification & Validation".
///   4. It bypassed `notification_templates` entirely: an admin who edited
///      the Knowledge Hub text — or switched the notification OFF — in
///      Notification Control had no effect on it whatsoever.
///
/// Everything now goes through `AppNotificationSender.sendEvent`, so the
/// module gets the template lookup, the enabled/disabled master switch, the
/// per-channel push flag, both language renderings and the FCM push for free,
/// and behaves exactly like Services, Role Management and the rest.
///
/// ─── BILINGUAL DOCUMENT NAMES ────────────────────────────────────────────
///
/// A Knowledge Hub document has two names (`nameEnglish` / `nameArabic`), and
/// a notification stores two renderings. The English body must interpolate the
/// English name and the Arabic body the Arabic one — so every method takes
/// both and passes the Arabic through `variablesAr`. Callers that only have
/// one name pass it twice; the old ' / ' concatenation is gone.
///
/// Nothing here is a raw string: the event comes from
/// `KnowledgeHubNotificationEvent`, the landing page from
/// `KnowledgeHubNotificationPage`, and every placeholder from
/// `TemplateVariable`.

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub_module/knowledge_hub_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub_module/knowledge_hub_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class KnowledgeHubNotificationService {
  KnowledgeHubNotificationService._();

  /// Kept so older call sites that guard on it still compile. The module is
  /// live again, so this is `true`.
  static const bool enabled = true;

  // ───────────────────────────────────────────────────────────────────────
  //  Shared plumbing
  // ───────────────────────────────────────────────────────────────────────

  /// The one place a Knowledge Hub event is actually dispatched.
  ///
  /// [documentNameEn] / [documentNameAr] are substituted into the English and
  /// Arabic renderings respectively. [extra] / [extraAr] carry any additional
  /// placeholder the event declares (only `endDate`, today).
  static Future<bool> _send({
    required KnowledgeHubNotificationEvent event,
    required KnowledgeHubNotificationPage page,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentNameEn,
    required String documentNameAr,
    Map<TemplateVariable, String> extra = const {},
    Map<TemplateVariable, String> extraAr = const {},
    bool isPinned = false,
  }) {
    return AppNotificationSender.sendEvent(
      event: event,
      pageKey: page.key,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      variables: <TemplateVariable, String>{
        TemplateVariable.documentName: documentNameEn,
        ...extra,
      },
      variablesAr: <TemplateVariable, String>{
        TemplateVariable.documentName:
            documentNameAr.isEmpty ? documentNameEn : documentNameAr,
        ...(extraAr.isEmpty ? extra : extraAr),
      },
      isPinned: isPinned,
    );
  }

  /// Same event, many recipients — returns how many were sent. Recipients are
  /// de-duplicated and empty addresses dropped before the fan-out.
  static Future<int> _sendToAll({
    required KnowledgeHubNotificationEvent event,
    required KnowledgeHubNotificationPage page,
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required bool isArabic,
    required String documentNameEn,
    required String documentNameAr,
    Map<TemplateVariable, String> extra = const {},
    Map<TemplateVariable, String> extraAr = const {},
  }) {
    return AppNotificationSender.sendEventToAll(
      event: event,
      pageKey: page.key,
      senderEmail: senderEmail,
      receiverEmails: receiverEmails
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty),
      isArabic: isArabic,
      variables: <TemplateVariable, String>{
        TemplateVariable.documentName: documentNameEn,
        ...extra,
      },
      variablesAr: <TemplateVariable, String>{
        TemplateVariable.documentName:
            documentNameAr.isEmpty ? documentNameEn : documentNameAr,
        ...(extraAr.isEmpty ? extra : extraAr),
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  //  §1.1 — Submission & review cycle
  // ───────────────────────────────────────────────────────────────────────

  /// Confirmation to the AUTHOR that their document reached the review queue.
  /// Spec: "Document Submitted" → "Document Submitted for Review".
  /// Template: knowledge_hub_document_submitted → page: SubmissionDetails
  static Future<bool> notifyAuthorOfSubmission({
    required String senderEmail,
    required String authorEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.documentSubmitted,
      page: KnowledgeHubNotificationPage.submissionDetails,
      senderEmail: senderEmail,
      receiverEmail: authorEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  /// Tell the APPROVER a review has been assigned to them.
  /// Spec: "Review Request Received" → "Review Request Assigned to You".
  /// Template: knowledge_hub_review_request_received → page: ApprovalsDetails
  static Future<bool> notifyApproverOfReviewRequest({
    required String senderEmail,
    required String approverEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.reviewRequestReceived,
      page: KnowledgeHubNotificationPage.approvalsDetails,
      senderEmail: senderEmail,
      receiverEmail: approverEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  /// Several approvers share one queue — notify all of them at once.
  static Future<int> notifyApproversOfReviewRequest({
    required String senderEmail,
    required Iterable<String> approverEmails,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _sendToAll(
      event: KnowledgeHubNotificationEvent.reviewRequestReceived,
      page: KnowledgeHubNotificationPage.approvalsDetails,
      senderEmail: senderEmail,
      receiverEmails: approverEmails,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  /// A document is still sitting unreviewed past the reminder threshold.
  /// Spec: "Review Reminder Issued" → "Pending Review — Reminder
  /// Notification". Raised by `KnowledgeHubNotificationScheduler`, not by a
  /// button — nothing happens at the moment it becomes due.
  ///
  /// [receiverEmail] rather than `approverEmail` because the spec's body is
  /// written to the AUTHOR ("The assigned authority has been notified and is
  /// expected to take the necessary action promptly"), while the same event
  /// is also what you would send an approver to chase them. Both are valid
  /// recipients; the caller decides which.
  /// Template: knowledge_hub_review_reminder_issued → page: SubmissionDetails
  static Future<bool> remindOfPendingReview({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentNameEn,
    required String documentNameAr,
    KnowledgeHubNotificationPage page =
        KnowledgeHubNotificationPage.submissionDetails,
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.reviewReminderIssued,
      page: page,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  //  §1.1 — Approval outcome
  // ───────────────────────────────────────────────────────────────────────

  /// Tell the AUTHOR their document was approved or declined.
  ///
  /// One method rather than two because the two branches are the same
  /// notification with the opposite outcome — the same shape as
  /// `ServicesNotificationService.notifyRequesterOfDecision`.
  /// Template: knowledge_hub_document_approved / _document_rejected
  ///           → page: SubmissionDetails
  static Future<bool> notifyAuthorOfDecision({
    required bool approved,
    required String approverEmail,
    required String authorEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _send(
      event: approved
          ? KnowledgeHubNotificationEvent.documentApproved
          : KnowledgeHubNotificationEvent.documentRejected,
      page: KnowledgeHubNotificationPage.submissionDetails,
      senderEmail: approverEmail,
      receiverEmail: authorEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  /// Tell the AUTHOR the document came back with reviewer comments and needs
  /// changes before it can be resubmitted.
  ///
  /// Distinct from a rejection: a rejection ends the request, a revision
  /// request expects the same document back.
  /// Template: knowledge_hub_revision_requested → page: SubmissionDetails
  static Future<bool> notifyAuthorOfRevisionRequest({
    required String senderEmail,
    required String authorEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.revisionRequested,
      page: KnowledgeHubNotificationPage.submissionDetails,
      senderEmail: senderEmail,
      receiverEmail: authorEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  //  §1.1 — Publication lifecycle
  // ───────────────────────────────────────────────────────────────────────

  /// The document is live. Sent to the author, and to the audience when the
  /// caller can resolve one.
  /// Template: knowledge_hub_document_published → page: ViewKnowledgeDetails
  static Future<bool> notifyOfPublication({
    required String senderEmail,
    required String receiverEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.documentPublished,
      page: KnowledgeHubNotificationPage.viewKnowledgeDetails,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  /// Publication announced to a whole audience (the owning department, or the
  /// limited-availability list). Returns how many were sent.
  static Future<int> announcePublication({
    required String senderEmail,
    required Iterable<String> audienceEmails,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _sendToAll(
      event: KnowledgeHubNotificationEvent.documentPublished,
      page: KnowledgeHubNotificationPage.viewKnowledgeDetails,
      senderEmail: senderEmail,
      receiverEmails: audienceEmails,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  /// The document was withdrawn from circulation.
  /// Template: knowledge_hub_document_removed → page: SubmissionDetails
  static Future<bool> notifyOfRemoval({
    required String senderEmail,
    required String receiverEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.documentRemoved,
      page: KnowledgeHubNotificationPage.submissionDetails,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  /// 14-day expiry warning. [endDateEn] / [endDateAr] are already-formatted
  /// dates — the service does not format, so the caller keeps control of the
  /// calendar and locale it formats with.
  /// Template: knowledge_hub_document_expiring_in_14_days
  ///           → page: SubmissionDetails
  static Future<bool> notifyOwnerOfUpcomingExpiry({
    required String senderEmail,
    required String ownerEmail,
    required String documentNameEn,
    required String documentNameAr,
    required String endDateEn,
    required bool isArabic,
    String endDateAr = '',
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.documentExpiringIn14Days,
      page: KnowledgeHubNotificationPage.submissionDetails,
      senderEmail: senderEmail,
      receiverEmail: ownerEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
      extra: <TemplateVariable, String>{TemplateVariable.endDate: endDateEn},
      extraAr: <TemplateVariable, String>{
        TemplateVariable.endDate: endDateAr.isEmpty ? endDateEn : endDateAr,
      },
    );
  }

  /// The validity period ended and the document has been archived.
  /// Template: knowledge_hub_document_archived → page: SubmissionDetails
  static Future<bool> notifyOwnerOfArchival({
    required String senderEmail,
    required String ownerEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    return _send(
      event: KnowledgeHubNotificationEvent.documentArchived,
      page: KnowledgeHubNotificationPage.submissionDetails,
      senderEmail: senderEmail,
      receiverEmail: ownerEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  //  §1.1 — Engagement
  // ───────────────────────────────────────────────────────────────────────

  /// Somebody asked a question or left a comment on a document — tell its
  /// owner. Never sent to the commenter themselves; the caller is expected to
  /// drop the self-notification, and [notifyOwnerOfInquiry] guards it too.
  /// Template: knowledge_hub_inquiry_or_comment_submitted
  ///           → page: ViewKnowledgeDetails
  static Future<bool> notifyOwnerOfInquiry({
    required String commenterEmail,
    required String ownerEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) {
    // Commenting on your own document should not notify you about it.
    if (ownerEmail.trim().toLowerCase() ==
        commenterEmail.trim().toLowerCase()) {
      return Future<bool>.value(false);
    }
    return _send(
      event: KnowledgeHubNotificationEvent.inquiryOrCommentSubmitted,
      page: KnowledgeHubNotificationPage.viewKnowledgeDetails,
      senderEmail: commenterEmail,
      receiverEmail: ownerEmail,
      isArabic: isArabic,
      documentNameEn: documentNameEn,
      documentNameAr: documentNameAr,
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  //  Back-compat shims
  //
  //  The stub exposed these names. They are kept so any call site not yet
  //  migrated keeps compiling — but they now genuinely send, instead of
  //  returning false. New code should use the intent-named methods above.
  // ───────────────────────────────────────────────────────────────────────

  @Deprecated('Use notifyAuthorOfSubmission')
  static Future<bool> documentSubmitted({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyAuthorOfSubmission(
        senderEmail: senderEmail,
        authorEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyAuthorOfDecision(approved: true)')
  static Future<bool> documentApproved({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyAuthorOfDecision(
        approved: true,
        approverEmail: senderEmail,
        authorEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyAuthorOfDecision(approved: false)')
  static Future<bool> documentRejected({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyAuthorOfDecision(
        approved: false,
        approverEmail: senderEmail,
        authorEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyOfPublication')
  static Future<bool> documentPublished({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyOfPublication(
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyOfRemoval')
  static Future<bool> documentRemoved({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyOfRemoval(
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyOwnerOfUpcomingExpiry')
  static Future<bool> documentExpiringSoon({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    required String endDate,
    String documentNameAr = '',
  }) =>
      notifyOwnerOfUpcomingExpiry(
        senderEmail: senderEmail,
        ownerEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        endDateEn: endDate,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyOwnerOfArchival')
  static Future<bool> documentArchived({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyOwnerOfArchival(
        senderEmail: senderEmail,
        ownerEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyAuthorOfRevisionRequest')
  static Future<bool> revisionRequested({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyAuthorOfRevisionRequest(
        senderEmail: senderEmail,
        authorEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyOwnerOfInquiry')
  static Future<bool> inquirySubmitted({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyOwnerOfInquiry(
        commenterEmail: senderEmail,
        ownerEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use remindOfPendingReview')
  static Future<bool> reviewReminder({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      remindOfPendingReview(
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

  @Deprecated('Use notifyApproverOfReviewRequest')
  static Future<bool> reviewRequestAssigned({
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentName,
    String documentNameAr = '',
  }) =>
      notifyApproverOfReviewRequest(
        senderEmail: senderEmail,
        approverEmail: receiverEmail,
        documentNameEn: documentName,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );
}
