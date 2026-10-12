/// Module: GRC Control
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_control_notifier.dart
/// Purpose: Decides WHICH control notifications a finished action produces
///          and WHO gets them, then hands each one to
///          [GrcControlNotificationService]. Called by ControlCubit (single
///          add/edit/delete), the Control Weight Issue screen and the
///          control bulk upload — so every entry point announces a control
///          change the same way.
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// AUDIENCE: the owners of the control's module plus everyone currently
/// assigned to the control (champions and owners). Department assignment also
/// reaches that department's manager. The actor is never a recipient.
///
/// Everything here runs fire-and-forget AFTER the save succeeded
/// ([GrcNotify.run]); a failing lookup or send is logged and dropped.
library;

import 'package:knowticed_plus/features/grc/control/data/services/grc_control_notification_service.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/policy/data/services/grc_policy_notification_service.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_notification_support.dart';

abstract final class GrcControlNotifier {
  static Future<Set<String>> _audience({
    required String moduleId,
    required String policyId,
    required String controlId,
    Iterable<String> extra = const <String>[],
  }) async {
    final module = await GrcNotify.module(moduleId);
    final assignees =
        await GrcNotify.controlAssignees(moduleId, policyId, controlId);
    return GrcNotify.audience(<String>[
      ...?module?.moduleOwners,
      ...assignees,
      ...extra,
    ]);
  }

  /// A control was created on its own (Add Control page).
  static void created({
    required String moduleId,
    required String policyId,
    required ControlEntity control,
  }) {
    if (control.status == ControlStatus.draft) return;
    GrcNotify.run('control-created', () async {
      final String actor = GrcNotify.actorEmail;
      final module = await GrcNotify.module(moduleId);
      final String policyName = await GrcNotify.policyName(moduleId, policyId);
      final Set<String> owners =
          GrcNotify.audience(module?.moduleOwners ?? const <String>[]);
      if (owners.isNotEmpty) {
        GrcNotify.fire(
          'control-added',
          () => GrcPolicyNotificationService.controlAddedToPolicy(
            actorEmail: actor,
            controlName: control.controlsNameEn,
            policyName: policyName,
            recipients: owners,
            isArabic: GrcNotify.isArabic,
          ),
        );
      }
      _detectWeightIssue(
        moduleId: moduleId,
        policyId: policyId,
        control: control,
      );
      _departments(
        actor: actor,
        departments: control.departments.map((d) => d.department),
        control: control,
        policyName: policyName,
        moduleName: module?.moduleNameEn ?? '',
        baseAudience: owners,
      );
    });
  }

  /// A control was edited. [previous] is the control as it was before the
  /// save; null means it could not be read, so only the generic
  /// "Control Updated" is sent.
  static void updated({
    required String moduleId,
    required String policyId,
    required ControlEntity? previous,
    required ControlEntity after,
  }) {
    if (after.status == ControlStatus.draft) return;
    GrcNotify.run('control-updated', () async {
      final String actor = GrcNotify.actorEmail;
      final bool isArabic = GrcNotify.isArabic;
      final module = await GrcNotify.module(moduleId);
      final String policyName = await GrcNotify.policyName(moduleId, policyId);
      final Set<String> audience = await _audience(
        moduleId: moduleId,
        policyId: policyId,
        controlId: after.id,
      );
      if (audience.isEmpty) return;
      final String name = after.controlsNameEn;

      bool specific = false;
      final ControlEntity? prev = previous;
      if (prev != null) {
        final bool wasInactive = prev.status == ControlStatus.inactive;
        final bool isInactive = after.status == ControlStatus.inactive;
        if (wasInactive != isInactive) {
          specific = true;
          GrcNotify.fire(
            'control-status',
            () => GrcControlNotificationService.controlStatusChanged(
              actorEmail: actor,
              controlName: name,
              policyName: policyName,
              isNowActive: !isInactive,
              recipients: audience,
              isArabic: isArabic,
            ),
          );
        }

        if (prev.controlsWeight != after.controlsWeight) {
          specific = true;
          _detectWeightIssue(
            moduleId: moduleId,
            policyId: policyId,
            control: after,
          );
          GrcNotify.fire(
            'control-weight',
            () => GrcControlNotificationService.controlWeightUpdated(
              actorEmail: actor,
              controlName: name,
              oldWeight: formatControlWeight(prev.controlsWeight),
              newWeight: formatControlWeight(after.controlsWeight),
              policyName: policyName,
              recipients: audience,
              isArabic: isArabic,
            ),
          );
        }

        final Set<String> before =
            prev.departments.map((d) => d.department).toSet();
        final Iterable<String> added = after.departments
            .map((d) => d.department)
            .where((String d) => !before.contains(d));
        if (added.isNotEmpty) specific = true;
        _departments(
          actor: actor,
          departments: added,
          control: after,
          policyName: policyName,
          moduleName: module?.moduleNameEn ?? '',
          baseAudience: audience,
        );
      }

      final bool otherFieldsChanged = prev == null ||
          prev.controlsNameEn != after.controlsNameEn ||
          prev.controlsNameAr != after.controlsNameAr ||
          prev.controlsNumberEn != after.controlsNumberEn ||
          prev.controlsDescriptionEn != after.controlsDescriptionEn ||
          prev.controlsDescriptionAr != after.controlsDescriptionAr ||
          prev.frequency != after.frequency ||
          prev.controlsDocumentEn != after.controlsDocumentEn ||
          prev.controlsDocumentAr != after.controlsDocumentAr ||
          !_sameDay(prev.startDate, after.startDate) ||
          !_sameDay(prev.endDate, after.endDate);

      if (otherFieldsChanged || !specific) {
        GrcNotify.fire(
          'control-updated',
          () => GrcControlNotificationService.controlUpdated(
            actorEmail: actor,
            controlName: name,
            policyName: policyName,
            recipients: audience,
            isArabic: isArabic,
          ),
        );
      }
    });
  }

