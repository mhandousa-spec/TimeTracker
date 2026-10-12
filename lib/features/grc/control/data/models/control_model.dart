/// Module: Policy Management
/// Description: Defines the Control Model used for data persistence. Every
///              field is stored as a history List so that previous values
///              are never lost and each edit is fully traceable. Controls
///              are stored in Firestore as their own subcollection:
///              GRC_Modules/{Module_ID}/Policies/{Policy_ID}/Controls/{Control_ID}
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: ControlEntity, ControlStatus, DepartmentWeight
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the Controls subcollection
///                                schema: added policyId, number fields,
///                                split documents (En/Ar), start/end dates,
///                                departments, equalWeights, score, and
///                                Controls_Status history. Removed
///                                isDeleted in favor of ControlStatus
///                                (Mohamed Magdy Abdelkhalek)
///                   2026-07-18 - departments is now a history of
///                                List<DepartmentWeight> (department name +
///                                weight) instead of plain department
///                                names. When equalWeights is true, weights
///                                are auto-generated equally so they sum to
///                                100 (e.g. when "All" departments are
///                                picked). Added ControlStatus.scheduled
///                                (Mohamed Magdy Abdelkhalek)
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_department_weight.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_model.dart
/// Purpose: Contains the ControlModel class used for Firestore
///          (de)serialization. Controls now live in their own subcollection
///          under a Policy document, but still carry their own revision
///          history and tracking, exactly like PolicyModel.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

