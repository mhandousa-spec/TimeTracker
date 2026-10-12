/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_remote_data_source.dart
/// Purpose: Firestore reads and writes for the company document.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N01 / N07. `CompanyCubit` held
/// `FirebaseFirestore.instance` and called `.doc().set(...)` / `.doc().get()`
/// itself — a Firestore call from the presentation layer.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/utils/company_collection_paths.dart';

class CompanyRemoteDataSource {
  CompanyRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Function Name: [read]
  ///
  /// Purpose: Load one company document.
  ///
  /// Returns: [Future<CompanyModel?>] — `null` when the document is absent,
  ///          which the caller treats as "no company", not as an error.
  Future<CompanyModel?> read(String companyId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _db
        .collection(CompanyCollectionPaths.companies)
        .doc(companyId)
        .get();

    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return CompanyModel.fromMap(data);
  }

  /// Function Name: [write]
  ///
  /// Purpose: Merge-write a company document.
  Future<void> write(String companyId, CompanyModel company) {
    return _db
        .collection(CompanyCollectionPaths.companies)
        .doc(companyId)
        .set(company.toMap(), SetOptions(merge: true));
  }
}
