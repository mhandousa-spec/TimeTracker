/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_details_page.dart
/// Purpose: Declares `TableDetailsPage` and `TableDetailsOutcome`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// "Table Name Details" — Figma 7398:4102 / 4300 / 4841 (iPad H 1024, open),
/// 7398:4690 (collapsed), 7398:17048 / 17240 / 4498 / 5039 (the 768 twins).
///
/// The screen that was missing. A table created from "+ Table" appeared as a
/// card on the database details screen and the card opened the Editing Table
/// Name form — skipping everything the design puts between the two:
///
///   Access  -> the table's access flow (7398:13651 / 14553)
///   Edit    -> the Editing Table Name card (7398:6934 / 7121)
///   Delete  -> confirm, delete, leave
///   the info card, expandable, with Comments on it (7398:8232)
///   four tiles: columns, rows, comments access, accesses
///   search + filter + export over the table's own data grid
///
/// Both orientations share this file, and the breadcrumb trims itself:
/// `SideFrameMasterServices` keeps the last three crumbs on a landscape tablet
/// and the last two on a portrait one, so "Database" drops off at 768 without
/// this page deciding anything.
///
/// WHAT IT HANDS BACK
/// ------------------
/// The card grid that pushed this is waiting. It gets a [TableDetailsOutcome]
/// rather than a bare record, because "deleted" and "renamed" need different
/// handling there — one removes a card and takes the parent's `tables_count`
/// down with it, the other replaces the card in place — and a null return could
/// only mean "nothing happened".

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/access_rule_fields.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/database_access_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_data_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_details_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/create_table_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/table_data_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/table_comments_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_info_card.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_rows_grid.dart';

/// What happened while the table details screen was open.
class TableDetailsOutcome {
  const TableDetailsOutcome({required this.table, required this.deleted});

  const TableDetailsOutcome.updated(DatabaseTableEntity table)
      : this(table: table, deleted: false);

  const TableDetailsOutcome.deleted(DatabaseTableEntity table)
      : this(table: table, deleted: true);

  /// The record as it stands. On a delete this is the record that WAS there, so
  /// the grid can find the card to remove by id.
  final DatabaseTableEntity table;

  final bool deleted;
}

class TableDetailsPage extends StatefulWidget {
  const TableDetailsPage({
    super.key,
    required this.database,
    required this.table,
    this.editedBy,
  });

  /// The parent. Carried for its name — the second crumb — and because both the
  /// edit card and the access flow are opened against it.
  final DatabaseEntity database;

  /// The row the card grid already has. The screen opens on it rather than
  /// re-reading: it is the same document, and a spinner over data the user was
  /// just looking at buys nothing.
  final DatabaseTableEntity table;

  /// Employee id stamped on grants and comments written from here.
  final String? editedBy;

  /// Opens the screen and resolves with what happened, or null if the user
  /// simply went back.
  static Future<TableDetailsOutcome?> open(
    BuildContext context, {
    required DatabaseEntity database,
    required DatabaseTableEntity table,
    String? editedBy,
  }) {
    return Navigator.of(context).push<TableDetailsOutcome>(
      MaterialPageRoute<TableDetailsOutcome>(
        builder: (_) => TableDetailsPage(
          database: database,
          table: table,
          editedBy: editedBy,
        ),
      ),
    );
  }

  @override
  State<TableDetailsPage> createState() => _TableDetailsPageState();
}

class _TableDetailsPageState extends State<TableDetailsPage> {
  late final TableDetailsCubit _cubit = TableDetailsCubit(table: widget.table);

  final TextEditingController _search = TextEditingController();

  /// The table's own DATA â the rows the card below is filled in with.
  ///
  /// A SECOND cubit rather than more fields on [TableDetailsCubit]: that one
  /// holds the record and owns delete, this one holds a subcollection it has to
  /// read, and folding a network read into the cubit that renders the header
  /// would put a spinner over the whole screen for something only the card at
  /// the bottom is waiting on.
  late final TableDataCubit _data = TableDataCubit(table: widget.table);

  @override
  void initState() {
    super.initState();
    // Read on open rather than on first scroll: the rows ARE the screen, and a
    // grid that fills in after the user has already started reading it is worse
    // than one that arrives with the page.
    _data.load();
  }

