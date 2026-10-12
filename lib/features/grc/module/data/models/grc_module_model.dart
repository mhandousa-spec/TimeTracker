/// Module: GRC Module Management
/// Description: Defines the Model used to persist GRC Module records, where
///              every field is stored as a history List so that previous
///              values are never lost and each edit is fully traceable.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: GRCModuleEntity, dart:convert
/// Revision History: 2026-06-30 - Initial creation
///                   2026-07-06 - Aligned Firestore keys and Dart field names to
///                                the updated schema; removed isDeleted list
///                                (soft-delete now via Status:"Removed");
///                                Editors→Modifiers stores user email;
///                                added "Scheduled" status value
///                                (Mohamed Magdy Abdelkhalek)
library;

import 'dart:convert';

import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';
import 'package:intl/intl.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_model.dart
/// Purpose: Contains the GRCModuleModel class used for create/update/read
///          operations and Firestore (de)serialization.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

/// function name: [_deriveStatus]
///
/// purpose: 'Inactive' and 'Removed' are the only statuses a caller sets
///          explicitly, and they're sticky. Any other requested status
///          (including the default 'Active' the UI sends) is derived from
///          whether [activationDate] has arrived yet.
///
/// parameters:
///            [String] requestedStatus: the status a caller asked for
///            [DateTime] activationDate: the record's activation date
///
/// return type: [String] - 'Inactive' | 'Removed' | 'Scheduled' | 'Active'
String _deriveStatus({
  required String requestedStatus,
  required DateTime activationDate,
}) {
  final requested = GrcModuleStatus.fromString(requestedStatus);
  if (requested == GrcModuleStatus.inactive ||
      requested == GrcModuleStatus.removed) {
    return requested.value;
  }
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return activationDate.isAfter(startOfToday)
      ? GrcModuleStatus.scheduled.value
      : GrcModuleStatus.active.value;
}

/// Tracks an owner stint that has been opened (added) but not yet closed
/// (removed), while [GRCModuleModel.toOwnerHistory] walks the revisions.
class _OpenOwnerStint {
  final DateTime startDate;
  final String assignedByEmail;

  _OpenOwnerStint({required this.startDate, required this.assignedByEmail});
}

