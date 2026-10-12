// ***************************** FILE INFO ***************************** //
// File Name: shift_model.dart
// Purpose: Defines recurring HR shifts and their revision history.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/shift_entity.dart';

/// Represents a recurring shift with aligned revision history lists.
class ShiftModel {
  ShiftModel({
    required this.id,
    required this.locationIds,
    required this.branchIds,
    required this.startMinutesHistory,
    required this.endMinutesHistory,
    required this.timestamps,
    required this.editors,
  });

  static const String idKey = 'Id';
  static const String locationIdsKey = 'Location_Ids';
  static const String branchIdsKey = 'Branch_Ids';
  static const String startMinutesKey = 'Start_Minutes';
  static const String endMinutesKey = 'End_Minutes';
  static const String timestampsKey = 'Timestamps';
  static const String editorKey = 'Editor';

  final String id;
  final List<String> locationIds;
  final List<String> branchIds;
  final List<int> startMinutesHistory;
  final List<int> endMinutesHistory;
  final List<Timestamp> timestamps;
  final List<String> editors;

  String get locationId => locationIds.last;
  String get branchId => branchIds.last;
  int get startMinutes => startMinutesHistory.last;
  int get endMinutes => endMinutesHistory.last;
  String get currentLocationId => locationId;
  String get currentBranchId => branchId;
  int get currentStartMinutes => startMinutes;
  int get currentEndMinutes => endMinutes;

  /// Method Name: [toEntity]
  ///
  /// Purpose: Converts this persistence model to its domain representation.
  ///
  /// Returns: A tracked shift entity.
  ShiftEntity toEntity() => ShiftEntity(
        id: id,
        locationId: locationId,
        branchId: branchId,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
      );

  /// Method Name: [withInitialRevision]
  ///
  /// Purpose: Adds the first audit timestamp and editor to a draft shift.
  ///
  /// Returns: A tracked shift with one complete revision.
  ShiftModel withInitialRevision(
          {required String editorId, Timestamp? timestamp}) =>
      ShiftModel(
        id: id,
        locationIds: [locationId],
        branchIds: [branchId],
        startMinutesHistory: [startMinutes],
        endMinutesHistory: [endMinutes],
        timestamps: [timestamp ?? Timestamp.now()],
        editors: [editorId],
      );

  /// Method Name: [appendRevision]
  ///
  /// Purpose: Appends one aligned shift revision without changing its ID.
  ///
  /// Returns: A new shift containing the appended revision.
  ShiftModel appendRevision({
    required String locationId,
    required String branchId,
    required int startMinutes,
    required int endMinutes,
    required String editorId,
    Timestamp? timestamp,
  }) =>
      ShiftModel(
        id: id,
        locationIds: [...locationIds, locationId],
        branchIds: [...branchIds, branchId],
        startMinutesHistory: [...startMinutesHistory, startMinutes],
        endMinutesHistory: [...endMinutesHistory, endMinutes],
        timestamps: [..._revisionTimestamps, timestamp ?? Timestamp.now()],
        editors: [..._revisionEditors, editorId],
      );

  List<Timestamp> get _revisionTimestamps =>
      timestamps.isEmpty ? [Timestamp.now()] : timestamps;
  List<String> get _revisionEditors => editors.isEmpty ? [''] : editors;

  /// Method Name: [copyWith]
  ///
  /// Purpose: Creates a copy while preserving tracked history.
  ///
  /// Returns: A copied shift model.
  ShiftModel copyWith({
    String? id,
    List<String>? locationIds,
    List<String>? branchIds,
    List<int>? startMinutesHistory,
    List<int>? endMinutesHistory,
    List<Timestamp>? timestamps,
    List<String>? editors,
  }) =>
      ShiftModel(
        id: id ?? this.id,
        locationIds: locationIds ?? [...this.locationIds],
        branchIds: branchIds ?? [...this.branchIds],
        startMinutesHistory:
            startMinutesHistory ?? [...this.startMinutesHistory],
        endMinutesHistory: endMinutesHistory ?? [...this.endMinutesHistory],
        timestamps: timestamps ?? [...this.timestamps],
        editors: editors ?? [...this.editors],
      );

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes the complete tracked shift to Firestore.
  ///
  /// Returns: A Firestore-compatible map.
  Map<String, dynamic> toMap() => {
        idKey: id,
        locationIdsKey: locationIds,
        branchIdsKey: branchIds,
        startMinutesKey: startMinutesHistory,
        endMinutesKey: endMinutesHistory,
        timestampsKey: timestamps,
        editorKey: editors,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Reads a shift document using its declared Firestore types.
  ///
  /// Parameters:
  /// - [map]: Stored Firestore shift values.
  ///
  /// Returns: A tracked shift model.
  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      id: map[idKey] as String,
      locationIds: List<String>.from(map[locationIdsKey] as List),
      branchIds: List<String>.from(map[branchIdsKey] as List),
      startMinutesHistory: List<int>.from(map[startMinutesKey] as List),
      endMinutesHistory: List<int>.from(map[endMinutesKey] as List),
      timestamps: List<Timestamp>.from(map[timestampsKey] as List),
      editors: List<String>.from(map[editorKey] as List),
    );
  }
}
