/// Module: database / db3_create_table / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: table_column_type.dart
/// Purpose: Declares `TableColumnType`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The six values the "Data Type" dropdown offers on every column block of the
/// Creating Table card — Figma `Columns type` 7398:8196 (iPad H) / 7398:8204
/// (iPad V), drawn open over 7398:6533 / 7398:6732.
///
/// Domain layer: no Flutter imports, no colours. The labels live here because
/// they are the enum's own vocabulary, not presentation styling — the page
/// picks one by locale. Same arrangement as `DatabaseAccessType`.
///
/// THE TYPE ALSO OWNS WHAT THE VALUE MAY CONTAIN
/// --------------------------------------------
/// Choosing "Number" on a block means the box beside the dropdown only takes a
/// number. [allowedCharacterPattern] is the keystroke filter the field installs
/// and [accepts] is the whole-value check the save guard runs — two halves of
/// one rule, kept together so the filter cannot let through something the guard
/// then refuses for a reason the user has no way to see.
///
/// Both live HERE rather than in the widget because the rule belongs to the data
/// type, not to the screen: the table-data screen has to enforce the same thing,
/// and a second copy is how "Percentage" ends up capped at 100 on one screen and
/// unbounded on the other.
///
/// Pure Dart on purpose — no `TextInputFormatter`, no `TextInputType`. Those are
/// Flutter types, so the presentation layer builds them from these members; see
/// `TableColumnInputRules`.

enum TableColumnType {
  /// Free text. The Figma shows this pre-selected on all four blocks, so it is
  /// also what [fromStorageKey] falls back to.
  general,

  number,
  currency,
  date,
  time,
  percentage;

  /// Value written to / read from Firestore. Kept independent of the enum's
  /// Dart name so renaming the enum never silently orphans existing columns.
  String get storageKey {
    switch (this) {
      case TableColumnType.general:
        return 'general';
      case TableColumnType.number:
        return 'number';
      case TableColumnType.currency:
        return 'currency';
      case TableColumnType.date:
        return 'date';
      case TableColumnType.time:
        return 'time';
      case TableColumnType.percentage:
        return 'percentage';
    }
  }

  String get labelEn {
    switch (this) {
      case TableColumnType.general:
        return 'General';
      case TableColumnType.number:
        return 'Number';
      case TableColumnType.currency:
        return 'Currency';
      case TableColumnType.date:
        return 'Date';
      case TableColumnType.time:
        return 'Time';
      case TableColumnType.percentage:
        return 'Percentage';
    }
  }

  String get labelAr {
    switch (this) {
      case TableColumnType.general:
        return 'عام';
      case TableColumnType.number:
        return 'رقم';
      case TableColumnType.currency:
        return 'عملة';
      case TableColumnType.date:
        return 'تاريخ';
      case TableColumnType.time:
        return 'وقت';
      case TableColumnType.percentage:
        return 'نسبة مئوية';
    }
  }

  String localizedLabel({required bool isArabic}) =>
      isArabic ? labelAr : labelEn;

  // ── What the value may contain ─────────────────────────────────────────────

  /// Arabic-Indic digits count as digits.
  ///
  /// The app already renders numbers in this script (`LocalizedNumber`), and an
  /// Arabic keyboard produces `٢٥` rather than `25` — refusing those keystrokes
  /// would make a Number column untypeable in Arabic.
  static const String _digits = r'0-9٠-٩';

  /// True when this type restricts the value at all.
  ///
  /// Only [general] does not. It is checked instead of comparing against
  /// `general` at each call site, so adding a second free-text type later is one
  /// line here.
  bool get restrictsValue => this != TableColumnType.general;

  /// Character class for the field's keystroke filter — every character the box
  /// will accept while this type is selected.
  ///
  /// A character class, NOT a whole-value pattern: a filter runs per keystroke,
  /// so it cannot know that `1-2` is not a number. Rejecting the SHAPE is
  /// [accepts]'s job. This only stops the keystrokes that could never be part of
  /// a valid value — a letter in a Number column.
  ///
  /// Null for [general], which filters nothing.
  String? get allowedCharacterPattern {
    switch (this) {
      case TableColumnType.general:
        return null;
      case TableColumnType.number:
        return '[$_digits-]';
      // A minus so a currency column can hold a credit, a dot for the piastres.
      case TableColumnType.currency:
        return '[$_digits.-]';
      // No minus: a negative percentage is not something this screen means.
      case TableColumnType.percentage:
        return '[$_digits.%]';
      case TableColumnType.date:
        return '[$_digits/]';
      case TableColumnType.time:
        return '[$_digits:]';
    }
  }

