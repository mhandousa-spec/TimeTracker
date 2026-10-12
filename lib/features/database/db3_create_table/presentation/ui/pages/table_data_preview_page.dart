/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_preview_page.dart
/// Purpose: Declares `TableDataPreviewPage`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// "Preview" — Figma 7398:15210, reached from the Preview button on Editing
/// Table Name (7398:15076).
///
/// The table as a READER sees it: a dark heading band, striped rows, no boxes
/// and nothing to press. That contrast is the whole point of the screen —
/// somebody who has been typing into thirty grey boxes cannot tell what the
/// result looks like, and this is the answer without having to save first.
///
/// IT TAKES ROWS RATHER THAN READING THEM
/// --------------------------------------
/// The rows are handed in by the editing screen, unsaved. Re-reading the
/// subcollection here would preview what is STORED, which is exactly what the
/// user is not asking about — they want to see what they have just typed.
/// It also means this screen owns no cubit and does no writes.
///
/// The grid itself is `TableRowsGrid`, the same widget the module already had —
/// its dark heading band and striping ARE this Figma frame, drawn back when the
/// cells had nothing in them.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_rows_grid.dart';

class TableDataPreviewPage extends StatelessWidget {
  const TableDataPreviewPage({
    super.key,
    required this.database,
    required this.table,
    required this.rows,
  });

  final DatabaseEntity database;
  final DatabaseTableEntity table;

  /// The rows as the editing screen left them — unsaved.
  final List<TableDataRow> rows;

  static Future<void> open(
    BuildContext context, {
    required DatabaseEntity database,
    required DatabaseTableEntity table,
    required List<TableDataRow> rows,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TableDataPreviewPage(
          database: database,
          table: table,
          rows: rows,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool isArabic = context.isArabic;

    final String databaseTitle = FormatHelper.capitalize(
      database.localizedTitle(isArabic: isArabic),
    );

    // NAMED columns only. A preview is what the reader will see, and a column
    // with no heading is not something anybody will ever see — showing it here
    // would preview a state that cannot be saved.
    final List<TableColumn> columns = table.columns
        .where((TableColumn column) => column.isNamed)
        .toList(growable: false);

    // Empty rows are dropped for the same reason `TableDataCubit.save` drops
    // them: they are not going to be stored, so previewing them would show the
    // user four rows that are about to become none.
    final List<TableDataRow> filled = rows
        .where((TableDataRow row) => !row.isEmpty)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: strings.database,
        secondTitle:
            DatabaseDetailsStrings.of(context).detailsCrumb(databaseTitle),
        thirdTitle: strings.previewCrumb,
        onFirstTap: () => Navigator.of(context).pop(),
        onSecondTap: () => Navigator.of(context).pop(),
        child: CreateDatabaseMetrics.pageScroll(
          context,
          child: TableRowsGrid(columns: columns, rows: filled),
        ),
      ),
    );
  }
}
