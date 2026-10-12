/// Module: database / db2_database_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_page.dart
/// Purpose: Declares `DatabaseDetailsPage` and `DatabaseDetailsOutcome`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Database Name Details" — the landing screen of the Figma section
/// "INSIDE DATABASE PAGE: Giving Accesses , Editing , Deleting".
///
///   iPad VERTICAL    1024 x 768  (7398:735 open, 7398:2082 collapsed)
///   iPad HORIZONTAL   768 x 768  (7398:847 open, 7398:954 collapsed)
///
/// Three actions and a toolbar:
///
///   Access  -> the access list (7398:10662 / 10875)
///   Edit    -> the editing card (7398:6461 / 16968)
///   Delete  -> confirm, delete, leave
///   + Table -> db3's Creating Table card (7398:6533 / 6732)
///
/// UPDATED 16/8/2026. "+ Table" and the region under the toolbar were both
/// placeholders — a "not wired up yet" dialog and a hard-coded "No tables in
/// this database yet". The next Figma section
/// ("INSIDE DATABASE PAGE: Creating Table + Viewable Fields") now exists as
/// `db3_create_table`, so the button opens it and the region draws the real
/// list. This page owns the list's cubit rather than the card doing: the list
/// outlives every visit to that card, and rebuilding it each time the card
/// closed would flash an empty table on the way back.
///
/// UPDATED 17/8/2026. The list is now the Figma's CARD GRID rather than a
/// nine-column table, and a card opens db3's Table Name Details screen
/// (7398:4102) instead of jumping straight into the edit form. That screen owns
/// the table's Access, Edit, Delete and Comments, so three of this page's
/// handlers moved into it and what comes back here is a `TableDetailsOutcome`.
///
/// Both orientations share this file. The only thing that moves is whether the
/// three secondary controls in the toolbar carry labels: the 768 frame draws
/// Filter and Sort as bare icons because four labelled controls plus a search
/// box do not fit, which is the same rule db1's list toolbar follows on a
/// phone.
///
/// WHAT IT HANDS BACK
/// ------------------
/// The list screen pushed this and is waiting. It gets a
/// [DatabaseDetailsOutcome] rather than a bare record, because "deleted" and
/// "renamed" need different handling there — one removes a card, the other
/// replaces it — and a null return could only mean "nothing happened".

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/15-custom_sort_icon.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/controller/database_details_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/database_access_page.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/edit_database_page.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_info_card.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_list_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/create_table_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/table_details_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_list_section.dart';

/// What happened while the details screen was open.
class DatabaseDetailsOutcome {
  const DatabaseDetailsOutcome({required this.database, required this.deleted});

  const DatabaseDetailsOutcome.updated(DatabaseEntity database)
      : this(database: database, deleted: false);

  const DatabaseDetailsOutcome.deleted(DatabaseEntity database)
      : this(database: database, deleted: true);

  /// The record as it stands. On a delete this is the record that WAS there,
  /// so the list can find the card to remove by id.
  final DatabaseEntity database;

  final bool deleted;
}

class DatabaseDetailsPage extends StatefulWidget {
  const DatabaseDetailsPage({
    super.key,
    required this.database,
    this.editedBy,
    this.readOnly = false,
  });

  /// The row the list screen already has. The screen opens on it rather than
  /// re-reading: it is the same document, and a spinner over data the user was
  /// just looking at buys nothing.
  final DatabaseEntity database;

  /// Employee id stamped on grants written from the access editor.
  final String? editedBy;

  /// Opens the screen for LOOKING, not for acting. ADDED 16/8/2026.
  ///
  /// Set by the list when the record is soft-deleted. A deleted database still
  /// has everything it had — its info card, its tables, its grants — and that
  /// is exactly what someone standing in the Deleted chip came to see, which is
  /// why the card opens at all now instead of ignoring the tap.
  ///
  /// It drops EDIT and DELETE from the action row. Both are meaningless here:
  /// an edit would write changes into a record no chip but Deleted lists, and
  /// Delete has already happened. They are HIDDEN rather than greyed out —
  /// a disabled button invites the user to work out why, and the answer
  /// ("because you deleted this") is already the reason they are on this
  /// screen.
  ///
  /// Restore is deliberately NOT added here. It lives on the card's "..." menu
  /// one screen back, where it already works and where the list can move the
  /// row to the right chip the moment it succeeds.
  final bool readOnly;

