/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_table_data_page.dart
/// Purpose: Declares `EditTableDataPage`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// "Editing Table Name" — Figma 7398:15076 (iPad H 1024), with the Data Type
/// dropdown drawn open at 7398:15661 / 15961 and the 768 twin at 7398:15349.
///
/// The screen a table is actually FILLED IN on. Table Name Details (7398:3042)
/// displays what is here and offers Edit and Import; this is what Edit opens,
/// and it is the only screen in the module that writes a row.
///
/// WHAT IT OWNS THAT THE DETAILS SCREEN DOES NOT
/// ---------------------------------------------
///   Undo / Redo                whole-snapshot history, see `TableDataCubit`
///   Remove Selection           the ticked rows, by id
///   + Row / + Column           append one of either
///   the heading fields         a column's NAME and its Data Type
///   the red circle per column  remove the column and its values
///   Discard / Preview / Save
///
/// A COLUMN IS EDITED HERE AND ON THE CREATE CARD, AND THAT IS FINE
/// ----------------------------------------------------------------
/// `CreateTablePage` also edits columns — it is where they are declared. The
/// difference is what each screen is FOR: that card sets a table's shape before
/// there is anything in it, while this one adjusts the shape around data that
/// already exists, which is why removing a column here has to warn about the
/// values underneath it and there does not. Both write through
/// `updateTable`, so there is still one writer.
///
/// The grid scrolls in BOTH directions and the heading row scrolls with it.
/// A frozen heading would need two synchronised scroll controllers and a third
/// for the tick column; at `maxColumns` of 50 the honest answer is a grid the
/// user can push around, which is what the Figma's own overflow shows.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_data_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/table_data_preview_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_column_input_rules.dart';

import '../../../../../../generated/l10n.dart';

class EditTableDataPage extends StatefulWidget {
  const EditTableDataPage({
    super.key,
    required this.database,
    required this.table,
    this.importedRows,
    this.importOverwrites = false,
  });

  /// The parent, carried for the second crumb.
  final DatabaseEntity database;

  final DatabaseTableEntity table;

  /// Rows read from a file on the Import Table dialog (Figma 7398:4041),
  /// applied once the stored rows have loaded.
  ///
  /// They arrive UNSAVED and go on the undo stack like anything else typed
  /// here, so the user sees what the file held before it is stored and can take
  /// it back. An import that wrote straight through would be the only action in
  /// this module the user could not reconsider.
  final List<TableDataRow>? importedRows;

  /// "Type Of Import": true replaces the existing rows, false appends after
  /// them. Ignored when [importedRows] is null.
  final bool importOverwrites;

  /// Opens the screen and resolves with the saved table, or null when the user
  /// left without saving.
  ///
  /// The TABLE and not the rows: the caller is the details screen, which holds
  /// a record whose `row_count` and `columns` this screen can both change, and
  /// it re-reads the rows itself.
  static Future<DatabaseTableEntity?> open(
    BuildContext context, {
    required DatabaseEntity database,
    required DatabaseTableEntity table,
    List<TableDataRow>? importedRows,
    bool importOverwrites = false,
  }) {
    return Navigator.of(context).push<DatabaseTableEntity>(
      MaterialPageRoute<DatabaseTableEntity>(
        builder: (_) => EditTableDataPage(
          database: database,
          table: table,
          importedRows: importedRows,
          importOverwrites: importOverwrites,
        ),
      ),
    );
  }

  @override
  State<EditTableDataPage> createState() => _EditTableDataPageState();
}

class _EditTableDataPageState extends State<EditTableDataPage> {
  late final TableDataCubit _cubit = TableDataCubit(table: widget.table);

  /// Measured from Figma 7398:15076.
  static const double _tickColumnWidth = 40;
  static const double _cellWidth = 250;
  static const double _cellGap = 15;
  static const double _fieldHeight = 36;
  static const double _typeDropdownWidth = 96;

  @override
  void initState() {
    super.initState();
    _open();
  }

