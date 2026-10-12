/// Module: GRC / Control Champion + Control Owner
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_assignee_notifier.dart
/// Purpose: Turns a champion / owner assignment change into the right
///          notifications — who was added to which control, who was taken
///          off, who was swapped from one control to another — and the
///          reassignment-request lifecycle, then hands each one to
///          [GrcAssigneeNotificationService].
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// Called from ChampionCubit / OwnerCubit (every direct assignment, including
/// the Add/Edit Control page's assignee section), from GrcRequestCubit
/// (reassignment requests) and from the module's bulk-upload tabs.
///
/// Everything runs fire-and-forget after the save succeeded; lookups that
/// fail fall back to empty names rather than dropping the notification.
library;

import 'package:knowticed_plus/features/grc/control/data/services/grc_control_notification_service.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notification_service.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_notification_support.dart';

abstract final class GrcAssigneeNotifier {
  /// [before] → [after] for one assignee. [isNewAssignee] is true when the
  /// assignee document was just created (first assignment in the module).
  /// [removedFromModule] is true when the save set the status to Removed.
  static void assignmentChanged({
    required GrcAssigneeRole role,
    required String moduleId,
    required String assigneeEmail,
    required List<AssigningControlEntity> before,
    required List<AssigningControlEntity> after,
    bool isNewAssignee = false,
    bool removedFromModule = false,
  }) {
    final String actor = GrcNotify.actorEmail;
    if (assigneeEmail.isEmpty || assigneeEmail == actor) return;

    String keyOf(AssigningControlEntity a) => '${a.policyId}/${a.controlId}';
    final Set<String> beforeKeys = before.map(keyOf).toSet();
    final Set<String> afterKeys = after.map(keyOf).toSet();
    final List<AssigningControlEntity> added =
        after.where((a) => !beforeKeys.contains(keyOf(a))).toList();
    final List<AssigningControlEntity> removed = removedFromModule
        ? List<AssigningControlEntity>.of(before)
        : before.where((a) => !afterKeys.contains(keyOf(a))).toList();

    if (added.isEmpty && removed.isEmpty) return;

    GrcNotify.run('assignee-${role.name}', () async {
      final bool isArabic = GrcNotify.isArabic;
      final List<String> to = <String>[assigneeEmail];
      final module = await GrcNotify.module(moduleId);
      final String moduleName = module?.moduleNameEn ?? '';

      // Removed from the module altogether.
      if (removedFromModule) {
        for (final AssigningControlEntity a in removed) {
          final String control =
              await GrcNotify.controlName(moduleId, a.policyId, a.controlId);
          GrcNotify.fire(
            'assignee-removed',
            () => GrcAssigneeNotificationService.removed(
              role: role,
              actorEmail: actor,
              controlName: control,
              assigneeEmails: to,
              isArabic: isArabic,
            ),
          );
        }
        return;
      }

      // One control swapped for another — a single "assignment changed".
      if (added.length == 1 && removed.length == 1) {
        final AssigningControlEntity from = removed.first;
        final AssigningControlEntity into = added.first;
        final String newControl = await GrcNotify.controlName(
            moduleId, into.policyId, into.controlId);
        final String newPolicy =
            await GrcNotify.policyName(moduleId, into.policyId);
        if (from.policyId == into.policyId) {
          final String oldControl = await GrcNotify.controlName(
              moduleId, from.policyId, from.controlId);
          GrcNotify.fire(
            'assignee-control-changed',
            () => GrcAssigneeNotificationService.controlAssignmentChanged(
              role: role,
              actorEmail: actor,
              oldControlName: oldControl,
              newControlName: newControl,
              policyName: newPolicy,
              assigneeEmails: to,
              isArabic: isArabic,
            ),
          );
        } else {
          GrcNotify.fire(
            'assignee-policy-changed',
            () => GrcAssigneeNotificationService.policyAssignmentChanged(
              role: role,
              actorEmail: actor,
              policyName: newPolicy,
              controlName: newControl,
              moduleName: moduleName,
              assigneeEmails: to,
              isArabic: isArabic,
            ),
          );
        }
        return;
      }

      for (final AssigningControlEntity a in added) {
        final String control =
            await GrcNotify.controlName(moduleId, a.policyId, a.controlId);
        final String policy = await GrcNotify.policyName(moduleId, a.policyId);
        GrcNotify.fire(
          'assignee-added',
          () => isNewAssignee
              ? GrcAssigneeNotificationService.assigned(
                  role: role,
                  actorEmail: actor,
                  controlName: control,
                  policyName: policy,
                  assigneeEmails: to,
                  isArabic: isArabic,
                )
              : GrcAssigneeNotificationService.changedNewAssignee(
                  role: role,
                  actorEmail: actor,
                  controlName: control,
                  policyName: policy,
                  moduleName: moduleName,
                  assigneeEmails: to,
                  isArabic: isArabic,
                ),
        );
      }

      for (final AssigningControlEntity a in removed) {
        final String control =
            await GrcNotify.controlName(moduleId, a.policyId, a.controlId);
        final String policy = await GrcNotify.policyName(moduleId, a.policyId);
        GrcNotify.fire(
          'assignee-taken-off',
          () => GrcAssigneeNotificationService.changedPreviousAssignee(
            role: role,
            actorEmail: actor,
            controlName: control,
            policyName: policy,
            moduleName: moduleName,
            assigneeEmails: to,
            isArabic: isArabic,
          ),
        );
      }
    });
  }

