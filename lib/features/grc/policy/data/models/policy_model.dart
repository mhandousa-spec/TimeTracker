/// Module: Policy Management
/// Description: Defines the Policy Model used for data persistence with
///              full revision history per field, including status lifecycle.
///              Policies are stored in Firestore at:
///              GRC_Modules/{Module_ID}/Policies/{Policy_ID}
///              Controls now live in their own subcollection underneath this
///              document and are no longer embedded here.
/// Author: Mohamed Elrashidy
/// Date: 2025-01-15
/// Dependencies: PolicyEntity, PolicyStatus
/// Revision History: 2025-01-15 - Initial creation
///                   2026-07-06 - Added status history list (Mohamed Elrashidy)
///                   2026-07-14 - Migrated to the new schema: removed the
///                                nested controls List<List<ControlModel>>
///                                (Controls are now a Firestore
///                                subcollection), renamed Image to
///                                Policy_Image, split Policy_Document into
///                                En/Ar, dates now stored as ISO strings,
///                                and tracking fields renamed to
///                                Modification_Date/Modifiers. Removed
///                                Is_Deleted in favor of
///                                PolicyStatus.removed (Mohamed Elrashidy)
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';
import '../../domain/entities/policy_entity.dart';
import '../../domain/entities/policy_status.dart';
import '../../domain/entities/policy_weight_history_entry.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_model.dart
/// Purpose: Contains the PolicyModel class used for Firestore
///          (de)serialization with full revision history per field.
/// Author: Mohamed Elrashidy
/// Created At: 15/1/2025

/// function name: [_deriveStatus]
///
/// purpose: 'Draft', 'Inactive', and 'Removed' are the only statuses ever
///          set explicitly, and they're sticky. Any other stored status
///          ('Active', 'Scheduled', 'Expired' — including a value that was
///          correct when written but has since gone stale) is recomputed
///          live from where [startDate]/[endDate] fall relative to today,
///          so a Policy's displayed status is always current without
///          requiring an edit to refresh it.
///
/// parameters:
///            [String] rawStatus: the most recently stored status string
///            [DateTime] startDate: the policy's current Start Date
///            [DateTime] endDate: the policy's current End Date
///
/// return type: [PolicyStatus] - the status to actually display
PolicyStatus _deriveStatus({
  required String rawStatus,
  required DateTime startDate,
  required DateTime endDate,
}) {
  final sticky = PolicyStatus.fromString(rawStatus);
  if (sticky == PolicyStatus.draft ||
      sticky == PolicyStatus.inactive ||
      sticky == PolicyStatus.removed) {
    return sticky;
  }
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  if (endDate.isBefore(startOfToday)) return PolicyStatus.expired;
  if (startDate.isAfter(startOfToday)) return PolicyStatus.scheduled;
  return PolicyStatus.active;
}

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

/// class name: [PolicyModel]
///
/// purpose: represents a Policy record where every field is kept as a
///          List<...>. Each index across all Lists represents one historical
///          version at the same point in time. The [status] List tracks the
///          policy lifecycle (Draft → Active → Inactive / Scheduled /
///          Expired / Removed). Controls are intentionally NOT included
///          here - they live in their own Controls subcollection under this
///          Policy document and should be fetched/managed via ControlModel.
///
/// authors: Mohamed Elrashidy
///
/// created at: 15/1/2025
class PolicyModel {
  static const String _keyPolicyId = 'Policy_ID';
  static const String _keyPolicyImage = 'Policy_Image';
  static const String _keyPolicyNameEn = 'Policy_Name_En';
  static const String _keyPolicyNameAr = 'Policy_Name_Ar';
  static const String _keyPolicyNumberEn = 'Policy_Number_En';
  static const String _keyPolicyNumberAr = 'Policy_Number_Ar';
  static const String _keyPolicyDescriptionEn = 'Policy_Description_En';
  static const String _keyPolicyDescriptionAr = 'Policy_Description_Ar';
  static const String _keyPolicyStartDate = 'Policy_Start_Date';
  static const String _keyPolicyEndDate = 'Policy_End_Date';
  static const String _keyPolicyWeight = 'Policy_Weight';
  static const String _keyPolicyDocumentEn = 'Policy_Document_En';
  static const String _keyPolicyDocumentAr = 'Policy_Document_Ar';
  static const String _keyPolicyStatus = 'Policy_Status';
  static const String _keyPolicyScore = 'Policy_Score';

