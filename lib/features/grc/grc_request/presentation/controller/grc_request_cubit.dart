/// Module: GRC Request Management
/// Description: BLoC Cubit that manages GRC Request state for the
///              presentation layer, mirroring ChampionCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, use cases, GrcRequestEntity

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notifier.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/approve_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/cancel_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/reject_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';

part 'grc_request_state.dart';

class GrcRequestCubit extends Cubit<GrcRequestState> {
  GrcRequestCubit({
    required CreateGrcRequestUseCase createGrcRequestUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApproveGrcRequestUseCase approveGrcRequestUseCase,
    required RejectGrcRequestUseCase rejectGrcRequestUseCase,
    required CancelGrcRequestUseCase cancelGrcRequestUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _createUseCase = createGrcRequestUseCase,
        _getAllUseCase = getGrcRequestsUseCase,
        _approveUseCase = approveGrcRequestUseCase,
        _rejectUseCase = rejectGrcRequestUseCase,
        _cancelUseCase = cancelGrcRequestUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(GrcRequestInitial());

  final CreateGrcRequestUseCase _createUseCase;
  final GetGrcRequestsUseCase _getAllUseCase;
  final ApproveGrcRequestUseCase _approveUseCase;
  final RejectGrcRequestUseCase _rejectUseCase;
  final CancelGrcRequestUseCase _cancelUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> getRequestsForModule(String moduleId) async {
    emit(GrcRequestLoading());
    final result = await _getAllUseCase.call(moduleId);
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (requests) => emit(GrcRequestListLoaded(requests)),
    );
  }

  Future<void> createRequest(CreateGrcRequestParams params) async {
    emit(GrcRequestLoading());
    final result = await _createUseCase.call(params);
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) {
        // Reassignment Request Submitted → approvers; Reassignment Requested
        // → the current and proposed champion. Fire-and-forget.
        GrcAssigneeNotifier.requestSubmitted(request);
        emit(GrcRequestActionSuccess(request));
      },
    );
  }

  Future<void> approveRequest({
    required String moduleId,
    required String requestId,
  }) async {
    emit(GrcRequestLoading());
    final result = await _approveUseCase.call(
      ApproveGrcRequestParams(
        moduleId: moduleId,
        requestId: requestId,
        decidedBy: _currentUserEmail,
      ),
    );
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) {
        // Reassignment Approved → requester, incoming and outgoing assignee.
        GrcAssigneeNotifier.requestDecided(request, approved: true);
        emit(GrcRequestActionSuccess(request));
      },
    );
  }

  Future<void> rejectRequest({
    required String moduleId,
    required String requestId,
    required String reason,
  }) async {
    emit(GrcRequestLoading());
    final result = await _rejectUseCase.call(
      RejectGrcRequestParams(
        moduleId: moduleId,
        requestId: requestId,
        decidedBy: _currentUserEmail,
        reason: reason,
      ),
    );
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) {
        // Reassignment Rejected → requester (Control Rejected for a
        // Control Changes request).
        GrcAssigneeNotifier.requestDecided(
          request,
          approved: false,
          rejectionReason: reason,
        );
        emit(GrcRequestActionSuccess(request));
      },
    );
  }

  Future<void> cancelRequest({
    required String moduleId,
    required String requestId,
  }) async {
    emit(GrcRequestLoading());
    final result = await _cancelUseCase.call(
      CancelGrcRequestParams(
        moduleId: moduleId,
        requestId: requestId,
        canceledBy: _currentUserEmail,
      ),
    );
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) => emit(GrcRequestActionSuccess(request)),
    );
  }

  /// Thin pass-throughs for the Policy/Control use cases
  /// GrcRequestDetailsPage used to resolve straight out of `GetIt` inside its
  /// own `State`. Routing them through the Cubit (instead of adding new
  /// emitted states) keeps the page's existing `result.fold(...)` call-site
  /// logic byte-for-byte the same — only where the use case instance comes
  /// from changes. Mirrors ChampionCubit.getAllPolicies /
  /// getAllControlsForPolicy from commit ee088fe.
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    required String moduleId,
  }) {
    return _getAllPoliciesUseCase.call(moduleId: moduleId);
  }

  Future<Either<Failure, List<ControlEntity>>> getAllControlsForPolicy({
    required String moduleId,
    required String policyId,
  }) {
    return _getAllControlsUseCase.call(moduleId: moduleId, policyId: policyId);
  }
}

/// Business rule: canceled requests are only relevant to the requester, so
/// they're kept out of the module-wide "Requests" view — they still show up
/// in the "My Requests" view (which scopes by `requestedBy` instead, upstream
/// of this filter).
extension GrcRequestListScopeX on List<GrcRequestEntity> {
  List<GrcRequestEntity> get visibleForModuleScope =>
      where((r) => r.status != ApprovalStatus.canceled).toList();
}
