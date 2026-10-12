// Module: Assignment Controls (Control Champion)
// Description: BLoC Cubit that manages the Champion's Assignment Controls
//              list and Submit-evidence action, mirroring ChampionCubit's
//              shape.
// Author: Mohamed Magdy Abdelkhalek
// Date: 2026-07-27

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/services/grc_evidence_notifier.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_resolver.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/create_or_update_pending_approval_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_resolver.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_assignment_control_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

part 'assignment_control_state.dart';

class AssignmentControlCubit extends Cubit<AssignmentControlState> {
  AssignmentControlCubit({
    required GetChampionUseCase getChampionUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetAllOwnersUseCase getAllOwnersUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAssignmentControlUseCase getAssignmentControlUseCase,
    required SubmitEvidenceUseCase submitEvidenceUseCase,
    required CreateOrUpdatePendingApprovalUseCase createOrUpdatePendingApprovalUseCase,
  })  : _getChampionUseCase = getChampionUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getAllOwnersUseCase = getAllOwnersUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _getAssignmentControlUseCase = getAssignmentControlUseCase,
        _submitEvidenceUseCase = submitEvidenceUseCase,
        _createOrUpdatePendingApprovalUseCase = createOrUpdatePendingApprovalUseCase,
        super(AssignmentControlInitial());

  final GetChampionUseCase _getChampionUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetAllOwnersUseCase _getAllOwnersUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final GetAssignmentControlUseCase _getAssignmentControlUseCase;
  final SubmitEvidenceUseCase _submitEvidenceUseCase;
  final CreateOrUpdatePendingApprovalUseCase _createOrUpdatePendingApprovalUseCase;

  /// Loads every control this champion is assigned to (via ChampionModel,
  /// no Assignment_Controls doc required), resolves each control's details
  /// and any existing Assignment_Controls submission, then emits the
  /// derived list. A champion with no record yet (ValidationError from
  /// getChampion) is a normal empty state, not a failure.
  Future<void> getMyAssignmentControls({
    required String moduleId,
    required String championEmail,
  }) async {
    emit(AssignmentControlLoading());
    final championResult =
        await _getChampionUseCase.call(championEmail, moduleId: moduleId);

    await championResult.fold(
      (failure) async {
        if (failure is ValidationError) {
          emit(AssignmentControlListLoaded(const []));
        } else {
          emit(AssignmentControlFailure(failure.message));
        }
      },
      (champion) async {
        final policyControls = <String, List<ControlEntity>>{};
        for (final ac in champion.assigningControls) {
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

        final policiesResult =
            await _getAllPoliciesUseCase.call(moduleId: moduleId);
        final policies = <String, PolicyEntity>{
          for (final p in policiesResult.fold((_) => <PolicyEntity>[], (p) => p))
            p.id: p,
        };

        final ownersResult = await _getAllOwnersUseCase.call(moduleId: moduleId);
        final owners =
            ownersResult.fold((_) => const <OwnerEntity>[], (o) => o);

        final existingAssignments = <String, AssignmentControlEntity>{};
        for (final ac in champion.assigningControls) {
          final assignmentResult = await _getAssignmentControlUseCase.call(
            moduleId: moduleId,
            controlId: ac.controlId,
            championEmail: championEmail,
          );
          assignmentResult.fold(
            (_) {},
            (assignment) {
              if (assignment != null) {
                existingAssignments[ac.controlId] = assignment;
              }
            },
          );
        }

        emit(AssignmentControlListLoaded(
          buildAssignmentControlItems(
            assigningControls: champion.assigningControls,
            policyControls: policyControls,
            policies: policies,
            existingAssignments: existingAssignments,
            owners: owners,
          ),
        ));
      },
    );
  }

  /// Resolves the current Control Owner and Department Manager for this
  /// policy+control (if any), submits (creates or resubmits) the evidence,
  /// then creates/resets the linked Approval doc to Pending so the manager's
  /// Approvals list picks it up.
  Future<void> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required File documentFile,
    required String note,
  }) async {
    emit(AssignmentControlLoading());
    final ownersResult = await _getAllOwnersUseCase.call(moduleId: moduleId);
    final ownerEmail = ownersResult.fold(
      (_) => null,
      (owners) => findOwnerEmailForControl(
        owners,
        policyId: policyId,
        controlId: controlId,
      ),
    );

    final employees = Get.isRegistered<MainCoreEmployeeController>()
        ? (Get.find<MainCoreEmployeeController>().allEmployeesEntities ??
            const <EmployeeEntityPro>[])
        : const <EmployeeEntityPro>[];
    final departmentManagerEmail = findDepartmentManagerEmail(
      employees,
      championEmail: championEmail,
    );

    final result = await _submitEvidenceUseCase.call(
      SubmitEvidenceParams(
        moduleId: moduleId,
        policyId: policyId,
        controlId: controlId,
        championEmail: championEmail,
        controlOwnerEmail: ownerEmail,
        departmentManagerEmail: departmentManagerEmail,
        documentFile: documentFile,
        note: note,
        editorEmail: championEmail,
      ),
    );

    await result.fold(
      (failure) async => emit(AssignmentControlFailure(failure.message)),
      (assignment) async {
        await _createOrUpdatePendingApprovalUseCase.call(
          CreateOrUpdatePendingApprovalParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            editorEmail: championEmail,
          ),
        );
        // Evidence Submitted → champion; Waiting for Review → manager.
        GrcEvidenceNotifier.submitted(
          moduleId: moduleId,
          assignment: assignment,
        );
        emit(AssignmentControlActionSuccess(assignment));
      },
    );
  }
}
