/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_card.dart
/// Purpose: Declares `RequestCard` — one of the employee's own requests on
///          the Requests tab (card view).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:14909`: top-end "Status: Pending"; icon box + "Request Type:
/// Sick Leave"; Request Date · Requested Timeframe · Total Time; a
/// transaction shows "Request Type: Transaction" and Check In / Check Out
/// instead of the timeframe. A pending card has the yellow Send Reminder
/// (only with `Send_Request_Reminder`). Tap → the request's details (LOW
/// haptic, no splash).
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - owner review: names / titles take up to two lines
/// (no "…" on a normal name such as "Bayanatz Transformation").
/// Updated: 9/10/2026 - UI quality pass: 10 padding; the card hugs its
/// content (`TtCardGrid`), values wrap instead of "…".

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_flows.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request, required this.state, required this.onTap});

  final TimeTrackerRequest request;
  final RequestsState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool canRemind = request.status == RequestStatus.pending &&
        GetIt.instance<TimeTrackerAccess>().canSendRequestReminder;
    return GestureDetector(
      key: ValueKey<String>('requestCard_${request.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        onTap();
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(10.r),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: RequestStatusLabel(status: request.status),
            ),
            Row(
              children: <Widget>[
                const RequestIconBox(),
                SizedBox(width: 10.w),
                Text('${s.timeTrackerRequestType}: ',
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                Expanded(
                  child: Text(RequestText.typeName(context, request, state),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            RequestInfoLine(
              icon: const TtGlyph.svg(TtAssets.calendar),
              label: s.timeTrackerRequestDate,
              value: RequestText.requestDate(context, request),
            ),
            ...RequestCardLines.timeLines(context, request),
            // Fills only when a neighbour in the row is taller (TtCardGrid).
            const Spacer(),
            if (canRemind) ...<Widget>[
              SizedBox(height: 10.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: KeyedSubtree(
                  key: ValueKey<String>('requestCardReminder_${request.id}'),
                  child: RequestOutlinedButton(
                    label: s.timeTrackerSendRequestReminder,
                    icon: const TtGlyph.svg(TtAssets.reminder),
                    color: AppColors.primary,
                    filled: true,
                    onTap: () => RequestFlows.sendReminder(context, request),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The time lines shared by the request and approval cards / details.
class RequestCardLines {
  const RequestCardLines._();

  /// Function Name: [timeLines]
  ///
  /// Purpose: Timeframe + Total Time, or Check In / Check Out + Total Time
  /// for a transaction.
  ///
  /// Return type: [List<Widget>]
  static List<Widget> timeLines(BuildContext context, TimeTrackerRequest r) {
    final S s = S.of(context);
    return <Widget>[
      if (r.isTransaction) ...<Widget>[
        RequestInfoLine(
          icon: const TtGlyph.icon(Icons.login),
          label: s.timeTrackerCheckIn,
          value: RequestText.dateAt(context, r.startAt),
        ),
        RequestInfoLine(
          icon: const TtGlyph.svg(TtAssets.logout),
          label: s.timeTrackerCheckOut,
          value: RequestText.dateAt(context, r.endAt),
        ),
      ] else
        RequestInfoLine(
          icon: const TtGlyph.svg(TtAssets.calendar),
          label: s.timeTrackerRequestedTimeframe,
          value: RequestText.timeframe(context, r),
        ),
      RequestInfoLine(
        icon: const TtGlyph.svg(TtAssets.clock),
        label: s.timeTrackerTotalTime,
        value: RequestText.totalTime(context, r),
      ),
    ];
  }
}