  /// Opens the screen and resolves with what happened, or null if the user
  /// simply went back.
  static Future<DatabaseDetailsOutcome?> open(
    BuildContext context, {
    required DatabaseEntity database,
    String? editedBy,
    bool readOnly = false,
  }) {
    return Navigator.of(context).push<DatabaseDetailsOutcome>(
      MaterialPageRoute<DatabaseDetailsOutcome>(
        builder: (_) => DatabaseDetailsPage(
          database: database,
          editedBy: editedBy,
          readOnly: readOnly,
        ),
      ),
    );
  }

  @override
  State<DatabaseDetailsPage> createState() => _DatabaseDetailsPageState();
}

class _DatabaseDetailsPageState extends State<DatabaseDetailsPage> {
  late final DatabaseDetailsCubit _cubit =
      DatabaseDetailsCubit(database: widget.database);

  /// The tables inside this database (db3). Loaded once when the screen opens;
  /// every write from the Creating Table card is folded in rather than
  /// refetched, so returning from that card does not blank the list first.
  late final TableListCubit _tables =
      TableListCubit(databaseId: widget.database.id)..load();

  final TextEditingController _search = TextEditingController();

  /// Whether anything was saved while this screen was open. Drives what
  /// [_close] hands back — a screen that was only looked at must not make the
  /// list refetch.
  bool _changed = false;

