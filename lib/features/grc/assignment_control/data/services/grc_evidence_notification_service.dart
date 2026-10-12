/// Module: GRC Assignment Controls / Approvals / My Audit
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_evidence_notification_service.dart
/// Purpose: Every notification of the "Assignment Controls & Approvals &
///          Audit" group of [GrcNotificationEvent] — the evidence journey
///          Champion → Department Manager → Control Owner → score — plus the
///          champion's submission-deadline reminders.
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// Nothing here is a raw string. AUDIENCE IS THE CALLER'S JOB. Delivery
/// (in-app + FCM push) is AppNotificationSender's.
///
/// DATE-DRIVEN EVENTS
/// ------------------
/// "Submission Due in 14 Days / Due Today / Overdue" cannot be observed by a
/// cubit — nobody is running the app when the date arrives. The calendar
/// (GrcControlCalendarEvent) shows them on the right day; the three methods
/// at the bottom are the single place a scheduled job should call.
library;

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class GrcEvidenceNotificationService {
  GrcEvidenceNotificationService._();

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

  // ── Submission ──────────────────────────────────────────────────────────

  /// Evidence Submitted — confirmation to the champion.
  static Future<int> evidenceSubmitted({
    required String actorEmail,
    required String controlName,
    required Iterable<String> championEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.evidenceSubmitted,
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: championEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
        },
      );

  /// Evidence Waiting for Review — to the department manager.
  static Future<int> evidenceWaitingForReview({
    required String actorEmail,
    required String controlChampionName,
    required String controlName,
    required Iterable<String> managerEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.evidenceWaitingForReview,
        page: GrcNotificationPage.grcApprovals,
        actorEmail: actorEmail,
        recipients: managerEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlChampionName: controlChampionName,
          TemplateVariable.controlName: controlName,
        },
      );

  // ── Department manager decision ─────────────────────────────────────────

  /// Department Manager Approved — to the champion.
  static Future<int> managerApproved({
    required String actorEmail,
    required String controlName,
    required String departmentManagerName,
    required String controlOwnerName,
    required Iterable<String> championEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.departmentManagerApproved,
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: championEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.departmentManagerName: departmentManagerName,
          TemplateVariable.controlOwnerName: controlOwnerName,
        },
      );

  /// Evidence Waiting for Final Approval — to the control owner.
  static Future<int> evidenceWaitingForFinalApproval({
    required String actorEmail,
    required String controlName,
    required String controlChampionName,
    required String departmentManagerName,
    required Iterable<String> ownerEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.evidenceWaitingForFinalApproval,
        page: GrcNotificationPage.grcMyAudits,
        actorEmail: actorEmail,
        recipients: ownerEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.controlChampionName: controlChampionName,
          TemplateVariable.departmentManagerName: departmentManagerName,
        },
      );

  /// Department Manager Rejected — to the champion.
  static Future<int> managerRejected({
    required String actorEmail,
    required String controlName,
    required String departmentManagerName,
    required Iterable<String> championEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.departmentManagerRejected,
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: championEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.departmentManagerName: departmentManagerName,
        },
      );

  // ── Control owner decision ──────────────────────────────────────────────

  /// Control Owner Approved / Rejected — to the champion.
  static Future<int> ownerDecided({
    required String actorEmail,
    required String controlName,
    required String controlOwnerName,
    required bool approved,
    required Iterable<String> championEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: approved
            ? GrcNotificationEvent.controlOwnerApproved
            : GrcNotificationEvent.controlOwnerRejected,
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: championEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.controlOwnerName: controlOwnerName,
        },
      );

  /// Score has been added — [controlScore] already formatted.
  static Future<int> scoreAdded({
    required String actorEmail,
    required String controlScore,
    required String controlName,
    required String controlOwnerName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.scoreHasBeenAdded,
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlScore: controlScore,
          TemplateVariable.controlName: controlName,
          TemplateVariable.controlOwnerName: controlOwnerName,
        },
      );

  /// Score has been Edited.
  static Future<int> scoreEdited({
    required String actorEmail,
    required String controlName,
    required String oldControlScore,
    required String newControlScore,
    required String controlOwnerName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.scoreHasBeenEdited,
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.oldControlScore: oldControlScore,
          TemplateVariable.newControlScore: newControlScore,
          TemplateVariable.controlOwnerName: controlOwnerName,
        },
      );

  // ── Date-driven (for a scheduled job) ───────────────────────────────────

  /// Control Champion Assignment Start Date Reached.
  static Future<int> assignmentStartDateReached({
    required String actorEmail,
    required String controlName,
    required String policyName,
    required String moduleName,
    required Iterable<String> championEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.controlChampionAssignmentStartDateReached,
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: championEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Submission Due in 14 Days / Due Today / Overdue.
  static Future<int> submissionDeadline({
    required String actorEmail,
    required GrcSubmissionDeadline stage,
    required String controlName,
    required String policyName,
    required String dueDate,
    required Iterable<String> championEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: switch (stage) {
          GrcSubmissionDeadline.dueIn14Days =>
            GrcNotificationEvent.controlChampionSubmissionDueIn14Days,
          GrcSubmissionDeadline.dueToday =>
            GrcNotificationEvent.controlChampionSubmissionDueToday,
          GrcSubmissionDeadline.overdue =>
            GrcNotificationEvent.controlChampionSubmissionOverdue,
        },
        page: GrcNotificationPage.grcAssignmentControls,
        actorEmail: actorEmail,
        recipients: championEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.dueDate: dueDate,
        },
      );
}

/// The three submission-deadline moments.
enum GrcSubmissionDeadline { dueIn14Days, dueToday, overdue }
