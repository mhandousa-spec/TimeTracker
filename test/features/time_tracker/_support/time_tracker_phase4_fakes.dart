/// Module: test / time_tracker / _support
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_phase4_fakes.dart
/// Purpose: Phase-4 test doubles: a recording notification service, an
///          in-memory role reader (for the real `RoleApproverDirectory`),
///          request / balance seeding, and `Phase4Kit` — the Request /
///          Approval services wired over the in-memory remote for one
///          signed-in user.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
/// Updated: 9/10/2026 - data model: [seedBalance] writes the per-year
/// `{email}_{year}` document; `Phase4Kit.comments` (the Comments
/// sub-collection repository) is passed to `RequestService`.

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_notification_pages.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/vacation_balance_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_comment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_type_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/role_approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/approval_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_effects.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';

import 'time_tracker_phase3_fakes.dart';
import 'time_tracker_test_fakes.dart';

/// One recorded notification.
class SentNotification {
  const SentNotification(this.event, this.page, this.receiver, this.requestId, this.variables, this.sender);

  final TimeTrackerNotificationEvent event;
  final TimeTrackerNotificationPage page;
  final String receiver;
  final String requestId;
  final Map<TemplateVariable, String> variables;
  final String sender;
}

/// Records every send instead of calling `AppNotificationSender`.
class FakeNotifications extends TimeTrackerNotificationService {
  FakeNotifications();

  final List<SentNotification> sent = <SentNotification>[];

  List<SentNotification> of(TimeTrackerNotificationEvent e) =>
      sent.where((SentNotification n) => n.event == e).toList();

  @override
  Future<bool> send({
    required TimeTrackerNotificationEvent event,
    required TimeTrackerNotificationPage page,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const <TemplateVariable, String>{},
    Map<TemplateVariable, String> variablesAr = const <TemplateVariable, String>{},
    String requestId = '',
  }) async {
    sent.add(SentNotification(event, page, receiverEmail.toLowerCase(), requestId, variables, senderEmail));
    return true;
  }
}

/// In-memory roles: id → (name, modules, switches).
class FakeRoleSource extends TimeTrackerRoleRemoteDataSource {
  FakeRoleSource(this.roles) : super();

  final List<(TimeTrackerRoleRecord, Map<String, dynamic>)> roles;
  int reads = 0;

  /// A role with the approval switches ([all] = All Departments).
  static (TimeTrackerRoleRecord, Map<String, dynamic>) approverRole(
    String id, {
    String name = '',
    bool all = true,
    bool approve = true,
    List<String> modules = const <String>['time_tracker'],
  }) =>
      (
        TimeTrackerRoleRecord(id: id, name: name, modules: modules),
        <String, dynamic>{
          'Approval_Permissions': <bool>[true],
          'Approve_And_Reject': <bool>[approve],
          'Approvals_All_Departments': all,
        },
      );

  @override
  Future<List<TimeTrackerRoleRecord>> fetchRoles() async {
    reads++;
    return <TimeTrackerRoleRecord>[for (final (TimeTrackerRoleRecord, Map<String, dynamic>) r in roles) r.$1];
  }

  @override
  Future<Map<String, dynamic>> fetchTimeTrackerSwitches(String roleId) async {
    for (final (TimeTrackerRoleRecord, Map<String, dynamic>) r in roles) {
      if (r.$1.id == roleId) return r.$2;
    }
    return <String, dynamic>{};
  }
}

TimeTrackerAudit _audit(DateTime at) => TimeTrackerAudit.next(null, actor: 'seed@co.com', now: at);

/// Store [requests] as they are (status, steps…), created at [at].
void seedRequests(FakeTimeTrackerRemote remote, List<TimeTrackerRequest> requests, {DateTime? at}) {
  final DateTime when = at ?? DateTime(2026, 10, 1);
  for (final TimeTrackerRequest r in requests) {
    remote.store.putIfAbsent(TimeTrackerFirestorePaths.requests, () => <String, Map<String, dynamic>>{})[r.id] =
        TimeTrackerHistoryCodec.append(
      old: null,
      values: TimeTrackerRequestModel.row(r, id: r.id, audit: _audit(when)),
      now: when,
    );
  }
}

