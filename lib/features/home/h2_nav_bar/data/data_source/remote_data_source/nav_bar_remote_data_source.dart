/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_remote_data_source.dart
/// Purpose: Firestore reads for the nav bar's company-licence lookup.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Extracted from `nav_bar_cubit`, which used to call
/// `FirebaseFirestore.instance.collection('Demo_Requests')` directly.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/constants/firebase_collections.dart';

class NavBarRemoteDataSource {
  NavBarRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Function Name: [getDemoRequestDocument]
  ///
  /// Purpose: Fetch the raw demo-request document for a company.
  ///
  /// Parameters:
  /// - [companyId]: Document id of the company's demo-request record.
  ///
  /// Returns: [Future<Map<String, dynamic>?>] — `null` when the document does
  ///          not exist or carries no data.
  Future<Map<String, dynamic>?> getDemoRequestDocument(String companyId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(FirebaseCollections.demoRequests)
        .doc(companyId)
        .get();

    if (!snapshot.exists) return null;
    return snapshot.data();
  }
}
