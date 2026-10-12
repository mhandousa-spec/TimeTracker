/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: database_notification_service.dart
/// Purpose: Notifications raised by the Database Management module.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// ************************* FILE INFO ************************* ///
/// File Name: database_notification_service.dart
/// Purpose: ALL thirteen notifications the Database Management module can
///          raise — the §1.7 table of "Knowticed Plus — Notification &
///          Validation" — behind one intent-named method each.
///
/// This is the Database module's notification service. Same shape as
/// `AccountStatusNotificationService` (User Access) and the
/// `ServicesNotificationService` its header refers to: static methods, no raw
/// module / event / placeholder strings, everything delegated to
/// [AppNotificationSender].
///
/// ─── WHY THE MESSAGES ARE NOT IN THIS FILE ───────────────────────────
/// They are in `notification/domain/enums/database_module/
/// database_events.dart`, and at send time the Firestore template
/// `database_<key>` wins over the enum. So an admin editing the text in
/// Notification Control changes what these methods send, and this file never
/// needs touching for a wording change. That is the whole point of the
/// catalog; a service that formatted its own strings would put every database
/// notification outside the admin's reach, which is the bug that
/// `account_status_notification_service.dart` was rewritten to fix.
///
/// ─── WHY IT TAKES PLAIN STRINGS ──────────────────────────────────────
/// Not one parameter here is a database-feature type. The notification feature
/// must not import `DatabaseAccessGrant` / `DatabaseEntity` / `DatabaseMember`
/// — a feature raises its own notifications, so the arrow points
/// database → notification and never back. The database side of the wiring
/// (which grant changed, who was added, who was dropped, who the actor is)
/// lives in `features/database/db1_create_database/data/repository/
/// database_notification_dispatcher.dart`, which speaks both languages and is
/// the only thing that calls this class.
///
/// ─── LANGUAGE ────────────────────────────────────────────────────────
/// `isArabic` defaults to false, matching the User Access service. One call
/// sends ONE language, so a notification going to several people goes out in
/// one language; there is no per-recipient saved language preference to read
/// yet. Pass the receiver's preference at the call site once there is one.
///
/// ─── THE TWO EVENTS WITH NO CALL SITE ────────────────────────────────
/// [accessExpired] and [commentAdded] are complete and callable but nothing
/// invokes them today, deliberately:
///
///   • accessExpired is time-driven. Nothing happens in the app on the day a
///     grant's `end_date` passes — no screen is open, no write occurs — so the
///     only honest trigger is a scheduled job (Cloud Function / cron) reading
///     grants whose window just closed. Calling it from a screen would send it
///     to whoever happened to open the module that day and to nobody else. The
///     calendar covers the same date visually in the meantime; see
///     `DatabaseCalendarEvent.accessExpired`.
///   • commentAdded waits on Comments, which is unbuilt (the Figma section
///     covering it has no screens yet).
///
/// Both are kept here rather than added later so the file matches the spec
/// table one-for-one and the gap is documented instead of silent.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import 'package:knowticed_plus/features/notification/domain/enums/database_module/database_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/database_module/database_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

abstract final class DatabaseNotificationService {
  const DatabaseNotificationService._();

  /// Used when no human triggered the notification — the same sentinel
  /// `AccountStatusNotificationService` uses, so system-sent notifications are
  /// attributable to one address across modules.
  static const String systemSender = 'system@company.com';

  // ═══════════════════════════════════════════════════════════
  // Formatting helpers
  // ═══════════════════════════════════════════════════════════

  /// What `{{tableName}}` renders as on a DATABASE-level grant.
  ///
  /// The spec's access bodies all read "... access to {{databaseName}} /
  /// {{tableName}}", and a grant written by the create wizard or by the
  /// database Access screen covers the whole database — there is no one table
  /// to name. An empty string would render "HR Database / " with a dangling
  /// slash, which reads as a bug; this renders "HR Database / All Tables",
  /// which is what the grant actually gives.
  ///
  /// It is NOT a claim about Viewable Fields. Field-level restriction lives on
  /// a table grant (`DatabaseAccessGrant.viewableFields`) and has its own
  /// event, [viewableFieldsUpdated].
  static String allTablesLabel({required bool isArabic}) =>
      isArabic ? 'كل الجداول' : 'All Tables';

  /// Dates in these bodies are formatted in ONE place so a grant's window
  /// prints identically in the notification, on the calendar card and in the
  /// Access table — `DateTimeHelper.formatDateTimeMMMDDYYYY` is what the other
  /// two already use.
  ///
  /// A null date renders as an em dash rather than the literal "null". A
  /// complete grant always has both dates (`DatabaseAccessGrant.isComplete`),
  /// so this only shows up if a legacy document is missing one.
  static String _date(DateTime? value) =>
      value == null ? '—' : DateTimeHelper.formatDateTimeMMMDDYYYY(value);

