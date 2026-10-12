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
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_filter_frame.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// "Transaction" in the Request Type dropdown.
const String _transaction = '__transaction__';

class RequestFilterDialog extends StatefulWidget {
  const RequestFilterDialog({
    super.key,
    required this.initial,
    required this.types,
    this.departments,
    this.employees,
  });

  final RequestFilter initial;

  /// Every request type (removed ones included — old requests use them).
  final List<RequestType> types;

  /// Approvals with "All Departments": id → name (null = no Department field).
  final Map<String, String>? departments;

  /// Approvals: the requesters to choose from (null = no Employee field).
  final List<TimeTrackerEmployee>? employees;

  @override
  State<RequestFilterDialog> createState() => _RequestFilterDialogState();
}

class _RequestFilterDialogState extends State<RequestFilterDialog> {
  String? _type;
  RequestStatus? _status;
  DateTime? _from;
  DateTime? _to;
  String? _department;
  String? _employee;

  @override
  void initState() {
    super.initState();
    final RequestFilter f = widget.initial;
    _type = f.kind == RequestKind.transaction ? _transaction : f.requestTypeId;
    _status = f.status;
    _from = f.from;
    _to = f.to;
    _department = f.departmentId;
    _employee = (f.employeeEmail ?? '').isEmpty ? null : f.employeeEmail;
  }

  RequestFilter _collect() => RequestFilter(
        kind: _type == _transaction ? RequestKind.transaction : null,
        requestTypeId: _type == _transaction ? null : _type,
        status: _status,
        from: _from,
        to: _to,
        departmentId: _department,
        employeeEmail: _employee,
      );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final Map<String, String>? departments = widget.departments;
    final List<TimeTrackerEmployee>? people = widget.employees;
    final List<TimeTrackerEmployee> choosable = <TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in people ?? const <TimeTrackerEmployee>[])
        if (_department == null || e.departmentId == _department) e,
    ];
    final Widget type = TtFilterDropdown<String>(
      label: s.timeTrackerRequestType,
      value: _type,
      items: <(String, String)>[
        for (final RequestType t in widget.types) (t.id, t.name(isArabic: ar)),
        (_transaction, s.timeTrackerTransactionButton),
      ],
      onChanged: (String? v) => setState(() => _type = v),
    );
    final Widget status = TtFilterDropdown<RequestStatus>(
      label: s.timeTrackerStatus,
      value: _status,
      items: <(RequestStatus, String)>[
        for (final RequestStatus st in RequestStatus.values) (st, RequestText.statusLabel(context, st)),
      ],
      onChanged: (RequestStatus? v) => setState(() => _status = v),
    );
    final Widget? department = departments == null
        ? null
        : TtFilterDropdown<String>(
            label: s.timeTrackerDepartment,
            value: _department,
            items: <(String, String)>[for (final MapEntry<String, String> d in departments.entries) (d.key, d.value)],
            onChanged: (String? v) => setState(() {
              _department = v;
              // Child follows its parent (house rule): a requester of another
              // department is no longer a valid choice.
              if (v != null && _employee != null &&
                  !(people ?? const <TimeTrackerEmployee>[])
                      .any((TimeTrackerEmployee e) => e.email == _employee && e.departmentId == v)) {
                _employee = null;
              }
            }),
          );
    final Widget? employee = people == null
        ? null
        : TtFilterDropdown<String>(
            label: S.of(context).employee,
            value: choosable.any((TimeTrackerEmployee e) => e.email == _employee) ? _employee : null,
            items: <(String, String)>[for (final TimeTrackerEmployee e in choosable) (e.email, e.name(isArabic: ar))],
            onChanged: (String? v) => setState(() => _employee = v),
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
        if (department != null || employee != null)
          TtPair(start: department ?? employee!, end: department != null ? employee : null),
      ],
    );
  }
}
