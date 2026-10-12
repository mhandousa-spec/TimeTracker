/// Module: GRC / Approved Evidence
/// Description: Loads the module's approved evidence and holds the four
///              filter selections (Years, Departments, Policies, Controls).
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart';
import 'package:knowticed_plus/features/grc/approved_evidence/domain/entities/approved_evidence_data.dart';
import 'package:knowticed_plus/features/grc/approved_evidence/domain/use_cases/get_approved_evidence_use_case.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

part 'approved_evidence_state.dart';

/// class name: [ApprovedEvidenceCubit]
class ApprovedEvidenceCubit extends Cubit<ApprovedEvidenceState> {
  ApprovedEvidenceCubit({
    required this.moduleId,
    required GetApprovedEvidenceUseCase useCase,
  })  : _useCase = useCase,
        super(const ApprovedEvidenceState());

  /// Builds the cubit from use cases already registered in GetIt, so the
  /// feature needs no DI registration of its own.
  factory ApprovedEvidenceCubit.create(String moduleId) {
    final sl = GetIt.instance;
    return ApprovedEvidenceCubit(
      moduleId: moduleId,
      useCase: GetApprovedEvidenceUseCase(
        getAllApprovals: sl<GetAllApprovalsUseCase>(),
        getAssignmentControlById: sl<GetAssignmentControlByIdUseCase>(),
        getAllPolicies: sl<GetAllPoliciesUseCase>(),
        getAllControls: sl<GetAllControlsUseCase>(),
      ),
    );
  }

  final String moduleId;
  final GetApprovedEvidenceUseCase _useCase;

  Future<void> load() async {
    emit(state.copyWith(status: ApprovedEvidenceStatus.loading));
    final result = await _useCase.call(moduleId: moduleId);
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(
        status: ApprovedEvidenceStatus.failure,
        message: f.message,
      )),
      (data) => emit(state.copyWith(
        status: ApprovedEvidenceStatus.loaded,
        data: data,
      )),
    );
  }

  void setYears(Set<int> years) => emit(state.copyWith(years: years));

  /// Narrowing departments drops picks that no longer belong to them.
  void setDepartments(Set<String> departments) {
    final data = state.data;
    if (data == null) return;
    final policyIds = {
      for (final p in data.policiesFor(departments)) p.id,
    }.intersection(state.policyIds);
    emit(state.copyWith(
      departments: departments,
      policyIds: policyIds,
      controlIds: _keepControls(data, policyIds, departments),
    ));
  }

  void setPolicies(Set<String> policyIds) {
    final data = state.data;
    if (data == null) return;
    emit(state.copyWith(
      policyIds: policyIds,
      controlIds: _keepControls(data, policyIds, state.departments),
    ));
  }

  void setControls(Set<String> controlIds) =>
      emit(state.copyWith(controlIds: controlIds));

  void reset() => emit(state.copyWith(
        years: const <int>{},
        departments: const <String>{},
        policyIds: const <String>{},
        controlIds: const <String>{},
      ));

  Set<String> _keepControls(
    ApprovedEvidenceData data,
    Set<String> policyIds,
    Set<String> departments,
  ) {
    final allowed = {
      for (final r in data.controlsFor(policyIds, departments))
        ApprovedEvidenceData.controlKey(r.policy.id, r.control.id),
    };
    return state.controlIds.intersection(allowed);
  }
}
