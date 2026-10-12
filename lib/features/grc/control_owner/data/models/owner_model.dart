// lib/features/grc/control_owner/data/models/owner_model.dart
/// Module: Control Owner Management
/// Description: Defines the Model used to persist Control Owner records,
///              where every field except [controlOwnerPermissions] is
///              stored as a history List, exactly like GRCModuleModel.
///              Firestore path:
///              GRC Modules/{Module_ID}/Control Owners/{Owner_Email}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: AssigningControlModel, OwnerEntity, OwnerStatus, intl

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/control/data/models/assigning_control_model.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

class _OpenControlStint {
  final DateTime startDate;
  final String assignedByEmail;

  _OpenControlStint({required this.startDate, required this.assignedByEmail});
}

/// class name: [OwnerModel]
///
/// purpose: represents a Control Owner record. [assigningControls],
///          [status], [modificationDate], [modifiers] are history Lists
///          (index i = one revision), exactly like ChampionModel.
///          [controlOwnerPermissions] is NOT a history list — it always
///          holds the CURRENT permissions, one inner List<String> per
///          control in the latest revision's assigningControls, in the
///          same order (controlOwnerPermissions[i] belongs to
///          assigningControls.last[i]).
class OwnerModel {
  static const String _keyOwnerEmail = 'Owner_Email';
  static const String _keyOwnersStatus = 'Owners_Status';
  static const String _keyControlOwnersPermissions = 'Control_Owners_Permissions';

  final String ownerEmail;
  final List<List<AssigningControlModel>> assigningControls;
  final List<String> status; // 'Active' | 'Removed'
  final List<List<String>> controlOwnerPermissions;
  final List<DateTime> modificationDate;
  final List<String> modifiers;

