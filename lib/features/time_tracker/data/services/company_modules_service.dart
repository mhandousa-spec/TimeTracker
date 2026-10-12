/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: company_modules_service.dart
/// Purpose: Declares `CompanyModulesService` — answers "is the company
///          licensed for module X?" (mainly `hasHrModule`) from the company's
///          licence, cached per company.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 7 (8/10/2026): with HR, locations / shift hours /
/// assignments come from HR; without HR, Time Tracker owns them. This is the
/// one place that decides which. It reads the COMPANY licence
/// (`Demo_Requests/{companyId}` → `Modules`, parsed like
/// `RoleCubit.loadCompanyLicensedModules`), not the signed-in role's
/// selected modules.
///
/// Errors propagate (no try/catch outside repositories and cubits); the
/// caller decides. Nothing is cached after a failure.

import 'package:knowticed_plus/core/helper/hr/hr_api_constants.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/company_modules_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/company_modules_parser.dart';

/// Returns the signed-in company's id ('' before login).
typedef CompanyIdReader = String Function();

class CompanyModulesService {
  CompanyModulesService({
    required CompanyModulesRemoteDataSource dataSource,
    CompanyIdReader companyId = _tenantId,
  })  : _dataSource = dataSource,
        _companyId = companyId;

  final CompanyModulesRemoteDataSource _dataSource;
  final CompanyIdReader _companyId;

  String? _cachedFor;
  Map<String, bool> _cached = const <String, bool>{};

  /// Function Name: [licensedModules]
  ///
  /// Purpose: Module key (lower-case) -> licensed, for the signed-in company.
  ///
  /// Return type: [Future<Map<String, bool>>] — throws when no company is
  /// signed in or the read fails.
  Future<Map<String, bool>> licensedModules() async {
    final String company = _companyId().trim();
    if (_cachedFor != null && _cachedFor == company) return _cached;
    final Map<String, dynamic>? licence = await _dataSource.fetchLicence(company);
    _cached = CompanyModulesParser.licensedModules(licence);
    _cachedFor = company;
    return _cached;
  }

  /// Function Name: [hasHrModule]
  ///
  /// Purpose: Whether the company has the HR module.
  ///
  /// Return type: [Future<bool>]
  Future<bool> hasHrModule() async =>
      (await licensedModules())[CompanyModulesParser.hrModuleKey] == true;

  /// Function Name: [clear]
  ///
  /// Purpose: Forget the cached licence (after logout / company switch).
  ///
  /// Return type: [void]
  void clear() {
    _cachedFor = null;
    _cached = const <String, bool>{};
  }

  static String _tenantId() => HrApiConstants.tenantId;
}
