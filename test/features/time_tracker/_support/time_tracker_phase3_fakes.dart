/// Module: test / time_tracker / _support
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_phase3_fakes.dart
/// Purpose: Phase-3 test doubles: an in-memory employee directory, a
///          resolver for a company WITH HR, and seeding helpers for request
///          types and groups.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:knowticed_plus/features/time_tracker/data/models/employee_group_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_type_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/hr_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/company_modules_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

import 'time_tracker_test_fakes.dart';

/// The company's employees, in memory.
class FakeDirectory implements EmployeeDirectoryBaseRepository {
  FakeDirectory([List<TimeTrackerEmployee>? people, this.departments, this.departmentsAr])
      : people = people ?? defaultPeople;

  final List<TimeTrackerEmployee> people;

  /// 9/10/2026 (UI pass): the departments to answer (null = Design / Sales).
  final Map<String, String>? departments;

  /// The Arabic names, answered for an Arabic UI (null = [departments]).
  final Map<String, String>? departmentsAr;

  /// Me (dep-1), a colleague (dep-1) and someone from another department.
  static const List<TimeTrackerEmployee> defaultPeople = <TimeTrackerEmployee>[
    TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1', departmentName: 'Design'),
    TimeTrackerEmployee(email: 'amr@co.com', nameEn: 'Amr M', departmentId: 'dep-1', departmentName: 'Design'),
    TimeTrackerEmployee(email: 'sara@co.com', nameEn: 'Sara A', departmentId: 'dep-2', departmentName: 'Sales'),
  ];

  @override
  Future<List<TimeTrackerEmployee>> fetchEmployees({required bool isArabic}) async => people;

  @override
  Future<Map<String, String>> fetchDepartments({required bool isArabic}) async =>
      (isArabic ? departmentsAr : null) ?? departments ?? <String, String>{'dep-1': 'Design', 'dep-2': 'Sales'};
}

/// A resolver for a company WITH HR.
WorkSetupSourceResolver hrResolver(FakeTimeTrackerRemote remote) => WorkSetupSourceResolver(
      companyModules: CompanyModulesService(
        dataSource: FakeCompanyModulesRemote(<String, Map<String, dynamic>>{
          'c': <String, dynamic>{
            'Modules': <String, dynamic>{'hr': true, 'time_tracker': true},
          },
        }),
        companyId: () => 'c',
      ),
      timeTrackerSource: TimeTrackerWorkSetupSource(remoteDataSource: remote),
      hrSource: HrWorkSetupSource(remoteDataSource: FakeHrRemote()),
    );

TimeTrackerAudit _audit() => TimeTrackerAudit.next(null, actor: 'hr@co.com', now: DateTime(2026, 10, 1));

/// Store [locations] (no assignments).
void seedLocations(FakeTimeTrackerRemote remote, List<WorkLocation> locations) {
  for (final WorkLocation l in locations) {
    remote.store.putIfAbsent(TimeTrackerFirestorePaths.locations, () => <String, Map<String, dynamic>>{})[l.id] =
        TimeTrackerHistoryCodec.append(
      old: null,
      values: WorkLocationModel.row(l, id: l.id, audit: _audit()),
      now: DateTime(2026, 10, 1),
    );
  }
}

/// Store [types].
void seedRequestTypes(FakeTimeTrackerRemote remote, List<RequestType> types) {
  for (final RequestType t in types) {
    remote.store.putIfAbsent(TimeTrackerFirestorePaths.requestTypes, () => <String, Map<String, dynamic>>{})[t.id] =
        TimeTrackerHistoryCodec.append(
      old: null,
      values: RequestTypeModel.row(t, id: t.id, audit: _audit()),
      now: DateTime(2026, 10, 1),
    );
  }
}

/// Store [groups].
void seedGroups(FakeTimeTrackerRemote remote, List<EmployeeGroup> groups) {
  for (final EmployeeGroup g in groups) {
    remote.store.putIfAbsent(TimeTrackerFirestorePaths.groups, () => <String, Map<String, dynamic>>{})[g.id] =
        TimeTrackerHistoryCodec.append(
      old: null,
      values: EmployeeGroupModel.row(g, id: g.id, audit: _audit()),
      now: DateTime(2026, 10, 1),
    );
  }
}

/// Upload stub: no real storage; counts group pictures.
class FakeGroupUploads implements AttachmentBaseRepository {
  int groupImages = 0;

  @override
  Future<RequestAttachment> uploadRequestAttachment({
    required String employeeEmail,
    required String fileName,
    required List<int> bytes,
  }) async =>
      RequestAttachment(name: fileName, url: 'https://x/$fileName', sizeBytes: bytes.length);

  @override
  Future<String> uploadGroupImage({
    required String uploaderEmail,
    required String fileName,
    required List<int> bytes,
  }) async {
    groupImages++;
    return 'https://x/$fileName';
  }
}