  /// A bulk upload finished. [assigneeEmails] are the people it assigned;
  /// [first] is any one uploaded pair (the Arabic summary names a control).
  static void bulkUploaded({
    required GrcAssigneeRole role,
    required String moduleId,
    required Iterable<String> assigneeEmails,
    AssigningControlEntity? first,
  }) {
    GrcNotify.run('assignee-bulk-${role.name}', () async {
      final String actor = GrcNotify.actorEmail;
      final bool isArabic = GrcNotify.isArabic;
      final String actorName = GrcNotify.personName(actor);
      final module = await GrcNotify.module(moduleId);
      final String moduleName = module?.moduleNameEn ?? '';

      final Set<String> assignees = GrcNotify.audience(assigneeEmails);
      if (assignees.isNotEmpty) {
        GrcNotify.fire(
          'assignee-bulk',
          () => GrcAssigneeNotificationService.bulkUploadedToAssignees(
            role: role,
            actorEmail: actor,
            userName: actorName,
            moduleName: moduleName,
            assigneeEmails: assignees,
            isArabic: isArabic,
          ),
        );
      }

      if (role != GrcAssigneeRole.champion) return;
      final Set<String> owners = GrcNotify.audience(
          module?.moduleOwners ?? const <String>[])
        ..removeAll(assignees);
      if (owners.isEmpty) return;
      final AssigningControlEntity? pair = first;
      final String control = pair == null
          ? ''
          : await GrcNotify.controlName(
              moduleId, pair.policyId, pair.controlId);
      final String policy = pair == null
          ? ''
          : await GrcNotify.policyName(moduleId, pair.policyId);
      GrcNotify.fire(
        'champion-bulk-summary',
        () => GrcAssigneeNotificationService.championBulkUploadCompleted(
          actorEmail: actor,
          uploadedByUserName: actorName,
          controlName: control,
          policyName: policy,
          moduleName: moduleName,
          recipients: owners,
          isArabic: isArabic,
        ),
      );
    });
  }

  /// "Control Rejected" — a Control Changes request was sent back.
  static void _controlChangeRejected(GrcRequestEntity request) {
    GrcNotify.run('control-rejected', () async {
      final String actor = GrcNotify.actorEmail;
      final Set<String> requester =
          GrcNotify.audience(<String>[request.requestedBy]);
      if (requester.isEmpty) return;
      for (final AssigningControlEntity a
          in request.controls ?? const <AssigningControlEntity>[]) {
        final String control = await GrcNotify.controlName(
            request.moduleId, a.policyId, a.controlId);
        final String policy =
            await GrcNotify.policyName(request.moduleId, a.policyId);
        GrcNotify.fire(
          'control-rejected',
          () => GrcControlNotificationService.controlRejected(
            actorEmail: actor,
            controlName: control,
            policyName: policy,
            recipients: requester,
            isArabic: GrcNotify.isArabic,
          ),
        );
      }
    });
  }

  // ── Reassignment requests ───────────────────────────────────────────────

  static GrcAssigneeRole? _roleOf(GrcRequestType type) => switch (type) {
        GrcRequestType.reassignChampion => GrcAssigneeRole.champion,
        GrcRequestType.reassignOwner => GrcAssigneeRole.owner,
        GrcRequestType.controlChanges => null,
      };

  static Future<List<String>> _controlNames(GrcRequestEntity request) async {
    final List<String> names = <String>[];
    for (final AssigningControlEntity a
        in request.controls ?? const <AssigningControlEntity>[]) {
      final String name = await GrcNotify.controlName(
          request.moduleId, a.policyId, a.controlId);
      if (name.isNotEmpty) names.add(name);
    }
    return names;
  }

