/// Module: roles / r4_active_directory / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: ad_mobile_export_preview_page.dart
/// Purpose: Declares `AdMobileExportPreviewPage` — step 2 of the phone export
///          flow for Active Directory.
/// Author: Knowticed Plus team
/// Created At: 9/9/2026
/// Updated: 9/9/2026 - Wears `SideFrameMasterServices` like every other pushed
///          page in the roles module, searches with `AppSearchTextField`, and
///          every row now carries the `CustomCheckBox` tick.
///
/// Figma: MESBAH / page ROLE MANAGEMENT, node 6975:23836 (iPhone, 375x1038)
/// and the card it opens, node 6975:24036 (340x192).
///
/// The rows arrive already filtered from the Export Details step; this screen
/// narrows them once more — by the search box and by the ticks — and hands the
/// survivors to `CSVHelper.exportForUser` through the file-name card.
///
/// EVERY ROW IS TICKABLE. The frame draws this list as a plain preview, but the
/// System Logs half of the same flow (node 6976:24438) draws the identical card
/// with a tick, and so does Adding New Access — so an admin who spots one wrong
/// person here would otherwise have to walk back to the filters to drop them.
/// The ticks start ON: the previous step already chose this set, so they are
/// there to REMOVE people, not to re-add all of them one at a time.
///
/// The column POSITIONS are passed in rather than re-derived here: the caller
/// owns the mapping from `EmployeeDataItems` to `usersData` offsets, and one
/// owner means the two screens cannot disagree about which cell is the job
/// title.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// The header row this page writes is `EmployeeDataItems` in enum order, the
// same one the desktop export uses.
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_person.dart';
import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AdMobileExportPreviewPage extends StatefulWidget {
  const AdMobileExportPreviewPage({
    super.key,
    required this.rows,
    required this.nameColumns,
    required this.departmentColumn,
    required this.titleColumn,
    required this.genderColumn,
    required this.idColumn,
  });

  /// Rows of `usersData` that survived the Export Details filters.
  final List<List<dynamic>> rows;

  /// Columns joined with a space to form the displayed name — first and last.
  final List<int> nameColumns;

  final int departmentColumn;
  final int titleColumn;
  final int genderColumn;
  final int idColumn;

  @override
  State<AdMobileExportPreviewPage> createState() =>
      _AdMobileExportPreviewPageState();
}

