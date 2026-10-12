// ***************************** FILE INFO ***************************** //
// File Name: department_locations_state.dart
// Purpose: Defines Departments location loading and submission states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import '../../domain/entity/department_location_entity.dart';

/// Base state for the Departments location list and create flow.
sealed class DepartmentLocationsState {
  const DepartmentLocationsState({
    required this.locations,
    required this.selectedLocationId,
    required this.searchQuery,
  });

  final List<DepartmentLocationEntity> locations;
  final String? selectedLocationId;
  final String searchQuery;

  /// Method Name: [filteredLocations]
  ///
  /// Purpose: Applies the current search text to loaded location values.
  ///
  /// Returns: Locations matching the English name, Arabic name, or country.
  List<DepartmentLocationEntity> get filteredLocations {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return locations;

    return locations
        .where(
          (location) =>
              location.nameEn.toLowerCase().contains(query) ||
              location.nameAr.toLowerCase().contains(query) ||
              location.countryCode.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  /// Method Name: [selectedLocation]
  ///
  /// Purpose: Resolves the selected location from the loaded collection.
  ///
  /// Returns: The selected location, or null when none is selected.
  DepartmentLocationEntity? get selectedLocation {
    final selectedId = selectedLocationId;
    if (selectedId == null) return null;

    for (final location in locations) {
      if (location.id == selectedId) return location;
    }
    return null;
  }
}

/// State before Departments location loading begins.
final class DepartmentLocationsInitial extends DepartmentLocationsState {
  const DepartmentLocationsInitial()
      : super(
          locations: const [],
          selectedLocationId: null,
          searchQuery: '',
        );
}

/// State emitted while the location collection is loading.
final class DepartmentLocationsLoading extends DepartmentLocationsState {
  const DepartmentLocationsLoading({
    required super.locations,
    required super.selectedLocationId,
    required super.searchQuery,
  });
}

/// State containing loaded locations and the current selection.
final class DepartmentLocationsLoaded extends DepartmentLocationsState {
  const DepartmentLocationsLoaded({
    required super.locations,
    required super.selectedLocationId,
    required super.searchQuery,
  });
}

/// State containing the last available locations and a loading error.
final class DepartmentLocationsLoadError extends DepartmentLocationsState {
  const DepartmentLocationsLoadError({
    required this.message,
    required super.locations,
    required super.selectedLocationId,
    required super.searchQuery,
  });

  final String message;
}

/// State emitted while a location is being written to Firestore.
final class DepartmentLocationSaving extends DepartmentLocationsState {
  const DepartmentLocationSaving({
    required super.locations,
    required super.selectedLocationId,
    required super.searchQuery,
  });
}

/// State emitted after a location is persisted successfully.
final class DepartmentLocationSuccess extends DepartmentLocationsState {
  const DepartmentLocationSuccess({
    required super.locations,
    required super.selectedLocationId,
    required super.searchQuery,
  });
}

/// State containing a location persistence failure.
final class DepartmentLocationError extends DepartmentLocationsState {
  const DepartmentLocationError({
    required this.message,
    required super.locations,
    required super.selectedLocationId,
    required super.searchQuery,
  });

  final String message;
}
