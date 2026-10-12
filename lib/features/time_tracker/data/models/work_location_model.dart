/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: work_location_model.dart
/// Purpose: Declares `WorkLocationModel` — Firestore <-> `WorkLocation`
///          mapping for one Time Tracker-owned `Locations/{id}` history
///          document (no-HR companies).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Field names are FINAL SPEC §2 verbatim (+ `Created_By` / `Modified_By`).
/// `Work_Start_Time` / `Work_End_Time` are minutes since midnight;
/// `Working_Days` entries are wrapped `{Values: [1..7]}`.
/// Updated: 8/10/2026 - `Late_After_Minutes` (grace period, owner decision
/// 22; missing on older documents → 0).
/// Updated: 9/10/2026 - approved schema: `Allowed_Break_Minutes` (old
/// `Break_Minutes` still read) and `Allowed_Pause_Minutes` (0 = no limit).
/// Updated: 9/10/2026 - phase 3: `Country_Ar` / `State_Ar` / `City_Ar` (the
/// Arabic twins on the Figma form; missing → '').

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

typedef _F = TimeTrackerFieldCodec;

class WorkLocationModel {
  const WorkLocationModel._();

  static const String fLocationId = 'Location_Id';
  static const String fNameEn = 'Name_En';
  static const String fNameAr = 'Name_Ar';
  static const String fGoogleMapsUrl = 'Google_Maps_Url';
  static const String fLatitude = 'Latitude';
  static const String fLongitude = 'Longitude';
  static const String fIsGeofence = 'Is_Geofence_Enabled';
  static const String fGeofenceRadius = 'Geofence_Radius_Meters';
  // 9/10/2026 — dropdown values (owner): ISO-2 country code, state code,
  // English city name. The Arabic twin fields were removed.
  static const String fCountry = 'Country_Code';
  static const String fState = 'State_Code';
  static const String fCity = 'City_Name';
  static const String fPostalCode = 'Postal_Code';
  static const String fWorkStart = 'Work_Start_Time';
  static const String fWorkEnd = 'Work_End_Time';
  static const String fWorkingDays = 'Working_Days';
  static const String fLateAfterMinutes = 'Late_After_Minutes';
  static const String fIsBreakAllowed = 'Is_Break_Allowed';
  /// Approved schema name (9/10/2026); `Break_Minutes` is still READ for
  /// documents written before ([fLegacyBreakMinutes]).
  static const String fBreakMinutes = 'Allowed_Break_Minutes';
  static const String fLegacyBreakMinutes = 'Break_Minutes';
  static const String fIsPauseAllowed = 'Is_Pause_Allowed';

  /// ADDED 9/10/2026 (approved schema): the longest pause (0 = no limit).
  static const String fPauseMinutes = 'Allowed_Pause_Minutes';
  static const String fStatus = 'Location_Status';

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  ///
  /// Return type: [WorkLocation]
  static WorkLocation fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    final List<int> days = _F.ints(now(fWorkingDays));
    return WorkLocation(
      id: id.isNotEmpty ? id : _F.string(now(fLocationId)),
      nameEn: _F.string(now(fNameEn)),
      nameAr: _F.string(now(fNameAr)),
      googleMapsUrl: _F.string(now(fGoogleMapsUrl)),
      latitude: _F.nullableDecimal(now(fLatitude)),
      longitude: _F.nullableDecimal(now(fLongitude)),
      isGeofenceEnabled: _F.boolean(now(fIsGeofence)),
      geofenceRadiusMeters: _F.decimal(now(fGeofenceRadius)),
      country: _F.string(now(fCountry)),
      state: _F.string(now(fState)),
      city: _F.string(now(fCity)),
      postalCode: _F.string(now(fPostalCode)),
      workStartMinutes: _F.integer(now(fWorkStart), fallback: 9 * 60),
      workEndMinutes: _F.integer(now(fWorkEnd), fallback: 17 * 60),
      workingDays: days.isEmpty ? WorkSchedule.allDays : days,
      lateAfterMinutes: _F.integer(now(fLateAfterMinutes)),
      isBreakAllowed: _F.boolean(now(fIsBreakAllowed)),
      breakMinutes: _F.integer(now(fBreakMinutes) ?? now(fLegacyBreakMinutes)),
      isPauseAllowed: _F.boolean(now(fIsPauseAllowed)),
      pauseMinutes: _F.integer(now(fPauseMinutes)),
      status: LocationStatus.fromStorageKey(_F.string(now(fStatus))),
      audit: _F.auditOf(map),
    );
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    WorkLocation location, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fLocationId: id,
        fNameEn: location.nameEn.trim(),
        fNameAr: location.nameAr.trim(),
        fGoogleMapsUrl: location.googleMapsUrl.trim(),
        fLatitude: location.latitude,
        fLongitude: location.longitude,
        fIsGeofence: location.isGeofenceEnabled,
        fGeofenceRadius: location.geofenceRadiusMeters,
        fCountry: location.country.trim(),
        fState: location.state.trim(),
        fCity: location.city.trim(),
        fPostalCode: location.postalCode.trim(),
        fWorkStart: location.workStartMinutes,
        fWorkEnd: location.workEndMinutes,
        fWorkingDays: _F.wrap(List<Object?>.of(location.workingDays)),
        fLateAfterMinutes:
            location.lateAfterMinutes < 0 ? 0 : location.lateAfterMinutes,
        fIsBreakAllowed: location.isBreakAllowed,
        fBreakMinutes: location.isBreakAllowed ? location.breakMinutes : 0,
        fIsPauseAllowed: location.isPauseAllowed,
        fPauseMinutes: location.isPauseAllowed && location.pauseMinutes > 0 ? location.pauseMinutes : 0,
        fStatus: location.status.storageKey,
        ...audit.fields,
      };
}
