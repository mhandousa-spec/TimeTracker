/// Module: database / db2_database_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_page.dart
/// Purpose: Declares `DatabaseAccessPage`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Database > Database Name > Access" — Figma 7398:10662 (iPad V, 1024 x 916)
/// / 7398:10875 (iPad H, 768 x 916).
///
///   Edit Access button, a chip row (All / Active / Deactivated / Removed /
///   Scheduled), search + Filter + Sort + Export, and the eight-column table.
///
/// Both orientations share this file. The 768 frame draws Filter, Sort and
/// Export as bare icons and lets the chip row and the table scroll sideways —
/// which they already do: `StatusChipFilter` is a horizontal scroll view and
/// `AccessTable` scrolls by design (see its header for why eight columns
/// cannot be made to fit).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/15-custom_sort_icon.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_row.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/enums/database_access_status.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/table_access_flow.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/controller/database_access_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/edit_database_access_flow.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/access_filter_dialog.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/access_table.dart';

class DatabaseAccessPage extends StatefulWidget {
  const DatabaseAccessPage({
    super.key,
    required this.database,
    this.table,
    this.editedBy,
    this.onTableSaved,
  });

  final DatabaseEntity database;

  /// Set to show ONE TABLE's access instead of the whole database's — Figma
  /// 7398:11000, the `Access` crumb under Table Name Details.
  ///
  /// ONE SCREEN, NOT TWO (17/8/2026). The table frame is this frame: the same
  /// Edit Access button, the same All / Active / Removed chips, the same
  /// search, Filter, Sort and Export, and the same six-column table. Only the
  /// breadcrumb and the subcollection differ, and both grant subcollections are
  /// deliberately the same document shape. A db3 copy of this file would have
  /// been 470 lines that drift the first time either side gains a column.
  final DatabaseTableEntity? table;

  /// Employee id stamped as the "Access Grantor" on grants written from here.
  final String? editedBy;

  /// Called with the refreshed table after the table's access editor saves.
  ///
  /// A CALLBACK and not the route's result, because this route already resolves
  /// with a `DatabaseEntity` for the database-level screen and widening that to
  /// `Object?` would push the cast onto both callers. The table's details
  /// screen is still on the stack underneath and holds the record whose
  /// `member_count` just changed, so it folds the new one in directly.
  final ValueChanged<DatabaseTableEntity>? onTableSaved;

  /// Opens the screen and resolves with the record as it stands IF the access
  /// editor saved, or null when nothing changed. The details page swaps its
  /// copy for whatever comes back, because a save also rewrites the parent's
  /// access type and member count.
  static Future<DatabaseEntity?> open(
    BuildContext context, {
    required DatabaseEntity database,
    DatabaseTableEntity? table,
    String? editedBy,
    ValueChanged<DatabaseTableEntity>? onTableSaved,
  }) {
    return Navigator.of(context).push<DatabaseEntity>(
      MaterialPageRoute<DatabaseEntity>(
        builder: (_) => DatabaseAccessPage(
          database: database,
          table: table,
          editedBy: editedBy,
          onTableSaved: onTableSaved,
        ),
      ),
    );
  }

  @override
  State<DatabaseAccessPage> createState() => _DatabaseAccessPageState();
}

class _DatabaseAccessPageState extends State<DatabaseAccessPage> {
  late final DatabaseAccessCubit _cubit = DatabaseAccessCubit(
    database: widget.database,
    table: widget.table,
  )..load();

  /// The table this screen is scoped to, or null on the database-level screen.
  DatabaseTableEntity? get _table => _cubit.state.table;

  final TextEditingController _search = TextEditingController();

  /// Set once the access editor saves, so leaving hands the refreshed record
  /// back rather than the one this screen opened with.
  bool _changed = false;

  @override
  void dispose() {
    _search.dispose();
    _cubit.close();
    super.dispose();
  }

