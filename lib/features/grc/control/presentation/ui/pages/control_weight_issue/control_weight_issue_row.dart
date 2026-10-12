/// Module: Policy Management
/// Description: In-memory row/table model behind the Control Weight Issue
///              page's editable table: one TextEditingController per row's
///              weight, plus the derived Total Weight the page needs.
///              Deliberately has no dependency on Firestore or use cases so
///              it can be unit tested directly (same spirit as
///              PolicyWeightIssueRow/Rows).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter, ControlEntity
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';

/// class name: [ControlWeightIssueRow]
///
/// purpose: one editable row of the Controls Weight table. Wraps a single
///          [ControlEntity] and a weight [TextEditingController] the UI
///          edits directly. [noOfDepartments] is read straight off the
///          entity's own `departments` list — unlike Policy (which needed
///          a separate Controls-count fetch per row), a Control already
///          carries its department count directly, no secondary fetch
///          needed.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssueRow {
  final String controlId;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final int noOfDepartments;
  final double initialWeight;
  final TextEditingController weightController;

  ControlWeightIssueRow._({
    required this.controlId,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.noOfDepartments,
    required this.initialWeight,
  }) : weightController = TextEditingController(text: formatControlWeight(initialWeight)),
        _exactWeight = initialWeight;

  /// function name: [ControlWeightIssueRow.fromControl]
  ///
  /// purpose: build a row from a loaded [ControlEntity].
  ///
  /// parameters:
  ///            [ControlEntity] control: the source control
  ///
  /// return type: [ControlWeightIssueRow] - the new row
  factory ControlWeightIssueRow.fromControl(ControlEntity control) {
    return ControlWeightIssueRow._(
      controlId: control.id,
      controlsNumberEn: control.controlsNumberEn,
      controlsNumberAr: control.controlsNumberAr,
      controlsNameEn: control.controlsNameEn,
      controlsNameAr: control.controlsNameAr,
      controlsDescriptionEn: control.controlsDescriptionEn,
      controlsDescriptionAr: control.controlsDescriptionAr,
      startDate: control.startDate,
      endDate: control.endDate,
      noOfDepartments: control.departments.length,
      initialWeight: control.controlsWeight,
    );
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
    if (exact != null && text == formatControlWeight(exact)) return exact;
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
    weightController.text = formatControlWeight(value);
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
    weightController.text = formatControlWeight(initialWeight);
  }

  /// function name: [dispose]
  ///
  /// purpose: release [weightController]. Must be called whenever a
  ///          [ControlWeightIssueRows] holding this row is discarded.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    weightController.dispose();
  }
}

/// class name: [ControlWeightIssueRows]
///
/// purpose: own the full row list for the Controls Weight table and expose
///          the derived Total Weight / validity / Equal Weight / Discard /
///          changed-rows operations the cubit and page need.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssueRows {
  ControlWeightIssueRows(this.rows);

  final List<ControlWeightIssueRow> rows;

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
  List<ControlWeightIssueRow> get changedRows =>
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
