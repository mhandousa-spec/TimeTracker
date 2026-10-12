/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_list_state.dart
/// Purpose: Declares `TableListState`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026

part of './table_list_cubit.dart';

@immutable
class TableListState {
  const TableListState({
    required this.databaseId,
    this.tables = const <DatabaseTableEntity>[],
    this.query = '',
    this.isLoading = true,
    this.errorMessage,
  });

  final String databaseId;

  /// Everything the server returned, newest first. The search narrows [visible]
  /// rather than this, so clearing the box does not cost a refetch.
  final List<DatabaseTableEntity> tables;

  final String query;

  /// True on the very first load and on every explicit reload. Starts true so
  /// the section shows a spinner rather than "no tables yet" for the half
  /// second before the first read lands — an empty state that turns out to be
  /// wrong is worse than a spinner.
  final bool isLoading;

  final String? errorMessage;

  bool get hasQuery => query.trim().isNotEmpty;

  /// A failed read and an empty collection look identical and mean opposite
  /// things, so the section renders them differently and this is what tells
  /// them apart.
  bool get hasError => errorMessage != null;

  /// The rows the section draws.
  ///
  /// Matched against BOTH names regardless of the UI locale: someone searching
  /// an Arabic interface for "Employee" is searching for a table they know by
  /// its English name, and refusing to find it would be a bug they could not
  /// explain.
  List<DatabaseTableEntity> get visible {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return tables;

    return tables
        .where(
          (DatabaseTableEntity table) =>
              table.nameEn.toLowerCase().contains(needle) ||
              table.nameAr.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  TableListState copyWith({
    String? databaseId,
    List<DatabaseTableEntity>? tables,
    String? query,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TableListState(
      databaseId: databaseId ?? this.databaseId,
      tables: tables ?? this.tables,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
