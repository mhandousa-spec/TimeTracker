// lib/features/grc/control_champion/data/models/champion_model.dart
/// Module: Control Champion Management
/// Description: Defines the Model used to persist Control Champion records,
///              where every field is stored as a history List so that
///              previous values are never lost and each edit is fully
///              traceable, exactly like GRCModuleModel. Firestore path:
///              GRC Modules/{Module_ID}/Control Champions/{Champion_Email}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: AssigningControlModel, ChampionEntity, ChampionStatus, intl

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/control/data/models/assigning_control_model.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

/// class name: [ChampionModel]
///
/// purpose: represents a Control Champion record where every field is kept
///          as a List<...>; index i across all Lists is one revision.
///          [championEmail] is the Firestore document id and is NOT a
///          history list. [assigningControls] is Items-wrapped in Firestore
///          (see [toJson]) because Firestore rejects arrays that directly
///          contain other arrays.
class ChampionModel {
  static const String _keyChampionEmail = 'Champion_Email';
  static const String _keyChampionStatus = 'Champion_Status';

  final String championEmail;
  final List<List<AssigningControlModel>> assigningControls;
  final List<String> status; // 'Active' | 'Removed'
  final List<DateTime> modificationDate;
  final List<String> modifiers;

  ChampionModel({
    required this.championEmail,
    required this.assigningControls,
    required this.status,
    required this.modificationDate,
    required this.modifiers,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All ChampionModel Lists must have the same number of elements (same index count)',
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

  factory ChampionModel.create({
    required String championEmail,
    required List<AssigningControlModel> initialAssigningControls,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    return ChampionModel(
      championEmail: championEmail,
      assigningControls: [initialAssigningControls],
      status: [ChampionStatus.active.value],
      modificationDate: [now],
      modifiers: [modifierEmail],
    );
  }

  /// Appends a new revision to every history List, reusing the previous
  /// value for any field not passed. Pass status: 'Removed' to soft-delete,
  /// 'Active' to restore.
  ChampionModel copyWithUpdate({
    List<AssigningControlModel>? assigningControls,
    String? status,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    return ChampionModel(
      championEmail: championEmail,
      assigningControls: [
        ...this.assigningControls,
        assigningControls ?? this.assigningControls.last,
      ],
      status: [...this.status, status ?? this.status.last],
      modificationDate: [...modificationDate, now],
      modifiers: [...modifiers, modifierEmail],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keyChampionEmail: championEmail,
      GrcFirestoreKeys.assigningControls: assigningControls
          .map((rev) => {'Items': rev.map((a) => a.toJson()).toList()})
          .toList(),
      _keyChampionStatus: status,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: modifiers,
    };
  }

  factory ChampionModel.fromJson(Map<String, dynamic> json) {
    return ChampionModel(
      championEmail: json[_keyChampionEmail] as String,
      assigningControls:
          (json[GrcFirestoreKeys.assigningControls] as List? ?? [])
              .map((rev) =>
                  ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
                      .map((item) => AssigningControlModel.fromJson(
                          item as Map<String, dynamic>))
                      .toList())
              .toList(),
      status: List<String>.from(json[_keyChampionStatus] ?? []),
      modificationDate:
          (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
              .map((d) => _storageDateFormat.parse(d as String))
              .toList(),
      modifiers: List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []),
    );
  }

  ChampionEntity toEntity() {
    return ChampionEntity(
      championEmail: championEmail,
      assigningControls:
          assigningControls.last.map((a) => a.toEntity()).toList(),
      status: ChampionStatus.fromString(status.last),
      createdAt: modificationDate.first,
      modificationDate: modificationDate.last,
      lastModifier: modifiers.last,
    );
  }
}
