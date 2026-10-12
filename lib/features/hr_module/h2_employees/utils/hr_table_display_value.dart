// ***************************** FILE INFO ***************************** //
// File Name: hr_table_display_value.dart
// Purpose: Formats HR employee table values without changing stored data.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

/// Formats table text while preserving non-display data such as IDs and URLs.
abstract final class HrTableDisplayValue {
  /// Method Name: [format]
  ///
  /// Purpose: Capitalizes English display text and preserves Arabic, numeric,
  /// and explicitly non-display values.
  ///
  /// Parameters:
  /// - [value]: Raw table value.
  /// - [capitalize]: Whether the value is human-readable display text.
  ///
  /// Returns: A safe value for a table cell.
  static String format(String value, {bool capitalize = true}) {
    if (value.isEmpty || !capitalize || _shouldPreserve(value)) return value;
    final normalized = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return normalized.splitMapJoin(
      RegExp(r'\s+'),
      onMatch: (match) => match.group(0)!,
      onNonMatch: _capitalizeWord,
    );
  }

  static bool _shouldPreserve(String value) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(value) ||
      RegExp(r'^\s*[+\d.,:/-]+\s*$').hasMatch(value) ||
      value.contains('://') ||
      value.contains('@');

  static String _capitalizeWord(String value) {
    if (value.isEmpty || value.trim().isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
