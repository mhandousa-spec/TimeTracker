/// Module: GRC / shared / debug
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_test_tools.dart
/// Purpose: QA helpers behind the "GRC Test Tools" button on the GRC home
///          page. They exercise the real notification + calendar pipeline
///          end to end so a tester can sign in on one device (the demo
///          account) and watch the results arrive on another (the target
///          account's phone):
///
///          1. [sendAllNotifications] — sends EVERY [GrcNotificationEvent]
///             (all §2.0 GRC rows) to the target through
///             AppNotificationSender, i.e. in-app record + FCM push, with
///             sample values in every placeholder.
///          2. [seedCalendarData] — creates one clearly-labelled "[TEST]"
///             module owned by the target, with policies, controls,
///             champion/owner assignments and reassignment requests dated so
///             that every GRC calendar card appears TODAY (or on the next
///             few days) on the target's calendar.
///          3. [checkCalendar] — runs the three GRC calendar builders for the
///             target email and counts the cards per type, so the result can
///             be compared with what the phone shows.
///          4. [removeTestData] — moves every "[TEST]" module to Removed, which
///             takes all of its cards off every calendar.
/// Author: Knowticed Plus team
/// Created At: 17/9/2026
///
/// ⚠️ QA ONLY. Everything here writes to the live tenant. Turn the button off
/// with [kGrcTestToolsEnabled] before a production release.
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/create_or_update_pending_approval_usecase.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/decide_approval_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/apply_owner_score_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_status.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/apply_my_audit_score_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/create_or_update_pending_my_audit_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/decide_my_audit_usecase.dart';
import 'package:knowticed_plus/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/data_source/calendar_data_service.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/create_champion_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/approve_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/create_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/create_policy_usecase.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_notification_support.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

/// Shows / hides the GRC Test Tools button. Set to false before release.
const bool kGrcTestToolsEnabled = false;

/// The account the tester opens on the phone. Editable in the dialog.
const String kGrcTestDefaultTargetEmail =
    'yousef_jamal_2508@knowticedplus.com';

/// Every test module's English name starts with this, so [removeTestData]
/// can find them again and nobody mistakes them for real data.
const String kGrcTestModulePrefix = '[TEST]';

/// One line of a test report.
class GrcTestResult {
  final String label;
  final bool ok;
  final String detail;

  const GrcTestResult(this.label, {required this.ok, this.detail = ''});
}

abstract final class GrcTestTools {
  static T _sl<T extends Object>() => GetIt.instance<T>();

