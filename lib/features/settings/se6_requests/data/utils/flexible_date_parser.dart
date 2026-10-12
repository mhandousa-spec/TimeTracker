/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: flexible_date_parser.dart
/// Purpose: Parse the several shapes a stored date can arrive in.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N02. `_parseDate` lived on the edit page's State with
/// **four** `try/catch` blocks in it — every one of them dead: they wrapped
/// `int.tryParse`, `DateTime.tryParse` and plain arithmetic, none of which
/// throw. The catches were empty, so they could only ever have hidden a genuine
/// bug. The logic is unchanged; the try blocks are simply gone.

abstract class FlexibleDateParser {
  /// Function Name: [parse]
  ///
  /// Purpose: Read a date written as ISO 8601, `dd/MM/yyyy`, `yyyy-MM-dd`, or
  ///          milliseconds since epoch.
  ///
  /// Returns: [DateTime?] — `null` when [raw] is empty or matches nothing.
  static DateTime? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final String cleaned = raw.trim();

    final DateTime? iso = DateTime.tryParse(cleaned);
    if (iso != null) return iso;

    if (cleaned.contains('/')) {
      final DateTime? slashed = _fromParts(cleaned.split('/'), dayFirst: true);
      if (slashed != null) return slashed;
    }

    if (cleaned.contains('-')) {
      final DateTime? dashed = _fromParts(cleaned.split('-'), dayFirst: false);
      if (dashed != null) return dashed;
    }

    final int? millis = int.tryParse(cleaned);
    if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);

    return null;
  }

  /// `dd/MM/yyyy` when [dayFirst], `yyyy-MM-dd` otherwise.
  static DateTime? _fromParts(List<String> parts, {required bool dayFirst}) {
    if (parts.length != 3) return null;

    final int? day = int.tryParse(dayFirst ? parts[0] : parts[2]);
    final int? month = int.tryParse(parts[1]);
    final int? year = int.tryParse(dayFirst ? parts[2] : parts[0]);

    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1900) return null;

    return DateTime(year, month, day);
  }
}
