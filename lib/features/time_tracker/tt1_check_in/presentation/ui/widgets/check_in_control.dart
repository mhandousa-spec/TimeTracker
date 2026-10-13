/// Module: time_tracker / tt1_check_in / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: check_in_control.dart
/// Purpose: Declares `CheckInControl` — the right side of the profile card:
///          yellow Check In, or the live timer + Pause / Resume (black) +
///          Check Out (yellow).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma states: not checked in / checked out → Check In (`661:10375`,
/// `661:13423`); checked in → "00 : 01 Hour" + Pause + Check Out
/// (`661:12245`), no Pause when the rules forbid it (`661:12639`); paused →
/// Resume + Check Out (`661:13030`). Buttons 100 × 35, radius 8; timer
/// SemiBold 22. [compact] (header collapsed, `661:13832`) drops the timer.
/// The timer counts from the stored sessions (pauses are not work — owner
/// decision 5). Updated: 13/10/2026 - owner: hours : minutes : seconds,
/// ticking every second; while paused, the pause time left.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_flows.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_sheet.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CheckInControl extends StatelessWidget {
  const CheckInControl({super.key, this.compact = false});

  /// Header collapsed: buttons only.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckInCubit, CheckInState>(
      builder: (BuildContext context, CheckInState state) {
        if (state.status == CheckInLoadStatus.initial ||
            state.status == CheckInLoadStatus.loading) {
          return SizedBox(
            width: 35.r,
            height: 35.r,
            child: const CircleProgressMaster(),
          );
        }
        if (!state.isCheckedIn) return _CheckInButton(busy: state.isBusy);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (!compact && state.day != null) ...<Widget>[
              _LiveTimer(day: state.day!, pauseLimitMinutes: state.allowedPauseMinutes),
              SizedBox(height: 8.h),
            ],
            _RunningButtons(state: state),
          ],
        );
      },
    );
  }
}

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.busy});

  final bool busy;

  @override
  Widget build(BuildContext context) {
    return ShrinkOnTap(
      key: const ValueKey<String>('timeTrackerCheckInButton'),
      child: customButtonWithSvg(
        title: S.of(context).timeTrackerCheckIn,
        function: busy ? () {} : () => CheckInFlows.checkIn(context),
        color: AppColors.primary,
        colorBorder: AppColors.transparent,
        image: kCheckInIcon,
        widthImage: 22.r,
        heightImage: 22.r,
        svgColor: AppColors.textButton,
        textStyle:
            StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
      ),
    );
  }
}

class _RunningButtons extends StatelessWidget {
  const _RunningButtons({required this.state});

  final CheckInState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool showPauseResume = state.isPaused || state.canPause;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showPauseResume) ...<Widget>[
          // QA KP-TT-016 (9/10/2026): the buttons hug their label (at least
          // 100) — "تسجيل الانصراف" wrapped and was clipped in a fixed 100.
          ConstrainedBox(
            key: const ValueKey<String>('timeTrackerPauseButton'),
            constraints: BoxConstraints(minWidth: 100.w),
            child: customButton(
              wrapContent: true,
              contentHorizontalPadding: 16.sp,
              title: state.isPaused ? s.timeTrackerResume : s.timeTrackerPause,
              function: state.isBusy
                  ? () {}
                  : () => CheckInFlows.pauseOrResume(context),
              color: AppColors.blackButton,
              // 9/10/2026 UI fix round 1: `blackButton` turns white in dark
              // mode, so the label must turn dark there (it was white on
              // white).
              textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppTheme.isDark ? AppColors.black : AppColors.white),
            ),
          ),
          SizedBox(width: 15.w),
        ],
        ConstrainedBox(
          key: const ValueKey<String>('timeTrackerCheckOutButton'),
          constraints: BoxConstraints(minWidth: 100.w),
          child: ShrinkOnTap(
            child: customButton(
              wrapContent: true,
              contentHorizontalPadding: 16.sp,
              title: s.timeTrackerCheckOut,
              function:
                  state.isBusy ? () {} : () => CheckInFlows.checkOut(context),
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
            ),
          ),
        ),
      ],
    );
  }
}

/// "01 : 05 : 09" — worked time of the shown day, to the second (13/10/2026
/// owner: hours, minutes and seconds). While paused, the pause time left
/// under it ("Pause left: 12 : 30"), or how long the pause has run when
/// there is no limit; past the limit it says so in red.
class _LiveTimer extends StatefulWidget {
  const _LiveTimer({required this.day, required this.pauseLimitMinutes});

  final AttendanceDay day;

  /// The day's longest pause; 0 = no limit.
  final int pauseLimitMinutes;

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
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
    final S s = S.of(context);
    final DateTime now = DateTime.now();
    int worked = 0;
    int paused = 0;
    for (final AttendanceSession session in widget.day.sessions) {
      worked += AttendanceCalculator.workSeconds(session, now);
      paused += AttendanceCalculator.pauseSeconds(session, now);
    }
    final int limit = widget.pauseLimitMinutes * 60;
    String? pauseLine;
    Color pauseColor = AppColors.secondaryText;
    if (widget.day.isPaused) {
      if (limit <= 0) {
        pauseLine = s.timeTrackerPausedFor(TimeTrackerFormat.clockSeconds(context, paused));
      } else if (paused <= limit) {
        pauseLine = s.timeTrackerPauseLeft(TimeTrackerFormat.clockSeconds(context, limit - paused, short: limit < 3600));
        pauseColor = AppColors.orange;
      } else {
        pauseLine = s.timeTrackerPauseOver(
            TimeTrackerFormat.clockSeconds(context, paused - limit, short: paused - limit < 3600));
        pauseColor = AppColors.red;
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '${TimeTrackerFormat.clockSeconds(context, worked)} ${s.timeTrackerHourUnit}',
          key: const ValueKey<String>('timeTrackerLiveTimer'),
          style: StyleText.fontSize22Weight600.copyWith(
            color: AppColors.text,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
        if (pauseLine != null)
          Text(
            pauseLine,
            key: const ValueKey<String>('timeTrackerPauseLeft'),
            style: StyleText.fontSize12Weight500.copyWith(color: pauseColor),
          ),
      ],
    );
  }
}
