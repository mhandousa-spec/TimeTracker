/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_filter_dialog.dart
/// Purpose: Declares `RequestFilterDialog` — the Requests / Approvals
///          "Filter" popup: Request Type · Status · From Date – To Date, and
///          on the Approvals tab Department → Employee.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Pops the new `RequestFilter` (Reset pops `RequestFilter.none`). Scales in.
/// Updated: 9/10/2026 - UI quality pass (owner finding 13:45 #3): the
/// meaningless "Choose Type", "Day" and "Total Time" are gone. Request Type
/// lists the company's types plus "Transaction"; Status lists every request
/// status; the date range keeps a request that touches it (To before From
/// shows an error and greys Apply). Approvals ([departments] / [employees]
/// given): Department only for an "All Departments" approver (scope rule —
/// otherwise null and hidden), Employee depends on the chosen Department
/// (parent → child, house rule). One frame with the Attendance filter
/// (`TtFilterFrame`).

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_filter_frame.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// "Transaction" in the Request Type dropdown.
const String _transaction = '__transaction__';

/// 13/10/2026 (owner): Request Type, Status and Department are MULTI-select;
/// the Employee list is gone (a company can have thousands — the search bar
/// finds employees by name).
class RequestFilterDialog extends StatefulWidget {
  const RequestFilterDialog({
    super.key,
    required this.initial,
    required this.types,
    this.departments,
  });

  final RequestFilter initial;

  /// Every request type (removed ones included — old requests use them).
  final List<RequestType> types;

  /// Approvals with "All Departments": id → name (null = no Department field).
  final Map<String, String>? departments;

  @override
  State<RequestFilterDialog> createState() => _RequestFilterDialogState();
}

class _RequestFilterDialogState extends State<RequestFilterDialog> {
  Set<String> _types = <String>{};
  Set<RequestStatus> _statuses = <RequestStatus>{};
  DateTime? _from;
  DateTime? _to;
  Set<String> _departments = <String>{};

  @override
  void initState() {
    super.initState();
    final RequestFilter f = widget.initial;
    _types = <String>{
      ...f.requestTypeIds,
      if (f.includeTransactions || f.kind == RequestKind.transaction) _transaction,
    };
    _statuses = <RequestStatus>{...f.statuses};
    _from = f.from;
    _to = f.to;
    _departments = <String>{...f.departmentIds};
  }

  RequestFilter _collect() => RequestFilter(
        kind: widget.initial.kind == RequestKind.request ? RequestKind.request : null,
        requestTypeIds: <String>{for (final String t in _types) if (t != _transaction) t},
        includeTransactions: _types.contains(_transaction),
        statuses: _statuses,
        from: _from,
        to: _to,
        departmentIds: _departments,
        // An HR-dashboard link's employee stays until Reset.
        employeeEmail: widget.initial.employeeEmail,
      );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final Map<String, String>? departments = widget.departments;
    // One entry per name: two types that share a name are one choice.
    final Map<String, Set<String>> byName = <String, Set<String>>{};
    for (final RequestType t in widget.types) {
      byName.putIfAbsent(t.name(isArabic: ar).trim(), () => <String>{}).add(t.id);
    }
    final Widget type = TtFilterMultiDropdown<String>(
      label: s.timeTrackerRequestType,
      values: <String>{
        for (final MapEntry<String, Set<String>> e in byName.entries)
          if (e.value.any(_types.contains)) e.key,
        if (_types.contains(_transaction)) _transaction,
      },
      items: <(String, String)>[
        for (final String n in byName.keys) (n, n),
        (_transaction, s.timeTrackerTransactionButton),
      ],
      onChanged: (Set<String> picked) => setState(() => _types = <String>{
            for (final String n in picked) ...(n == _transaction ? <String>{_transaction} : byName[n] ?? <String>{}),
          }),
    );
    final Widget status = TtFilterMultiDropdown<RequestStatus>(
      label: s.timeTrackerStatus,
      values: _statuses,
      items: <(RequestStatus, String)>[
        for (final RequestStatus st in RequestStatus.values) (st, RequestText.statusLabel(context, st)),
      ],
      onChanged: (Set<RequestStatus> v) => setState(() => _statuses = v),
    );
    final Widget? department = departments == null
        ? null
        : TtFilterMultiDropdown<String>(
            label: s.timeTrackerDepartment,
            values: _departments,
            items: <(String, String)>[for (final MapEntry<String, String> d in departments.entries) (d.key, d.value)],
            onChanged: (Set<String> v) => setState(() => _departments = v),
          );
    return TtFilterFrame(
      applyKey: const ValueKey<String>('requestFilterApply'),
      canApply: TtDateRangeFields.isValid(_from, _to),
      onReset: () => Navigator.of(context).pop(RequestFilter.none),
      onApply: () => Navigator.of(context).pop(_collect()),
      rows: <Widget>[
        TtPair(start: type, end: status),
        TtDateRangeFields(
          from: _from,
          to: _to,
          onFrom: (DateTime? d) => setState(() => _from = d),
          onTo: (DateTime? d) => setState(() => _to = d),
        ),
        if (department != null) department,
      ],
    );
  }
}
