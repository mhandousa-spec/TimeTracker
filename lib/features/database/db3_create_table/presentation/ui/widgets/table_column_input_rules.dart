/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_column_input_rules.dart
/// Purpose: Declares `TableColumnInputRules`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Turns a `TableColumnType` into the three Flutter things a text field needs to
/// hold only that type: a keystroke filter, a keyboard, and a hint that shows
/// the shape being asked for.
///
/// NOTHING CALLS THIS RIGHT NOW (17/8/2026)
/// ----------------------------------------
/// Its one caller was the Column Name box on `TableColumnBlock`, and that was
/// the wrong field to point it at: a Column Name is a HEADING, so a Number
/// column could not be called "Salary". The rules were taken off that box and
/// it now accepts any text.
///
/// Kept rather than deleted because the rules were never wrong, only
/// misapplied. Their real subject is the CELL under each heading — the Form
/// Builder's next screen — and this is exactly what a cell editor for a Number
/// column needs. Rebuilding it from the enum in a fortnight would be the same
/// code with new bugs.
///
/// WHY THIS IS NOT ON THE ENUM
/// ---------------------------
/// `TextInputFormatter` and `TextInputType` come from `flutter/services`, and
/// `TableColumnType` is domain — it may not import Flutter. So the RULE lives on
/// the enum (`allowedCharacterPattern`, `accepts`) and the WIDGETRY lives here,
/// built from it. Nothing in this file decides what is valid; it only expresses
/// the enum's decision in the field's vocabulary.
///
/// WHY THE FILTER IS NOT THE WHOLE STORY
/// -------------------------------------
/// A filter runs one keystroke at a time, so it can keep letters out of a Number
/// column but cannot tell that `1-2-3` is not a number, and it cannot stop a
/// value that was already typed as General from staying there when the type is
/// switched to Number. `TableColumnType.accepts` is what covers both — it used
/// to back the inline error on the block and the guard on Create, and it is
/// what a cell editor will check a finished value with.

import 'package:flutter/services.dart';

import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';

abstract final class TableColumnInputRules {
  /// Function Name: [formattersFor]
  ///
  /// Purpose: The formatters one column-name box installs for [type].
  ///
  /// The length limit comes FIRST and is always present: it is the Figma's
  /// ceiling on the field, not part of the type rule, and dropping it for
  /// restricted types would let a Number column hold sixty digits.
  ///
  /// Returns: [List<TextInputFormatter>] length limit, plus the type's character
  /// filter when it has one.
  static List<TextInputFormatter> formattersFor(
    TableColumnType type, {
    required int maxLength,
  }) {
    final String? pattern = type.allowedCharacterPattern;

    return <TextInputFormatter>[
      LengthLimitingTextInputFormatter(maxLength),
      if (pattern != null)
        FilteringTextInputFormatter.allow(RegExp(pattern)),
    ];
  }

  /// Function Name: [keyboardFor]
  ///
  /// Purpose: The keyboard [type] should open on a phone or an iPad.
  ///
  /// `datetime` rather than `number` for Date and Time: it is the one keyboard
  /// iOS gives with digits AND the separators (`/`, `:`) on the same plane, so
  /// the user is not hunting for a slash the filter would have accepted.
  ///
  /// Returns: [TextInputType] the keyboard for this type.
  static TextInputType keyboardFor(TableColumnType type) {
    switch (type) {
      case TableColumnType.general:
        return TextInputType.text;
      case TableColumnType.number:
        return const TextInputType.numberWithOptions(signed: true);
      case TableColumnType.currency:
        return const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        );
      case TableColumnType.percentage:
        return const TextInputType.numberWithOptions(decimal: true);
      case TableColumnType.date:
      case TableColumnType.time:
        return TextInputType.datetime;
    }
  }

  /// Function Name: [hintFor]
  ///
  /// Purpose: What the empty box suggests.
  ///
  /// A restricted type shows its own example instead of [fallback]: leaving
  /// "Employee Name" under a Number column would be the field asking for the one
  /// thing it is about to refuse.
  ///
  /// Returns: [String] the hint text.
  static String hintFor(TableColumnType type, {required String fallback}) =>
      type.restrictsValue ? type.formatExample : fallback;
}