/// Store [balance] as its year's document (`{email}_{year}`, 9/10/2026).
void seedBalance(FakeTimeTrackerRemote remote, VacationBalance balance) {
  final String id = VacationBalanceModel.docIdOf(balance);
  remote.store.putIfAbsent(TimeTrackerFirestorePaths.vacationBalances, () => <String, Map<String, dynamic>>{})[id] =
      TimeTrackerHistoryCodec.append(
    old: null,
    values: VacationBalanceModel.row(balance, id: id, audit: _audit(DateTime(2026))),
    now: DateTime(2026),
  );
}

/// The phase-4 services over [remote] for the user of [access].
class Phase4Kit {
  Phase4Kit({
    required this.remote,
    required this.access,
    String manager = '',
    List<TimeTrackerEmployee>? people,
    List<(TimeTrackerRoleRecord, Map<String, dynamic>)> roles = const <(TimeTrackerRoleRecord, Map<String, dynamic>)>[],
    WorkSetupSourceResolver? resolver,
    DateTime Function()? clock,
  })  : directory = FakeDirectory(people),
        managers = FakeManagerResolver(manager),
        roleSource = FakeRoleSource(roles) {
    final DateTime Function() now = clock ?? DateTime.now;
    requests = RequestRepositoryImpl(remoteDataSource: remote, access: access);
    comments = RequestCommentRepositoryImpl(remoteDataSource: remote, access: access);
    types = RequestTypeRepositoryImpl(remoteDataSource: remote, access: access);
    balances = VacationBalanceRepositoryImpl(remoteDataSource: remote, access: access);
    attendance = AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
    final WorkSetupSourceResolver r = resolver ?? noHrResolver(remote);
    // 9/10/2026 (code review finding 9): as in time_tracker_get_it.dart.
    approvers = RoleApproverDirectory(
      roles: roleSource,
      directory: directory,
      requests: requests,
      clock: now,
      readsCompanyRequests: () => access.readsCompanyRequests,
    );
    // 9/10/2026 (code review): RequestEffects only plans; the request
    // repository writes request + balance + day in one transaction.
    effects = RequestEffects(resolver: r, directory: directory);
    requestService = RequestService(
      requests: requests,
      comments: comments,
      types: types,
      balances: balances,
      resolver: r,
      managers: managers,
      approvers: approvers,
      effects: effects,
      notifier: notifications,
      access: access,
      log: log,
      clock: now,
    );
    approvalService = ApprovalService(
      requests: requests,
      types: types,
      approvers: approvers,
      effects: effects,
      notifier: notifications,
      access: access,
      log: log,
      clock: now,
    );
  }

  final FakeTimeTrackerRemote remote;
  final TimeTrackerAccess access;
  final FakeDirectory directory;
  final FakeManagerResolver managers;
  final FakeRoleSource roleSource;
  final FakeNotifications notifications = FakeNotifications();
  final FakeLog log = FakeLog();
  late final RequestRepositoryImpl requests;
  late final RequestCommentRepositoryImpl comments;
  late final RequestTypeRepositoryImpl types;
  late final VacationBalanceRepositoryImpl balances;
  late final AttendanceRepositoryImpl attendance;
  late final RoleApproverDirectory approvers;
  late final RequestEffects effects;
  late final RequestService requestService;
  late final ApprovalService approvalService;

  /// The same services as seen by another signed-in user ([other]).
  Phase4Kit as(TimeTrackerAccess other, {String manager = '', DateTime Function()? clock}) => Phase4Kit(
        remote: remote,
        access: other,
        manager: manager,
        people: directory.people,
        roles: roleSource.roles,
        clock: clock,
      );
}
