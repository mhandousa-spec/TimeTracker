/// Module: database / db1_create_database / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_use_case.dart
/// Purpose: Declares `CreateDatabaseUseCase`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// Validation + duplicate check + write, in that order. This lives in the
/// domain layer so the same rules apply no matter which screen calls it —
/// the iPad card today, an import flow or an API tomorrow.

import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';

/// Field-level validation outcome. The cubit maps these onto the two title
/// fields' `errorText`, which is what turns their border red.
class CreateDatabaseValidation {
  const CreateDatabaseValidation({this.titleEnError, this.titleArError});

  final String? titleEnError;
  final String? titleArError;

  bool get isValid => titleEnError == null && titleArError == null;
}

class CreateDatabaseUseCase {
  const CreateDatabaseUseCase(this._repository);

  final CreateDatabaseBaseRepository _repository;

  /// Function Name: [validate]
  ///
  /// Purpose: Pure, synchronous field checks. Separate from [call] so the
  /// cubit can run it on every keystroke without touching the network.
  ///
  /// The messages are passed in rather than built here because the domain
  /// layer has no BuildContext and therefore no locale.
  CreateDatabaseValidation validate(
    DatabaseEntity database, {
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
  }) {
    final String titleEn = database.titleEn.trim();
    final String titleAr = database.titleAr.trim();

    String? enError;
    String? arError;

    if (titleEn.isEmpty) {
      enError = requiredEnMessage;
    } else if (titleEn.length < CreateDatabaseLimits.titleMinLength) {
      enError = tooShortMessage;
    }

    if (titleAr.isEmpty) {
      arError = requiredArMessage;
    } else if (titleAr.length < CreateDatabaseLimits.titleMinLength) {
      arError = tooShortMessage;
    }

    return CreateDatabaseValidation(titleEnError: enError, titleArError: arError);
  }

  /// Function Name: [call]
  ///
  /// Purpose: Reject a duplicate title, then write the record.
  ///
  /// The duplicate check is a separate round-trip on purpose: a unique-index
  /// style write would need a transaction over a collection query, which
  /// Firestore does not offer. This narrows the window rather than closing
  /// it — two simultaneous creates with the same title can still both land,
  /// which is acceptable for a titled document and is caught by the list view.
  ///
  /// CREATE OR UPDATE, decided by [existingId] (ADDED 16/8/2026).
  ///
  /// The wizard can be reopened on a parked draft now, and finishing one has to
  /// rewrite THAT document — going through `createDatabase` would leave the
  /// draft under Drafts with a duplicate beside it. The same id is what the
  /// duplicate check has to forgive: a resumed draft keeps the title it was
  /// saved with, so without `excludeId` every resume would be refused for
  /// clashing with itself.
  Future<Either<Failure, DatabaseEntity>> call(
    DatabaseEntity database, {
    File? coverImage,
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
    String? existingId,
    required String duplicateMessage,
  }) async {
    final Either<Failure, bool> exists = await _repository.titleExists(
      titleEn: database.titleEn.trim(),
      titleAr: database.titleAr.trim(),
      excludeId: existingId,
    );

    final Failure? lookupFailure = exists.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (lookupFailure != null) return Left(lookupFailure);

    final bool isDuplicate = exists.getOrElse(() => false);
    if (isDuplicate) {
      return Left(ValidationError(duplicateMessage));
    }

    final DatabaseEntity cleaned = database.copyWith(
      titleEn: database.titleEn.trim(),
      titleAr: database.titleAr.trim(),
      descriptionEn: database.descriptionEn.trim(),
      descriptionAr: database.descriptionAr.trim(),
      // Denormalised onto the parent so the Database Builder list can show
      // "No. Of Members" without reading the grants subcollection for
      // every card. Deduped by employee: one person reachable through both
      // a department grant and an individual pick counts once.
      memberCount: grants
          .expand((DatabaseAccessGrant g) => g.members)
          .toSet()
          .length,
    );

    if (existingId != null && existingId.isNotEmpty) {
      return _repository.updateDatabase(
        cleaned.copyWith(id: existingId),
        coverImage: coverImage,
        grants: grants,
      );
    }

    return _repository.createDatabase(
      cleaned,
      coverImage: coverImage,
      grants: grants,
    );
  }
}