  // ═══════════════════════════════════════════════════════════
  // Structural events — sent to the people who hold access
  // ═══════════════════════════════════════════════════════════

  /// Trigger: Database Created. Spec §1.7 row 1.
  ///
  /// Goes to everyone the wizard granted access to, minus the creator — the
  /// body is written in the third person ("{{employeeName}} has created ...")
  /// so sending it back to the actor would tell them what they just did.
  /// Filtering that out is the dispatcher's job, not this method's.
  static Future<int> databaseCreated({
    required String actorEmail,
    required String actorName,
    required String databaseName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.databaseCreated,
        pageKey: DatabaseNotificationPage.databaseBuilderPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.employeeName: actorName,
          TemplateVariable.databaseName: databaseName,
        },
      );

  /// Trigger: Table Created. Spec §1.7 row 2.
  static Future<int> tableCreated({
    required String actorEmail,
    required String actorName,
    required String databaseName,
    required String tableName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.tableCreated,
        pageKey: DatabaseNotificationPage.databaseDetailsPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.employeeName: actorName,
          TemplateVariable.tableName: tableName,
          TemplateVariable.databaseName: databaseName,
        },
      );

  /// Trigger: Table Updated. Spec §1.7 row 3 — name, description or metadata.
  static Future<int> tableUpdated({
    required String actorEmail,
    required String actorName,
    required String tableName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.tableUpdated,
        pageKey: DatabaseNotificationPage.databaseDetailsPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.employeeName: actorName,
          TemplateVariable.tableName: tableName,
        },
      );

  /// Trigger: Table Structure Updated. Spec §1.7 row 11.
  ///
  /// Distinct from [tableUpdated] on purpose: this is the columns changing,
  /// which can affect how existing data reads, where that one is a rename.
  /// Both can fire for the same save; the dispatcher decides which apply.
  static Future<int> tableStructureUpdated({
    required String actorEmail,
    required String tableName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.tableStructureUpdated,
        pageKey: DatabaseNotificationPage.databaseDetailsPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.tableName: tableName,
        },
      );

  /// Trigger: Column Added. Spec §1.7 row 12.
  ///
  /// One notification per new column, because the body names the column. A save
  /// that added three columns sends three — which is what the spec's singular
  /// wording asks for, and is why the dispatcher caps how many it will send in
  /// one go.
  static Future<int> columnAdded({
    required String actorEmail,
    required String columnName,
    required String tableName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.columnAdded,
        pageKey: DatabaseNotificationPage.databaseDetailsPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.columnName: columnName,
          TemplateVariable.tableName: tableName,
        },
      );