  void _close() => Navigator.of(context)
      .pop(_changed ? _cubit.state.database : null);

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _onEditAccessPressed() async {
    // A TABLE's access is edited by the table's own flow, which writes to the
    // table's subcollection and knows about Viewable Fields — a concept the
    // database-level editor does not have.
    final DatabaseTableEntity? table = _table;
    if (table != null) {
      final DatabaseTableEntity? savedTable = await TableAccessFlow.open(
        context,
        database: _cubit.state.database,
        table: table,
        editedBy: widget.editedBy,
      );
      if (savedTable == null || !mounted) return;

      _changed = true;
      widget.onTableSaved?.call(savedTable);
      // Re-read: the flow REPLACES the subcollection, so the rows on this
      // screen are stale in a way no returned record can patch up.
      await _cubit.load();
      return;
    }

    final DatabaseEntity? saved = await EditDatabaseAccessFlow.open(
      context,
      database: _cubit.state.database,
      // The editor is handed the grants THIS screen already read, so it opens
      // on the selection instantly instead of re-reading a subcollection that
      // is sitting a few feet away in memory — and, more importantly, so both
      // screens are editing the same snapshot rather than two reads that could
      // disagree.
      records: _cubit.state.records,
      editedBy: widget.editedBy,
    );

    if (saved == null || !mounted) return;

    _changed = true;
    _cubit.databaseChanged(saved);
  }

  Future<void> _onFilterPressed() async {
    final AccessFilterResult? result = await AccessFilterDialog.show(
      context,
      departments: _cubit.state.departments,
      initialDepartmentId: _cubit.state.departmentFilter,
    );

    // A dismissed dialog resolves to null and is ignored; only Apply reaches
    // the cubit, so tapping outside cannot silently change the table.
    if (result == null) return;
    _cubit.departmentFilterChanged(result.departmentId);
  }

