/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_state.dart
/// Purpose: Declares `CreateTableState` and `CreateTableStatus`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026

part of './create_table_cubit.dart';

enum CreateTableStatus { initial, submitting, success, failure }

@immutable
class CreateTableState {
  const CreateTableState({
    required this.databaseId,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.rowCountText,
    required this.columns,
    required this.commentsAccess,
    this.original,
    this.status = CreateTableStatus.initial,
    this.nameEnError,
    this.nameArError,
    this.rowCountError,
    this.columnCountError,
    this.errorMessage,
    this.savedTable,
    this.submitted = false,
  });

  /// A blank card for a brand-new table.
  ///
  /// Starts with ONE column rather than the four the Figma sample shows: four
  /// is what that mock happens to contain, not a default, and a card that opens
  /// with three empty blocks the user has to delete is worse than one they add
  /// to. "Enter Column Number" is right there.
  factory CreateTableState.creating({
    required String databaseId,
    required String firstColumnId,
  }) =>
      CreateTableState(
        databaseId: databaseId,
        nameEn: '',
        nameAr: '',
        descriptionEn: '',
        descriptionAr: '',
        rowCountText: '',
        columns: <TableColumn>[TableColumn(id: firstColumnId, order: 0)],
        commentsAccess: TableCommentsAccess.private,
      );

  /// Seeds every field from an existing table — the Editing Table Name card
  /// (Figma 7398:6934 / 7398:7121). Named rather than a default constructor so
  /// a caller cannot accidentally build an EMPTY edit state and save it over a
  /// full record.
  factory CreateTableState.from(DatabaseTableEntity table) => CreateTableState(
        original: table,
        databaseId: table.databaseId,
        nameEn: table.nameEn,
        nameAr: table.nameAr,
        descriptionEn: table.descriptionEn,
        descriptionAr: table.descriptionAr,
        rowCountText: table.rowCount == 0 ? '' : '${table.rowCount}',
        columns: List<TableColumn>.unmodifiable(table.columns),
        commentsAccess: table.commentsAccess,
      );

  /// The table as loaded, or null when this card is creating one.
  ///
  /// This single field is what makes the two Figma frames one screen: it drives
  /// the breadcrumb, the primary button's label, whether the row/column count
  /// fields are drawn, and what [isDirty] compares against.
  final DatabaseTableEntity? original;

  /// Parent database. Carried on the state because a table cannot exist without
  /// one and the cubit has to hand it to the repository on every call.
  final String databaseId;

  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;

  /// Raw text of "Enter Row Number", NOT an int.
  ///
  /// The field has to be allowed to be empty while the user is retyping it; an
  /// int would force that transient state to become 0 and the box would fight
  /// back with a "0" the moment the last digit was deleted.
  final String rowCountText;

  final List<TableColumn> columns;
  final TableCommentsAccess commentsAccess;

  final CreateTableStatus status;

  final String? nameEnError;
  final String? nameArError;
  final String? rowCountError;
  final String? columnCountError;
  final String? errorMessage;

  /// The record the server returned. The details screen swaps its own copy for
  /// this one so the list behind the dialog is already correct when the dialog
  /// closes.
  final DatabaseTableEntity? savedTable;

  final bool submitted;

  // ── Derived ──────────────────────────────────────────────────────────────

  bool get isEditing => original != null;

  bool get isSubmitting => status == CreateTableStatus.submitting;

  int get columnCount => columns.length;

  /// Empty means zero rows — a table can legitimately start empty, and the
  /// Figma places no asterisk on that field.
  int get rowCount => int.tryParse(rowCountText.trim()) ?? 0;

  /// Errors stay hidden until the first save attempt, so a form that opens
  /// full does not immediately paint red under fields the user has not touched.
  /// Same rule as the create and edit database cards.
  String? get visibleNameEnError => submitted ? nameEnError : null;
  String? get visibleNameArError => submitted ? nameArError : null;

