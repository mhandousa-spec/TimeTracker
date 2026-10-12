// ***************************** FILE INFO ***************************** //
// File Name: flexible_date_parser.dart
// Purpose: Parse date strings that may arrive in several known formats.
// Author: Knowticed Team
// Created At: 2026-07-01
// ********************************************************************* //

/// Method Name: parseFlexibleDate
///
/// Purpose: Parse a date string using the supported date representations.
///
/// Parameters:
/// - [dateString]: A nullable ISO-8601, slash-delimited, hyphen-delimited,
///   or epoch-millisecond date string.
///
/// Returns: The parsed [DateTime], or `null` when the value cannot be parsed.
DateTime? parseFlexibleDate(String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) {
    return null;
  }

  final cleanedDate = dateString.trim();

  // Try ISO-8601 first because DateTime.tryParse handles its full syntax.
  final isoParsed = DateTime.tryParse(cleanedDate);
  if (isoParsed != null) {
    return isoParsed;
  }

  // Parse dd/MM/yyyy or d/M/yyyy values.
  if (cleanedDate.contains('/')) {
    final parts = cleanedDate.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (_isValidDateParts(day: day, month: month, year: year)) {
        return DateTime(year!, month!, day!);
      }
    }
  }

  // Parse yyyy-MM-dd values.
  if (cleanedDate.contains('-')) {
    final parts = cleanedDate.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (_isValidDateParts(day: day, month: month, year: year)) {
        return DateTime(year!, month!, day!);
      }
    }
  }

  // Parse epoch-millisecond values.
  final timestamp = int.tryParse(cleanedDate);
  if (timestamp != null) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  return null;
}

/// Method Name: _isValidDateParts
///
/// Purpose: Check the supported numeric bounds before constructing a date.
///
/// Parameters:
/// - [day]: The parsed day value.
/// - [month]: The parsed month value.
/// - [year]: The parsed year value.
///
/// Returns: `true` when all date parts are within the supported bounds.
bool _isValidDateParts({
  required int? day,
  required int? month,
  required int? year,
}) {
  return day != null &&
      month != null &&
      year != null &&
      day >= 1 &&
      day <= 31 &&
      month >= 1 &&
      month <= 12 &&
      year >= 1900;
}
