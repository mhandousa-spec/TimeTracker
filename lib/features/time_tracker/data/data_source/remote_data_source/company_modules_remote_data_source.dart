/// Module: time_tracker / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: company_modules_remote_data_source.dart
/// Purpose: Declares `CompanyModulesRemoteDataSource` — reads the company's
///          licence document `Demo_Requests/{companyId}` (READ-ONLY).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Same document `RoleCubit.loadCompanyLicensedModules` and the drawer read.
/// Throws on failure (no try/catch here).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/constants/firebase_collections.dart';

class CompanyModulesRemoteDataSource {
  CompanyModulesRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Function Name: [fetchLicence]
  ///
  /// Purpose: The raw licence document of [companyId], or null when missing.
  ///
  /// Parameters:
  ///   [String] companyId: refuses '' and ids containing `/`.
  ///
  /// Return type: [Future<Map<String, dynamic>?>]
  Future<Map<String, dynamic>?> fetchLicence(String companyId) async {
    final String id = companyId.trim();
    if (id.isEmpty || id.contains('/')) {
      throw StateError('No company is signed in — the licence cannot be read.');
    }
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(FirebaseCollections.demoRequests)
        .doc(id)
        .get();
    return snapshot.exists ? snapshot.data() : null;
  }
}