  /// A valid value of this type, shown in the field's hint and in the error.
  ///
  /// Locale-neutral digits: the example is a SHAPE ("two digits, a slash, two
  /// digits"), and rendering it in Arabic-Indic numerals in the Arabic build
  /// would make it look like a different rule rather than the same one.
  String get formatExample {
    switch (this) {
      case TableColumnType.general:
        return '';
      case TableColumnType.number:
        return '25';
      case TableColumnType.currency:
        return '1250.00';
      case TableColumnType.percentage:
        return '75%';
      case TableColumnType.date:
        return '25/12/2026';
      case TableColumnType.time:
        return '14:30';
    }
  }

  /// Function Name: [accepts]
  ///
  /// Purpose: Whether [value] is a complete, valid value of this type.
  ///
  /// EMPTY IS ACCEPTED. "This column has no name yet" is a different complaint
  /// with a different message, already made by `CreateTableState`'s
  /// `firstUnnamedColumnIndex` — reporting it here as well would show the user
  /// two errors for one blank box.
  ///
  /// The check runs on the value with its digits normalised to ASCII, so `٢٥`
  /// and `25` are the same number rather than one valid and one not.
  ///
  /// Returns: [bool] true when the value fits this type.
  bool accepts(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return true;

    final String normalized = _toAsciiDigits(trimmed);

    switch (this) {
      case TableColumnType.general:
        return true;

      case TableColumnType.number:
        return RegExp(r'^-?\d+$').hasMatch(normalized);

      // Two decimal places at most: money with three is a rate, not an amount,
      // and letting it through here means a total that does not add up later.
      case TableColumnType.currency:
        return RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(normalized);

      case TableColumnType.percentage:
        if (!RegExp(r'^\d+(\.\d{1,2})?%?$').hasMatch(normalized)) return false;
        final double? parsed =
            double.tryParse(normalized.replaceAll('%', ''));
        // Bounded, because a percentage is a share of something: 150% would be
        // accepted by the pattern and mean nothing in the column.
        return parsed != null && parsed <= 100;

      case TableColumnType.date:
        return _isRealDate(normalized);

      case TableColumnType.time:
        return _isRealTime(normalized);
    }
  }

  /// `dd/mm/yyyy`, and a date that exists.
  ///
  /// The pattern alone would pass 31/02/2026. `DateTime` rolls an impossible day
  /// over into the next month, so comparing the parts back is what catches it —
  /// including the leap years, which is why this does not do the arithmetic by
  /// hand the way the older validators in `Validator` do.
  static bool _isRealDate(String value) {
    final RegExpMatch? match =
        RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(value);
    if (match == null) return false;

    final int day = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int year = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1) return false;

    final DateTime parsed = DateTime(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }

  /// `hh:mm` on a 24-hour clock.
  ///
  /// 24-hour and not the `9:30 AM` that `Validator.validateTime` expects: AM/PM
  /// needs letters, and letters are exactly what this column's keystroke filter
  /// exists to refuse. A field cannot demand a format it will not let you type.
  static bool _isRealTime(String value) {
    final RegExpMatch? match =
        RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value);
    if (match == null) return false;

    final int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    return hour <= 23 && minute <= 59;
  }

  /// Maps Arabic-Indic digits onto ASCII ones and leaves everything else alone.
  ///
  /// Local to this file rather than the app's number extension: that one returns
  /// a parsed number and throws on anything that is not one, and this runs on
  /// half-typed text.
  static String _toAsciiDigits(String value) {
    const int arabicZero = 0x0660;
    final StringBuffer out = StringBuffer();
    for (final int unit in value.codeUnits) {
      out.writeCharCode(
        unit >= arabicZero && unit <= arabicZero + 9
            ? unit - arabicZero + 0x30
            : unit,
      );
    }
    return out.toString();
  }

  /// Parses a stored value back to the enum.
  ///
  /// Falls back to [general] rather than throwing: a column written by a later
  /// build with a type this one does not know about should still render as a
  /// column, because the alternative is a table the user cannot open at all.
  static TableColumnType fromStorageKey(String? key) {
    return TableColumnType.values.firstWhere(
      (TableColumnType type) => type.storageKey == key,
      orElse: () => TableColumnType.general,
    );
  }
}
