/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_base_repository.dart
/// Purpose: Domain contract for nav-bar module-licence lookups.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Which modules a company may see is business logic, so it gets a domain
/// contract rather than living as a raw Firestore call inside the cubit.

abstract class NavBarBaseRepository {
  /// Function Name: [getCompanyLicensedModules]
  ///
  /// Purpose: Resolve which modules the given company is licensed for.
  ///
  /// Parameters:
  /// - [companyId]: Document id of the company's demo-request record.
  ///
  /// Returns: [Future<Map<String, bool>>] keyed by lowercased module name.
  ///          An **empty map means "no licence data"**, which callers treat as
  ///          "block every non-system module" — it is not the same as a map of
  ///          all-false, and it is what is returned on a read failure.
  Future<Map<String, bool>> getCompanyLicensedModules(String companyId);
}
