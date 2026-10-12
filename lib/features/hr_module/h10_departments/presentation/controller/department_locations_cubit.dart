// ***************************** FILE INFO ***************************** //
// File Name: department_locations_cubit.dart
// Purpose: Coordinates Department location submission state.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/helper/main_helper/current_user_context.dart';
import '../../data/models/department_location_model.dart';
import '../../data/repository/department_locations_repository.dart';
import '../../domain/entity/department_location_entity.dart';
import 'department_locations_state.dart';

/// Coordinates location creation for the Departments presentation layer.
class DepartmentLocationsCubit extends Cubit<DepartmentLocationsState> {
  DepartmentLocationsCubit({required DepartmentLocationsRepository repository})
      : _repository = repository,
        super(const DepartmentLocationsInitial());

  final DepartmentLocationsRepository _repository;

  /// Method Name: [loadLocations]
  ///
  /// Purpose: Loads the tenant's persisted locations for the Departments view.
  ///
  /// Returns: Completes after a loaded or error state is emitted.
  Future<void> loadLocations() async {
    final previousState = state;
    emit(
      DepartmentLocationsLoading(
        locations: previousState.locations,
        selectedLocationId: previousState.selectedLocationId,
        searchQuery: previousState.searchQuery,
      ),
    );

    final result = await _repository.getLocations();
    result.fold(
      (failure) => emit(
        DepartmentLocationsLoadError(
          message: failure.message,
          locations: previousState.locations,
          selectedLocationId: previousState.selectedLocationId,
          searchQuery: previousState.searchQuery,
        ),
      ),
      (locations) => emit(
        DepartmentLocationsLoaded(
          locations: locations,
          selectedLocationId: _selectedLocationId(
            locations,
            previousState.selectedLocationId,
          ),
          searchQuery: previousState.searchQuery,
        ),
      ),
    );
  }

  /// Method Name: [selectLocation]
  ///
  /// Purpose: Selects one loaded location for the overview panel.
  ///
  /// Parameters:
  /// - [locationId]: ID of the location selected by the user.
  void selectLocation(String locationId) {
    if (!state.locations.any((location) => location.id == locationId)) {
      return;
    }
    emit(
      DepartmentLocationsLoaded(
        locations: state.locations,
        selectedLocationId: locationId,
        searchQuery: state.searchQuery,
      ),
    );
  }

  /// Method Name: [updateSearchQuery]
  ///
  /// Purpose: Updates the local search query used by the locations view.
  ///
  /// Parameters:
  /// - [query]: Current search field text.
  void updateSearchQuery(String query) {
    emit(
      DepartmentLocationsLoaded(
        locations: state.locations,
        selectedLocationId: state.selectedLocationId,
        searchQuery: query,
      ),
    );
  }

  /// Method Name: [createLocation]
  ///
  /// Purpose: Builds and persists a location while exposing submission state.
  ///
  /// Parameters:
  /// - [nameEn]: English location name.
  /// - [nameAr]: Arabic location name.
  /// - [countryCode]: Selected ISO country code.
  ///
  /// Returns: True when persistence succeeds; otherwise false.
  Future<bool> createLocation({
    required String nameEn,
    required String nameAr,
    required String countryCode,
  }) async {
    final previousState = state;
    emit(
      DepartmentLocationSaving(
        locations: previousState.locations,
        selectedLocationId: previousState.selectedLocationId,
        searchQuery: previousState.searchQuery,
      ),
    );
    final editorId = CurrentUserContext.email?.trim();
    if (editorId == null || editorId.isEmpty) {
      emit(
        DepartmentLocationError(
          message: '',
          locations: previousState.locations,
          selectedLocationId: previousState.selectedLocationId,
          searchQuery: previousState.searchQuery,
        ),
      );
      return false;
    }
    final location = DepartmentLocationModel.create(
      nameEn: nameEn,
      nameAr: nameAr,
      countryCode: countryCode,
      editorId: editorId,
    );
    final result = await _repository.createLocation(location);
    return result.fold(
      (failure) {
        emit(
          DepartmentLocationError(
            message: failure.message,
            locations: previousState.locations,
            selectedLocationId: previousState.selectedLocationId,
            searchQuery: previousState.searchQuery,
          ),
        );
        return false;
      },
      (_) {
        emit(
          DepartmentLocationSuccess(
            locations: previousState.locations,
            selectedLocationId: previousState.selectedLocationId,
            searchQuery: previousState.searchQuery,
          ),
        );
        return true;
      },
    );
  }

  /// Method Name: [_selectedLocationId]
  ///
  /// Purpose: Preserves a valid selection or chooses the first loaded location.
  ///
  /// Parameters:
  /// - [locations]: Newly loaded locations.
  /// - [previousId]: Previously selected location ID.
  ///
  /// Returns: The selection to use for the loaded state.
  String? _selectedLocationId(
    List<DepartmentLocationEntity> locations,
    String? previousId,
  ) {
    if (previousId != null &&
        locations.any((location) => location.id == previousId)) {
      return previousId;
    }
    return locations.isEmpty ? null : locations.first.id;
  }
}
