/// Module: Policy Management
/// Description: BLoC Cubit that manages the Control Weight Issue page's
///              state: loading the Controls under one Policy, editing
///              their weights (Equal Weight or by hand), and applying the
///              changed rows back through UpdateControlUseCase.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, GetAllControlsUseCase, UpdateControlUseCase,
///               ControlWeightIssueRow/Rows
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:knowticed_plus/features/grc/control/data/services/grc_control_notifier.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'control_weight_issue_state.dart';

/// class name: [ControlWeightIssueCubit]
///
/// purpose: manage all state for the Control Weight Issue page: fetching
///          the Controls under one Policy (excluding Draft — only Active,
///          Scheduled, and Unassigned controls count toward this Policy's
///          total, matching the existing `_hasControlWeightIssue` check
///          this page's entry button uses), editing their weights in
///          memory, and persisting the changed rows via
///          [UpdateControlUseCase] on Apply Changes.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssueCubit extends Cubit<ControlWeightIssueState> {
  ControlWeightIssueCubit({
    required GetAllControlsUseCase getAllControlsUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required RecalculateScoreRollupUseCase recalculateScoreRollupUseCase,
  })  : _getAllControlsUseCase = getAllControlsUseCase,
        _updateControlUseCase = updateControlUseCase,
        _recalculateScoreRollupUseCase = recalculateScoreRollupUseCase,
        super(ControlWeightIssueInitial());

  final GetAllControlsUseCase _getAllControlsUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final RecalculateScoreRollupUseCase _recalculateScoreRollupUseCase;

  ControlWeightIssueRows? _rowsData;

  /// The current row/table data. Only valid once a
  /// [ControlWeightIssueLoaded] state has been emitted at least once.
  ControlWeightIssueRows get rowsData => _rowsData!;

  /// Whether [load] has ever completed successfully — false only before
  /// the very first load, or if that first load failed. Lets the page
  /// tell "failed before there was any data to show" apart from "failed
  /// midway through an edit session, but the table is still there."
  bool get hasRows => _rowsData != null;

  /// function name: [load]
  ///
  /// purpose: fetch every Active/Scheduled/Unassigned Control under
  ///          [moduleId]/[policyId] and build fresh row data. Draft controls
  ///          haven't been published yet, and Inactive/Expired controls are
  ///          no longer in effect, so neither count toward this Policy's
  ///          weight total. Disposes any previously held row data first.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<void>]
  Future<void> load(String moduleId, String policyId) async {
    emit(ControlWeightIssueLoading());

    final result = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    final controls = result.fold((failure) {
      emit(ControlWeightIssueFailure(failure.message));
      return null;
    }, (controls) => controls);
    if (controls == null) return;

    final counted = controls
        .where((c) =>
            c.status == ControlStatus.active ||
            c.status == ControlStatus.scheduled ||
            c.status == ControlStatus.unassigned)
        .toList();

    _rowsData?.dispose();
    _rowsData = ControlWeightIssueRows(
      counted.map(ControlWeightIssueRow.fromControl).toList(),
    );
    emit(ControlWeightIssueLoaded(isEditing: false));
  }

  /// function name: [enterEditMode]
  ///
  /// purpose: switch the Controls Weight tab into edit mode (the "Edit"
  ///          button).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void enterEditMode() {
    emit(ControlWeightIssueLoaded(isEditing: true));
  }

  /// function name: [discardChanges]
  ///
  /// purpose: revert every row and exit edit mode (the "Discard Changes"
  ///          button).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void discardChanges() {
    rowsData.discardChanges();
    emit(ControlWeightIssueLoaded(isEditing: false));
  }

  /// function name: [applyEqualWeight]
  ///
  /// purpose: fill every row with an equal share of 100 (the "Equal
  ///          Weight" button). Stays in edit mode so the user can still
  ///          hand-edit afterward.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void applyEqualWeight() {
    rowsData.applyEqualWeight();
    emit(ControlWeightIssueLoaded(isEditing: true));
  }

  /// function name: [revalidate]
  ///
  /// purpose: re-emit the current edit-mode state so the page rebuilds
  ///          (Total Weight box, Apply Changes enabled state) after a
  ///          hand-edited cell. Called from each cell's `onChanged`.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void revalidate() {
    emit(ControlWeightIssueLoaded(isEditing: true));
  }

  /// function name: [applyChanges]
  ///
  /// purpose: persist every row whose weight actually changed via
  ///          [UpdateControlUseCase], one call per changed row, then
  ///          recompute this Policy's and its Module's scores (a weight
  ///          change alone can make a previously-correct score stale, even
  ///          though no Control score changed) via
  ///          [RecalculateScoreRollupUseCase.recalculatePolicyScore]/
  ///          [RecalculateScoreRollupUseCase.recalculateModuleScore]. No-op
  ///          if the live total isn't exactly 100. On full success, reloads
  ///          fresh data and returns to view mode; on any failure, emits
  ///          Failure for the listener snackbar then immediately re-emits
  ///          an editing Loaded state so the table stays visible in edit
  ///          mode (rows/controllers untouched) instead of falling back to
  ///          a bare error screen.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<void>]
  Future<void> applyChanges(String moduleId, String policyId) async {
    if (!rowsData.totalWeightValid) return;

    emit(ControlWeightIssueApplying());

    final changed = rowsData.changedRows;
    final editorId = currentGrcUserEmail();

    for (final row in changed) {
      final result = await _updateControlUseCase.call(
        UpdateControlParams(
          id: row.controlId,
          moduleId: moduleId,
          policyId: policyId,
          editorId: editorId,
          controlsWeight: row.currentWeight,
        ),
      );
      final failureMessage = result.fold((failure) => failure.message, (_) => null);
      if (failureMessage != null) {
        emit(ControlWeightIssueFailure(failureMessage));
        emit(ControlWeightIssueLoaded(isEditing: true));
        return;
      }
    }

    await _recalculateScoreRollupUseCase.recalculatePolicyScore(
      moduleId: moduleId,
      policyId: policyId,
      editorEmail: editorId,
    );
    await _recalculateScoreRollupUseCase.recalculateModuleScore(
      moduleId: moduleId,
      editorEmail: editorId,
    );

    // Control Weight Issue Resolved — applyChanges only runs when the new
    // total is valid, so every control touched to get there is reported as
    // resolved (same rule as PolicyWeightIssueCubit). Fire-and-forget.
    for (final row in changed) {
      GrcControlNotifier.weightIssue(
        moduleId: moduleId,
        policyId: policyId,
        controlId: row.controlId,
        controlName: row.controlsNameEn,
        isResolved: true,
      );
    }

    emit(ControlWeightIssueApplySuccess());
    await load(moduleId, policyId);
  }

  @override
  Future<void> close() {
    _rowsData?.dispose();
    return super.close();
  }
}
