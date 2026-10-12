/// Module: services_management_module
/// Description: Cubit owning the paginated Firestore query for the s11
///              dashboard's request-services table (search + department/
///              status/day filters, cursor-based "load more"). Kept as its
///              own small cubit rather than folded into the large
///              DashboardMasterCubit (944 LOC) because it owns an
///              unrelated, self-contained pagination/filter state machine
///              with a live Firestore Query cursor — merging it in would
///              risk destabilizing DashboardMasterCubit's existing
///              bootstrap flow without a compiler to verify the merge.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, cloud_firestore
/// Revision History: Initial version — extracted from
///                    s11_admin_dashboard_mobile/ui/widgets/table.dart
///                    (audit fix 1c): _fetchFirstPage, _fetchNextPage,
///                    _loadPage, _buildBaseQuery.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/request_services_table_state.dart';

class RequestServicesTableCubit extends Cubit<RequestServicesTableState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final FirebaseFirestore firestore;
  final String collectionPath;
  final int pageSize;

  RequestServicesTableCubit({
    required this.collectionPath,
    this.pageSize = 50,
    FirebaseFirestore? firestore,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        super(const RequestServicesTableState());

  Query _buildBaseQuery() {
    Query q = firestore
        .collection(collectionPath)
        .orderBy('serviceNameEnglishTimestamp', descending: true);

    if (state.department != null && state.department!.isNotEmpty) {
      q = q.where('departmentRequester', isEqualTo: state.department);
    }

    if (state.status != null && state.status!.isNotEmpty) {
      q = q.where('state', isEqualTo: state.status);
    }

    if (state.day != null) {
      final start = DateTime(state.day!.year, state.day!.month, state.day!.day);
      final end = start.add(const Duration(days: 1));
      q = q.where('serviceNameEnglishTimestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start));
      q = q.where('serviceNameEnglishTimestamp', isLessThan: Timestamp.fromDate(end));
    }

    return q.limit(pageSize);
  }

  Future<void> fetchFirstPage() async {
    emit(state.copyWith(
      initialLoading: true,
      rows: const [],
      clearLastDoc: true,
      hasMore: true,
    ));
    await _loadPage();
    emit(state.copyWith(initialLoading: false));
  }

  Future<void> fetchNextPage() async {
    if (!state.hasMore) return;
    emit(state.copyWith(loadingMore: true));
    await _loadPage();
    emit(state.copyWith(loadingMore: false));
  }

  Future<void> _loadPage() async {
    Query q = _buildBaseQuery();
    if (state.lastDoc != null) q = q.startAfterDocument(state.lastDoc!);

    final snap = await q.get();
    if (snap.docs.isEmpty) {
      emit(state.copyWith(hasMore: false));
      return;
    }

    final search = state.search;
    final newRows = <RequestServiceRow>[];
    for (final d in snap.docs) {
      final data = d.data() as Map<String, dynamic>;

      final dept = (data['departmentRequester'] ?? '').toString();
      final name = (data['serviceNameEnglish'] ?? '').toString();
      final status = (data['state'] ?? '').toString().toLowerCase().trim();

      DateTime? requestedAt;
      final ts = data['serviceNameEnglishTimestamp'];
      if (ts is Timestamp) requestedAt = ts.toDate();

      final sp = (data['selectedServiceProvider'] ?? {}) as Map<String, dynamic>;
      final providerName =
          '${(sp['firstName'] ?? '').toString()} ${(sp['lastName'] ?? '').toString()}'.trim();

      final searchable = [
        dept,
        name,
        status,
        providerName,
        (data['requestor'] ?? '').toString(),
        (data['serviceNameArabic'] ?? '').toString(),
      ].join(' ').toLowerCase();

      if (search.isEmpty || searchable.contains(search)) {
        newRows.add(RequestServiceRow(
          id: d.id,
          department: dept,
          serviceName: name,
          requestedAt: requestedAt,
          status: status,
          providerName: providerName.isEmpty ? 'N/A' : providerName,
          requester: (data['requestor'] ?? '').toString(),
        ));
      }
    }

    // Mirrors the original widget's paging semantics exactly: fewer raw
    // docs than a full page means there's nothing left to fetch.
    final hasMore = snap.docs.length >= pageSize;
    emit(state.copyWith(
      rows: [...state.rows, ...newRows],
      lastDoc: snap.docs.last,
      hasMore: hasMore,
    ));
  }

  void setSearch(String value) {
    emit(state.copyWith(search: value.trim().toLowerCase()));
    fetchFirstPage();
  }

  void setDepartment(String? value) {
    emit(state.copyWith(department: value, clearDepartment: value == null));
    fetchFirstPage();
  }

  void setStatus(String? value) {
    emit(state.copyWith(status: value, clearStatus: value == null));
    fetchFirstPage();
  }

  void setDay(DateTime? value) {
    emit(state.copyWith(day: value, clearDay: value == null));
    fetchFirstPage();
  }

  void clearFilters() {
    emit(state.copyWith(
      clearDepartment: true,
      clearStatus: true,
      clearDay: true,
      search: '',
    ));
    fetchFirstPage();
  }
}
