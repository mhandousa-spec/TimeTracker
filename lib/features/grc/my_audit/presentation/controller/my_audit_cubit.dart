// lib/features/grc/my_audit/presentation/controller/my_audit_cubit.dart
/// Module: My Audits (Control Owner)
/// Description: BLoC Cubit that manages the Owner's My Audits list and
///              Approve/Reject/Score actions, mirroring ApprovalCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_tab.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/services/grc_evidence_notifier.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/apply_owner_score_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_item.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_resolver.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_status.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/apply_my_audit_score_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/decide_my_audit_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/get_all_my_audits_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';

part 'my_audit_state.dart';

class MyAuditCubit extends Cubit<MyAuditState> {
  MyAuditCubit({
    required GetAllMyAuditsUseCase getAllMyAuditsUseCase,
    required GetAssignmentControlByIdUseCase getAssignmentControlByIdUseCase,
    required GetOwnerUseCase getOwnerUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required DecideMyAuditUseCase decideMyAuditUseCase,
    required ApplyMyAuditScoreUseCase applyMyAuditScoreUseCase,
    required ApplyManagerDecisionUseCase applyManagerDecisionUseCase,
    required ApplyOwnerScoreUseCase applyOwnerScoreUseCase,
    required RecalculateScoreRollupUseCase recalculateScoreRollupUseCase,
  })  : _getAllMyAuditsUseCase = getAllMyAuditsUseCase,
        _getAssignmentControlByIdUseCase = getAssignmentControlByIdUseCase,
        _getOwnerUseCase = getOwnerUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _decideMyAuditUseCase = decideMyAuditUseCase,
        _applyMyAuditScoreUseCase = applyMyAuditScoreUseCase,
        _applyManagerDecisionUseCase = applyManagerDecisionUseCase,
        _applyOwnerScoreUseCase = applyOwnerScoreUseCase,
        _recalculateScoreRollupUseCase = recalculateScoreRollupUseCase,
        super(MyAuditInitial());

  final GetAllMyAuditsUseCase _getAllMyAuditsUseCase;
  final GetAssignmentControlByIdUseCase _getAssignmentControlByIdUseCase;
  final GetOwnerUseCase _getOwnerUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final DecideMyAuditUseCase _decideMyAuditUseCase;
  final ApplyMyAuditScoreUseCase _applyMyAuditScoreUseCase;
  final ApplyManagerDecisionUseCase _applyManagerDecisionUseCase;
  final ApplyOwnerScoreUseCase _applyOwnerScoreUseCase;
  final RecalculateScoreRollupUseCase _recalculateScoreRollupUseCase;

