/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: geofence_test.dart
/// Purpose: Unit tests for `Geofence` (haversine distance, circle check) and
///          `CheckInGate` (wrong location blocks unless remote; allowed other
///          locations; geofence needs a position).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';

void main() {
  group('Geofence.distanceMeters', () {
    test('one degree of latitude is ~111.2 km', () {
      final double d = Geofence.distanceMeters(
        const GeoPoint(30, 31),
        const GeoPoint(31, 31),
      );
      expect(d, closeTo(111195, 5));
    });

    test('same point is 0; the formula is symmetric', () {
      const GeoPoint cairo = GeoPoint(30.0444, 31.2357);
      const GeoPoint giza = GeoPoint(29.9792, 31.1342);
      expect(Geofence.distanceMeters(cairo, cairo), 0);
      expect(
        Geofence.distanceMeters(cairo, giza),
        closeTo(Geofence.distanceMeters(giza, cairo), 1e-6),
      );
      expect(Geofence.distanceMeters(cairo, giza), closeTo(12000, 600));
    });
  });

  group('Geofence.contains', () {
    const GeoPoint center = GeoPoint(30, 31);
    // ~111.2 m north of the center.
    const GeoPoint north = GeoPoint(30.001, 31);

    test('inside, on the edge and outside', () {
      expect(Geofence.contains(center: center, radiusMeters: 200, point: north), isTrue);
      final double edge = Geofence.distanceMeters(center, north);
      expect(Geofence.contains(center: center, radiusMeters: edge, point: north), isTrue);
      expect(Geofence.contains(center: center, radiusMeters: 100, point: north), isFalse);
    });

    test('a non-positive radius contains nothing', () {
      expect(Geofence.contains(center: center, radiusMeters: 0, point: center), isFalse);
    });
  });

  group('CheckInGate.evaluate', () {
    const WorkLocation office = WorkLocation(
      id: 'hq',
      nameEn: 'Main Office',
      latitude: 30,
      longitude: 31,
      isGeofenceEnabled: true,
      geofenceRadiusMeters: 500,
    );
    const WorkLocation branch = WorkLocation(id: 'b2', nameEn: 'Branch 2');

    CheckInDecision run({
      WorkLocationType type = WorkLocationType.office,
      WorkLocation? chosen = office,
      String assigned = 'hq',
      List<String> allowed = const <String>[],
      bool elsewhere = false,
      GeoPoint? position = const GeoPoint(30.001, 31),
    }) =>
        CheckInGate.evaluate(
          type: type,
          chosen: chosen,
          assignedLocationId: assigned,
          allowedLocationIds: allowed,
          mayWorkElsewhere: elsewhere,
          position: position,
        );

    test('own location inside the geofence is allowed', () {
      expect(run(), CheckInDecision.allowed);
    });

    test('outside the geofence is the "Wrong Location" block', () {
      expect(run(position: const GeoPoint(30.1, 31)), CheckInDecision.wrongLocation);
    });

    test('geofence on but no position', () {
      expect(run(position: null), CheckInDecision.positionRequired);
    });

    test('remote / client site skip the geofence but need permission', () {
      expect(run(type: WorkLocationType.remote, position: null),
          CheckInDecision.differentLocationNotAllowed);
      expect(run(type: WorkLocationType.remote, elsewhere: true, position: null),
          CheckInDecision.allowed);
      expect(run(type: WorkLocationType.clientSite, elsewhere: true),
          CheckInDecision.allowed);
    });

    test('another location needs permission AND to be in the allowed list', () {
      expect(run(chosen: branch), CheckInDecision.locationNotAllowed);
      expect(run(chosen: branch, elsewhere: true), CheckInDecision.locationNotAllowed);
      expect(
        run(chosen: branch, elsewhere: true, allowed: <String>['b2']),
        CheckInDecision.allowed,
      );
    });

    test('no assignment, no location or an inactive one is refused', () {
      expect(run(assigned: ''), CheckInDecision.locationNotAllowed);
      expect(run(chosen: null), CheckInDecision.locationNotAllowed);
      expect(
        run(chosen: office.copyWith(status: LocationStatus.inactive)),
        CheckInDecision.locationNotAllowed,
      );
    });

    test('geofence off → allowed without a position', () {
      expect(
        run(chosen: office.copyWith(isGeofenceEnabled: false), position: null),
        CheckInDecision.allowed,
      );
    });
  });
}
