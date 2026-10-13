/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_table.dart
/// Purpose: Declares `TimeTrackerTable` (+ `TtColumn`) — the module's wide
///          table: dark header row, zebra rows, fixed column widths and a
///          horizontal scroll when the columns do not fit (Locations has 14,
///          Request Types 14 — Figma `661:37368` / `661:36293`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Same look as the phase-2 `AttendanceTableView` (header #2D2D2D with white
/// Medium 14 labels, rows 14 regular, long values ellipsize). Resizes with
/// `AnimatedSizeWrap` (animation standard: tables = Size). Row taps fire a
/// LOW haptic; there is no hover / splash highlight (owner rule).
/// Updated: 9/10/2026 - UI fix round 1 (owner finding 5, Figma
/// `661:14645`): rows are the Figma zebra — #F1F1F1 first, then white — so
/// the table shows as its own block on the #F5F5F5 page (the first row used
/// to be the page colour and the table had no visible container); dark mode
/// uses the house table pair and a dark header (the header used to turn
/// WHITE with white titles in dark mode). See [TtTableColors]. A table
/// wider than the screen (Locations: 16 columns) fades its hidden edge
/// (`TtOverflowFade`) instead of cutting a column title in half.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_tab_strip.dart';

/// The module's table colours (light = Figma `661:14645`; dark = the house
/// table pair used by the Database access tables).
abstract class TtTableColors {
  /// Header band: #2D2D2D in light, translucent black in dark — dark in
  /// both themes, so its titles are white in both.
  static Color get header => AppTheme.isDark ? AppColors.blackShadow : AppColors.black;

  /// Row [index] (0-based): #F1F1F1 / white in light, #28282B / #1E1F24 in
  /// dark.
  static Color row(int index) => index.isEven
      ? (AppTheme.isDark ? AppColors.tableRowDark : AppColors.evenRowColor)
      : (AppTheme.isDark ? AppColors.tableDarkBackground : AppColors.oddRowColor);
}

/// 13/10/2026 (owner rule): the SAME gap between every pair of table
/// columns (header and rows), so a long header never runs into its
/// neighbour ("Oncoming TimeLeaving Time").
double get ttTableColumnGap => 12.w;

/// One column: its title and width (unscaled; `.w` is applied).
class TtColumn {
  const TtColumn(this.title, this.width);

  final String title;
  final double width;
}

/// One cell: plain text (optionally coloured) or a custom widget.
class TtCell {
  const TtCell(this.text, {this.color}) : child = null;
  const TtCell.widget(Widget this.child)
      : text = '',
        color = null;

  final String text;
  final Color? color;
  final Widget? child;
}

class TimeTrackerTable extends StatelessWidget {
  const TimeTrackerTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowKeys = const <Key>[],
    this.onRowTap,
  });

  final List<TtColumn> columns;
  final List<List<TtCell>> rows;

  /// Optional key per row (tests).
  final List<Key> rowKeys;
  final ValueChanged<int>? onRowTap;

  @override
  Widget build(BuildContext context) {
    // The column gaps are NOT counted here: a table that fit the card before
    // still stretches (its columns give the gaps back); only a scrolling
    // table grows by them (see [_table]).
    final double total = columns.fold<double>(0, (double s, TtColumn c) => s + c.width.w) + 20.w;
    return AnimatedSizeWrap(
      child: TtOverflowFade(
        child: _table(total),
      ),
    );
  }

  Widget _table(double total) {
    return ClipRRect(
      borderRadius: CardStyles.radius(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final double width =
              total < box.maxWidth ? box.maxWidth : total + ttTableColumnGap * (columns.length - 1);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                children: <Widget>[
                  _line(
                    color: TtTableColors.header,
                    cells: <Widget>[
                      for (final TtColumn c in columns)
                        // 13/10/2026 (owner rule): table text wraps, never "…".
                        Text(c.title,
                            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.white)),
                    ],
                    stretch: total < box.maxWidth,
                  ),
                  for (int r = 0; r < rows.length; r++) _row(r, total < box.maxWidth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(int r, bool stretch) {
    final Widget line = _line(
      key: r < rowKeys.length ? rowKeys[r] : null,
      color: TtTableColors.row(r),
      stretch: stretch,
      cells: <Widget>[
        for (final TtCell cell in rows[r])
          cell.child ??
              Text(cell.text,
                  style: StyleText.fontSize12Weight400.copyWith(color: cell.color ?? AppColors.text)),
      ],
    );
    final ValueChanged<int>? tap = onRowTap;
    if (tap == null) return line;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        tap(r);
      },
      child: line,
    );
  }

  Widget _line({Key? key, required Color color, required List<Widget> cells, required bool stretch}) {
    return Container(
      key: key,
      color: color,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 11.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: ttTableColumnGap,
        children: <Widget>[
          for (int i = 0; i < columns.length; i++)
            stretch
                ? Expanded(flex: columns[i].width.round(), child: i < cells.length ? cells[i] : const SizedBox())
                : SizedBox(width: columns[i].width.w, child: i < cells.length ? cells[i] : const SizedBox()),
        ],
      ),
    );
  }
}
