/// Module: test / time_tracker / _support
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_test_fakes.dart
/// Purpose: Shared test doubles for the Time Tracker module: a switchable
///          permission reader / `TimeTrackerAccess` builder, an in-memory
///          `TimeTrackerRemoteDataSource` (same history append as the real
///          one), and in-memory HR / licence data sources — no Firebase, no
///          GetX controllers.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'dart:async';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_sections_enum.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/company_modules_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/hr_work_setup_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/hr_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/company_modules_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/manager_resolver.dart';

/// Every section master key ON.
Set<String> allSectionKeys() => <String>{
      for (final TimeTrackerPermissionsSections s
          in TimeTrackerPermissionsSections.values)
        s.storageKey,
    };

/// Every key (masters + children) ON.
Set<String> allKeys() => <String>{
      ...allSectionKeys(),
      for (final TimeTrackerPermissions p in TimeTrackerPermissions.values)
        p.storageKey,
    };

/// A [TimeTrackerAccess] whose switches are exactly [on] (storage keys).
TimeTrackerAccess accessWith(
  Set<String> on, {
  String email = 'me@co.com',
  String departmentId = 'dep-1',
  String employeeId = 'emp-1',
}) =>
    TimeTrackerAccess(
      reader: (TimeTrackerPermissionsSections section,
              TimeTrackerPermissions? permission) =>
          on.contains(permission?.storageKey ?? section.storageKey),
      identity: () => TimeTrackerIdentity(
        email: email,
        employeeId: employeeId,
        departmentId: departmentId,
      ),
    );

/// In-memory [TimeTrackerRemoteDataSource]: path -> id -> data.
class FakeTimeTrackerRemote implements TimeTrackerRemoteDataSource {
  final Map<String, Map<String, Map<String, dynamic>>> store =
      <String, Map<String, Map<String, dynamic>>>{};

  /// Paths of every `appendRow` call, in order.
  final List<String> writes = <String>[];
  int ensureCalls = 0;
  int _autoId = 0;

  /// When set, every call throws it.
  Object? failWith;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  Map<String, Map<String, dynamic>> _col(String path) =>
      store.putIfAbsent(path, () => <String, Map<String, dynamic>>{});

  List<TimeTrackerDocument> _docs(String path, {String prefix = ''}) {
    final List<String> ids = _col(path).keys.where((String id) => id.startsWith(prefix)).toList()
      ..sort();
    return <TimeTrackerDocument>[
      for (final String id in ids)
        TimeTrackerDocument(id: id, data: _col(path)[id]!),
    ];
  }

  void _maybeFail() {
    final Object? error = failWith;
    if (error != null) throw error;
  }

  @override
  Future<void> ensureModuleDocument() async {
    ensureCalls++;
  }

  @override
  Stream<List<TimeTrackerDocument>> watchCollection(String relativePath) {
    _maybeFail();
    collectionReads.add(relativePath);
    return _watch(() => _docs(relativePath));
  }

  @override
  Stream<List<TimeTrackerDocument>> watchIdPrefix(
    String relativePath,
    String prefix,
  ) {
    _maybeFail();
    return _watch(() => _docs(relativePath, prefix: prefix));
  }

