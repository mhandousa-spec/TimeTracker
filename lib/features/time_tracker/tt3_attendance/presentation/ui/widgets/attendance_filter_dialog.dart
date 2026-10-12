/// Module: time_tracker / tt3_attendance / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_filter_dialog.dart
/// Purpose: Declares `AttendanceFilterDialog` — the Attendance "Filter"
///          popup: Status · Work Location Type · From Date – To Date,
///          Reset / Apply.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Pops the new `AttendanceFilter` (Reset pops `AttendanceFilter.none`).
/// Updated: 9/10/2026 - UI quality pass (owner finding 13:45 #3): the same
/// professional pattern as the Requests filter (`TtFilterFrame`) — Status,
/// Work Location Type (Office / Remote / Client Site) and a date RANGE; the
/// meaningless "Day" and "Total Time" are gone. To before From shows an
/// error under To and greys Apply.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_filter_frame.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AttendanceFilterDialog extends StatefulWidget {
  const AttendanceFilterDialog({super.key, required this.initial});

  final AttendanceFilter initial;

  @override
  State<AttendanceFilterDialog> createState() => _AttendanceFilterDialogState();
}

class _AttendanceFilterDialogState extends State<AttendanceFilterDialog> {
  AttendanceStatus? _status;
  WorkLocationType? _type;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final AttendanceFilter f = widget.initial;
    _status = f.status;
    _type = f.type;
    _from = f.from;
    _to = f.to;
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return TtFilterFrame(
      applyKey: const ValueKey<String>('attendanceFilterApply'),
      canApply: TtDateRangeFields.isValid(_from, _to),
      onReset: () => Navigator.of(context).pop(AttendanceFilter.none),
      onApply: () => Navigator.of(context).pop(
        AttendanceFilter(status: _status, type: _type, from: _from, to: _to),
      ),
      rows: <Widget>[
        TtPair(
          start: TtFilterDropdown<AttendanceStatus>(
            label: s.timeTrackerStatus,
            value: _status,
            items: <(AttendanceStatus, String)>[
              for (final AttendanceStatus st in AttendanceStatus.values) (st, TimeTrackerFormat.statusLabel(context, st)),
            ],
            onChanged: (AttendanceStatus? v) => setState(() => _status = v),
          ),
          end: TtFilterDropdown<WorkLocationType>(
            label: s.timeTrackerWorkLocationType,
            value: _type,
            items: <(WorkLocationType, String)>[
              for (final WorkLocationType t in WorkLocationType.values) (t, TimeTrackerFormat.placeLabel(context, t)),
            ],
            onChanged: (WorkLocationType? v) => setState(() => _type = v),
          ),
        ),
        TtDateRangeFields(
          from: _from,
          to: _to,
          onFrom: (DateTime? d) => setState(() => _from = d),
          onTo: (DateTime? d) => setState(() => _to = d),
        ),
      ],
    );
  }
}
