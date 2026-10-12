/// Module: Approvals (Department Manager)
/// Description: BLoC Cubit that manages the manager's Approvals list and
///              Approve/Reject actions, mirroring AssignmentControlCubit's
///              shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/services/grc_evidence_notifier.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_item.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_resolver.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/decide_approval_usecase.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/create_or_update_pending_my_audit_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

part 'approval_state.dart';

class ApprovalCubit extends Cubit<ApprovalState> {
  ApprovalCubit({
    required GetAllApprovalsUseCase getAllApprovalsUseCase,
    required GetAssignmentControlByIdUseCase getAssignmentControlByIdUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required DecideApprovalUseCase decideApprovalUseCase,
    required ApplyManagerDecisionUseCase applyManagerDecisionUseCase,
    required CreateOrUpdatePendingMyAuditUseCase createOrUpdatePendingMyAuditUseCase,
  })  : _getAllApprovalsUseCase = getAllApprovalsUseCase,
        _getAssignmentControlByIdUseCase = getAssignmentControlByIdUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _decideApprovalUseCase = decideApprovalUseCase,
        _applyManagerDecisionUseCase = applyManagerDecisionUseCase,
        _createOrUpdatePendingMyAuditUseCase = createOrUpdatePendingMyAuditUseCase,
        super(ApprovalInitial());

  final GetAllApprovalsUseCase _getAllApprovalsUseCase;
  final GetAssignmentControlByIdUseCase _getAssignmentControlByIdUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final DecideApprovalUseCase _decideApprovalUseCase;
  final ApplyManagerDecisionUseCase _applyManagerDecisionUseCase;
  final CreateOrUpdatePendingMyAuditUseCase _createOrUpdatePendingMyAuditUseCase;

  /// Loads every Approval (any status) whose linked Assignment Control's
  /// Department Manager is [managerEmail], resolving each one's
  /// Control/Policy details for display. The list page filters by status
  /// (All/Approved/Pending/Rejected) client-side, mirroring how the
  /// Champion's Assignment Controls list derives its own tabs.
  /// GRC bug report p3: a Module Owner reviews every champion's evidence in
  /// their module, not only the ones they are the supervisor for. Remembered
  /// per cubit so the refresh after approve / reject keeps the same scope.
  bool _includeAllInModule = false;

  Future<void> getMyApprovals({
    required String moduleId,
    required String managerEmail,
    bool? includeAllInModule,
  }) async {
    if (includeAllInModule != null) _includeAllInModule = includeAllInModule;
    emit(ApprovalLoading());
    final approvalsResult = await _getAllApprovalsUseCase.call(moduleId: moduleId);

    await approvalsResult.fold(
      (failure) async => emit(ApprovalFailure(failure.message)),
      (approvals) async {
        final assignmentControls = <String, AssignmentControlEntity>{};
        for (final approval in approvals) {
          final result = await _getAssignmentControlByIdUseCase.call(
            moduleId: moduleId,
            id: approval.submissionId,
          );
          result.fold(
            (_) {},
            (assignmentControl) {
              if (assignmentControl != null) {
                assignmentControls[approval.submissionId] = assignmentControl;
              }
            },
          );
        }

        final relevant = assignmentControls.values
            .where((ac) =>
                _includeAllInModule ||
                (ac.departmentManager ?? '').trim().toLowerCase() ==
                    managerEmail.trim().toLowerCase());

        final policyControls = <String, List<ControlEntity>>{};
        for (final ac in relevant) {
          if (policyControls.containsKey(ac.policyId)) continue;
          final controlsResult = await _getAllControlsUseCase.call(
            moduleId: moduleId,
            policyId: ac.policyId,
          );
          controlsResult.fold(
            (_) {},
            (controls) => policyControls[ac.policyId] = controls,
          );
        }

        final policiesResult = await _getAllPoliciesUseCase.call(moduleId: moduleId);
        final policies = <String, PolicyEntity>{
          for (final p in policiesResult.fold((_) => <PolicyEntity>[], (p) => p))
            p.id: p,
        };

        emit(ApprovalListLoaded(
          buildApprovalItems(
            approvals: approvals,
            assignmentControls: assignmentControls,
            policyControls: policyControls,
            policies: policies,
            managerEmail: managerEmail,
            includeAll: _includeAllInModule,
          ),
        ));
      },
    );
  }

  Future<void> approve({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String managerEmail,
    String? comment,
  }) async {
    emit(ApprovalLoading());
    final approvalResult = await _decideApprovalUseCase.call(
      DecideApprovalParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: ApprovalStatus.approved.value,
        approvalComment: comment,
        editorEmail: managerEmail,
      ),
    );

    await approvalResult.fold(
      (failure) async => emit(ApprovalFailure(failure.message)),
      (approval) async {
        final acResult = await _applyManagerDecisionUseCase.call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            newStatus: AssignmentControlStatus.inReview,
            editorEmail: managerEmail,
          ),
        );
        await acResult.fold(
          (failure) async => emit(ApprovalFailure(failure.message)),
          (assignment) async {
            // Manager Approved → champion; Waiting for Final Approval → owner.
            GrcEvidenceNotifier.managerDecided(
              moduleId: moduleId,
              assignment: assignment,
              approved: true,
            );
            await _createOrUpdatePendingMyAuditUseCase.call(
              CreateOrUpdatePendingMyAuditParams(
                moduleId: moduleId,
                controlId: controlId,
                championEmail: championEmail,
                editorEmail: managerEmail,
              ),
            );
            emit(ApprovalActionSuccess(approval));
          },
        );
      },
    );
  }

  Future<void> reject({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String managerEmail,
    required String reason,
  }) async {
    emit(ApprovalLoading());
    final approvalResult = await _decideApprovalUseCase.call(
      DecideApprovalParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: ApprovalStatus.rejected.value,
        reasonOfRejection: reason,
        editorEmail: managerEmail,
      ),
    );

    await approvalResult.fold(
      (failure) async => emit(ApprovalFailure(failure.message)),
      (approval) async {
        final acResult = await _applyManagerDecisionUseCase.call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            newStatus: AssignmentControlStatus.rejected,
            rejectionReason: reason,
            editorEmail: managerEmail,
          ),
        );
        acResult.fold(
          (failure) => emit(ApprovalFailure(failure.message)),
          (assignment) {
            // Department Manager Rejected → champion.
            GrcEvidenceNotifier.managerDecided(
              moduleId: moduleId,
              assignment: assignment,
              approved: false,
            );
            emit(ApprovalActionSuccess(approval));
          },
        );
      },
    );
  }
}
