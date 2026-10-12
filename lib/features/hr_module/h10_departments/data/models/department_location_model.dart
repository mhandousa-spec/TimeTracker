// ***************************** FILE INFO ***************************** //
// File Name: department_location_model.dart
// Purpose: Defines the tracked Department location persistence model.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/department_location_entity.dart';

/// Represents a Department location with aligned revision history.
class DepartmentLocationModel {
  DepartmentLocationModel({
    required this.id,
    required this.nameEnValues,
    required this.nameArValues,
    required this.countryCodeValues,
    required this.timestamps,
    required this.editors,
  });

  static const String idKey = 'Id';
  static const String nameEnKey = 'Location_NameـEnglish';
  static const String nameArKey = 'Location_Name_Arabic';
  static const String countryCodeKey = 'Country_Code';
  static const String timestampsKey = 'Timestamps';
  static const String editorKey = 'Editor';

  final String id;
  final List<String> nameEnValues;
  final List<String> nameArValues;
  final List<String> countryCodeValues;
  final List<Timestamp> timestamps;
  final List<String> editors;

  /// Returns the latest English location name.
  String get nameEn => _latest(nameEnValues);

  /// Returns the latest Arabic location name.
  String get nameAr => _latest(nameArValues);

  /// Returns the latest country code.
  String get countryCode => _latest(countryCodeValues);

  /// Method Name: [toEntity]
  ///
  /// Purpose: Hides persistence history and exposes only current values.
  ///
  /// Returns: A Department location entity without audit fields.
  DepartmentLocationEntity toEntity() {
    return DepartmentLocationEntity(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      countryCode: countryCode,
    );
  }

  /// Method Name: [create]
  ///
  /// Purpose: Creates the first tracked location revision with a new ID.
  ///
  /// Parameters:
  /// - [nameEn]: Initial English location name.
  /// - [nameAr]: Initial Arabic location name.
  /// - [countryCode]: Initial ISO country code.
  /// - [editorId]: Current editor identity.
  /// - [timestamp]: Optional audit timestamp override.
  ///
  /// Returns: A location containing one aligned revision.
  factory DepartmentLocationModel.create({
    required String nameEn,
    required String nameAr,
    required String countryCode,
    required String editorId,
    Timestamp? timestamp,
  }) {
    final createdAt = Timestamp.now().microsecondsSinceEpoch;
    final suffix = Random.secure().nextInt(1 << 32).toRadixString(36);
    return DepartmentLocationModel(
      id: 'location_${createdAt}_$suffix',
      nameEnValues: [nameEn],
      nameArValues: [nameAr],
      countryCodeValues: [countryCode],
      timestamps: [timestamp ?? Timestamp.now()],
      editors: [editorId],
    );
  }

  /// Method Name: [appendRevision]
  ///
  /// Purpose: Adds one aligned location revision without changing its ID.
  ///
  /// Parameters:
  /// - [nameEn]: New English name, or null to preserve the latest value.
  /// - [nameAr]: New Arabic name, or null to preserve the latest value.
  /// - [countryCode]: New country code, or null to preserve the latest value.
  /// - [editorId]: Editor identity for this revision.
  /// - [timestamp]: Optional audit timestamp override.
  ///
  /// Returns: A new location containing the appended revision.
  DepartmentLocationModel appendRevision({
    String? nameEn,
    String? nameAr,
    String? countryCode,
    required String editorId,
    Timestamp? timestamp,
  }) {
    return DepartmentLocationModel(
      id: id,
      nameEnValues: [...nameEnValues, nameEn ?? this.nameEn],
      nameArValues: [...nameArValues, nameAr ?? this.nameAr],
      countryCodeValues: [
        ...countryCodeValues,
        countryCode ?? this.countryCode
      ],
      timestamps: [...timestamps, timestamp ?? Timestamp.now()],
      editors: [...editors, editorId],
    );
  }

  /// Method Name: [copyWith]
  ///
  /// Purpose: Copies a location while preserving tracked history by default.
  ///
  /// Returns: A copied location model.
  DepartmentLocationModel copyWith({
    String? id,
    List<String>? nameEnValues,
    List<String>? nameArValues,
    List<String>? countryCodeValues,
    List<Timestamp>? timestamps,
    List<String>? editors,
  }) {
    return DepartmentLocationModel(
      id: id ?? this.id,
      nameEnValues: nameEnValues ?? [...this.nameEnValues],
      nameArValues: nameArValues ?? [...this.nameArValues],
      countryCodeValues: countryCodeValues ?? [...this.countryCodeValues],
      timestamps: timestamps ?? [...this.timestamps],
      editors: editors ?? [...this.editors],
    );
  }

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes the complete aligned location history.
  ///
  /// Returns: A Firestore-compatible tracked location map.
  Map<String, dynamic> toMap() => {
        idKey: id,
        nameEnKey: nameEnValues,
        nameArKey: nameArValues,
        countryCodeKey: countryCodeValues,
        timestampsKey: timestamps,
        editorKey: editors,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Reads tracked values directly from their Firestore list fields.
  ///
  /// Parameters:
  /// - [map]: Stored Firestore location fields.
  ///
  /// Returns: A location model containing its persisted revision lists.
  factory DepartmentLocationModel.fromMap(Map<String, dynamic> map) {
    return DepartmentLocationModel(
      id: map[idKey] as String,
      nameEnValues: List<String>.from(map[nameEnKey] as List),
      nameArValues: List<String>.from(map[nameArKey] as List),
      countryCodeValues: List<String>.from(map[countryCodeKey] as List),
      timestamps: List<Timestamp>.from(map[timestampsKey] as List),
      editors: List<String>.from(map[editorKey] as List),
    );
  }

  static String _latest(List<String> values) =>
      values.isEmpty ? '' : values.last;
}
