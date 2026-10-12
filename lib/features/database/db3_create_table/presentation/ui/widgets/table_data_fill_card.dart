/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_fill_card.dart
/// Purpose: Declares `TableDataFillCard`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// The white card under "Table Name" on Table Name Details — Figma 7398:3042
/// (iPad H 1024) and 7398:3246, with the 768 twin at 7398:3144.
///
/// This is where a table is FILLED IN. Every earlier file in this module wrote
/// "the values belong to the Form Builder"; this widget is that, and it is the
/// screen the user reaches by tapping a table and typing.
///
/// LAID OUT BY COLUMN, NOT BY ROW
/// ------------------------------
/// The Figma stacks each column's cells under its own heading — "Department"
/// with four boxes under it, "Date" with four beside those — rather than
/// drawing a row of boxes per record. It reads as a form, which is what it is:
/// the person filling this in is going down one column at a time. Measured from
/// 7398:3076: the card is 879 wide, each column 250, the gap between them 15,
/// each box 36 tall on a 51 pitch, and the heading sits 15 above the first box.
///
/// The column widths do NOT stretch to fill the card. Two columns in an 879
/// card leave 349 of white on the right in the Figma, and that is deliberate —
/// a table with two columns should not draw two 430-wide boxes just because
/// there is room. The row scrolls horizontally once the columns outrun the
/// card, which is what makes a twelve-column table reachable at 768.
///
/// EACH CELL IS THE FIELD ITS COLUMN'S TYPE ASKS FOR
/// -------------------------------------------------
/// A Date column gets the calendar dropdown, everything else gets a text box
/// carrying that type's keystroke filter and keyboard (`TableColumnInputRules`).
/// The rule is `TableColumnType`'s and is not restated here — see that enum's
/// header for why the type owns both halves of it.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_column_input_rules.dart';

/// Signature of one cell edit — which row, which column, what was typed.
typedef TableCellChanged = void Function({
  required String rowId,
  required String columnId,
  required String value,
});

class TableDataFillCard extends StatelessWidget {
  const TableDataFillCard({
    super.key,
    required this.columns,
    required this.rows,
    required this.onCellChanged,
    this.invalidCells = const <String>{},
    this.enabled = true,
  });

  /// The NAMED columns, in saved order. Unnamed ones are filtered out upstream
  /// (`TableDataState.namedColumns`) — a column with no heading is one nothing
  /// can be filled into.
  final List<TableColumn> columns;

  /// The rows to draw, already narrowed by the search box.
  final List<TableDataRow> rows;

  final TableCellChanged onCellChanged;

  /// `rowId/columnId` of every cell whose text does not fit its column's type.
  /// Rendered as a red border in place rather than as a list of complaints
  /// somewhere else on the screen.
  final Set<String> invalidCells;

  final bool enabled;

  /// Measured from Figma 7398:3076.
  static const double _columnWidth = 250;
  static const double _columnGap = 15;
  static const double _fieldHeight = 36;
  static const double _rowGap = 15;

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    // No headings means no form to draw, and the fix is on another screen — so
    // this says so in words rather than showing the shared empty animation,
    // which would leave the user with nothing to act on. Same call
    // `TableRowsGrid` makes.
    if (columns.isEmpty) {
      return _shell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.sp),
          child: Text(
            strings.noNamedColumns,
            textAlign: TextAlign.center,
            style: StyleText.fontSize13Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    // Headings but no rows IS emptiness — a table created with zero rows, or a
    // search that matched none — so it gets the shared animation.
    if (rows.isEmpty) return _shell(child: const CustomEmptyState());

    return _shell(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < columns.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: _columnGap.sp),
              _column(context, columns[i]),
            ],
          ],
        ),
      ),
    );
  }

  /// The card itself — white, 8-radius, 15 of padding all round (7398:3076).
  Widget _shell({required Widget child}) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: child,
      );

  /// One heading with its cells stacked under it.
  Widget _column(BuildContext context, TableColumn column) {
    return SizedBox(
      width: _columnWidth.sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            column.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 11.sp),
          for (final TableDataRow row in rows) ...<Widget>[
            _cell(context, column: column, row: row),
            SizedBox(height: _rowGap.sp),
          ],
        ],
      ),
    );
  }

  /// One cell. The field is chosen by the column's type, never by what is
  /// already in the cell — a Date column with a half-typed value is still a
  /// Date column.
  Widget _cell(
    BuildContext context, {
    required TableColumn column,
    required TableDataRow row,
  }) {
    final String value = row.valueFor(column);
    final bool invalid = invalidCells.contains('${row.id}/${column.id}');

    // The error text is the TYPE's example rather than a sentence. The cell is
    // 250 wide and a sentence would wrap to three lines under every wrong cell;
    // "25/12/2026" says the same thing in the space available.
    final String? errorText = invalid ? column.type.formatExample : null;

    if (column.type == TableColumnType.date) {
      return CustomDropdownCalendar(
        height: _fieldHeight,
        value: _parseDate(value),
        enabled: enabled,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        hint: column.type.formatExample,
        errorText: errorText,
        // Formatted back to the SAME shape `TableColumnType.date` accepts, so a
        // date picked here and a date typed on the editing screen are one
        // string rather than two conventions for one day.
        dateFormatter: _formatDate,
        onChanged: (DateTime? picked) => onCellChanged(
          rowId: row.id,
          columnId: column.id,
          value: picked == null ? '' : _formatDate(picked),
        ),
      );
    }

    return CustomTextField(
      // Keyed by cell so Flutter cannot recycle one cell's controller into
      // another's slot when a row is removed above it — the same reasoning
      // `TableColumn.id` exists for on the create card.
      key: ValueKey<String>('${row.id}/${column.id}'),
      initialValue: value,
      height: _fieldHeight,
      enabled: enabled,
      hint: column.type.formatExample,
      errorText: errorText,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.r),
      keyboardType: TableColumnInputRules.keyboardFor(column.type),
      inputFormatters: TableColumnInputRules.formattersFor(
        column.type,
        maxLength: CreateTableLimits.cellMaxLength,
      ),
      onChanged: (String text) => onCellChanged(
        rowId: row.id,
        columnId: column.id,
        value: text,
      ),
    );
  }

  /// `dd/MM/yyyy` — the one shape `TableColumnType.date.accepts` passes.
  static String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// Null for anything that is not a complete date, which is what makes the
  /// calendar open on today rather than throwing on a half-typed cell.
  static DateTime? _parseDate(String value) {
    final RegExpMatch? match =
        RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(value.trim());
    if (match == null) return null;

    final DateTime parsed = DateTime(
      int.parse(match.group(3)!),
      int.parse(match.group(2)!),
      int.parse(match.group(1)!),
    );
    return parsed;
  }
}
