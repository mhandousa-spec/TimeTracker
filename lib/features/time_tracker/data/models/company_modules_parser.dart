/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: company_modules_parser.dart
/// Purpose: Declares `CompanyModulesParser` — reads which modules a company
///          is licensed for from its `Demo_Requests/{companyId}` document.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Same parsing as `RoleCubit.loadCompanyLicensedModules` (the licence the
/// role editor and the drawer use): the `Modules` map sits under
/// `Demo_Details` or at the root; each module is a bool, a history list, or
/// `{Values: [...]}` — the LAST entry decides. Keys are lower-cased.
///
/// Used to answer "does this company have HR?" (owner decision 7): the
/// COMPANY licence, not the signed-in role's `Current_Selected_Modules` — a
/// role without HR access in an HR company must still see HR-owned set-up.

import 'package:knowticed_plus/core/constants/firebase_collections.dart';

class CompanyModulesParser {
  const CompanyModulesParser._();

  /// The HR module's licence key.
  static const String hrModuleKey = 'hr';

  /// Function Name: [licensedModules]
  ///
  /// Purpose: Module key (lower-case) -> licensed now.
  ///
  /// Parameters:
  ///   [Map<String, dynamic>?] document: the raw licence document.
  ///
  /// Return type: [Map<String, bool>] — empty when the document or its
  /// `Modules` map is missing (fail-closed: nothing licensed).
  static Map<String, bool> licensedModules(Map<String, dynamic>? document) {
    if (document == null) return const <String, bool>{};
    final Object? details = document[FirebaseCollections.demoDetailsKey];
    Object? modules;
    if (details is Map && details[FirebaseCollections.modulesKey] is Map) {
      modules = details[FirebaseCollections.modulesKey];
    } else {
      modules = document[FirebaseCollections.modulesKey];
    }
    if (modules is! Map) return const <String, bool>{};
    return <String, bool>{
      for (final MapEntry<dynamic, dynamic> e in modules.entries)
        e.key.toString().trim().toLowerCase(): _isOn(e.value),
    };
  }

  /// Function Name: [hasHr]
  ///
  /// Purpose: Whether the licence includes the HR module.
  ///
  /// Parameters:
  ///   [Map<String, dynamic>?] document
  ///
  /// Return type: [bool]
  static bool hasHr(Map<String, dynamic>? document) =>
      licensedModules(document)[hrModuleKey] == true;

  static bool _isOn(Object? value) {
    if (value is bool) return value;
    if (value is List) return value.isNotEmpty && value.last == true;
    if (value is Map) {
      final Object? values = value[FirebaseCollections.moduleValuesKey];
      return values is List && values.isNotEmpty && values.last == true;
    }
    return false;
  }
}