  /// A reassignment request was submitted.
  static void requestSubmitted(GrcRequestEntity request) {
    final GrcAssigneeRole? role = _roleOf(request.type);
    if (role == null) return;
    GrcNotify.run('request-submitted', () async {
      final String actor = GrcNotify.actorEmail;
      final bool isArabic = GrcNotify.isArabic;
      final module = await GrcNotify.module(request.moduleId);
      final String moduleName = module?.moduleNameEn ?? '';
      final String requesterName = GrcNotify.personName(request.requestedBy);
      final List<String> controls = await _controlNames(request);

      // Approvers — the module owners (the Requests tab's decision makers).
      final Set<String> approvers =
          GrcNotify.audience(module?.moduleOwners ?? const <String>[]);
      if (approvers.isNotEmpty) {
        if (role == GrcAssigneeRole.champion && controls.length == 1) {
          GrcNotify.fire(
            'request-approval-required',
            () => GrcAssigneeNotificationService.championApprovalRequired(
              actorEmail: actor,
              controlName: controls.first,
              requesterName: requesterName,
              approverEmails: approvers,
              isArabic: isArabic,
            ),
          );
        } else {
          GrcNotify.fire(
            'request-submitted',
            () => GrcAssigneeNotificationService.reassignmentSubmitted(
              role: role,
              actorEmail: actor,
              requesterName: requesterName,
              moduleName: moduleName,
              approverEmails: approvers,
              isArabic: isArabic,
            ),
          );
        }
      }

      // Champion only — the current and proposed champion hear about it.
      if (role == GrcAssigneeRole.champion) {
        final Set<String> people = GrcNotify.audience(<String?>[
          request.currentChampionEmail,
          request.newChampionEmail,
        ])
          ..removeAll(approvers);
        if (people.isNotEmpty) {
          GrcNotify.fire(
            'request-requested',
            () => GrcAssigneeNotificationService.championReassignmentRequested(
              actorEmail: actor,
              controlName: controls.join(', '),
              currentChampionName:
                  GrcNotify.personName(request.currentChampionEmail),
              newChampionName: GrcNotify.personName(request.newChampionEmail),
              recipients: people,
              isArabic: isArabic,
            ),
          );
        }
      }
    });
  }

  /// A reassignment request was approved or rejected.
  static void requestDecided(
    GrcRequestEntity request, {
    required bool approved,
    String rejectionReason = '',
  }) {
    if (request.type == GrcRequestType.controlChanges) {
      if (!approved) _controlChangeRejected(request);
      return;
    }
    final GrcAssigneeRole? role = _roleOf(request.type);
    if (role == null) return;
    GrcNotify.run('request-decided', () async {
      final String actor = GrcNotify.actorEmail;
      final bool isArabic = GrcNotify.isArabic;
      final module = await GrcNotify.module(request.moduleId);
      final String moduleName = module?.moduleNameEn ?? '';
      final List<String> controls = await _controlNames(request);
      final String? newEmail = role == GrcAssigneeRole.champion
          ? request.newChampionEmail
          : request.newOwnerEmail;
      final String? oldEmail = role == GrcAssigneeRole.champion
          ? request.currentChampionEmail
          : request.currentOwnerEmail;
      final String newName = GrcNotify.personName(newEmail);
      final Set<String> requester =
          GrcNotify.audience(<String>[request.requestedBy]);

      // The requester.
      if (requester.isNotEmpty) {
        if (role == GrcAssigneeRole.champion && controls.length == 1) {
          GrcNotify.fire(
            'request-decided-requester',
            () => GrcAssigneeNotificationService.championRequestDecided(
              actorEmail: actor,
              controlName: controls.first,
              approved: approved,
              requesterEmails: requester,
              isArabic: isArabic,
            ),
          );
        } else if (approved) {
          GrcNotify.fire(
            'request-approved-requester',
            () => GrcAssigneeNotificationService.reassignmentApproved(
              role: role,
              actorEmail: actor,
              moduleName: moduleName,
              newAssigneeName: newName,
              requesterEmails: requester,
              isArabic: isArabic,
            ),
          );
        } else {
          GrcNotify.fire(
            'request-rejected-requester',
            () => GrcAssigneeNotificationService.reassignmentRejected(
              role: role,
              actorEmail: actor,
              moduleName: moduleName,
              approverName: GrcNotify.personName(actor),
              rejectionReason: rejectionReason,
              requesterEmails: requester,
              isArabic: isArabic,
            ),
          );
        }
      }

      if (!approved) return;

      // The incoming and outgoing assignee, per control.
      final Set<String> incoming = GrcNotify.audience(<String?>[newEmail]);
      final Set<String> outgoing = GrcNotify.audience(<String?>[oldEmail]);
      for (final AssigningControlEntity a
          in request.controls ?? const <AssigningControlEntity>[]) {
        final String control = await GrcNotify.controlName(
            request.moduleId, a.policyId, a.controlId);
        final String policy =
            await GrcNotify.policyName(request.moduleId, a.policyId);
        if (incoming.isNotEmpty) {
          GrcNotify.fire(
            'request-approved-new',
            () => GrcAssigneeNotificationService.reassignmentApprovedNewAssignee(
              role: role,
              actorEmail: actor,
              controlName: control,
              policyName: policy,
              moduleName: moduleName,
              assigneeEmails: incoming,
              isArabic: isArabic,
            ),
          );
        }
        if (outgoing.isNotEmpty) {
          GrcNotify.fire(
            'request-approved-old',
            () => GrcAssigneeNotificationService.reassignmentApprovedOldAssignee(
              role: role,
              actorEmail: actor,
              controlName: control,
              policyName: policy,
              moduleName: moduleName,
              newAssigneeName: newName,
              assigneeEmails: outgoing,
              isArabic: isArabic,
            ),
          );
        }
      }
    });
  }
}
