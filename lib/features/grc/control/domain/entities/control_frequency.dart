/// The fixed set of Control review frequencies. Extracted because the
/// option list ('Weekly', 'Bi weekly', ...) was declared 3 times across
/// 2 files with no enum backing it, despite matching the pattern this
/// codebase already uses for ControlStatus/ChampionStatus/etc.
library;

enum ControlFrequency {
  weekly,
  biWeekly,
  monthly,
  quarterly,
  semiAnnual,
  annually;

  String get value {
    switch (this) {
      case ControlFrequency.weekly:
        return 'Weekly';
      case ControlFrequency.biWeekly:
        return 'Bi weekly';
      case ControlFrequency.monthly:
        return 'Monthly';
      case ControlFrequency.quarterly:
        return 'Quarterly';
      case ControlFrequency.semiAnnual:
        return 'Semi Annual';
      case ControlFrequency.annually:
        return 'Annually';
    }
  }

  /// Case-insensitive match against [value]; returns null (not a default)
  /// because, unlike a status, there is no sensible fallback frequency —
  /// callers must treat "no match" as a validation error.
  static ControlFrequency? fromString(String value) {
    for (final f in ControlFrequency.values) {
      if (f.value.toLowerCase() == value.toLowerCase()) return f;
    }
    return null;
  }

  static List<String> get allValues =>
      ControlFrequency.values.map((f) => f.value).toList();
}
