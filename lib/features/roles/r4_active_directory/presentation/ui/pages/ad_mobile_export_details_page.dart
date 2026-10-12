/// Module: roles / r4_active_directory / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: ad_mobile_export_details_page.dart
/// Purpose: Declares `AdMobileExportDetailsPage` — the PHONE BODY of the
///          Active Directory tab.
/// Author: Knowticed Plus team
/// Created At: 9/9/2026
/// Updated: 9/9/2026 - This is now what the Active Directory TAB renders on a
///          phone (see `CsvView`), not a page pushed from an Export button.
///          The frame is the tab's content, so the widget draws no Scaffold,
///          no page title and no tab row — `RoleScreen` already draws those
///          above it — and starts straight at "Export Details".
///
/// Figma: MESBAH / page ROLE MANAGEMENT, node 6975:11036 (iPhone, 375x1038).
///
/// WHY A PAGE AND NOT THE EXISTING DIALOG
/// `_ExportDialog` (csv_export_dialog.dart) is a two-pane `Dialog`: filters on
/// the left, the preview list revealed beside them on the right. The phone
/// design is two SEPARATE full-screen steps — a card of stacked fields, then a
/// searchable list of matches. That is a different information architecture,
/// not a narrower one, so the dialog is left exactly as it is for tablet and
/// desktop and the phone gets this pair of pages.
///
/// THE FIELDS ARE THE FRAME'S, NOT THE DIALOG'S
/// The desktop dialog has nine dropdowns; this frame draws ten — it adds
/// Nationality between Gender and Country. The uploaded CSV has no nationality
/// column (`EmployeeDataItems` goes gender → country, and `_ColumnIndex`
/// records `nationality = -1`), so that dropdown is drawn with an empty option
/// list: the row is where Figma puts it and it starts working the day the
/// column exists, rather than being silently dropped from the screen.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/pages/ad_mobile_export_preview_page.dart';
import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_widgets.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/localized_digits.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Column positions inside a `usersData` row.
///
/// A private copy of the `_ColumnIndex` in custom_csv_table_page.dart: that one
/// is a private declaration inside a part-file family this page is not part of,
/// so it cannot be imported. Both are derived from `EmployeeDataItems` order,
/// and this one says so in code rather than in a comment, so the two cannot
/// drift when a field is inserted into the enum.
abstract class _Column {
  static final int department = EmployeeDataItems.departmentEnglishName.index;
  static final int role = EmployeeDataItems.role.index;
  static final int title = EmployeeDataItems.englishTitle.index;
  static final int workLocation = EmployeeDataItems.workLocation.index;
  static final int supervisor = EmployeeDataItems.supervisorEmail.index;
  static final int gender = EmployeeDataItems.gender.index;
  static final int country = EmployeeDataItems.country.index;
  static final int firstName = EmployeeDataItems.firstName.index;
  static final int lastName = EmployeeDataItems.lastName.index;
  static final int id = EmployeeDataItems.id.index;

  /// Not in the uploaded document — see the file header.
  static const int nationality = -1;
}

class AdMobileExportDetailsPage extends StatefulWidget {
  const AdMobileExportDetailsPage({super.key});

  @override
  State<AdMobileExportDetailsPage> createState() =>
      _AdMobileExportDetailsPageState();
}

class _AdMobileExportDetailsPageState extends State<AdMobileExportDetailsPage> {
  final ActiveDirectoryController _ctrl = AppControllers.activeDirectory;

  // ── Selections ────────────────────────────────────────────────────────────
  String? _department;
  String? _role;
  String? _title;
  String? _workLocation;
  String? _supervisor;
  String? _gender;
  String? _nationality;
  String? _country;
  String? _fileFormat;
  String? _language;

  // ── Option lists, derived from the uploaded document ──────────────────────
  //
  // Read at BUILD time, not in `initState`. The controller loads `usersData`
  // asynchronously from its own constructor, so at the moment this widget is
  // first built the document is usually still empty — lists captured in
  // `initState` would stay empty for the life of the screen and every dropdown
  // would open onto nothing. `_memoRowCount` keeps the eight passes from being
  // redone on every `setState`, since the document does not change while the
  // form is open.
  int _memoRowCount = -1;
  List<String> _departments = const [];
  List<String> _roles = const [];
  List<String> _titles = const [];
  List<String> _workLocations = const [];
  List<String> _supervisors = const [];
  List<String> _genders = const [];
  List<String> _nationalities = const [];
  List<String> _countries = const [];

