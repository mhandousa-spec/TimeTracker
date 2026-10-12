/// Module: roles / r5_system_logs / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: logs_mobile_export_details_page.dart
/// Purpose: Declares `LogsMobileExportDetailsPage` — the PHONE BODY of the
///          System Logs tab.
/// Author: Knowticed Plus team
/// Created At: 9/9/2026
/// Updated: 9/9/2026 - This is now what the System Logs TAB renders on a phone
///          (see `SystemLogsTable`), not a page pushed from an Export button.
///          The frame is the tab's content, so the widget draws no Scaffold,
///          no page title and no tab row — `RoleScreen` already draws those
///          above it — and starts straight at "Export Details".
///
/// Figma: MESBAH / page ROLE MANAGEMENT, node 6976:24621 (iPhone, 375x1180).
///
/// WHY A PAGE AND NOT THE EXISTING DIALOG
/// `SystemLogsDownloadDialog` is a file-name box and nothing else — the phone
/// frame is a full filter form followed by an employee picker. Same reason as
/// the Active Directory side: the phone gets its own two steps and the
/// existing dialog stays untouched for tablet and desktop.
///
/// THE FILTERS ARE APPLIED LOCALLY, NOT PUSHED INTO THE CONTROLLER
/// `SystemLogsController.filterLogs` mutates `finalSystemLogsList`, which is
/// the list the table BEHIND this flow renders. Exporting must not silently
/// re-filter the screen the user came from, so this page derives its own
/// matching list from `systemLogsData` and hands it to the next step. Nothing
/// here changes what the table shows.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_person.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/domain/enums/system_logs_items.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/pages/logs_mobile_employees_page.dart';
import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The four preset ranges of the Date Range block, in the frame's reading
/// order: Today, Last 7 Days (top row), Last 30 Days, Custom (second row).
enum _DateRange { today, last7Days, last30Days, custom }

class LogsMobileExportDetailsPage extends StatefulWidget {
  const LogsMobileExportDetailsPage({super.key});

  @override
  State<LogsMobileExportDetailsPage> createState() =>
      _LogsMobileExportDetailsPageState();
}

