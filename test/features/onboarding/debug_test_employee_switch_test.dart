/// Module: test / onboarding
///
///*************************** FILE INFO ****************************///
/// File Name: debug_test_employee_switch_test.dart
/// Purpose: DEBUG-ONLY 9/10/2026 — proves the "Switch to test employee"
///          sign-in is (1) off in release / profile builds (guard with
///          injected flags), (2) limited to test-domain accounts of the chosen
///          company and never the company admin, (3) still subject to the
///          normal account checks (activation, status, Users_Access window)
///          without any password, and (4) that the picker list carries no
///          credential.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 - DEBUG-ONLY
///
/// The repository runs against an in-memory fake of `DemoRemoteDataSource`
/// (injected through the 9/10/2026 constructor seam); no Firebase is touched.

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/data_source/remote_data_source/demo_remote_data_source.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/models/debug_test_employee.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/repository/demo_login_repository.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/failure_authentication_type.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

const String kCid = 'DM-003';
const String kAdmin = 'owner.contact@dm003.test'; // a .test admin: still refused

Timestamp _ts(DateTime d) => Timestamp.fromDate(d);

Map<String, dynamic> _sv(List<dynamic> values) => <String, dynamic>{
      'Values': values,
      'Timestamps': <Timestamp>[_ts(DateTime(2026, 1, 1))],
    };

/// A valid `Demo_Requests/{cid}` document. Deliberately WITHOUT a
/// `Temporary_Password`: the debug path must never need one.
Map<String, dynamic> _company({String admin = kAdmin, int seats = 50}) {
  final DateTime now = DateTime.now();
  return <String, dynamic>{
    'Request_Id': kCid,
    'Request_Status': 'approved',
    'Answers': <String>[],
    'Company_Information': <String, dynamic>{
      'Company_Name': _sv(<String>['Test Company']),
      'Company_Address': _sv(<String>['Cairo']),
      'Tax_Number': _sv(<String>['1']),
      'Country': _sv(<String>['Egypt']),
      'City': _sv(<String>['Cairo']),
      'Province': _sv(<String>['Cairo']),
      'Zip_Code': _sv(<String>['11511']),
      'Company_Industry': _sv(<String>['healthcare']),
      'Company_Size': _sv(<String>['fiveToTen']),
    },
    'Demo_Details': <String, dynamic>{
      'Number_Of_Users': _sv(<int>[seats]),
      'Access_Begin': _sv(<Timestamp>[_ts(now.subtract(const Duration(days: 10)))]),
      'Access_End': _sv(<Timestamp>[_ts(now.add(const Duration(days: 30)))]),
      'Updated_By': _sv(<String>['system']),
      'Response_Time': _ts(DateTime(2026, 1, 2)),
    },
    'Contact_Information': <String, dynamic>{
      'First_Name': _sv(<String>['Owner']),
      'Last_Name': _sv(<String>['Contact']),
      'Email': _sv(<String>[admin]),
      'Phone': <String, dynamic>{
        'Phone_Number': <String>['1000000000'],
        'Country_Code': <String>['+20'],
        'Timestamps': <Timestamp>[_ts(DateTime(2026, 1, 1))],
      },
      'Approval_Date': _ts(DateTime(2026, 1, 2)),
    },
  };
}

Map<String, dynamic> _account(String email,
        {String companyId = kCid, bool activated = true}) =>
    <String, dynamic>{
      'Email': email,
      'Company_Id': companyId,
      'Is_Activated': activated,
      'Demo_Granted': null,
      'Demo_Activated': null,
    };

