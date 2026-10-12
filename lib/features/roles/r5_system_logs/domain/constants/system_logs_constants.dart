/// Module: roles / r5_system_logs / domain / constants
///
///*********************** FILE INFO ********************///
/// FILE NAME: system_logs_constants.dart
/// Purpose: to have all the constants related to the system logs
/// Author: Amr Mesbah
/// Created at: 29/1/2025

import 'package:knowticed_plus/features/roles/r5_system_logs/domain/enums/system_logs_items.dart';
import 'package:knowticed_plus/generated/l10n.dart';

abstract class SystemLogsConstants {
  static const List<SystemLogsItems> systemLogsItems = [
    SystemLogsItems.firstName,
    SystemLogsItems.middleName,
    SystemLogsItems.lastName,
    SystemLogsItems.role,
    SystemLogsItems.country,
    SystemLogsItems.city,
    SystemLogsItems.date,
    SystemLogsItems.time,
    SystemLogsItems.lat,
    SystemLogsItems.long,
    SystemLogsItems.module,

    SystemLogsItems.action,
  ];

  /// Stable **sort keys**, deliberately English.
  ///
  /// Flagged by the review as "hardcoded English while `sortListInArabic` uses
  /// `S.current`". They are not display text: `SystemLogsController.sortLogs`
  /// matches on these values, and the appbar maps the user's localized choice
  /// back through `sortList[sortListInArabic.indexOf(value)]` before calling
  /// it. Localizing this list would break that lookup — the display list below
  /// is the one users read.
  static List<String> get sortList => [
        "First Name",
        "Last Name",
        "Date",
        "Country",
        "City",
      ];
  /// Display labels for [sortList], in the **active** locale.
  ///
  /// The name is historical: `S.current` resolves whatever locale is active,
  /// so this is the localized list rather than an Arabic-only one. Index
  /// positions must stay aligned with [sortList].
  static List<String> get sortListInArabic => [
        S.current.firstName,
        S.current.lastName,
        S.current.date,
        S.current.country,
        S.current.city,
      ];
}
