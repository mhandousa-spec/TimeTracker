/// ************************* FILE INFO ************************* ///
/// File Name: grc_module_notification_service.dart
/// Module:    GRC / Module
/// Purpose:   Every notification the GRC **Module** section can raise, as
///            intent-named methods. Cubits and UI must NOT build a
///            NotificationModelSystem or touch FirestoreNotificationService
///            directly — they call this service.
/// Author: Knowticed Plus team
/// Created At: 13/9/2026
///
/// Follows services_notification_service.dart, the reference implementation:
/// nothing here is a raw string. The event comes from [GrcNotificationEvent],
/// the landing page from [GrcNotificationPage], and every placeholder from
/// [TemplateVariable]. `sendEvent` asserts in debug builds that no placeholder
/// the template needs was forgotten.
///
/// The bilingual copy itself lives in the event enum (transcribed from
/// "Knowticed Plus — Notification & Validation" §2.0 GRC) and, at runtime, in
/// `notification_templates/grc_<key>` where an admin may have edited it. This
/// file decides only WHEN an event fires and WHO receives it.
///
/// AUDIENCE IS THE CALLER'S JOB — every method takes its recipients, matching
/// database_notification_service.dart. Resolving "the module's owners" or "GRC
/// admins" needs data this layer does not have.
///
/// SCOPE: the eleven Module-section events. The document also specifies ~74
/// Policy / Control / Champion / Owner events, already present in the enum and
/// still unwired; they belong in sibling services under their own features.
library;

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class GrcModuleNotificationService {
  GrcModuleNotificationService._();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Trigger: Module Created.
  static Future<int> moduleCreated({
    required String actorEmail,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.moduleCreated,
        pageKey: GrcNotificationPage.grcModules.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Trigger: Module Updated/Edited.
  static Future<int> moduleUpdated({
    required String actorEmail,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.moduleUpdatedEdited,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Trigger: Module Deleted — the module moved to Removed Modules.
  static Future<int> moduleDeleted({
    required String actorEmail,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.moduleDeleted,
        pageKey: GrcNotificationPage.grcModules.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Trigger: Module Restored.
  static Future<int> moduleRestored({
    required String actorEmail,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.moduleRestored,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
        },
      );

  // ── Status ───────────────────────────────────────────────────────────────

  /// Trigger: Module Status Changed — Activated / Deactivated.
  ///
  /// One method rather than two: the call site always has the new status as a
  /// bool, and splitting it invites picking the wrong one.
  static Future<int> moduleStatusChanged({
    required String actorEmail,
    required String moduleName,
    required bool isNowActive,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: isNowActive
            ? GrcNotificationEvent.moduleStatusChangedActivated
            : GrcNotificationEvent.moduleStatusChangedDeactivated,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
        },
      );

  // ── Ownership ────────────────────────────────────────────────────────────

  /// Trigger: Module Owner Assigned. Second person ("You have been assigned"),
  /// so this goes to the NEW owner alone.
  static Future<int> ownerAssigned({
    required String actorEmail,
    required String moduleName,
    required Iterable<String> newOwnerEmails,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.moduleOwnerAssigned,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: newOwnerEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Trigger: Module Owner Changed — third person, naming the new owner, so it
  /// suits everyone who is NOT the new owner: the previous owner(s) and admins.
  /// Pair it with [ownerAssigned] for the incoming owner.
  static Future<int> ownerChanged({
    required String actorEmail,
    required String moduleName,
    required String newOwnerName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.moduleOwnerChanged,
        pageKey: GrcNotificationPage.grcPreviousModuleOwners.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
          TemplateVariable.newOwnerName: newOwnerName,
        },
      );

  // ── Activation date ──────────────────────────────────────────────────────

  /// Trigger: Activation Date Updated. [oldDate] / [newDate] are already
  /// formatted for display — this layer does not know the viewer's locale.
  static Future<int> activationDateUpdated({
    required String actorEmail,
    required String moduleName,
    required String oldDate,
    required String newDate,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.activationDateUpdated,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
          TemplateVariable.oldDate: oldDate,
          TemplateVariable.newDate: newDate,
        },
      );

  /// Trigger: Activation Date Today.
  ///
  /// NOT fired from the UI — nothing opens the app on the right morning. This
  /// needs a scheduled job (or the calendar derivation) to raise it; the method
  /// is here so that job has a single place to call.
  static Future<int> activationDateToday({
    required String actorEmail,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.activationDateToday,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
        },
      );

  // ── Department ───────────────────────────────────────────────────────────

  /// Trigger: Module Removed from Department — the owning department changed,
  /// so the OLD department's people lose it. Send to them, not the new ones.
  static Future<int> removedFromDepartment({
    required String actorEmail,
    required String moduleName,
    required String departmentName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.moduleRemovedFromDepartment,
        pageKey: GrcNotificationPage.grcModules.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
          TemplateVariable.departmentName: departmentName,
        },
      );
}
