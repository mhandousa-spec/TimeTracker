/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: phase3_data_test.dart
/// Purpose: Data-layer tests of phase 3: the location model's Arabic twins
///          (round trip; older documents without them), the import sheet
///          reader (CSV with BOM / CRLF / quoted commas) and the group
///          service gates.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/local_data_source/time_tracker_sheet_reader.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/group_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_assignment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/group_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

import '../_support/time_tracker_test_fakes.dart';

void main() {
  group('WorkLocationModel (phase 3)', () {
    test('Country / State / City dropdown codes round-trip (no Arabic twins)', () {
      const WorkLocation l = WorkLocation(
        id: 'hq',
        nameEn: 'HQ',
        nameAr: 'المقر',
        country: 'EG',
        state: 'C',
        city: 'Nasr City',
      );
      final Map<String, dynamic> doc = TimeTrackerHistoryCodec.append(
        old: null,
        values: WorkLocationModel.row(l, id: 'hq',
            audit: TimeTrackerAudit.next(null, actor: 'hr@co.com', now: DateTime(2026))),
        now: DateTime(2026),
      );
      expect(doc.containsKey('Country_Code'), isTrue);
      expect(doc.containsKey('Country_Ar'), isFalse);
      final WorkLocation back = WorkLocationModel.fromMap('hq', doc);
      expect(back.country, 'EG');
      expect(back.state, 'C');
      expect(back.city, 'Nasr City');
      expect(back.name(isArabic: true), 'المقر');
    });

    test('an older document without the address reads it as empty', () {
      final WorkLocation back = WorkLocationModel.fromMap('x', <String, dynamic>{
        'Name_En': <String>['Old'],
        'timestamps': <int>[1],
      });
      expect(back.country, '');
      expect(back.name(isArabic: true), 'Old');
    });
  });

  test('sheet reader: CSV with BOM, CRLF and a quoted comma', () {
    final Uint8List bytes = Uint8List.fromList(
      utf8.encode('﻿Location Name,City\r\n"Branch, 2",Giza\r\nHQ,القاهرة\r\n'),
    );
    final List<List<String>> grid = TimeTrackerSheetReader.read(bytes, 'locations.csv');
    expect(grid.first, <String>['Location Name', 'City']);
    expect(grid[1], <String>['Branch, 2', 'Giza']);
    expect(grid[2][1], 'القاهرة');
  });

  group('GroupService gates', () {
    GroupService service(TimeTrackerAccess access, FakeTimeTrackerRemote r) => GroupService(
          groups: GroupRepositoryImpl(remoteDataSource: r, access: access),
          assignments: LocationAssignmentRepositoryImpl(remoteDataSource: r, access: access),
          access: access,
          log: FakeLog(),
        );
    const EmployeeGroup g = EmployeeGroup(id: 'g', name: 'Ops');

    test('Edit_Group / Delete_Group OFF and HR present are refused', () async {
      final FakeTimeTrackerRemote r = FakeTimeTrackerRemote();
      final GroupService noEdit = service(accessWith(allKeys()..removeAll(<String>{'Edit_Group', 'Delete_Group'})), r);
      await expectLater(noEdit.update(g, before: g, stored: const <LocationAssignment>[], companyHasHr: false),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      await expectLater(noEdit.delete(g, stored: const <LocationAssignment>[], companyHasHr: false),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      final GroupService all = service(accessWith(allKeys()), r);
      await expectLater(all.create(g, stored: const <LocationAssignment>[], companyHasHr: true),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      expect(r.writes, isEmpty);
    });
  });
}
