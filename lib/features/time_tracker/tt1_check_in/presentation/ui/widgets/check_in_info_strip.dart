/// Module: time_tracker / tt1_check_in / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: check_in_info_strip.dart
/// Purpose: Declares `CheckInInfoStrip` — the white card under the profile
///          card once the day has a session: Date · Check In Time · Location
///          · Break · Check Out Time.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:12612` (89 high card, five #F5F5F5 boxes 130 × 69, radius 8,
/// label Regular 16 grey over value Regular 16). The boxes wrap on narrow
/// screens (iPhone). Check In Time = the day's FIRST check-in; Location =
/// the latest session's place; Break = the allowed break; Check Out Time =
/// the last check-out ("-" while checked in).
/// Updated: 9/10/2026 - UI fix round 1 (same class as owner finding 2): a
/// label never ends in "…" ("Check Out Ti…" on iPad portrait). Like Figma
/// (`661:18593`: five boxes that hug their text), each box is at least as
/// wide as its label / value; on a tablet the five share one row (the spare
/// width split evenly); when they cannot (iPhone, narrow panes) they wrap
/// two per row and a label may take a second line.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/check_in_options.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CheckInInfoStrip extends StatelessWidget {
  const CheckInInfoStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckInCubit, CheckInState>(
      builder: (BuildContext context, CheckInState state) {
        final AttendanceDay? day = state.day;
        if (!state.showInfoStrip || day == null) return const SizedBox.shrink();
        final S s = S.of(context);
        final AttendanceSession last = day.sessions.last;
        final int breakMinutes = state.allowedBreakMinutes;
        final List<_InfoItem> items = <_InfoItem>[
          _InfoItem(s.timeTrackerDate, TimeTrackerFormat.date(context, day.date)),
          _InfoItem(
            s.timeTrackerCheckInTime,
            TimeTrackerFormat.time(context, day.firstCheckInAt),
          ),
          _InfoItem(s.timeTrackerLocation, _placeOf(context, state, last)),
          _InfoItem(
            s.timeTrackerBreak,
            breakMinutes > 0
                ? s.timeTrackerMinutesValue(TimeTrackerFormat.count(context, breakMinutes))
                : s.timeTrackerNoBreak,
          ),
          _InfoItem(
            s.timeTrackerCheckOutTime,
            TimeTrackerFormat.time(context, day.lastCheckOutAt),
          ),
        ];
        return Container(
          width: double.infinity,
          padding: EdgeInsetsDirectional.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: CardStyles.radius(),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double gap = 10.w;
              final List<double> natural = <double>[
                for (final _InfoItem item in items) _InfoBox.naturalWidth(context, item),
              ];
              final double need =
                  natural.fold<double>(0, (double a, double b) => a + b) + gap * (items.length - 1);
              if (!context.isPhone && need <= box.maxWidth) {
                final double extra = (box.maxWidth - need) / items.length;
                return Row(
                  children: <Widget>[
                    for (int i = 0; i < items.length; i++) ...<Widget>[
                      if (i > 0) SizedBox(width: gap),
                      SizedBox(width: natural[i] + extra, child: _InfoBox(item: items[i])),
                    ],
                  ],
                );
              }
              final double half = (box.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: 10.h,
                children: <Widget>[
                  for (final _InfoItem item in items)
                    SizedBox(width: half, child: _InfoBox(item: item, wrap: true)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static String _placeOf(
    BuildContext context,
    CheckInState state,
    AttendanceSession session,
  ) {
    String name = '';
    final List<WorkLocation> known = <WorkLocation>[
      if (state.setup != null) state.setup!.location,
      for (final CheckInOption o in state.options)
        if (o.location != null) o.location!,
    ];
    for (final WorkLocation l in known) {
      if (l.id == session.workLocationId) {
        name = context.isArabic && l.nameAr.isNotEmpty ? l.nameAr : l.nameEn;
        break;
      }
    }
    return TimeTrackerFormat.placeLabel(
      context,
      session.workLocationType,
      officeName: name,
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.item, this.wrap = false});

  final _InfoItem item;

  /// Narrow layout: the label may take a second line (the box grows).
  final bool wrap;

  static TextStyle _style() => StyleText.fontSize14Weight400;

  /// Width the box needs to show its label and value on one line each.
  static double naturalWidth(BuildContext context, _InfoItem item) {
    double widthOf(String text) {
      final TextPainter p = TextPainter(
        text: TextSpan(text: text, style: _style()),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final double w = p.width;
      p.dispose();
      return w;
    }

    final double label = widthOf(item.label);
    final double value = widthOf(item.value);
    return (label > value ? label : value) + 24.w + 2;
  }

  @override
  Widget build(BuildContext context) {
    // 13/10/2026 (owner): the box hugs its two lines — half the old space
    // between the label and the value (the fixed 69 height pushed them
    // apart).
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            item.label,
            maxLines: wrap ? 2 : 1,
            softWrap: true,
            style: _style().copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 6.h),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _style().copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }
}