  final String id;
  final String moduleId;
  final List<String?> policyImage;
  final List<String> policyNameEn;
  final List<String> policyNameAr;
  final List<String> policyNumberEn;
  final List<String> policyNumberAr;
  final List<String> policyDescriptionEn;
  final List<String> policyDescriptionAr;
  final List<DateTime> startDate;
  final List<DateTime> endDate;
  final List<double> policyWeight;
  final List<String?> policyDocumentEn;
  final List<String?> policyDocumentAr;
  final List<String> status; // PolicyStatus.value strings
  final List<double> score;

  // Tracking
  final List<DateTime> lastModifiedDate;
  final List<String> editors;

  PolicyModel({
    required this.id,
    required this.moduleId,
    required this.policyImage,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.policyDocumentEn,
    required this.policyDocumentAr,
    required this.status,
    required this.score,
    required this.lastModifiedDate,
    required this.editors,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All PolicyModel Lists must have the same number of elements',
      );
    }
  }

  /// function name: [_allSameLength]
  ///
  /// purpose: validate that all history Lists share the same length.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all lengths match
  bool _allSameLength() {
    final lengths = <int>{
      policyImage.length,
      policyNameEn.length,
      policyNameAr.length,
      policyNumberEn.length,
      policyNumberAr.length,
      policyDescriptionEn.length,
      policyDescriptionAr.length,
      startDate.length,
      endDate.length,
      policyWeight.length,
      policyDocumentEn.length,
      policyDocumentAr.length,
      status.length,
      score.length,
      lastModifiedDate.length,
      editors.length,
    };
    return lengths.length == 1;
  }

  /// function name: [PolicyModel.create]
  ///
  /// purpose: build the first revision of a PolicyModel where every List
  ///          starts with exactly one element.
  ///
  /// parameters:
  ///            [String] id: unique identifier (Policy_ID)
  ///            [String] moduleId: parent module id (denormalized)
  ///            [String?] policyImage: initial image url/path
  ///            [String] policyNameEn: initial English name
  ///            [String] policyNameAr: initial Arabic name
  ///            [String] policyNumberEn: initial English number
  ///            [String] policyNumberAr: initial Arabic number
  ///            [String] policyDescriptionEn: initial English description
  ///            [String] policyDescriptionAr: initial Arabic description
  ///            [DateTime] startDate: initial start date
  ///            [DateTime] endDate: initial end date
  ///            [double] policyWeight: initial weight
  ///            [String?] policyDocumentEn: initial English document url/path
  ///            [String?] policyDocumentAr: initial Arabic document url/path
  ///            [PolicyStatus] status: initial lifecycle status
  ///            [String] editorId: id/email of the creating user
  ///
  /// return type: [PolicyModel] - the newly created model instance
  factory PolicyModel.create({
    required String id,
    required String moduleId,
    String? policyImage,
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    String? policyDocumentEn,
    String? policyDocumentAr,
    required PolicyStatus status,
    double score = 0,
    required String editorId,
  }) {
    final now = DateTime.now();
    return PolicyModel(
      id: id,
      moduleId: moduleId,
      policyImage: [policyImage],
      policyNameEn: [policyNameEn],
      policyNameAr: [policyNameAr],
      policyNumberEn: [policyNumberEn],
      policyNumberAr: [policyNumberAr],
      policyDescriptionEn: [policyDescriptionEn],
      policyDescriptionAr: [policyDescriptionAr],
      startDate: [startDate],
      endDate: [endDate],
      policyWeight: [policyWeight],
      policyDocumentEn: [policyDocumentEn],
      policyDocumentAr: [policyDocumentAr],
      status: [status.value],
      score: [score],
      lastModifiedDate: [now],
      editors: [editorId],
    );
  }

  /// function name: [copyWithUpdate]
  ///
  /// purpose: append a new revision to every List. Fields left null reuse
  ///          their last value so all Lists stay the same length.
  ///
  /// parameters:
  ///            [String?] policyImage: new image url/path, if changed
  ///            [String] policyNameEn: new English name, if changed
  ///            [String] policyNameAr: new Arabic name, if changed
  ///            [String] policyNumberEn: new English number, if changed
  ///            [String] policyNumberAr: new Arabic number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight, if changed
  ///            [String?] policyDocumentEn: new English document url/path, if changed
  ///            [String?] policyDocumentAr: new Arabic document url/path, if changed
  ///            [PolicyStatus] status: new lifecycle status, if changed
  ///            [String] editorId: id/email of the user performing the update (required)
  ///
  /// return type: [PolicyModel] - a new model with the appended revision
  PolicyModel copyWithUpdate({
    String? policyImage,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    String? policyDocumentEn,
    String? policyDocumentAr,
    PolicyStatus? status,
    double? score,
    required String editorId,
  }) {
    final now = DateTime.now();
    return PolicyModel(
      id: id,
      moduleId: moduleId,
      policyImage: [...this.policyImage, policyImage ?? this.policyImage.last],
      policyNameEn: [
        ...this.policyNameEn,
        policyNameEn ?? this.policyNameEn.last
      ],
      policyNameAr: [
        ...this.policyNameAr,
        policyNameAr ?? this.policyNameAr.last
      ],
      policyNumberEn: [
        ...this.policyNumberEn,
        policyNumberEn ?? this.policyNumberEn.last
      ],
      policyNumberAr: [
        ...this.policyNumberAr,
        policyNumberAr ?? this.policyNumberAr.last
      ],
      policyDescriptionEn: [
        ...this.policyDescriptionEn,
        policyDescriptionEn ?? this.policyDescriptionEn.last
      ],
      policyDescriptionAr: [
        ...this.policyDescriptionAr,
        policyDescriptionAr ?? this.policyDescriptionAr.last
      ],
      startDate: [
        ...this.startDate,
        startDate ?? this.startDate.last
      ],
      endDate: [
        ...this.endDate,
        endDate ?? this.endDate.last
      ],
      policyWeight: [
        ...this.policyWeight,
        policyWeight ?? this.policyWeight.last
      ],
      policyDocumentEn: [
        ...this.policyDocumentEn,
        policyDocumentEn ?? this.policyDocumentEn.last
      ],
      policyDocumentAr: [
        ...this.policyDocumentAr,
        policyDocumentAr ?? this.policyDocumentAr.last
      ],
      status: [...this.status, status?.value ?? this.status.last],
      score: [...this.score, score ?? this.score.last],
      lastModifiedDate: [...lastModifiedDate, now],
      editors: [...editors, editorId],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize to a Firestore-ready Map using Capital_Underscore
  ///          keys.
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore representation
  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.moduleId: moduleId,
      _keyPolicyId: id,
      _keyPolicyImage: policyImage,
      _keyPolicyNameEn: policyNameEn,
      _keyPolicyNameAr: policyNameAr,
      _keyPolicyNumberEn: policyNumberEn,
      _keyPolicyNumberAr: policyNumberAr,
      _keyPolicyDescriptionEn: policyDescriptionEn,
      _keyPolicyDescriptionAr: policyDescriptionAr,
      _keyPolicyStartDate:
          startDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyPolicyEndDate:
          endDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyPolicyWeight: policyWeight,
      _keyPolicyDocumentEn: policyDocumentEn,
      _keyPolicyDocumentAr: policyDocumentAr,
      _keyPolicyStatus: status,
      _keyPolicyScore: score,
      GrcFirestoreKeys.modificationDate:
          lastModifiedDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: editors,
    };
  }

  /// function name: [PolicyModel.fromJson]
  ///
  /// purpose: rebuild a [PolicyModel] from raw Firestore document data.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw Firestore document data
  ///
  /// return type: [PolicyModel] - the reconstructed model instance
  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    final editorsRaw =
        List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []);
    return PolicyModel(
      id: json[_keyPolicyId] as String,
      moduleId: json[GrcFirestoreKeys.moduleId] as String,
      policyImage: List<String?>.from(json[_keyPolicyImage] ?? []),
      policyNameEn: List<String>.from(json[_keyPolicyNameEn] ?? []),
      policyNameAr: List<String>.from(json[_keyPolicyNameAr] ?? []),
      policyNumberEn: List<String>.from(json[_keyPolicyNumberEn] ?? []),
      policyNumberAr: List<String>.from(json[_keyPolicyNumberAr] ?? []),
      policyDescriptionEn:
          List<String>.from(json[_keyPolicyDescriptionEn] ?? []),
      policyDescriptionAr:
          List<String>.from(json[_keyPolicyDescriptionAr] ?? []),
      startDate: (json[_keyPolicyStartDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      endDate: (json[_keyPolicyEndDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      policyWeight: (json[_keyPolicyWeight] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      policyDocumentEn: List<String?>.from(json[_keyPolicyDocumentEn] ?? []),
      policyDocumentAr: List<String?>.from(json[_keyPolicyDocumentAr] ?? []),
      status: json[_keyPolicyStatus] != null
          ? List<String>.from(json[_keyPolicyStatus])
          : List<String>.filled(editorsRaw.length, PolicyStatus.draft.value),
      score: json[_keyPolicyScore] != null
          ? (json[_keyPolicyScore] as List)
              .map((e) => (e as num).toDouble())
              .toList()
          : List<double>.filled(editorsRaw.length, 0),
      lastModifiedDate:
          (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
              .map((d) => _storageDateFormat.parse(d as String))
              .toList(),
      editors: editorsRaw,
    );
  }

  /// function name: [toEntity]
  ///
  /// purpose: convert the full history model to a [PolicyEntity] holding
  ///          only the latest value of every field. Controls are not part
  ///          of this conversion - fetch them separately from the Controls
  ///          subcollection via ControlModel.
  ///
  /// parameters: none
  ///
  /// return type: [PolicyEntity] - the entity built from the last index of every List
  PolicyEntity toEntity() {
    return PolicyEntity(
      id: id,
      moduleId: moduleId,
      policyImage: policyImage.last,
      policyNameEn: policyNameEn.last,
      policyNameAr: policyNameAr.last,
      policyNumberEn: policyNumberEn.last,
      policyNumberAr: policyNumberAr.last,
      policyDescriptionEn: policyDescriptionEn.last,
      policyDescriptionAr: policyDescriptionAr.last,
      startDate: startDate.last,
      endDate: endDate.last,
      policyWeight: policyWeight.last,
      policyDocumentEn: policyDocumentEn.last,
      policyDocumentAr: policyDocumentAr.last,
      status: _deriveStatus(
        rawStatus: status.last,
        startDate: startDate.last,
        endDate: endDate.last,
      ),
      score: score.last,
      lastModifiedDate: lastModifiedDate.last,
      lastEditor: editors.last,
      // Revision 0's date is when the policy was first written.
      createdAt: lastModifiedDate.first,
    );
  }

  /// function name: [toWeightHistory]
  ///
  /// purpose: reconstruct every recorded weight change by diffing
  ///          [policyWeight] between consecutive revisions. A change at
  ///          revision N is credited to whoever saved that revision
  ///          ([editors][N]) on [lastModifiedDate][N]. Revisions that
  ///          didn't touch the weight (previous == current) emit nothing.
  ///
  /// parameters: none
  ///
  /// return type: [List<PolicyWeightHistoryEntry>] - one entry per weight change, in revision order
  List<PolicyWeightHistoryEntry> toWeightHistory() {
    final entries = <PolicyWeightHistoryEntry>[];
    for (var i = 1; i < policyWeight.length; i++) {
      if (policyWeight[i] == policyWeight[i - 1]) continue;
      entries.add(
        PolicyWeightHistoryEntry(
          policyId: id,
          policyNameEn: policyNameEn[i],
          policyNameAr: policyNameAr[i],
          weightPrevious: policyWeight[i - 1],
          weightCurrent: policyWeight[i],
          changedByEmail: editors[i],
          dateOfAction: lastModifiedDate[i],
        ),
      );
    }
    return entries;
  }
}