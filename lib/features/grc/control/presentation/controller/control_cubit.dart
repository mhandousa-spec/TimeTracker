/// Module: Policy Management
/// Description: BLoC Cubit that manages standalone Control state for the
///              presentation layer. Delegates all operations to the
///              corresponding use cases and emits typed [ControlState]
///              subclasses. Extracted from PolicyCubit, which previously
///              owned these operations even though neither
///              ControlDetailsPage nor AddEditControlPage ever needs a
///              Policy operation — see
///              docs/superpowers/specs/2026-07-28-control-cubit-extraction-design.md.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
/// Dependencies: flutter_bloc, get, use cases, ControlEntity
/// Revision History: 2026-07-28 - Extracted from PolicyCubit
library;

import 'dart:io';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/grc/control/data/services/grc_control_notifier.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_notification_support.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'control_state.dart';

/// class name: [ControlCubit]
///
/// purpose: manage all standalone Control UI state (create/update/delete/
///          list-all). Each public method maps to one use case and follows
///          the pattern: emit [ControlLoading] → call use case → emit a
///          success state or [ControlFailure].
class ControlCubit extends Cubit<ControlState> {
  ControlCubit({
    required CreateControlUseCase createControlUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required DeleteControlUseCase deleteControlUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _createControlUseCase = createControlUseCase,
        _updateControlUseCase = updateControlUseCase,
        _deleteControlUseCase = deleteControlUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(ControlInitial());

  final CreateControlUseCase _createControlUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final DeleteControlUseCase _deleteControlUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  /// Resolves the currently logged-in user's email. Duplicated from
  /// PolicyCubit (not shared via inheritance/composition) because both
  /// Cubits independently need it and Cubits should not depend on each
  /// other.
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> createControl({
    required String moduleId,
    required String policyId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    List<double>? departmentsWeights,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(ControlLoading());
    final result = await _createControlUseCase.call(
      CreateControlParams(
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (control) {
        // Control Added to Policy + Department Assigned (fire-and-forget).
        GrcControlNotifier.created(
          moduleId: moduleId,
          policyId: policyId,
          control: control,
        );
        emit(ControlActionSuccess(control));
      },
    );
  }

  Future<void> updateControl({
    required String id,
    required String moduleId,
    required String policyId,
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    List<double>? departmentsWeights,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(ControlLoading());
    // The control as it was before this edit, so the notifications can say
    // what changed. One read; null just means "send the generic update".
    final ControlEntity? previous =
        await GrcNotify.control(moduleId, policyId, id);
    final result = await _updateControlUseCase.call(
      UpdateControlParams(
        id: id,
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (control) {
        // Updated / Weight Updated / Activated / Deactivated / Department
        // Assigned — whichever this edit actually changed.
        GrcControlNotifier.updated(
          moduleId: moduleId,
          policyId: policyId,
          previous: previous,
          after: control,
        );
        emit(ControlActionSuccess(control));
      },
    );
  }

  Future<void> deleteControl({
    required String id,
    required String moduleId,
    required String policyId,
  }) async {
    emit(ControlLoading());
    // Name + audience have to be read while the control still exists.
    final GrcControlDeleteContext? notifyContext =
        await GrcControlNotifier.prepareDeleted(
      moduleId: moduleId,
      policyId: policyId,
      controlId: id,
    );
    final result = await _deleteControlUseCase.call(
      DeleteControlParams(id: id, moduleId: moduleId, policyId: policyId),
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (_) {
        GrcControlNotifier.deleted(notifyContext);
        emit(ControlDeleted(id));
      },
    );
  }

  Future<void> getAllControls({
    required String moduleId,
    required String policyId,
  }) async {
    emit(ControlLoading());
    final result = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (controls) => emit(ControlsListLoaded(controls)),
    );
  }
}
