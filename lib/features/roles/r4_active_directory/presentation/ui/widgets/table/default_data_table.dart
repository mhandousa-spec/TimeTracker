/// Module: roles / r4_active_directory / presentation / ui / widgets / table
///
///*************************** FILE INFO ****************************///
/// File Name: default_data_table.dart
/// Purpose: Declares `DefaultDataTable`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 31/8/2026 - Added the opt-in [fillWidth]. See its doc comment.
/// Updated: 9/10/2026 - The LayoutBuilder is now used only when [fillWidth] is
///          set. Unconditional, it broke every caller wrapped in an
///          IntrinsicWidth — Active Directory showed an empty table.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';


import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';


//Youssef Ashraf , mohammed Ashraf
///Default Table Style for active_directory
class DefaultDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? columnSpacing;

  /// Stretch the table to the full width available instead of letting it size
  /// to its content.
  ///
  /// ADDED 31/8/2026. The horizontal `SingleChildScrollView` below hands the
  /// `DataTable` UNBOUNDED width, so the table measures its columns from their
  /// own content and stops there. When that total is narrower than the screen
  /// — a table with few columns, or short values — the result is a table
  /// floating in unused space, which is what the Services dashboard showed.
  ///
  /// Opt-in rather than the default: this widget is shared by System Logs,
  /// Active Directory and User Management, whose tables have enough columns to
  /// already fill their space. Flipping the default would relayout all of them
  /// for the sake of one caller.
  ///
  /// The constraint is a MINIMUM, not a fixed width — see [build]. A wide table
  /// keeps its content width and still scrolls; only a narrow one is stretched.
  final bool fillWidth;

  const DefaultDataTable(
      {super.key,
      required this.columns,
      required this.rows,
      this.columnSpacing,
      this.fillWidth = false});

  @override
  Widget build(BuildContext context) {
    var isLandScape = ContextExtension(context).isLandscape;
    bool isDarkMode =
        themeController.currentTheme.value == AppColors.darkTheme;

    // FIXED 9/10/2026 — EMPTY ACTIVE DIRECTORY. The LayoutBuilder below was
    // added on 31/8/2026 for EVERY caller, but only [fillWidth] reads its
    // constraints. Active Directory wraps this table in an `IntrinsicWidth`
    // (csv_table_builders2.dart `_buildTableArea`), and a LayoutBuilder cannot
    // report intrinsic sizes: "LayoutBuilder does not support returning
    // intrinsic dimensions" was thrown on every layout, the table was never
    // laid out, and the Users Data / Invalid Data tabs drew nothing as soon as
    // they had one row. Callers that do not ask for [fillWidth] now get the
    // same tree they had before 31/8/2026 (no LayoutBuilder), so intrinsic
    // measurement works again; [fillWidth] callers are unchanged.
    if (!fillWidth) {
      return _scrollingTable(_buildTable(isLandScape, isDarkMode), null);
    }

    // The LayoutBuilder sits OUTSIDE both scroll views on purpose: inside the
    // horizontal one `constraints.maxWidth` is infinite, which is the whole
    // reason the table cannot size itself to the screen. Out here it is the
    // real width the parent is offering. The vertical scroll view below only
    // unbounds the HEIGHT, so it passes this width straight through.
    return LayoutBuilder(
      builder: (context, constraints) => _scrollingTable(
        _buildTable(isLandScape, isDarkMode),
        constraints,
      ),
    );
  }

  /// The styled [DataTable]. Split out 9/10/2026 so the [fillWidth] and
  /// non-[fillWidth] paths in [build] share one definition.
  Widget _buildTable(bool isLandScape, bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.r),
        topRight: Radius.circular(8.r),
      ),
      child: DataTable(
        border: TableBorder(
          horizontalInside: BorderSide(
            width: 0,
            color: isDarkMode ? AppColors.totalBlack : AppColors.white,
          ),
        ),
        // columnSpacing: 45.w, //columnSpacing,
        // AppColors.header is already 0xff2D2D2D in the light palette and
        // 0xFF171717 in the dark one, so it replaces the manual ternary.
        headingRowColor: WidgetStatePropertyAll(AppColors.header),
        dataRowMinHeight: 46.h,
        dataRowMaxHeight: 46.h,
        headingRowHeight: 46.h,
        horizontalMargin: isLandScape ? 29.w : 16.w,
        dividerThickness: 0,
        showCheckboxColumn: false,
        columns: columns,
        rows: rows,
      ),
    );
  }

  /// Both scroll views around [table]. [constraints] is the LayoutBuilder's,
  /// and is `null` on the non-[fillWidth] path (9/10/2026), where nothing
  /// reads it.
  Widget _scrollingTable(Widget table, BoxConstraints? constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // `minWidth`, deliberately, and never a fixed width or a tight
        // `SizedBox`: DataTable hands surplus space to its columns, so a
        // narrow table is stretched to fill the row, while a table wider
        // than the screen is left at its own width and still scrolls
        // horizontally. A fixed width would have squeezed the wide case
        // into an overflow.
        //
        // `hasBoundedWidth` guards the case where this widget is itself
        // placed inside another horizontal scroll view or an unbounded Row:
        // maxWidth would be infinity there, and an infinite minWidth is a
        // layout crash rather than a wide table.
        child: fillWidth && constraints != null && constraints.hasBoundedWidth
            ? ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: table,
              )
            : table,
      ),
    );
  }
}
