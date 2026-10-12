/// Module: test / time_tracker / _support
///
///*************************** FILE INFO ****************************///
/// File Name: tt_demo_seed.dart
/// Purpose: The DM-003 company of the owner's tests (Bayanatz + the six
///          `@dm003.test` employees, two departments, org-chart managers,
///          HR / manager roles) and [seedTtDemo] — the REAL debug demo-data
///          service (`TimeTrackerDemoService.load`) run over the in-memory
///          remote, so the UI-pass renders show exactly what the 🧪 button
///          writes on the device.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass)
///
/// Salma's name / job title are stored in lower case on purpose (the
/// Active Directory upload bug) — every screen must still show them in
/// proper case.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_sections_enum.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/role_approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';

import 'time_tracker_phase3_fakes.dart';
import 'time_tracker_phase4_fakes.dart';
import 'time_tracker_test_fakes.dart';
import 'time_tracker_widget_harness.dart';

const String kTtOwner = 'bayanatz@knowticed.com';

const Map<String, String> kTtDepartments = <String, String>{
  '101': 'Administrative Affairs',
  '102': 'Citizen Services',
};

/// `Departments/{id}.Department_Name_In_Arabic` (QA KP-TT-017).
const Map<String, String> kTtDepartmentsAr = <String, String>{
  '101': 'الشؤون الإدارية',
  '102': 'خدمات المواطنين',
};

const List<TimeTrackerEmployee> kTtPeople = <TimeTrackerEmployee>[
  TimeTrackerEmployee(
    email: kTtOwner,
    nameEn: 'Bayanatz Transformation',
    nameAr: 'بيانات للتحول الرقمي',
    jobTitleEn: 'Project Manager',
    jobTitleAr: 'مدير المشروع',
    role: 'Master Admin',
  ),
  TimeTrackerEmployee(
    email: 'khaled.abdelrahman@dm003.test',
    nameEn: 'Khaled Abdelrahman',
    nameAr: 'خالد عبدالرحمن',
    jobTitleEn: 'Director of Administrative Affairs',
    jobTitleAr: 'مدير الشؤون الإدارية',
    departmentId: '101',
    departmentName: 'Administrative Affairs',
    departmentNameEn: 'Administrative Affairs',
    departmentNameAr: 'الشؤون الإدارية',
    phone: '+20 1000001001',
    role: 'Department Manager',
  ),
  TimeTrackerEmployee(
    email: 'mona.elsayed@dm003.test',
    nameEn: 'Mona Elsayed',
    nameAr: 'منى السيد',
    jobTitleEn: 'Human Resources Officer',
    jobTitleAr: 'مسؤولة الموارد البشرية',
    departmentId: '101',
    departmentName: 'Administrative Affairs',
    departmentNameEn: 'Administrative Affairs',
    departmentNameAr: 'الشؤون الإدارية',
    phone: '+20 1000001002',
    role: 'HR Officer',
  ),
  TimeTrackerEmployee(
    email: 'omar.farouk@dm003.test',
    nameEn: 'Omar Farouk',
    nameAr: 'عمر فاروق',
    jobTitleEn: 'Administrative Specialist',
    jobTitleAr: 'أخصائي شؤون إدارية',
    departmentId: '101',
    departmentName: 'Administrative Affairs',
    departmentNameEn: 'Administrative Affairs',
    departmentNameAr: 'الشؤون الإدارية',
    phone: '+20 1000001003',
    role: 'Employee',
  ),
  TimeTrackerEmployee(
    email: 'nourhan.mostafa@dm003.test',
    nameEn: 'Nourhan Mostafa',
    nameAr: 'نورهان مصطفى',
    jobTitleEn: 'Records and Archives Officer',
    jobTitleAr: 'مسؤولة السجلات والأرشيف',
    departmentId: '101',
    departmentName: 'Administrative Affairs',
    departmentNameEn: 'Administrative Affairs',
    departmentNameAr: 'الشؤون الإدارية',
    phone: '+20 1000001004',
    role: 'Employee',
  ),
  TimeTrackerEmployee(
    email: 'youssef.ibrahim@dm003.test',
    nameEn: 'Youssef Ibrahim',
    nameAr: 'يوسف إبراهيم',
    jobTitleEn: 'Citizen Services Officer',
    jobTitleAr: 'موظف خدمة المواطنين',
    departmentId: '102',
    departmentName: 'Citizen Services',
    departmentNameEn: 'Citizen Services',
    departmentNameAr: 'خدمات المواطنين',
    phone: '+20 1000001005',
    role: 'Employee',
  ),
  TimeTrackerEmployee(
    email: 'salma.fathy@dm003.test',
    // Stored in lower case on purpose (Active Directory upload bug).
    nameEn: 'salma fathy',
    nameAr: 'سلمى فتحي',
    jobTitleEn: 'service center coordinator',
    jobTitleAr: 'منسقة مركز الخدمات',
    departmentId: '102',
    departmentName: 'citizen services',
    departmentNameEn: 'citizen services',
    departmentNameAr: 'خدمات المواطنين',
    phone: '+20 1000001006',
    role: 'Employee',
  ),
];

