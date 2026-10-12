/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_cubit.dart
/// Purpose: Declares `EditDatabaseCubit`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Editing Database Name" — Figma 7398:6461 (iPad V) / 7398:16968 (iPad H).
///
/// The same card as the create screen (cover, bilingual title, bilingual
/// description) with two differences that go all the way down:
///
///   * it starts FULL, seeded from the record, so [isDirty] is "different from
///     what was loaded" rather than "not empty"
///   * it UPDATES, so the duplicate-title check has to ignore the record being
///     edited — see `DatabaseDetailsBaseRepository.titleExists`
///
/// There is no access dropdown here: the Figma puts access on its own screen
/// ("Editing Database Access"), and editing it means rewriting the grants,
/// which is a different write with a different confirmation.

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/repository/database_details_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';

part './edit_database_state.dart';

class EditDatabaseCubit extends Cubit<EditDatabaseState> {
  EditDatabaseCubit({
    required DatabaseEntity database,
    DatabaseDetailsBaseRepository? repository,
  })  : _repository = repository ?? DatabaseDetailsRepository(),
        super(EditDatabaseState.from(database));

  final DatabaseDetailsBaseRepository _repository;

  @override
  void emit(EditDatabaseState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Fields ───────────────────────────────────────────────────────────────

  void titleEnChanged(String value) =>
      emit(state.copyWith(titleEn: value, clearTitleEnError: true));

  void titleArChanged(String value) =>
      emit(state.copyWith(titleAr: value, clearTitleArError: true));

  void descriptionEnChanged(String value) =>
      emit(state.copyWith(descriptionEn: value));

  void descriptionArChanged(String value) =>
      emit(state.copyWith(descriptionAr: value));

  void coverImagePicked(File file) => emit(state.copyWith(coverImage: file));

  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  /// Puts every field back to the record as loaded — "Discard Changes".
  ///
  /// Resets rather than pops, because the page also has to push the same
  /// values back into its `TextEditingController`s; a cubit that only popped
  /// would leave the boxes showing the edits it had just thrown away.
  void discard() => emit(EditDatabaseState.from(state.original));

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Function Name: [save]
  ///
  /// Purpose: Validate, check the title is free, and write.
  ///
  /// The localized copy is passed in because a cubit has no BuildContext and
  /// the domain layer must not acquire one — the same arrangement db1 uses.
  ///
  /// ORDER MATTERS. Local validation first (free, no network), then the
  /// duplicate query, then the write. Running the duplicate check on an empty
  /// title would spend a Firestore read to be told that "" is available.
  Future<void> save({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
  }) async {
    final String titleEn = state.titleEn.trim();
    final String titleAr = state.titleAr.trim();

    final String? enError = _titleError(
      titleEn,
      requiredMessage: requiredEnMessage,
      tooShortMessage: tooShortMessage,
    );
    final String? arError = _titleError(
      titleAr,
      requiredMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );

    if (enError != null || arError != null) {
      emit(state.copyWith(
        submitted: true,
        status: EditDatabaseStatus.initial,
        titleEnError: enError,
        titleArError: arError,
        clearTitleEnError: enError == null,
        clearTitleArError: arError == null,
      ));
      return;
    }

    emit(state.copyWith(
      submitted: true,
      status: EditDatabaseStatus.submitting,
      clearErrorMessage: true,
      clearTitleEnError: true,
      clearTitleArError: true,
    ));

    // Only worth asking when a title actually changed. An edit that touched
    // the description alone would otherwise pay for two queries to confirm
    // that the record still has the name it already had.
    if (titleEn.toLowerCase() != state.original.titleEn.trim().toLowerCase() ||
        titleAr.toLowerCase() != state.original.titleAr.trim().toLowerCase()) {
      final Either<Failure, bool> taken = await _repository.titleExists(
        titleEn: titleEn,
        titleAr: titleAr,
        excludeId: state.original.id,
      );

      final bool rejected = taken.fold(
        (Failure failure) {
          emit(state.copyWith(
            status: EditDatabaseStatus.failure,
            errorMessage: failure.errMessage,
          ));
          return true;
        },
        (bool exists) {
          if (!exists) return false;
          emit(state.copyWith(
            status: EditDatabaseStatus.failure,
            errorMessage: duplicateMessage,
          ));
          return true;
        },
      );

      if (rejected) return;
    }

    final DatabaseEntity edited = state.original.copyWith(
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: state.descriptionEn.trim(),
      descriptionAr: state.descriptionAr.trim(),
    );

    final Either<Failure, DatabaseEntity> result =
        await _repository.updateDatabase(edited, coverImage: state.coverImage);

    emit(result.fold(
      (Failure failure) => state.copyWith(
        status: EditDatabaseStatus.failure,
        errorMessage: failure.errMessage,
      ),
      // Seeded from what came BACK, not from what was sent: the server
      // resolved `updated_at` and the cover URL, and the next Discard has to
      // return to the saved state rather than to the pre-save one.
      (DatabaseEntity saved) => EditDatabaseState.from(saved).copyWith(
        status: EditDatabaseStatus.success,
        savedDatabase: saved,
      ),
    ));
  }

  /// Both titles use the same two rules, so they share one check — a second
  /// copy is how the English side ends up enforcing a limit the Arabic side
  /// does not.
  String? _titleError(
    String value, {
    required String requiredMessage,
    required String tooShortMessage,
  }) {
    if (value.isEmpty) return requiredMessage;
    if (value.length < CreateDatabaseLimits.titleMinLength) {
      return tooShortMessage;
    }
    return null;
  }
}
