/// Module: GRC — Action Center
///
///*************************** FILE INFO ****************************///
/// File Name: grc_action_issue.dart
/// Purpose: One row of the Action Center table (Figma MAGDY, "MAIN PAGE :
///          Creating , Editing , Deleting Module" → Action Center frames)
///          and the pure rules that find those rows in the loaded GRC data.
/// Author: Amr Mesbah
/// Created: 17/9/2026
///
/// Rules (Figma issue texts):
/// * Errors
///   - module: Active/Scheduled policy weights do not add up to 100
///   - policy: weight 0            → "Weight missing (0%)"
///   - policy: no controls         → "Policy has 0 controls"
///   - policy: control weights ≠ 100 → "Weight sum X% (needs 100%)"
///   - policy: no document at all  → "No document uploaded"
///   - control: Unassigned         → "Unassigned · no owner"
/// * Recommendations
///   - policy: only one language document → "English present · Arabic missing"
///   - policy / control: Draft     → "Draft → needs completion"
///   - policy: not edited for 2 years → "Stale · not updated 2yr"
///   - control: Active, started, never scored → "No score given"
///   - control: scored below [kGrcBaselineScore] → "Below baseline · score X"
///   - control: no frequency       → "Frequency not set"
/// * Expired
///   - policy / control with status Expired, or an end date already passed
///
/// Only Active / Scheduled policies are checked for errors (the same set the
/// weight rules count); Inactive ones are out of effect and skipped.
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_dashboard_stats.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';

/// Scores under this are "Below baseline".
const int kGrcBaselineScore = 50;

enum GrcIssueKind { error, recommendation, expired }

class GrcActionIssue {
  final GRCModuleEntity module;

  /// Null for a module-level issue (policy weights).
  final PolicyEntity? policy;

  /// Null for a policy-level issue.
  final ControlEntity? control;

  final GrcIssueKind kind;
  final String messageEn;
  final String messageAr;

  /// Raw department keys the row belongs to (for the department picker).
  final Set<String> departments;

  const GrcActionIssue({
    required this.module,
    required this.kind,
    required this.messageEn,
    required this.messageAr,
    this.policy,
    this.control,
    this.departments = const <String>{},
  });

  String message({required bool isArabic}) => isArabic ? messageAr : messageEn;

  String moduleName({required bool isArabic}) =>
      module.localizedName(isArabic: isArabic);

  String policyName({required bool isArabic}) =>
      policy?.localizedName(isArabic: isArabic) ?? '—';

  String controlName({required bool isArabic}) {
    final c = control;
    if (c == null) return '—';
    return isArabic && c.controlsNameAr.trim().isNotEmpty
        ? c.controlsNameAr
        : c.controlsNameEn;
  }

  /// Search haystack (both languages).
  String get searchText => [
        module.moduleNameEn,
        module.moduleNameAr,
        policy?.policyNameEn ?? '',
        policy?.policyNameAr ?? '',
        control?.controlsNameEn ?? '',
        control?.controlsNameAr ?? '',
        messageEn,
        messageAr,
      ].join(' ').toLowerCase();
}