/// class name: [GRCModuleModel]
///
/// purpose: represents a GRC Module record where every field is kept as a
///          List<...>. Each index across all the Lists (including [modifiers]
///          and [modificationDate]) represents one historical version of the
///          record at the same point in time. Updating any single field
///          requires appending a new element to every List (re-using the
///          previous value for unchanged fields) so that all Lists always stay
///          the same length.
///
///          Soft-delete is no longer a separate [isDeleted] List. Setting
///          [status] to "Removed" via [copyWithUpdate] is the canonical
///          delete operation, and setting it back to "Active" restores it.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleModel {
  static const String _keyModuleImage = 'Module_Image';
  static const String _keyModuleNameEn = 'Module_Name_En';
  static const String _keyModuleNameAr = 'Module_Name_Ar';
  static const String _keyModuleDescriptionEn = 'Module_Description_En';
  static const String _keyModuleDescriptionAr = 'Module_Description_Ar';
  static const String _keyModuleOwningDepartment = 'Module_Owning_Department';
  static const String _keyModuleActivationDate = 'Module_Activation_Date';
  static const String _keyModuleOwners = 'Module_Owners';
  static const String _keyStatus = 'Status';
  static const String _keyModuleScore = 'Module_Score';

  final String moduleId;

  final List<String?> moduleImage;
  final List<String> moduleNameEn;
  final List<String> moduleNameAr;
  final List<String> moduleDescriptionEn;
  final List<String> moduleDescriptionAr;
  final List<String> moduleOwningDepartment;
  final List<DateTime> moduleActivationDate;

  /// Each element is a JSON-encoded List<String> of owner **email addresses**.
  /// Firestore rejects nested arrays, so every revision's owner list is
  /// stored as jsonEncode(List<String>) and decoded on read.
  final List<String> moduleOwners;

  /// "Active" | "Inactive" | "Scheduled" | "Removed"
  final List<String> status;

  final List<double> score;

  // Tracking fields
  final List<DateTime> modificationDate;

  /// Stores the email address of the user responsible for each revision.
  final List<String> modifiers;

  GRCModuleModel({
    required this.moduleId,
    required this.moduleImage,
    required this.moduleNameEn,
    required this.moduleNameAr,
    required this.moduleDescriptionEn,
    required this.moduleDescriptionAr,
    required this.moduleOwningDepartment,
    required this.moduleActivationDate,
    required this.moduleOwners,
    required this.status,
    required this.score,
    required this.modificationDate,
    required this.modifiers,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All Lists must have the same number of elements (same index count)',
      );
    }
  }

  /// function name: [_allSameLength]
  ///
  /// purpose: validate that every history List in the model has the exact
  ///          same length, guaranteeing that the indexes stay synchronized
  ///          across all fields.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all Lists share the same length
  bool _allSameLength() {
    final lengths = <int>{
      moduleImage.length,
      moduleNameEn.length,
      moduleNameAr.length,
      moduleDescriptionEn.length,
      moduleDescriptionAr.length,
      moduleOwningDepartment.length,
      moduleActivationDate.length,
      moduleOwners.length,
      status.length,
      score.length,
      modificationDate.length,
      modifiers.length,
    };
    return lengths.length == 1;
  }

  /// function name: [GRCModuleModel.create]
  ///
  /// purpose: build a brand new [GRCModuleModel] record. Every history List
  ///          is initialized with a single element representing the first
  ///          (creation) revision. The initial status is always "Active".
  ///
  /// parameters:
  ///            [String] moduleId: unique identifier of the new record
  ///            [String] moduleImage: initial image url/path
  ///            [String] moduleNameEn: initial English module name
  ///            [String] moduleNameAr: initial Arabic module name
  ///            [String] moduleDescriptionEn: initial English description
  ///            [String] moduleDescriptionAr: initial Arabic description
  ///            [String] moduleOwningDepartment: initial owning department
  ///            [DateTime] moduleActivationDate: initial activation date
  ///            [List<String>] owners: initial list of owner ids
  ///            [String] status: initial status ("Active" | "Inactive" | "Scheduled")
  ///            [String] modifierEmail: email of the user creating the record
  ///
  /// return type: [GRCModuleModel] - the newly created model instance
  factory GRCModuleModel.create({
    required String moduleId,
    String? moduleImage,
    required String moduleNameEn,
    required String moduleNameAr,
    required String moduleDescriptionEn,
    required String moduleDescriptionAr,
    required String moduleOwningDepartment,
    required DateTime moduleActivationDate,
    required List<String> owners,
    required String status,
    double score = 0,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    return GRCModuleModel(
      moduleId: moduleId,
      moduleImage: [moduleImage],
      moduleNameEn: [moduleNameEn],
      moduleNameAr: [moduleNameAr],
      moduleDescriptionEn: [moduleDescriptionEn],
      moduleDescriptionAr: [moduleDescriptionAr],
      moduleOwningDepartment: [moduleOwningDepartment],
      moduleActivationDate: [moduleActivationDate],
      // JSON-encode the owners list into a single String for Firestore.
      moduleOwners: [jsonEncode(owners)],
      status: [
        _deriveStatus(
          requestedStatus: status,
          activationDate: moduleActivationDate,
        ),
      ],
      score: [score],
      modificationDate: [now],
      modifiers: [modifierEmail],
    );
  }

  /// function name: [copyWithUpdate]
  ///
  /// purpose: append a new revision (new index) to every history List in the
  ///          model. Any field not explicitly passed reuses its last known
  ///          value, ensuring all Lists remain the same length after the
  ///          update.
  ///
  ///          To soft-delete: pass status: "Removed".
  ///          To restore:     pass status: "Active".
  ///
  /// parameters:
  ///            [String] moduleImage: new image url/path, if changed
  ///            [String] moduleNameEn: new English module name, if changed
  ///            [String] moduleNameAr: new Arabic module name, if changed
  ///            [String] moduleDescriptionEn: new English description, if changed
  ///            [String] moduleDescriptionAr: new Arabic description, if changed
  ///            [String] moduleOwningDepartment: new owning department, if changed
  ///            [DateTime] moduleActivationDate: new activation date, if changed
  ///            [List<String>] owners: new owners list (raw ids), if changed
  ///            [String] status: new status ("Active"|"Inactive"|"Scheduled"|"Removed"), if changed
  ///            [String] modifierEmail: email of the user performing the update (required)
  ///
  /// return type: [GRCModuleModel] - a new model instance with the appended revision
  GRCModuleModel copyWithUpdate({
    String? moduleImage,
    String? moduleNameEn,
    String? moduleNameAr,
    String? moduleDescriptionEn,
    String? moduleDescriptionAr,
    String? moduleOwningDepartment,
    DateTime? moduleActivationDate,
    List<String>? owners,
    String? status,
    double? score,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    return GRCModuleModel(
      moduleId: moduleId,
      moduleImage: [...this.moduleImage, moduleImage ?? this.moduleImage.last],
      moduleNameEn: [
        ...this.moduleNameEn,
        moduleNameEn ?? this.moduleNameEn.last
      ],
      moduleNameAr: [
        ...this.moduleNameAr,
        moduleNameAr ?? this.moduleNameAr.last
      ],
      moduleDescriptionEn: [
        ...this.moduleDescriptionEn,
        moduleDescriptionEn ?? this.moduleDescriptionEn.last,
      ],
      moduleDescriptionAr: [
        ...this.moduleDescriptionAr,
        moduleDescriptionAr ?? this.moduleDescriptionAr.last,
      ],
      moduleOwningDepartment: [
        ...this.moduleOwningDepartment,
        moduleOwningDepartment ?? this.moduleOwningDepartment.last,
      ],
      moduleActivationDate: [
        ...this.moduleActivationDate,
        moduleActivationDate ?? this.moduleActivationDate.last,
      ],
      // JSON-encode the new owners list if provided; otherwise carry forward
      // the last encoded string as-is (already encoded from a previous revision).
      moduleOwners: [
        ...moduleOwners,
        owners != null ? jsonEncode(owners) : moduleOwners.last,
      ],
      status: [
        ...this.status,
        _deriveStatus(
          requestedStatus: status ?? this.status.last,
          activationDate:
              moduleActivationDate ?? this.moduleActivationDate.last,
        ),
      ],
      score: [...this.score, score ?? this.score.last],
      modificationDate: [...modificationDate, now],
      modifiers: [...modifiers, modifierEmail],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize the model into a Map ready to be persisted in
  ///          Firestore. Keys exactly match the schema:
  ///
  ///          Module_ID | Module_Image | Module_Name_En | Module_Name_Ar |
  ///          Module_Description_En | Module_Description_Ar |
  ///          Module_Owning_Department | Module_Activation_Date |
  ///          Module_Owners | Status | Modification_Date | Modifiers
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore-ready representation
  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.moduleId: moduleId,
      _keyModuleImage: moduleImage,
      _keyModuleNameEn: moduleNameEn,
      _keyModuleNameAr: moduleNameAr,
      _keyModuleDescriptionEn: moduleDescriptionEn,
      _keyModuleDescriptionAr: moduleDescriptionAr,
      _keyModuleOwningDepartment: moduleOwningDepartment,
      _keyModuleActivationDate: moduleActivationDate
          .map((d) => _storageDateFormat.format(d))
          .toList(),
      // Already JSON-encoded strings — stored as List<String> in Firestore.
      _keyModuleOwners: moduleOwners,
      _keyStatus: status,
      _keyModuleScore: score,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: modifiers,
    };
  }

  /// function name: [GRCModuleModel.fromJson]
  ///
  /// purpose: rebuild a [GRCModuleModel] instance from the raw Map retrieved
  ///          from Firestore.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw document data from Firestore
  ///
  /// return type: [GRCModuleModel] - the reconstructed model instance
  factory GRCModuleModel.fromJson(Map<String, dynamic> json) {
    final modifiersRaw =
        List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []);
    return GRCModuleModel(
      moduleId: json[GrcFirestoreKeys.moduleId] as String,
      moduleImage: List<String?>.from(json[_keyModuleImage] ?? []),
      moduleNameEn: List<String>.from(json[_keyModuleNameEn] ?? []),
      moduleNameAr: List<String>.from(json[_keyModuleNameAr] ?? []),
      moduleDescriptionEn:
          List<String>.from(json[_keyModuleDescriptionEn] ?? []),
      moduleDescriptionAr:
          List<String>.from(json[_keyModuleDescriptionAr] ?? []),
      moduleOwningDepartment:
          List<String>.from(json[_keyModuleOwningDepartment] ?? []),
      moduleActivationDate: (json[_keyModuleActivationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      // Stored as List<String> of JSON-encoded owner lists — keep as-is;
      // decoding happens in toEntity() when the latest value is needed.
      moduleOwners: List<String>.from(json[_keyModuleOwners] ?? []),
      status: json[_keyStatus] != null
          ? List<String>.from(json[_keyStatus])
          // Backwards-compat: documents written before the Status field was
          // added default to "Active".
          : List<String>.filled(
              modifiersRaw.length, GrcModuleStatus.active.value),
      score: json[_keyModuleScore] != null
          ? (json[_keyModuleScore] as List)
              .map((e) => (e as num).toDouble())
              .toList()
          : List<double>.filled(modifiersRaw.length, 0),
      modificationDate:
          (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
              .map((d) => _storageDateFormat.parse(d as String))
              .toList(),
      modifiers: modifiersRaw,
    );
  }

  /// function name: [toEntity]
  ///
  /// purpose: convert the model (full revision history) into a
  ///          [GRCModuleEntity] holding only the latest (current) value of
  ///          every field, which is what the rest of the app actually consumes.
  ///          The owners string is decoded back to List<String> here.
  ///
  /// parameters: none
  ///
  /// return type: [GRCModuleEntity] - the flattened entity from the last index
  GRCModuleEntity toEntity() {
    final currentActivationDate = moduleActivationDate.last;
    return GRCModuleEntity(
      moduleId: moduleId,
      moduleImage: moduleImage.last,
      moduleNameEn: moduleNameEn.last,
      moduleNameAr: moduleNameAr.last,
      moduleDescriptionEn: moduleDescriptionEn.last,
      moduleDescriptionAr: moduleDescriptionAr.last,
      moduleOwningDepartment: moduleOwningDepartment.last,
      moduleActivationDate: currentActivationDate,
      // Decode the JSON-encoded string back to List<String>.
      moduleOwners: List<String>.from(
        jsonDecode(moduleOwners.last) as List,
      ),
      status: _deriveStatus(
        requestedStatus: status.last,
        activationDate: currentActivationDate,
      ),
      score: score.last,
      createdAt: modificationDate.first,
      modificationDate: modificationDate.last,
      lastModifier: modifiers.last,
    );
  }

  /// function name: [toOwnerHistory]
  ///
  /// purpose: reconstruct every completed owner-assignment stint by diffing
  ///          [moduleOwners] between consecutive revisions. An owner email
  ///          appearing in revision N but not N-1 opens a stint (assigned by
  ///          [modifiers] at N); an owner email disappearing between N-1 and
  ///          N closes their currently open stint (ends at
  ///          [modificationDate] at N) and emits one
  ///          [GRCModuleOwnerHistoryEntry]. Currently-active owners (never
  ///          removed) never appear in the result. If the same owner is
  ///          added and removed multiple times, each removal produces its
  ///          own entry.
  ///
  /// parameters: none
  ///
  /// return type: [List<GRCModuleOwnerHistoryEntry>] - completed stints only, sorted by endDate descending
  List<GRCModuleOwnerHistoryEntry> toOwnerHistory() {
    final ownerSets = moduleOwners
        .map((raw) => Set<String>.from(jsonDecode(raw) as List))
        .toList();

    final openStints = <String, _OpenOwnerStint>{};
    for (final email in ownerSets.first) {
      openStints[email] = _OpenOwnerStint(
        startDate: modificationDate.first,
        assignedByEmail: modifiers.first,
      );
    }

    final entries = <GRCModuleOwnerHistoryEntry>[];
    for (var i = 1; i < ownerSets.length; i++) {
      final previous = ownerSets[i - 1];
      final current = ownerSets[i];

      for (final email in current.difference(previous)) {
        openStints[email] = _OpenOwnerStint(
          startDate: modificationDate[i],
          assignedByEmail: modifiers[i],
        );
      }

      for (final email in previous.difference(current)) {
        final stint = openStints.remove(email);
        if (stint == null) continue;
        entries.add(GRCModuleOwnerHistoryEntry(
          ownerEmail: email,
          assignedByEmail: stint.assignedByEmail,
          startDate: stint.startDate,
          endDate: modificationDate[i],
        ));
      }
    }

    entries.sort((a, b) => b.endDate.compareTo(a.endDate));
    return entries;
  }
}