  /// Load, then fold in an import if one came with the route.
  ///
  /// In that order and awaited: applying the file's rows before the stored ones
  /// arrive would have `load` overwrite them a moment later, and an "Overwrite"
  /// import would silently become a no-op.
  Future<void> _open() async {
    await _cubit.load();
    final List<TableDataRow>? imported = widget.importedRows;
    if (imported == null || !mounted) return;

    _cubit.applyImportedRows(imported, overwrite: widget.importOverwrites);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ── Leaving ──────────────────────────────────────────────────────────────

  /// Discard, the breadcrumb and the system back gesture all come through here,
  /// so there is one answer to "what happens to unsaved work" instead of three.
  Future<void> _close() async {
    if (!_cubit.state.isDirty) {
      Navigator.of(context).pop();
      return;
    }

    final CreateTableStrings strings = CreateTableStrings.of(context);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.discardChanges,
      subtitle: strings.discardRowsSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    Navigator.of(context).pop();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Preview renders the table as the reader will see it (Figma 7398:15210).
  ///
  /// It shows the UNSAVED state deliberately — previewing what is on screen is
  /// the only thing "preview" can usefully mean, and saving first would make
  /// the button a second Save.
  Future<void> _onPreviewPressed() async {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final TableDataState state = _cubit.state;

    if (state.rows.every((TableDataRow row) => row.isEmpty)) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: strings.nothingToPreview,
        closeLabel: strings.close,
      );
      return;
    }

    if (!mounted) return;
    await TableDataPreviewPage.open(
      context,
      database: widget.database,
      table: state.table,
      rows: state.rows,
    );
  }

