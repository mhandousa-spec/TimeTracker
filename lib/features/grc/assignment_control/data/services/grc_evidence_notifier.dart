/// Module: GRC Assignment Controls / Approvals / My Audit
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_evidence_notifier.dart
/// Purpose: Decides who hears about each step of the evidence journey and
///          hands the send to [GrcEvidenceNotificationService]:
///            submit  → champion (confirmation) + department manager
///            manager → champion (+ control owner on approval)
///            owner   → champion (approve / reject / score)
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// Fire-and-forget: every method returns immediately and never throws.
library;

import 'package:knowticed_plus/features/grc/assignment_control/data/services/grc_evidence_notification_service.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_notification_support.dart';

abstract final class GrcEvidenceNotifier {
  static String _score(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  /// Evidence Submitted (champion) + Evidence Waiting for Review (manager —
  /// or the control owner when the champion's department has no manager).
  static void submitted({
    required String moduleId,
    required AssignmentControlEntity assignment,
  }) {
    GrcNotify.run('evidence-submitted', () async {
      final String actor = GrcNotify.actorEmail;
      final bool isArabic = GrcNotify.isArabic;
      final String control = await GrcNotify.controlName(
          moduleId, assignment.policyId, assignment.controlId);
      final String champion = assignment.controlChampionEmail;

      // A confirmation to the person who just submitted — the one event
      // where the actor IS the audience.
      final Set<String> self =
          GrcNotify.audience(<String>[champion], excludeActor: false);
      if (self.isNotEmpty) {
        GrcNotify.fire(
          'evidence-submitted',
          () => GrcEvidenceNotificationService.evidenceSubmitted(
            actorEmail: actor,
            controlName: control,
            championEmails: self,
            isArabic: isArabic,
          ),
        );
      }

      final Set<String> reviewers = GrcNotify.audience(<String?>[
        assignment.departmentManager ?? assignment.controlOwner,
      ]);
      if (reviewers.isNotEmpty) {
        GrcNotify.fire(
          'evidence-review',
          () => GrcEvidenceNotificationService.evidenceWaitingForReview(
            actorEmail: actor,
            controlChampionName: GrcNotify.personName(champion),
            controlName: control,
            managerEmails: reviewers,
            isArabic: isArabic,
          ),
        );
      }
    });
  }

  /// Department manager approved / rejected.
  static void managerDecided({
    required String moduleId,
    required AssignmentControlEntity assignment,
    required bool approved,
  }) {
    GrcNotify.run('evidence-manager', () async {
      final String actor = GrcNotify.actorEmail;
      final bool isArabic = GrcNotify.isArabic;
      final String control = await GrcNotify.controlName(
          moduleId, assignment.policyId, assignment.controlId);
      final String managerName = GrcNotify.personName(actor);
      final Set<String> champion =
          GrcNotify.audience(<String>[assignment.controlChampionEmail]);

      if (!approved) {
        if (champion.isEmpty) return;
        GrcNotify.fire(
          'evidence-manager-rejected',
          () => GrcEvidenceNotificationService.managerRejected(
            actorEmail: actor,
            controlName: control,
            departmentManagerName: managerName,
            championEmails: champion,
            isArabic: isArabic,
          ),
        );
        return;
      }

      final String ownerName = GrcNotify.personName(assignment.controlOwner);
      if (champion.isNotEmpty) {
        GrcNotify.fire(
          'evidence-manager-approved',
          () => GrcEvidenceNotificationService.managerApproved(
            actorEmail: actor,
            controlName: control,
            departmentManagerName: managerName,
            controlOwnerName: ownerName,
            championEmails: champion,
            isArabic: isArabic,
          ),
        );
      }
      final Set<String> owner =
          GrcNotify.audience(<String?>[assignment.controlOwner]);
      if (owner.isNotEmpty) {
        GrcNotify.fire(
          'evidence-final-approval',
          () => GrcEvidenceNotificationService.evidenceWaitingForFinalApproval(
            actorEmail: actor,
            controlName: control,
            controlChampionName:
                GrcNotify.personName(assignment.controlChampionEmail),
            departmentManagerName: managerName,
            ownerEmails: owner,
            isArabic: isArabic,
          ),
        );
      }
    });
  }

  /// Control owner approved / rejected the evidence.
  static void ownerDecided({
    required String moduleId,
    required AssignmentControlEntity assignment,
    required bool approved,
  }) {
    GrcNotify.run('evidence-owner', () async {
      final String actor = GrcNotify.actorEmail;
      final Set<String> champion =
          GrcNotify.audience(<String>[assignment.controlChampionEmail]);
      if (champion.isEmpty) return;
      final String control = await GrcNotify.controlName(
          moduleId, assignment.policyId, assignment.controlId);
      GrcNotify.fire(
        'evidence-owner-decided',
        () => GrcEvidenceNotificationService.ownerDecided(
          actorEmail: actor,
          controlName: control,
          controlOwnerName: GrcNotify.personName(actor),
          approved: approved,
          championEmails: champion,
          isArabic: GrcNotify.isArabic,
        ),
      );
    });
  }

  /// Score added (no previous score) or edited. Goes to the champion and
  /// the department manager who approved the evidence.
  static void scored({
    required String moduleId,
    required AssignmentControlEntity assignment,
    required double? previousScore,
    required double newScore,
  }) {
    GrcNotify.run('evidence-score', () async {
      final String actor = GrcNotify.actorEmail;
      final bool isArabic = GrcNotify.isArabic;
      final Set<String> recipients = GrcNotify.audience(<String?>[
        assignment.controlChampionEmail,
        assignment.departmentManager,
      ]);
      if (recipients.isEmpty) return;
      final String control = await GrcNotify.controlName(
          moduleId, assignment.policyId, assignment.controlId);
      final String ownerName = GrcNotify.personName(actor);
      final double? before = previousScore;
      if (before == null) {
        GrcNotify.fire(
          'score-added',
          () => GrcEvidenceNotificationService.scoreAdded(
            actorEmail: actor,
            controlScore: _score(newScore),
            controlName: control,
            controlOwnerName: ownerName,
            recipients: recipients,
            isArabic: isArabic,
          ),
        );
      } else if (before != newScore) {
        GrcNotify.fire(
          'score-edited',
          () => GrcEvidenceNotificationService.scoreEdited(
            actorEmail: actor,
            controlName: control,
            oldControlScore: _score(before),
            newControlScore: _score(newScore),
            controlOwnerName: ownerName,
            recipients: recipients,
            isArabic: isArabic,
          ),
        );
      }
    });
  }
}
