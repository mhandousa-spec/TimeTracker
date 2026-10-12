/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_rows_grid.dart
/// Purpose: Declares `TableRowsGrid`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// The data grid on "Table Name Details" — Figma `Group 1000005097`
/// (7398:4138) inside 7398:4102 / 4300 / 4690 / 4841, and its 768-wide twins
/// inside 7398:17048 / 4498. The same grid is the Preview screen, 7398:15210.
///
/// BUILT ON `Table`, NOT `DataTable` (17/8/2026)
/// ---------------------------------------------
/// Ported to match `ServiceTableWidget` in the services module, which is the
/// house pattern for a wide read-only table. `DataTable` was the wrong tool
/// here for three reasons the services table had already run into:
///
///   * it sizes columns to their CONTENT with no way to pin one, so the same
///     table drew different column widths on two screens;
///   * `columnSpacing` is a gap, not a width, so a long value and a short one
///     could not be given the same slot;
///   * its heading row cannot be given a decoration per row, which is what the
///     dark band needs.
///
/// `Table` takes `columnWidths` directly, so every column here is a measured
/// `FixedColumnWidth` and the grid scrolls horizontally when they outrun the
/// card — the same behaviour, and the same look, as the services list.
///
/// WHERE THE CELLS COME FROM
/// -------------------------
/// The table's own rows (`TableDataRow`), read from the `Rows` subcollection by
/// `TableDataCubit`. A cell the row has no entry for draws an em dash: a column
/// of nothing reads as a rendering failure, one of dashes reads as "no value
/// here yet", which is what it is.
///
/// DIRECTION IS PER CELL, NOT PER TABLE
/// ------------------------------------
/// A table can hold an Arabic column next to an English one — that is the whole
/// point of the bilingual fields elsewhere in this module — so each heading and
/// each value gets the direction its OWN script asks for, inside a table whose
/// overall direction follows the app locale. Same rule, same detection, as the
/// services table.

// ignore_for_file: unnecessary_string_interpolations
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';