/// A raw `Employees_Info` document. Carries credential fields on purpose, to
/// prove the picker strips them and the switch never compares them.
Map<String, dynamic> _employee(
  String id,
  String email, {
  String first = 'Omar',
  String last = 'Farouk',
  String role = 'Employee',
  String status = 'active',
  String departmentId = '101',
}) =>
    <String, dynamic>{
      'Id': id,
      'timestamps': <int>[1],
      'Email': <String>[email],
      'First_Name': <String>[first],
      'Last_Name': <String>[last],
      'First_Name_In_Arabic': <String>['عمر'],
      'Last_Name_In_Arabic': <String>['فاروق'],
      'Role': <String>[role],
      'Status': <String>[status],
      'Department_Id': <String>[departmentId],
      'Password': 'stored-secret-never-compared',
      'Default_Password': 'stored-default-never-compared',
    };

/// In-memory stand-in for the Firestore reads the repository makes.
class _FakeRemote implements DemoRemoteDataSource {
  final Map<String, Map<String, dynamic>> accounts =
      <String, Map<String, dynamic>>{};
  final Map<String, Map<String, dynamic>> companies =
      <String, Map<String, dynamic>>{};
  final Map<String, List<Map<String, dynamic>>> employees =
      <String, List<Map<String, dynamic>>>{};

  /// `Users_Access/{employeeId}` records (absent = no date window).
  final Map<String, Map<String, dynamic>> access =
      <String, Map<String, dynamic>>{};
  final List<String> calls = <String>[];

  @override
  Future<Either<Failure, dynamic>> getDemoAccountOverview(
      {required String email}) async {
    calls.add('account:$email');
    return Right<Failure, dynamic>(accounts[email]);
  }

  @override
  Future<Either<Failure, dynamic>> getCompanyDemoRequest(
      {required String companyId}) async {
    calls.add('company:$companyId');
    return Right<Failure, dynamic>(companies[companyId]);
  }

  @override
  Future<Either<Failure, dynamic>> getCompanyActualNumberOfUsers(
      {required String companyId}) async {
    calls.add('seats:$companyId');
    return Right<Failure, dynamic>((employees[companyId] ?? <dynamic>[]).length);
  }

  @override
  Future<Either<Failure, dynamic>> getEmployeeAccount(
      {required String email}) async {
    calls.add('employee:$email');
    final String cid = ApiConstants.baseUri.split('/').last;
    return Right<Failure, dynamic>((employees[cid] ?? <Map<String, dynamic>>[])
        .where((Map<String, dynamic> e) =>
            (e['Email'] as List<dynamic>).contains(email))
        .toList());
  }

  @override
  Future<Either<Failure, dynamic>> getEmployeePermission(
      {required String employeeId}) async {
    calls.add('access:$employeeId');
    return Right<Failure, dynamic>(access[employeeId]);
  }

  @override
  Future<Either<Failure, dynamic>> debugGetCompanyEmployees(
      {required String companyId}) async {
    calls.add('list:$companyId');
    return Right<Failure, dynamic>(employees[companyId] ?? <dynamic>[]);
  }