  @override
  void dispose() {
    _search.dispose();
    _tables.close();
    _cubit.close();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop(
      _changed ? DatabaseDetailsOutcome.updated(_cubit.state.database) : null,
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _onEditPressed() async {
    final DatabaseEntity? saved = await EditDatabasePage.open(
      context,
      database: _cubit.state.database,
    );
    if (saved == null || !mounted) return;

    _changed = true;
    _cubit.databaseChanged(saved);
  }

  Future<void> _onAccessPressed() async {
    final DatabaseEntity? saved = await DatabaseAccessPage.open(
      context,
      database: _cubit.state.database,
      editedBy: widget.editedBy,
    );
    if (saved == null || !mounted) return;

    _changed = true;
    _cubit.databaseChanged(saved);
  }

  /// The red Delete button: confirm, delete, tell the user, hand the outcome
  /// back to the list.
  ///
  /// The success dialog is shown BEFORE popping, while this route is still on
  /// screen — dismissing it and then leaving is one clear sequence, where
  /// popping first would open a dialog over a list that had already lost the
  /// card and leave the user wondering which screen the message belonged to.
  Future<void> _onDeletePressed() async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final DatabaseEntity database = _cubit.state.database;
    final String title =
        FormatHelper.capitalize(database.localizedTitle(isArabic: context.isArabic));

    // showConfirmDialog pops before invoking onConfirm, so this flag is set
    // while the await below is still suspended and is readable after it.
    // Cancel and a barrier tap both leave it false.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.deleteConfirmTitle,
      subtitle: strings.deleteConfirmSubtitle(title),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    final bool deleted = await _cubit.delete();
    if (!mounted) return;

    if (!deleted) {
      final String message =
          _cubit.state.errorMessage ?? strings.couldNotSave;
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
      subtitle: strings.deletedSubtitle(title),
      closeLabel: strings.close,
    );
    if (!mounted) return;

    Navigator.of(context).pop(DatabaseDetailsOutcome.deleted(database));
  }

  /// "+ Table" opens db3's Creating Table card (Figma 7398:6533 / 6732).
  ///
  /// The write bumped `tables_count` on THIS database in the same batch, so the
  /// local copy is bumped too and the screen is marked changed — otherwise the
  /// card on the Database Builder list would still read "No. Of Tables: 0" over
  /// a database that now has one, until the module was reopened.
  Future<void> _onAddTablePressed() async {
    final DatabaseTableEntity? created = await CreateTablePage.open(
      context,
      database: _cubit.state.database,
      createdBy: widget.editedBy,
    );
    if (created == null || !mounted) return;

    _tables.tableSaved(created);
    _changed = true;
    _cubit.databaseChanged(
      _cubit.state.database.copyWith(
        tablesCount: _cubit.state.database.tablesCount + 1,
      ),
    );
  }

  /// A card opens db3's Table Name Details screen (Figma 7398:4102).
  ///
  /// UPDATED 17/8/2026. It used to open the Editing Table Name card directly,
  /// which skipped the screen the design puts in between — the one carrying the
  /// description, the four tiles, the rows grid and the Comments button. Edit,
  /// Access and Delete are all buttons on that screen now, which is why the two
  /// handlers that used to live here went with them.
  ///
  /// TWO OUTCOMES, HANDLED DIFFERENTLY. A rename replaces the card in place and
  /// changes nothing the Database Builder list behind THIS screen renders, so
  /// `_changed` stays false. A delete removes the card AND takes the parent's
  /// `tables_count` down — the repository already wrote that decrement in the
  /// same batch as the delete, so the local copy is brought into step and the
  /// screen marked changed, or the card on the builder list would still claim a
  /// table that is gone.
  Future<void> _onTableTapped(DatabaseTableEntity table) async {
    final TableDetailsOutcome? outcome = await TableDetailsPage.open(
      context,
      database: _cubit.state.database,
      table: table,
      editedBy: widget.editedBy,
    );
    if (outcome == null || !mounted) return;

    if (!outcome.deleted) {
      _tables.tableSaved(outcome.table);
      return;
    }

    _tables.tableRemoved(outcome.table.id);
    _changed = true;
    _cubit.databaseChanged(
      _cubit.state.database.copyWith(
        // Clamped at zero. The count is a denormalised field that a partial
        // write or an older build could leave at 0 over a database that still
        // has tables, and "-1 Tables" on a card is worse than a stale 0.
        tablesCount: _cubit.state.database.tablesCount > 0
            ? _cubit.state.database.tablesCount - 1
            : 0,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final bool isArabic = context.isArabic;

    return BlocBuilder<DatabaseDetailsCubit, DatabaseDetailsState>(
      bloc: _cubit,
      builder: (BuildContext context, DatabaseDetailsState state) {
        final String title =
            FormatHelper.capitalize(state.database.localizedTitle(isArabic: isArabic));

        return PopScope(
          // The system back gesture has to carry the same result as the
          // breadcrumb, or an edit made here would be invisible to the list
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
              secondTitle: strings.detailsCrumb(title),
              onFirstTap: _close,
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _actions(strings, state),
                    SizedBox(height: 12.h),

                    DatabaseInfoCard(
                      database: state.database,
                      isExpanded: state.isExpanded,
                      onToggle: _cubit.toggleExpanded,
                    ),
                    SizedBox(height: metrics.blockGap),

                    _toolbar(strings),
                    SizedBox(height: metrics.blockGap),

                    // The table cards (db3). The section reports loading,
                    // failed and empty separately, because two of them used to
                    // look like the third.
                    BlocBuilder<TableListCubit, TableListState>(
                      bloc: _tables,
                      builder: (
                        BuildContext context,
                        TableListState tableState,
                      ) {
                        return TableListSection(
                          state: tableState,
                          onTableTap: _onTableTapped,
                          onRetry: _tables.load,
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

  /// Access on the leading edge; Edit and Delete together on the trailing one.
  ///
  /// That grouping is the Figma's and it is not arbitrary: Access opens a
  /// screen, while Edit and Delete change or end this record. Putting the
  /// destructive pair at the far edge also keeps Delete as far as possible
  /// from the button the user reaches for most.
  ///
  /// On a DELETED record ([DatabaseDetailsPage.readOnly]) the trailing pair is
  /// not drawn at all and Access is the only button left — see that field for
  /// why hidden rather than disabled.
  Widget _actions(DatabaseDetailsStrings strings, DatabaseDetailsState state) {
    final bool busy = state.isDeleting;

    return Row(
      children: <Widget>[
        customButtonWithSvg(
          title: context.isPhone ? "" : strings.access,
          space: context.isPhone ? 0.sp : 8.sp,
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
        if (!widget.readOnly) ...<Widget>[
          customButtonWithSvg(
            title: context.isPhone ? "" : strings.edit,
            function: busy ? () {} : _onEditPressed,
            color: AppColors.primary,
            colorBorder: AppColors.transparent,
            space: context.isPhone ? 0 : 8.sp,
            image:  DatabaseDetailsAssets.edit,
            widthImage: 18.r,
            heightImage: 18.r,
            svgColor: AppColors.textButton,
            textStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
          SizedBox(width: 10.w),
          customButtonWithSvg(
            space: context.isPhone ? 0 : 8.sp,

            title: context.isPhone ?"" :strings.delete,
            function: busy ? () {} : _onDeletePressed,
            // The one red button in the module. `AppColors.delete` is the
            // palette's destructive tone, the same one the card menu's Delete
            // row and the review screen's remove badge use.
            color: busy ? AppColors.disabledGrey : AppColors.delete,
            colorBorder: AppColors.transparent,
            image: DatabaseDetailsAssets.delete,
            widthImage: 18.r,
            heightImage: 18.r,
            svgColor: AppColors.white,
            textStyle:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
          ),
        ],
      ],
    );
  }

  /// Search + Filter + Sort + "+ Table" (Figma 7398:735).
  ///
  /// The 768 frame (7398:847) draws Filter and Sort as bare icons, and they
  /// are NOT reproduced that way here on purpose: `CustomFilterIcon` and
  /// `CustomSortIcon` are pinned to 100.sp on any non-phone window, so
  /// dropping the label would leave the button exactly as wide with a hole
  /// where the word used to be — the search box would gain nothing. They lose
  /// their labels on a phone, which those widgets already handle themselves.
  ///
  /// "+ Table" is different: `customButtonWithSvg` has a real icon-only mode
  /// (a 38.sp square) when handed an empty title, so it does collapse.
  Widget _toolbar(DatabaseDetailsStrings strings) {
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
          // Narrows the list in memory rather than refetching: the whole set is
          // already here, and a query per keystroke would be a read per
          // keystroke for a list of a handful of rows.
          onChanged: _tables.searchChanged,
        ),
        SizedBox(width: 10.w),

        // TODO(db3): still inert, and deliberately so. A table record has no
        // status, no owner and no type — nothing a Filter popover could offer —
        // and with search live, sorting a handful of rows that already arrive
        // newest-first has nothing to add. Both belong to the Form Builder
        // screen, where they filter and sort the ROWS inside a table. They
        // render without claiming a state they do not have.
        CustomFilterIcon(
          title: strings.filter,
          color: AppColors.card,
          onTap: () {},
        ),
        SizedBox(width: 10.w),
        CustomSortIcon(
          title: strings.sort,
          color: AppColors.card,
          onTap: () {},
        ),
        SizedBox(width: 10.w),

        _addTableButton(strings, compact),
      ],
    );
  }

  /// "+ Table", narrower than `ButtonSizing` would make it.
  ///
  /// WHY IT IS WRAPPED (17/8/2026)
  /// -----------------------------
  /// `customButtonWithSvg` pins every labelled button to 135.sp on a tablet and
  /// ignores its own `width` parameter — that is the app's rule, and it is the
  /// right rule for a row of primary actions where buttons of different widths
  /// would look ragged. This is not that row. "+ Table" sits at the end of a
  /// TOOLBAR, after Filter and Sort, and the widest thing in it should be the
  /// search box; 135.sp for a five-letter label was taking 40pt of that box for
  /// whitespace.
  ///
  /// The `SizedBox` is how it narrows without editing the shared widget: the
  /// button's inner `Container(width: 135.sp)` resolves its own width against
  /// the constraints it is handed, so a tight 100.w from above simply wins. The
  /// content — a 14pt glyph, an 8pt gap and "Table" at 14sp — needs about 62pt
  /// of that, which leaves room for Arabic and for a large text-scale setting.
  ///
  /// Only when there IS a label. On a phone the empty title puts the widget in
  /// its icon-only mode, which is a 38.sp SQUARE — clamping that to 100 would
  /// stretch it into a rectangle.
  Widget _addTableButton(DatabaseDetailsStrings strings, bool compact) {
    final Widget button = customButtonWithSvg(
      title: compact ? '' : strings.table,
      function: _onAddTablePressed,
      color: AppColors.primary,
      colorBorder: AppColors.transparent,
      image: DatabaseDetailsAssets.addTable,
      // 14 rather than 16: the glyph is a bare "+" and at 16 it read as the
      // loudest thing in a toolbar whose other two controls are outlined.
      widthImage: 14.r,
      heightImage: 14.r,
      svgColor: AppColors.textButton,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
    );

    if (compact) return button;
    return SizedBox(width: 100.w, child: button);
  }
}
