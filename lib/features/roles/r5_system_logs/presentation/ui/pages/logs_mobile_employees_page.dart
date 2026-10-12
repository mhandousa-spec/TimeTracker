/// Module: roles / r5_system_logs / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: logs_mobile_employees_page.dart
/// Purpose: Declares `LogsMobileEmployeesPage` — step 2 of the phone export
///          flow for System Logs.
/// Author: Knowticed Plus team
/// Created At: 9/9/2026
/// Updated: 9/9/2026 - Wears `SideFrameMasterServices` like every other pushed
///          page in the roles module, and searches with `AppSearchTextField`.
///
/// Figma: MESBAH / page ROLE MANAGEMENT, node 6976:24438 (iPhone, 375x1038)
/// and the card it opens, node 6976:24238 (340x192).
///
/// The Active Directory preview is read-only — it shows who is about to be
/// exported. This one is a PICKER: the frame gives every row a tick and adds a
/// Select All button, so the export is narrowed one more time to the people
/// the admin cares about.
///
/// WHERE THE PEOPLE COME FROM
/// A `SystemLogsModel` carries the actor's name and e-mail but no department,
/// job title or photo — and the card draws all three. So the rows are grouped
/// by e-mail and each group is enriched from
/// `MainCoreEmployeeController.mapOfEmployeesWithEmailKey`, falling back to
/// what the log itself holds when an actor is no longer in the directory
/// (someone who has since left still appears in the logs and must still be
/// exportable).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/domain/enums/system_logs_items.dart';
import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_person.dart';
import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LogsMobileEmployeesPage extends StatefulWidget {
  const LogsMobileEmployeesPage({
    super.key,
    required this.logs,
    this.columns = const <SystemLogsItems>[],
  });

  /// Log entries that survived the Export Details filters.
  final List<SystemLogsModel> logs;

  /// The columns the admin ticked in Column To Export, in enum order.
  ///
  /// CHANGED 10/9/2026 from a single nullable `column`. That field is a
  /// multi-select now, so the answer it produces is a list; EMPTY means every
  /// column, exactly as `null` did.
  final List<SystemLogsItems> columns;

  @override
  State<LogsMobileEmployeesPage> createState() =>
      _LogsMobileEmployeesPageState();
}

