/// Module: GRC / Approved Evidence
/// Description: Loads a module's approved evidence: every Approval whose
///              status is Approved, the submission it decided, and that
///              submission's Control and Policy.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
/// Dependencies: GetAllApprovalsUseCase, GetAssignmentControlByIdUseCase,
///               GetAllPoliciesUseCase, GetAllControlsUseCase
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart';
import 'package:knowticed_plus/features/grc/approved_evidence/domain/entities/approved_evidence_data.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

/// class name: [GetApprovedEvidenceUseCase]
///
/// purpose: only the policy read fails the whole load. An approvals read
///          that fails, or a submission / control that can no longer be
///          found, just leaves that evidence out.
class GetApprovedEvidenceUseCase {
  const GetApprovedEvidenceUseCase({
    required GetAllApprovalsUseCase getAllApprovals,
    required GetAssignmentControlByIdUseCase getAssignmentControlById,
    required GetAllPoliciesUseCase getAllPolicies,
    required GetAllControlsUseCase getAllControls,
  })  : _getAllApprovals = getAllApprovals,
        _getAssignmentControlById = getAssignmentControlById,
        _getAllPolicies = getAllPolicies,
        _getAllControls = getAllControls;

  final GetAllApprovalsUseCase _getAllApprovals;
  final GetAssignmentControlByIdUseCase _getAssignmentControlById;
  final GetAllPoliciesUseCase _getAllPolicies;
  final GetAllControlsUseCase _getAllControls;

  Future<Either<Failure, ApprovedEvidenceData>> call({
    required String moduleId,
  }) async {
    final policiesResult = await _getAllPolicies.call(moduleId: moduleId);
    return policiesResult.fold<Future<Either<Failure, ApprovedEvidenceData>>>(
      (failure) async => Left(failure),
      (allPolicies) async {
        final policies = allPolicies
            .where((p) => p.status != PolicyStatus.removed)
            .toList(growable: false);

        final controlsResults = await Future.wait(
          policies.map(
            (p) => _getAllControls.call(moduleId: moduleId, policyId: p.id),
          ),
        );
        final controlsByPolicy = <String, List<ControlEntity>>{};
        for (var i = 0; i < policies.length; i++) {
          controlsResults[i].fold(
            (_) {},
            (controls) => controlsByPolicy[policies[i].id] = controls,
          );
        }

        final approvals = (await _getAllApprovals.call(moduleId: moduleId))
            .fold((_) => const <ApprovalEntity>[], (a) => a)
            .where((a) => a.status == ApprovalStatus.approved)
            .toList();

        final submissions = await Future.wait(
          approvals.map(
            (a) => _getAssignmentControlById.call(
              moduleId: moduleId,
              id: a.submissionId,
            ),
          ),
        );

        final policyById = <String, PolicyEntity>{
          for (final p in policies) p.id: p,
        };

        final items = <ApprovedEvidenceItem>[];
        for (var i = 0; i < approvals.length; i++) {
          final AssignmentControlEntity? submission =
              submissions[i].fold((_) => null, (s) => s);
          if (submission == null) continue;
          final PolicyEntity? policy = policyById[submission.policyId];
          if (policy == null) continue;
          final ControlEntity? control = (controlsByPolicy[policy.id] ??
                  const <ControlEntity>[])
              .where((c) => c.id == submission.controlId)
              .firstOrNull;
          if (control == null) continue;
          items.add(ApprovedEvidenceItem(
            approval: approvals[i],
            submission: submission,
            control: control,
            policy: policy,
          ));
        }

        return Right<Failure, ApprovedEvidenceData>(ApprovedEvidenceData(
          items: items,
          policies: policies,
          controlsByPolicy: controlsByPolicy,
        ));
      },
    );
  }
}
