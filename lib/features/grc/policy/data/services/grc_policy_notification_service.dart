/// Module: GRC Policy
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_policy_notification_service.dart
/// Purpose: One call site per policy-level notification, so no caller builds
///          a NotificationModelSystem or touches AppNotificationSender
///          directly. The twin of GrcModuleNotificationService, for the
///          Policy & Control group of [GrcNotificationEvent].
/// Author: Knowticed Plus team
/// Created At: 14/9/2026
///
/// Nothing here is a raw string: the event carries its own EN/AR title and
/// body from [GrcNotificationEvent], and the placeholders it declares are
/// filled from [TemplateVariable]. Adding a new policy notification means
/// adding a method here, never a string at the call site.
///
/// DATE-DRIVEN EVENTS ARE NOT HERE. "14 days before…" and "…due today" are
/// not things a cubit can observe — nobody is running the app at the moment a
/// date arrives. Those live in the calendar enums
/// (grc_module_calendar_events.dart) the same way the module's do.
library;

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class GrcPolicyNotificationService {
  GrcPolicyNotificationService._();

  // ── Creation ─────────────────────────────────────────────────────────────

  /// Policy Created — "The policy {policyName} has been successfully created
  /// under the GRC module {moduleName}."
  static Future<int> policyCreated({
    required String actorEmail,
    required String policyName,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyCreated,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// New Policies Added (Bulk Upload) — one notification for the batch, not
  /// one per row, which is why it names the uploader rather than a policy.
  static Future<int> policiesBulkUploaded({
    required String actorEmail,
    required String uploadedByUserName,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.newPoliciesAddedBulkUpload,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.uploadedByUserName: uploadedByUserName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  // ── Activation dates ─────────────────────────────────────────────────────

  /// Policy Scheduled for Activation — fired when a policy is saved with a
  /// start date still in the future.
  static Future<int> policyScheduledForActivation({
    required String actorEmail,
    required String policyName,
    required String startDate,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyScheduledForActivation,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.startDate: startDate,
        },
      );

  /// Policy Activation Date Updated — the start date moved.
  static Future<int> activationDateUpdated({
    required String actorEmail,
    required String policyName,
    required String oldStartDate,
    required String newStartDate,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyActivationDateUpdated,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.oldStartDate: oldStartDate,
          TemplateVariable.newStartDate: newStartDate,
        },
      );

  /// Policy End Date Updated — the expiration date moved.
  static Future<int> expirationDateUpdated({
    required String actorEmail,
    required String policyName,
    required String oldEndDate,
    required String newEndDate,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyEndDateUpdated,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.oldEndDate: oldEndDate,
          TemplateVariable.newEndDate: newEndDate,
        },
      );

  /// Policy Expired — the policy passed its end date and is now marked
  /// expired.
  static Future<int> policyExpired({
    required String actorEmail,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyExpired,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
        },
      );

  // ── Weight ───────────────────────────────────────────────────────────────

  /// Policy Weight Updated.
  static Future<int> policyWeightUpdated({
    required String actorEmail,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyWeightUpdated,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
        },
      );

  /// Policy Weight Issue Detected / Resolved — one method, because the two
  /// are the same transition observed in opposite directions and every caller
  /// already knows which side it just crossed.
  static Future<int> policyWeightIssue({
    required String actorEmail,
    required String policyName,
    required bool isResolved,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: isResolved
            ? GrcNotificationEvent.policyWeightIssueResolved
            : GrcNotificationEvent.policyWeightIssueDetected,
        pageKey: GrcNotificationPage.grcPolicyWeightIssue.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
        },
      );

  // ── Controls ─────────────────────────────────────────────────────────────

  /// Control Added to Policy — "A new control {controlName} has been added to
  /// the policy {policyName}."
  static Future<int> controlAddedToPolicy({
    required String actorEmail,
    required String controlName,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.controlAddedToPolicy,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
        },
      );

  // ── Lifecycle (ADDED 16/9/2026) ──────────────────────────────────────────

  /// Policy Updated/Edited.
  static Future<int> policyUpdated({
    required String actorEmail,
    required String policyName,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyUpdatedEdited,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Policy Deleted — moved to the removed policies section.
  static Future<int> policyDeleted({
    required String actorEmail,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyDeleted,
        pageKey: GrcNotificationPage.grcModuleDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
        },
      );

  /// Policy Activated / Deactivated.
  static Future<int> policyStatusChanged({
    required String actorEmail,
    required String policyName,
    required bool isNowActive,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: isNowActive
            ? GrcNotificationEvent.policyActivated
            : GrcNotificationEvent.policyDeactivated,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
        },
      );

  // ── Date-driven (for a scheduled job) ────────────────────────────────────
  //
  // Not fired from the UI — see the file header. The calendar already shows
  // these on the right day (GrcPolicyCalendarEvent); these methods are the one
  // place a scheduled job should call to also push them.

  /// 14 Days Before Policy Start Date.
  static Future<int> activationIn14Days({
    required String actorEmail,
    required String policyName,
    required String startDate,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.e14DaysBeforePolicyStartDate,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.startDate: startDate,
        },
      );

  /// Policy Activation Date Today.
  static Future<int> activationToday({
    required String actorEmail,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.policyActivationDateToday,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
        },
      );

  /// 14 Days Before Policy Expiration Date.
  static Future<int> expirationIn14Days({
    required String actorEmail,
    required String policyName,
    required String endDate,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: GrcNotificationEvent.e14DaysBeforePolicyExpirationDate,
        pageKey: GrcNotificationPage.grcPolicyDetails.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.endDate: endDate,
        },
      );
}
