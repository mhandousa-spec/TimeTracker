/// Module: GRC — Final Score Rollup
/// Description: Recomputes and persists Control -> Policy -> Module scores.
///              [call] runs the full chain after a Control Owner submits or
///              edits a score in My Audits; [recalculatePolicyScore] and
///              [recalculateModuleScore] are exposed separately for the
///              Policy/Control Weight Issue flows, where a weight changes
///              but no Control score does. See
///              docs/superpowers/specs/2026-07-29-score-rollup-design.md.
///              This is the only place this calculation happens — it is a
///              plain domain-layer class, not a Cubit, and depends only on
///              already-existing repositories/use cases (no new Firestore
///              access code). Best-effort: every step's Either result is
///              unwrapped with a safe fallback rather than short-circuiting,
///              matching the existing precedent where ApprovalCubit's
///              linked-My-Audit creation isn't folded/checked either — the
///              caller's own success does not depend on this succeeding.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-29
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/update_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/update_policy_usecase.dart';

/// The Policy's own weighted share of its Module —
/// Σ(control.score × control.controlsWeight / 100) × policyWeight / 100.
/// The first factor (matching the existing weight-scoping convention in
/// control_entity.dart's ControlListWeightX.hasControlWeightIssue — excludes
/// Draft, Inactive, and Expired controls) is the Policy's own 0-100 grade
/// from its Controls; multiplying by [policyWeight] converts that into
/// "how many of this Policy's weight-share points were earned," which is
/// what gets persisted as Policy.score and summed directly (no further
/// weighting) into the Module score.
double computePolicyScore(List<ControlEntity> controls, double policyWeight) {
  const weightScopedStatuses = {
    ControlStatus.active,
    ControlStatus.scheduled,
    ControlStatus.unassigned,
  };
  final controlsGrade = controls
      .where((c) => weightScopedStatuses.contains(c.status))
      .fold<double>(0, (sum, c) => sum + c.score * c.controlsWeight / 100);
  return controlsGrade * policyWeight / 100;
}

/// Straight sum of every Active/Scheduled Policy's score under one Module.
/// Each Policy's score is already its own weighted share (see
/// [computePolicyScore]), so no further weight multiplication happens here —
/// summing the shares directly gives the Module's total. Matches the
/// existing weightScopedPolicies filter in grc_module_policies_tab.dart.
double computeModuleScore(List<PolicyEntity> policies) {
  return policies
      .where((p) =>
          p.status == PolicyStatus.active || p.status == PolicyStatus.scheduled)
      .fold<double>(0, (sum, p) => sum + p.score);
}

class RecalculateScoreRollupUseCase {
  const RecalculateScoreRollupUseCase({
    required UpdateControlUseCase updateControlUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetPolicyUseCase getPolicyUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required UpdateGRCModuleUseCase updateGrcModuleUseCase,
  })  : _updateControlUseCase = updateControlUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getPolicyUseCase = getPolicyUseCase,
        _updatePolicyUseCase = updatePolicyUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _updateGrcModuleUseCase = updateGrcModuleUseCase;

  final UpdateControlUseCase _updateControlUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetPolicyUseCase _getPolicyUseCase;
  final UpdatePolicyUseCase _updatePolicyUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final UpdateGRCModuleUseCase _updateGrcModuleUseCase;

  /// Full chain triggered when a Control Owner submits/edits a score in My
  /// Audits: persist the Control's own score, then cascade the recompute up
  /// through its Policy and Module.
  Future<void> call({
    required String moduleId,
    required String policyId,
    required String controlId,
    required double controlScore,
    required String editorEmail,
  }) async {
    await _updateControlUseCase.call(
      UpdateControlParams(
        id: controlId,
        moduleId: moduleId,
        policyId: policyId,
        editorId: editorEmail,
        score: controlScore.round(),
      ),
    );

    await recalculatePolicyScore(
      moduleId: moduleId,
      policyId: policyId,
      editorEmail: editorEmail,
    );
    await recalculateModuleScore(moduleId: moduleId, editorEmail: editorEmail);
  }

  /// Recomputes and persists just one Policy's own score from its current
  /// Controls and current weight — used when a weight changes but no
  /// Control score did (Policy Weight Issue, Control Weight Issue), as well
  /// as internally by [call].
  Future<void> recalculatePolicyScore({
    required String moduleId,
    required String policyId,
    required String editorEmail,
  }) async {
    final controlsResult = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    final controls = controlsResult.fold((_) => <ControlEntity>[], (c) => c);

    final policyResult =
        await _getPolicyUseCase.call(policyId, moduleId: moduleId);
    final policyWeight = policyResult.fold((_) => 0.0, (p) => p.policyWeight);
    final newPolicyScore = computePolicyScore(controls, policyWeight);

    await _updatePolicyUseCase.call(
      UpdatePolicyParams(
        id: policyId,
        moduleId: moduleId,
        editorId: editorEmail,
        score: newPolicyScore,
      ),
    );
  }

  /// Recomputes and persists the Module's score from all its current
  /// Policies — used after one or more Policy scores change without a new
  /// Control score (Policy Weight Issue, Control Weight Issue), as well as
  /// internally by [call].
  Future<void> recalculateModuleScore({
    required String moduleId,
    required String editorEmail,
  }) async {
    final policiesResult =
        await _getAllPoliciesUseCase.call(moduleId: moduleId);
    final policies = policiesResult.fold((_) => <PolicyEntity>[], (p) => p);
    final newModuleScore = computeModuleScore(policies);

    await _updateGrcModuleUseCase.execute(
      id: moduleId,
      editorId: editorEmail,
      score: newModuleScore,
    );
  }
}
