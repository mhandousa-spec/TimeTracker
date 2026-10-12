/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_repository.dart
/// Purpose: Implements [CompanyBaseRepository] over the remote data source.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N02 / N07. `getCompany`, `addCompany`,
/// `updateCompanyModel` and `updateCompanyInformation` all reached Firestore
/// from `CompanyCubit`; the I/O half of them lives here now and the cubit keeps
/// only the state transitions.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/data_source/remote_data_source/company_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/base_repository/company_base_repository.dart';

class CompanyRepository implements CompanyBaseRepository {
  CompanyRepository({CompanyRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CompanyRemoteDataSource();

  final CompanyRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, CompanyModel?>> getCompany(String companyId) async {
    try {
      return Right<Failure, CompanyModel?>(
          await _remoteDataSource.read(companyId));
    } catch (e) {
      return Left<Failure, CompanyModel?>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveCompany(
    String companyId,
    CompanyModel company,
  ) async {
    try {
      await _remoteDataSource.write(companyId, company);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }
}
