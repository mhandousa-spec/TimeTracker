/// Module: GRC / shared
///
/// ************************* FILE INFO ************************* ///
/// File Name: grc_notification_support.dart
/// Purpose: The plumbing every GRC notification call site shares — who the
///          actor is, the display language, date formatting, recipient
///          filtering, fire-and-forget sending, and the small Firestore
///          lookups (module name + owners, policy name, control name) a
///          cubit needs when it only holds ids.
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// WHY A HELPER AND NOT MORE CONSTRUCTOR ARGUMENTS
/// ------------------------------------------------
/// GrcModuleCubit and PolicyCubit are handed the module entity by their pages,
/// so they pass `moduleOwners` in. The Control / Champion / Owner / Evidence
/// flows are reached from a dozen pages that only carry ids; threading the
/// module through all of them would touch every constructor for no gain. The
/// lookups here are one document read each and only run AFTER the action has
/// succeeded, inside a fire-and-forget block — they can never slow down or
/// fail the save that triggered them.
///
/// The sending itself still goes through the per-feature services
/// (GrcControlNotificationService, …) → AppNotificationSender, so FCM push,
/// the in-app record and Notification Control's enable switch all apply
/// exactly as they do for every other module.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/grc/control/data/models/control_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_champion/data/models/champion_model.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/data/models/owner_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/module/data/models/grc_module_model.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/data/models/policy_model.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

abstract final class GrcNotify {
  // ── Context ─────────────────────────────────────────────────────────────

  /// The signed-in user — the sender of every GRC notification.
  static String get actorEmail => currentGrcUserEmail();

  static bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Dates in notification bodies read the way the rest of GRC writes them
  /// ("16 Sep 2026"). English on purpose: the stored English body is what the
  /// FCM push carries.
  static String fmtDate(DateTime d) => DateFormat('d MMM yyyy', 'en').format(d);

  /// A person's English display name for a `{…Name}` placeholder. Falls back
  /// to a name derived from the address when the employee is not loaded.
  static String personName(String? email) {
    final String value = (email ?? '').trim();
    if (value.isEmpty) return '';
    final employee = findEmployeeByEmail(value);
    final String first = employee?.firstName?.trim() ?? '';
    final String last = employee?.lastName?.trim() ?? '';
    final String full = '$first $last'.trim();
    return full.isNotEmpty ? full : FormatHelper.formatEmailToName(value);
  }

  /// De-duplicated, non-empty recipients. The actor is removed by default —
  /// they just did the thing and do not need telling.
  static Set<String> audience(
    Iterable<String?> emails, {
    bool excludeActor = true,
  }) {
    final Set<String> result = <String>{
      for (final String? e in emails)
        if (e != null && e.trim().isNotEmpty) e.trim(),
    };
    if (excludeActor) result.remove(actorEmail);
    return result;
  }

  /// Runs a send without letting it affect the action that triggered it —
  /// the same shape GrcModuleCubit._notify / PolicyCubit._notify use.
  static void fire(String tag, Future<int> Function() send) {
    unawaited(
      Future<int>.sync(send).then((int sent) {
        debugPrint('[grc-notify:$tag] sent to $sent recipient(s).');
        return sent;
      }).catchError((Object e, StackTrace st) {
        debugPrint('[grc-notify:$tag] send failed - $e\n$st');
        return 0;
      }),
    );
  }

  /// Runs an async block (lookups + sends) fire-and-forget.
  static void run(String tag, Future<void> Function() body) {
    unawaited(
      Future<void>.sync(body).catchError((Object e, StackTrace st) {
        debugPrint('[grc-notify:$tag] failed - $e\n$st');
      }),
    );
  }

  // ── Lookups ─────────────────────────────────────────────────────────────

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _moduleRef(String moduleId) =>
      _db.collection(GrcFirebasePaths.modulesCollection).doc(moduleId);

  /// The module document, or null when it cannot be read.
  static Future<GRCModuleEntity?> module(String moduleId) async {
    if (moduleId.isEmpty) return null;
    try {
      final doc = await _moduleRef(moduleId).get();
      final data = doc.data();
      if (data == null) return null;
      return GRCModuleModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('[grc-notify] module lookup failed ($moduleId) - $e');
      return null;
    }
  }