class _AdMobileExportPreviewPageState extends State<AdMobileExportPreviewPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  /// Ticked rows, keyed the same way [MobileExportPerson.id] is.
  final Set<String> _selected = <String>{};

  /// Row + person pairs, built once. The person is derived from the row's
  /// cells, and neither the rows nor the mapping change while this screen is
  /// open, so rebuilding them per keystroke would be pure waste.
  late final List<MapEntry<List<dynamic>, MobileExportPerson>> _all;

  @override
  void initState() {
    super.initState();
    _all = [
      for (int i = 0; i < widget.rows.length; i++)
        MapEntry(widget.rows[i], _personOf(widget.rows[i], i)),
    ];
    _selected.addAll(_all.map((entry) => entry.value.id));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  String _cell(List<dynamic> row, int column) =>
      (column >= 0 && row.length > column)
          ? (row[column]?.toString().trim() ?? '')
          : '';

  MobileExportPerson _personOf(List<dynamic> row, int index) {
    final String name = widget.nameColumns
        .map((c) => _cell(row, c))
        .where((part) => part.isNotEmpty)
        .join(' ');

    final String id = _cell(row, widget.idColumn);

    return MobileExportPerson(
      // The uploaded document can carry a blank id cell, and two blanks would
      // collide as one key — so the row position is the fallback.
      id: id.isEmpty ? 'row-$index' : id,
      name: name,
      department: _cell(row, widget.departmentColumn),
      jobTitle: _cell(row, widget.titleColumn),
      gender: _cell(row, widget.genderColumn).toLowerCase(),
    );
  }

  /// What the list shows: everything the search box still matches.
  List<MapEntry<List<dynamic>, MobileExportPerson>> get _visible {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where((entry) => entry.value.searchIndex.contains(q))
        .toList();
  }

  /// What Export writes: every ticked row, whether or not the search box is
  /// currently hiding it. Typing in the box is a way to FIND someone, not a
  /// second filter on the export — hiding a row must not silently drop it.
  List<List<dynamic>> get _selectedRows => _all
      .where((entry) => _selected.contains(entry.value.id))
      .map((entry) => entry.key)
      .toList();

  /// Select All ticks everything currently listed; tapping it again once they
  /// are all ticked clears them, so one button covers both directions.
  void _toggleAll() {
    final List<MapEntry<List<dynamic>, MobileExportPerson>> visible = _visible;
    final bool allSelected = visible.isNotEmpty &&
        visible.every((entry) => _selected.contains(entry.value.id));

    setState(() {
      if (allSelected) {
        _selected.removeAll(visible.map((entry) => entry.value.id));
      } else {
        _selected.addAll(visible.map((entry) => entry.value.id));
      }
    });
  }

  // ── Export ────────────────────────────────────────────────────────────────

  /// Opens the file-name card and lets it drive the export.
  ///
  /// REWRITTEN 10/9/2026, alongside the System Logs half of this flow. It used
  /// to await a name and hand the rows to
  /// `ActiveDirectoryController.exportSelectedRowsToCSV`, which writes through
  /// `CSVHelper.exportToCSV` — a folder write that scoped storage refuses on
  /// Android and that lands in the app's unreachable private Documents on iOS.
  /// The bool it returned could not tell a refused save sheet from a failure
  /// either, so the card said "saved" in every case.
  ///
  /// `CSVHelper.exportForUser` hands the file
  ///to the system save sheet, and the
  /// card owns the wait, the messages and the three outcomes — see
  /// `MobileExportFileNameDialog`.
  Future<void> _export() async {
    final List<List<dynamic>> rows = _selectedRows;
    if (rows.isEmpty) return;

    // The same header `ActiveDirectoryController._getExportData` writes, so
    // this file and the desktop export open identically in Excel.
    final List<List<dynamic>> out = [
      EmployeeDataItems.values.map((e) => e.name).toList(),
      ...rows,
    ];

    final bool exported = await MobileExportFileNameDialog.show(
      context,
      defaultFileName:
          mobileExportDefaultFileName(context, S.of(context).activeDirectory),
      onExport: (String fileName) => CSVHelper().exportRowsForUser(
        fileName: fileName,
        rows: out,
      ),
    );

    if (!mounted || !exported) return;
    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<MapEntry<List<dynamic>, MobileExportPerson>> visible = _visible;

    // The frame owns the header, the back chevron, the Scaffold background and
    // the 15.sp horizontal padding — the same wrapper Adding New Access and
    // User Access Details wear, so this page sits in the module rather than
    // beside it. `SideFrameBoundedBody` is what makes the `Flexible` below
    // legal: on a phone the frame lays its child out inside a
    // SingleChildScrollView, so the incoming height is unbounded.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: s.platformControlsAndManagement,
          onFirstTap: () => popFrameRoutes(context, 1),
          secondTitle: s.previewExport,
          // Room for the bottom navigation bar, so the action row stays
          // above it (Role QA p.48).
          child: SideFrameBoundedBody(
            extraReserved: 60.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.employeesMatches,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                ),
                SizedBox(height: 10.sp),
                // `expanded: false` — AppSearchTextField wraps itself in an
                // Expanded by default, for the search rows that sit in a Row
                // beside filter buttons. This one is a direct child of a
                // Column, where an Expanded would throw.
                AppSearchTextField(
                  controller: _search,
                  expanded: false,
                  hintText: s.searchEmployee,
                  onChanged: (value) => setState(() => _query = value),
                ),
                SizedBox(height: 10.sp),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: MobileExportSelectAllButton(onTap: _toggleAll),
                ),
                SizedBox(height: 15.sp),
                Flexible(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            s.noMatchesFound,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.secondaryText),
                          ),
                        )
                      // Role QA p.48: `shrinkWrap` so a short list no longer
                      // stretches to the bottom of the page and pushes
                      // Discard / Export out of sight under the nav bar.
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => SizedBox(
                            height: MobileExportMetrics.personCardGap.h,
                          ),
                          itemBuilder: (_, index) {
                            final MobileExportPerson person =
                                visible[index].value;
                            return MobileExportPersonCard(
                              person: person,
                              selected: _selected.contains(person.id),
                              onTap: () => setState(() {
                                if (!_selected.remove(person.id)) {
                                  _selected.add(person.id);
                                }
                              }),
                            );
                          },
                        ),
                ),
                SizedBox(height: MobileExportMetrics.buttonsTopGap.h),
                MobileExportActions(
                  secondaryLabel: s.discard,
                  onSecondary: () => Navigator.of(context).pop(),
                  primaryLabel: s.export,
                  primaryIcon: AppAssets.export,
                  primaryEnabled: _selected.isNotEmpty,
                  onPrimary: _export,
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
