/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_page.dart
/// Purpose: Declares `TableDataPage`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// "Table Name Details", the Form Builder's copy of it — Figma 7398:3042 /
/// 3246 (iPad H 1024) and 7398:3144 (768).
///
/// WHY THERE ARE TWO SCREENS WITH THIS NAME
/// ----------------------------------------
/// `TableDetailsPage` is the db2 one (7398:4102): the info card, the four
/// tiles, Access / Edit / Delete, and the table's data underneath as a grid.
/// This is the one the Form Builder section draws (7398:3042): the table's
/// name, its data laid out as a form, and the two buttons that change it —
/// Edit and Import.
///
/// They are not duplicates and neither is redundant. The first is ABOUT the
/// table — who reaches it, what it is for, how many rows it has. This one is
/// the table's CONTENTS. The route between them is the grid's heading band:
///
///     Database Details  ->  Table Name Details (db2, the grid)
///                              tap the grid's heading
///                       ->  Table Name Details (this, Edit / Import)
///                              tap Edit
///                       ->  Editing Table Name (the editable grid)
///
/// The breadcrumb reads the same on both because the Figma's does — the second
/// crumb differs ("Database Details" against "Database Name") and that is the
/// design's own doing, so this screen follows 7398:3042 and names the database.
///
/// IT OWNS NO WRITES
/// -----------------
/// The card is display-only and both buttons hand off: Edit opens
/// `EditTableDataPage`, Import parses a file and opens the same editor on what
/// it held. `TableDataCubit.save` stays the one place a row is written.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_import_mode.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_data_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/edit_table_data_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/import_table_dialog.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_data_fill_card.dart';

class TableDataPage extends StatefulWidget {
  const TableDataPage({
    super.key,
    required this.database,
    required this.table,
  });

  final DatabaseEntity database;
  final DatabaseTableEntity table;

  /// Opens the screen and resolves with the table as it stands, or null when
  /// nothing was saved.
  ///
  /// The screen behind it — the db2 details page — is holding a record whose
  /// `row_count` and `columns` the editor can change, which is why this hands
  /// the whole table back rather than a bare "something happened".
  static Future<DatabaseTableEntity?> open(
    BuildContext context, {
    required DatabaseEntity database,
    required DatabaseTableEntity table,
  }) {
    return Navigator.of(context).push<DatabaseTableEntity>(
      MaterialPageRoute<DatabaseTableEntity>(
        builder: (_) => TableDataPage(database: database, table: table),
      ),
    );
  }

  @override
  State<TableDataPage> createState() => _TableDataPageState();
}

class _TableDataPageState extends State<TableDataPage> {
  late final TableDataCubit _cubit = TableDataCubit(table: widget.table);

  /// Whether anything was saved while this screen was open. Decides what the
  /// screen behind it gets back — a screen that was only looked at must not
  /// make the grid underneath redraw.
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _close() =>
      Navigator.of(context).pop(_changed ? _cubit.state.table : null);

  // ── Actions ──────────────────────────────────────────────────────────────

  /// "Edit" (Figma 7398:3042) opens the editable grid, 7398:15076.
  ///
  /// Reached by tapping the card as well: the card here is display-only, and a
  /// grid of boxes that swallows a tap is the most confusing thing this screen
  /// could do.
  Future<void> _onEditPressed() async {
    final DatabaseTableEntity? saved = await EditTableDataPage.open(
      context,
      database: widget.database,
      table: _cubit.state.table,
    );
    if (saved == null || !mounted) return;

    _changed = true;
    // Re-read rather than trusting what came back: the editor wrote the rows
    // and this screen renders them, and the record it returns carries the
    // columns and the count but not the cells.
    await _cubit.load();
  }

  /// "Import" (Figma 7398:4041). Reads a file and opens the editor on it.
  ///
  /// The rows land UNSAVED so the user sees what arrived before it is stored,
  /// and Undo covers it — see `TableDataCubit.applyImportedRows`. That is also
  /// why the import cannot happen on this screen: this one has no Save.
  Future<void> _onImportPressed() async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    final TableImportRequest? request = await showImportTableDialog(
      context: context,
      columns: _cubit.state.namedColumns,
    );
    if (request == null || !mounted) return;

    if (request.result.rows.isEmpty) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: strings.importMatchedNothing,
        closeLabel: strings.close,
      );
      return;
    }

    // Headings the table has no column for are reported rather than dropped
    // quietly — the user picked that file believing it fitted.
    if (request.result.unmatchedHeadings.isNotEmpty) {
      await showWarningDialog(
        context: context,
        title: strings.importTable,
        subtitle: strings.importUnmatchedHeadings(
          request.result.unmatchedHeadings.join(', '),
        ),
        closeLabel: strings.close,
      );
      if (!mounted) return;
    }

    final DatabaseTableEntity? saved = await EditTableDataPage.open(
      context,
      database: widget.database,
      table: _cubit.state.table,
      importedRows: request.result.rows,
      importOverwrites: request.mode == TableImportMode.overwrite,
    );
    if (saved == null || !mounted) return;

    _changed = true;
    await _cubit.load();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final bool isArabic = context.isArabic;

    final String databaseTitle = FormatHelper.capitalize(
      widget.database.localizedTitle(isArabic: isArabic),
    );

    return BlocBuilder<TableDataCubit, TableDataState>(
      bloc: _cubit,
      builder: (BuildContext context, TableDataState state) {
        final String tableName = FormatHelper.capitalize(
          state.table.localizedName(isArabic: isArabic),
        );

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) return;
            _close();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: strings.database,
              secondTitle: DatabaseDetailsStrings.of(context)
                  .detailsCrumb(databaseTitle),
              thirdTitle: strings.tableDetailsCrumb(tableName),
              onFirstTap: _close,
              onSecondTap: _close,
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _actions(strings),
                    SizedBox(height: 20.sp),

                    // The table's own name over the card, 24pt semibold
                    // (Figma 7398:3044) — the one place on this screen that
                    // says WHICH table is being filled in.
                    Text(
                      tableName,
                      style: StyleText.fontSize24Weight600
                          .copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 12.sp),

                    if (state.isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.sp),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _onEditPressed,
                        behavior: HitTestBehavior.opaque,
                        child: TableDataFillCard(
                          columns: state.namedColumns,
                          rows: state.rows,
                          // DISPLAY ONLY. Figma 7398:3042 puts no Save on this
                          // screen — Edit and Import are the two buttons — and
                          // a card that takes typing it can never persist is a
                          // card that loses work.
                          enabled: false,
                          onCellChanged: _cubit.cellChanged,
                        ),
                      ),
                    SizedBox(height: metrics.blockGap),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Edit and Import, both on the trailing edge (Figma 7398:3042). Nothing sits
  /// on the leading one: neither button leaves or ends anything, so the
  /// leading-edge slot this module reserves for Discard and Access stays empty
  /// rather than being filled for symmetry.
  Widget _actions(CreateTableStrings strings) {
    return Row(
      children: <Widget>[
        const Spacer(),
        customButtonWithSvg(
          title: strings.edit,
          function: _onEditPressed,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: DatabaseDetailsAssets.edit,
          widthImage: 18.r,
          heightImage: 18.r,
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
        SizedBox(width: 10.sp),
        customButtonWithSvg(
          title: strings.import,
          function: _onImportPressed,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: CreateTableAssets.importTable,
          widthImage: 18.r,
          heightImage: 18.r,
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