  /// Loads every My_Audit whose linked Assignment Control's `controlOwner`
  /// is [ownerEmail], plus a derived Overdue row for each of this Owner's
  /// assigned controls (via OwnerModel) that has no submission at all past
  /// its deadline. Resolves each surviving row's Control/Policy for display.
  Future<void> getMyAudits({
    required String moduleId,
    required String ownerEmail,
  }) async {
    emit(MyAuditLoading());
    final auditsResult = await _getAllMyAuditsUseCase.call(moduleId: moduleId);

    await auditsResult.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audits) async {
        final assignmentControls = <String, AssignmentControlEntity>{};
        for (final audit in audits) {
          final result = await _getAssignmentControlByIdUseCase.call(
            moduleId: moduleId,
            id: audit.submissionId,
          );
          result.fold(
            (_) {},
            (assignmentControl) {
              if (assignmentControl != null) {
                assignmentControls[audit.submissionId] = assignmentControl;
              }
            },
          );
        }

        final ownerResult = await _getOwnerUseCase.call(ownerEmail, moduleId: moduleId);
        final ownerAssigningControls = ownerResult.fold(
          (_) => const <AssigningControlEntity>[],
          (owner) => owner.assigningControls,
        );
        final OwnerEntity? ownerEntity =
            ownerResult.fold((_) => null, (owner) => owner);

        final policyIds = <String>{
          for (final ac in assignmentControls.values)
            if (ac.controlOwner == ownerEmail) ac.policyId,
          for (final ac in ownerAssigningControls) ac.policyId,
        };

        final policyControls = <String, List<ControlEntity>>{};
        for (final policyId in policyIds) {
          final controlsResult = await _getAllControlsUseCase.call(
            moduleId: moduleId,
            policyId: policyId,
          );
          controlsResult.fold(
            (_) {},
            (controls) => policyControls[policyId] = controls,
          );
        }

        final policiesResult = await _getAllPoliciesUseCase.call(moduleId: moduleId);
        final policies = <String, PolicyEntity>{
          for (final p in policiesResult.fold((_) => <PolicyEntity>[], (p) => p))
            p.id: p,
        };

        emit(MyAuditListLoaded(
          buildMyAuditItems(
            audits: audits,
            assignmentControls: assignmentControls,
            ownerAssigningControls: ownerAssigningControls,
            policyControls: policyControls,
            policies: policies,
            ownerEmail: ownerEmail,
          )
              .map((item) => item.withOwnerCanScore(ownerEntity?.canGiveScore(
                        policyId: item.control.policyId,
                        controlId: item.control.id,
                      ) ??
                  true))
              .toList(),
        ));
      },
    );
  }

  /// GRC bug report p3 — the Module Owner's "Give Score" queue.
  ///
  /// Every audit in [moduleId] the control owner has already APPROVED
  /// (Outstanding: approved, no score yet) or scored, whose owner was added
  /// with "Give Score" off (see kOwnerScoreByModuleOwner). Those scores are
  /// the Module Owner's to give. Scored ones stay listed so a score can be
  /// edited, exactly like the owner's own Scored tab.
  Future<void> getScoreRequests({required String moduleId}) async {
    emit(MyAuditLoading());
    final auditsResult = await _getAllMyAuditsUseCase.call(moduleId: moduleId);

    await auditsResult.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audits) async {
        final owners = <String, OwnerEntity?>{};
        final controlsByPolicy = <String, List<ControlEntity>>{};
        final policiesResult =
            await _getAllPoliciesUseCase.call(moduleId: moduleId);
        final policies = <String, PolicyEntity>{
          for (final p
              in policiesResult.fold((_) => <PolicyEntity>[], (p) => p))
            p.id: p,
        };

        final items = <MyAuditItem>[];
        for (final audit in audits) {
          final MyAuditTab tab = computeMyAuditTab(audit);
          if (tab != MyAuditTab.outstanding && tab != MyAuditTab.scored) {
            continue;
          }
          final acResult = await _getAssignmentControlByIdUseCase.call(
            moduleId: moduleId,
            id: audit.submissionId,
          );
          final AssignmentControlEntity? ac =
              acResult.fold((_) => null, (a) => a);
          final String? ownerEmail = ac?.controlOwner;
          if (ac == null || ownerEmail == null || ownerEmail.isEmpty) continue;

          if (!owners.containsKey(ownerEmail)) {
            final r = await _getOwnerUseCase.call(ownerEmail, moduleId: moduleId);
            owners[ownerEmail] = r.fold((_) => null, (o) => o);
          }
          final OwnerEntity? owner = owners[ownerEmail];
          if (owner == null ||
              owner.canGiveScore(policyId: ac.policyId, controlId: ac.controlId)) {
            continue;
          }

          if (!controlsByPolicy.containsKey(ac.policyId)) {
            final r = await _getAllControlsUseCase.call(
                moduleId: moduleId, policyId: ac.policyId);
            controlsByPolicy[ac.policyId] =
                r.fold((_) => <ControlEntity>[], (c) => c);
          }
          final control = findControlInPolicy(
              controlsByPolicy, ac.policyId, ac.controlId);
          final policy = policies[ac.policyId];
          if (control == null || policy == null) continue;

          items.add(MyAuditItem(
            audit: audit,
            assignmentControl: ac,
            control: control,
            policy: policy,
            tab: tab,
            // The Module Owner is the one scoring these.
            ownerCanScore: true,
          ));
        }
        emit(MyAuditListLoaded(items));
      },
    );
  }

  /// Pending -> Outstanding. Assignment Controls stays In review (no score yet).
  Future<void> approve({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String ownerEmail,
  }) async {
    emit(MyAuditLoading());
    final result = await _decideMyAuditUseCase.call(
      DecideMyAuditParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: MyAuditStatus.outstanding.value,
        editorEmail: ownerEmail,
      ),
    );
    await result.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audit) async {
        // Control Owner Approved → champion.
        final assignment = await _assignmentFor(
          moduleId: moduleId,
          controlId: controlId,
          championEmail: championEmail,
        );
        if (assignment != null) {
          GrcEvidenceNotifier.ownerDecided(
            moduleId: moduleId,
            assignment: assignment,
            approved: true,
          );
        }
        emit(MyAuditActionSuccess(audit));
      },
    );
  }

  /// The champion's Assignment_Controls document (id `<control>_<champion>`),
  /// or null when it cannot be read. Used by the notifications only.
  Future<AssignmentControlEntity?> _assignmentFor({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) async {
    final result = await _getAssignmentControlByIdUseCase.call(
      moduleId: moduleId,
      id: '${controlId}_$championEmail',
    );
    return result.fold<AssignmentControlEntity?>(
      (_) => null,
      (assignment) => assignment,
    );
  }

  /// Pending -> Rejected, and Assignment Controls -> Rejected (back to Champion).
  Future<void> reject({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String ownerEmail,
    required String reason,
  }) async {
    emit(MyAuditLoading());
    final result = await _decideMyAuditUseCase.call(
      DecideMyAuditParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: MyAuditStatus.rejected.value,
        reasonOfRejection: reason,
        editorEmail: ownerEmail,
      ),
    );

    await result.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audit) async {
        final acResult = await _applyManagerDecisionUseCase.call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            newStatus: AssignmentControlStatus.rejected,
            rejectionReason: reason,
            editorEmail: ownerEmail,
          ),
        );
        acResult.fold(
          (failure) => emit(MyAuditFailure(failure.message)),
          (assignment) {
            // Control Owner Rejected → champion.
            GrcEvidenceNotifier.ownerDecided(
              moduleId: moduleId,
              assignment: assignment,
              approved: false,
            );
            emit(MyAuditActionSuccess(audit));
          },
        );
      },
    );
  }

  /// (Outstanding or Scored) -> Scored, and Assignment Controls -> Approved
  /// (the terminal state of the whole workflow).
  Future<void> submitScore({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String ownerEmail,
    required double score,
    String? justification,
  }) async {
    emit(MyAuditLoading());
    // The score before this save decides "Score Added" vs "Score Edited".
    final AssignmentControlEntity? previousAssignment = await _assignmentFor(
      moduleId: moduleId,
      controlId: controlId,
      championEmail: championEmail,
    );
    final result = await _applyMyAuditScoreUseCase.call(
      ApplyMyAuditScoreParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        score: score,
        justification: justification,
        editorEmail: ownerEmail,
      ),
    );

    await result.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audit) async {
        final acResult = await _applyOwnerScoreUseCase.call(
          ApplyOwnerScoreParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            score: score,
            justification: justification,
            editorEmail: ownerEmail,
          ),
        );
        await acResult.fold(
          (failure) async => emit(MyAuditFailure(failure.message)),
          (assignment) async {
            // Score Added / Score Edited → champion + department manager.
            GrcEvidenceNotifier.scored(
              moduleId: moduleId,
              assignment: assignment,
              previousScore: previousAssignment?.controlScore,
              newScore: score,
            );
            await _recalculateScoreRollupUseCase.call(
              moduleId: moduleId,
              policyId: policyId,
              controlId: controlId,
              controlScore: score,
              editorEmail: ownerEmail,
            );
            emit(MyAuditActionSuccess(audit));
          },
        );
      },
    );
  }
}
