// ***************************** FILE INFO ***************************** //
// File Name: shift_management_local_data.dart
// Purpose: Provides temporary local location and branch data.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../data/models/branch_model.dart';
import '../data/models/location_model.dart';

/// Provides temporary data until shift-management persistence is added.
abstract final class ShiftManagementLocalData {
  static const locations = <LocationModel>[
    LocationModel(id: 'egypt', nameEn: 'Egypt', nameAr: 'مصر'),
    LocationModel(
      id: 'saudi-arabia',
      nameEn: 'Saudi Arabia',
      nameAr: 'المملكة العربية السعودية',
    ),
    LocationModel(
      id: 'united-arab-emirates',
      nameEn: 'United Arab Emirates',
      nameAr: 'الإمارات العربية المتحدة',
    ),
  ];

  static const branches = <BranchModel>[
    BranchModel(
      id: 'nasr-city',
      nameEn: 'Nasr City',
      nameAr: 'مدينة نصر',
      locationId: 'egypt',
    ),
    BranchModel(
      id: 'malignity',
      nameEn: 'Malignity',
      nameAr: 'ماليجنيتي',
      locationId: 'egypt',
    ),
    BranchModel(
      id: 'rehab',
      nameEn: 'Rehab',
      nameAr: 'الرحاب',
      locationId: 'egypt',
    ),
    BranchModel(
      id: 'riyadh',
      nameEn: 'Riyadh',
      nameAr: 'الرياض',
      locationId: 'saudi-arabia',
    ),
    BranchModel(
      id: 'jeddah',
      nameEn: 'Jeddah',
      nameAr: 'جدة',
      locationId: 'saudi-arabia',
    ),
    BranchModel(
      id: 'dubai',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      locationId: 'united-arab-emirates',
    ),
    BranchModel(
      id: 'abu-dhabi',
      nameEn: 'Abu Dhabi',
      nameAr: 'أبو ظبي',
      locationId: 'united-arab-emirates',
    ),
  ];

  /// Method Name: [getLocations]
  ///
  /// Purpose: Returns all locations available to shift management.
  ///
  /// Returns: An immutable view of the local location response.
  static List<LocationModel> getLocations() => List.unmodifiable(locations);

  /// Method Name: [getBranches]
  ///
  /// Purpose: Returns all branches available to shift management.
  ///
  /// Returns: An immutable view of the local branch response.
  static List<BranchModel> getBranches() => List.unmodifiable(branches);

  /// Method Name: [getBranchesForLocation]
  ///
  /// Purpose: Resolves branches associated with a selected location.
  ///
  /// Parameters:
  /// - [locationId]: Location ID, or null for all locations.
  ///
  /// Returns: Branches belonging to the selected location.
  static List<BranchModel> getBranchesForLocation(String? locationId) {
    if (locationId == null) return getBranches();
    return List.unmodifiable(
      branches.where((branch) => branch.locationId == locationId),
    );
  }
}
