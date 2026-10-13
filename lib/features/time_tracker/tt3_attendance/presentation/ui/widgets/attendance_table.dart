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
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
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
/// 13/10/2026 (owner F2): the six data columns are EQUAL; only "No" is
/// narrow.
const List<int> _flex = <int>[4, 10, 10, 10, 10, 10, 10];

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

  /// 13/10/2026 (owner O1, Figma mobile card): icon + "Label: value" on
  /// every line — Attendance Date, then Oncoming / Leaving / Break / Total
  /// — and "Status: Present" at the top end.
  Widget _card(
    BuildContext context,
    List<String> headers,
    List<String> cells,
    AttendanceDay day,
  ) {
    // Figma icons (exported from the mobile attendance card).
    const List<String> icons = <String>[TtAssets.dayOncoming, TtAssets.dayLeaving, TtAssets.dayBreak, TtAssets.dayTotal];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _line(TtAssets.dayCalendar, headers[1], cells[0])),
            SizedBox(width: 8.w),
            Text.rich(
              TextSpan(
                text: '${headers[2]}: ',
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                children: <InlineSpan>[
                  TextSpan(
                    text: cells[1],
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: TimeTrackerFormat.statusColor(day.status)),
                  ),
                ],
              ),
            ),
          ],
        ),
        for (int i = 2; i < cells.length; i++)
          Padding(
            padding: EdgeInsetsDirectional.only(top: 8.h),
            child: _line(icons[i - 2], headers[i + 1], cells[i]),
          ),
      ],
    );
  }

  /// [icon] "Label: value".
  Widget _line(String icon, String label, String value) {
    return Row(
      children: <Widget>[
        TtIcon(TtGlyph.svg(icon), size: 20.r, color: AppColors.secondaryText),
        SizedBox(width: 8.w),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText),
              children: <InlineSpan>[
                TextSpan(
                  text: value,
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
