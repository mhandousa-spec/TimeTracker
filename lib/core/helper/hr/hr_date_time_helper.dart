// ***************************** FILE INFO ***************************** //
// File Name: hr_date_time_helper.dart
// Purpose: Provides localized date and time formatting for HR features.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Provides shared date and time formatting for HR features.
abstract final class HrDateTimeHelper {
  /// Method Name: [formatTimestamp]
  ///
  /// Purpose: Formats a Firestore timestamp using the active locale.
  ///
  /// Parameters:
  /// - [context]: Supplies the current application locale.
  /// - [value]: The nullable Firestore timestamp to format.
  ///
  /// Returns: A localized date string, or an empty string for a null value.
  static String formatTimestamp(BuildContext context, Timestamp? value) {
    if (value == null) return '';

    return DateFormat(
      'dd MMM yyyy',
      Localizations.localeOf(context).languageCode,
    ).format(value.toDate());
  }
}
