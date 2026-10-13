/// Module: time_tracker / tt8_request_types / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_filter_dialog.dart
/// Purpose: Declares `RequestTypeFilterDialog` (+ `RequestTypeStatusChoice`)
///          — the Request Types "Filter" popup: Status (All / Active /
///          Inactive / Removed) · Reset / Apply.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Same shell as the other Time Tracker filters. "All" lists every status,
/// Removed included (owner rule). Pops a `RequestTypeStatusChoice` (its
/// `status` null = All) so "All" can be told apart from a dismissed popup.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_filter_frame.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/widgets/request_type_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The popup's answer (null [status] = All).
class RequestTypeStatusChoice {
  const RequestTypeStatusChoice(this.status);

  final RequestTypeStatus? status;
}

class RequestTypeFilterDialog extends StatefulWidget {
  const RequestTypeFilterDialog({super.key, required this.initial});

  final RequestTypeStatus? initial;

  @override
  State<RequestTypeFilterDialog> createState() => _RequestTypeFilterDialogState();
}

class _RequestTypeFilterDialogState extends State<RequestTypeFilterDialog> {
  late RequestTypeStatus? _status = widget.initial;

  /// Updated: 12/10/2026 (owner): the SAME filter as Approvals / Requests —
  /// the shared `TtFilterFrame` (header · fields · Reset / Apply) with an
  /// "All"-first `TtFilterDropdown`.
  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return TtFilterFrame(
      applyKey: const ValueKey<String>('requestTypeFilterApply'),
      onReset: () => Navigator.of(context).pop(const RequestTypeStatusChoice(null)),
      onApply: () => Navigator.of(context).pop(RequestTypeStatusChoice(_status)),
      // 13/10/2026 (owner): a single field takes the full width.
      rows: <Widget>[
        TtFilterDropdown<RequestTypeStatus>(
          key: const ValueKey<String>('requestTypeStatusFilter'),
          label: s.timeTrackerStatus,
          value: _status,
          items: <(RequestTypeStatus, String)>[
            for (final RequestTypeStatus st in RequestTypeStatus.values) (st, RequestTypeText.status(context, st)),
          ],
          onChanged: (RequestTypeStatus? v) => setState(() => _status = v),
        ),
      ],
    );
  }
}
