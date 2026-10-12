/// Module: roles / r5_system_logs / data / models
///
///*********************** FILE INFO ********************///
/// FILE NAME: system_logs_model.dart
/// Purpose: to have the model of the system logs.
/// Author: Amr Mesbah
/// Created At: 29/1/2025

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

class SystemLogsModel {
  final String? userEmail;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;
  final String? country;
  final String? city;
  final String? role;
  final String? lat;
  final String? long;
  final String? action;
  final Modules? module;
  final Timestamp? timestamp;

  static const String USER_EMAIL = 'User_Email';
  static const String FIRST_NAME = 'First_Name';
  static const String MIDDLE_NAME = 'Middle_Name';
  static const String LAST_NAME = 'Last_Name';
  static const String FIRST_NAME_ARABIC = 'First_Name_Arabic';
  static const String MIDDLE_NAME_ARABIC = 'Middle_Name_Arabic';
  static const String LAST_NAME_ARABIC = 'Last_Name_Arabic';
  static const String COUNTRY = 'Country';
  static const String CITY = 'City';
  static const String ROLE = 'Role';
  static const String LAT = 'Lat';
  static const String LONG = 'Long';
  static const String ACTION = 'Action';
  static const String TIMESTAMP = 'Timestamp';
  static const String MODULE = 'Module';
  const SystemLogsModel(
      {this.userEmail,
      this.firstName,
      this.middleName,
      this.lastName,
      this.country,
      this.firstNameInArabic,
      this.middleNameInArabic,
      this.lastNameInArabic,
      this.city,
      this.role,
      this.lat,
      this.long,
      this.action,
      this.timestamp,
      this.module});

  /// Was a generative named constructor that assigned to each field in its
  /// body. The fields are `final` now (§10), so this is a factory that builds
  /// the instance in one shot — same parsing, same output.
  factory SystemLogsModel.fromMap(dynamic json) {
    return SystemLogsModel(
      userEmail: FormatHelper.capitalize(json[USER_EMAIL]),
      firstName: FormatHelper.capitalize(json[FIRST_NAME]),
      middleName: FormatHelper.capitalize(json[MIDDLE_NAME]),
      lastName: FormatHelper.capitalize(json[LAST_NAME]),
      firstNameInArabic: json[FIRST_NAME_ARABIC],
      middleNameInArabic: json[MIDDLE_NAME_ARABIC],
      lastNameInArabic: json[LAST_NAME_ARABIC],
      country: FormatHelper.capitalize(json[COUNTRY]),
      city: FormatHelper.capitalize(json[CITY]),
      role: FormatHelper.capitalize(json[ROLE]),
      lat: json[LAT],
      long: json[LONG],
      action: FormatHelper.capitalize(json[ACTION]),
      timestamp: json[TIMESTAMP],
      module: json[MODULE] != null
          ? Modules.values.firstWhere((e) => e.name == json[MODULE])
          : null,
    );
  }

  /// When the log was recorded, as a plain [DateTime].
  ///
  /// Added so `SystemLogsController` can sort without importing
  /// `cloud_firestore` — the Firestore `Timestamp` type stays inside `data/`
  /// (§3 layer boundary).
  DateTime? get loggedAt => timestamp?.toDate();

  /// Function Name: [copyWith]
  ///
  /// Purpose: Produce a modified copy — the model is immutable (§10).
  ///
  /// Returns: [SystemLogsModel]
  SystemLogsModel copyWith({
    String? userEmail,
    String? firstName,
    String? middleName,
    String? lastName,
    String? firstNameInArabic,
    String? middleNameInArabic,
    String? lastNameInArabic,
    String? country,
    String? city,
    String? role,
    String? lat,
    String? long,
    String? action,
    Modules? module,
    Timestamp? timestamp,
  }) {
    return SystemLogsModel(
      userEmail: userEmail ?? this.userEmail,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      firstNameInArabic: firstNameInArabic ?? this.firstNameInArabic,
      middleNameInArabic: middleNameInArabic ?? this.middleNameInArabic,
      lastNameInArabic: lastNameInArabic ?? this.lastNameInArabic,
      country: country ?? this.country,
      city: city ?? this.city,
      role: role ?? this.role,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      action: action ?? this.action,
      module: module ?? this.module,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[USER_EMAIL] = userEmail;
    map[FIRST_NAME] = firstName;
    map[MIDDLE_NAME] = middleName;
    map[LAST_NAME] = lastName;
    map[FIRST_NAME_ARABIC] = firstNameInArabic;
    map[MIDDLE_NAME_ARABIC] = middleNameInArabic;
    map[LAST_NAME_ARABIC] = lastNameInArabic;
    map[COUNTRY] = country;
    map[CITY] = city;
    map[ROLE] = role;
    map[LAT] = lat;
    map[LONG] = long;
    map[ACTION] = action;
    map[TIMESTAMP] = timestamp;
    map[MODULE] = module?.name;

    return map;
  }
}
