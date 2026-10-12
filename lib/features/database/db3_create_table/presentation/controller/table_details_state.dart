/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_details_state.dart
/// Purpose: Declares `TableDetailsState`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026

part of './table_details_cubit.dart';

@immutable
class TableDetailsState {
  const TableDetailsState({
    required this.table,
    this.isExpanded = true,
    this.query = '',
    this.isDeleting = false,
    this.isChanged = false,
    this.errorMessage,
  });

  final DatabaseTableEntity table;

  /// Whether the info card is open. Starts TRUE because that is the state the
  /// Figma draws first (7398:4102) and because someone arriving from a card
  /// they just tapped came to read the description, not to hunt for a link
  /// that would bring it back.
  final bool isExpanded;

  /// The search box's text.
  ///
  /// KEPT BUT NOT READ HERE (17/8/2026). It narrowed a list of row NUMBERS
  /// back when a row had nothing else to be found by; the rows have cells now,
  /// so the box feeds `TableDataCubit.searchChanged` and the narrowing happens
  /// against the values. This stays because the field is part of the screen's
  /// state and a second screen reading it is cheaper than two search boxes.
  final String query;

  final bool isDeleting;

  /// True once anything on this screen was saved. Drives what the page hands
  /// back — a screen that was only looked at must not make the grid behind it
  /// redraw a card that did not change.
  final bool isChanged;

  final String? errorMessage;

  /// The columns the grid draws headings for.
  ///
  /// UNNAMED COLUMNS ARE DROPPED. A table's `columns` array is sized by "Enter
  /// Column Number" on the create card, so a table can legitimately hold four
  /// entries with two headings typed; rendering the blank ones would put two
  /// unlabelled columns in the middle of the grid that nothing can ever fill.
  /// The page says so in words instead when this comes back empty.
  List<TableColumn> get namedColumns => table.columns
      .where((TableColumn column) => column.isNamed)
      .toList(growable: false);

  TableDetailsState copyWith({
    DatabaseTableEntity? table,
    bool? isExpanded,
    String? query,
    bool? isDeleting,
    bool? isChanged,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TableDetailsState(
      table: table ?? this.table,
      isExpanded: isExpanded ?? this.isExpanded,
      query: query ?? this.query,
      isDeleting: isDeleting ?? this.isDeleting,
      isChanged: isChanged ?? this.isChanged,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