/// Org chart: Khaled reports to the owner, everyone else to Khaled.
const Map<String, String> kTtManagers = <String, String>{
  'khaled.abdelrahman@dm003.test': kTtOwner,
  'mona.elsayed@dm003.test': 'khaled.abdelrahman@dm003.test',
  'omar.farouk@dm003.test': 'khaled.abdelrahman@dm003.test',
  'nourhan.mostafa@dm003.test': 'khaled.abdelrahman@dm003.test',
  'youssef.ibrahim@dm003.test': 'khaled.abdelrahman@dm003.test',
  'salma.fathy@dm003.test': 'khaled.abdelrahman@dm003.test',
};

List<(TimeTrackerRoleRecord, Map<String, dynamic>)> get kTtRoles => <(TimeTrackerRoleRecord, Map<String, dynamic>)>[
      FakeRoleSource.approverRole('HR Officer', name: 'HR Officer'),
      FakeRoleSource.approverRole('Department Manager', name: 'Department Manager', all: false),
    ];

/// The owner with every Time Tracker switch on and a full identity.
TimeTrackerAccess ttOwnerAccess() {
  final Set<String> on = allKeys();
  return TimeTrackerAccess(
    reader: (TimeTrackerPermissionsSections section, TimeTrackerPermissions? permission) =>
        on.contains(permission?.storageKey ?? section.storageKey),
    identity: () => const TimeTrackerIdentity(
      email: kTtOwner,
      employeeId: 'emp-1',
      nameEn: 'Bayanatz Transformation',
      nameAr: 'بيانات للتحول الرقمي',
      jobTitleEn: 'Project Manager',
      jobTitleAr: 'مدير المشروع',
      departmentName: '',
    ),
  );
}

/// A harness for the owner over the DM-003 company.
TimeTrackerHarness ttDemoHarness() => TimeTrackerHarness(
      people: kTtPeople,
      departments: kTtDepartments,
      departmentsAr: kTtDepartmentsAr,
      access: ttOwnerAccess(),
      email: kTtOwner,
      manager: '',
      roles: kTtRoles,
    );

class _Managers implements ManagerResolver {
  @override
  Future<String> managerEmailOf({required String employeeEmail, String employeeId = ''}) async =>
      kTtManagers[employeeEmail.trim().toLowerCase()] ?? '';
}

/// Uploads nothing: the attachment keeps a readable fake URL.
class _Uploads implements AttachmentBaseRepository {
  int count = 0;

  @override
  Future<RequestAttachment> uploadRequestAttachment({
    required String employeeEmail,
    required String fileName,
    required List<int> bytes,
  }) async {
    count++;
    return RequestAttachment(
      name: fileName,
      url: 'https://storage.example/demo/$count.pdf',
      sizeBytes: bytes.length,
      uploadedAt: DateTime.now(),
    );
  }

  @override
  Future<String> uploadGroupImage({
    required String uploaderEmail,
    required String fileName,
    required List<int> bytes,
  }) async =>
      'https://storage.example/$fileName';
}

/// The real demo service over [h]'s in-memory remote.
TimeTrackerDemoService ttDemoService(TimeTrackerHarness h, {Future<ByteData> Function(String)? loadAsset}) {
  final FakeDirectory directory = FakeDirectory(kTtPeople, kTtDepartments, kTtDepartmentsAr);
  return TimeTrackerDemoService(
    remote: h.remote,
    directory: directory,
    managers: _Managers(),
    approvers: RoleApproverDirectory(
      roles: FakeRoleSource(kTtRoles),
      directory: directory,
      requests: RequestRepositoryImpl(remoteDataSource: h.remote, access: h.access),
      readsCompanyRequests: () => true,
    ),
    resolver: h.resolver,
    attachments: _Uploads(),
    access: h.access,
    loadAsset: loadAsset,
  );
}

/// Function Name: [seedTtDemo]
///
/// Purpose: Load the demo data into [h] (call before `h.pump`).
///
/// Return type: [Future<TtDemoResult>]
Future<TtDemoResult> seedTtDemo(WidgetTester tester, TimeTrackerHarness h, {bool isArabic = false}) async {
  TtDemoResult? result;
  await tester.runAsync(() async {
    result = await ttDemoService(h).load(isArabic: isArabic);
  });
  return result!;
}
