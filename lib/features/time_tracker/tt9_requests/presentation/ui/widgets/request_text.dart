/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_text.dart
/// Purpose: Declares `RequestText` — the localized values of one request
///          shared by the cards, the table, the details pages and Export
///          (status label + colour, type name, timeframe, total time,
///          approval step labels) — and `RequestStatusLabel` ("Status:
///          Pending").
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Inventory §C (`661:14909` cards, `661:14645` table): statuses Approved
/// (green), Pending (orange), Rejected (red), Under Review (yellow),
/// Canceled / Canceled By HR (red); a transaction reads "Transaction" with
/// Check In / Check Out instead of the timeframe. Dates "15 Oct 2024",
/// times "10:00 PM" (owner rules). Total time: all day = days, otherwise
/// "7:30 Hrs".

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestText {
  const RequestText._();

  static bool _ar(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar';

  /// Function Name: [statusLabel] / [statusColor]
  ///
  /// Return type: [String] / [Color]
  static String statusLabel(BuildContext context, RequestStatus status) {
    final S s = S.of(context);
    switch (status) {
      case RequestStatus.pending:
        return s.timeTrackerPending;
      case RequestStatus.approved:
        return s.timeTrackerApproved;
      case RequestStatus.rejected:
        return s.timeTrackerRejected;
      case RequestStatus.underReview:
        return s.timeTrackerUnderReview;
      case RequestStatus.canceled:
        return s.timeTrackerCanceled;
      case RequestStatus.canceledByHr:
        return s.timeTrackerCanceledByHr;
    }
  }

  static Color statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppColors.orange;
      case RequestStatus.approved:
        return AppColors.lightGreen;
      case RequestStatus.underReview:
        return AppColors.yellow;
      case RequestStatus.rejected:
      case RequestStatus.canceled:
      case RequestStatus.canceledByHr:
        return AppColors.red;
    }
  }

  /// Function Name: [bucketLabel] / [bucketColor]
  ///
  /// Purpose: The status counters' labels / colours (null = default).
  ///
  /// Return type: [String] / [Color?]
  static String bucketLabel(BuildContext context, RequestBucket bucket) {
    final S s = S.of(context);
    switch (bucket) {
      case RequestBucket.all:
        return s.timeTrackerAll;
      case RequestBucket.approved:
        return s.timeTrackerApproved;
      case RequestBucket.pending:
        return s.timeTrackerPending;
      case RequestBucket.rejected:
        return s.timeTrackerRejected;
      case RequestBucket.underReview:
        return s.timeTrackerUnderReview;
      case RequestBucket.canceled:
        return s.timeTrackerCanceled;
    }
  }

  static Color? bucketColor(RequestBucket bucket) {
    switch (bucket) {
      case RequestBucket.all:
        return null;
      case RequestBucket.approved:
        return statusColor(RequestStatus.approved);
      case RequestBucket.pending:
        return statusColor(RequestStatus.pending);
      case RequestBucket.rejected:
        return statusColor(RequestStatus.rejected);
      case RequestBucket.underReview:
        return statusColor(RequestStatus.underReview);
      case RequestBucket.canceled:
        return statusColor(RequestStatus.canceled);
    }
  }

  /// Function Name: [typeName]
  ///
  /// Purpose: "Sick Leave" (app language) or "Transaction".
  ///
  /// Return type: [String]
  static String typeName(BuildContext context, TimeTrackerRequest r, RequestsState state) {
    if (r.isTransaction) return S.of(context).timeTrackerTransactionButton;
    final RequestType? t = state.typeOf(r);
    return t == null ? TimeTrackerFormat.dash : t.name(isArabic: _ar(context));
  }

  /// Function Name: [typeNames]
  ///
  /// Purpose: The type name in both languages (notifications).
  ///
  /// Return type: [TimeTrackerTypeName]
  static TimeTrackerTypeName typeNames(BuildContext context, TimeTrackerRequest r, RequestsState state) {
    if (r.isTransaction) {
      return TimeTrackerTypeName(en: S.of(context).timeTrackerTransactionButton);
    }
    final RequestType? t = state.typeOf(r);
    return TimeTrackerTypeName(en: t?.name(isArabic: false) ?? '', ar: t?.name(isArabic: true) ?? '');
  }

  /// "15 Oct 2024 At 10:00 PM".
  static String dateAt(BuildContext context, DateTime value) => S.of(context).timeTrackerDateAtTime(
        TimeTrackerFormat.date(context, value),
        TimeTrackerFormat.time(context, value),
      );

  /// Function Name: [timeframe]
  ///
  /// Purpose: "15 Oct 2024 To 17 Oct 2024" (with times when not all day).
  ///
  /// Return type: [String]
  static String timeframe(BuildContext context, TimeTrackerRequest r) {
    String one(DateTime d) => r.isAllDay ? TimeTrackerFormat.date(context, d) : dateAt(context, d);
    return S.of(context).timeTrackerTimeframeValue(one(r.startAt), one(r.endAt));
  }

  /// Function Name: [totalTime]
  ///
  /// Purpose: "3 Days" for an all-day request, "7:30 Hrs" otherwise.
  ///
  /// Return type: [String]
  static String totalTime(BuildContext context, TimeTrackerRequest r) {
    if (r.isAllDay && !r.isTransaction) {
      final int days = (r.totalMinutes / RequestFormRules.minutesPerDay).round();
      // UI pass 9/10/2026: "1 Day" / "يوم واحد" (was "1 Days").
      return TimeTrackerFormat.days(context, days);
    }
    return TimeTrackerFormat.hours(context, r.totalMinutes);
  }

  /// The request date (its creation; the start while unsaved).
  static String requestDate(BuildContext context, TimeTrackerRequest r) =>
      TimeTrackerFormat.date(context, r.audit.createdAt ?? r.startAt);

  /// Function Name: [stepRole] / [stepDecision]
  ///
  /// Purpose: "Manager" / "HR", and "Approved" / "Rejected" / "Pending".
  ///
  /// Return type: [String]
  static String stepRole(BuildContext context, RequestApprovalStep step) =>
      step.step == ApprovalStepKind.manager ? S.of(context).timeTrackerManagerStep : S.of(context).timeTrackerHrStep;

  static String stepDecision(BuildContext context, RequestApprovalStep step) {
    final S s = S.of(context);
    switch (step.decision) {
      case ApprovalDecision.approved:
        return s.timeTrackerApproved;
      case ApprovalDecision.rejected:
        return s.timeTrackerRejected;
      case ApprovalDecision.pending:
        return s.timeTrackerPending;
      // 9/10/2026 (code review): a step closed without its own decision (never
      // shown — `visibleSteps` hides it; existing "Skipped" label reused).
      case ApprovalDecision.skipped:
        return s.timeTrackerImportActionSkip;
    }
  }

  /// Column titles of the Requests table / Export (without "No").
  static List<String> headers(BuildContext context) {
    final S s = S.of(context);
    return <String>[
      s.timeTrackerRequestDate,
      s.timeTrackerRequestType,
      s.timeTrackerStartDate,
      s.timeTrackerEndDate,
      s.timeTrackerTotalTime,
      s.timeTrackerStatus,
      // 13/10/2026 (owner H1).
      s.timeTrackerApprovedByColumn,
    ];
  }

  /// "Approved By": who approved so far (manager, then HR), "–" if nobody.
  static String approvedBy(BuildContext context, TimeTrackerRequest r, RequestsState state) {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<String> names = <String>[
      for (final RequestApprovalStep st in r.approvalSteps)
        if (st.decision == ApprovalDecision.approved && !st.isCancellation && st.approverEmail.isNotEmpty)
          state.employeeOf(st.approverEmail)?.name(isArabic: ar) ?? st.approverEmail,
    ];
    return names.isEmpty ? TimeTrackerFormat.dash : names.toSet().join(' · ');
  }

  /// Function Name: [cells]
  ///
  /// Purpose: One row's values in [headers] order.
  ///
  /// Return type: [List<String>]
  static List<String> cells(BuildContext context, TimeTrackerRequest r, RequestsState state) {
    String when(DateTime d) => r.isAllDay ? TimeTrackerFormat.date(context, d) : dateAt(context, d);
    return <String>[
      requestDate(context, r),
      typeName(context, r, state),
      when(r.startAt),
      when(r.endAt),
      totalTime(context, r),
      statusLabel(context, r.status),
      approvedBy(context, r, state),
    ];
  }

  static const List<double> _widths = <double>[50, 130, 160, 190, 190, 110, 130, 170];

  /// Table columns: "No" + [headers].
  static List<TtColumn> columns(BuildContext context) {
    final List<String> h = <String>[S.of(context).timeTrackerColumnNo, ...headers(context)];
    return <TtColumn>[for (int i = 0; i < h.length; i++) TtColumn(h[i], _widths[i])];
  }

  /// Table cells: index + [cells], status coloured.
  static List<TtCell> tableCells(BuildContext context, int index, TimeTrackerRequest r, RequestsState state) {
    final List<String> c = cells(context, r, state);
    return <TtCell>[
      TtCell(TimeTrackerFormat.count(context, index + 1)),
      for (int i = 0; i < c.length; i++)
        TtCell(c[i], color: i == c.length - 2 ? statusColor(r.status) : null),
    ];
  }
}

/// "Status: Pending" (small, the value in its status colour).
class RequestStatusLabel extends StatelessWidget {
  const RequestStatusLabel({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '${S.of(context).timeTrackerStatus}: ',
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText),
        children: <InlineSpan>[
          TextSpan(
            text: RequestText.statusLabel(context, status),
            style: StyleText.fontSize10Weight400.copyWith(color: RequestText.statusColor(status)),
          ),
        ],
      ),
    );
  }
}