  /// Export writes what is ON SCREEN — see `DatabaseAccessCubit.exportVisibleRows`
  /// for why the filters travel with it.
  ///
  /// Every label the file needs is resolved HERE and passed down, because the
  /// cubit has no BuildContext and the CSV has to read in the same language
  /// the table does. A file whose headers are English while its status column
  /// is Arabic is worse than either.
  Future<void> _onExportPressed() async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    await _cubit.exportVisibleRows(
      isArabic: isArabic,
      headers: <String>[
        strings.colName,
        strings.colDepartment,
        strings.colGrantor,
        strings.colStart,
        strings.colEnd,
        strings.colAccessType,
        strings.colAccessStatus,
      ],
      statusLabel: (DatabaseAccessRow row) =>
          row.status.localizedLabel(isArabic: isArabic),
      permissionLabel: (DatabasePermissionLevel? level) => level == null
          ? ''
          : (isArabic ? level.labelAr : level.labelEn),
      // Empty rather than an em dash: a "—" in a CSV cell is read as data by
      // whatever opens the file, and a spreadsheet full of dashes cannot be
      // sorted or counted.
      dateLabel: (DateTime? date) => DatabaseDateFormat.short(
        date,
        isArabic: isArabic,
        placeholder: '',
      ),
    );
  }

  /// Reports the export once and then clears the flag, so a rebuild cannot
  /// re-open the dialog.
  Future<void> _onStateChanged(
    BuildContext context,
    DatabaseAccessState state,
  ) async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    switch (state.exportStatus) {
      case DatabaseExportStatus.empty:
        _cubit.exportHandled();
        await showWarningDialog(
          context: context,
          title: strings.exportEmptyTitle,
          subtitle: strings.exportEmpty,
          closeLabel: strings.close,
        );
        return;

      case DatabaseExportStatus.success:
        final String name =
            state.exportedFile?.uri.pathSegments.last ?? '';
        _cubit.exportHandled();
        await showSuccessDialog(
          context: context,
          title: strings.exportDoneTitle,
          subtitle: strings.exportDone(name),
          closeLabel: strings.close,
        );
        return;

      case DatabaseExportStatus.failure:
        final String message = state.errorMessage ?? strings.exportFailed;
        _cubit.exportHandled();
        _cubit.clearMessages();
        await showErrorDialog(
          context: context,
          title: strings.exportFailedTitle,
          subtitle: message,
          closeLabel: strings.close,
        );
        return;

      case DatabaseExportStatus.idle:
      case DatabaseExportStatus.running:
        return;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final bool isArabic = context.isArabic;

    return BlocConsumer<DatabaseAccessCubit, DatabaseAccessState>(
      bloc: _cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, DatabaseAccessState state) {
        final String title =
            FormatHelper.capitalize(state.database.localizedTitle(isArabic: isArabic));

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
              secondTitle: title,
              // Four crumbs on a table (Figma 7398:11000 — "Database >
              // Database Details > Table Name Details > Access"), three on a
              // database. `SideFrameMasterServices` trims the leading ones
              // itself at narrow widths, so this only has to state them.
              thirdTitle: _table == null
                  ? strings.accessCrumb
                  : FormatHelper.capitalize(
                      _table!.localizedName(isArabic: context.isArabic),
                    ),
              fourthTitle: _table == null ? null : strings.accessCrumb,
              // On a table, the third crumb IS the table — one step back, the
              // screen this was opened from. On a database it is "Access",
              // which is this screen, so it stays inert.
              onThirdTap: _table == null ? null : _close,
              // "Database" leaves the section entirely; the record's own name
              // is one step back, to its details screen. Different
              // destinations, so different callbacks.
              //
              // The first crumb pops TWICE through one captured NavigatorState.
              // Reading `Navigator.of(context)` again after the first pop would
              // walk a defunct element; holding the state object is what makes
              // the second hop safe. The details route underneath has
              // `canPop: false`, so `maybePop` runs ITS close handler rather
              // than dropping it — which is how the list still receives the
              // edit that was made here.
              onFirstTap: () {
                final NavigatorState navigator = Navigator.of(context);
                navigator.pop(_changed ? _cubit.state.database : null);
                navigator.maybePop();
              },
              onSecondTap: _close,
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.extraHorizontalInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: customButtonWithSvg(
                          space: context.isPhone ? 0.sp : 8.sp,
                          title: context.isPhone ?  "":strings.editAccess,
                          function: _onEditAccessPressed,
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: DatabaseDetailsAssets.editAccess,
                          widthImage: 18.r,
                          heightImage: 18.r,
                          svgColor: AppColors.textButton,
                          textStyle: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.textButton),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      StatusChipFilter(
                        items: _chips(strings, isArabic),
                        selectedKey: state.filterKey,
                        onSelected: _cubit.filterChanged,
                      ),
                      SizedBox(height: 12.h),

                      _toolbar(strings, state),
                      SizedBox(height: 12.h),

                      if (state.isLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          // `CircleProgressMaster` centres itself, so it
                          // replaces the Center as well as the indicator.
                          child: const CircleProgressMaster(),
                        )
                      // A FAILED read and an EMPTY subcollection are different
                      // things and must not look the same. Without this branch
                      // a denied read would draw the empty-state animation —
                      // "nobody has access to this database" is the one claim
                      // about an access list that must never be guessed at.
                      //
                      // This is exactly why `CustomEmptyState` is only reached
                      // below, after the error case has had its turn.
                      else if (state.errorMessage != null)
                        _error(state, strings)
                      else
                        AccessTable(
                          rows: _cubit.visibleRows(isArabic: isArabic),
                        ),
                      SizedBox(height: metrics.blockGap),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _error(DatabaseAccessState state, DatabaseDetailsStrings strings) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              state.errorMessage ?? strings.couldNotLoad,
              textAlign: TextAlign.center,
              style:
                  StyleText.fontSize14Weight400.copyWith(color: AppColors.red),
            ),
            SizedBox(height: 12.h),
            customButton(
              title: strings.retry,
              function: () => _cubit.load(),
              wrapContent: true,
              color: AppColors.primary,
              textColor: AppColors.textButton,
            ),
          ],
        ),
      ),
    );
  }

  /// The chips — five on a database, three on a table (see [_filters]). Each
  /// status keeps the colour it has in the table, so a
  /// chip and the rows it selects can never disagree — the colours come from
  /// one place, `AccessStatusBadge.colorFor`.
  /// Which chips this screen offers.
  ///
  /// A TABLE gets three — All / Active / Removed (Figma 7398:11000) — where a
  /// DATABASE gets all five. That is the design's call and it follows from what
  /// each level can express: a database grant carries a start date and an
  /// enabled flag, so it can be Scheduled (starts later) or Deactivated
  /// (switched off while still listed). A table grant is written by the table's
  /// own editor, which has neither control — it is on or it is taken away — so
  /// two of the five chips could only ever read 0 on this screen, and a filter
  /// that can never match anything is worse than an absent one.
  ///
  /// The ENUM keeps all five. This narrows what is shown, not what exists: a
  /// table grant written by some later screen that does set those fields still
  /// lands in the right bucket, it just is not filterable here yet.
  List<DatabaseAccessFilter> get _filters => _table == null
      ? DatabaseAccessFilter.values
      : const <DatabaseAccessFilter>[
          DatabaseAccessFilter.all,
          DatabaseAccessFilter.active,
          DatabaseAccessFilter.removed,
        ];

  List<StatusChipItem> _chips(
    DatabaseDetailsStrings strings,
    bool isArabic,
  ) {
    String labelFor(DatabaseAccessFilter f) {
      switch (f) {
        case DatabaseAccessFilter.all:
          return strings.all;
        case DatabaseAccessFilter.active:
          return strings.activeChip;
        case DatabaseAccessFilter.deactivated:
          return strings.deactivatedChip;
        case DatabaseAccessFilter.removed:
          return strings.removedChip;
        case DatabaseAccessFilter.scheduled:
          return strings.scheduledChip;
      }
    }

    return _filters
        .map((DatabaseAccessFilter f) => StatusChipItem(
              key: f.name,
              label: labelFor(f),
              count: _cubit.countFor(f, isArabic: isArabic),
              // "All" keeps the default text colour: it is not a status, so
              // tinting it would imply one.
              labelColor: f.status == null
                  ? null
                  : AccessStatusBadge.colorFor(f.status!),
            ))
        .toList(growable: false);
  }

  /// Search + Filter + Sort + Export (Figma 7398:10662).
  ///
  /// The 768 frame (7398:10875) draws all three trailing controls as bare
  /// icons. Only Export follows it: `customButtonWithSvg` has a real icon-only
  /// mode (a 38.sp square) when handed an empty title, while `CustomFilterIcon`
  /// and `CustomSortIcon` are pinned to 100.sp on any non-phone window — so
  /// dropping THEIR labels would leave the buttons exactly as wide with a hole
  /// where the word used to be, and buy the search box nothing. They collapse
  /// on a phone, which those widgets handle themselves.
  Widget _toolbar(DatabaseDetailsStrings strings, DatabaseAccessState state) {
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
          onChanged: _cubit.searchChanged,
        ),
        SizedBox(width: 10.w),

        // Tinted while a department filter is applied: the dialog closes over
        // the table, so without this the only evidence the list is being
        // narrowed is rows being absent — which reads as data loss, not as a
        // filter. Same treatment as db1's list toolbar.
        CustomFilterIcon(
          title: strings.filter,
          color: state.hasDepartmentFilter
              ? AppColors.primary
              : AppColors.card,
          svgColor: state.hasDepartmentFilter
              ? AppColors.textButton
              : AppColors.secondaryText,
          textStyle: StyleText.fontSize14Weight400.copyWith(
            color: state.hasDepartmentFilter
                ? AppColors.textButton
                : AppColors.secondaryText,
          ),
          onTap: _onFilterPressed,
        ),
        SizedBox(width: 10.w),

        // TODO(db2): Sort opens its own popover in the Figma. Still a no-op,
        // so it renders without claiming a state it does not have.
        CustomSortIcon(
          title: strings.sort,
          color: AppColors.card,
          onTap: () {},
        ),
        SizedBox(width: 10.w),

        customButtonWithSvg(
          title: compact ? '' : strings.export,
          function: state.isExporting ? () {} : _onExportPressed,
          color: state.isExporting ? AppColors.disabledGrey : AppColors.primary,
          colorBorder: AppColors.transparent,
          image: DatabaseDetailsAssets.export,
          widthImage: compact ? 20.r : 16.r,
          heightImage: compact ? 20.r : 16.r,
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
