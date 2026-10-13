/// Module: time_tracker / tt5_locations / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: locations_state.dart
/// Purpose: Declares `LocationsState` (+ `LocationsLoadStatus`,
///          `LocationsFilter`) — the company's locations, the employees
///          assigned to each, the search text and the filter of the
///          Locations tab.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// One immutable state + `copyWith` + status enum + derived getters
/// (playbook §3). Deleted locations (soft delete, A4) are never listed.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';

enum LocationsLoadStatus { initial, loading, loaded, failure }

/// What reading an import file gave: nothing (cancelled), a plan, or an
/// unreadable file.
class LocationImportRead {
  const LocationImportRead.cancelled()
      : plan = null,
        grid = null,
        unreadable = false;
  const LocationImportRead.read(LocationImportPlan this.plan, {this.grid}) : unreadable = false;
  const LocationImportRead.unreadable()
      : plan = null,
        grid = null,
        unreadable = true;

  final LocationImportPlan? plan;

  /// ADDED 13/10/2026 (owner): the file as read (first row = headings), for
  /// the bulk-upload review where each cell can be fixed.
  final List<List<String>>? grid;
  final bool unreadable;
}

/// The Locations filter popup: status and geofence (null = any).
class LocationsFilter {
  const LocationsFilter({this.status, this.geofence});

  final LocationStatus? status;
  final bool? geofence;

  static const LocationsFilter none = LocationsFilter();

  bool get isActive => status != null || geofence != null;
}

class LocationsState {
  const LocationsState({
    this.status = LocationsLoadStatus.initial,
    this.locations = const <WorkLocation>[],
    this.assignments = const <LocationAssignment>[],
    this.companyHasHr = false,
    this.query = '',
    this.filter = LocationsFilter.none,
    this.isGrid = true,
    this.failure = TimeTrackerActionFailure.none,
    this.errorMessage = '',
  });

  final LocationsLoadStatus status;

  /// Every stored location (deleted ones included — see [listed]).
  final List<WorkLocation> locations;
  final List<LocationAssignment> assignments;

  /// HR owns locations: every write is refused.
  final bool companyHasHr;
  final String query;
  final LocationsFilter filter;

  /// 13/10/2026 (owner): tablet List / Grid toggle (true = cards).
  final bool isGrid;
  final TimeTrackerActionFailure failure;
  final String errorMessage;

  /// Not deleted, by English name.
  List<WorkLocation> get listed => <WorkLocation>[
        for (final WorkLocation l in locations)
          if (l.status != LocationStatus.deleted) l,
      ]..sort((WorkLocation a, WorkLocation b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));

  /// [listed] narrowed by the search box and the filter.
  List<WorkLocation> get visible {
    final String q = query.trim().toLowerCase();
    return <WorkLocation>[
      for (final WorkLocation l in listed)
        if ((filter.status == null || l.status == filter.status) &&
            (filter.geofence == null || l.isGeofenceEnabled == filter.geofence) &&
            (q.isEmpty || '${l.nameEn} ${l.nameAr} ${l.city} ${l.country} ${l.state}'.toLowerCase().contains(q)))
          l,
    ];
  }

  /// The location with [id] (null when unknown).
  WorkLocation? byId(String id) {
    for (final WorkLocation l in locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// E-mails currently assigned to location [id].
  List<String> assignedTo(String id) => <String>[
        for (final LocationAssignment a in assignments)
          if (a.locationId == id) a.employeeEmail,
      ];

  bool get isLoading => status == LocationsLoadStatus.initial || status == LocationsLoadStatus.loading;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [LocationsState]
  LocationsState copyWith({
    LocationsLoadStatus? status,
    List<WorkLocation>? locations,
    List<LocationAssignment>? assignments,
    bool? companyHasHr,
    String? query,
    LocationsFilter? filter,
    bool? isGrid,
    TimeTrackerActionFailure? failure,
    String? errorMessage,
  }) =>
      LocationsState(
        status: status ?? this.status,
        locations: locations ?? this.locations,
        assignments: assignments ?? this.assignments,
        companyHasHr: companyHasHr ?? this.companyHasHr,
        query: query ?? this.query,
        filter: filter ?? this.filter,
        isGrid: isGrid ?? this.isGrid,
        failure: failure ?? this.failure,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
