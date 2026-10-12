/// Module: Policy Management
/// Description: In-memory row/table model behind the Policy Weight Issue
///              page's editable table: one TextEditingController per row's
///              weight, plus the derived Total Weight the page needs.
///              Deliberately has no dependency on Firestore or use cases so
///              it can be unit tested directly (same spirit as
///              PolicyBulkUploadRows).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter, PolicyEntity
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';

/// class name: [PolicyWeightIssueRow]
///
/// purpose: one editable row of the Policies Weight table. Wraps a single
///          [PolicyEntity] plus its [noOfControls] (resolved separately,
///          Controls are not part of PolicyEntity) and a weight
///          [TextEditingController] the UI edits directly.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssueRow {
  final String policyId;
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyNameEn;
  final String policyNameAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final int noOfControls;
  final double initialWeight;
  final TextEditingController weightController;

  PolicyWeightIssueRow._({
    required this.policyId,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.noOfControls,
    required this.initialWeight,
  }) : weightController = TextEditingController(text: _format(initialWeight)),
        _exactWeight = initialWeight;

  /// function name: [PolicyWeightIssueRow.fromPolicy]
  ///
  /// purpose: build a row from a loaded [PolicyEntity] and its separately
  ///          resolved Controls count.
  ///
  /// parameters:
  ///            [PolicyEntity] policy: the source policy
  ///            [int] noOfControls: number of Controls under this policy
  ///
  /// return type: [PolicyWeightIssueRow] - the new row
  factory PolicyWeightIssueRow.fromPolicy(
    PolicyEntity policy, {
    required int noOfControls,
  }) {
    return PolicyWeightIssueRow._(
      policyId: policy.id,
      policyNumberEn: policy.policyNumberEn,
      policyNumberAr: policy.policyNumberAr,
      policyNameEn: policy.policyNameEn,
      policyNameAr: policy.policyNameAr,
      policyDescriptionEn: policy.policyDescriptionEn,
      policyDescriptionAr: policy.policyDescriptionAr,
      startDate: policy.startDate,
      endDate: policy.endDate,
      noOfControls: noOfControls,
      initialWeight: policy.policyWeight,
    );
  }

  static String _format(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  /// The live value typed into [weightController], or 0 if unparsable.
  ///
  /// The field only SHOWS 2 decimals. [_exactWeight] keeps the full-precision
  /// value behind it (the saved weight, or an Equal Weight share such as
  /// 100 / 6 = 16.666...), and is used for as long as the field still shows
  /// that value. Once the user types something else, the typed number wins.
  double get currentWeight {
    final String text = weightController.text.trim();
    final double? exact = _exactWeight;
    if (exact != null && text == _format(exact)) return exact;
    return double.tryParse(text) ?? 0;
  }

  /// Full-precision value behind [weightController]; see [currentWeight].
  double? _exactWeight;

  /// Whether the user has changed this row's weight from its last-saved value.
  bool get hasChanged => currentWeight != initialWeight;

  /// function name: [setWeight]
  ///
  /// purpose: overwrite [weightController]'s text with [value] (used by
  ///          Equal Weight).
  ///
  /// parameters:
  ///            [double] value: the new weight to display
  ///
  /// return type: [void]
  void setWeight(double value) {
    _exactWeight = value;
    weightController.text = _format(value);
  }

  /// function name: [resetToInitial]
  ///
  /// purpose: revert [weightController] back to [initialWeight] (Discard
  ///          Changes).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void resetToInitial() {
    _exactWeight = initialWeight;
    weightController.text = _format(initialWeight);
  }

  /// function name: [dispose]
  ///
  /// purpose: release [weightController]. Must be called whenever a
  ///          [PolicyWeightIssueRows] holding this row is discarded.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    weightController.dispose();
  }
}

/// class name: [PolicyWeightIssueRows]
///
/// purpose: own the full row list for the Policies Weight table and expose
///          the derived Total Weight / validity / Equal Weight / Discard /
///          changed-rows operations the cubit and page need.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssueRows {
  PolicyWeightIssueRows(this.rows);

  final List<PolicyWeightIssueRow> rows;

  /// Sum of every row's live weight value.
  double get totalWeight =>
      rows.fold<double>(0, (sum, row) => sum + row.currentWeight);

  /// The rule this page enforces: the sum must be (within floating-point
  /// tolerance of) exactly 100. A small epsilon is used instead of strict
  /// equality because `100 / n` for some row counts (e.g. n = 3) is not
  /// exactly representable as a double, so an untouched Equal Weight split
  /// must still validate.
  bool get totalWeightValid => (totalWeight - 100).abs() < 0.001;

  /// function name: [applyEqualWeight]
  ///
  /// purpose: set every row's weight to the exact decimal share `100 / n`
  ///          (the "Equal Weight" action). No-op on an empty table.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void applyEqualWeight() {
    if (rows.isEmpty) return;
    // The exact share (100 / 6 = 16.666...) goes into the calculation; the
    // field still shows it rounded to 2 decimals (16.67). Total Weight sums
    // the exact values, so it reads exactly 100.
    final double share = 100 / rows.length;
    for (final row in rows) {
      row.setWeight(share);
    }
  }


  /// function name: [discardChanges]
  ///
  /// purpose: revert every row back to its last-saved weight (the "Discard
  ///          Changes" action).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void discardChanges() {
    for (final row in rows) {
      row.resetToInitial();
    }
  }

  /// Rows whose live weight differs from their last-saved value — exactly
  /// the set Apply Changes needs to persist.
  List<PolicyWeightIssueRow> get changedRows =>
      rows.where((row) => row.hasChanged).toList();

  /// function name: [dispose]
  ///
  /// purpose: dispose every row's controller.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
  }
}
