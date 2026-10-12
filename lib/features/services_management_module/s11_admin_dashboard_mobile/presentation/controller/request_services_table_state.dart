/// Module: services_management_module
/// Description: State for RequestServicesTableCubit — the paginated,
///              filterable request-services table on the s11 dashboard.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable
/// Revision History: Initial version — extracted from
///                    s11_admin_dashboard_mobile/ui/widgets/table.dart
///                    (audit fix 1c).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Plain data holder for a single request-services row, kept here so the
/// UI never touches Firestore document snapshots directly.
class RequestServiceRow extends Equatable {
  final String id;
  final String department;
  final String serviceName;
  final DateTime? requestedAt;
  final String status;
  final String requester;
  final String providerName;

  const RequestServiceRow({
    required this.id,
    required this.department,
    required this.serviceName,
    required this.status,
    required this.providerName,
    this.requestedAt,
    this.requester = '',
  });

  @override
  List<Object?> get props =>
      [id, department, serviceName, requestedAt, status, requester, providerName];
}

class RequestServicesTableState extends Equatable {
  final List<RequestServiceRow> rows;
  final bool initialLoading;
  final bool loadingMore;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;
  final String? department;
  final String? status;
  final DateTime? day;
  final String search;

  const RequestServicesTableState({
    this.rows = const [],
    this.initialLoading = true,
    this.loadingMore = false,
    this.hasMore = true,
    this.lastDoc,
    this.department,
    this.status,
    this.day,
    this.search = '',
  });

  RequestServicesTableState copyWith({
    List<RequestServiceRow>? rows,
    bool? initialLoading,
    bool? loadingMore,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
    bool clearLastDoc = false,
    String? department,
    bool clearDepartment = false,
    String? status,
    bool clearStatus = false,
    DateTime? day,
    bool clearDay = false,
    String? search,
  }) {
    return RequestServicesTableState(
      rows: rows ?? this.rows,
      initialLoading: initialLoading ?? this.initialLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: clearLastDoc ? null : (lastDoc ?? this.lastDoc),
      department: clearDepartment ? null : (department ?? this.department),
      status: clearStatus ? null : (status ?? this.status),
      day: clearDay ? null : (day ?? this.day),
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
        rows,
        initialLoading,
        loadingMore,
        hasMore,
        lastDoc,
        department,
        status,
        day,
        search,
      ];
}