  @override
  Future<Either<Failure, dynamic>> debugGetCompanyDepartments(
      {required String companyId}) async {
    return const Right<Failure, dynamic>(<Map<String, dynamic>>[
      <String, dynamic>{
        'Department_ID': '101',
        'Department_Name': 'Administrative Affairs',
        'Department_Name_In_Arabic': 'الشؤون الإدارية',
      },
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('isDebugTestEmployeeSwitchEnabled (injected flags)', () {
    test('false in a RELEASE build', () {
      expect(
          isDebugTestEmployeeSwitchEnabled(
              debugMode: false, releaseMode: true, profileMode: false),
          isFalse);
    });

    test('false in a PROFILE build', () {
      expect(
          isDebugTestEmployeeSwitchEnabled(
              debugMode: false, releaseMode: false, profileMode: true),
          isFalse);
    });

    test('false whenever release or profile is set, even with debug true', () {
      expect(
          isDebugTestEmployeeSwitchEnabled(
              debugMode: true, releaseMode: true, profileMode: false),
          isFalse);
      expect(
          isDebugTestEmployeeSwitchEnabled(
              debugMode: true, releaseMode: false, profileMode: true),
          isFalse);
      expect(
          isDebugTestEmployeeSwitchEnabled(
              debugMode: false, releaseMode: false, profileMode: false),
          isFalse);
    });

    test('true only in a DEBUG build', () {
      expect(
          isDebugTestEmployeeSwitchEnabled(
              debugMode: true, releaseMode: false, profileMode: false),
          isTrue);
    });

    test('the compile-time entry-point constant matches the framework flags',
        () {
      expect(kDebugTestEmployeeSwitchBuild,
          kDebugMode && !kReleaseMode && !kProfileMode);
      expect(kDebugTestEmployeeSwitchBuild, isDebugTestEmployeeSwitchEnabled());
    });

    test('a disabled guard refuses every account and never starts a session',
        () {
      expect(
          debugTestEmployeeRefusal(
              email: 'omar.farouk@dm003.test',
              selectedCompanyId: kCid,
              enabled: false),
          DebugSwitchRefusal.disabled);
      DebugTestEmployeeSession.end();
      DebugTestEmployeeSession.start('omar.farouk@dm003.test', enabled: false);
      expect(DebugTestEmployeeSession.isActive, isFalse);
    });
  });

  group('isDebugTestEmail', () {
    test('accepts the configured .test domain, any case', () {
      expect(kDebugTestEmailDomains, <String>['.test']);
      expect(isDebugTestEmail('omar.farouk@dm003.test'), isTrue);
      expect(isDebugTestEmail('  Mona.Elsayed@DM003.TEST '), isTrue);
    });

    test('rejects real and look-alike addresses', () {
      expect(isDebugTestEmail('bayanatz@knowticed.com'), isFalse);
      expect(isDebugTestEmail('admin.test@company.com'), isFalse);
      expect(isDebugTestEmail('someone@test.com'), isFalse);
      expect(isDebugTestEmail('someone@dm003.testing'), isFalse);
      expect(isDebugTestEmail('dm003.test'), isFalse);
      expect(isDebugTestEmail(''), isFalse);
    });

    test('honours a custom list (suffix, domain, @domain)', () {
      expect(isDebugTestEmail('a@qa.example.com', domains: <String>['qa.example.com']),
          isTrue);
      expect(isDebugTestEmail('a@x.qa.example.com', domains: <String>['@qa.example.com']),
          isTrue);
      expect(isDebugTestEmail('a@example.com', domains: <String>['qa.example.com']),
          isFalse);
    });
  });

  group('debugTestEmployeeRefusal', () {
    test('allows a test employee of the chosen company', () {
      expect(
          debugTestEmployeeRefusal(
            email: 'omar.farouk@dm003.test',
            selectedCompanyId: kCid,
            accountCompanyId: 'dm-003',
            companyAdminEmail: kAdmin,
            isActivated: true,
            enabled: true,
          ),
          isNull);
    });

    test('refuses a non-test email', () {
      expect(
          debugTestEmployeeRefusal(
              email: 'bayanatz@knowticed.com',
              selectedCompanyId: kCid,
              enabled: true),
          DebugSwitchRefusal.notTestEmail);
    });

    test('refuses the company admin even on a test domain', () {
      expect(
          debugTestEmployeeRefusal(
              email: kAdmin.toUpperCase(),
              selectedCompanyId: kCid,
              companyAdminEmail: kAdmin,
              enabled: true),
          DebugSwitchRefusal.companyAdmin);
    });

    test('refuses an account of another company', () {
      expect(
          debugTestEmployeeRefusal(
              email: 'omar.farouk@dm003.test',
              selectedCompanyId: kCid,
              accountCompanyId: 'DM-009',
              enabled: true),
          DebugSwitchRefusal.otherCompany);
    });

    test('a not-activated TEST account is allowed (debug only)', () {
      expect(
          debugTestEmployeeRefusal(
              email: 'omar.farouk@dm003.test',
              selectedCompanyId: kCid,
              accountCompanyId: kCid,
              companyAdminEmail: kAdmin,
              isActivated: false,
              enabled: true),
          isNull);
      // …but never outside a debug build.
      expect(
          debugTestEmployeeRefusal(
              email: 'omar.farouk@dm003.test',
              selectedCompanyId: kCid,
              isActivated: false,
              enabled: false),
          DebugSwitchRefusal.disabled);
    });

    test('a not-activated NON-test account is still refused', () {
      expect(
          debugTestEmployeeRefusal(
              email: 'new.hire@company.com',
              selectedCompanyId: kCid,
              accountCompanyId: kCid,
              isActivated: false,
              enabled: true),
          isNotNull);
      // With a custom allow-list that does not cover the address, the
      // activation rule itself refuses it.
      expect(
          debugTestEmployeeRefusal(
              email: 'new.hire@company.com',
              selectedCompanyId: kCid,
              isActivated: false,
              enabled: true,
              domains: const <String>['.test']),
          DebugSwitchRefusal.notTestEmail);
    });
  });

  group('DebugTestEmployeeSession', () {
    tearDown(DebugTestEmployeeSession.end);

    test('start (debug) shows the badge flag, end clears it', () {
      DebugTestEmployeeSession.start('  Omar.Farouk@DM003.test', enabled: true);
      expect(DebugTestEmployeeSession.activeEmail.value, 'omar.farouk@dm003.test');
      expect(DebugTestEmployeeSession.isActive, isTrue);
      DebugTestEmployeeSession.end();
      expect(DebugTestEmployeeSession.isActive, isFalse);
    });
  });

  group('DebugTestEmployee', () {
    test('falls back between languages and to the email', () {
      const DebugTestEmployee e = DebugTestEmployee(
        email: 'x@dm003.test',
        nameEn: '',
        nameAr: 'سلمى فتحي',
        role: 'Employee',
        departmentEn: 'Citizen Services',
        departmentAr: '',
        status: 'active',
      );
      expect(e.name(arabic: false), 'سلمى فتحي');
      expect(e.department(arabic: true), 'Citizen Services');
      expect(e.isActive, isTrue);
      const DebugTestEmployee noName = DebugTestEmployee(
        email: 'y@dm003.test',
        nameEn: '',
        nameAr: '',
        role: '',
        departmentEn: '',
        departmentAr: '',
        status: 'locked',
      );
      expect(noName.name(arabic: true), 'y@dm003.test');
      expect(noName.isActive, isFalse);
    });
  });

  group('DemoLoginRepository debug switch (fake data source)', () {
    // `_checkEmployeePermission` parses Users_Access dates with
    // DateFormat(..., 'en'); the test VM has no locale data until this runs.
    setUpAll(() => initializeDateFormatting());

    late _FakeRemote remote;
    late DemoLoginRepository repository;
    const String previousBaseUri = 'Demo/PREVIOUS';

    setUp(() {
      ApiConstants.baseUri = previousBaseUri;
      remote = _FakeRemote();
      repository = DemoLoginRepository(remote: remote);
      remote.companies[kCid] = _company();
      remote.employees[kCid] = <Map<String, dynamic>>[
        _employee('e1', 'omar.farouk@dm003.test'),
        _employee('e2', 'mona.elsayed@dm003.test',
            first: 'Mona', last: 'Elsayed', role: 'HR Officer'),
        _employee('e3', 'salma.fathy@dm003.test',
            first: 'Salma', last: 'Fathy', status: 'locked'),
        _employee('e4', kAdmin, first: 'Owner', last: 'Contact',
            role: 'Master Admin'),
        _employee('e5', 'bayanatz@knowticed.com',
            first: 'Bayanatz', last: 'Owner', role: 'Master Admin'),
        _employee('e6', 'nourhan.mostafa@dm003.test',
            first: 'Nourhan', last: 'Mostafa'),
      ];
      remote.accounts['omar.farouk@dm003.test'] =
          _account('omar.farouk@dm003.test');
      remote.accounts['mona.elsayed@dm003.test'] =
          _account('mona.elsayed@dm003.test');
      remote.accounts['salma.fathy@dm003.test'] =
          _account('salma.fathy@dm003.test');
      remote.accounts['nourhan.mostafa@dm003.test'] =
          _account('nourhan.mostafa@dm003.test', activated: false);
      remote.accounts[kAdmin] = _account(kAdmin);
      remote.accounts['other.person@dm009.test'] =
          _account('other.person@dm009.test', companyId: 'DM-009');
    });

    tearDown(() => ApiConstants.baseUri = '');

    Future<Either<Object, NewEmployeeModelHistory>> signIn(String email) =>
        repository.debugSignInAsTestEmployee(companyId: kCid, email: email);

    test('signs in an active, activated test employee without any password',
        () async {
      final Either<Object, NewEmployeeModelHistory> result =
          await signIn('Omar.Farouk@dm003.test');
      expect(result.isRight(), isTrue, reason: '$result');
      final NewEmployeeModelHistory employee =
          result.getOrElse(() => NewEmployeeModelHistory());
      expect(employee.email.last, 'omar.farouk@dm003.test');
      expect(ApiConstants.baseUri, 'Demo/$kCid');
      // The normal checks all ran: account, company, seats, record, access.
      expect(
          remote.calls,
          containsAllInOrder(<String>[
            'account:omar.farouk@dm003.test',
            'company:$kCid',
            'seats:$kCid',
            'employee:omar.farouk@dm003.test',
            'access:e1',
          ]));
    });

    test('a non-test email is refused before anything is read', () async {
      final Either<Object, NewEmployeeModelHistory> result =
          await signIn('bayanatz@knowticed.com');
      final Object? left = result.fold((Object l) => l, (_) => null);
      expect(left, isA<DebugSwitchFailure>());
      expect((left! as DebugSwitchFailure).refusal,
          DebugSwitchRefusal.notTestEmail);
      expect(remote.calls, isEmpty);
      expect(ApiConstants.baseUri, previousBaseUri);
    });

    test('the company admin is refused even on a test domain', () async {
      final Object? left =
          (await signIn(kAdmin)).fold((Object l) => l, (_) => null);
      expect((left! as DebugSwitchFailure).refusal,
          DebugSwitchRefusal.companyAdmin);
      expect(ApiConstants.baseUri, previousBaseUri);
    });

    test('a not-activated TEST account signs in as activated, nothing written',
        () async {
      final Either<Object, NewEmployeeModelHistory> result =
          await signIn('nourhan.mostafa@dm003.test');
      expect(result.isRight(), isTrue, reason: '$result');
      // Every normal check still ran (record, Users_Access)…
      expect(remote.calls, contains('employee:nourhan.mostafa@dm003.test'));
      expect(remote.calls, contains('access:e6'));
      // …and nothing was written: the fake has only read methods (any write
      // would hit noSuchMethod and throw), and the flag is unchanged.
      expect(remote.accounts['nourhan.mostafa@dm003.test']!['Is_Activated'],
          isFalse);
    });

    test('a not-activated test account is still refused when locked',
        () async {
      remote.accounts['salma.fathy@dm003.test'] =
          _account('salma.fathy@dm003.test', activated: false);
      final Object? left = (await signIn('salma.fathy@dm003.test'))
          .fold((Object l) => l, (_) => null);
      expect((left! as DebugSwitchFailure).refusal,
          DebugSwitchRefusal.statusBlocked);
      expect(ApiConstants.baseUri, previousBaseUri);
    });

    test('an account of another company is refused (company named)', () async {
      final Object? left = (await signIn('other.person@dm009.test'))
          .fold((Object l) => l, (_) => null);
      final DebugSwitchFailure failure = left! as DebugSwitchFailure;
      expect(failure.refusal, DebugSwitchRefusal.otherCompany);
      expect(failure.detail, 'DM-009');
      expect(ApiConstants.baseUri, previousBaseUri);
    });

    test('a locked employee is refused with its status, nothing written',
        () async {
      final Object? left = (await signIn('salma.fathy@dm003.test'))
          .fold((Object l) => l, (_) => null);
      final DebugSwitchFailure failure = left! as DebugSwitchFailure;
      expect(failure.refusal, DebugSwitchRefusal.statusBlocked);
      expect(failure.detail, 'locked');
    });

    test('an expired Users_Access window gives the normal Access Denied',
        () async {
      remote.access['e2'] = <String, dynamic>{
        'From_Date': <String, dynamic>{
          'Values': <String>['Jan 01, 2025'],
        },
        'To_Date': <String, dynamic>{
          'Values': <String>['Jan 31, 2025'],
        },
      };
      final Object? left = (await signIn('mona.elsayed@dm003.test'))
          .fold((Object l) => l, (_) => null);
      expect(left, isA<Failure>());
      expect((left! as Failure).errMessage,
          FailureAuthenticationType.dontHavePermission.dialogBoxMessage);
      expect(ApiConstants.baseUri, previousBaseUri);
    });

    test('the seat limit of the normal sign-in still applies', () async {
      remote.companies[kCid] = _company(seats: 2);
      final Object? left = (await signIn('omar.farouk@dm003.test'))
          .fold((Object l) => l, (_) => null);
      expect((left! as Failure).errMessage,
          FailureAuthenticationType.tooManyUsers.dialogBoxMessage);
    });

    test('the picker lists test accounts only — no admin, no real email',
        () async {
      final Either<Failure, List<DebugTestEmployee>> result =
          await repository.debugListTestEmployees(companyId: kCid);
      final List<DebugTestEmployee> list =
          result.getOrElse(() => <DebugTestEmployee>[]);
      expect(list.map((DebugTestEmployee e) => e.email), <String>[
        'mona.elsayed@dm003.test',
        'nourhan.mostafa@dm003.test',
        'omar.farouk@dm003.test',
        'salma.fathy@dm003.test',
      ]);
      final DebugTestEmployee mona = list.first;
      expect(mona.name(arabic: false), 'Mona Elsayed');
      expect(mona.role, 'HR Officer');
      expect(mona.department(arabic: false), 'Administrative Affairs');
      expect(mona.department(arabic: true), 'الشؤون الإدارية');
      expect(list.last.status, 'locked');
      // Not activated is reported for the grey note, not filtered out.
      expect(list[1].email, 'nourhan.mostafa@dm003.test');
      expect(list[1].isActivated, isFalse);
      expect(mona.isActivated, isTrue);
      // The source documents were copied, not mutated.
      expect(remote.employees[kCid]!.first.containsKey('Password'), isTrue);
    });

    test('the picker refuses an unknown company', () async {
      final Either<Failure, List<DebugTestEmployee>> result =
          await repository.debugListTestEmployees(companyId: 'DM-404');
      expect(result.isLeft(), isTrue);
    });

    test('an unreadable company fails CLOSED (lists nobody, signs no one in)',
        () async {
      remote.companies[kCid] = <String, dynamic>{'Request_Id': kCid};
      final Either<Failure, List<DebugTestEmployee>> list =
          await repository.debugListTestEmployees(companyId: kCid);
      expect(list.isLeft(), isTrue);
      final Either<Object, NewEmployeeModelHistory> signedIn =
          await signIn('omar.farouk@dm003.test');
      expect(signedIn.isLeft(), isTrue);
      expect(ApiConstants.baseUri, previousBaseUri);
    });

    test('last-used company: signed-in → saved email → DM-003', () async {
      ApiConstants.baseUri = 'Demo/DM-005';
      expect(await repository.debugLastUsedCompanyId(), 'DM-005');
      ApiConstants.baseUri = '';
      expect(
          await repository.debugLastUsedCompanyId(
              savedEmail: 'other.person@dm009.test'),
          'DM-009');
      expect(await repository.debugLastUsedCompanyId(), kDebugDefaultTestCompanyId);
      expect(kDebugDefaultTestCompanyId, 'DM-003');
    });
  });
}
