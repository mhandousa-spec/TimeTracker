/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: hr_work_setup_mapper.dart
/// Purpose: Declares `HrShift` and `HrWorkSetupMapper` — read-only parsing of
///          the HR module's `Shifts`, `Shift_Assignments` and `Locations`
///          documents into Time Tracker shapes.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// HR documents (h9_shift_management, 23/8/2026) use their OWN history shape:
/// `Shifts/{id}` = `Id`, `Location_Ids[]`, `Branch_Ids[]`, `Start_Minutes[]`,
/// `End_Minutes[]`, `Timestamps[]` (capital T), `Editor[]`;
/// `Shift_Assignments/{employeeId}` = `Id`, `Employee_Id`, `Shift_Id[]`, … .
/// The current value is the last list entry, which `TimeTrackerHistoryCodec.
/// lastOf` reads for both lists and scalars. This file does NOT import the HR
/// feature (its models import GetX); it only knows the field names.
///
/// HR locations are still hard-coded in the HR module today (no Firestore
/// documents), so a shift's location id that has no `Locations` document
/// becomes a name-only location with no geofence — flagged for Rashidy.

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

typedef _F = TimeTrackerFieldCodec;

/// The current values of one HR shift.
class HrShift {
  const HrShift({
    required this.id,
    required this.locationId,
    required this.startMinutes,
    required this.endMinutes,
  });

  final String id;
  final String locationId;
  final int startMinutes;
  final int endMinutes;
}

class HrWorkSetupMapper {
  const HrWorkSetupMapper._();

  static const String fId = 'Id';
  static const String fLocationIds = 'Location_Ids';
  static const String fStartMinutes = 'Start_Minutes';
  static const String fEndMinutes = 'End_Minutes';
  static const String fEmployeeId = 'Employee_Id';
  static const String fShiftId = 'Shift_Id';

  /// Function Name: [shiftFrom]
  ///
  /// Purpose: The current values of one `Shifts` document.
  ///
  /// Return type: [HrShift]
  static HrShift shiftFrom(TimeTrackerDocument doc) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(doc.data, key);
    final String id = _F.string(now(fId));
    return HrShift(
      id: id.isNotEmpty ? id : doc.id,
      locationId: _F.string(now(fLocationIds)),
      startMinutes: _F.integer(now(fStartMinutes)),
      endMinutes: _F.integer(now(fEndMinutes)),
    );
  }

  /// Function Name: [shiftIdOf]
  ///
  /// Purpose: The current shift id of one `Shift_Assignments` document.
  ///
  /// Return type: [String] — '' when unassigned.
  static String shiftIdOf(TimeTrackerDocument assignment) =>
      _F.string(TimeTrackerHistoryCodec.lastOf(assignment.data, fShiftId));

  /// Function Name: [locationFrom]
  ///
  /// Purpose: One HR `Locations` document as a `WorkLocation`. Accepts both
  /// the house names (`Name_En` / `Name_Ar`) and a plain `Name`.
  ///
  /// Return type: [WorkLocation]
  static WorkLocation locationFrom(TimeTrackerDocument doc) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(doc.data, key);
    final String nameEn = _F.string(now('Name_En'));
    return WorkLocation(
      id: doc.id,
      nameEn: nameEn.isNotEmpty ? nameEn : _F.string(now('Name')),
      nameAr: _F.string(now('Name_Ar')),
      latitude: _F.nullableDecimal(now('Latitude')),
      longitude: _F.nullableDecimal(now('Longitude')),
      isGeofenceEnabled: _F.boolean(now('Is_Geofence_Enabled')),
      geofenceRadiusMeters: _F.decimal(now('Geofence_Radius_Meters')),
    );
  }

  /// Function Name: [locationsFrom]
  ///
  /// Purpose: Every HR location: the `Locations` documents, plus a name-only
  /// entry for each shift location id that has no document yet.
  ///
  /// Parameters:
  ///   [List<TimeTrackerDocument>] locationDocs
  ///   [List<HrShift>] shifts
  ///
  /// Return type: [List<WorkLocation>]
  static List<WorkLocation> locationsFrom(
    List<TimeTrackerDocument> locationDocs,
    List<HrShift> shifts,
  ) {
    final Map<String, WorkLocation> byId = <String, WorkLocation>{
      for (final TimeTrackerDocument d in locationDocs) d.id: locationFrom(d),
    };
    for (final HrShift shift in shifts) {
      if (shift.locationId.isEmpty) continue;
      byId.putIfAbsent(
        shift.locationId,
        () => WorkLocation(id: shift.locationId, nameEn: shift.locationId),
      );
    }
    return List<WorkLocation>.unmodifiable(byId.values);
  }
}
