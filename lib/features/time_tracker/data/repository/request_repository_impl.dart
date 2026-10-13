/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: request_repository_impl.dart
/// Purpose: Declares `RequestRepositoryImpl` — leave requests and attendance
///          transactions in `Modules/time_tracker/Requests/{id}`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Validation repeats the form rules so a bad write never reaches Firestore
/// from any caller: a requester, an end not before the start, a request type
/// for leave requests, a transaction always has both times.
/// Updated: 9/10/2026 - phase 4: [fetchRequest] (every decision re-reads the
/// stored request first, so two approvers never act on a stale copy).
/// Updated: 9/10/2026 - code review:
///   * finding 2: every update is a compare-and-set — refused INSIDE the
///     transaction ([checkStored]) when the stored document has more rows
///     than the copy that was read (`TimeTrackerRequest.revision`);
///   * findings 3 + 4: [commitRequest] writes the request, the vacation
///     balance (deduct / refund the stored `Deducted_Vacation_Days`) and a
///     transaction's attendance day in ONE transaction;
///   * finding 9: [watchRequestsOf] (`Requester_Email` array-contains);
///   * finding 10: a deduction with no balance stored is refused
///     (`TimeTrackerNoVacationBalance`);
///   * an unknown `Request_Status` is skipped ([isReadable]) instead of
///     reading as pending.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): the deduction / refund
/// lands on the balance of the year the request STARTS in
/// (`Vacation_Balances/{email}_{year}`, `VacationBalanceRules.balanceYearOf`)
/// — still inside the same transaction as the request; no roll-over (a year
/// with no document = no balance: a deduction is refused, a refund has
/// nothing to give back).
/// Updated: 9/10/2026 - owner round 9 option b: ONE balance write PER YEAR
/// of the request (a request spanning 2026–2027 moves both documents), all
/// in the same transaction; a year with no document or too few days left
/// refuses the whole write (`TimeTrackerNoVacationBalance(year)` /
/// `TimeTrackerYearBalanceShort`).

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/vacation_balance_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_side_effects.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_failures.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_correction_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

