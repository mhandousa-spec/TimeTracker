/// Module: time_tracker / tt3_attendance / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_table.dart
/// Purpose: Declares the attendance list widgets — `AttendanceTableView`
///          (tablet: the dark-header table) and `AttendanceCardList` (phone:
///          one card per day) — plus `AttendanceRowText`, the localized cell
///          values shared by both, by search and by Export.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:14182`: header row #2D2D2D with white Medium 16 labels
/// (No · Attendance Date · Status · Oncoming Time · Leaving Time · Break
/// Time · Total Time), zebra rows, status text coloured (Present green,
/// Absent red, Excused grey, Vacation yellow, Sick Leave dark red; Late
/// orange). The core has no generic table, so the To-Do / CRM practice of a
/// module table is followed; it resizes with `AnimatedSizeWrap` (animation
/// standard: tables = Size). Cells are 12–14 regular; long values ellipsize.
/// Updated: 9/10/2026 - UI fix round 1: header / zebra colours from
/// `TtTableColors` (Figma #2D2D2D header, #F1F1F1 / white rows; dark mode
/// keeps a dark header with white titles) — same as every module table.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The visible values of one attendance row.
class AttendanceRowText {
  const AttendanceRowText._();

  /// Column titles, in table order.
  static List<String> headers(BuildContext context) {
    final S s = S.of(context);
    return <String>[
      s.timeTrackerColumnNo,
      s.timeTrackerAttendanceDate,
      s.timeTrackerStatus,
      s.timeTrackerOncomingTime,
      s.timeTrackerLeavingTime,
      s.timeTrackerBreakTime,
      s.timeTrackerTotalTime,
    ];
  }

  /// Function Name: [cells]
  ///
  /// Purpose: The row's values (without the No column).
  ///
  /// Return type: [List<String>]
  static List<String> cells(BuildContext context, AttendanceDay day) => <String>[
        TimeTrackerFormat.date(context, day.date),
        TimeTrackerFormat.statusLabel(context, day.status),
        TimeTrackerFormat.time(context, day.firstCheckInAt),
        TimeTrackerFormat.time(context, day.lastCheckOutAt),
        TimeTrackerFormat.mins(context, day.breakMinutes),
        TimeTrackerFormat.hours(context, day.totalWorkMinutes),
      ];

  /// Search text of the row.
  static String describe(BuildContext context, AttendanceDay day) =>
      cells(context, day).join(' ');
}

/// Column weights (No · Date · Status · In · Out · Break · Total).
const List<int> _flex = <int>[5, 12, 10, 11, 11, 9, 9];

class AttendanceTableView extends StatelessWidget {
  const AttendanceTableView({super.key, required this.days});

  final List<AttendanceDay> days;

  @override
  Widget build(BuildContext context) {
    final List<String> headers = AttendanceRowText.headers(context);
    return AnimatedSizeWrap(
      child: ClipRRect(
        borderRadius: CardStyles.radius(),
        child: Column(
          children: <Widget>[
            Container(
              color: TtTableColors.header,
              padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 11.sp),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < headers.length; i++)
                    Expanded(
                      flex: _flex[i],
                      child: Text(
                        headers[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                ],
              ),
            ),
            for (int r = 0; r < days.length; r++) _row(context, r, days[r]),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, int index, AttendanceDay day) {
    final List<String> cells = <String>[
      TimeTrackerFormat.count(context, index + 1),
      ...AttendanceRowText.cells(context, day),
    ];
    return Container(
      key: ValueKey<String>('attendanceRow_${day.id}'),
      color: TtTableColors.row(index),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 11.sp),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < cells.length; i++)
            Expanded(
              flex: _flex[i],
              child: Text(
                cells[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // 9/10/2026 (UI pass): table values 12 (house: value 12;
                // Figma 661:14182 rows).
                style: StyleText.fontSize12Weight400.copyWith(
                  color: i == 2
                      ? TimeTrackerFormat.statusColor(day.status)
                      : AppColors.text,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Phone: one card per day (date + status on one row, the four times
/// under it).
class AttendanceCardList extends StatelessWidget {
  const AttendanceCardList({super.key, required this.days});

  final List<AttendanceDay> days;

  @override
  Widget build(BuildContext context) {
    final List<String> headers = AttendanceRowText.headers(context);
    return AnimatedSizeWrap(
      child: Column(
        children: <Widget>[
          for (final AttendanceDay day in days)
            Container(
              key: ValueKey<String>('attendanceRow_${day.id}'),
              margin: EdgeInsetsDirectional.only(bottom: 10.h),
              padding: EdgeInsetsDirectional.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: CardStyles.radius(),
              ),
              child: _card(context, headers, AttendanceRowText.cells(context, day), day),
            ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    List<String> headers,
    List<String> cells,
    AttendanceDay day,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                cells[0],
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
              ),
            ),
            Text(
              cells[1],
              style: StyleText.fontSize14Weight500
                  .copyWith(color: TimeTrackerFormat.statusColor(day.status)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        for (int i = 2; i < cells.length; i++)
          Padding(
            padding: EdgeInsetsDirectional.only(top: 4.h),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    headers[i + 1],
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
                Text(
                  cells[i],
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
