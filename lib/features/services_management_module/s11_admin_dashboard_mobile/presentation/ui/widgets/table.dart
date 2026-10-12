/// Module: services_management_module
/// Description: Paginated, filterable request-services table for the s11
///              dashboard. All Firestore paging/query logic now goes
///              through RequestServicesTableCubit — this widget only
///              dispatches cubit methods and renders
///              RequestServicesTableState (audit fix 1c).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, RequestServicesTableCubit,
///               RequestServicesTableState
/// Revision History: Rewritten to remove direct
///                    FirebaseFirestore.instance.collection(...) usage (was
///                    previously a StatefulWidget owning the paginated
///                    Firestore query directly).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';

import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/request_services_table_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/request_services_table_state.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart' show FirestoreCollections;

/// ---------- Table Widget ----------
class RequestServicesTable extends StatefulWidget {
  const RequestServicesTable({
    super.key,
    this.pageSize = 50,
    this.collectionPath = FirestoreCollections.requestServicesRoot, // relative; getBaseUrl(...) is applied below
  });

  final int pageSize;
  final String collectionPath;

  @override
  State<RequestServicesTable> createState() => _RequestServicesTableState();
}

class _RequestServicesTableState extends State<RequestServicesTable> {
  final ScrollController _scroll = ScrollController();
  late final RequestServicesTableCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = RequestServicesTableCubit(
      collectionPath: getBaseUrl(widget.collectionPath),
      pageSize: widget.pageSize,
    )..fetchFirstPage();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    final state = _cubit.state;
    if (!state.hasMore || state.loadingMore || state.initialLoading) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _cubit.fetchNextPage();
    }
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _cubit.state.day ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _cubit.setDay(picked);
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('yyyy-MM-dd – HH:mm').format(d);
  }

  Color _statusColor(String s, bool light) {
    final key = s.trim().toLowerCase();
    final map = <String, Color>{
      'done': AppColors.green,
      'approved': AppColors.green,
      'inprogress': AppColors.yellow,
      'pending': AppColors.orange,
      'rejected': AppColors.darkRed,
      'breached sla': AppColors.red,
      'branchsla': AppColors.red,
      'cancel': AppColors.red,
      'canceled': AppColors.red,
      'cancelled': AppColors.red,
    };
    return map[key] ?? (light ? AppColors.mediumGrey : AppColors.lightGrey);
  }

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<RequestServicesTableCubit, RequestServicesTableState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --------- Controls: Search + Filters ---------
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      onChanged: _cubit.setSearch,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: _DepartmentDropdown(
                      value: state.department,
                      onChanged: _cubit.setDepartment,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: _StatusDropdown(
                      value: state.status,
                      onChanged: _cubit.setStatus,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDay,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(state.day == null
                        ? 'Request date'
                        : DateFormat('yyyy-MM-dd').format(state.day!)),
                  ),
                  if (state.department != null ||
                      state.status != null ||
                      state.day != null ||
                      state.search.isNotEmpty)
                    TextButton.icon(
                      onPressed: _cubit.clearFilters,
                      icon: const Icon(Icons.clear),
                      label: Text(S.of(context).Reset),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // --------- Table / Skeleton ---------
              Container(
                decoration: BoxDecoration(
                  color: light ? AppColors.white : AppColors.darkDashboardTable,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: light ? AppColors.indicator : AppColors.darkDashboardTable),
                ),
                child: state.initialLoading
                    ? _SkeletonTable(rows: 8)
                    : state.rows.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: Text(S.of(context).noResults)),
                          )
                        : Scrollbar(
                            controller: _scroll,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scroll,
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: 16,
                                headingRowHeight: 44,
                                dataRowMinHeight: 48,
                                dataRowMaxHeight: 56,
                                columns: [
                                  DataColumn(label: Text(S.of(context).no)),
                                  DataColumn(label: Text(S.of(context).department)),
                                  DataColumn(label: Text(S.of(context).ServiceName)),
                                  DataColumn(label: Text(S.of(context).RequestedDate)),
                                  DataColumn(label: Text(S.of(context).status)),
                                  DataColumn(label: Text(S.of(context).serviceProvider)),
                                ],
                                rows: List.generate(state.rows.length, (i) {
                                  final r = state.rows[i];
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${i + 1}')),
                                      DataCell(Text(
                                          r.department.isEmpty ? '-' : r.department)),
                                      DataCell(Text(
                                          r.serviceName.isEmpty ? '-' : r.serviceName)),
                                      DataCell(Text(_fmtDate(r.requestedAt))),
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(r.status, light)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                              color: _statusColor(r.status, light)),
                                        ),
                                        child: Text(
                                          r.status.isEmpty ? '-' : r.status,
                                          style: TextStyle(
                                            color: _statusColor(r.status, light),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                      DataCell(Text(r.providerName)),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
              ),

              // --------- Load more / Progress ---------
              if (!state.initialLoading) ...[
                const SizedBox(height: 12),
                if (state.loadingMore)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator()))
                else if (state.hasMore)
                  Center(
                    child: OutlinedButton(
                      onPressed: _cubit.fetchNextPage,
                      child: Text(S.of(context).loadMore),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(S.of(context).noMoreResults),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// ---------- Skeleton (instant paint) ----------
class _SkeletonTable extends StatelessWidget {
  const _SkeletonTable({required this.rows});
  final int rows;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final base = light ? AppColors.lightGrey : AppColors.white.withOpacity(0.10);

    Widget bar([double w = 80]) => Container(
      height: 14,
      width: w,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(rows, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                bar(36),
                const SizedBox(width: 16),
                bar(120),
                const SizedBox(width: 16),
                bar(200),
                const SizedBox(width: 16),
                bar(160),
                const SizedBox(width: 16),
                bar(100),
                const SizedBox(width: 16),
                bar(160),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// ---------- Department filter ----------
class _DepartmentDropdown extends StatelessWidget {
  const _DepartmentDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  // Put the departments you actually have indexed
  static const _items = <String>[
    'Executive',
    'Customer Support',
    'Finance',
    'Operations',
    'Information Technology',
    'Human Resources',
    'Marketing',
    'Sales',
    'Data Management',
    'Compliance & Legal',
    'Software',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      value: value != null && _items.contains(value) ? value : null,
      label: 'Department',
      hint: 'Department',
      items: _items
          .map((d) => DropdownItem<String>(value: d, label: d))
          .toList(),
      onChanged: (v) => onChanged(v),
    );
  }
}

/// ---------- Status filter ----------
class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _statuses = <String>[
    'approved',
    'done',
    'cancel',
    'rejected',
    'inprogress',
    'branchsla',
    'pending',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      value: value != null && _statuses.contains(value) ? value : null,
      label: 'Status',
      hint: 'Status',
      items: _statuses
          .map((s) => DropdownItem<String>(value: s, label: s))
          .toList(),
      onChanged: (v) => onChanged(v),
    );
  }
}
