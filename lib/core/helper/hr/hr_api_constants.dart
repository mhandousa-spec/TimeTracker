// ***************************** FILE INFO ***************************** //
// File Name: hr_api_constants.dart
// Purpose: Centralizes tenant-scoped Firestore paths owned by the HR module.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../network/api_constants.dart';
import '../../network/get_base_url.dart';

/// Defines the shared Firestore paths used by HR features.
abstract final class HrApiConstants {
  static const String hrModulePath = 'Modules/hr';
  static const String contactDetailsCollection = 'Employee Contact Details';
  static const String certificationsCollection = 'Employee Certifications';
  static const String insuranceDetailsCollection = 'Employee Insurance Details';
  static const String emergencyDetailsCollection = 'Employee Emergency Details';
  static const String attachmentsCollection = 'Employee Attachments';
  static const String shiftsCollection = 'Shifts';
  static const String shiftAssignmentsCollection = 'Shift_Assignments';
  static const String locationsCollection = 'Locations';

  static String get employeesInfoPath => getBaseUrl(ApiConstants.employeesInfo);

  /// Method Name: [tenantId]
  ///
  /// Purpose: Resolves the active company identifier from the tenant-scoped
  /// Firestore base path.
  ///
  /// Returns: The final non-empty segment of [ApiConstants.baseUri].
  static String get tenantId {
    final segments = ApiConstants.baseUri
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();
    return segments.isEmpty ? '' : segments.last;
  }

  static String get contactDetailsPath =>
      _hrCollectionPath(contactDetailsCollection);
  static String get certificationsPath =>
      _hrCollectionPath(certificationsCollection);
  static String get insuranceDetailsPath =>
      _hrCollectionPath(insuranceDetailsCollection);
  static String get emergencyDetailsPath =>
      _hrCollectionPath(emergencyDetailsCollection);
  static String get attachmentsPath => _hrCollectionPath(attachmentsCollection);
  static String get shiftsPath => _hrCollectionPath(shiftsCollection);
  static String get shiftAssignmentsPath =>
      _hrCollectionPath(shiftAssignmentsCollection);
  static String get locationsPath => _hrCollectionPath(locationsCollection);
  static String get collectionPath => shiftAssignmentsPath;
  static String get collectionName => shiftAssignmentsCollection;

  /// Method Name: [_hrCollectionPath]
  ///
  /// Purpose: Resolves an HR collection beneath the active tenant.
  ///
  /// Parameters:
  /// - [collection]: Collection name beneath the HR module path.
  ///
  /// Returns: A tenant-scoped Firestore collection path.
  static String _hrCollectionPath(String collection) =>
      getBaseUrl('$hrModulePath/$collection');
}

typedef HrEmployeeApiConstants = HrApiConstants;
typedef ShiftApiConstants = HrApiConstants;
typedef ShiftAssignmentApiConstants = HrApiConstants;
