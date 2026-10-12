/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_quick_cards.dart
/// Purpose: Declares the two Time Tracker quick-button home cards —
///          `TimeTrackerQuickRequestsCard` (Check In · Check Out · Requests)
///          and `TimeTrackerQuickApprovalsCard` (Check In · Check Out ·
///          Approvals).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Time Tracker phase 6 (brief §A), Figma `2583:26873` / `2583:26886`
/// (125 wide, three stacked yellow buttons):
///   * Check In / Check Out run the module's OWN flows (`CheckInFlows` over a
///     `CheckInCubit` from get_it): the location sheet, the geofence check,
///     Wrong Location, the confirm / success dialogs and the System Log —
///     exactly as on the module's main page.
///   * While checked in, the Check In button turns grey and shows the live
///     worked time ("02 : 15 Hour", refreshed every 20 s); Check Out is grey
///     until there is a session to close.
///   * Requests / Approvals open the module on that tab.
/// A button whose switch is off is not shown (owner rule: buttons disappear
/// with their switch); with neither Check In nor the tab switch the card
/// shows the no-access message.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/time_tracker_home_cards_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/time_tracker/time_tracker_home_card_parts.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_flows.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Figma "Tracker" — Check In · Check Out · Requests.
class TimeTrackerQuickRequestsCard extends StatelessWidget {
  const TimeTrackerQuickRequestsCard({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) =>
      const _QuickCard(card: TimeTrackerHomeCard.quickRequests, tab: TimeTrackerTab.requests);
}

/// Figma "Tracker" — Check In · Check Out · Approvals.
class TimeTrackerQuickApprovalsCard extends StatelessWidget {
  const TimeTrackerQuickApprovalsCard({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) =>
      const _QuickCard(card: TimeTrackerHomeCard.quickApprovals, tab: TimeTrackerTab.approvals);
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.card, required this.tab});

  final TimeTrackerHomeCard card;

  /// The third button's tab.
  final TimeTrackerTab tab;

  @override
  Widget build(BuildContext context) {
    final GetIt sl = GetIt.instance;
    final TimeTrackerAccess? access = sl.isRegistered<TimeTrackerAccess>() ? sl<TimeTrackerAccess>() : null;
    final bool checkIn = (access?.canCheckInAndOut ?? false) && sl.isRegistered<CheckInCubit>();
    final bool showTab = tab == TimeTrackerTab.approvals
        ? (access?.canViewApprovals ?? false)
        : (access?.canViewRequests ?? false);
    final S s = S.of(context);
    final Widget scope = TimeTrackerHomeCardScope(
      card: card,
      title: s.tracker,
      width: kHomeWidgetNarrowWidth,
      builder: (BuildContext context, TimeTrackerHomeCardsState state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (checkIn) const _CheckInButtons(),
          if (checkIn && showTab) SizedBox(height: 4.h),
          if (showTab)
            TimeTrackerQuickButton(
              key: ValueKey<String>('timeTrackerQuick_${tab.name}'),
              label: tab == TimeTrackerTab.approvals ? s.timeTrackerTabApprovals : s.timeTrackerTabRequests,
              onTap: () => openTimeTrackerModule(context, tab: tab),
            ),
        ],
      ),
    );
    // The Check In / Check Out cubit sits above the card (only with the
    // switch — no work set-up is loaded otherwise).
    return checkIn ? BlocProvider<CheckInCubit>(create: (_) => sl<CheckInCubit>()..init(), child: scope) : scope;
  }
}

/// Check In (or the live timer while checked in) and Check Out.
class _CheckInButtons extends StatelessWidget {
  const _CheckInButtons();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<CheckInCubit, CheckInState>(
      builder: (BuildContext context, CheckInState state) {
        final bool ready = state.status == CheckInLoadStatus.ready && !state.isBusy;
        final AttendanceDay? day = state.day;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (state.isCheckedIn && day != null)
              _LiveTimerButton(key: const ValueKey<String>('timeTrackerQuickTimer'), day: day)
            else
              TimeTrackerQuickButton(
                key: const ValueKey<String>('timeTrackerQuickCheckIn'),
                label: s.timeTrackerCheckIn,
                onTap: ready ? () => CheckInFlows.checkIn(context) : null,
              ),
            SizedBox(height: 4.h),
            TimeTrackerQuickButton(
              key: const ValueKey<String>('timeTrackerQuickCheckOut'),
              label: s.timeTrackerCheckOut,
              onTap: ready && state.isCheckedIn ? () => CheckInFlows.checkOut(context) : null,
            ),
          ],
        );
      },
    );
  }
}

/// The grey (disabled) Check In button showing the worked time of [day],
/// refreshed every 20 s — same figure as the module's live timer.
class _LiveTimerButton extends StatefulWidget {
  const _LiveTimerButton({required this.day, super.key});

  final AttendanceDay day;

  @override
  State<_LiveTimerButton> createState() => _LiveTimerButtonState();
}

class _LiveTimerButtonState extends State<_LiveTimerButton> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    int minutes = 0;
    for (final AttendanceSession session in widget.day.sessions) {
      minutes += AttendanceCalculator.workMinutes(session, now);
    }
    return TimeTrackerQuickButton(
      label: '${TimeTrackerFormat.clock(context, minutes)} ${S.of(context).timeTrackerHourUnit}',
    );
  }
}