class TableRowsGrid extends StatelessWidget {
  const TableRowsGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.onHeaderTap,
    this.onRowTap,
  });

  /// The table's NAMED columns, in saved order. Unnamed ones are filtered out
  /// upstream (`TableDataState.namedColumns`) — a column with no heading is one
  /// nothing can ever be filled into.
  final List<TableColumn> columns;

  /// The rows to draw, already narrowed by the search box.
  final List<TableDataRow> rows;

  /// Tapping the HEADING BAND opens the table's own screen — Figma 7398:3042,
  /// where it can be edited or imported into.
  ///
  /// The heading and not a button, because that is the gesture the design uses:
  /// this grid IS the table, and its heading is the thing that names it. Null
  /// leaves the band inert, which is what the Preview screen wants — a preview
  /// that navigates somewhere is not a preview.
  final VoidCallback? onHeaderTap;

  /// Optional per-row tap, wired the way `ServiceTableWidget` wires its own:
  /// every cell in the row is wrapped, so the whole band is the target rather
  /// than the text inside one column.
  final ValueChanged<TableDataRow>? onRowTap;

  /// Width of the leading "NO" column. Fixed, because a row number is never
  /// more than a few digits and letting it size to content would make it move
  /// between a table of 9 rows and one of 1000.
  static const double _numberColumnWidth = 60;

  /// Ceiling on a measured column. Past this a long value ellipsises instead of
  /// pushing every other column off the screen.
  static const double _maxColumnWidth = 300;

  /// Rough advance width of one character at the cell's 13sp. The services
  /// table uses the same 8, and it is a MEASURE, not a guess at the font: it
  /// only has to order columns sensibly, and the ellipsis handles the rest.
  static const double _perCharacter = 8;

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    // A table with no headings has no grid to draw, and the fix is on another
    // screen — so this says so in words rather than showing the shared empty
    // animation, which would leave the user with nothing to act on.
    if (columns.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.sp),
        child: Text(
          strings.noNamedColumns,
          textAlign: TextAlign.center,
          style: StyleText.fontSize13Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }

    // Headings but no rows IS emptiness — a table created with zero rows, or a
    // search that matched none — so it gets the shared animation.
    if (rows.isEmpty) return const CustomEmptyState();

    final bool isLight = !AppTheme.isDark;

    return AnimatedSizeWrap(
      child: Directionality(
        textDirection:
            context.isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Table(
              // Transparent, and present. `Table` draws no dividers without a
              // border, but it also does not round its own corners — the radius
              // has to be on the border for the header band to be clipped by
              // the ClipRRect above rather than squaring it off.
              border: TableBorder.all(
                color: AppColors.transparent,
                borderRadius: BorderRadius.circular(10.r),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: _columnWidths(context),
              children: <TableRow>[
                _headerRow(context, strings, isLight),
                for (int i = 0; i < rows.length; i++)
                  _dataRow(context, rows[i], i, isLight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widths ───────────────────────────────────────────────────────────────

  /// Function Name: [_columnWidths]
  ///
  /// Purpose: A measured `FixedColumnWidth` per column.
  ///
  /// Measured from the column's OWN contents — its heading and every value
  /// under it — rather than split evenly: a Status column holding "approved"
  /// and a Point-of-contact column holding a full name should not be the same
  /// width, and evenly-split columns make the short one wasteful and the long
  /// one unreadable at the same time.
  ///
  /// Returns: [Map] column index -> width.
  Map<int, TableColumnWidth> _columnWidths(BuildContext context) {
    return <int, TableColumnWidth>{
      0: FixedColumnWidth(_numberColumnWidth.sp),
      for (int i = 0; i < columns.length; i++)
        i + 1: FixedColumnWidth(_widthFor(context, columns[i])),
    };
  }

  double _widthFor(BuildContext context, TableColumn column) {
    double longest = column.name.length.toDouble();
    for (final TableDataRow row in rows) {
      longest = math.max(longest, row.valueFor(column).length.toDouble());
    }

    // The floor is narrower in portrait: the same 140 that reads as comfortable
    // on a landscape tablet leaves a portrait one showing two columns.
    final double floor = context.isLandscape ? 140.sp : 120.sp;
    final double measured =
        math.min(longest * _perCharacter.sp, _maxColumnWidth.sp);

    return math.max(measured, floor);
  }

  // ── Rows ─────────────────────────────────────────────────────────────────

  /// The dark heading band. Black in light mode and the divider grey in dark —
  /// the services table's own pair, so the two modules' tables read as one
  /// component.
  TableRow _headerRow(
    BuildContext context,
    CreateTableStrings strings,
    bool isLight,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        color: isLight ? AppColors.black : AppColors.blackShadow,
      ),
      children: <Widget>[
        _headerCell(strings.rowNumber),
        for (final TableColumn column in columns) _headerCell(column.name),
      ],
    );
  }

  Widget _headerCell(String label) {
    final Widget text = Directionality(
      textDirection:
          _isArabicText(label) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          // The band is dark in BOTH themes, so the heading text is white in
          // both rather than following the body text colour.
          style:
              StyleText.fontSize16Weight600.copyWith(color: AppColors.white),
        ),
      ),
    );

    if (onHeaderTap == null) return text;

    return InkWell(
      onTap: onHeaderTap,
      // Every heading cell carries the tap, so the whole band is the target —
      // the same wrapping `ServiceTableWidget` uses to make a row tappable.
      child: text,
    );
  }

  TableRow _dataRow(
    BuildContext context,
    TableDataRow row,
    int index,
    bool isLight,
  ) {
    final bool isEven = index.isEven;
    final Color rowColor = isLight
        ? (isEven ? AppColors.oddRowColor : AppColors.white)
        : (isEven ? AppColors.darkDashboardTable : AppColors.black);

    final List<Widget> cells = <Widget>[
      _textCell(context, '${row.displayNumber}', maxLines: 1),
      for (final TableColumn column in columns)
        _valueCell(context, row.valueFor(column)),
    ];

    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: onRowTap == null
          ? cells
          : cells
              .map((Widget cell) => InkWell(
                    onTap: () => onRowTap!(row),
                    child: cell,
                  ))
              .toList(growable: false),
    );
  }

  // ── Cells ────────────────────────────────────────────────────────────────

  /// Padded cell with the body text style merged in, so a cell that builds its
  /// own child does not have to restate the style.
  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: _cellStyle(context),
        child: child,
      ),
    );
  }

  Widget _textCell(
    BuildContext context,
    String text, {
    int maxLines = 2,
  }) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
      ),
    );
  }

  /// One value, in its own script's direction.
  ///
  /// Empty renders as an em dash in the muted colour rather than as nothing —
  /// see this file's header.
  Widget _valueCell(BuildContext context, String value) {
    final bool empty = value.trim().isEmpty;

    return _cell(
      context,
      Directionality(
        textDirection:
            _isArabicText(value) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Text(
          empty ? '—' : value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: empty
              ? _cellStyle(context).copyWith(color: AppColors.secondaryText)
              : _cellStyle(context),
        ),
      ),
    );
  }

  TextStyle _cellStyle(BuildContext context) =>
      StyleText.fontSize14Weight400.copyWith(
        color: AppTheme.isDark ? AppColors.white : AppColors.text,
      );

  /// True when the text is written in Arabic script.
  ///
  /// Checked on the FIRST letter rather than the whole string, unlike the
  /// services table's `^[؀-ۿ\s]+$`: a cell holding "23 Feb 2024" or
  /// "مبيعات 2024" mixes digits and letters, and an all-or-nothing pattern
  /// calls both of those LTR — which puts an Arabic value's punctuation on the
  /// wrong end. The first letter is what the paragraph's direction follows.
  static bool _isArabicText(String text) {
    for (final int unit in text.runes) {
      // Latin letters settle it the other way.
      if ((unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A)) {
        return false;
      }
      // Arabic, Arabic Supplement, Arabic Extended-A, Presentation Forms.
      if ((unit >= 0x0600 && unit <= 0x06FF) ||
          (unit >= 0x0750 && unit <= 0x077F) ||
          (unit >= 0x08A0 && unit <= 0x08FF) ||
          (unit >= 0xFB50 && unit <= 0xFDFF) ||
          (unit >= 0xFE70 && unit <= 0xFEFF)) {
        return true;
      }
    }
    return false;
  }
}