/// Finds every issue in [data].
List<GrcActionIssue> buildGrcActionIssues(
  GrcDashboardData data, {
  DateTime? now,
}) {
  final DateTime clock = now ?? DateTime.now();
  final DateTime today = DateTime(clock.year, clock.month, clock.day);
  final DateTime staleBefore = DateTime(clock.year - 2, clock.month, clock.day);
  final issues = <GrcActionIssue>[];

  String dateEn(DateTime d) => DateFormat('d MMM yyyy', 'en').format(d);
  String dateAr(DateTime d) => DateFormat('d MMM yyyy', 'ar').format(d);
  String pct(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  for (final snap in data.snapshots) {
    final module = snap.module;
    final policies =
        snap.policies.where((p) => p.status != PolicyStatus.removed).toList();

    Set<String> deptsOf(List<ControlEntity> controls) {
      final out = <String>{
        for (final c in controls)
          for (final d in c.departments)
            if (d.department.trim().isNotEmpty) d.department.trim(),
      };
      if (out.isEmpty && module.moduleOwningDepartment.trim().isNotEmpty) {
        out.add(module.moduleOwningDepartment.trim());
      }
      return out;
    }

    // ── module: policy weights ────────────────────────────────────────
    final scoped = policies
        .where((p) => GrcDashboardData.weightScopedPolicies.contains(p.status));
    if (scoped.isNotEmpty) {
      final total = scoped.fold<double>(0, (s, p) => s + p.policyWeight);
      if ((total - 100).abs() >= 0.001) {
        issues.add(GrcActionIssue(
          module: module,
          kind: GrcIssueKind.error,
          messageEn: 'Policies weight sum ${pct(total)}% (needs 100%)',
          messageAr: 'مجموع أوزان السياسات ${pct(total)}% (المطلوب 100%)',
          departments: deptsOf(const []),
        ));
      }
    }

    for (final policy in policies) {
      final controls = snap.controlsByPolicy[policy.id] ?? const <ControlEntity>[];
      final depts = deptsOf(controls);

      void add(GrcIssueKind kind, String en, String ar, {ControlEntity? c}) {
        issues.add(GrcActionIssue(
          module: module,
          policy: policy,
          control: c,
          kind: kind,
          messageEn: en,
          messageAr: ar,
          departments: c == null ? depts : deptsOf([c]),
        ));
      }

      // ── policy ──────────────────────────────────────────────────────
      if (policy.status == PolicyStatus.draft) {
        add(GrcIssueKind.recommendation, 'Draft → needs completion',
            'مسودة ← تحتاج إلى استكمال');
        continue;
      }

      final bool policyExpired = policy.status == PolicyStatus.expired ||
          (policy.status != PolicyStatus.inactive &&
              policy.endDate.isBefore(today));
      if (policyExpired) {
        add(GrcIssueKind.expired, 'Policy expired ${dateEn(policy.endDate)}',
            'انتهت السياسة ${dateAr(policy.endDate)}');
        continue;
      }

      if (!GrcDashboardData.weightScopedPolicies.contains(policy.status)) {
        continue; // Inactive
      }

      if (policy.policyWeight <= 0) {
        add(GrcIssueKind.error, 'Weight missing (0%)', 'الوزن غير محدد (0%)');
      }

      if (controls.isEmpty) {
        add(GrcIssueKind.error, 'Policy has 0 controls',
            'السياسة لا تحتوي على ضوابط');
      } else if (controls.hasControlWeightIssue) {
        final total = controls.totalControlWeight;
        add(GrcIssueKind.error, 'Weight sum ${pct(total)}% (needs 100%)',
            'مجموع الأوزان ${pct(total)}% (المطلوب 100%)');
      }

      final bool hasEn = (policy.policyDocumentEn ?? '').trim().isNotEmpty;
      final bool hasAr = (policy.policyDocumentAr ?? '').trim().isNotEmpty;
      if (!hasEn && !hasAr) {
        add(GrcIssueKind.error, 'No document uploaded', 'لم يتم رفع مستند');
      } else if (hasEn && !hasAr) {
        add(GrcIssueKind.recommendation, 'English present · Arabic missing',
            'الإنجليزية موجودة · العربية مفقودة');
      } else if (hasAr && !hasEn) {
        add(GrcIssueKind.recommendation, 'Arabic present · English missing',
            'العربية موجودة · الإنجليزية مفقودة');
      }

      if (policy.lastModifiedDate.isBefore(staleBefore)) {
        add(GrcIssueKind.recommendation, 'Stale · not updated 2yr',
            'قديمة · لم تُحدَّث منذ سنتين');
      }

      // ── controls ────────────────────────────────────────────────────
      for (final c in controls) {
        if (c.status == ControlStatus.draft) {
          add(GrcIssueKind.recommendation, 'Draft → needs completion',
              'مسودة ← تحتاج إلى استكمال',
              c: c);
          continue;
        }
        if (c.status == ControlStatus.inactive) continue;

        final bool expired = c.status == ControlStatus.expired ||
            c.endDate.isBefore(today);
        if (expired) {
          add(GrcIssueKind.expired, 'Control expired ${dateEn(c.endDate)}',
              'انتهى الضابط ${dateAr(c.endDate)}',
              c: c);
          continue;
        }

        if (c.status == ControlStatus.unassigned) {
          add(GrcIssueKind.error, 'Unassigned · no owner',
              'غير معيّن · بلا مالك',
              c: c);
        }

        if (c.frequency.trim().isEmpty) {
          add(GrcIssueKind.recommendation, 'Frequency not set',
              'التكرار غير محدد',
              c: c);
        }

        if (c.status == ControlStatus.active) {
          final bool started = !c.startDate.isAfter(clock);
          if (c.score <= 0 && c.scoreHistory.isEmpty && started) {
            add(GrcIssueKind.recommendation, 'No score given',
                'لم تُمنح درجة',
                c: c);
          } else if (c.score > 0 && c.score < kGrcBaselineScore) {
            add(GrcIssueKind.recommendation,
                'Below baseline · score ${c.score}',
                'أقل من الحد الأدنى · الدرجة ${c.score}',
                c: c);
          }
        }
      }
    }
  }
  return issues;
}