/// class name: [ControlModel]
///
/// purpose: represents a single Control record where every field is kept as
///          a List<...>. Each index across all the Lists (including
///          [editors] and [lastModifiedDate]) represents one historical
///          version of the Control at the same point in time.
///
///          Firestore path:
///          GRC_Modules/{Module_ID}/Policies/{Policy_ID}/Controls/{Control_ID}
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class ControlModel {
  static const String _keyControlsId = 'Controls_ID';
  static const String _keyControlsNameEn = 'Controls_Name_En';
  static const String _keyControlsNameAr = 'Controls_Name_Ar';
  static const String _keyControlsNumberEn = 'Controls_Number_En';
  static const String _keyControlsNumberAr = 'Controls_Number_Ar';
  static const String _keyControlsDescriptionEn = 'Controls_Description_En';
  static const String _keyControlsDescriptionAr = 'Controls_Description_Ar';
  static const String _keyControlsDocumentEn = 'Controls_Document_En';
  static const String _keyControlsDocumentAr = 'Controls_Document_Ar';
  static const String _keyControlsWeight = 'Controls_Weight';
  static const String _keyControlsFrequency = 'Controls_Frequency';
  static const String _keyControlsStartDate = 'Controls_Start_Date';
  static const String _keyControlsEndDate = 'Controls_End_Date';
  static const String _keyControlsDepartments = 'Controls_Departments';
  static const String _keyControlsEqualWeights = 'Controls_Equal_Weights';
  static const String _keyControlsScore = 'Controls_Score';
  static const String _keyControlsStatus = 'Controls_Status';

  final String id;
  final String policyId;
  final List<String> controlsNameEn;
  final List<String> controlsNameAr;
  final List<String> controlsNumberEn;
  final List<String> controlsNumberAr;
  final List<String> controlsDescriptionEn;
  final List<String> controlsDescriptionAr;
  final List<String?> controlsDocumentEn;
  final List<String?> controlsDocumentAr;
  final List<double> controlsWeight;
  final List<String> frequency;
  final List<DateTime> startDate;
  final List<DateTime> endDate;
  final List<List<DepartmentWeight>> departments;
  final List<bool> equalWeights;
  final List<int> score;
  final List<String> status; // ControlStatus.value strings

  // Tracking
  final List<DateTime> lastModifiedDate;
  final List<String> editors;

  ControlModel({
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
    required this.editors,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All ControlModel Lists must have the same number of elements (same index count)',
      );
    }
  }

  /// function name: [_allSameLength]
  ///
  /// purpose: validate that every history List inside the model has the
  ///          same length, guaranteeing index synchronization across all
  ///          fields and tracking lists.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all Lists share the same length
  bool _allSameLength() {
    final lengths = <int>{
      controlsNameEn.length,
      controlsNameAr.length,
      controlsNumberEn.length,
      controlsNumberAr.length,
      controlsDescriptionEn.length,
      controlsDescriptionAr.length,
      controlsDocumentEn.length,
      controlsDocumentAr.length,
      controlsWeight.length,
      frequency.length,
      startDate.length,
      endDate.length,
      departments.length,
      equalWeights.length,
      score.length,
      status.length,
      lastModifiedDate.length,
      editors.length,
    };
    return lengths.length == 1;
  }

  /// function name: [ControlModel.create]
  ///
  /// purpose: build a brand new [ControlModel] record where every history
  ///          List is initialized with a single element representing the
  ///          first (creation) revision of this Control.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the new control (Controls_ID)
  ///            [String] policyId: id of the parent Policy document
  ///            [String] controlsNameEn: initial English control name
  ///            [String] controlsNameAr: initial Arabic control name
  ///            [String] controlsNumberEn: initial English control number
  ///            [String] controlsNumberAr: initial Arabic control number
  ///            [String] controlsDescriptionEn: initial English description
  ///            [String] controlsDescriptionAr: initial Arabic description
  ///            [String?] controlsDocumentEn: initial English document url/path
  ///            [String?] controlsDocumentAr: initial Arabic document url/path
  ///            [double] controlsWeight: initial weight value
  ///            [String] frequency: initial frequency value
  ///            [DateTime] startDate: initial start date
  ///            [DateTime] endDate: initial end date
  ///            [List<String>] departments: initial department names to assign
  ///            [List<double>?] departmentWeights: initial weight per department, in the
  ///                                                same order as [departments]. Ignored when
  ///                                                [equalWeights] is true. Required (and must
  ///                                                match [departments] in length) when
  ///                                                [equalWeights] is false.
  ///            [bool] equalWeights: when true (e.g. the user picked "All" departments),
  ///                                 weights are generated automatically so every department
  ///                                 gets an equal share and the total always sums to 100
  ///            [int] score: initial score value
  ///            [ControlStatus] status: initial lifecycle status
  ///            [String] editorId: id/email of the user creating this control
  ///
  /// return type: [ControlModel] - the newly created model instance
  factory ControlModel.create({
    required String id,
    required String policyId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    String? controlsDocumentEn,
    String? controlsDocumentAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    List<double>? departmentWeights,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    required String editorId,
  }) {
    final now = DateTime.now();
    return ControlModel(
      id: id,
      policyId: policyId,
      controlsNameEn: [controlsNameEn],
      controlsNameAr: [controlsNameAr],
      controlsNumberEn: [controlsNumberEn],
      controlsNumberAr: [controlsNumberAr],
      controlsDescriptionEn: [controlsDescriptionEn],
      controlsDescriptionAr: [controlsDescriptionAr],
      controlsDocumentEn: [controlsDocumentEn],
      controlsDocumentAr: [controlsDocumentAr],
      controlsWeight: [controlsWeight],
      frequency: [frequency],
      startDate: [startDate],
      endDate: [endDate],
      departments: [
        _buildDepartmentWeights(
          departments: departments,
          departmentWeights: departmentWeights,
          equalWeights: equalWeights,
        ),
      ],
      equalWeights: [equalWeights],
      score: [score],
      status: [status.value],
      lastModifiedDate: [now],
      editors: [editorId],
    );
  }

  /// function name: [_buildDepartmentWeights]
  ///
  /// purpose: build the list of [DepartmentWeight] entries for one revision.
  ///          When [equalWeights] is true (the user selected "All"
  ///          departments, or otherwise wants an even split), the weight is
  ///          generated automatically via [DepartmentWeight.equalSplit] so
  ///          the total always sums to 100. Otherwise, the caller-supplied
  ///          [departmentWeights] are paired with [departments] in order.
  ///
  /// parameters:
  ///            [List<String>] departments: the department names for this revision
  ///            [List<double>?] departmentWeights: the manual weight per department, if not equal
  ///            [bool] equalWeights: whether weights should be split equally (summing to 100)
  ///
  /// return type: [List<DepartmentWeight>] - the department/weight pairs for this revision
  static List<DepartmentWeight> _buildDepartmentWeights({
    required List<String> departments,
    required List<double>? departmentWeights,
    required bool equalWeights,
  }) {
    if (equalWeights) {
      return DepartmentWeight.equalSplit(departments);
    }

    assert(
      departmentWeights != null &&
          departmentWeights.length == departments.length,
      'departmentWeights must be provided with the same length as '
      'departments when equalWeights is false',
    );

    return List<DepartmentWeight>.generate(
      departments.length,
      (i) => DepartmentWeight(
        department: departments[i],
        weight: departmentWeights![i],
      ),
    );
  }

  /// function name: [copyWithUpdate]
  ///
  /// purpose: append a new revision (new index) to every history List in
  ///          the control. Any field not explicitly passed reuses its last
  ///          known value, ensuring all Lists remain the same length.
  ///
  /// parameters:
  ///            [String] controlsNameEn: new English control name, if changed
  ///            [String] controlsNameAr: new Arabic control name, if changed
  ///            [String] controlsNumberEn: new English control number, if changed
  ///            [String] controlsNumberAr: new Arabic control number, if changed
  ///            [String] controlsDescriptionEn: new English description, if changed
  ///            [String] controlsDescriptionAr: new Arabic description, if changed
  ///            [String?] controlsDocumentEn: new English document url/path, if changed
  ///            [String?] controlsDocumentAr: new Arabic document url/path, if changed
  ///            [double] controlsWeight: new weight value, if changed
  ///            [String] frequency: new frequency value, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [List<String>] departments: new department names to assign, if changed
  ///            [List<double>?] departmentWeights: new weight per department, in the same
  ///                                                order as [departments]. Ignored when
  ///                                                [equalWeights] resolves to true. Required
  ///                                                (matching [departments] in length) when
  ///                                                [equalWeights] resolves to false.
  ///            [bool] equalWeights: new equal-weights flag, if changed. When true, department
  ///                                 weights are regenerated automatically so they always sum
  ///                                 to 100 (e.g. the user switched to "All" departments)
  ///            [int] score: new score value, if changed
  ///            [ControlStatus] status: new lifecycle status, if changed
  ///            [String] editorId: id/email of the user performing the update (required)
  ///
  /// return type: [ControlModel] - a new model instance with the appended revision
  ControlModel copyWithUpdate({
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
    List<String>? departments,
    List<double>? departmentWeights,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    required String editorId,
  }) {
    final now = DateTime.now();
    // Only rebuild the department/weight pairs when the department names or
    // the equalWeights flag actually changed; otherwise keep the previous
    // revision's weights untouched.
    final resolvedEqualWeights = equalWeights ?? this.equalWeights.last;
    final newDepartmentsRevision = (departments == null && equalWeights == null)
        ? this.departments.last
        : _buildDepartmentWeights(
            departments: departments ??
                this.departments.last.map((d) => d.department).toList(),
            departmentWeights: departmentWeights,
            equalWeights: resolvedEqualWeights,
          );
    return ControlModel(
      id: id,
      policyId: policyId,
      controlsNameEn: [
        ...this.controlsNameEn,
        controlsNameEn ?? this.controlsNameEn.last,
      ],
      controlsNameAr: [
        ...this.controlsNameAr,
        controlsNameAr ?? this.controlsNameAr.last,
      ],
      controlsNumberEn: [
        ...this.controlsNumberEn,
        controlsNumberEn ?? this.controlsNumberEn.last,
      ],
      controlsNumberAr: [
        ...this.controlsNumberAr,
        controlsNumberAr ?? this.controlsNumberAr.last,
      ],
      controlsDescriptionEn: [
        ...this.controlsDescriptionEn,
        controlsDescriptionEn ?? this.controlsDescriptionEn.last,
      ],
      controlsDescriptionAr: [
        ...this.controlsDescriptionAr,
        controlsDescriptionAr ?? this.controlsDescriptionAr.last,
      ],
      controlsDocumentEn: [
        ...this.controlsDocumentEn,
        controlsDocumentEn ?? this.controlsDocumentEn.last,
      ],
      controlsDocumentAr: [
        ...this.controlsDocumentAr,
        controlsDocumentAr ?? this.controlsDocumentAr.last,
      ],
      controlsWeight: [
        ...this.controlsWeight,
        controlsWeight ?? this.controlsWeight.last,
      ],
      frequency: [...this.frequency, frequency ?? this.frequency.last],
      startDate: [
        ...this.startDate,
        startDate ?? this.startDate.last,
      ],
      endDate: [
        ...this.endDate,
        endDate ?? this.endDate.last,
      ],
      departments: [...this.departments, newDepartmentsRevision],
      equalWeights: [
        ...this.equalWeights,
        equalWeights ?? this.equalWeights.last,
      ],
      score: [...this.score, score ?? this.score.last],
      status: [...this.status, status?.value ?? this.status.last],
      lastModifiedDate: [...lastModifiedDate, now],
      editors: [...editors, editorId],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize the control model into a Map ready to be stored
  ///          as a document inside the Controls subcollection. Keys follow
  ///          the Capital_Underscore convention used across the schema.
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore-ready representation of this control
  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.policyId: policyId,
      _keyControlsId: id,
      _keyControlsNameEn: controlsNameEn,
      _keyControlsNameAr: controlsNameAr,
      _keyControlsNumberEn: controlsNumberEn,
      _keyControlsNumberAr: controlsNumberAr,
      _keyControlsDescriptionEn: controlsDescriptionEn,
      _keyControlsDescriptionAr: controlsDescriptionAr,
      _keyControlsDocumentEn: controlsDocumentEn,
      _keyControlsDocumentAr: controlsDocumentAr,
      _keyControlsWeight: controlsWeight,
      _keyControlsFrequency: frequency,
      _keyControlsStartDate:
          startDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyControlsEndDate:
          endDate.map((d) => _storageDateFormat.format(d)).toList(),
      // Firestore rejects arrays that directly contain other arrays, so each
      // revision's department list is wrapped in a map (List<List<...>>
      // would otherwise serialize as a nested array and the write would
      // throw). Each item is itself a {Department, Weight} map.
      _keyControlsDepartments: departments
          .map((rev) => {'Items': rev.map((d) => d.toJson()).toList()})
          .toList(),
      _keyControlsEqualWeights: equalWeights,
      _keyControlsScore: score,
      _keyControlsStatus: status,
      GrcFirestoreKeys.modificationDate:
          lastModifiedDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: editors,
    };
  }

  /// function name: [ControlModel.fromJson]
  ///
  /// purpose: rebuild a [ControlModel] instance from the raw document data
  ///          retrieved from the Controls subcollection.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw control document data from Firestore
  ///
  /// return type: [ControlModel] - the reconstructed model instance
  factory ControlModel.fromJson(Map<String, dynamic> json) {
    final editorsRaw =
        List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []);
    return ControlModel(
      id: json[_keyControlsId] as String,
      policyId: json[GrcFirestoreKeys.policyId] as String,
      controlsNameEn: List<String>.from(json[_keyControlsNameEn] ?? []),
      controlsNameAr: List<String>.from(json[_keyControlsNameAr] ?? []),
      controlsNumberEn: List<String>.from(json[_keyControlsNumberEn] ?? []),
      controlsNumberAr: List<String>.from(json[_keyControlsNumberAr] ?? []),
      controlsDescriptionEn:
          List<String>.from(json[_keyControlsDescriptionEn] ?? []),
      controlsDescriptionAr:
          List<String>.from(json[_keyControlsDescriptionAr] ?? []),
      controlsDocumentEn:
          List<String?>.from(json[_keyControlsDocumentEn] ?? []),
      controlsDocumentAr:
          List<String?>.from(json[_keyControlsDocumentAr] ?? []),
      controlsWeight: (json[_keyControlsWeight] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      frequency: List<String>.from(json[_keyControlsFrequency] ?? []),
      startDate: (json[_keyControlsStartDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      endDate: (json[_keyControlsEndDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      departments: (json[_keyControlsDepartments] as List? ?? [])
          .map((rev) => ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
              .map((item) =>
                  DepartmentWeight.fromJson(item as Map<String, dynamic>))
              .toList())
          .toList(),
      equalWeights: List<bool>.from(json[_keyControlsEqualWeights] ?? []),
      score: List<int>.from(json[_keyControlsScore] ?? []),
      status: json[_keyControlsStatus] != null
          ? List<String>.from(json[_keyControlsStatus])
          : List<String>.filled(
              editorsRaw.length, ControlStatus.unassigned.value),
      lastModifiedDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      editors: editorsRaw,
    );
  }

  /// function name: [toEntity]
  ///
  /// purpose: convert this model (full revision history) into a
  ///          [ControlEntity] that holds only the latest (current) value
  ///          of every field, derived from the last index of each List.
  ///
  /// parameters: none
  ///
  /// return type: [ControlEntity] - the flattened entity built from the last index of every List
  ControlEntity toEntity() {
    return ControlEntity(
      id: id,
      policyId: policyId,
      controlsNameEn: controlsNameEn.last,
      controlsNameAr: controlsNameAr.last,
      controlsNumberEn: controlsNumberEn.last,
      controlsNumberAr: controlsNumberAr.last,
      controlsDescriptionEn: controlsDescriptionEn.last,
      controlsDescriptionAr: controlsDescriptionAr.last,
      controlsDocumentEn: controlsDocumentEn.last,
      controlsDocumentAr: controlsDocumentAr.last,
      controlsWeight: controlsWeight.last,
      frequency: frequency.last,
      startDate: startDate.last,
      endDate: endDate.last,
      departments: departments.last,
      equalWeights: equalWeights.last,
      score: score.last,
      status: ControlStatus.fromString(status.last),
      lastModifiedDate: lastModifiedDate.last,
      lastEditor: editors.last,
      scoreHistory: <ControlScorePoint>[
        for (var i = 0; i < score.length && i < lastModifiedDate.length; i++)
          ControlScorePoint(date: lastModifiedDate[i], score: score[i]),
      ],
    );
  }

  /// function name: [toWeightHistory]
  ///
  /// purpose: reconstruct every recorded weight change by diffing
  ///          [controlsWeight] between consecutive revisions. A change at
  ///          revision N is credited to whoever saved that revision
  ///          ([editors][N]) on [lastModifiedDate][N]. Revisions that
  ///          didn't touch the weight (previous == current) emit nothing.
  ///
  /// parameters: none
  ///
  /// return type: [List<ControlWeightHistoryEntry>] - one entry per weight change, in revision order
  List<ControlWeightHistoryEntry> toWeightHistory() {
    final entries = <ControlWeightHistoryEntry>[];
    for (var i = 1; i < controlsWeight.length; i++) {
      if (controlsWeight[i] == controlsWeight[i - 1]) continue;
      entries.add(
        ControlWeightHistoryEntry(
          controlId: id,
          policyId: policyId,
          controlsNameEn: controlsNameEn[i],
          controlsNameAr: controlsNameAr[i],
          weightPrevious: controlsWeight[i - 1],
          weightCurrent: controlsWeight[i],
          changedByEmail: editors[i],
          dateOfAction: lastModifiedDate[i],
        ),
      );
    }
    return entries;
  }
}