  /// A control was deleted. Resolve the audience BEFORE the delete runs —
  /// call [prepareDeleted] first and [deleted] once the delete succeeded.
  static Future<GrcControlDeleteContext?> prepareDeleted({
    required String moduleId,
    required String policyId,
    required String controlId,
  }) async {
    try {
      final control = await GrcNotify.control(moduleId, policyId, controlId);
      if (control == null || control.status == ControlStatus.draft) {
        return null;
      }
      return GrcControlDeleteContext(
        controlName: control.controlsNameEn,
        policyName: await GrcNotify.policyName(moduleId, policyId),
        audience: await _audience(
          moduleId: moduleId,
          policyId: policyId,
          controlId: controlId,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static void deleted(GrcControlDeleteContext? context) {
    if (context == null || context.audience.isEmpty) return;
    final String actor = GrcNotify.actorEmail;
    GrcNotify.fire(
      'control-deleted',
      () => GrcControlNotificationService.controlDeleted(
        actorEmail: actor,
        controlName: context.controlName,
        policyName: context.policyName,
        recipients: context.audience,
        isArabic: GrcNotify.isArabic,
      ),
    );
  }

  /// Controls were bulk uploaded under a policy — one notification.
  static void bulkUploaded({
    required String moduleId,
    required String policyId,
  }) {
    GrcNotify.run('control-bulk', () async {
      final String actor = GrcNotify.actorEmail;
      final module = await GrcNotify.module(moduleId);
      final Set<String> owners =
          GrcNotify.audience(module?.moduleOwners ?? const <String>[]);
      if (owners.isEmpty) return;
      final String policyName = await GrcNotify.policyName(moduleId, policyId);
      GrcNotify.fire(
        'control-bulk',
        () => GrcControlNotificationService.controlsBulkUploaded(
          actorEmail: actor,
          policyName: policyName,
          userName: GrcNotify.personName(actor),
          recipients: owners,
          isArabic: GrcNotify.isArabic,
        ),
      );
    });
  }

  /// Control Weight Issue Detected / Resolved for one control.
  static void weightIssue({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String controlName,
    required bool isResolved,
  }) {
    GrcNotify.run('control-weight-issue', () async {
      final String actor = GrcNotify.actorEmail;
      final Set<String> audience = await _audience(
        moduleId: moduleId,
        policyId: policyId,
        controlId: controlId,
      );
      if (audience.isEmpty) return;
      GrcNotify.fire(
        'control-weight-issue',
        () => GrcControlNotificationService.controlWeightIssue(
          actorEmail: actor,
          controlName: controlName,
          isResolved: isResolved,
          recipients: audience,
          isArabic: GrcNotify.isArabic,
        ),
      );
    });
  }

  /// Control Weight Issue Detected — fired when a save leaves the policy's
  /// counted control weights not adding up to 100. Resolution is announced
  /// from the Control Weight Issue screen, where the fix is applied.
  static void _detectWeightIssue({
    required String moduleId,
    required String policyId,
    required ControlEntity control,
  }) {
    GrcNotify.run('control-weight-detect', () async {
      final List<ControlEntity> siblings =
          await GrcNotify.policyControls(moduleId, policyId);
      if (siblings.isEmpty || !siblings.hasControlWeightIssue) return;
      weightIssue(
        moduleId: moduleId,
        policyId: policyId,
        controlId: control.id,
        controlName: control.controlsNameEn,
        isResolved: false,
      );
    });
  }

  static void _departments({
    required String actor,
    required Iterable<String> departments,
    required ControlEntity control,
    required String policyName,
    required String moduleName,
    required Set<String> baseAudience,
  }) {
    for (final String department in departments.toSet()) {
      if (department.trim().isEmpty) continue;
      final Set<String> recipients = GrcNotify.audience(<String>[
        ...baseAudience,
        ...GrcNotify.departmentManagers(department),
      ]);
      if (recipients.isEmpty) continue;
      GrcNotify.fire(
        'control-department',
        () => GrcControlNotificationService.departmentAssigned(
          actorEmail: actor,
          departmentName: department,
          controlName: control.controlsNameEn,
          policyName: policyName,
          moduleName: moduleName,
          recipients: recipients,
          isArabic: GrcNotify.isArabic,
        ),
      );
    }
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// What [GrcControlNotifier.deleted] needs, captured before the document is
/// gone.
class GrcControlDeleteContext {
  final String controlName;
  final String policyName;
  final Set<String> audience;

  const GrcControlDeleteContext({
    required this.controlName,
    required this.policyName,
    required this.audience,
  });
}
