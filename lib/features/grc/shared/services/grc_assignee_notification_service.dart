/// Module: GRC / Control Champion + Control Owner
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_assignee_notification_service.dart
/// Purpose: Every notification of the "Add Champion Officers & Assign
///          Controls To Their Compliance Officers" group of
///          [GrcNotificationEvent], for both assignee roles. Champions and
///          owners follow the same lifecycle (assigned, moved, removed,
///          reassigned by request, bulk uploaded), so one service takes the
///          [GrcAssigneeRole] and picks the matching event.
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// Nothing here is a raw string: events, pages and placeholders all come from
/// their enums. AUDIENCE IS THE CALLER'S JOB. Delivery (in-app + FCM push)
/// is AppNotificationSender's.
///
/// SPEC ROWS WITH NO SEPARATE CALL SITE
/// ------------------------------------
/// * `controlOwnerAssigned2` repeats "Control Owner Assigned" word for word
///   with the module added; [assigned] for owners already covers that moment.
/// * "Reassignment Request Updated" has a method here, but the app has no
///   edit-a-pending-request flow yet, so nothing calls it today.
library;

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

/// Which assignee list a notification is about.
enum GrcAssigneeRole {
  champion,
  owner;

  GrcNotificationPage get detailsPage => this == GrcAssigneeRole.champion
      ? GrcNotificationPage.grcControlChampionDetails
      : GrcNotificationPage.grcControlOwnerDetails;
}

class GrcAssigneeNotificationService {
  GrcAssigneeNotificationService._();

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

  static TemplateVariable _newAssigneeVariable(GrcAssigneeRole role) =>
      role == GrcAssigneeRole.champion
          ? TemplateVariable.newChampionName
          : TemplateVariable.newOwnerName;

  // ── Direct assignment ───────────────────────────────────────────────────

  /// First assignment of a person to a control ("Control Assigned" /
  /// "Control Ownership Assigned"). Second person — send to the assignee.
  static Future<int> assigned({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String controlName,
    required String policyName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlAssignedToChampion
            : GrcNotificationEvent.controlOwnerAssigned,
        page: role.detailsPage,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
        },
      );