  @override
  void dispose() {
    _search.dispose();
    _data.close();
    _cubit.close();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop(
      _cubit.state.isChanged
          ? TableDetailsOutcome.updated(_cubit.state.table)
          : null,
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Edit opens the SAME card "+ Table" opens, in its Editing Table Name mode
  /// (Figma 7398:6934 / 7121) — not a second editor.
  Future<void> _onEditPressed() async {
    final DatabaseTableEntity? saved = await CreateTablePage.open(
      context,
      database: widget.database,
      table: _cubit.state.table,
      createdBy: widget.editedBy,
    );
    if (saved == null || !mounted) return;

    _cubit.tableChanged(saved);
  }

  /// Access opens the table's ACCESS LIST — Figma 7398:11000, the `Access`
  /// crumb under Table Name Details.
  ///
  /// The LIST and not the editor (17/8/2026). That screen was thought not to
  /// exist — `table_access_page.dart` even carried a note saying the Figma's
  /// "Access" crumb led nowhere and had been dropped — and it does: All /
  /// Active / Removed chips over a six-column table of everyone who reaches
  /// this table, with Edit Access on it. `DatabaseAccessPage` renders it,
  /// because the table frame IS the database frame with a fourth crumb.
  ///
  /// `Editing Table Access` is one step further in, behind that button.
  Future<void> _onAccessPressed() async {
    await DatabaseAccessPage.open(
      context,
      database: widget.database,
      table: _cubit.state.table,
      editedBy: widget.editedBy,
      // Folded straight in: the access editor rewrites `member_count`, which
      // the Accesses tile on this screen renders.
      onTableSaved: _cubit.tableChanged,
    );
  }

  /// Tapping the grid's heading band opens the table's OWN screen — Figma
  /// 7398:3042, where it can be edited or imported into.
  ///
  /// That is the design's route and not an invented one: this screen is about
  /// the table (who reaches it, what it is for, how many rows), and the grid at
  /// the bottom is the table itself. Tapping the thing to open the thing is the
  /// gesture; there is no "Fill" button in the Figma because the grid is it.
  ///
  /// What comes back is the record as the editor left it, so the "No. Of Rows"
  /// tile and the grid both catch up without a refetch of the parent.
  Future<void> _onTableHeaderTapped() async {
    final DatabaseTableEntity? saved = await TableDataPage.open(
      context,
      database: widget.database,
      table: _cubit.state.table,
    );
    if (saved == null || !mounted) return;

    // Both cubits, because both hold a copy of the record: this one renders the
    // tiles and the header, the other renders the rows.
    _cubit.tableChanged(saved);
    await _data.load();
  }

  Future<void> _onCommentsPressed() {
    return TableCommentsPage.open(
      context,
      database: widget.database,
      table: _cubit.state.table,
      currentEmployeeId: widget.editedBy,
    );
  }

  /// The red Delete button: confirm, delete, tell the user, hand the outcome
  /// back to the grid.
  ///
  /// The success dialog is shown BEFORE popping, while this route is still on
  /// screen — dismissing it and then leaving is one clear sequence, where
  /// popping first would open a dialog over a grid that had already lost the
  /// card. Same order db2's delete uses one level up.
  Future<void> _onDeletePressed() async {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final DatabaseTableEntity table = _cubit.state.table;
    final String name = FormatHelper.capitalize(
      table.localizedName(isArabic: context.isArabic),
    );

    // showConfirmDialog pops before invoking onConfirm, so this flag is set
    // while the await below is still suspended and is readable after it.
    // Cancel and a barrier tap both leave it false.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.deleteTableTitle,
      subtitle: strings.deleteTableSubtitle(name),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    final bool deleted = await _cubit.delete();
    if (!mounted) return;

    if (!deleted) {
      final String message = _cubit.state.errorMessage ?? strings.couldNotDelete;
      _cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.deleteFailedTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    await showSuccessDialog(
      context: context,
      title: strings.deletedTitle,
      subtitle: strings.deletedSubtitle(name),
      closeLabel: strings.close,
    );
    if (!mounted) return;

    Navigator.of(context).pop(TableDetailsOutcome.deleted(table));
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

    return BlocBuilder<TableDetailsCubit, TableDetailsState>(
      bloc: _cubit,
      builder: (BuildContext context, TableDetailsState state) {
        final String tableName = FormatHelper.capitalize(
          state.table.localizedName(isArabic: isArabic),
        );

        return PopScope(
          // The system back gesture has to carry the same result as the
          // breadcrumb, or an edit made here would be invisible to the grid
          // until the module was reopened.
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
              // Both leading crumbs leave this screen the same way the
              // breadcrumb reads: back to the database's own details page,
              // which is the single screen underneath this one.
              onFirstTap: _close,
              onSecondTap: _close,
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _actions(strings, state),
                    SizedBox(height: 12.h),

                    TableInfoCard(
                      table: state.table,
                      isExpanded: state.isExpanded,
                      onToggle: _cubit.toggleExpanded,
                      onCommentsPressed: _onCommentsPressed,
                    ),
                    SizedBox(height: metrics.blockGap),

                    // The four tiles of Figma 7398:4102. `SummaryTileRow` is
                    // db1's — the same widget the access review screens use —
                    // so a tile here and a tile there cannot drift apart.
                    //
                    // THEY GO WITH THE CARD (17/8/2026). "Hide" collapses the
                    // table's details, and the tiles ARE table details — how
                    // many columns it has, how many rows, its comments setting,
                    // how many people reach it. The collapsed frame (7398:4690)
                    // draws none of them: it is the labelled row, the toolbar
                    // and the grid, nothing else. Leaving them behind made
                    // "Hide" look like it had only half worked.
                    if (state.isExpanded) ...<Widget>[
                      SummaryTileRow(tiles: _tiles(state, strings, isArabic)),
                      SizedBox(height: metrics.blockGap),
                    ],

                    _toolbar(strings),
                    SizedBox(height: metrics.blockGap),

                    // The table's data (Figma 7398:4102). Its own cubit, so a
                    // row arriving rebuilds the grid and not the header, the
                    // tiles and the toolbar above it.
                    BlocBuilder<TableDataCubit, TableDataState>(
                      bloc: _data,
                      builder: (BuildContext context, TableDataState data) {
                        return TableRowsGrid(
                          columns: data.namedColumns,
                          rows: data.visibleRows,
                          onHeaderTap: _onTableHeaderTapped,
                        );
                      },
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

  /// No. Of Columns / No. Of Rows / Comments Access / Accesses
  /// (Figma 7398:4102, `Frame 1597883023`-`1597883026`).
  ///
  /// The Figma draws the fourth tile as a stack of faces with a "+6" chip. It
  /// is a COUNT here instead: the table document carries `member_count`,
  /// denormalised by the access flow, and the photos live one subcollection and
  /// one directory lookup away — a read per table opened, for decoration. The
  /// number is the fact the tile is there to state, and the Access button right
  /// above it is where the faces actually are.
  List<SummaryTile> _tiles(
    TableDetailsState state,
    CreateTableStrings strings,
    bool isArabic,
  ) {
    return <SummaryTile>[
      SummaryTile(
        label: strings.noOfColumns,
        // The NAMED columns, so this agrees with the grid underneath it rather
        // than counting headings the user never typed.
        value: '${state.namedColumns.length}',
      ),
      SummaryTile(label: strings.noOfRows, value: '${state.table.rowCount}'),
      SummaryTile(
        label: strings.commentsAccess,
        value: state.table.commentsAccess.localizedLabel(isArabic: isArabic),
      ),
      SummaryTile(
        label: strings.accesses,
        value: '${state.table.memberCount}',
      ),
    ];
  }

  /// Access on the leading edge; Edit and Delete together on the trailing one.
  ///
  /// That grouping is the Figma's and it is not arbitrary: Access opens a
  /// screen, while Edit and Delete change or end this record. Putting the
  /// destructive pair at the far edge also keeps Delete as far as possible from
  /// the button the user reaches for most. Same arrangement as db2's details
  /// screen, so the two levels do not disagree about where Delete lives.
  ///
  /// ON A PHONE EDIT AND DELETE LOSE THEIR LABELS (17/8/2026). Figma 7398:1701
  /// keeps "Access" labelled at 105 wide on the leading edge and draws the
  /// other two as 38 x 38 icon squares on the trailing one (7398:1714 pen,
  /// 7398:1753 trash). Three labelled buttons need about 300pt of a 345pt card
  /// in English and overflow it outright in Arabic; shrinking the type until
  /// they fit would make the destructive one the hardest to read on the screen.
  /// The arrangement — and which button keeps its words — is the Figma's.
  Widget _actions(CreateTableStrings strings, TableDetailsState state) {
    final bool busy = state.isDeleting;
    final CreateTableMetrics metrics = CreateTableMetrics.of(context);
    final bool iconOnly = metrics.iconOnlyRowActions;

    return Row(
      children: <Widget>[
        customButtonWithSvg(
          title: strings.access,
          function: busy ? () {} : _onAccessPressed,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: DatabaseDetailsAssets.access,
          widthImage: 18.r,
          heightImage: 18.r,
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
        const Spacer(),
        if (iconOnly)
          _iconAction(
            tooltip: strings.edit,
            asset: DatabaseDetailsAssets.edit,
            glyph: AppColors.textButton,
            fill: AppColors.primary,
            size: metrics.rowActionButtonSize,
            onTap: busy ? null : _onEditPressed,
          )
        else
          customButtonWithSvg(
            title: strings.edit,
            function: busy ? () {} : _onEditPressed,
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
        if (iconOnly)
          _iconAction(
            tooltip: strings.delete,
            asset: DatabaseDetailsAssets.delete,
            glyph: AppColors.white,
            // The one red button on this screen, labelled or not.
            fill: busy ? AppColors.disabledGrey : AppColors.delete,
            size: metrics.rowActionButtonSize,
            onTap: busy ? null : _onDeletePressed,
          )
        else
          customButtonWithSvg(
            title: strings.delete,
            function: busy ? () {} : _onDeletePressed,
            // The one red button on this screen. `AppColors.delete` is the
            // palette's destructive tone, the same one db2's Delete uses.
            color: busy ? AppColors.disabledGrey : AppColors.delete,
            colorBorder: AppColors.transparent,
            image: DatabaseDetailsAssets.delete,
            widthImage: 25.r,
            heightImage: 25.r,
            svgColor: AppColors.white,
            textStyle:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
          ),
      ],
    );
  }

  /// One 38 x 38 icon square — the phone form of a labelled action.
  ///
  /// The label does not vanish, it moves into the [tooltip] and the semantics
  /// node, so the button still answers "what is this" to a long press and to a
  /// screen reader. A glyph on its own with nothing behind it is how an icon
  /// button becomes unusable for the people who most need the label.
  Widget _iconAction({
    required String tooltip,
    required String asset,
    required Color glyph,
    required Color fill,
    required double size,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: CustomSvgImage(
                assetPath: asset,
                width: 20.r,
                height: 20.r,
                color: glyph,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Search + Filter + Export over the data grid (Figma 7398:4102).
  Widget _toolbar(CreateTableStrings strings) {
    final bool compact = context.isPhone;

    return Row(
      children: <Widget>[
        // AppSearchTextField's root IS an Expanded, so it goes straight into
        // the Row — wrapping it in another one throws "Competing
        // ParentDataWidgets".
        AppSearchTextField(
          controller: _search,
          hintText: strings.search,
          fillColor: AppColors.card,
          // The rows, not the row NUMBERS. `TableDetailsState.query` narrowed
          // a list of numbers because that was all a row had; a row now has
          // cells, and the cells are what somebody searches for.
          onChanged: _data.searchChanged,
        ),
        SizedBox(width: 10.w),

        // TODO(form-builder): Filter and Export are drawn and inert, and
        // deliberately so. Both act on the ROWS in the grid below, and a row
        // has no values yet — the cells come from the Form Builder, the next
        // Figma section, and until then a filter would have nothing to narrow
        // and an export would write a file of headings and dashes. They render
        // rather than being hidden because the Figma puts them here and
        // removing them would make this screen disagree with the design over
        // something that is arriving; they claim no state they do not have.
        CustomFilterIcon(
          title: strings.filter,
          color: AppColors.card,
          onTap: () {},
        ),
        SizedBox(width: 10.w),
        customButtonWithSvg(
          title: compact ? '' : strings.export,
          function: () {},
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: DatabaseDetailsAssets.export,
          widthImage: 16.r,
          heightImage: 16.r,
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
