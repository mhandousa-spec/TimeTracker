/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_remote_data_source.dart
/// Purpose: The one Firestore write behind the social settings page.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
/// Updated: 9/10/2026 - The save APPENDS a revision instead of overwriting.
///          It used to `update()` the given map straight onto the employee
///          document, replacing each history array with one element and never
///          touching `timestamps`. It now reads the document, appends one
///          revision through `SocialHistoryWriter` (the Employees_Info append
///          helper), and writes only the keys that append changed — the same
///          read → append → update shape as the change-request approval path
///          (`RequestsRemoteDataSource.applyChangesToEmployee`).
///
/// Added for CR-SKEL-SE2-N01 / N06. This call previously sat in
/// `SocialController` — a presentation-layer class — and resolved its
/// collection with `getBaseUrl('Employees_Info')`, a literal that also appears
/// (correctly, as a constant) in `EmployeeCollectionPaths.main`. Reusing that
/// constant is the §15 fix; both resolve to `Demo/{companyId}/Employees_Info`.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/main_controller/data/utils/employee_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se2_social/data/models/social_history_writer.dart';

class SocialRemoteDataSource {
  SocialRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Function Name: [updateSocialFields]
  ///
  /// Purpose: Append one social revision to the employee's profile document.
  ///
  /// Parameters:
  /// - [employeeId]: the Employees_Info document id.
  /// - [fields]: `BuildSocialUpdate` output — field → new revision value, for
  ///   the changed social fields only.
  ///
  /// Uses `update`, not `set(merge: true)`: the document is expected to exist,
  /// and a missing one should surface as an error rather than silently create a
  /// half-populated employee record.
  ///
  /// Throws [StateError] when the employee document is missing (the
  /// repository turns it into a `Failure`).
  Future<void> updateSocialFields({
    required String employeeId,
    required Map<String, dynamic> fields,
  }) async {
    final DocumentReference<Map<String, dynamic>> employeeRef =
        _firestore.collection(EmployeeCollectionPaths.main).doc(employeeId);

    // CHANGED 9/10/2026 — read, append one revision, write what changed.
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await employeeRef.get();
    final Map<String, dynamic>? stored = snapshot.data();
    if (!snapshot.exists || stored == null) {
      throw StateError('Employee document not found for id $employeeId');
    }

    final Map<String, dynamic> write =
        SocialHistoryWriter.buildWrite(stored: stored, changes: fields);
    if (write.isEmpty) return;

    await employeeRef.update(write);
  }
}