  /// Trigger: Table Deleted. Spec §1.7 row 13.
  ///
  /// Sent to the people who HELD access, read before the delete — after it the
  /// grants are gone and there is nobody left to tell. `isPinned` because the
  /// body says the action is irreversible and names the administrator to
  /// contact: it is the one database notification the recipient may need to
  /// find again after the fact.
  static Future<int> tableDeleted({
    required String actorEmail,
    required String databaseName,
    required String tableName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.tableDeleted,
        pageKey: DatabaseNotificationPage.databaseDetailsPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        isPinned: true,
        variables: <TemplateVariable, String>{
          TemplateVariable.tableName: tableName,
          TemplateVariable.databaseName: databaseName,
        },
      );

  // ═══════════════════════════════════════════════════════════
  // Access events — sent to the affected person
  // ═══════════════════════════════════════════════════════════

  /// Trigger: Access Granted. Spec §1.7 row 4.
  ///
  /// ONE RECIPIENT, not a list. The body is second person ("You have been
  /// granted {{permissionLevel}} access ... from {{startDate}} to
  /// {{endDate}}") and every value in it is that person's own grant, so a
  /// broadcast would tell nine people about the tenth's window. A save that
  /// grants access to nine people sends nine of these, each with its own
  /// permission level and dates.
  ///
  /// [tableName] takes [allTablesLabel] on a database-level grant.
  static Future<bool> accessGranted({
    required String actorEmail,
    required String recipientEmail,
    required String databaseName,
    required String tableName,
    required String permissionLabel,
    required DateTime? startDate,
    required DateTime? endDate,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEvent(
        event: DatabaseNotificationEvent.accessGranted,
        pageKey: DatabaseNotificationPage.databaseAccessPage.key,
        senderEmail: actorEmail,
        receiverEmail: recipientEmail,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.permissionLevel: permissionLabel,
          TemplateVariable.databaseName: databaseName,
          TemplateVariable.tableName: tableName,
          TemplateVariable.startDate: _date(startDate),
          TemplateVariable.endDate: _date(endDate),
        },
      );

  /// Trigger: Access Updated. Spec §1.7 row 5 — the level or the window moved
  /// on a grant the person already had.
  static Future<bool> accessUpdated({
    required String actorEmail,
    required String recipientEmail,
    required String databaseName,
    required String tableName,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEvent(
        event: DatabaseNotificationEvent.accessUpdated,
        pageKey: DatabaseNotificationPage.databaseAccessPage.key,
        senderEmail: actorEmail,
        receiverEmail: recipientEmail,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.databaseName: databaseName,
          TemplateVariable.tableName: tableName,
        },
      );

  /// Trigger: Access Revoked. Spec §1.7 row 6.
  ///
  /// Pinned: the recipient has lost access to data they may be mid-task on, and
  /// the body names who did it, which is what they will look for afterwards.
  static Future<bool> accessRevoked({
    required String actorEmail,
    required String actorName,
    required String recipientEmail,
    required String databaseName,
    required String tableName,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEvent(
        event: DatabaseNotificationEvent.accessRevoked,
        pageKey: DatabaseNotificationPage.databaseAccessPage.key,
        senderEmail: actorEmail,
        receiverEmail: recipientEmail,
        isArabic: isArabic,
        isPinned: true,
        variables: <TemplateVariable, String>{
          TemplateVariable.databaseName: databaseName,
          TemplateVariable.tableName: tableName,
          TemplateVariable.employeeName: actorName,
        },
      );

  /// Trigger: Access Expired. Spec §1.7 row 7.
  ///
  /// NO CALL SITE YET — see the header. Sent from [systemSender] because the
  /// expiry is the clock's doing, not a person's: the body says access "has
  /// been automatically terminated", so attributing it to whoever granted it
  /// months ago would misrepresent what happened.
  static Future<bool> accessExpired({
    required String recipientEmail,
    required String databaseName,
    required String tableName,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEvent(
        event: DatabaseNotificationEvent.accessExpired,
        pageKey: DatabaseNotificationPage.databaseAccessPage.key,
        senderEmail: systemSender,
        receiverEmail: recipientEmail,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.databaseName: databaseName,
          TemplateVariable.tableName: tableName,
        },
      );

  /// Trigger: Viewable Fields Updated. Spec §1.7 row 8.
  ///
  /// Raised when a table grant's `viewable_fields` changed — INCLUDING when it
  /// changed to empty, which widens the grant back to every field rather than
  /// narrowing it to none. See `DatabaseAccessGrant.viewableFields`; the body
  /// says the scope "has been adjusted", which is true in both directions.
  static Future<int> viewableFieldsUpdated({
    required String actorEmail,
    required String tableName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.viewableFieldsUpdated,
        pageKey: DatabaseNotificationPage.tableAccessPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.tableName: tableName,
        },
      );

  /// Trigger: Comment Added. Spec §1.7 row 9.
  ///
  /// NO CALL SITE YET — Comments is unbuilt. See the header.
  static Future<int> commentAdded({
    required String actorEmail,
    required String actorName,
    required String databaseName,
    required String tableName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: DatabaseNotificationEvent.commentAdded,
        pageKey: DatabaseNotificationPage.databaseDetailsPage.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.employeeName: actorName,
          TemplateVariable.databaseName: databaseName,
          TemplateVariable.tableName: tableName,
        },
      );

  /// Trigger: Bulk Access Update. Spec §1.7 row 10.
  ///
  /// THE SUMMARY, NOT THE NOTIFICATION EACH PERSON GETS. Its own body says so:
  /// "Affected users will receive individual notifications reflecting their
  /// updated access rights" — which is exactly what [accessGranted],
  /// [accessUpdated] and [accessRevoked] already sent. So this goes to the
  /// person who ran the change, as their receipt for it, and never to the
  /// affected list; sending it there too would be the fourteenth notification
  /// telling nine people what the previous thirteen just did.
  static Future<bool> bulkAccessUpdate({
    required String actorEmail,
    required String actorName,
    required String databaseName,
    required String tableName,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEvent(
        event: DatabaseNotificationEvent.bulkAccessUpdate,
        pageKey: DatabaseNotificationPage.databaseAccessPage.key,
        senderEmail: actorEmail,
        receiverEmail: actorEmail,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.databaseName: databaseName,
          TemplateVariable.tableName: tableName,
          TemplateVariable.employeeName: actorName,
        },
      );

  /// Every module this service belongs to, for readers checking the key it
  /// writes into `Name_of_module`. The events carry it; this is here so a
  /// reader does not have to open the enum to find out.
  static AppModule get module => AppModule.database;
}
