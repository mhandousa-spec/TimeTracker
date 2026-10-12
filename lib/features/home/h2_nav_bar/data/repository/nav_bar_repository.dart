/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_repository.dart
/// Purpose: Turns the raw demo-request document into a module-licence map.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/data/data_source/remote_data_source/nav_bar_remote_data_source.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/domain/base_repository/nav_bar_base_repository.dart';

class NavBarRepository implements NavBarBaseRepository {
  NavBarRepository({NavBarRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? NavBarRemoteDataSource();

  final NavBarRemoteDataSource _remoteDataSource;

  @override
  Future<Map<String, bool>> getCompanyLicensedModules(String companyId) async {
    try {
      final Map<String, dynamic>? data =
          await _remoteDataSource.getDemoRequestDocument(companyId);
      if (data == null) return <String, bool>{};

      final Map<dynamic, dynamic>? modulesData = _extractModulesMap(data);
      if (modulesData == null) return <String, bool>{};

      final Map<String, bool> licensed = <String, bool>{};
      for (final MapEntry<dynamic, dynamic> entry in modulesData.entries) {
        licensed[entry.key.toString().toLowerCase()] =
            _isEntryLicensed(entry.value);
      }
      return licensed;
    } catch (_) {
      // An empty map means "no licence data", which the callers treat as
      // "block every non-system module" — the safe default on a read failure.
      return <String, bool>{};
    }
  }

  /// The licence map lives either nested under `Demo_Details` (older documents)
  /// or at the document root (newer ones). Both shapes are still in the wild.
  Map<dynamic, dynamic>? _extractModulesMap(Map<String, dynamic> data) {
    final dynamic demoDetails = data[FirebaseCollections.demoDetailsKey];
    if (demoDetails is Map) {
      final dynamic nested = demoDetails[FirebaseCollections.modulesKey];
      if (nested is Map) return nested;
    }
    final dynamic root = data[FirebaseCollections.modulesKey];
    if (root is Map) return root;
    return null;
  }

  /// A module entry is either `{Values: [..., true]}`, a bare bool, or a list
  /// whose last element is the current value.
  bool _isEntryLicensed(dynamic moduleData) {
    if (moduleData is Map) {
      final dynamic values = moduleData[FirebaseCollections.moduleValuesKey];
      if (values is List && values.isNotEmpty) return values.last == true;
      return false;
    }
    if (moduleData is bool) return moduleData;
    if (moduleData is List && moduleData.isNotEmpty) {
      return moduleData.last == true;
    }
    return false;
  }
}
