/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_repository.dart
/// Purpose: Implements [SocialBaseRepository] over the remote data source.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N01. The failure is converted to a [Failure] here so
/// the cubit never sees a `FirebaseException` — the old code caught the raw
/// error in the controller and interpolated `error.toString()` straight into a
/// user-facing snackbar.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se2_social/data/data_source/remote_data_source/social_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/base_repository/social_base_repository.dart';

class SocialRepository implements SocialBaseRepository {
  SocialRepository({SocialRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SocialRemoteDataSource();

  final SocialRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, void>> updateSocialFields({
    required String employeeId,
    required Map<String, dynamic> fields,
  }) async {
    if (employeeId.isEmpty) {
      return Left<Failure, void>(
        FirebaseFailure('Cannot save: the employee record has no id.'),
      );
    }

    try {
      await _remoteDataSource.updateSocialFields(
        employeeId: employeeId,
        fields: fields,
      );
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }
}