class RequestRepositoryImpl
    extends TimeTrackerHistoryRepository<TimeTrackerRequest>
    implements RequestBaseRepository {
  RequestRepositoryImpl({
    required super.remoteDataSource,
    required super.access,
  });

  @override
  String get collectionPath => TimeTrackerFirestorePaths.requests;

  @override
  String get entityLabel => 'request';

  @override
  TimeTrackerRequest decode(TimeTrackerDocument document) =>
      TimeTrackerRequestModel.fromMap(document.id, document.data);

  @override
  bool isReadable(TimeTrackerDocument document) =>
      TimeTrackerRequestModel.hasKnownStatus(document.data);

  @override
  Map<String, Object?> encode(
    TimeTrackerRequest entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      TimeTrackerRequestModel.row(entity, id: id, audit: audit);

  @override
  void validate(TimeTrackerRequest entity) {
    if (entity.requesterEmail.trim().isEmpty) {
      throw Exception('A request needs a requester.');
    }
    if (!entity.isTransaction && entity.requestTypeId.trim().isEmpty) {
      throw Exception('Choose a request type.');
    }
    if (entity.endAt.isBefore(entity.startAt)) {
      throw Exception('The end must not be before the start.');
    }
    if (entity.totalMinutes < 0) {
      throw Exception('The total time cannot be negative.');
    }
  }

  /// Compare-and-set (code review finding 2): the stored document must
  /// still be the one [entity] was read from.
  @override
  void checkStored(TimeTrackerRequest entity, Map<String, dynamic>? stored) {
    if (entity.revision <= 0 || stored == null) return;
    if (TimeTrackerHistoryCodec.rowCount(stored) != entity.revision) {
      throw const TimeTrackerRecordChanged();
    }
  }

  @override
  Stream<List<TimeTrackerRequest>> watchRequests() => watchAll();

  @override
  Stream<List<TimeTrackerRequest>> watchRequestsOf({required String email}) {
    final String key;
    try {
      key = TimeTrackerFirestorePaths.emailKey(email);
    } catch (error) {
      return Stream<List<TimeTrackerRequest>>.error(clean(error, 'load the ${entityLabel}s'));
    }
    return watchDocuments(
      () => remote.watchArrayContains(collectionPath, TimeTrackerRequestModel.fRequesterEmail, key),
    );
  }

  @override
  Future<TimeTrackerRequest> createRequest({
    required TimeTrackerRequest request,
  }) async =>
      write(request, id: null, mustExist: false, newId: newIdOf(request));

  /// 13/10/2026 (owner decision 48): REQ-2026-0001 / TRX-2026-0001 — the
  /// year the request is created.
  static NewDocId newIdOf(TimeTrackerRequest request) =>
      NewDocId('${request.isTransaction ? 'TRX' : 'REQ'}-${DateTime.now().year}');

  @override
  Future<TimeTrackerRequest> updateRequest({
    required TimeTrackerRequest request,
  }) async =>
      write(request, id: requireId(request.id), mustExist: true);

  @override
  Future<TimeTrackerRequest?> fetchRequest({required String id}) async =>
      id.trim().isEmpty ? null : fetchOne(id);

  @override
  Future<RequestCommit> commitRequest({
    required TimeTrackerRequest request,
    RequestSideEffects effects = RequestSideEffects.none,
    required DateTime now,
  }) async {
    validate(request);
    final String by = actor();
    final bool isNew = request.id.trim().isEmpty;
    if (isNew && effects.attendance != AttendanceCorrectionKind.none) {
      throw Exception('A new request cannot correct an attendance day.');
    }
    TimeTrackerAudit audit(Map<String, dynamic>? stored) =>
        TimeTrackerAudit.next(stored, actor: by, now: DateTime.now());
    final List<HistoryRowWrite> writes = <HistoryRowWrite>[
      HistoryRowWrite(
        relativePath: collectionPath,
        id: isNew ? null : request.id,
        mustExist: !isNew,
        newId: isNew ? newIdOf(request) : null,
        row: (String id, Map<String, dynamic>? stored) {
          checkStored(request, stored);
          return encode(request, id: id, audit: audit(stored));
        },
      ),
    ];
    // 9/10/2026 (owner round 9 option b): one balance write per year.
    final Map<int, int> balanceAt = <int, int>{};
    final List<int> years = effects.usedDaysByYear.keys.toList()..sort();
    for (final int year in years) {
      final double delta = effects.usedDaysByYear[year] ?? 0;
      if (delta == 0) continue;
      balanceAt[year] = writes.length;
      writes.add(HistoryRowWrite(
        relativePath: TimeTrackerFirestorePaths.vacationBalances,
        id: keyOf(() => TimeTrackerFirestorePaths.vacationBalanceDocId(request.requesterEmail, year)),
        row: (String id, Map<String, dynamic>? stored) => _balanceRow(id, stored, year, delta, audit(stored)),
      ));
    }
    if (effects.attendance != AttendanceCorrectionKind.none) {
      writes.add(HistoryRowWrite(
        relativePath: TimeTrackerFirestorePaths.attendance,
        id: keyOf(() => TimeTrackerFirestorePaths.attendanceDocId(
              request.requesterEmail,
              TransactionCorrectionRules.dayOf(request),
            )),
        row: (String id, Map<String, dynamic>? stored) =>
            _dayRow(id, stored, request, effects, now, audit(stored)),
      ));
    }
    try {
      final List<TimeTrackerDocument?> docs = await remote.appendRows(writes);
      return RequestCommit(
        request: decode(docs.first!),
        balances: <int, VacationBalance>{
          for (final MapEntry<int, int> e in balanceAt.entries)
            if (docs[e.value] != null) e.key: VacationBalanceModel.fromMap(docs[e.value]!.id, docs[e.value]!.data),
        },
      );
    } catch (error) {
      throw clean(error, 'save the $entityLabel');
    }
  }

  /// [year]'s balance after [delta] used days, from the balance AS STORED
  /// inside the transaction. No balance stored for that year: a deduction
  /// is refused (finding 10, owner: missing = 0 days remaining), a refund
  /// has nothing to give back. Too few days left for a deduction: refused
  /// (owner round 9 option b — the message names the year). No roll-over.
  static Map<String, Object?>? _balanceRow(
    String id,
    Map<String, dynamic>? stored,
    int year,
    double delta,
    TimeTrackerAudit audit,
  ) {
    if (stored == null) {
      if (delta > 0) throw TimeTrackerNoVacationBalance(year: year);
      return null;
    }
    final VacationBalance current = VacationBalanceModel.fromMap(id, stored);
    if (delta > 0 && VacationBalanceRules.wouldExceed(current, delta)) {
      throw TimeTrackerYearBalanceShort(year: year, daysLeft: current.remainingDays);
    }
    final double used = current.usedDays + delta;
    return VacationBalanceModel.row(current.copyWith(usedDays: used < 0 ? 0 : used), id: id, audit: audit);
  }

  /// The corrected (or reverted) attendance day of a transaction, built
  /// from the day AS STORED inside the transaction.
  static Map<String, Object?>? _dayRow(
    String id,
    Map<String, dynamic>? stored,
    TimeTrackerRequest request,
    RequestSideEffects effects,
    DateTime now,
    TimeTrackerAudit audit,
  ) {
    if (effects.attendance == AttendanceCorrectionKind.apply) {
      final AttendanceDay day = TransactionCorrectionRules.apply(
        existing: stored == null ? null : AttendanceDayModel.fromMap(id, stored),
        transaction: request,
        schedule: effects.schedule,
        now: now,
      );
      return AttendanceDayModel.row(day, id: id, audit: audit);
    }
    if (stored == null) return null;
    final AttendanceCorrectionHistory? history =
        AttendanceDayModel.correctionHistory(id, stored, request.id);
    if (history == null) return null;
    return AttendanceDayModel.row(
      TransactionCorrectionRules.revert(
        current: history.current,
        before: history.before,
        schedule: effects.schedule,
        now: now,
      ),
      id: id,
      audit: audit,
    );
  }
}
