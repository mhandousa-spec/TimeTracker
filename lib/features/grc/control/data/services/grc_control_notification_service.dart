/// Module: GRC Control
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_control_notification_service.dart
/// Purpose: One intent-named method per control-level notification of the
///          "Policy & Control" group of [GrcNotificationEvent]. The twin of
///          GrcPolicyNotificationService for controls.
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// Nothing here is a raw string: the event carries its own EN/AR copy, the
/// landing page comes from [GrcNotificationPage], and every placeholder from
/// [TemplateVariable]. AUDIENCE IS THE CALLER'S JOB — every method takes its
/// recipients. Delivery (in-app record + FCM push) is AppNotificationSender's.
///
/// Champion / owner assignment events live in GrcAssigneeNotificationService;
/// evidence and score events in GrcEvidenceNotificationService.
library;

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class GrcControlNotificationService {
  GrcControlNotificationService._();

  static Future<int> _send({
    required GrcNotificationEvent event,
    required GrcNotificationPage page,
    required String actorEmail,
    required Iterable<String> recipients,
    required Map<TemplateVariable, String> variables,
    required bool isArabic,
  }) =>
      AppNotificationSender.sendEventToAll(
        event: event,
        pageKey: page.key,
        senderEmail: actorEmail,
        receiverEmails: recipients,
        isArabic: isArabic,
        variables: variables,
      );

  /// Control Added to Policy (bulk upload) — one notification per batch.
  static Future<int> controlsBulkUploaded({
    required String actorEmail,
    required String policyName,
    required String userName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.controlAddedToPolicyBulkUpload,
        page: GrcNotificationPage.grcPolicyDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.userName: userName,
        },
      );

  /// Department Assigned to Control — one call per newly added department.
  static Future<int> departmentAssigned({
    required String actorEmail,
    required String departmentName,
    required String controlName,
    required String policyName,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.departmentAssignedToControl,
        page: GrcNotificationPage.grcControlDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.departmentName: departmentName,
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Control Updated.
  static Future<int> controlUpdated({
    required String actorEmail,
    required String controlName,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.controlUpdated,
        page: GrcNotificationPage.grcControlDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
        },
      );

  /// Control Deleted.
  static Future<int> controlDeleted({
    required String actorEmail,
    required String controlName,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.controlDeleted,
        page: GrcNotificationPage.grcPolicyDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
        },
      );

  /// Control Weight Updated. Weights are already formatted for display.
  static Future<int> controlWeightUpdated({
    required String actorEmail,
    required String controlName,
    required String oldWeight,
    required String newWeight,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.controlWeightUpdated,
        page: GrcNotificationPage.grcControlDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.oldWeight: oldWeight,
          TemplateVariable.newWeight: newWeight,
          TemplateVariable.policyName: policyName,
        },
      );

  /// Control Activated / Deactivated — one method; the caller knows which
  /// side of the switch it just crossed.
  static Future<int> controlStatusChanged({
    required String actorEmail,
    required String controlName,
    required String policyName,
    required bool isNowActive,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: isNowActive
            ? GrcNotificationEvent.controlActivated
            : GrcNotificationEvent.controlDeactivated,
        page: GrcNotificationPage.grcControlDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
        },
      );

  /// Control Weight Issue Detected / Resolved.
  static Future<int> controlWeightIssue({
    required String actorEmail,
    required String controlName,
    required bool isResolved,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: isResolved
            ? GrcNotificationEvent.controlWeightIssueResolved
            : GrcNotificationEvent.controlWeightIssueDetected,
        page: GrcNotificationPage.grcControlWeightIssue,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
        },
      );

  /// Control Rejected — a control change was sent back to its author.
  static Future<int> controlRejected({
    required String actorEmail,
    required String controlName,
    required String policyName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.controlRejected,
        page: GrcNotificationPage.grcControlDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
        },
      );
}
