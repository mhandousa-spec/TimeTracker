/// Module: database / db3_create_table / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: table_import_mode.dart
/// Purpose: Declares `TableImportMode`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// The two values the "Type Of Import" dropdown offers on the Import Table
/// dialog — Figma 7398:4041, drawn with "Overwrite" selected at 7398:3450 and
/// "Append" at 7398:3647.
///
/// Domain layer: plain Dart, no Flutter imports. The labels live here because
/// they are the enum's own vocabulary, the same arrangement `TableColumnType`
/// and `DatabaseAccessType` use.

enum TableImportMode {
  /// Replace every row in the table with the file's rows.
  ///
  /// First in the list because it is what the Figma draws selected, and it is
  /// the safer default of the two to READ: a user who picks the wrong one here
  /// loses the file's rows into a pile of existing ones, which is harder to
  /// undo than a table they can re-import.
  overwrite,

  /// Add the file's rows after the ones already there.
  append;

  String get storageKey => this == TableImportMode.overwrite
      ? 'overwrite'
      : 'append';

  String get labelEn =>
      this == TableImportMode.overwrite ? 'Overwrite' : 'Append';

  String get labelAr => this == TableImportMode.overwrite ? 'استبدال' : 'إضافة';

  String localizedLabel({required bool isArabic}) =>
      isArabic ? labelAr : labelEn;
}
