/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_base_repository.dart
/// Purpose: Domain contract for reading and writing the company document.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N02.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_model.dart';

abstract class CompanyBaseRepository {
  /// The company document. `Right(null)` means "no such company"; a `Left`
  /// means the read failed.
  Future<Either<Failure, CompanyModel?>> getCompany(String companyId);

  /// Merge-write the company document.
  Future<Either<Failure, void>> saveCompany(
    String companyId,
    CompanyModel company,
  );
}
