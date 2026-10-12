/// Module: Policy Management
/// Description: Defines the Control Entity used by the app's UI/business
///              logic layer. Holds the latest (current) values of a single
///              Control record as plain single fields. Controls now live in
///              their own Firestore subcollection under a Policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: ControlStatus, DepartmentWeight
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the Controls subcollection
///                                schema: added policyId, number fields,
///                                split documents (En/Ar), start/end dates,
///                                departments, equalWeights, score, and
///                                ControlStatus. Removed isDeleted in favor
///                                of ControlStatus.unassigned/expired
///                                (Mohamed Magdy Abdelkhalek)
///                   2026-07-18 - departments now holds [DepartmentWeight]
///                                entries (department + weight) instead of
///                                plain names, so each selected department
///                                carries its own weight. When equalWeights
///                                is true (e.g. "All" departments selected)
///                                the weights are generated equally and
///                                always sum to 100 (Mohamed Magdy
///                                Abdelkhalek)

import 'control_status.dart';
import 'control_department_weight.dart';

/// Renders a control weight without a trailing ".00" for whole numbers,
/// while still showing the decimals an equal split can produce (e.g.
/// 100/3 -> "33.33"). Extracted because 5 files in this feature each
/// reimplemented this exact formatting rule under 4 different names.
String formatControlWeight(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

/// ************************* FILE INFO *************************** ///
/// File Name: control_entity.dart
/// Purpose: Contains the ControlEntity class, a flat (non-list)
///          representation of a Control record, derived from the latest
///          index of the ControlModel. This is what the Presentation and
///          Domain layers consume directly.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [ControlEntity]
///
/// purpose: holds the current (latest) values of a Control record as plain
///          single fields. Controls are stored as a subcollection under a
///          Policy document (GRC_Modules/{Module_ID}/Policies/{Policy_ID}/
///          Controls/{Control_ID}) and each Control carries its own
///          tracking fields (lastModifiedDate, lastEditorId) derived from
///          its own revision history in [ControlModel].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
/// One saved score of a Control, taken from its revision history.
///
/// ADDED 16/9/2026 for the GRC Compliance Timeline. ControlModel keeps every
/// field as a revision list, and `score[i]` was saved on
/// `lastModifiedDate[i]`, so the history is read, not stored anew.
class ControlScorePoint {
  final DateTime date;
  final int score;

  const ControlScorePoint({required this.date, required this.score});
}

class ControlEntity {
  final String id;
  final String policyId;
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final String? controlsDocumentEn;
  final String? controlsDocumentAr;
  final double controlsWeight;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<DepartmentWeight> departments;
  final bool equalWeights;
  final int score;
  final ControlStatus status;

  // Tracking fields (latest values only)
  final DateTime lastModifiedDate;
  final String lastEditor;

  /// Every saved score, oldest first. Empty when the entity was not built
  /// from a ControlModel (tests, in-memory drafts). Optional, so no existing
  /// constructor call changes.
  final List<ControlScorePoint> scoreHistory;

  const ControlEntity({
    required this.id,
    required this.policyId,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsDocumentEn,
    required this.controlsDocumentAr,
    required this.controlsWeight,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.departments,
    required this.equalWeights,
    required this.score,
    required this.status,
    required this.lastModifiedDate,
    required this.lastEditor,
    this.scoreHistory = const <ControlScorePoint>[],
  });

  /// function name: [copyWith]
  ///
  /// purpose: create a new [ControlEntity] instance with selected fields
  ///          replaced by new values, keeping all other fields unchanged.
  ///
  /// parameters:
  ///            [String] controlsNameEn: new English control name, if changed
  ///            [String] controlsNameAr: new Arabic control name, if changed
  ///            [String] controlsNumberEn: new English control number, if changed
  ///            [String] controlsNumberAr: new Arabic control number, if changed
  ///            [String] controlsDescriptionEn: new English description, if changed
  ///            [String] controlsDescriptionAr: new Arabic description, if changed
  ///            [String] controlsDocumentEn: new English document url/path, if changed
  ///            [String] controlsDocumentAr: new Arabic document url/path, if changed
  ///            [double] controlsWeight: new weight value, if changed
  ///            [String] frequency: new frequency value, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [List<DepartmentWeight>] departments: new departments (with weights) list, if changed
  ///            [bool] equalWeights: new equal-weights flag, if changed
  ///            [int] score: new score value, if changed
  ///            [ControlStatus] status: new status, if changed
  ///
  /// return type: [ControlEntity] - the updated entity instance
  ControlEntity copyWith({
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    String? controlsDocumentEn,
    String? controlsDocumentAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<DepartmentWeight>? departments,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
  }) {
    return ControlEntity(
      id: id,
      policyId: policyId,
      controlsNameEn: controlsNameEn ?? this.controlsNameEn,
      controlsNameAr: controlsNameAr ?? this.controlsNameAr,
      controlsNumberEn: controlsNumberEn ?? this.controlsNumberEn,
      controlsNumberAr: controlsNumberAr ?? this.controlsNumberAr,
      controlsDescriptionEn:
          controlsDescriptionEn ?? this.controlsDescriptionEn,
      controlsDescriptionAr:
          controlsDescriptionAr ?? this.controlsDescriptionAr,
      controlsDocumentEn: controlsDocumentEn ?? this.controlsDocumentEn,
      controlsDocumentAr: controlsDocumentAr ?? this.controlsDocumentAr,
      controlsWeight: controlsWeight ?? this.controlsWeight,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      departments: departments ?? this.departments,
      equalWeights: equalWeights ?? this.equalWeights,
      score: score ?? this.score,
      status: status ?? this.status,
      lastModifiedDate: lastModifiedDate,
      lastEditor: lastEditor,
      scoreHistory: scoreHistory,
    );
  }
}

/// Business rule: a Policy's Controls should collectively add up to 100
/// weight, but only Active, Scheduled, and Unassigned controls count toward
/// that total — Draft controls haven't been published yet, and Inactive/
/// Expired controls are no longer in effect. Extracted from
/// `PolicyViewModeWidget`'s State (where it lived as private helpers) so the
/// rule lives with the entity instead of a View widget.
extension ControlListWeightX on List<ControlEntity> {
  static const _weightScopedStatuses = {
    ControlStatus.active,
    ControlStatus.scheduled,
    ControlStatus.unassigned,
  };

  /// Sum of every Active/Scheduled/Unassigned control's weight.
  double get totalControlWeight =>
      where((c) => _weightScopedStatuses.contains(c.status))
          .fold<double>(0, (sum, c) => sum + c.controlsWeight);

  /// True when there's at least one Active/Scheduled/Unassigned control and
  /// their weights don't add up to 100 — i.e. the policy's controls are out
  /// of balance.
  bool get hasControlWeightIssue {
    final counted = where((c) => _weightScopedStatuses.contains(c.status));
    return counted.isNotEmpty && totalControlWeight != 100;
  }
}
