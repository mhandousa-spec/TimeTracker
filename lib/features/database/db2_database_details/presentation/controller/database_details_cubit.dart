/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_cubit.dart
/// Purpose: Declares `DatabaseDetailsCubit` and `DatabaseDetailsState`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The state behind "Database Name Details" — Figma 7398:735 (iPad V) /
/// 7398:847 (iPad H).
///
/// It holds very little because the screen does: the record itself, whether
/// the info card is expanded, and the delete. What it exists for is that the
/// record is MUTABLE from three directions — the Editing screen renames it,
/// the Editing Access screen changes its access type and member count, and the
/// Delete button ends it — and all three have to land on one copy that the
/// page renders and hands back to the list on the way out.
///
/// DELETING GOES THROUGH db1's REPOSITORY, NOT A NEW ONE
/// ----------------------------------------------------
/// `CreateDatabaseRepository.deleteDatabase` is the one delete in the module,
/// and since 16/8/2026 it is a SOFT delete: the document and its
/// `Access_Grants` subcollection stay put, the status moves to `deleted`, and
/// the record turns up under the list screen's Deleted chip where Restore can
/// bring it back. A second delete path here would be a second chance to get
/// that wrong — a real document delete from this screen would make the record
/// unrestorable while the list screen still offered Restore for it.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/create_database_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';

enum DatabaseDetailsStatus { initial, deleting, deleted, failure }

@immutable
class DatabaseDetailsState {
  const DatabaseDetailsState({
    required this.database,
    this.isExpanded = true,
    this.status = DatabaseDetailsStatus.initial,
    this.errorMessage,
  });

  final DatabaseEntity database;

  /// The info card's Hide / Expand toggle (Figma 7398:735 shows it open,
  /// 7398:2082 shows it collapsed to a "Database Details" line).
  ///
  /// Held in the cubit rather than as widget state because the toggle survives
  /// pushing the Editing screen and coming back — a user who collapsed the
  /// card to see more of the table should not have it reopen every time.
  final bool isExpanded;

  final DatabaseDetailsStatus status;
  final String? errorMessage;

  bool get isDeleting => status == DatabaseDetailsStatus.deleting;

  DatabaseDetailsState copyWith({
    DatabaseEntity? database,
    bool? isExpanded,
    DatabaseDetailsStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DatabaseDetailsState(
      database: database ?? this.database,
      isExpanded: isExpanded ?? this.isExpanded,
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DatabaseDetailsCubit extends Cubit<DatabaseDetailsState> {
  DatabaseDetailsCubit({
    required DatabaseEntity database,
    CreateDatabaseBaseRepository? repository,
  })  : _repository = repository ?? CreateDatabaseRepository(),
        super(DatabaseDetailsState(database: database));

  final CreateDatabaseBaseRepository _repository;

  @override
  void emit(DatabaseDetailsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void toggleExpanded() =>
      emit(state.copyWith(isExpanded: !state.isExpanded));

  /// Swaps in the record a child screen just saved.
  void databaseChanged(DatabaseEntity database) =>
      emit(state.copyWith(database: database));

  void clearMessages() => emit(state.copyWith(
        clearErrorMessage: true,
        status: DatabaseDetailsStatus.initial,
      ));

  /// Function Name: [delete]
  ///
  /// Purpose: The red Delete button. Returns whether the record left the list,
  /// so the page can decide to navigate; the failure is reported through state.
  ///
  /// SOFT since 16/8/2026, and [previousStatus] is why it takes the record's
  /// current status: Restore puts the database back where it came from, so a
  /// draft deleted from here returns to Drafts rather than being promoted into
  /// the finished list.
  Future<bool> delete() async {
    emit(state.copyWith(
      status: DatabaseDetailsStatus.deleting,
      clearErrorMessage: true,
    ));

    final Either<Failure, void> result = await _repository.deleteDatabase(
      state.database.id,
      previousStatus: state.database.status,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          status: DatabaseDetailsStatus.failure,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(status: DatabaseDetailsStatus.deleted));
        return true;
      },
    );
  }
}