  /// The count errors are NOT gated on [submitted]: they fire while the user is
  /// typing into the box that caused them, where "between 1 and 50" is an
  /// answer rather than a scolding.
  String? get visibleRowCountError => rowCountError;
  String? get visibleColumnCountError => columnCountError;

  // COLUMN-NAME VALIDATION REMOVED 17/8/2026.
  //
  // `firstUnnamedColumnIndex`, `firstTypeMismatchColumnIndex` and
  // `duplicateColumnName` lived here and were checked by `CreateTablePage`
  // before every save. All three are gone: a Column Name is a HEADING —
  // "Salary", "Start Date" — and the rules were treating it as though it had
  // to be a VALUE of the column's own type, so a Number column refused to be
  // called anything but a number.
  //
  // The type rule itself is untouched on `TableColumnType` (`accepts`,
  // `allowedCharacterPattern`). It belongs to the CELLS the Form Builder will
  // put under each heading, which is where it will be applied.

  /// Different from the record as LOADED when editing, "anything typed" when
  /// creating.
  ///
  /// The split matters: on the edit card every field starts full, so db1's
  /// "is anything non-empty" rule would report a freshly opened form as dirty
  /// and warn about losing changes nobody made.
  bool get isDirty {
    final DatabaseTableEntity? loaded = original;

    if (loaded == null) {
      return nameEn.trim().isNotEmpty ||
          nameAr.trim().isNotEmpty ||
          descriptionEn.trim().isNotEmpty ||
          descriptionAr.trim().isNotEmpty ||
          rowCountText.trim().isNotEmpty ||
          commentsAccess != TableCommentsAccess.private ||
          columns.any((TableColumn c) => c.isNamed) ||
          columns.length != 1;
    }

    return nameEn.trim() != loaded.nameEn.trim() ||
        nameAr.trim() != loaded.nameAr.trim() ||
        descriptionEn.trim() != loaded.descriptionEn.trim() ||
        descriptionAr.trim() != loaded.descriptionAr.trim() ||
        commentsAccess != loaded.commentsAccess ||
        !_sameColumns(columns, loaded.columns);
  }

  /// Column lists match when they have the same names and types in the same
  /// order. Ids are ignored on purpose — a duplicated-then-undone block would
  /// otherwise leave the card permanently "dirty" over an id nobody can see.
  static bool _sameColumns(List<TableColumn> a, List<TableColumn> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].name.trim() != b[i].name.trim() || a[i].type != b[i].type) {
        return false;
      }
    }
    return true;
  }

  CreateTableState copyWith({
    DatabaseTableEntity? original,
    String? databaseId,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? rowCountText,
    List<TableColumn>? columns,
    TableCommentsAccess? commentsAccess,
    CreateTableStatus? status,
    String? nameEnError,
    String? nameArError,
    String? rowCountError,
    String? columnCountError,
    String? errorMessage,
    DatabaseTableEntity? savedTable,
    bool? submitted,
    bool clearNameEnError = false,
    bool clearNameArError = false,
    bool clearRowCountError = false,
    bool clearColumnCountError = false,
    bool clearErrorMessage = false,
  }) {
    return CreateTableState(
      original: original ?? this.original,
      databaseId: databaseId ?? this.databaseId,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      rowCountText: rowCountText ?? this.rowCountText,
      columns: columns ?? this.columns,
      commentsAccess: commentsAccess ?? this.commentsAccess,
      status: status ?? this.status,
      nameEnError: clearNameEnError ? null : (nameEnError ?? this.nameEnError),
      nameArError: clearNameArError ? null : (nameArError ?? this.nameArError),
      rowCountError:
          clearRowCountError ? null : (rowCountError ?? this.rowCountError),
      columnCountError: clearColumnCountError
          ? null
          : (columnCountError ?? this.columnCountError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      savedTable: savedTable ?? this.savedTable,
      submitted: submitted ?? this.submitted,
    );
  }
}