  // A controller, not `async*` (8/10/2026): cancelling an `async*` stream
  // parked at `await for` only completes at the NEXT event, so a cubit's
  // `close()` (which awaits its subscription's cancel) hung forever.
  Stream<List<TimeTrackerDocument>> _watch(
    List<TimeTrackerDocument> Function() read,
  ) {
    StreamSubscription<void>? changes;
    late final StreamController<List<TimeTrackerDocument>> out;
    out = StreamController<List<TimeTrackerDocument>>(
      onListen: () {
        out.add(read());
        changes = _changes.stream.listen((_) => out.add(read()));
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  // 9/10/2026 (code review finding 9): array-contains on a history list.
  @override
  Stream<List<TimeTrackerDocument>> watchArrayContains(
    String relativePath,
    String field,
    Object value,
  ) {
    _maybeFail();
    arrayQueries.add('$relativePath.$field=$value');
    return _watch(() => <TimeTrackerDocument>[
          for (final TimeTrackerDocument d in _docs(relativePath))
            if (TimeTrackerHistoryCodec.historyOf(d.data, field).contains(value)) d,
        ]);
  }

  /// Every `watchArrayContains` call (`path.field=value`), in order.
  final List<String> arrayQueries = <String>[];

  /// Every `watchCollection` path, in order (9/10/2026 — company-wide reads).
  final List<String> collectionReads = <String>[];

  /// Called inside `appendRows` before the builders run (9/10/2026): a test
  /// can change the store here to simulate a concurrent write.
  void Function()? beforeTransaction;

  @override
  Future<List<TimeTrackerDocument>> fetchCollection(String relativePath) async {
    _maybeFail();
    return _docs(relativePath);
  }

  @override
  Future<TimeTrackerDocument?> fetchDocument(
    String relativePath,
    String id,
  ) async {
    _maybeFail();
    final Map<String, dynamic>? data = _col(relativePath)[id];
    return data == null ? null : TimeTrackerDocument(id: id, data: data);
  }

  @override
  Future<TimeTrackerDocument> appendRow({
    required String relativePath,
    required String? id,
    required bool mustExist,
    required HistoryRowBuilder row,
  }) async {
    _maybeFail();
    await ensureModuleDocument();
    beforeTransaction?.call();
    final String docId = id ?? 'auto-${++_autoId}';
    final Map<String, dynamic>? old = _col(relativePath)[docId];
    if (mustExist && old == null) {
      throw StateError('This record no longer exists.');
    }
    final Map<String, dynamic> data = TimeTrackerHistoryCodec.append(
      old: old,
      values: row(docId, old),
      now: DateTime.now(),
    );
    _col(relativePath)[docId] = data;
    writes.add(relativePath);
    _changes.add(null);
    return TimeTrackerDocument(id: docId, data: data);
  }

  // 9/10/2026 (code review findings 2 + 3): all-or-nothing, like the real
  // transaction — every builder runs first, nothing is stored if one throws.
  @override
  Future<List<TimeTrackerDocument?>> appendRows(List<HistoryRowWrite> writes) async {
    _maybeFail();
    await ensureModuleDocument();
    beforeTransaction?.call();
    final List<String> ids = <String>[
      for (final HistoryRowWrite w in writes) w.id ?? 'auto-${++_autoId}',
    ];
    final List<TimeTrackerDocument?> out = <TimeTrackerDocument?>[];
    for (int i = 0; i < writes.length; i++) {
      final Map<String, dynamic>? old = _col(writes[i].relativePath)[ids[i]];
      if (writes[i].mustExist && old == null) {
        throw StateError('This record no longer exists.');
      }
      final Map<String, Object?>? values = writes[i].row(ids[i], old);
      out.add(values == null
          ? null
          : TimeTrackerDocument(
              id: ids[i],
              data: TimeTrackerHistoryCodec.append(old: old, values: values, now: DateTime.now()),
            ));
    }
    for (int i = 0; i < writes.length; i++) {
      final TimeTrackerDocument? doc = out[i];
      if (doc == null) continue;
      _col(writes[i].relativePath)[ids[i]] = doc.data;
      this.writes.add(writes[i].relativePath);
    }
    _changes.add(null);
    return out;
  }

  @override
  Future<bool> createIfAbsent({
    required String relativePath,
    required String id,
    required HistoryRowBuilder row,
  }) async {
    _maybeFail();
    await ensureModuleDocument();
    if (_col(relativePath).containsKey(id)) return false;
    _col(relativePath)[id] = TimeTrackerHistoryCodec.append(
      old: null,
      values: row(id, null),
      now: DateTime.now(),
    );
    writes.add(relativePath);
    _changes.add(null);
    return true;
  }

  // 9/10/2026 (debug demo data tool).
  @override
  Future<List<TimeTrackerDocument>> fetchArrayContains(
    String relativePath,
    String field,
    Object value,
  ) async {
    _maybeFail();
    return <TimeTrackerDocument>[
      for (final TimeTrackerDocument d in _docs(relativePath))
        if (TimeTrackerHistoryCodec.historyOf(d.data, field).contains(value)) d,
    ];
  }

  @override
  Future<void> deleteDocument(String relativePath, String id) async {
    _maybeFail();
    _col(relativePath).remove(id);
    _changes.add(null);
  }
}

/// In-memory licence documents keyed by company id.
class FakeCompanyModulesRemote implements CompanyModulesRemoteDataSource {
  FakeCompanyModulesRemote(this.licences);

  final Map<String, Map<String, dynamic>> licences;
  int reads = 0;
  Object? failWith;

  @override
  Future<Map<String, dynamic>?> fetchLicence(String companyId) async {
    reads++;
    final Object? error = failWith;
    if (error != null) throw error;
    return licences[companyId];
  }
}

/// In-memory HR collections.
class FakeHrRemote implements HrWorkSetupRemoteDataSource {
  final Map<String, Map<String, dynamic>> shifts = <String, Map<String, dynamic>>{};
  final Map<String, Map<String, dynamic>> assignments =
      <String, Map<String, dynamic>>{};
  final Map<String, Map<String, dynamic>> locations =
      <String, Map<String, dynamic>>{};

  List<TimeTrackerDocument> _all(Map<String, Map<String, dynamic>> m) =>
      <TimeTrackerDocument>[
        for (final MapEntry<String, Map<String, dynamic>> e in m.entries)
          TimeTrackerDocument(id: e.key, data: e.value),
      ];

  TimeTrackerDocument? _one(Map<String, Map<String, dynamic>> m, String id) =>
      m[id] == null ? null : TimeTrackerDocument(id: id, data: m[id]!);

  @override
  Future<List<TimeTrackerDocument>> fetchShifts() async => _all(shifts);

  @override
  Future<TimeTrackerDocument?> fetchShift(String shiftId) async =>
      _one(shifts, shiftId);

  @override
  Future<TimeTrackerDocument?> fetchShiftAssignment(String employeeId) async =>
      _one(assignments, employeeId);

  @override
  Future<List<TimeTrackerDocument>> fetchLocations() async => _all(locations);

  @override
  Future<TimeTrackerDocument?> fetchLocation(String locationId) async =>
      _one(locations, locationId);
}

/// Records System Log actions instead of calling the GetX controller.
class FakeLog extends TimeTrackerLogService {
  FakeLog();

  final List<String> actions = <String>[];

  @override
  void log(String action) => actions.add(action);
}

/// A fixed direct manager ('' = none).
class FakeManagerResolver implements ManagerResolver {
  FakeManagerResolver([this.manager = '']);

  String manager;
  int calls = 0;

  @override
  Future<String> managerEmailOf({
    required String employeeEmail,
    String employeeId = '',
  }) async {
    calls++;
    return manager;
  }
}

/// A scripted device position.
class FakeLocationReader implements DeviceLocationReader {
  FakeLocationReader(this.result);

  DeviceLocationResult result;
  int reads = 0;

  @override
  Future<DeviceLocationResult> currentPosition() async {
    reads++;
    return result;
  }
}

/// A resolver for a company WITHOUT HR over [remote] (phase 2).
WorkSetupSourceResolver noHrResolver(FakeTimeTrackerRemote remote) =>
    WorkSetupSourceResolver(
      companyModules: CompanyModulesService(
        dataSource: FakeCompanyModulesRemote(<String, Map<String, dynamic>>{
          'c': <String, dynamic>{
            'Modules': <String, dynamic>{'hr': false, 'time_tracker': true},
          },
        }),
        companyId: () => 'c',
      ),
      timeTrackerSource: TimeTrackerWorkSetupSource(remoteDataSource: remote),
      hrSource: HrWorkSetupSource(remoteDataSource: FakeHrRemote()),
    );

/// Store [location] and assign [email] to it (no-HR company set-up).
void seedAssignment(
  FakeTimeTrackerRemote remote, {
  required WorkLocation location,
  String email = 'me@co.com',
  AttendanceRules rules = const AttendanceRules(),
  DateTime? startDate,
  List<WorkLocation> others = const <WorkLocation>[],
}) {
  final TimeTrackerAudit audit =
      TimeTrackerAudit.next(null, actor: 'hr@co.com', now: DateTime(2026));
  for (final WorkLocation l in <WorkLocation>[location, ...others]) {
    remote.store.putIfAbsent(TimeTrackerFirestorePaths.locations, () => <String, Map<String, dynamic>>{})[l.id] =
        TimeTrackerHistoryCodec.append(
      old: null,
      values: WorkLocationModel.row(l, id: l.id, audit: audit),
      now: DateTime(2026),
    );
  }
  remote.store.putIfAbsent(
    TimeTrackerFirestorePaths.locationAssignments,
    () => <String, Map<String, dynamic>>{},
  )[email] = TimeTrackerHistoryCodec.append(
    old: null,
    values: LocationAssignmentModel.row(
      LocationAssignment(
        employeeEmail: email,
        locationId: location.id,
        startDate: startDate,
        rules: rules,
      ),
      id: email,
      audit: audit,
    ),
    now: DateTime(2026),
  );
}
