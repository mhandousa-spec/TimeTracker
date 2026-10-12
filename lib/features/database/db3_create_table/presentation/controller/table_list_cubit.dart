/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_list_cubit.dart
/// Purpose: Declares `TableListCubit`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The list of tables drawn on the database details screen — the region that
/// was a hard-coded "No tables in this database yet" until this section landed
/// (Figma 7398:4102 / 7398:4690 landscape, 7398:17048 / 7398:17240 portrait).
///
/// Owned by the details page, not by the Creating Table screen: the list
/// outlives every visit to that card, and rebuilding it from scratch each time
/// the card closed would flash an empty table at the user on the way back.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/repository/create_table_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';

part './table_list_state.dart';

class TableListCubit extends Cubit<TableListState> {
  TableListCubit({
    required String databaseId,
    CreateTableBaseRepository? repository,
  })  : _repository = repository ?? CreateTableRepository(),
        super(TableListState(databaseId: databaseId));

  final CreateTableBaseRepository _repository;

  @override
  void emit(TableListState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [load]
  ///
  /// Purpose: Read every table under the database.
  ///
  /// Called once when the details screen opens and again after any write. The
  /// search text is deliberately NOT cleared: a reload triggered by creating a
  /// table should leave the user's filter where they put it.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Either<Failure, List<DatabaseTableEntity>> result =
        await _repository.fetchTables(state.databaseId);

    emit(result.fold(
      (Failure failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.errMessage,
      ),
      (List<DatabaseTableEntity> tables) => state.copyWith(
        isLoading: false,
        tables: tables,
        clearErrorMessage: true,
      ),
    ));
  }

  void searchChanged(String value) => emit(state.copyWith(query: value));

  /// Function Name: [tableSaved]
  ///
  /// Purpose: Fold a created or edited table into the list without a refetch.
  ///
  /// A new table goes to the FRONT, which is where `fetchTables` would put it
  /// too — it orders by creation date descending — so the optimistic list and
  /// the next real read agree about where it sits. An edited one is replaced in
  /// place, because editing does not change when it was created.
  void tableSaved(DatabaseTableEntity table) {
    final int index = state.tables.indexWhere(
      (DatabaseTableEntity existing) => existing.id == table.id,
    );

    final List<DatabaseTableEntity> tables = <DatabaseTableEntity>[
      ...state.tables,
    ];
    if (index < 0) {
      tables.insert(0, table);
    } else {
      tables[index] = table;
    }

    emit(state.copyWith(tables: List<DatabaseTableEntity>.unmodifiable(tables)));
  }

  /// Function Name: [tableRemoved]
  ///
  /// Purpose: Drop a deleted table out of the list without a refetch.
  ///
  /// ADDED 17/8/2026 with the Table Name Details screen, which is where Delete
  /// now lives. Matched by ID rather than by identity: the record handed back
  /// by that screen may have been edited before it was deleted, so it is not
  /// the object this list is holding.
  void tableRemoved(String tableId) {
    emit(state.copyWith(
      tables: List<DatabaseTableEntity>.unmodifiable(
        state.tables.where(
          (DatabaseTableEntity table) => table.id != tableId,
        ),
      ),
    ));
  }

  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));
}