class _LogsMobileExportDetailsPageState
    extends State<LogsMobileExportDetailsPage> {
  final SystemLogsController _ctrl = AppControllers.systemLogs;

  // ── Employee search (10/9/2026) ───────────────────────────────────────────
  //
  // A named-people filter above the form: type a name, tap a row, and that
  // person becomes an avatar under the box. It is the ninth filter and the
  // narrowest one — the eight dropdowns describe a KIND of log, this names the
  // people whose logs are wanted.
  //
  // It searches the whole directory rather than only the actors in the
  // currently-matching logs. Which people HAVE logs is what the filters above
  // are for; making the picker depend on them too would mean the list of names
  // silently changed under the user every time they touched a dropdown.
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  /// Picked people, keyed by folded e-mail — the same key `_keyOf` derives
  /// from a log, so a pick can be matched against `SystemLogsModel.userEmail`
  /// without another lookup.
  final Map<String, MobileExportPerson> _picked =
      <String, MobileExportPerson>{};

  /// The whole directory as cards.
  ///
  /// Rebuilt whenever the underlying map changes SIZE rather than once and for
  /// all: `MainCoreEmployeeController` fills
  /// `mapOfEmployeesWithEmailKey` asynchronously, so a list captured the first
  /// time this tab is built is usually captured empty — and an empty list here
  /// is a search box that silently finds nobody for the life of the screen.
  /// The same guard the Active Directory form uses for its option lists.
  ///
  /// It is `didChangeDependencies`, not `initState`, because building a row
  /// reads the locale and the department cubit — both inherited, and inherited
  /// widgets may not be looked up from `initState`.
  List<MobileExportPerson> _directory = const <MobileExportPerson>[];
  int _memoDirectorySize = -1;

  // ── Selections ────────────────────────────────────────────────────────────
  _DateRange? _range;
  DateTime? _customFrom;
  DateTime? _customTo;

  // ── Every field on this form is a MULTI-SELECT (10/9/2026) ───────────────
  //
  // They were eight single-value dropdowns. One value per field made the form
  // able to ask only the narrowest possible question — one role, one country,
  // one column — when the thing an admin actually wants to export is "these
  // three roles across these two countries".
  //
  // EMPTY MEANS "DO NOT NARROW BY THIS", for all eight. That is what `null`
  // meant before, so an untouched form still matches every log and still
  // exports every column, exactly as it did.
  //
  // Within one field the picks are OR-ed (Country = France OR Germany);
  // across fields they are AND-ed (a French log with the wrong role is out).
  // That is the only reading that makes a filter form useful: a log cannot be
  // in two countries at once, so AND-ing inside a field would match nothing.
  List<String> _roles = <String>[];
  List<String> _modules = <String>[];
  List<String> _actions = <String>[];
  List<String> _countries = <String>[];
  List<String> _cities = <String>[];

  /// The columns the admin ticked, by `SystemLogsItems.name`. Empty is every
  /// column, which is what the desktop export writes.
  List<String> _columns = <String>[];

  /// Neither of these narrows anything and neither reaches the export yet —
  /// `LogsMobileEmployeesPage` always writes CSV through `CSVHelper`. They are
  /// on the form because the frame draws them, and they are multi-select for
  /// the same reason the other six are: the eight boxes have to behave alike.
  List<String> _fileFormats = <String>[];
  List<String> _languages = <String>[];

  static const List<String> _fileFormatCodes = ['csv', 'xlsx', 'pdf'];
  static const List<String> _languageCodes = ['en', 'ar', 'both'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshDirectory();
  }

  void _refreshDirectory() {
    final int size = AppControllers.employee.mapOfEmployeesWithEmailKey.length;
    if (_memoDirectorySize == size) return;
    _memoDirectorySize = size;
    _directory = _buildDirectory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Employee search ───────────────────────────────────────────────────────

  /// Every employee in the directory as a card, sorted by name.
  ///
  /// The same shape `LogsMobileEmployeesPage` builds for step 2, drawn from the
  /// same map — `MainCoreEmployeeController.mapOfEmployeesWithEmailKey` — so a
  /// person picked here is the same row, with the same photo and department,
  /// as the one they are shown on the next screen.
  List<MobileExportPerson> _buildDirectory() {
    final bool isArabic = context.isArabic;
    final MainCoreDepartmentCubit departments =
        context.read<MainCoreDepartmentCubit>();

    final List<MobileExportPerson> people = [];

    AppControllers.employee.mapOfEmployeesWithEmailKey
        .forEach((String email, EmployeeEntityPro employee) {
      final String name = [
        isArabic ? (employee.firstNameInArabic ?? employee.firstName)
                 : employee.firstName,
        isArabic ? (employee.lastNameInArabic ?? employee.lastName)
                 : employee.lastName,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');

      final String department = (employee.departmentId ?? '').isEmpty
          ? ''
          : departments.getDepartmentName(employee.departmentId!, !isArabic);

      people.add(
        MobileExportPerson(
          // Folded, so it equals the key `_keyOf` derives from a log — the
          // directory stores the address as it was entered, the log stores a
          // capitalised copy.
          id: email.trim().toLowerCase(),
          // An employee with no name falls back to the address, so a row is
          // never blank and can still be searched for.
          name: name.isEmpty ? email : name,
          department: department,
          jobTitle:
              (isArabic ? (employee.titleInArabic ?? employee.title)
                        : employee.title) ??
                  employee.role ??
                  '',
          imagePath: employee.photo ?? '',
          gender: employee.gender?.toLowerCase(),
        ),
      );
    });

    people.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return people;
  }

  /// The rows the search box is currently offering.
  ///
  /// Empty while nothing is typed — the list is a RESULT, not a browser: all
  /// several hundred employees under the search bar would push the form itself
  /// off the screen. Already-picked people drop out too, since their avatar is
  /// the thing to tap when they need removing.
  List<MobileExportPerson> get _results {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return const <MobileExportPerson>[];
    return _directory
        .where((person) =>
            !_picked.containsKey(person.id) && person.searchIndex.contains(q))
        .toList();
  }

  void _pick(MobileExportPerson person) {
    setState(() {
      _picked[person.id] = person;
      // The field empties and the results collapse with it, ready for the next
      // name rather than leaving a stale list of one behind.
      _searchCtrl.clear();
      _query = '';
    });
  }

  void _unpick(String id) => setState(() => _picked.remove(id));

  String _keyOf(SystemLogsModel log) =>
      (log.userEmail ?? '').trim().toLowerCase();

  // ── Date range ────────────────────────────────────────────────────────────

  /// Inclusive start of the selected range, or null when nothing is picked.
  ///
  /// The presets are anchored on midnight today so "Last 7 Days" always means
  /// seven whole days rather than a window that slides with the clock while
  /// the user is filling the form in.
  DateTime? get _from {
    final DateTime now = DateTime.now();
    final DateTime midnight = DateTime(now.year, now.month, now.day);
    switch (_range) {
      case _DateRange.today:
        return midnight;
      case _DateRange.last7Days:
        return midnight.subtract(const Duration(days: 7));
      case _DateRange.last30Days:
        return midnight.subtract(const Duration(days: 30));
      case _DateRange.custom:
        return _customFrom;
      case null:
        return null;
    }
  }

  /// Inclusive end of the selected range. The presets all run up to now.
  DateTime? get _to =>
      _range == _DateRange.custom ? _customTo : DateTime.now();

  // ── Matching ──────────────────────────────────────────────────────────────

  /// True when [value] is one of [selected], or when nothing is selected.
  ///
  /// Case- and whitespace-insensitive for the same reason the single-value
  /// version was: `SystemLogsModel.fromMap` runs every field through
  /// `FormatHelper.capitalize`, while the option lists are built from the
  /// employee directory, so the two spellings of one country need not match
  /// byte for byte.
  bool _matchesAny(List<String> selected, String? value) {
    if (selected.isEmpty) return true;
    final String actual = (value ?? '').trim().toLowerCase();
    return selected.any((s) => s.trim().toLowerCase() == actual);
  }

  bool _matchesDate(SystemLogsModel log) {
    final DateTime? from = _from;
    if (from == null) return true;

    final DateTime? stamp = log.timestamp?.toDate();
    if (stamp == null) return false;

    if (stamp.isBefore(from)) return false;

    final DateTime? to = _to;
    // The end is inclusive of the whole day the user picked, so the comparison
    // runs against the following midnight rather than the picked instant —
    // otherwise a "to" of 12 Sept excludes everything logged that afternoon.
    if (to != null) {
      final DateTime endOfDay =
          DateTime(to.year, to.month, to.day).add(const Duration(days: 1));
      if (!stamp.isBefore(endOfDay)) return false;
    }
    return true;
  }

  List<SystemLogsModel> get _matchingLogs {
    return _ctrl.systemLogsData.where((log) {
      // The named-people filter, and the narrowest one: picking nobody means
      // everybody, exactly like the eight dropdowns above.
      if (_picked.isNotEmpty && !_picked.containsKey(_keyOf(log))) return false;
      if (!_matchesAny(_roles, log.role)) return false;
      if (!_matchesAny(_actions, log.action)) return false;
      if (!_matchesAny(_countries, log.country)) return false;
      if (!_matchesAny(_cities, log.city)) return false;
      // Modules are matched on the enum's `name`, not on its display text, so
      // the comparison is exact rather than case-folded.
      if (_modules.isNotEmpty && !_modules.contains(log.module?.name)) {
        return false;
      }
      return _matchesDate(log);
    }).toList();
  }

  void _clear() {
    setState(() {
      _range = null;
      _customFrom = null;
      _customTo = null;
      _roles = <String>[];
      _modules = <String>[];
      _actions = <String>[];
      _countries = <String>[];
      _cities = <String>[];
      _columns = <String>[];
      _fileFormats = <String>[];
      _languages = <String>[];
      // Clear Filter clears THIS filter too — leaving the avatars behind would
      // hold the count down with nothing on the form left to explain it.
      _picked.clear();
      _searchCtrl.clear();
      _query = '';
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    // Cheap: a length comparison on every build, a rebuild only when the
    // directory actually changed. See `_directory`.
    _refreshDirectory();
    final List<SystemLogsModel> logs = _matchingLogs;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        MobileExportMetrics.pagePadding.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Employee search, above Export Details ────────────────────────
          //
          // `expanded: false` is required: `AppSearchTextField` wraps itself in
          // an `Expanded` by default, which is right for the search rows that
          // sit in a `Row` beside filter buttons and illegal here, where it is
          // a direct child of a `Column`.
          AppSearchTextField(
            controller: _searchCtrl,
            hintText: s.searchEmployee,
            expanded: false,
            onChanged: (value) => setState(() => _query = value),
          ),
          MobileExportSelectedAvatars(
            people: _picked.values.toList(),
            onRemove: _unpick,
          ),
          _searchResults(s),
          SizedBox(height: 15.h),
          MobileExportSectionTitle(text: s.exportDetails),
          SizedBox(height: 8.h),
          MobileExportCard(children: _fields(s)),
          // Says why Next is grey. The filters CAN be fully filled in and still
          // match nothing — Country and City come from the employee directory
          // rather than from the logs, so "France" and "Fahaheel" are both
          // offered and together select no log at all. Without this the button
          // is indistinguishable from a broken one.
          if (logs.isEmpty) MobileExportNote(text: s.noMatchesFound),
          SizedBox(height: MobileExportMetrics.buttonsTopGap.h),
          MobileExportActions(
            secondaryLabel: s.clearFilter,
            onSecondary: _clear,
            // The count is on the label for the same reason the Active
            // Directory frame writes "Preview 142 Matches" on its own primary:
            // it turns the enabled/disabled state into something readable.
            // Role QA p.47: the count was the number of LOG ENTRIES (201)
            // while the next page lists EMPLOYEES — so "Next (201)" opened a
            // list of 4. It now counts the distinct employees, the same key
            // (the log's e-mail) the next page groups by.
            primaryLabel:
                '${s.next} (${logs.map(_keyOf).toSet().length})',
            primaryEnabled: logs.isNotEmpty,
            onPrimary: () => _openEmployees(logs),
          ),
        ],
      ),
    );
  }

  /// The rows the search box is offering, or a one-line "no matches" when what
  /// was typed finds nobody. Nothing at all while the box is empty.
  ///
  /// Not a `ListView`: this sits inside the tab's own `SingleChildScrollView`,
  /// so a second scrollable here would either need a fixed height — cutting the
  /// list off — or fight the outer one for the drag. A `Column` of cards grows
  /// with its content and scrolls with the page.
  Widget _searchResults(S s) {
    if (_query.trim().isEmpty) return const SizedBox.shrink();

    final List<MobileExportPerson> results = _results;

    if (results.isEmpty) {
      return MobileExportNote(text: s.noEmployeesFound);
    }

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        children: [
          for (int i = 0; i < results.length; i++) ...[
            if (i > 0) SizedBox(height: MobileExportMetrics.personCardGap.h),
            MobileExportPersonCard(
              person: results[i],
              onTap: () => _pick(results[i]),
              // No tick: a result row is not a checkbox list. Tapping it moves
              // the person into the avatar row above and the row leaves the
              // list, so a box that could only ever be drawn empty would be
              // saying something untrue about how the row behaves.
              showTick: false,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _fields(S s) {
    final List<Widget> items = [
      // ── Date Range ────────────────────────────────────────────────────────
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MobileExportFieldLabel(text: s.dateRange),
          MobileExportChipGrid(
            labels: [s.today, s.last7Days, s.last30Days, s.custom],
            selectedIndex: _range?.index,
            onSelected: (index) =>
                setState(() => _range = _DateRange.values[index]),
          ),
          // Only "Custom" needs two dates, and the frame has no room drawn for
          // them — so they appear under the chips when that chip is on and
          // take no space otherwise.
          if (_range == _DateRange.custom) ...[
            SizedBox(height: MobileExportMetrics.chipGap.h),
            Row(
              children: [
                Expanded(
                  child: CustomDropdownCalendar(
                    label: s.from,
                    hint: s.selectStartDate,
                    value: _customFrom,
                    height: MobileExportMetrics.fieldHeight,
                    fillColor: AppColors.background,
                    borderRadius: BorderRadius.circular(
                      MobileExportMetrics.fieldRadius.r,
                    ),
                    onChanged: (date) => setState(() => _customFrom = date),
                  ),
                ),
                SizedBox(width: MobileExportMetrics.chipGap.w),
                Expanded(
                  child: CustomDropdownCalendar(
                    label: s.to,
                    hint: s.selectEndDate,
                    value: _customTo,
                    height: MobileExportMetrics.fieldHeight,
                    fillColor: AppColors.background,
                    borderRadius: BorderRadius.circular(
                      MobileExportMetrics.fieldRadius.r,
                    ),
                    onChanged: (date) => setState(() => _customTo = date),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      // ── The eight fields, in the frame's order ───────────────────────────
      //
      // All eight are MULTI-SELECT. See the note on the state above for what an
      // empty selection means and how picks combine.
      MobileExportMultiSelectField(
        label: s.role,
        hint: s.selectRole,
        items: _itemsOf(_ctrl.accessNames),
        values: _roles,
        onChanged: (v) => setState(() => _roles = v),
      ),
      MobileExportMultiSelectField(
        label: s.module,
        hint: s.selectModule,
        // Value is the enum name so the comparison against `log.module` is
        // stable; the label is the module's display name, which is localized.
        items: [
          for (final Modules module in Modules.values)
            MultiSelectDropdownItem(
              value: module.name,
              label: module.getModuleName,
            ),
        ],
        values: _modules,
        onChanged: (v) => setState(() => _modules = v),
      ),
      MobileExportMultiSelectField(
        label: s.action,
        hint: s.selectAction,
        items: _itemsOf(_ctrl.actions),
        values: _actions,
        onChanged: (v) => setState(() => _actions = v),
      ),
      MobileExportMultiSelectField(
        label: s.country,
        hint: s.selectCountry,
        items: _itemsOf(_ctrl.countries),
        values: _countries,
        onChanged: (v) => setState(() => _countries = v),
      ),
      MobileExportMultiSelectField(
        label: s.city,
        hint: s.selectCity,
        items: _itemsOf(_ctrl.cities),
        values: _cities,
        onChanged: (v) => setState(() => _cities = v),
      ),
      // The exported columns are the log's own fields: ticking a few narrows
      // the file to those, ticking none writes them all, which is what the
      // desktop export does.
      MobileExportMultiSelectField(
        label: s.columnToExport,
        hint: s.selectColumn,
        items: [
          for (final SystemLogsItems item in SystemLogsItems.values)
            MultiSelectDropdownItem(value: item.name, label: item.name),
        ],
        values: _columns,
        onChanged: (v) => setState(() => _columns = v),
      ),
      MobileExportMultiSelectField(
        label: s.fileFormat,
        hint: s.selectFileFormat,
        items: [
          for (final String code in _fileFormatCodes)
            MultiSelectDropdownItem(value: code, label: _fileFormatLabel(code)),
        ],
        values: _fileFormats,
        onChanged: (v) => setState(() => _fileFormats = v),
      ),
      MobileExportMultiSelectField(
        label: s.language,
        hint: s.selectLanguage,
        items: [
          for (final String code in _languageCodes)
            MultiSelectDropdownItem(value: code, label: _languageLabel(code)),
        ],
        values: _languages,
        onChanged: (v) => setState(() => _languages = v),
      ),
    ];

    final List<Widget> spaced = [];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) spaced.add(const MobileExportFieldGap());
      spaced.add(items[i]);
    }
    return spaced;
  }

  /// The plain string lists off the controller — role names, actions,
  /// countries, cities — as pickable rows. Value and label are the same string
  /// because the controller already holds them in the spelling users read.
  List<MultiSelectDropdownItem<String>> _itemsOf(List<String> values) => [
        for (final String v in values)
          MultiSelectDropdownItem(value: v, label: v),
      ];

  String _fileFormatLabel(String code) {
    switch (code) {
      case 'csv':
        return S.of(context).formatCsv;
      case 'xlsx':
        return S.of(context).formatExcel;
      default:
        return S.of(context).formatPdf;
    }
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'en':
        return S.of(context).english;
      case 'ar':
        return S.of(context).arabic;
      default:
        return S.of(context).bothLanguages;
    }
  }

  void _openEmployees(List<SystemLogsModel> logs) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LogsMobileEmployeesPage(
          logs: logs,
          // Empty means "every column", matching the desktop export. The order
          // is taken from the enum rather than from the order the admin ticked
          // in, so the file's header row always reads the same way.
          columns: [
            for (final SystemLogsItems item in SystemLogsItems.values)
              if (_columns.contains(item.name)) item,
          ],
        ),
      ),
    );
  }
}
