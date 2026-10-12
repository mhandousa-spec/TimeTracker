/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: employee_branding_base_repository.dart
/// Purpose: Domain contract for employee personal branding.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N02 / N21. Every method returns an `Either` so a
/// failure is a value the cubit must handle, rather than the previous mix of
/// `rethrow`, `null` and `false`.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/entities/employee_branding_entity.dart';

abstract class EmployeeBrandingBaseRepository {
  /// Whether the per-employee branding collection has been seeded.
  Future<bool> isInitialized();

  /// Seed one branding document per employee from the company's branding.
  /// A no-op when the collection already has documents.
  Future<Either<Failure, void>> initializeEmployeeDataCollection({
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
  });

  /// One employee's branding. `Right(null)` means "no override"; a `Left`
  /// means the read itself failed — the old signature returned `null` for both.
  Future<Either<Failure, EmployeeBrandingEntity?>> getEmployeeBranding(
      String employeeId);

  Future<Either<Failure, void>> saveEmployeeBranding(
      EmployeeBrandingEntity branding);

  Future<Either<Failure, void>> resetToCompanyBranding({
    required String employeeId,
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
  });

  Future<Either<Failure, void>> deleteEmployeeBranding(String employeeId);
}