class _LogsMobileEmployeesPageState extends State<LogsMobileEmployeesPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  /// Selected actors, keyed by the lower-cased e-mail so a capitalised copy of
  /// the same address cannot tick twice. `SystemLogsModel.fromMap` runs every
  /// field through `FormatHelper.capitalize`, so the e-mail on a log is NOT
  /// the one the directory is keyed by — hence the folding, here and in the
  /// lookup below.
  final Set<String> _selected = <String>{};

  List<MobileExportPerson> _people = const <MobileExportPerson>[];
  bool _peopleBuilt = false;

  /// Every log belonging to one actor, by the same folded key.
  late final Map<String, List<SystemLogsModel>> _logsByPerson;

  @override
  void initState() {
    super.initState();
    _logsByPerson = <String, List<SystemLogsModel>>{};
    for (final SystemLogsModel log in widget.logs) {
      _logsByPerson.putIfAbsent(_keyOf(log), () => <SystemLogsModel>[]).add(log);
    }
    // Everyone starts ticked: the previous step already narrowed the set, so
    // the default is "export what I just filtered" and the ticks are there to
    // remove people, not to have to add them all back one at a time.
    _selected.addAll(_logsByPerson.keys);
  }

  /// Built once here rather than in `build`: the directory lookup and the name
  /// assembly do not change for the life of the screen, and redoing them on
  /// every keystroke in the search box would repeat that work per character.
  ///
  /// `didChangeDependencies`, not `initState`, because it reads the locale and
  /// the department cubit — both inherited, and inherited widgets may not be
  /// looked up from `initState`.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_peopleBuilt) return;
    _peopleBuilt = true;
    _people = _buildPeople();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── People ────────────────────────────────────────────────────────────────

  String _keyOf(SystemLogsModel log) =>
      (log.userEmail ?? '').trim().toLowerCase();

  List<MobileExportPerson> _buildPeople() {
    final bool isArabic = context.isArabic;

    // The directory is keyed by the e-mail exactly as it was stored; fold it
    // once so a lookup by the log's capitalised copy still lands.
    final Map<String, EmployeeEntityPro> directory = {
      for (final MapEntry<String, EmployeeEntityPro> entry
          in AppControllers.employee.mapOfEmployeesWithEmailKey.entries)
        entry.key.trim().toLowerCase(): entry.value,
    };

    final MainCoreDepartmentCubit departments =
        context.read<MainCoreDepartmentCubit>();

    final List<MobileExportPerson> people = [];

    _logsByPerson.forEach((String key, List<SystemLogsModel> logs) {
      final SystemLogsModel log = logs.first;
      final EmployeeEntityPro? employee = directory[key];

      final String name = [
        isArabic ? (log.firstNameInArabic ?? log.firstName) : log.firstName,
        isArabic ? (log.lastNameInArabic ?? log.lastName) : log.lastName,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');

      final String department = (employee?.departmentId ?? '').isEmpty
          ? ''
          : departments.getDepartmentName(employee!.departmentId!, !isArabic);

      people.add(
        MobileExportPerson(
          id: key,
          // An actor with no name on the log falls back to the address, so a
          // row is never blank and can still be searched for.
          name: name.isEmpty ? (log.userEmail ?? key) : name,
          department: department,
          jobTitle: (isArabic
                  ? (employee?.titleInArabic ?? employee?.title)
                  : employee?.title) ??
              log.role ??
              '',
          imagePath: employee?.photo ?? '',
          gender: employee?.gender?.toLowerCase(),
        ),
      );
    });

    people.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return people;
  }

  List<MobileExportPerson> get _visible {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return _people;
    return _people
        .where((person) => person.searchIndex.contains(q))
        .toList();
  }

  /// Select All ticks everything currently listed; tapping it again once they
  /// are all ticked clears them, so the one button covers both directions the
  /// way a header checkbox does.
  void _toggleAll() {
    final List<MobileExportPerson> visible = _visible;
    final bool allSelected =
        visible.isNotEmpty && visible.every((p) => _selected.contains(p.id));

    setState(() {
      if (allSelected) {
        _selected.removeAll(visible.map((p) => p.id));
      } else {
        _selected.addAll(visible.map((p) => p.id));
      }
    });
  }

  // ── Export ────────────────────────────────────────────────────────────────

  /// The columns written to the file — the admin's picks, or all twelve when
  /// they ticked none (the same set `SystemLogsController._fillHeaders` uses).
  List<SystemLogsItems> get _columns =>
      widget.columns.isEmpty ? SystemLogsItems.values : widget.columns;

  /// The rows the file is made of — a header of column names, then one line
  /// per log belonging to a ticked person.
  List<List<dynamic>> _rows() {
    final bool isArabic = context.isArabic;
    final List<SystemLogsItems> columns = _columns;

    final List<List<dynamic>> rows = [
      [for (final SystemLogsItems item in columns) item.name],
    ];
    for (final String key in _selected) {
      for (final SystemLogsModel log in _logsByPerson[key] ?? const []) {
        rows.add([
          for (final SystemLogsItems item in columns)
            item.itemValue(log, isArabic: isArabic),
        ]);
      }
    }
    return rows;
  }

  /// Opens the file-name card and lets it drive the export.
  ///
  /// REWRITTEN 10/9/2026 — "export page not work". This used to await a file
  /// name, write it with `CSVHelper.exportToCSV`, and then report success or
  /// failure itself. Two things were wrong with that, and the first is why
  /// nothing ever appeared on a phone:
  ///
  ///  * `exportToCSV` writes into a folder. On Android that folder is barred by
  ///    scoped storage and the write throws; on iOS it is the app's private
  ///    Documents, which no other app — and no user — can open. Neither is a
  ///    place an export can land. `CSVHelper.exportForUser` hands the file to
  ///    the system save sheet instead, and the user says where it goes.
  ///  * The outcome was a bool, so a dismissed save sheet, a failed write and a
  ///    real export were three things this could not tell apart. The card
  ///    reports all three now.
  ///
  /// The card owns the wait and the messages (see `MobileExportFileNameDialog`)
  /// and resolves true only when a file was actually written — which is the one
  /// case where this page should close behind it.
  Future<void> _export() async {
    final bool exported = await MobileExportFileNameDialog.show(
      context,
      defaultFileName:
          mobileExportDefaultFileName(context, S.of(context).systemsLogs),
      onExport: (String fileName) => CSVHelper().exportRowsForUser(
        fileName: fileName,
        rows: _rows(),
      ),
    );

    if (!mounted || !exported) return;
    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<MobileExportPerson> visible = _visible;

    // The frame owns the header, the back chevron, the Scaffold background and
    // the 15.sp horizontal page padding — the same wrapper Adding New Access
    // wears. `SideFrameBoundedBody` is what makes the `Flexible` below legal:
    // on a phone the frame lays its child out inside a SingleChildScrollView,
    // so the incoming height is unbounded.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: s.platformControlsAndManagement,
          onFirstTap: () => popFrameRoutes(context, 1),
          secondTitle: s.employees,
          // Room for the bottom navigation bar (Role QA p.49).
          child: SideFrameBoundedBody(
            extraReserved: 60.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.employees,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                ),
                SizedBox(height: 10.sp),
                // `expanded: false` — AppSearchTextField wraps itself in an
                // Expanded by default, which is right for the search rows that
                // sit in a Row beside filter buttons and illegal here, where it
                // is a direct child of a Column.
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
                            s.noEmployeesFound,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.secondaryText),
                          ),
                        )
                      // Role QA p.49: `shrinkWrap` so a short list no longer
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
                            final MobileExportPerson person = visible[index];
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
