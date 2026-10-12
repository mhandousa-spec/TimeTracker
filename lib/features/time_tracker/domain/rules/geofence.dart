/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: geofence.dart
/// Purpose: Declares `GeoPoint`, `Geofence` (haversine distance + circle
///          check) and `CheckInGate` (may this check-in go ahead?).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 5 (8/10/2026): geofence = a circle (radius in meters)
/// around the location; a check-in at the wrong place is BLOCKED unless the
/// employee works Remote (Client Site is treated the same way: away from any
/// company location, so no geofence). Working anywhere but the assigned
/// location needs [CheckInGate.evaluate]'s `mayWorkElsewhere` — the caller
/// combines the `Work_From_Different_Location` switch with the assignment's
/// `Is_Different_Location_Allowed`.

import 'dart:math' as math;

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';

/// A latitude / longitude pair in degrees.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class Geofence {
  const Geofence._();

  /// Mean Earth radius used by the haversine formula.
  static const double earthRadiusMeters = 6371008.8;

  /// Function Name: [distanceMeters]
  ///
  /// Purpose: Great-circle distance between [a] and [b] (haversine).
  ///
  /// Parameters:
  ///   [GeoPoint] a
  ///   [GeoPoint] b
  ///
  /// Return type: [double] — meters.
  static double distanceMeters(GeoPoint a, GeoPoint b) {
    final double dLat = _rad(b.latitude - a.latitude);
    final double dLon = _rad(b.longitude - a.longitude);
    final double sinLat = math.sin(dLat / 2);
    final double sinLon = math.sin(dLon / 2);
    final double h = sinLat * sinLat +
        math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) * sinLon * sinLon;
    return 2 * earthRadiusMeters * math.asin(math.min(1.0, math.sqrt(h)));
  }

  /// Function Name: [contains]
  ///
  /// Purpose: Whether [point] is inside the circle of [radiusMeters] around
  /// [center] (the edge counts as inside). A non-positive radius contains
  /// nothing (fail-closed).
  ///
  /// Parameters:
  ///   [GeoPoint] center
  ///   [double] radiusMeters
  ///   [GeoPoint] point
  ///
  /// Return type: [bool]
  static bool contains({
    required GeoPoint center,
    required double radiusMeters,
    required GeoPoint point,
  }) =>
      radiusMeters > 0 && distanceMeters(center, point) <= radiusMeters;

  static double _rad(double degrees) => degrees * math.pi / 180;
}

/// The answer of [CheckInGate.evaluate].
enum CheckInDecision {
  /// Go ahead.
  allowed,

  /// The device is outside the location's geofence ("Wrong Location").
  wrongLocation,

  /// The geofence is on but no device position is available.
  positionRequired,

  /// The chosen location is not the employee's, nor one they may use.
  locationNotAllowed,

  /// Remote / client site chosen without permission to work elsewhere.
  differentLocationNotAllowed,
}

class CheckInGate {
  const CheckInGate._();

  /// Function Name: [evaluate]
  ///
  /// Purpose: Decide whether a check-in may go ahead.
  ///
  /// Parameters:
  ///   [WorkLocationType] type: office / remote / client site.
  ///   [WorkLocation?] chosen: the location picked (office only).
  ///   [String] assignedLocationId: the employee's own location ('' = none).
  ///   [List<String>] allowedLocationIds: other locations they may use.
  ///   [bool] mayWorkElsewhere: switch + assignment allow other places.
  ///   [GeoPoint?] position: the device position, if known.
  ///
  /// Return type: [CheckInDecision]
  static CheckInDecision evaluate({
    required WorkLocationType type,
    required WorkLocation? chosen,
    required String assignedLocationId,
    required List<String> allowedLocationIds,
    required bool mayWorkElsewhere,
    required GeoPoint? position,
  }) {
    if (type.isAwayFromCompanyLocation) {
      return mayWorkElsewhere
          ? CheckInDecision.allowed
          : CheckInDecision.differentLocationNotAllowed;
    }
    if (chosen == null || !chosen.isActive) {
      return CheckInDecision.locationNotAllowed;
    }
    final bool isOwn =
        assignedLocationId.isNotEmpty && chosen.id == assignedLocationId;
    final bool isAllowedOther =
        mayWorkElsewhere && allowedLocationIds.contains(chosen.id);
    if (!isOwn && !isAllowedOther) return CheckInDecision.locationNotAllowed;
    if (!chosen.isGeofenceEnabled || !chosen.hasCoordinates) {
      return CheckInDecision.allowed;
    }
    if (position == null) return CheckInDecision.positionRequired;
    final bool inside = Geofence.contains(
      center: GeoPoint(chosen.latitude!, chosen.longitude!),
      radiusMeters: chosen.geofenceRadiusMeters,
      point: position,
    );
    return inside ? CheckInDecision.allowed : CheckInDecision.wrongLocation;
  }
}