  OwnerModel({
    required this.ownerEmail,
    required this.assigningControls,
    required this.status,
    required this.controlOwnerPermissions,
    required this.modificationDate,
    required this.modifiers,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All OwnerModel history Lists must have the same number of elements (same index count)',
      );
    }
    if (controlOwnerPermissions.length != assigningControls.last.length) {
      throw ArgumentError(
        'controlOwnerPermissions must have exactly one entry per control in the latest Assigning_Controls revision',
      );
    }
  }

  bool _allSameLength() {
    final lengths = <int>{
      assigningControls.length,
      status.length,
      modificationDate.length,
      modifiers.length,
    };
    return lengths.length == 1;
  }

  factory OwnerModel.create({
    required String ownerEmail,
    required List<AssigningControlModel> initialAssigningControls,
    required String modifierEmail,
    /// GRC bug report p2 — false stores kOwnerScoreByModuleOwner on every
    /// control assigned here.
    bool canGiveScore = true,
  }) {
    final now = DateTime.now();
    return OwnerModel(
      ownerEmail: ownerEmail,
      assigningControls: [initialAssigningControls],
      status: const ['Active'],
      controlOwnerPermissions: List<List<String>>.generate(
        initialAssigningControls.length,
        (_) => canGiveScore ? <String>[] : <String>[kOwnerScoreByModuleOwner],
      ),
      modificationDate: [now],
      modifiers: [modifierEmail],
    );
  }

  /// Matches each entry of [newControls] against the CURRENT (pre-update)
  /// assigningControls.last by (policyId, controlId) and carries over that
  /// control's existing permissions; a control with no match (newly added)
  /// defaults to an empty permissions list.
  List<List<String>> _carryOverPermissions(List<AssigningControlModel> newControls) {
    final previousControls = assigningControls.last;
    return newControls.map((newControl) {
      final oldIndex = previousControls.indexWhere(
        (old) =>
            old.policyId == newControl.policyId &&
            old.controlId == newControl.controlId,
      );
      if (oldIndex == -1 || oldIndex >= controlOwnerPermissions.length) {
        return <String>[];
      }
      return controlOwnerPermissions[oldIndex];
    }).toList();
  }

  /// Appends a new revision. If [assigningControls] changes and
  /// [controlOwnerPermissions] is not explicitly passed, permissions are
  /// carried over via [_carryOverPermissions]; otherwise the existing
  /// permissions are kept as-is.
  OwnerModel copyWithUpdate({
    List<AssigningControlModel>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    String? status,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    final newAssigningControls = assigningControls ?? this.assigningControls.last;
    final newPermissions = controlOwnerPermissions ??
        (assigningControls == null
            ? this.controlOwnerPermissions
            : _carryOverPermissions(newAssigningControls));
    return OwnerModel(
      ownerEmail: ownerEmail,
      assigningControls: [...this.assigningControls, newAssigningControls],
      status: [...this.status, status ?? this.status.last],
      controlOwnerPermissions: newPermissions,
      modificationDate: [...modificationDate, now],
      modifiers: [...modifiers, modifierEmail],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keyOwnerEmail: ownerEmail,
      GrcFirestoreKeys.assigningControls: assigningControls
          .map((rev) => {'Items': rev.map((a) => a.toJson()).toList()})
          .toList(),
      _keyOwnersStatus: status,
      _keyControlOwnersPermissions:
          controlOwnerPermissions.map((perms) => {'Items': perms}).toList(),
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: modifiers,
    };
  }

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      ownerEmail: json[_keyOwnerEmail] as String,
      assigningControls:
          (json[GrcFirestoreKeys.assigningControls] as List? ?? [])
              .map((rev) =>
                  ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
                      .map((item) => AssigningControlModel.fromJson(
                          item as Map<String, dynamic>))
                      .toList())
              .toList(),
      status: List<String>.from(json[_keyOwnersStatus] ?? []),
      controlOwnerPermissions:
          (json[_keyControlOwnersPermissions] as List? ?? [])
              .map((entry) => List<String>.from(
                  (entry as Map<String, dynamic>)['Items'] ?? []))
              .toList(),
      modificationDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      modifiers: List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []),
    );
  }

  OwnerEntity toEntity() {
    return OwnerEntity(
      ownerEmail: ownerEmail,
      assigningControls:
          assigningControls.last.map((a) => a.toEntity()).toList(),
      controlOwnerPermissions: controlOwnerPermissions,
      status: OwnerStatus.fromString(status.last),
      createdAt: modificationDate.first,
      modificationDate: modificationDate.last,
      lastModifier: modifiers.last,
    );
  }

  /// function name: [toControlAssignmentHistory]
  ///
  /// purpose: reconstruct every completed assignment stint this owner held
  ///          on one specific {policyId, controlId} pair, by diffing
  ///          [assigningControls] between consecutive revisions. The pair
  ///          appearing in revision N but not N-1 opens a stint (assigned
  ///          by [modifiers] at N); it disappearing between N-1 and N
  ///          closes the currently open stint (ends at [modificationDate]
  ///          at N) and emits one [ControlOwnerHistoryEntry]. A pair that
  ///          is still currently assigned (never removed) produces no
  ///          entry for that open stint.
  ///
  /// parameters:
  ///            [String] policyId: the Policy id half of the pair to track
  ///            [String] controlId: the Control id half of the pair to track
  ///
  /// return type: [List<ControlOwnerHistoryEntry>] - this owner's completed stints on this Control
  List<ControlOwnerHistoryEntry> toControlAssignmentHistory({
    required String policyId,
    required String controlId,
  }) {
    bool hasControl(List<AssigningControlModel> revision) => revision
        .any((a) => a.policyId == policyId && a.controlId == controlId);

    _OpenControlStint? open;
    if (hasControl(assigningControls.first)) {
      open = _OpenControlStint(
        startDate: modificationDate.first,
        assignedByEmail: modifiers.first,
      );
    }

    final entries = <ControlOwnerHistoryEntry>[];
    for (var i = 1; i < assigningControls.length; i++) {
      final wasAssigned = hasControl(assigningControls[i - 1]);
      final isAssigned = hasControl(assigningControls[i]);

      if (isAssigned && !wasAssigned) {
        open = _OpenControlStint(
          startDate: modificationDate[i],
          assignedByEmail: modifiers[i],
        );
      }

      if (!isAssigned && wasAssigned && open != null) {
        entries.add(ControlOwnerHistoryEntry(
          ownerEmail: ownerEmail,
          assignedByEmail: open.assignedByEmail,
          startDate: open.startDate,
          endDate: modificationDate[i],
        ));
        open = null;
      }
    }

    return entries;
  }
}