  /// English policy name, '' when it cannot be read.
  static Future<String> policyName(String moduleId, String policyId) async {
    if (moduleId.isEmpty || policyId.isEmpty) return '';
    try {
      final doc = await _moduleRef(moduleId)
          .collection('Policies')
          .doc(policyId)
          .get();
      final data = doc.data();
      if (data == null) return '';
      return PolicyModel.fromJson(data).toEntity().policyNameEn;
    } catch (e) {
      debugPrint('[grc-notify] policy lookup failed ($policyId) - $e');
      return '';
    }
  }

  /// The control document, or null when it cannot be read.
  static Future<ControlEntity?> control(
    String moduleId,
    String policyId,
    String controlId,
  ) async {
    if (moduleId.isEmpty || policyId.isEmpty || controlId.isEmpty) return null;
    try {
      final doc = await _moduleRef(moduleId)
          .collection('Policies')
          .doc(policyId)
          .collection('Controls')
          .doc(controlId)
          .get();
      final data = doc.data();
      if (data == null) return null;
      return ControlModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('[grc-notify] control lookup failed ($controlId) - $e');
      return null;
    }
  }

  /// Every control under [policyId]; empty when nothing can be read.
  static Future<List<ControlEntity>> policyControls(
    String moduleId,
    String policyId,
  ) async {
    if (moduleId.isEmpty || policyId.isEmpty) return const <ControlEntity>[];
    try {
      final snapshot = await _moduleRef(moduleId)
          .collection('Policies')
          .doc(policyId)
          .collection('Controls')
          .get();
      return snapshot.docs
          .map((doc) => ControlModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      debugPrint('[grc-notify] controls lookup failed ($policyId) - $e');
      return const <ControlEntity>[];
    }
  }

  /// English control name, '' when it cannot be read.
  static Future<String> controlName(
    String moduleId,
    String policyId,
    String controlId,
  ) async =>
      (await control(moduleId, policyId, controlId))?.controlsNameEn ?? '';

  /// Emails of every active champion and owner currently assigned to
  /// [controlId] under [policyId]. Empty when nothing can be read.
  static Future<Set<String>> controlAssignees(
    String moduleId,
    String policyId,
    String controlId,
  ) async {
    final Set<String> result = <String>{};
    if (moduleId.isEmpty) return result;
    bool covers(List<AssigningControlEntity> pairs) => pairs.any(
        (AssigningControlEntity a) =>
            a.policyId == policyId && a.controlId == controlId);
    try {
      final champions =
          await _moduleRef(moduleId).collection('Control Champions').get();
      for (final doc in champions.docs) {
        final entity = ChampionModel.fromJson(doc.data()).toEntity();
        if (entity.status == ChampionStatus.removed) continue;
        if (covers(entity.assigningControls)) result.add(entity.championEmail);
      }
      final owners =
          await _moduleRef(moduleId).collection('Control Owners').get();
      for (final doc in owners.docs) {
        final entity = OwnerModel.fromJson(doc.data()).toEntity();
        if (entity.status == OwnerStatus.removed) continue;
        if (covers(entity.assigningControls)) result.add(entity.ownerEmail);
      }
    } catch (e) {
      debugPrint('[grc-notify] assignee lookup failed ($controlId) - $e');
    }
    return result;
  }

  /// Emails of the manager(s) of the department called [departmentName]
  /// (English or Arabic) — the same "title starts with Chief" rule
  /// findDepartmentManagerEmail uses for evidence approvals.
  static Set<String> departmentManagers(String departmentName) {
    final Set<String> result = <String>{};
    final String wanted = departmentName.trim().toLowerCase();
    if (wanted.isEmpty) return result;
    if (!Get.isRegistered<MainCoreEmployeeController>() ||
        !Get.isRegistered<MainCoreDepartmentCubit>()) {
      return result;
    }
    final departments = Get.find<MainCoreDepartmentCubit>();
    final employees =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    for (final e in employees) {
      final String? departmentId = e.departmentId;
      final String? email = e.email;
      if (departmentId == null || email == null || email.isEmpty) continue;
      if (!(e.title?.trim().toLowerCase().startsWith('chief') ?? false)) {
        continue;
      }
      final String en = departments
              .getEnglishDepartmentNameFromDepartmentId(
                  departmentId: departmentId)
              ?.trim()
              .toLowerCase() ??
          '';
      final String ar = departments
              .getArabicDepartmentNameFromDepartmentId(
                  departmentId: departmentId)
              ?.trim()
              .toLowerCase() ??
          '';
      if (en == wanted || ar == wanted) result.add(email);
    }
    return result;
  }
}