  /// A control was added to an existing assignee ("New Control Champion /
  /// Owner Assigned").
  static Future<int> changedNewAssignee({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String controlName,
    required String policyName,
    required String moduleName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionChangedNewChampion
            : GrcNotificationEvent.controlOwnerChangedNewOwner,
        page: role.detailsPage,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// A control was taken off an assignee ("… Assignment Removed").
  static Future<int> changedPreviousAssignee({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String controlName,
    required String policyName,
    required String moduleName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionChangedPreviousChampion
            : GrcNotificationEvent.controlOwnerChangedPreviousOwner,
        page: GrcNotificationPage.grcModuleDetails,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// The assignee was removed from the module altogether.
  static Future<int> removed({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String controlName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionRemoved
            : GrcNotificationEvent.controlOwnerRemoved,
        page: GrcNotificationPage.grcModuleDetails,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
        },
      );

  /// One control swapped for another under the same policy.
  static Future<int> controlAssignmentChanged({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String oldControlName,
    required String newControlName,
    required String policyName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlAssignmentChangedControlChampion
            : GrcNotificationEvent.controlAssignmentChangedControlOwner,
        page: role.detailsPage,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.oldControlName: oldControlName,
          TemplateVariable.newControlName: newControlName,
          TemplateVariable.policyName: policyName,
        },
      );

  /// One control swapped for a control under a different policy.
  static Future<int> policyAssignmentChanged({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String policyName,
    required String controlName,
    required String moduleName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.policyAssignmentChangedControlChampion
            : GrcNotificationEvent.policyAssignmentChangedControlOwner,
        page: role.detailsPage,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.policyName: policyName,
          TemplateVariable.controlName: controlName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  // ── Bulk upload ─────────────────────────────────────────────────────────

  /// "New Control Champions / Owners Assigned" — once per batch, to the
  /// people the batch assigned.
  static Future<int> bulkUploadedToAssignees({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String userName,
    required String moduleName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionAddedBulkUpload
            : GrcNotificationEvent.controlOwnerAddedBulkUpload,
        page: role.detailsPage,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.userName: userName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// "A new Control Champions bulk upload has been completed by …" — the
  /// module owners' summary of a champion batch. [controlName] /
  /// [policyName] are only read by the Arabic copy; pass the first row's.
  static Future<int> championBulkUploadCompleted({
    required String actorEmail,
    required String uploadedByUserName,
    required String controlName,
    required String policyName,
    required String moduleName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.controlChampionAdded,
        page: GrcNotificationPage.grcModuleDetails,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.uploadedByUserName: uploadedByUserName,
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  // ── Reassignment requests ───────────────────────────────────────────────

  /// Champion only — tells the current and the proposed champion that a
  /// reassignment was requested.
  static Future<int> championReassignmentRequested({
    required String actorEmail,
    required String controlName,
    required String currentChampionName,
    required String newChampionName,
    required Iterable<String> recipients,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.reassignmentRequested,
        page: GrcNotificationPage.grcRequests,
        actorEmail: actorEmail,
        recipients: recipients,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.currentChampionName: currentChampionName,
          TemplateVariable.newChampionName: newChampionName,
        },
      );

  /// "… Reassignment Approval Required" — to the approvers.
  static Future<int> reassignmentSubmitted({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String requesterName,
    required String moduleName,
    required Iterable<String> approverEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionReassignmentRequestSubmitted
            : GrcNotificationEvent.controlOwnerReassignmentRequestSubmitted,
        page: GrcNotificationPage.grcRequests,
        actorEmail: actorEmail,
        recipients: approverEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.requesterName: requesterName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Champion only, single control: "A request to reassign {control} has been
  /// submitted by {requester} and requires your approval."
  static Future<int> championApprovalRequired({
    required String actorEmail,
    required String controlName,
    required String requesterName,
    required Iterable<String> approverEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: GrcNotificationEvent.approvalRequired,
        page: GrcNotificationPage.grcRequests,
        actorEmail: actorEmail,
        recipients: approverEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.requesterName: requesterName,
        },
      );

  /// "… Reassignment Request Updated" — to the approvers.
  static Future<int> reassignmentUpdated({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String requesterName,
    required String moduleName,
    required Iterable<String> approverEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionReassignmentRequestUpdated
            : GrcNotificationEvent.controlOwnerReassignmentRequestUpdated,
        page: GrcNotificationPage.grcRequests,
        actorEmail: actorEmail,
        recipients: approverEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.requesterName: requesterName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Module-level "Reassignment Approved" — to the requester.
  static Future<int> reassignmentApproved({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String moduleName,
    required String newAssigneeName,
    required Iterable<String> requesterEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionReassignmentApproved
            : GrcNotificationEvent.controlOwnerReassignmentApproved,
        page: GrcNotificationPage.grcRequestDetails,
        actorEmail: actorEmail,
        recipients: requesterEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
          _newAssigneeVariable(role): newAssigneeName,
        },
      );

  /// Champion only, single control: "Your reassignment request for {control}
  /// has been approved / rejected."
  static Future<int> championRequestDecided({
    required String actorEmail,
    required String controlName,
    required bool approved,
    required Iterable<String> requesterEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: approved
            ? GrcNotificationEvent.requestApproved
            : GrcNotificationEvent.requestRejected,
        page: GrcNotificationPage.grcRequestDetails,
        actorEmail: actorEmail,
        recipients: requesterEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
        },
      );

  /// Module-level "Reassignment Rejected" — to the requester.
  static Future<int> reassignmentRejected({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String moduleName,
    required String approverName,
    required String rejectionReason,
    required Iterable<String> requesterEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionReassignmentRejected
            : GrcNotificationEvent.controlOwnerReassignmentRejected,
        page: GrcNotificationPage.grcRequestDetails,
        actorEmail: actorEmail,
        recipients: requesterEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.moduleName: moduleName,
          TemplateVariable.approverName: approverName,
          TemplateVariable.rejectionReason: rejectionReason,
        },
      );

  /// Reassignment approved — the incoming assignee, per control.
  static Future<int> reassignmentApprovedNewAssignee({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String controlName,
    required String policyName,
    required String moduleName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            // The spec has no champion-specific "(New Champion)" approval row;
            // "Control Champion Changed (New Champion)" is the same message.
            ? GrcNotificationEvent.controlChampionChangedNewChampion
            : GrcNotificationEvent.controlOwnerReassignmentApprovedNewOwner,
        page: role.detailsPage,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
        },
      );

  /// Reassignment approved — the outgoing assignee, per control.
  static Future<int> reassignmentApprovedOldAssignee({
    required GrcAssigneeRole role,
    required String actorEmail,
    required String controlName,
    required String policyName,
    required String moduleName,
    required String newAssigneeName,
    required Iterable<String> assigneeEmails,
    bool isArabic = false,
  }) =>
      _send(
        event: role == GrcAssigneeRole.champion
            ? GrcNotificationEvent.controlChampionReassignmentApprovedOldChampion
            : GrcNotificationEvent.controlOwnerReassignmentApprovedOldOwner,
        page: GrcNotificationPage.grcModuleDetails,
        actorEmail: actorEmail,
        recipients: assigneeEmails,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.controlName: controlName,
          TemplateVariable.policyName: policyName,
          TemplateVariable.moduleName: moduleName,
          _newAssigneeVariable(role): newAssigneeName,
        },
      );
}
