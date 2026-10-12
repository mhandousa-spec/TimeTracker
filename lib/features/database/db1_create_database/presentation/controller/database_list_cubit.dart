/// Module: database / db1_create_database / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: database_list_cubit.dart
/// Purpose: Declares `DatabaseListCubit` and `DatabaseListState`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// Backs the Database Builder landing screen (Figma 7398:2492 / 2628) — the
/// list, its count chips and its search box.
///
/// Separate from `CreateDatabaseCubit` on purpose: that one is a wizard whose
/// whole life is one unsaved draft, this one is a read model of saved
/// records. Merging them would keep a half-filled draft alive for as long as
/// the list is on screen.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/create_database_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_sort_option.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';

/// The count-chip filters, in the order the Figma lays them out.
enum DatabaseListFilter { all, open, restricted, personal, drafts, deleted }

@immutable
class DatabaseListState {
  const DatabaseListState({
    this.databases = const <DatabaseEntity>[],
    this.filter = DatabaseListFilter.all,
    this.searchQuery = '',
    this.accessFilter,
    this.sortOption,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<DatabaseEntity> databases;
  final DatabaseListFilter filter;
  final String searchQuery;

  /// Access type chosen in the Filter dialog, or null for "not filtered".
  ///
  /// Deliberately a separate field from [filter] rather than folded into the
  /// chip enum: the chips are the view the user is standing in, the dialog is
  /// a refinement applied on top of it. Folding them together would make
  /// picking "Open Access" in the dialog silently move the chip selection.
  final DatabaseAccessType? accessFilter;

  /// Ordering picked on the Sort button, or null for "not sorted".
  ///
  /// NULLABLE on purpose rather than defaulting to one of the three options:
  /// `CustomSortButton` treats tapping the selected row again as a deselect
  /// and hands back null, and that null is the only way back to the order the
  /// repository returned. It is also what un-tints the button, so a list that
  /// looks unsorted actually is.
  final DatabaseSortOption? sortOption;

  final bool isLoading;
  final String? errorMessage;

  /// True while the dialog is narrowing the list — the Filter button is
  /// tinted from this so an active filter is never invisible.
  bool get hasAccessFilter => accessFilter != null;

  /// Key form used by `StatusChipFilter`, which selects by String rather than
  /// by index — storing the enum and deriving the key keeps the cubit free of
  /// the widget's addressing scheme.
  String get filterKey => filter.name;

  /// Records surviving the active chip, the search box AND the Filter dialog,
  /// in the order the Sort button asked for.
  ///
  /// Takes [isArabic] rather than reading a locale itself because this is the
  /// domain-facing read model and it has no BuildContext — and because A → Z
  /// has to mean the title the user is actually looking at. Sorting on
  /// `titleEn` while the cards render `titleAr` would produce an order that is
  /// correct and completely unreadable.
  ///
  /// Sorting happens AFTER filtering, over the handful of rows that survived,
  /// rather than over the whole collection — and not at all when nothing is
  /// selected, so the default view keeps the repository's own order.
  List<DatabaseEntity> visible({required bool isArabic}) {
    final String query = searchQuery.trim().toLowerCase();

    final List<DatabaseEntity> matches = databases.where((DatabaseEntity d) {
      if (!_matchesFilter(d)) return false;
      if (accessFilter != null && d.accessType != accessFilter) return false;
      if (query.isEmpty) return true;
      return d.titleEn.toLowerCase().contains(query) ||
          d.titleAr.contains(query);
    }).toList();

    final DatabaseSortOption? option = sortOption;
    if (option == null) return List<DatabaseEntity>.unmodifiable(matches);

    matches.sort((DatabaseEntity a, DatabaseEntity b) {
      switch (option) {
        case DatabaseSortOption.ascending:
          return _compareTitles(a, b, isArabic);
        case DatabaseSortOption.descending:
          return _compareTitles(b, a, isArabic);
        case DatabaseSortOption.lastUpdated:
          return _compareRecency(a, b, isArabic);
      }
    });

    return List<DatabaseEntity>.unmodifiable(matches);
  }

  /// A → Z on the title the current locale renders.
  ///
  /// Case-insensitive, so "apple" and "Apple" land next to each other instead
  /// of in two separate alphabets — `compareTo` on raw strings puts every
  /// capital ahead of every lowercase letter, which reads as broken.
  /// `toLowerCase()` is a no-op on Arabic, so the same path serves both.
  int _compareTitles(DatabaseEntity a, DatabaseEntity b, bool isArabic) {
    final int byTitle = a
        .localizedTitle(isArabic: isArabic)
        .toLowerCase()
        .compareTo(b.localizedTitle(isArabic: isArabic).toLowerCase());

    // Two records with the same title would otherwise sort unstably between
    // rebuilds. Falling back to the id makes the order fixed.
    return byTitle != 0 ? byTitle : a.id.compareTo(b.id);
  }

  /// Most recently touched first — `updatedAt` when the record has been
  /// edited, its creation date when it has not.
  ///
  /// A record with NEITHER date sorts last rather than first: null is missing
  /// information, and putting unknown-age rows at the top of a "most recent"
  /// list would push the actual recent ones out of sight.
  int _compareRecency(DatabaseEntity a, DatabaseEntity b, bool isArabic) {
    final DateTime? left = a.updatedAt ?? a.createdAt;
    final DateTime? right = b.updatedAt ?? b.createdAt;

    if (left == null && right == null) return _compareTitles(a, b, isArabic);
    if (left == null) return 1;
    if (right == null) return -1;

    final int byDate = right.compareTo(left);
    return byDate != 0 ? byDate : _compareTitles(a, b, isArabic);
  }

  bool _matchesFilter(DatabaseEntity d) {
    // DELETED RECORDS ARE INVISIBLE EVERYWHERE ELSE, All included. Since the
    // card menu became a soft delete (16/8/2026) they are still in
    // `databases`, so without this guard a deleted database would sit in the
    // middle of the working list looking exactly like a live one — and All
    // would be the chip where "Delete" appeared to do nothing at all.
    if (d.isDeleted) return filter == DatabaseListFilter.deleted;

    switch (filter) {
      case DatabaseListFilter.all:
        return true;
      // The access-type chips show FINISHED databases only. A draft has an
      // access type like anything else, but it has granted nobody anything
      // yet — listing it under "Restricted" next to real ones would make the
      // chip a lie. It is reachable under All and under Drafts.
      case DatabaseListFilter.open:
        return !d.isDraft && d.accessType == DatabaseAccessType.open;
      case DatabaseListFilter.restricted:
        return !d.isDraft && d.accessType == DatabaseAccessType.restricted;
      case DatabaseListFilter.personal:
        return !d.isDraft && d.accessType == DatabaseAccessType.personal;
      case DatabaseListFilter.drafts:
        return d.isDraft;
      // Handled by the guard above — a live record never belongs here.
      case DatabaseListFilter.deleted:
        return false;
    }
  }

  /// Count for one chip. Always against the FULL list, never the search
  /// results — otherwise typing in the search box would make the chips
  /// disagree with the cards under them.
  ///
  /// Returns a plain int rather than a built chip: `StatusChipItem` is a
  /// presentation type, so the page assembles the chips and the cubit only
  /// supplies numbers.
  int countFor(DatabaseListFilter which) {
    switch (which) {
      // LIVE records only, matching what the chip lists. A count that included
      // deleted rows would be a number the user could never reconcile with the
      // cards under it.
      case DatabaseListFilter.all:
        return databases.where((DatabaseEntity d) => !d.isDeleted).length;
      case DatabaseListFilter.open:
        return _countOfType(DatabaseAccessType.open);
      case DatabaseListFilter.restricted:
        return _countOfType(DatabaseAccessType.restricted);
      case DatabaseListFilter.personal:
        return _countOfType(DatabaseAccessType.personal);
      case DatabaseListFilter.drafts:
        return databases
            .where((DatabaseEntity d) => !d.isDeleted && d.isDraft)
            .length;
      // A real number since the card menu became a soft delete (16/8/2026).
      // This used to be a hardcoded zero because the document was gone.
      case DatabaseListFilter.deleted:
        return databases.where((DatabaseEntity d) => d.isDeleted).length;
    }
  }

  /// Counts FINISHED, LIVE databases of [type]. Drafts and deleted records are
  /// excluded for the same reason they are excluded from the chip's list: the
  /// number and the cards under it have to agree.
  int _countOfType(DatabaseAccessType type) => databases
      .where((DatabaseEntity d) =>
          !d.isDeleted && !d.isDraft && d.accessType == type)
      .length;

  DatabaseListState copyWith({
    List<DatabaseEntity>? databases,
    DatabaseListFilter? filter,
    String? searchQuery,
    DatabaseAccessType? accessFilter,
    DatabaseSortOption? sortOption,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,

    /// `accessFilter: null` cannot mean "clear it" — null is also "leave it
    /// alone" for every other nullable field here — so Reset needs its own
    /// flag, the same shape [clearErrorMessage] already uses.
    bool clearAccessFilter = false,

    /// Same reason: deselecting the sort option hands back null, and null on
    /// its own would read as "no change".
    bool clearSortOption = false,
  }) {
    return DatabaseListState(
      databases: databases ?? this.databases,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      accessFilter:
          clearAccessFilter ? null : (accessFilter ?? this.accessFilter),
      sortOption: clearSortOption ? null : (sortOption ?? this.sortOption),
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DatabaseListCubit extends Cubit<DatabaseListState> {
  DatabaseListCubit({CreateDatabaseBaseRepository? repository})
      : _repository = repository ?? CreateDatabaseRepository(),
        super(const DatabaseListState());

  final CreateDatabaseBaseRepository _repository;

  @override
  void emit(DatabaseListState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Either<Failure, List<DatabaseEntity>> result =
        await _repository.listDatabases();

    emit(result.fold(
      (Failure failure) => state.copyWith(
        isLoading: false,
        errorMessage: failure.errMessage,
      ),
      (List<DatabaseEntity> databases) => state.copyWith(
        isLoading: false,
        databases: databases,
      ),
    ));
  }

  /// Adds a freshly created record to the top of the list.
  ///
  /// The flow already returned the saved entity, so re-reading the whole
  /// collection to discover one new row would be a wasted query — and would
  /// briefly show a spinner over a list the user was just looking at.
  void insert(DatabaseEntity database) => emit(
        state.copyWith(
          databases: <DatabaseEntity>[database, ...state.databases],
        ),
      );

  /// Swaps a card for the edited version of itself.
  ///
  /// ADDED 16/8/2026 for the details screen (db2), which can rename a record,
  /// change its access type and change its member count — all three of which
  /// this list draws. Matched by id and left alone when the id is not here, so
  /// a record filtered out of the current chip does not get appended by an
  /// edit made somewhere else.
  ///
  /// Optimistic for the same reason `insert` is: the caller only has an edited
  /// record because the write already succeeded.
  void replace(DatabaseEntity database) => emit(
        state.copyWith(
          databases: state.databases
              .map((DatabaseEntity d) => d.id == database.id ? database : d)
              .toList(growable: false),
        ),
      );

  /// Marks a card whose record was ALREADY deleted elsewhere.
  ///
  /// Distinct from [delete], which performs the write. The details screen owns
  /// its own confirm-and-delete — the status is already `deleted` on the server
  /// by the time it returns — so calling `delete` here would fire a second
  /// write, and that one would stamp `previous_status: deleted` and make the
  /// record unrestorable.
  ///
  /// CHANGED 16/8/2026: this used to drop the row. Now that deleting is a
  /// status change, dropping it would hide the record from the Deleted chip
  /// until the next full load, which is exactly where the user goes looking
  /// for it.
  void markDeletedLocally(String id) => emit(
        state.copyWith(
          databases: state.databases
              .map((DatabaseEntity d) => d.id == id
                  ? d.copyWith(
                      status: DatabaseStatus.deleted,
                      previousStatus: d.status,
                      deletedAt: DateTime.now(),
                    )
                  : d)
              .toList(growable: false),
        ),
      );

  /// [key] is `DatabaseListFilter.name` — what `StatusChipFilter` hands back.
  /// An unrecognised key is ignored rather than defaulting to `all`, so a
  /// typo cannot silently widen what the user is looking at.
  void filterChanged(String key) {
    for (final DatabaseListFilter f in DatabaseListFilter.values) {
      if (f.name == key) {
        emit(state.copyWith(filter: f));
        return;
      }
    }
  }

  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  /// Applies the Filter dialog's choice. A null [type] is the dialog's Reset,
  /// so it clears the filter rather than being ignored as "no change".
  void accessFilterChanged(DatabaseAccessType? type) => emit(
        type == null
            ? state.copyWith(clearAccessFilter: true)
            : state.copyWith(accessFilter: type),
      );

  /// Applies the Sort button's choice. ADDED 16/8/2026.
  ///
  /// A null [option] is `CustomSortButton` deselecting — the user tapped the
  /// row that was already selected — so it clears the ordering and puts the
  /// list back in the repository's order rather than being ignored.
  ///
  /// Only the ordering changes here. The chip, the search box and the Filter
  /// dialog are untouched, so sorting narrows nothing: whatever set of cards
  /// was on screen is the same set, rearranged.
  void sortChanged(DatabaseSortOption? option) => emit(
        option == null
            ? state.copyWith(clearSortOption: true)
            : state.copyWith(sortOption: option),
      );

  /// Moves [database] into the Deleted chip, returning false when the write
  /// failed so the page can raise the error dialog.
  ///
  /// SOFT since 16/8/2026. The row is not dropped — its status changes, which
  /// is what makes it disappear from the chip the user is standing in and
  /// appear under Deleted with the count to match, both from one emit.
  ///
  /// The local edit lands only AFTER the repository confirms. An optimistic
  /// version would be a lie the user cannot see through: the card would move
  /// to Deleted, the record would still be live in Firestore, and the next
  /// load would put it back with no explanation. `insert` can be optimistic
  /// because the write has already succeeded by the time it is called; this
  /// cannot.
  ///
  /// `previousStatus` is the status the record is standing in RIGHT NOW, which
  /// is what Restore reads back — delete a draft and Restore returns it to
  /// Drafts, not to the finished list.
  Future<bool> delete(DatabaseEntity database) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Either<Failure, void> result = await _repository.deleteDatabase(
      database.id,
      previousStatus: database.status,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isLoading: false,
          databases: state.databases
              .map((DatabaseEntity d) => d.id == database.id
                  ? d.copyWith(
                      status: DatabaseStatus.deleted,
                      previousStatus: database.status,
                      // Local stand-in for the server timestamp. Nothing draws
                      // it, and the next load replaces it with the real one.
                      deletedAt: DateTime.now(),
                    )
                  : d)
              .toList(growable: false),
        ));
        return true;
      },
    );
  }

  /// Puts a soft-deleted record back where it came from — "Restore" on the
  /// card's "..." menu. ADDED 16/8/2026. Returns false on failure so the page
  /// can raise the dialog.
  ///
  /// The target comes from `DatabaseEntity.restoreTarget`, not from a constant:
  /// a database that was a draft when it was deleted goes back to Drafts. Both
  /// deletion markers are cleared locally through `clearDeletionMarkers` so the
  /// in-memory row matches the document, where they were removed outright.
  ///
  /// A record that is not actually deleted is refused before any write. It can
  /// only happen through a stale card — the Restore row is not drawn on a live
  /// one — and restoring a live database would rewrite its status for nothing.
  Future<bool> restore(DatabaseEntity database) async {
    if (!database.isDeleted) return false;

    final DatabaseStatus target = database.restoreTarget;

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Either<Failure, void> result = await _repository.restoreDatabase(
      database.id,
      status: target,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isLoading: false,
          databases: state.databases
              .map((DatabaseEntity d) => d.id == database.id
                  ? d.copyWith(status: target, clearDeletionMarkers: true)
                  : d)
              .toList(growable: false),
        ));
        return true;
      },
    );
  }

  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));
}