  void _refreshOptions() {
    if (_memoRowCount == _ctrl.usersData.length) return;
    _memoRowCount = _ctrl.usersData.length;
    _departments = _distinct(_Column.department);
    _roles = _distinct(_Column.role);
    _titles = _distinct(_Column.title);
    _workLocations = _distinct(_Column.workLocation);
    _supervisors = _distinct(_Column.supervisor);
    _genders = _distinct(_Column.gender);
    _nationalities = _distinct(_Column.nationality);
    _countries = _distinct(_Column.country);
  }

  /// Locale-independent codes; the label is resolved at build time, so
  /// switching language relabels the options without orphaning a selection.
  /// Same contract as the desktop dialog.
  static const List<String> _fileFormatCodes = ['csv', 'xlsx', 'pdf'];
  static const List<String> _languageCodes = ['en', 'ar', 'both'];

  // ── Data ──────────────────────────────────────────────────────────────────

  /// Unique, sorted, non-empty values of one column. A negative index (a
  /// column the document does not carry) yields an empty list rather than
  /// throwing.
  List<String> _distinct(int column) {
    if (column < 0) return const [];
    // Role QA p.21 / p.45: "Egypt" and "egypt" were listed as two countries.
    // Values are de-duplicated ignoring case (matching is already
    // case-insensitive, see [_matchingRows]), sorted the same way.
    final Map<String, String> byKey = <String, String>{};
    for (final row in _ctrl.usersData) {
      final String value =
          row.length > column ? (row[column]?.toString().trim() ?? '') : '';
      if (value.isEmpty) continue;
      byKey.putIfAbsent(value.toLowerCase(), () => value);
    }
    return byKey.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  /// Rows matching every active selection. The two app-defined dropdowns
  /// (file format, language) describe the OUTPUT and are deliberately not
  /// filters.
  List<List<dynamic>> get _matchingRows {
    bool matches(List<dynamic> row, String? value, int column) {
      if (value == null || value.isEmpty || column < 0) return true;
      if (row.length <= column) return false;
      return row[column]?.toString().trim().toLowerCase() ==
          value.trim().toLowerCase();
    }

    return _ctrl.usersData
        .where((row) =>
            matches(row, _department, _Column.department) &&
            matches(row, _role, _Column.role) &&
            matches(row, _title, _Column.title) &&
            matches(row, _workLocation, _Column.workLocation) &&
            matches(row, _supervisor, _Column.supervisor) &&
            matches(row, _gender, _Column.gender) &&
            matches(row, _nationality, _Column.nationality) &&
            matches(row, _country, _Column.country))
        .cast<List<dynamic>>()
        .toList();
  }

  void _clear() {
    setState(() {
      _department = null;
      _role = null;
      _title = null;
      _workLocation = null;
      _supervisor = null;
      _gender = null;
      _nationality = null;
      _country = null;
      _fileFormat = null;
      _language = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // BlocBuilder, not a bare build: `usersData` arrives asynchronously after
    // `ActiveDirectoryController`'s constructor kicks off `init()`, and this
    // widget is mounted before that finishes. Without listening, the form would
    // render its dropdowns from an empty document and never refill them.
    return BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
      bloc: AppControllers.activeDirectory,
      builder: (context, state) {
        if (_ctrl.loadingData) {
          return const Center(child: CircleProgressMaster());
        }

        _refreshOptions();

        final S s = S.of(context);
        final List<List<dynamic>> rows = _matchingRows;

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
              MobileExportSectionTitle(text: s.exportDetails),
              // Section title -> card top 193.
              SizedBox(height: 8.h),
              MobileExportCard(children: _fields(s)),
              SizedBox(height: MobileExportMetrics.buttonsTopGap.h),
              MobileExportActions(
                secondaryLabel: s.clearFilter,
                onSecondary: _clear,
                // The frame draws this pair 150 + hug, not the usual 135 + 135
                // (nodes 6975:23577 and 6975:23715) — the match count makes the
                // primary label too long for a pinned width.
                secondaryWidth: 150,
                primaryHugsContent: true,
                primaryLabel: s.previewMatches(
                  LocalizedDigits.apply(
                    rows.length.toString(),
                    Localizations.localeOf(context).languageCode,
                  ),
                ),
                primaryEnabled: rows.isNotEmpty,
                onPrimary: () => _openPreview(rows),
              ),
            ],
          ),
        );
      },
    );
  }

  /// The ten rows of the card, in the frame's order, each separated by the
  /// 6 that makes consecutive label tops 69 apart.
  List<Widget> _fields(S s) {
    final List<Widget> items = [
      MobileExportDropdownField(
        label: s.department,
        hint: s.selectDepartments,
        items: _itemsOf(_departments),
        value: _department,
        onChanged: (v) => setState(() => _department = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.role,
        hint: s.selectRole,
        items: _itemsOf(_roles),
        value: _role,
        onChanged: (v) => setState(() => _role = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.title,
        hint: s.selectTitle,
        items: _itemsOf(_titles),
        value: _title,
        onChanged: (v) => setState(() => _title = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.workLocation,
        hint: s.selectWorkLocation,
        items: _itemsOf(_workLocations),
        value: _workLocation,
        onChanged: (v) => setState(() => _workLocation = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.supervisor,
        hint: s.selectSupervisor,
        items: _itemsOf(_supervisors),
        value: _supervisor,
        onChanged: (v) => setState(() => _supervisor = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.gender,
        hint: s.selectGender,
        items: _itemsOf(_genders),
        value: _gender,
        onChanged: (v) => setState(() => _gender = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.nationality,
        hint: s.selectNationality,
        items: _itemsOf(_nationalities),
        value: _nationality,
        onChanged: (v) => setState(() => _nationality = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.country,
        // The frame's placeholder here reads "Select City"; the label above it
        // is Country and the column behind it is Country, so the placeholder
        // is the frame's slip and the Country hint is used.
        hint: s.selectCountry,
        items: _itemsOf(_countries),
        value: _country,
        onChanged: (v) => setState(() => _country = _orAll(v)),
      ),
      MobileExportDropdownField(
        label: s.fileFormat,
        hint: s.selectFileFormat,
        items: [
          for (final String code in _fileFormatCodes)
            DropdownItem(value: code, label: _fileFormatLabel(code)),
        ],
        value: _fileFormat,
        onChanged: (v) => setState(() => _fileFormat = v),
      ),
      MobileExportDropdownField(
        label: s.language,
        hint: s.selectLanguage,
        items: [
          for (final String code in _languageCodes)
            DropdownItem(value: code, label: _languageLabel(code)),
        ],
        value: _language,
        onChanged: (v) => setState(() => _language = v),
      ),
    ];

    final List<Widget> spaced = [];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) spaced.add(const MobileExportFieldGap());
      spaced.add(items[i]);
    }
    return spaced;
  }

  /// CSV-derived values are their own label — they are data, so they are not
  /// translated.
  ///
  /// Role QA p.43-46: labels are capitalised ("hr specialist" → "HR
  /// Specialist", "jordan" → "Jordan"); the stored value is untouched.
  /// Role QA p.21: every list opens with an "All" row that clears the filter.
  List<DropdownItem<String>> _itemsOf(List<String> values) => [
        DropdownItem(value: _allValue, label: S.of(context).all),
        for (final String v in values)
          DropdownItem(value: v, label: FormatHelper.capitalize(v)),
      ];

  /// Sentinel for the "All" row — picking it clears the selection.
  static const String _allValue = '__all__';

  String? _orAll(String? v) => v == _allValue ? null : v;

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

  void _openPreview(List<List<dynamic>> rows) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdMobileExportPreviewPage(
          rows: rows,
          nameColumns: [_Column.firstName, _Column.lastName],
          departmentColumn: _Column.department,
          titleColumn: _Column.title,
          genderColumn: _Column.gender,
          idColumn: _Column.id,
        ),
      ),
    );
  }
}