  static DateTime get _today {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _fmt(DateTime d) => DateFormat('d MMM yyyy', 'en').format(d);

  // ══════════════════════════════════════════════════════════════════════
  //  1. NOTIFICATIONS
  // ══════════════════════════════════════════════════════════════════════

  /// A readable sample for any placeholder, so every event renders fully.
  static String sampleValue(TemplateVariable variable) {
    final String key = variable.key;
    final String lower = key.toLowerCase();
    if (lower.contains('date')) {
      final int shift = lower.startsWith('old') ? -7 : 7;
      return _fmt(_today.add(Duration(days: shift)));
    }
    if (lower.contains('weight')) return lower.startsWith('old') ? '20' : '25';
    if (lower.contains('score')) return lower.startsWith('old') ? '70' : '85';
    if (lower.contains('reason')) return 'Test rejection reason';
    switch (variable) {
      case TemplateVariable.moduleName:
        return '$kGrcTestModulePrefix Information Security';
      case TemplateVariable.policyName:
        return 'Access Control Policy';
      case TemplateVariable.controlName:
        return 'Password Rotation';
      case TemplateVariable.oldControlName:
        return 'Account Lockout';
      case TemplateVariable.newControlName:
        return 'Password Rotation';
      case TemplateVariable.departmentName:
        return 'IT';
      default:
        break;
    }
    if (lower.contains('name')) {
      return 'Test ${key.replaceAll('Name', '').replaceAllMapped(RegExp('[A-Z]'), (m) => ' ${m[0]}').trim()}'
          .trim();
    }
    return 'Test $key';
  }

  static String _pageFor(GrcNotificationEvent event) {
    switch (event.group) {
      case 'Policy & Control':
        return GrcNotificationPage.grcPolicyDetails.key;
      case 'Assignment Controls & Approvals & Audit':
        return GrcNotificationPage.grcAssignmentControls.key;
      case '':
        return GrcNotificationPage.grcModuleDetails.key;
      default:
        return GrcNotificationPage.grcControlChampionDetails.key;
    }
  }

  /// Sends every GRC notification event to [targetEmail] — in-app + FCM.
  ///
  /// [onProgress] is called after each event with (done, total). A result is
  /// "NOT SENT" when the template is disabled in Notification Control or the
  /// write failed; the debug console says which.
  static Future<List<GrcTestResult>> sendAllNotifications({
    required String targetEmail,
    void Function(int done, int total)? onProgress,
  }) async {
    final String target = targetEmail.trim().toLowerCase();
    final String actor = GrcNotify.actorEmail;
    final List<GrcTestResult> results = <GrcTestResult>[];
    final List<GrcNotificationEvent> events = GrcNotificationEvent.values;

    for (int i = 0; i < events.length; i++) {
      final GrcNotificationEvent event = events[i];
      bool ok = false;
      try {
        ok = await AppNotificationSender.sendEvent(
          event: event,
          pageKey: _pageFor(event),
          senderEmail: actor,
          receiverEmail: target,
          isArabic: Get.locale?.languageCode == 'ar',
          variables: <TemplateVariable, String>{
            for (final TemplateVariable v in event.variables) v: sampleValue(v),
          },
        );
      } catch (_) {
        ok = false;
      }
      results.add(GrcTestResult(
        '${i + 1}. ${event.titleEn}',
        ok: ok,
        detail: ok ? event.key : 'NOT SENT (${event.key})',
      ));
      onProgress?.call(i + 1, events.length);
      // A small gap keeps the phone from collapsing ~80 pushes into one.
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    return results;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  2. CALENDAR TEST DATA
  // ══════════════════════════════════════════════════════════════════════

  static Future<R?> _step<R>(
    List<GrcTestResult> log,
    String label,
    Future<Either<Failure, R>> Function() run,
  ) async {
    try {
      final Either<Failure, R> result = await run();
      return result.fold(
        (Failure f) {
          log.add(GrcTestResult(label, ok: false, detail: f.message));
          return null;
        },
        (R value) {
          log.add(GrcTestResult(label, ok: true));
          return value;
        },
      );
    } catch (e) {
      log.add(GrcTestResult(label, ok: false, detail: '$e'));
      return null;
    }
  }

  /// Creates a "[TEST]" module owned by [targetEmail] whose dates make every
  /// GRC calendar card show up today (or within the next days):
  ///
  /// * module activation = today + 14 → "Activation in 14 Days" today
  /// * Policy A: start today, end today + 30 → "Start Date Reached" today
  /// * Policy B: start today − 10, end today → "Expires Today" today
  /// * Policy C: start today, end today + 14 → "Expires in 14 Days" today
  /// * Controls under A (target is champion AND owner of all four):
  ///     C1 today → today            starts today, submission due today
  ///     C2 today → today + 14       submission due in 14 days (today)
  ///     C3 today − 5 → today − 1    submission overdue
  ///     C4 today + 3 → today + 20   assignment scheduled
  /// * Reassignment requests (requested by the signed-in tester):
  ///     pending  champion + owner  → "Pending Approval" (target approves)
  ///     approved champion + owner  → target is the NEW assignee, starting
  ///                                  today and ending today
  static Future<List<GrcTestResult>> seedCalendarData({
    required String targetEmail,
  }) async {
    final List<GrcTestResult> log = <GrcTestResult>[];
    final String target = targetEmail.trim().toLowerCase();
    final String actor = GrcNotify.actorEmail;
    final DateTime today = _today;
    DateTime day(int offset) => today.add(Duration(days: offset));

    if (actor.isEmpty) {
      return const <GrcTestResult>[
        GrcTestResult('Signed-in user', ok: false, detail: 'No actor email.'),
      ];
    }
    if (actor.toLowerCase() == target) {
      log.add(const GrcTestResult(
        'Warning',
        ok: false,
        detail: 'Tester and target are the same account — pending requests '
            'are hidden from their own requester.',
      ));
    }

    final String stamp = DateFormat('d MMM HH:mm', 'en').format(DateTime.now());

    // ── Module ──────────────────────────────────────────────────────────
    final GRCModuleEntity? module = await _step<GRCModuleEntity>(
      log,
      'Create test module (owner: $target)',
      () => _sl<CreateGRCModuleUseCase>().execute(
        grcModuleNameEnglish: '$kGrcTestModulePrefix GRC Calendar $stamp',
        grcModuleNameArabic: '$kGrcTestModulePrefix تقويم الحوكمة $stamp',
        descriptionEnglish: 'Generated by GRC Test Tools. Safe to remove.',
        descriptionArabic: 'تم إنشاؤها بواسطة أدوات اختبار الحوكمة.',
        owningDepartment: 'IT',
        activationDate: day(14),
        owners: <String>[target],
        status: GrcModuleStatus.active.value,
        editorId: actor,
      ),
    );
    if (module == null) return log;
    final String moduleId = module.moduleId;

    // ── Policies ────────────────────────────────────────────────────────
    Future<PolicyEntity?> policy(String name, int start, int end) =>
        _step<PolicyEntity>(
          log,
          'Create policy "$name" (${_fmt(day(start))} → ${_fmt(day(end))})',
          () => _sl<CreatePolicyUseCase>().call(CreatePolicyParams(
            policyNameEn: name,
            policyNameAr: name,
            policyNumberEn: 'T-${name.hashCode.abs() % 1000}',
            policyNumberAr: 'T-${name.hashCode.abs() % 1000}',
            policyDescriptionEn: 'Test policy',
            policyDescriptionAr: 'سياسة اختبار',
            startDate: day(start),
            endDate: day(end),
            policyWeight: 33,
            editorId: actor,
            moduleId: moduleId,
            status: PolicyStatus.active,
          )),
        );

    final PolicyEntity? policyA = await policy('Test Policy A', 0, 30);
    await policy('Test Policy B (expires today)', -10, 0);
    await policy('Test Policy C (expires in 14 days)', 0, 14);
    if (policyA == null) return log;

    // ── Controls under Policy A ─────────────────────────────────────────
    Future<ControlEntity?> control(String name, int start, int end) =>
        _step<ControlEntity>(
          log,
          'Create control "$name" (${_fmt(day(start))} → ${_fmt(day(end))})',
          () => _sl<CreateControlUseCase>().call(CreateControlParams(
            moduleId: moduleId,
            policyId: policyA.id,
            editorId: actor,
            controlsNameEn: name,
            controlsNameAr: name,
            controlsNumberEn: name.split(' ').first,
            controlsNumberAr: name.split(' ').first,
            controlsDescriptionEn: 'Test control',
            controlsDescriptionAr: 'ضابط اختبار',
            controlsWeight: 25,
            frequency: 'Monthly',
            startDate: day(start),
            endDate: day(end),
            departments: const <String>[],
            departmentsWeights: const <double>[],
            equalWeights: true,
            score: 0,
            status: ControlStatus.computeDateBased(day(start)),
          )),
        );

    final List<ControlEntity> controls = <ControlEntity>[
      for (final ControlEntity? c in <ControlEntity?>[
        await control('C1 Starts & due today', 0, 0),
        await control('C2 Due in 14 days', 0, 14),
        await control('C3 Overdue', -5, -1),
        await control('C4 Scheduled', 3, 20),
      ])
        if (c != null) c,
    ];
    if (controls.isEmpty) return log;

    final List<AssigningControlEntity> pairs = <AssigningControlEntity>[
      for (final ControlEntity c in controls)
        AssigningControlEntity(policyId: policyA.id, controlId: c.id),
    ];

    // ── Target as champion and owner ────────────────────────────────────
    await _step(
      log,
      'Assign $target as Control Champion (${pairs.length} controls)',
      () => _sl<CreateChampionUseCase>().call(CreateChampionParams(
        moduleId: moduleId,
        championEmail: target,
        assigningControls: pairs,
        editorId: actor,
      )),
    );
    await _step(
      log,
      'Assign $target as Control Owner (${pairs.length} controls)',
      () => _sl<CreateOwnerUseCase>().call(CreateOwnerParams(
        moduleId: moduleId,
        ownerEmail: target,
        assigningControls: pairs,
        editorId: actor,
      )),
    );

    // ── Reassignment requests ───────────────────────────────────────────
    final List<AssigningControlEntity> firstPair = pairs.take(1).toList();

    // Pending — the target (module owner) is the approver.
    await _step(
      log,
      'Pending champion reassignment (target approves)',
      () => _sl<CreateGrcRequestUseCase>().call(CreateGrcRequestParams(
        moduleId: moduleId,
        requestedBy: actor,
        note: 'GRC Test Tools',
        currentChampionEmail: target,
        newChampionEmail: actor,
        controls: firstPair,
        startDate: today,
        endDate: day(10),
      )),
    );
    await _step(
      log,
      'Pending owner reassignment (target approves)',
      () => _sl<CreateGrcRequestUseCase>().call(CreateGrcRequestParams(
        moduleId: moduleId,
        requestedBy: actor,
        note: 'GRC Test Tools',
        type: GrcRequestType.reassignOwner,
        currentOwnerEmail: target,
        newOwnerEmail: actor,
        controls: firstPair,
        startDate: today,
        endDate: day(10),
      )),
    );

    // Approved — the target is the incoming assignee, today → today.
    Future<void> approved(GrcRequestType type) async {
      final bool champion = type == GrcRequestType.reassignChampion;
      final GrcRequestEntity? request = await _step<GrcRequestEntity>(
        log,
        'Approved ${champion ? 'champion' : 'owner'} reassignment '
            '(target is new assignee)',
        () => _sl<CreateGrcRequestUseCase>().call(CreateGrcRequestParams(
          moduleId: moduleId,
          requestedBy: actor,
          note: 'GRC Test Tools',
          type: type,
          currentChampionEmail: champion ? actor : null,
          newChampionEmail: champion ? target : null,
          currentOwnerEmail: champion ? null : actor,
          newOwnerEmail: champion ? null : target,
          controls: firstPair,
          startDate: today,
          endDate: today,
        )),
      );
      if (request == null) return;
      await _step(
        log,
        '  └ approve it',
        () => _sl<ApproveGrcRequestUseCase>().call(ApproveGrcRequestParams(
          moduleId: moduleId,
          requestId: request.id,
          decidedBy: actor,
        )),
      );
    }

    await approved(GrcRequestType.reassignChampion);
    await approved(GrcRequestType.reassignOwner);

    log.add(GrcTestResult(
      'Done — open the Calendar as $target',
      ok: true,
      detail: 'Module id: $moduleId',
    ));
    return log;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  3. CALENDAR CHECK
  // ══════════════════════════════════════════════════════════════════════

  /// Runs the three GRC calendar builders for [targetEmail] — exactly what
  /// that user's Calendar screen runs — and counts the cards per type.
  static Future<List<GrcTestResult>> checkCalendar({
    required String targetEmail,
  }) async {
    final String target = targetEmail.trim().toLowerCase();
    if (!Get.isRegistered<MainCoreDepartmentCubit>()) {
      return const <GrcTestResult>[
        GrcTestResult('Calendar service', ok: false,
            detail: 'MainCoreDepartmentCubit is not registered.'),
      ];
    }
    final CalendarDataService service = CalendarDataService(
      departmentCubit: Get.find<MainCoreDepartmentCubit>(),
    );

    final List<GrcTestResult> results = <GrcTestResult>[];
    final Map<String, Future<List<CalendarEventModel>> Function()> sources =
        <String, Future<List<CalendarEventModel>> Function()>{
      'GRC module': () =>
          service.getGrcCalendarEvents(currentUserEmail: target),
      'GRC policy': () =>
          service.getGrcPolicyCalendarEvents(currentUserEmail: target),
      'GRC control': () =>
          service.getGrcControlCalendarEvents(currentUserEmail: target),
    };

    for (final MapEntry<String, Future<List<CalendarEventModel>> Function()>
        source in sources.entries) {
      try {
        final List<CalendarEventModel> events = await source.value();
        results.add(GrcTestResult(
          '${source.key}: ${events.length} card(s)',
          ok: events.isNotEmpty,
          detail: events.isEmpty ? 'Nothing for $target' : '',
        ));
        final Map<String, List<CalendarEventModel>> byType =
            <String, List<CalendarEventModel>>{};
        for (final CalendarEventModel e in events) {
          byType
              .putIfAbsent(e.type?.titleEn ?? e.status, () => [])
              .add(e);
        }
        for (final MapEntry<String, List<CalendarEventModel>> t
            in byType.entries) {
          final List<String> days = t.value
              .map((CalendarEventModel e) => _fmt(e.date))
              .toSet()
              .toList();
          results.add(GrcTestResult(
            '   • ${t.key} × ${t.value.length}',
            ok: true,
            detail: days.join(', '),
          ));
        }
      } catch (e) {
        results.add(GrcTestResult(source.key, ok: false, detail: '$e'));
      }
    }
    return results;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  3b. APPROVALS TEST DATA
  // ══════════════════════════════════════════════════════════════════════

  /// Fills the Approvals page of the newest "[TEST]" module for the
  /// SIGNED-IN account. The Approvals list only shows submissions whose
  /// Department Manager is the viewer, so every submission here names the
  /// signed-in tester as manager and [targetEmail] as champion + owner.
  ///
  /// Controls of "Test Policy A" (run "Create calendar test data" first):
  ///   1st control → Pending
  ///   2nd control → Approved
  ///   3rd control → Rejected
  ///   4th control → Pending
  static Future<List<GrcTestResult>> seedApprovals({
    required String targetEmail,
  }) async {
    final List<GrcTestResult> log = <GrcTestResult>[];
    final String champion = targetEmail.trim().toLowerCase();
    final String manager = GrcNotify.actorEmail;
    if (manager.isEmpty) {
      return const <GrcTestResult>[
        GrcTestResult('Signed-in user', ok: false, detail: 'No actor email.'),
      ];
    }

    // ── Newest active test module ───────────────────────────────────────
    final List<GRCModuleEntity>? modules = await _step<List<GRCModuleEntity>>(
      log,
      'Load modules',
      () => _sl<GetAllGRCModulesUseCase>().execute(),
    );
    final List<GRCModuleEntity> tests = (modules ?? const <GRCModuleEntity>[])
        .where((GRCModuleEntity m) =>
            m.moduleNameEn.startsWith(kGrcTestModulePrefix) && !m.isRemoved)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (tests.isEmpty) {
      log.add(const GrcTestResult('No test module',
          ok: false, detail: 'Run "Create calendar test data" first.'));
      return log;
    }
    final GRCModuleEntity module = tests.first;
    final String moduleId = module.moduleId;
    log.add(GrcTestResult('Using "${module.moduleNameEn}"', ok: true));

    // ── Policy A and its controls ───────────────────────────────────────
    final List<PolicyEntity>? policies = await _step<List<PolicyEntity>>(
      log,
      'Load policies',
      () => _sl<GetAllPoliciesUseCase>().call(moduleId: moduleId),
    );
    PolicyEntity? policyA;
    for (final PolicyEntity p in policies ?? const <PolicyEntity>[]) {
      if (p.policyNameEn == 'Test Policy A') policyA = p;
    }
    if (policyA == null) {
      log.add(const GrcTestResult('Test Policy A not found', ok: false));
      return log;
    }
    final String policyId = policyA.id;
    final List<ControlEntity>? controls = await _step<List<ControlEntity>>(
      log,
      'Load controls of Test Policy A',
      () => _sl<GetAllControlsUseCase>()
          .call(moduleId: moduleId, policyId: policyId),
    );
    if (controls == null || controls.isEmpty) return log;

    // ── Evidence file ───────────────────────────────────────────────────
    final File evidence = File(
      '${Directory.systemTemp.path}/grc_test_evidence.txt',
    );
    await evidence.writeAsString(
      'GRC Test Tools evidence — ${DateTime.now().toIso8601String()}',
    );

    // ── Submit + decide ─────────────────────────────────────────────────
    const List<ApprovalStatus?> plan = <ApprovalStatus?>[
      null, // pending
      ApprovalStatus.approved,
      ApprovalStatus.rejected,
      null, // pending
    ];
    for (int i = 0; i < controls.length && i < plan.length; i++) {
      final ControlEntity c = controls[i];
      final String name = c.controlsNameEn;

      final AssignmentControlEntity? submitted =
          await _step<AssignmentControlEntity>(
        log,
        'Submit evidence for "$name" (manager: $manager)',
        () => _sl<SubmitEvidenceUseCase>().call(SubmitEvidenceParams(
          moduleId: moduleId,
          policyId: policyId,
          controlId: c.id,
          championEmail: champion,
          controlOwnerEmail: champion,
          departmentManagerEmail: manager,
          documentFile: evidence,
          note: 'GRC Test Tools submission',
          editorEmail: champion,
        )),
      );
      if (submitted == null) continue;

      await _step(
        log,
        '  └ approval → Pending',
        () => _sl<CreateOrUpdatePendingApprovalUseCase>().call(
          CreateOrUpdatePendingApprovalParams(
            moduleId: moduleId,
            controlId: c.id,
            championEmail: champion,
            editorEmail: champion,
          ),
        ),
      );

      final ApprovalStatus? decision = plan[i];
      if (decision == null) continue;
      final bool approve = decision == ApprovalStatus.approved;
      const String reason = 'Test rejection reason';

      await _step(
        log,
        '  └ approval → ${approve ? 'Approved' : 'Rejected'}',
        () => _sl<DecideApprovalUseCase>().call(DecideApprovalParams(
          moduleId: moduleId,
          controlId: c.id,
          championEmail: champion,
          status: decision.value,
          approvalComment: approve ? 'Looks good (test)' : null,
          reasonOfRejection: approve ? null : reason,
          editorEmail: manager,
        )),
      );
      await _step(
        log,
        '  └ assignment → ${approve ? 'In Review' : 'Rejected'}',
        () => _sl<ApplyManagerDecisionUseCase>().call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: c.id,
            championEmail: champion,
            newStatus: approve
                ? AssignmentControlStatus.inReview
                : AssignmentControlStatus.rejected,
            rejectionReason: approve ? null : reason,
            editorEmail: manager,
          ),
        ),
      );
    }

    log.add(GrcTestResult(
      'Done — open "${module.moduleNameEn}" → Approvals',
      ok: true,
      detail: 'Signed in as $manager',
    ));
    return log;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  3c. MY AUDITS TEST DATA
  // ══════════════════════════════════════════════════════════════════════

  /// Fills My Audits of the newest "[TEST]" module for the SIGNED-IN
  /// account (My Audits lists submissions whose Control Owner is the viewer).
  /// The signed-in tester is Control Owner, Champion and Department Manager,
  /// so the Assignment_Controls ids (`<control>_<tester>`) are new and do not
  /// clash with the ones "Create approvals test data" made.
  ///
  ///   C1 → Pending      (manager approved, owner not decided yet)
  ///   C2 → Outstanding  (owner approved, no score yet)
  ///   C4 → Scored       (score 85)
  ///   C5 → Rejected     (new control, rejected by the owner)
  ///   C3 → Overdue      (assigned to the tester, ended yesterday, never
  ///                      submitted by the tester)
  static Future<List<GrcTestResult>> seedMyAudits() async {
    final List<GrcTestResult> log = <GrcTestResult>[];
    final String me = GrcNotify.actorEmail;
    if (me.isEmpty) {
      return const <GrcTestResult>[
        GrcTestResult('Signed-in user', ok: false, detail: 'No actor email.'),
      ];
    }
    final DateTime today = _today;

    // ── Newest active test module ───────────────────────────────────────
    final List<GRCModuleEntity>? modules = await _step<List<GRCModuleEntity>>(
      log,
      'Load modules',
      () => _sl<GetAllGRCModulesUseCase>().execute(),
    );
    final List<GRCModuleEntity> tests = (modules ?? const <GRCModuleEntity>[])
        .where((GRCModuleEntity m) =>
            m.moduleNameEn.startsWith(kGrcTestModulePrefix) && !m.isRemoved)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (tests.isEmpty) {
      log.add(const GrcTestResult('No test module',
          ok: false, detail: 'Run "Create calendar test data" first.'));
      return log;
    }
    final GRCModuleEntity module = tests.first;
    final String moduleId = module.moduleId;
    log.add(GrcTestResult('Using "${module.moduleNameEn}"', ok: true));

    // ── Policy A and its controls ───────────────────────────────────────
    final List<PolicyEntity>? policies = await _step<List<PolicyEntity>>(
      log,
      'Load policies',
      () => _sl<GetAllPoliciesUseCase>().call(moduleId: moduleId),
    );
    PolicyEntity? policyA;
    for (final PolicyEntity p in policies ?? const <PolicyEntity>[]) {
      if (p.policyNameEn == 'Test Policy A') policyA = p;
    }
    if (policyA == null) {
      log.add(const GrcTestResult('Test Policy A not found', ok: false));
      return log;
    }
    final String policyId = policyA.id;

    Future<List<ControlEntity>> loadControls() async =>
        await _step<List<ControlEntity>>(
          log,
          'Load controls of Test Policy A',
          () => _sl<GetAllControlsUseCase>()
              .call(moduleId: moduleId, policyId: policyId),
        ) ??
        const <ControlEntity>[];

    List<ControlEntity> controls = await loadControls();
    ControlEntity? byPrefix(String prefix) {
      for (final ControlEntity c in controls) {
        if (c.controlsNameEn.startsWith(prefix)) return c;
      }
      return null;
    }

    // C5 is new, so the Rejected tab has its own row.
    if (byPrefix('C5') == null) {
      await _step<ControlEntity>(
        log,
        'Create control "C5 Audit Rejected"',
        () => _sl<CreateControlUseCase>().call(CreateControlParams(
          moduleId: moduleId,
          policyId: policyId,
          editorId: me,
          controlsNameEn: 'C5 Audit Rejected',
          controlsNameAr: 'C5 Audit Rejected',
          controlsNumberEn: 'C5',
          controlsNumberAr: 'C5',
          controlsDescriptionEn: 'Test control',
          controlsDescriptionAr: 'ضابط اختبار',
          controlsWeight: 25,
          frequency: 'Monthly',
          startDate: today,
          endDate: today.add(const Duration(days: 14)),
          departments: const <String>[],
          departmentsWeights: const <double>[],
          equalWeights: true,
          score: 0,
          status: ControlStatus.computeDateBased(today),
        )),
      );
      controls = await loadControls();
    }

    final ControlEntity? c1 = byPrefix('C1');
    final ControlEntity? c2 = byPrefix('C2');
    final ControlEntity? c3 = byPrefix('C3');
    final ControlEntity? c4 = byPrefix('C4');
    final ControlEntity? c5 = byPrefix('C5');

    // ── Tester as Control Owner of all of them ──────────────────────────
    final List<AssigningControlEntity> pairs = <AssigningControlEntity>[
      for (final ControlEntity? c in <ControlEntity?>[c1, c2, c3, c4, c5])
        if (c != null) AssigningControlEntity(policyId: policyId, controlId: c.id),
    ];
    await _step(
      log,
      'Assign $me as Control Owner (${pairs.length} controls)',
      () => _sl<CreateOwnerUseCase>().call(CreateOwnerParams(
        moduleId: moduleId,
        ownerEmail: me,
        assigningControls: pairs,
        editorId: me,
      )),
    );

    // ── Evidence file ───────────────────────────────────────────────────
    final File evidence = File(
      '${Directory.systemTemp.path}/grc_test_audit_evidence.txt',
    );
    await evidence.writeAsString(
      'GRC Test Tools audit evidence — ${DateTime.now().toIso8601String()}',
    );

    // Submit → manager approves → My Audit Pending.
    Future<bool> toPending(ControlEntity c) async {
      final String name = c.controlsNameEn;
      final AssignmentControlEntity? submitted =
          await _step<AssignmentControlEntity>(
        log,
        'Submit evidence for "$name"',
        () => _sl<SubmitEvidenceUseCase>().call(SubmitEvidenceParams(
          moduleId: moduleId,
          policyId: policyId,
          controlId: c.id,
          championEmail: me,
          controlOwnerEmail: me,
          departmentManagerEmail: me,
          documentFile: evidence,
          note: 'GRC Test Tools audit submission',
          editorEmail: me,
        )),
      );
      if (submitted == null) return false;
      await _step(
        log,
        '  └ approval → Pending',
        () => _sl<CreateOrUpdatePendingApprovalUseCase>().call(
          CreateOrUpdatePendingApprovalParams(
            moduleId: moduleId,
            controlId: c.id,
            championEmail: me,
            editorEmail: me,
          ),
        ),
      );
      await _step(
        log,
        '  └ approval → Approved',
        () => _sl<DecideApprovalUseCase>().call(DecideApprovalParams(
          moduleId: moduleId,
          controlId: c.id,
          championEmail: me,
          status: ApprovalStatus.approved.value,
          approvalComment: 'Looks good (test)',
          editorEmail: me,
        )),
      );
      await _step(
        log,
        '  └ assignment → In Review',
        () => _sl<ApplyManagerDecisionUseCase>().call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: c.id,
            championEmail: me,
            newStatus: AssignmentControlStatus.inReview,
            editorEmail: me,
          ),
        ),
      );
      final Object? audit = await _step(
        log,
        '  └ my audit → Pending',
        () => _sl<CreateOrUpdatePendingMyAuditUseCase>().call(
          CreateOrUpdatePendingMyAuditParams(
            moduleId: moduleId,
            controlId: c.id,
            championEmail: me,
            editorEmail: me,
          ),
        ),
      );
      return audit != null;
    }

    Future<void> ownerDecides(ControlEntity c, MyAuditStatus status) =>
        _step(
          log,
          '  └ my audit → ${status.value}',
          () => _sl<DecideMyAuditUseCase>().call(DecideMyAuditParams(
            moduleId: moduleId,
            controlId: c.id,
            championEmail: me,
            status: status.value,
            reasonOfRejection: status == MyAuditStatus.rejected
                ? 'Test rejection reason'
                : null,
            editorEmail: me,
          )),
        );

    // C1 → Pending
    if (c1 != null) await toPending(c1);

    // C2 → Outstanding
    if (c2 != null && await toPending(c2)) {
      await ownerDecides(c2, MyAuditStatus.outstanding);
    }

    // C4 → Scored
    if (c4 != null && await toPending(c4)) {
      await ownerDecides(c4, MyAuditStatus.outstanding);
      const double score = 85;
      await _step(
        log,
        '  └ my audit → Scored ($score)',
        () => _sl<ApplyMyAuditScoreUseCase>().call(ApplyMyAuditScoreParams(
          moduleId: moduleId,
          controlId: c4.id,
          championEmail: me,
          score: score,
          justification: 'Test score',
          editorEmail: me,
        )),
      );
      await _step(
        log,
        '  └ assignment → Approved',
        () => _sl<ApplyOwnerScoreUseCase>().call(ApplyOwnerScoreParams(
          moduleId: moduleId,
          controlId: c4.id,
          championEmail: me,
          score: score,
          justification: 'Test score',
          editorEmail: me,
        )),
      );
      try {
        await _sl<RecalculateScoreRollupUseCase>().call(
          moduleId: moduleId,
          policyId: policyId,
          controlId: c4.id,
          controlScore: score,
          editorEmail: me,
        );
        log.add(const GrcTestResult('  └ score roll-up', ok: true));
      } catch (e) {
        log.add(GrcTestResult('  └ score roll-up', ok: false, detail: '$e'));
      }
    }

    // C5 → Rejected
    if (c5 != null && await toPending(c5)) {
      await ownerDecides(c5, MyAuditStatus.rejected);
      await _step(
        log,
        '  └ assignment → Rejected',
        () => _sl<ApplyManagerDecisionUseCase>().call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: c5.id,
            championEmail: me,
            newStatus: AssignmentControlStatus.rejected,
            rejectionReason: 'Test rejection reason',
            editorEmail: me,
          ),
        ),
      );
    }

    // C3 → Overdue: nothing to write — it is owned by the tester, ended
    // yesterday and has no submission from the tester.
    if (c3 != null) {
      log.add(GrcTestResult('"${c3.controlsNameEn}" → Overdue', ok: true));
    }

    log.add(GrcTestResult(
      'Done — open "${module.moduleNameEn}" → My Audits',
      ok: true,
      detail: 'Signed in as $me',
    ));
    return log;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  4. CLEAN-UP
  // ══════════════════════════════════════════════════════════════════════

  /// Moves every "[TEST]" module to Removed. The calendar skips removed
  /// modules, so all generated cards disappear.
  static Future<List<GrcTestResult>> removeTestData() async {
    final List<GrcTestResult> log = <GrcTestResult>[];
    final String actor = GrcNotify.actorEmail;
    final List<GRCModuleEntity>? modules = await _step<List<GRCModuleEntity>>(
      log,
      'Load modules',
      () => _sl<GetAllGRCModulesUseCase>().execute(),
    );
    final List<GRCModuleEntity> tests = (modules ?? const <GRCModuleEntity>[])
        .where((GRCModuleEntity m) =>
            m.moduleNameEn.startsWith(kGrcTestModulePrefix) && !m.isRemoved)
        .toList();
    if (tests.isEmpty) {
      log.add(const GrcTestResult('No test modules to remove', ok: true));
    }
    for (final GRCModuleEntity m in tests) {
      await _step(
        log,
        'Remove "${m.moduleNameEn}"',
        () => _sl<DeleteGRCModuleUseCase>().execute(
          id: m.moduleId,
          editorId: actor,
        ),
      );
    }
    return log;
  }
}
