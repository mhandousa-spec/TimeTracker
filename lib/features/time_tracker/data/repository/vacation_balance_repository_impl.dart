/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_repository_impl.dart
/// Purpose: Declares `VacationBalanceRepositoryImpl` — vacation balances in
///          `Modules/time_tracker/Vacation_Balances/{email}_{year}`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 11: the balance always lives in Time Tracker.
/// Updated: 9/10/2026 - phase 5: [watchBalance] (one employee, live).
/// Updated: 9/10/2026 - code review: reads never write.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): ONE document per employee
/// per year, id `{lower-case email}_{year}` (created on the first save). No
/// roll-over: a year without a document has no balance. A document whose id
/// is not `{Employee_Email}_{Balance_Year}` (the old `{email}` layout) is
/// skipped by every list ([isReadable]). [setTotalDays] keeps the stored
/// used days inside its transaction.

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/vacation_balance_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/vacation_balance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';

class VacationBalanceRepositoryImpl
    extends TimeTrackerHistoryRepository<VacationBalance>
    implements VacationBalanceBaseRepository {
  VacationBalanceRepositoryImpl({
    required super.remoteDataSource,
    required super.access,
  });

  @override
  String get collectionPath => TimeTrackerFirestorePaths.vacationBalances;

  @override
  String get entityLabel => 'vacation balance';

  @override
  VacationBalance decode(TimeTrackerDocument document) =>
      VacationBalanceModel.fromMap(document.id, document.data);

  /// Only per-year documents are balances (9/10/2026).
  @override
  bool isReadable(TimeTrackerDocument document) =>
      VacationBalanceModel.isYearDocument(document.id, document.data);

  @override
  Map<String, Object?> encode(
    VacationBalance entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      VacationBalanceModel.row(entity, id: id, audit: audit);

  @override
  void validate(VacationBalance entity) {
    if (entity.totalDays < 0 || entity.usedDays < 0) {
      throw Exception('Vacation days cannot be negative.');
    }
  }

  String _id(String email, int year) =>
      keyOf(() => TimeTrackerFirestorePaths.vacationBalanceDocId(email, year));

  @override
  Stream<List<VacationBalance>> watchBalancesOfYear({required int year}) => watchDocuments(
        () => remote.watchArrayContains(collectionPath, VacationBalanceModel.fBalanceYear, year),
      ).map((List<VacationBalance> list) => List<VacationBalance>.unmodifiable(
            list.where((VacationBalance b) => b.year == year),
          ));

  /// A document-id prefix read narrowed to the exact `{email}_{year}` id.
  @override
  Stream<VacationBalance?> watchBalance({required String employeeEmail, required int year}) {
    final String id;
    try {
      id = TimeTrackerFirestorePaths.vacationBalanceDocId(employeeEmail, year);
    } catch (error) {
      return Stream<VacationBalance?>.error(clean(error, 'load the $entityLabel'));
    }
    return watchDocuments(() => remote.watchIdPrefix(collectionPath, id)).map(
      (List<VacationBalance> list) {
        for (final VacationBalance b in list) {
          if ('${b.employeeEmail.trim().toLowerCase()}_${b.year}' == id) return b;
        }
        return null;
      },
    );
  }

  @override
  Future<VacationBalance?> fetchBalance({required String employeeEmail, required int year}) async =>
      fetchOne(_id(employeeEmail, year));

  @override
  Future<List<VacationBalance>> fetchBalancesOf({required String employeeEmail}) async {
    final String email = keyOf(() => TimeTrackerFirestorePaths.emailKey(employeeEmail));
    return watchDocuments(
      () => remote.watchArrayContains(collectionPath, VacationBalanceModel.fEmployeeEmail, email),
    ).first;
  }

  @override
  Future<VacationBalance> saveBalance({required VacationBalance balance}) async =>
      write(balance, id: _id(balance.employeeEmail, balance.year), mustExist: false);

  @override
  Future<VacationBalance> setTotalDays({
    required String employeeEmail,
    required int year,
    required double totalDays,
  }) async {
    final String id = _id(employeeEmail, year);
    final String email = employeeEmail.trim().toLowerCase();
    validate(VacationBalance(employeeEmail: email, year: year, totalDays: totalDays));
    final String by = actor();
    try {
      final TimeTrackerDocument doc = await remote.appendRow(
        relativePath: collectionPath,
        id: id,
        mustExist: false,
        row: (String docId, Map<String, dynamic>? stored) {
          // The used days AS STORED inside the transaction (a deduction
          // that landed meanwhile is kept).
          final double used = stored == null ? 0 : VacationBalanceModel.fromMap(docId, stored).usedDays;
          return encode(
            VacationBalance(employeeEmail: email, year: year, totalDays: totalDays, usedDays: used),
            id: docId,
            audit: TimeTrackerAudit.next(stored, actor: by, now: DateTime.now()),
          );
        },
      );
      return decode(doc);
    } catch (error) {
      throw clean(error, 'save the $entityLabel');
    }
  }
}
