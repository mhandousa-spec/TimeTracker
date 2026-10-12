/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: employee_branding_remote_data_source.dart
/// Purpose: Every Firestore call behind employee personal branding.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N01 / N19. `EmployeeBrandingRepository` held
/// `FirebaseFirestore.instance` itself and built its collection paths inline;
/// se4 and se5 already split this correctly and this brings se3 into line.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/se3_company/data/models/employee_branding_mapper.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/utils/company_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/entities/employee_branding_entity.dart';

class EmployeeBrandingRemoteDataSource {
  EmployeeBrandingRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Function Name: [hasAnyBranding]
  ///
  /// Purpose: Whether the Employee_Data collection has been seeded.
  Future<bool> hasAnyBranding() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection(CompanyCollectionPaths.employeeData)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Function Name: [readEmployeeIds]
  ///
  /// Purpose: The `ID` of every employee, for the one-time seeding pass.
  Future<List<String>> readEmployeeIds() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection(CompanyCollectionPaths.employeesInfo).get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            doc.data()['ID'] as String?)
        .whereType<String>()
        .where((String id) => id.isNotEmpty)
        .toList();
  }

  /// Function Name: [writeMany]
  ///
  /// Purpose: Seed the collection in one batch.
  Future<void> writeMany(List<EmployeeBrandingEntity> brandings) async {
    if (brandings.isEmpty) return;

    final WriteBatch batch = _db.batch();
    for (final EmployeeBrandingEntity branding in brandings) {
      batch.set(
        _db
            .collection(CompanyCollectionPaths.employeeData)
            .doc(branding.employeeId),
        EmployeeBrandingMapper.toMap(branding),
      );
    }
    await batch.commit();
  }

  /// Function Name: [read]
  ///
  /// Purpose: One employee's branding, or `null` when they have none.
  Future<EmployeeBrandingEntity?> read(String employeeId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection(CompanyCollectionPaths.employeeData)
        .doc(employeeId)
        .get();

    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return EmployeeBrandingMapper.fromMap(data);
  }

  /// Function Name: [write]
  ///
  /// Purpose: Create or merge-update one employee's branding.
  Future<void> write(EmployeeBrandingEntity branding) {
    return _db
        .collection(CompanyCollectionPaths.employeeData)
        .doc(branding.employeeId)
        .set(EmployeeBrandingMapper.toMap(branding), SetOptions(merge: true));
  }

  /// Function Name: [delete]
  ///
  /// Purpose: Drop an employee's override so they inherit the company's.
  Future<void> delete(String employeeId) {
    return _db
        .collection(CompanyCollectionPaths.employeeData)
        .doc(employeeId)
        .delete();
  }
}
