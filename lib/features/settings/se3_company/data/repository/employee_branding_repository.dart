/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: employee_branding_repository.dart
/// Purpose: Employee personal-branding CRUD, on top of the remote data source.
/// Author: Amr Mesbah
/// Created at: 2026-01-25
/// Updated: 11/8/2026 - CR-SKEL-SE3-N19/N20/N21: `FirebaseFirestore.instance`
///          and the two hardcoded `Demo/$companyId/...` paths moved into
///          `EmployeeBrandingRemoteDataSource` / `CompanyCollectionPaths`; the
///          ~40 debug prints are gone with the previous round; the swallowing
///          catches now return a typed [Failure] instead of `null`/`false`, so
///          "no branding" and "the read failed" are no longer the same answer.
///
/// PORTED into services_app under features/settings.
/// Source: services_app features/employees/employee_branding/data/repo/…

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/data_source/remote_data_source/employee_branding_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/base_repository/employee_branding_base_repository.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/entities/employee_branding_entity.dart';

class EmployeeBrandingRepository implements EmployeeBrandingBaseRepository {
  EmployeeBrandingRepository({
    EmployeeBrandingRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? EmployeeBrandingRemoteDataSource();

  final EmployeeBrandingRemoteDataSource _remoteDataSource;

  @override
  Future<bool> isInitialized() async {
    try {
      return await _remoteDataSource.hasAnyBranding();
    } catch (_) {
      // A failed probe is treated as "not initialized" on purpose: the caller
      // only uses this to decide whether to run the idempotent seeding pass.
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> initializeEmployeeDataCollection({
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
  }) async {
    try {
      if (await _remoteDataSource.hasAnyBranding()) {
        return const Right<Failure, void>(null);
      }

      final List<String> employeeIds =
          await _remoteDataSource.readEmployeeIds();

      await _remoteDataSource.writeMany(
        employeeIds
            .map((String id) => EmployeeBrandingEntity.fromCompanyBranding(
                  employeeId: id,
                  companyLogo: companyLogo,
                  companyPrimaryColor: companyPrimaryColor,
                  companySecondaryColor: companySecondaryColor,
                  companyFontEnglish: companyFontEnglish,
                  companyFontArabic: companyFontArabic,
                ))
            .toList(),
      );

      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeBrandingEntity?>> getEmployeeBranding(
      String employeeId) async {
    try {
      return Right<Failure, EmployeeBrandingEntity?>(
        await _remoteDataSource.read(employeeId),
      );
    } catch (e) {
      return Left<Failure, EmployeeBrandingEntity?>(
          FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveEmployeeBranding(
      EmployeeBrandingEntity branding) async {
    try {
      await _remoteDataSource.write(
        branding.copyWith(updatedAt: DateTime.now()),
      );
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetToCompanyBranding({
    required String employeeId,
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
  }) {
    return saveEmployeeBranding(
      EmployeeBrandingEntity.fromCompanyBranding(
        employeeId: employeeId,
        companyLogo: companyLogo,
        companyPrimaryColor: companyPrimaryColor,
        companySecondaryColor: companySecondaryColor,
        companyFontEnglish: companyFontEnglish,
        companyFontArabic: companyFontArabic,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteEmployeeBranding(
      String employeeId) async {
    try {
      await _remoteDataSource.delete(employeeId);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }
}