  /// Save writes the rows and the columns, then leaves with the saved record.
  ///
  /// The invalid-cell guard runs BEFORE the write rather than letting the
  /// repository refuse: the cells are already outlined in red on this screen,
  /// and the dialog only has to say how many there are and send the user back
  /// to them.
  Future<void> _onSavePressed() async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    final Set<String> invalid = _cubit.invalidCells;
    if (invalid.isNotEmpty) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: strings.invalidCellsSubtitle(invalid.length),
        closeLabel: strings.close,
      );
      return;
    }

    final bool saved = await _cubit.save();
    if (!mounted) return;

    if (!saved) {
      final String message =
          _cubit.state.errorMessage ?? strings.tablesLoadFailed;
      _cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    await showSuccessDialog(
      context: context,
      title: strings.successTitle,
      subtitle: strings.rowsSavedSubtitle,
      closeLabel: strings.close,
    );
    if (!mounted) return;

    Navigator.of(context).pop(_cubit.state.table);
  }

  /// The red circle on a heading. Asks first, because the values under the
  /// column go with it — the one destructive action on this screen that is not
  /// reachable by Undo once the user has saved.
  Future<void> _onRemoveColumnPressed(TableColumn column) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.removeColumn,
      subtitle: strings.removeColumnSubtitle(
        FormatHelper.capitalize(column.name),
      ),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    _cubit.removeColumn(column.id);
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
              thirdTitle: strings.editingTableDataCrumb(tableName),
              onFirstTap: _close,
              onSecondTap: _close,
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _primaryActions(strings, state),
                    SizedBox(height: metrics.blockGap),

                    SizedBox(height: 12.sp),
                    _gridActions(strings, state),
                    SizedBox(height: metrics.blockGap),
                    _grid(state),

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Discard on the leading edge; Preview and Save together on the trailing
  /// one (Figma 7398:15076). Same grouping rule the details screen uses: the
  /// action that abandons the screen sits as far as possible from the one that
  /// commits it.
  Widget _primaryActions(CreateTableStrings strings, TableDataState state) {
    final bool busy = state.isSaving;
    final CreateTableMetrics metrics = CreateTableMetrics.of(context);

    final Widget discard = customButton(
      title: strings.discard,
      function: busy ? () {} : _close,
      color: AppColors.darkGrey,
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
    );
    final Widget preview = customButton(
      title: strings.preview,
      function: busy ? () {} : _onPreviewPressed,
      color: AppColors.primary,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
    );
    final Widget save = customButton(
      title: strings.save,
      function: busy ? () {} : _onSavePressed,
      color: busy ? AppColors.disabledGrey : AppColors.primary,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
    );

    // Three of ButtonSizing's 135pt buttons plus two gaps is 425 — eighty past
    // the phone card. `Wrap` keeps all three (Figma 7398:12154 draws Preview
    // and Save on the phone frame too) and lets the third fall to its own line
    // instead of the row painting overflow stripes.
    if (metrics.toolbarStacks) {
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 10.sp,
        runSpacing: 10.sp,
        children: <Widget>[discard, preview, save],
      );
    }

    return Row(
      children: <Widget>[
        discard,
        const Spacer(),
        preview,
        SizedBox(width: 10.sp),
        save,
      ],
    );
  }

  /// Undo / Redo on the leading edge, the three grid actions on the trailing
  /// one — the dark buttons of Figma 7398:15076.
  ///
  /// Undo and Redo are DISABLED rather than hidden when there is nothing to
  /// undo. A button that appears the first time you type is a button nobody
  /// finds; one that is there and grey says what it will do later.
  ///
  /// FIVE BUTTONS DO NOT FIT ON A PHONE (17/8/2026), and no amount of shrinking
  /// makes them: "Remove Selection" alone is wider than a third of a 345pt card.
  /// Figma 7398:12154 draws the same five on the phone frame — Undo, Row,
  /// Column, Remove Selection — so none of them is dropped; they wrap instead.
  ///
  /// `Wrap` rather than two hard-coded rows: the labels are localized, and an
  /// Arabic "Remove Selection" is a different width from the English one, so a
  /// split chosen here would be right in one language and wrong in the other.
  /// Above 600 the whole set still fits on one line, which is what the iPad
  /// frames draw — the difference is only that the leading pair and the
  /// trailing three are no longer pushed apart by a `Spacer`, because a Spacer
  /// is the one thing that cannot wrap.
  Widget _gridActions(CreateTableStrings strings, TableDataState state) {
    final bool busy = state.isSaving;
    final CreateTableMetrics metrics = CreateTableMetrics.of(context);

    final List<Widget> undoRedo = <Widget>[
      _darkButton(
        title: strings.undo,
        enabled: state.canUndo && !busy,
        onTap: _cubit.undo,
      ),
      _darkButton(
        title: strings.redo,
        enabled: state.canRedo && !busy,
        onTap: _cubit.redo,
      ),
    ];

    final List<Widget> gridEdits = <Widget>[
      _darkButton(
        title: '—  ${strings.removeSelection}',
        enabled: state.hasSelection && !busy,
        onTap: _cubit.removeSelection,
      ),
      _darkButton(
        title: '+  ${strings.addRow}',
        enabled: !busy,
        onTap: _cubit.addRow,
      ),
      _darkButton(
        title: '+  ${strings.addColumn}',
        enabled: !busy,
        onTap: _cubit.addColumn,
      ),
    ];

    if (metrics.toolbarStacks) {
      return Wrap(
        spacing: 12.sp,
        runSpacing: 12.sp,
        children: <Widget>[...undoRedo, ...gridEdits],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        undoRedo[0],
        SizedBox(width: 12.sp),
        undoRedo[1],
        const Spacer(),
        gridEdits[0],
        SizedBox(width: 12.sp),
        gridEdits[1],
        SizedBox(width: 12.sp),
        gridEdits[2],
      ],
    );
  }

  Widget _darkButton({
    required String title,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return customButton(
      title: title,
      function: enabled ? onTap : () {},
      wrapContent: true,
      color: enabled ? AppColors.header : AppColors.card,
      textStyle: StyleText.fontSize14Weight400.copyWith(
        color: enabled ? AppColors.white : AppColors.secondaryText,
      ),
    );
  }

  /// The white card: a heading row, then one row per record.
  ///
  /// [TableDataState.namedColumns] is deliberately NOT used here — see its
  /// doc. A column being renamed passes through empty on the way to its new
  /// name, and dropping it mid-word would take the user's cursor with it.
  Widget _grid(TableDataState state) {
    final List<TableColumn> columns = state.table.columns;

    // Computed ONCE for the whole grid, not once per row. It walks every cell,
    // so calling it inside the row builder would make drawing a 500-row table
    // 500 full passes over it.
    final Set<String> invalid = _cubit.invalidCells;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: state.isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 32.sp),
              child: const Center(child: CircularProgressIndicator()),
            )
          : columns.isEmpty && state.rows.isEmpty
              ? const CustomEmptyState()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _headingRow(columns, state),
                      SizedBox(height: 12.sp),
                      for (final TableDataRow row in state.rows) ...<Widget>[
                        _dataRow(row, columns, state, invalid),
                        SizedBox(height: _cellGap.sp),
                      ],
                    ],
                  ),
                ),
    );
  }

  /// One heading: the column's name in a box, its Data Type dropdown, and the
  /// red circle that removes it.
  Widget _headingRow(List<TableColumn> columns, TableDataState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Empty slot over the tick column, so the headings line up with the
        // cells under them rather than sitting one checkbox to the left.
        SizedBox(width: _tickColumnWidth.sp),
        for (int i = 0; i < columns.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: _cellGap.sp),
          _heading(columns[i], state),
        ],
      ],
    );
  }

  Widget _heading(TableColumn column, TableDataState state) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool busy = state.isSaving;

    return SizedBox(
      width: _cellWidth.sp,
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomTextField(
              key: ValueKey<String>('heading/${column.id}'),
              initialValue: column.name,
              height: _fieldHeight,
              enabled: !busy,
              hint: strings.columnName,
              fillColor: AppColors.background,
              borderRadius: BorderRadius.circular(4.r),
              // The heading's own box takes whatever the COLUMN NAME rule
              // allows, which is a length limit and nothing else — the type
              // restricts the cells, not the name of the column. Same reading
              // `TableColumnBlock` takes on the create card.
              inputFormatters: TableColumnInputRules.formattersFor(
                TableColumnType.general,
                maxLength: CreateTableLimits.columnNameMaxLength,
              ),
              onChanged: (String value) => _cubit.columnNameChanged(
                columnId: column.id,
                name: value,
              ),
            ),
          ),
          SizedBox(width: 8.sp),
          SizedBox(
            width: _typeDropdownWidth.sp,
            child: CustomDropdown<TableColumnType>(
              height: _fieldHeight,
              value: column.type,
              enabled: !busy,
              hint: S.of(context).type,
              // The trigger reads "Data Type" until a type is picked, exactly
              // as the Figma draws it (7398:15661) — the selected value is on
              // the CELLS, not repeated in the heading's own chrome.
              alwaysShowHint: true,
              fillColor: AppColors.background,
              borderRadius: BorderRadius.circular(4.r),
              items: <DropdownItem<TableColumnType>>[
                for (final TableColumnType type in TableColumnType.values)
                  DropdownItem<TableColumnType>(
                    value: type,
                    label: type.localizedLabel(isArabic: context.isArabic),
                  ),
              ],
              onChanged: (TableColumnType type) => _cubit.columnTypeChanged(
                columnId: column.id,
                type: type,
              ),
            ),
          ),
          SizedBox(width: 8.sp),
          GestureDetector(
            onTap: busy ? null : () => _onRemoveColumnPressed(column),
            child: CustomSvgImage(
              assetPath: CreateTableAssets.removeColumn,
              width: 20.sp,
              height: 20.sp,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  /// One record: its tick, then a cell per column.
  Widget _dataRow(
    TableDataRow row,
    List<TableColumn> columns,
    TableDataState state,
    Set<String> invalid,
  ) {
    final bool selected = state.selectedRowIds.contains(row.id);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: _tickColumnWidth.sp,
          child: GestureDetector(
            onTap: state.isSaving ? null : () => _cubit.toggleRowSelected(row.id),
            // The tick is a small target, and the row is what the user is
            // aiming at — an opaque hit test makes the whole slot tappable
            // rather than the 22pt square inside it.
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(top: 7.sp),
              // ALIGN, not the bare box. `CustomCheckBox` sizes itself with a
              // `Container(width: 22.sp, height: 22.sp)`, and a Container's
              // width is a REQUEST that its parent's constraints overrule:
              // `BoxConstraints.enforce` clamps 22 into the [40, 40] the
              // `SizedBox` above hands down, so the tick rendered 40 wide by 22
              // tall and passing `size:` changed nothing on the width.
              //
              // `Align` re-loosens the constraint to [0, 40] before the box
              // sees it, which is what lets the 22 stand. Same trap as
              // `Center`/`Align` around any fixed-size child in a fixed-width
              // slot.
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: CustomCheckBox(isSelected: selected),
              ),
            ),
          ),
        ),
        for (int i = 0; i < columns.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: _cellGap.sp),
          SizedBox(
            width: _cellWidth.sp,
            child: _cell(row, columns[i], state, invalid),
          ),
        ],
      ],
    );
  }

  Widget _cell(
    TableDataRow row,
    TableColumn column,
    TableDataState state,
    Set<String> invalid,
  ) {
    final bool bad = invalid.contains('${row.id}/${column.id}');

    return CustomTextField(
      key: ValueKey<String>('${row.id}/${column.id}'),
      initialValue: row.valueFor(column),
      height: _fieldHeight,
      enabled: !state.isSaving,
      // The hint is the TYPE's example, so an empty Date cell says
      // "25/12/2026" and an empty Number cell says "25" — the format is
      // stated where it is needed rather than in a legend.
      hint: column.type.formatExample,
      errorText: bad ? column.type.formatExample : null,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.r),
      keyboardType: TableColumnInputRules.keyboardFor(column.type),
      inputFormatters: TableColumnInputRules.formattersFor(
        column.type,
        maxLength: CreateTableLimits.cellMaxLength,
      ),
      onChanged: (String value) => _cubit.cellChanged(
        rowId: row.id,
        columnId: column.id,
        value: value,
      ),
    );
  }
}
