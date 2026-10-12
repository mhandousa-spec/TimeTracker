// ****************** FILE INFO ******************
// File Name: upload_client_files_use_case.dart
// Purpose: Orchestrates uploading pending File values of a client record to
//          Firebase Storage and returns the URL-backed values map
// Author: Mohand Adel
// Created At: 12/08/2026

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';

/// Uploads every pending platform file inside a client record's values map and
/// replaces it with its storage URL.
///
/// The Cubit/state never performs this platform I/O itself (rule 17); it
/// delegates to this use case which owns the upload boundary.
class UploadClientFilesUseCase {
  UploadClientFilesUseCase(this.repository);

  final CrmClientsBaseRepository repository;

  /// Iterates [values] and uploads every entry whose value is a [File],
  /// returning a new map keyed identically but with storage URLs. Non-file
  /// values are passed through untouched.
  ///
  /// On the first upload failure the operation stops and returns
  /// [Left] with the underlying [Failure]; previously uploaded URLs are not
  /// rolled back.
  Future<Either<Failure, Map<String, dynamic>>> execute({
    required Map<String, dynamic> values,
    required String recordId,
  }) async {
    final Map<String, dynamic> uploaded = <String, dynamic>{};

    for (final MapEntry<String, dynamic> entry in values.entries) {
      final dynamic value = entry.value;
      if (value is! File) {
        uploaded[entry.key] = value;
        continue;
      }

      final Either<Failure, String> result = await repository.uploadClientFile(
        file: value,
        recordId: recordId,
        fieldId: entry.key,
      );
      final Failure? failure = result.fold((left) => left, (_) => null);
      if (failure != null) return Left(failure);
      uploaded[entry.key] = result.fold((_) => '', (url) => url);
    }

    return Right(uploaded);
  }
}
