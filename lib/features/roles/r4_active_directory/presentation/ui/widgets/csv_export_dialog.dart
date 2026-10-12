/// Module: roles / r4_active_directory / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: csv_export_dialog.dart
/// Purpose: Part file of `custom_csv_table_page.dart`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
///
/// FIXED 25/8/2026 — the export dialog was English-only. Every dropdown carried
/// a `labelEn`/`labelAr` pair but `_labeledDropdown` passed only the English
/// half to `CustomDropdown`, so the Arabic strings were dead code and an Arabic
/// reader saw "Select Departments"/"Select Role"/... inside an otherwise
/// Arabic dialog (same for the "Preview N Matches" button). Labels, hints and
/// the button now come from `S`, so they follow the app locale; the file-format
/// and language options carry a stable code as their VALUE and a localized
/// string as their LABEL, so a locale switch never invalidates a selection.
/// Counts render in the reader's numerals via `LocalizedDigits`, matching the
/// tab and filter badges.

part of '../pages/custom_csv_table_page.dart';

class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  // ── Selections ────────────────────────────────────────────────────────────
  String? _department;
  String? _role;
  String? _title;
  String? _workLocation;
  String? _supervisor;
  String? _gender;
  String? _country;
  String? _fileFormat;
  String? _language;

  bool _showPreview = false;
  String _searchQuery = '';

  // ── Static option codes ───────────────────────────────────────────────────
  // Stable, locale-independent values. The user-facing label is resolved at
  // build time from `S`, so switching the app language relabels the options
  // without orphaning the current selection.
  static const List<String> _fileFormatCodes = ['csv', 'xlsx', 'pdf'];
  static const List<String> _languageCodes   = ['en', 'ar', 'both'];

  String _fileFormatLabel(BuildContext context, String code) {
    switch (code) {
      case 'csv':
        return S.of(context).formatCsv;
      case 'xlsx':
        return S.of(context).formatExcel;
      default:
        return S.of(context).formatPdf;
    }
  }

  String _languageLabel(BuildContext context, String code) {
    switch (code) {
      case 'en':
        return S.of(context).english;
      case 'ar':
        return S.of(context).arabic;
      default:
        return S.of(context).bothLanguages;
    }
  }

  /// A count rendered in the reader's numerals — see `_localizedCount` in
  /// csv_table_builders1.dart, which does the same for the tab badges.
  String _localizedCount(BuildContext context, int value) =>
      LocalizedDigits.apply(
        value.toString(),
        Localizations.localeOf(context).languageCode,
      );

  // ── Controller & real data ────────────────────────────────────────────────
  late final ActiveDirectoryController _ctrl;

  /// Extract unique sorted non-empty values from a column index.
  List<String> _extractColumn(int columnIndex) {
    if (columnIndex < 0) return [];
    return _ctrl.usersData
        .map((row) => row.length > columnIndex
        ? (row[columnIndex]?.toString().trim() ?? '')
        : '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // Dropdown option lists built lazily from real data
  late final List<String> _departments;
  late final List<String> _roles;
  late final List<String> _titles;
  late final List<String> _workLocations;
  late final List<String> _supervisors;
  late final List<String> _genders;
  late final List<String> _countries;

  @override
  void initState() {
    super.initState();
    _ctrl = AppControllers.activeDirectory;

    // Build dropdown options once from real usersData
    _departments   = _extractColumn(_ColumnIndex.department);
    _roles         = _extractColumn(_ColumnIndex.role);
    _titles        = _extractColumn(_ColumnIndex.title);
    _workLocations = _extractColumn(_ColumnIndex.workLocation);
    _supervisors   = _extractColumn(_ColumnIndex.supervisor);
    _genders       = _extractColumn(_ColumnIndex.gender);
    _countries     = _extractColumn(_ColumnIndex.country);
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  /// Returns rows from usersData that match all active dropdown selections.
  List<List<dynamic>> get _matchingRows {
    return _ctrl.usersData.where((row) {
      bool _match(String? filter, int col) {
        if (filter == null || filter.isEmpty) return true;
        if (row.length <= col) return false;
        return row[col]?.toString().trim().toLowerCase() ==
            filter.trim().toLowerCase();
      }

      if (!_match(_department,   _ColumnIndex.department))   return false;
      if (!_match(_role,         _ColumnIndex.role))         return false;
      if (!_match(_title,        _ColumnIndex.title))        return false;
      if (!_match(_workLocation, _ColumnIndex.workLocation)) return false;
      if (!_match(_supervisor,   _ColumnIndex.supervisor))   return false;
      if (!_match(_gender,       _ColumnIndex.gender))       return false;
      if (!_match(_country,      _ColumnIndex.country))      return false;
      return true;
    }).cast<List<dynamic>>().toList();
  }

  /// [_matchingRows] further filtered by the preview search box.
  List<List<dynamic>> get _previewRows {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _matchingRows;
    return _matchingRows
        .where((row) =>
        row.any((cell) => cell?.toString().toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns a display name for a row: firstName + lastName columns.
  /// Returns a display name for a row: firstName + lastName columns.
  String _rowName(List<dynamic> row) {
    // firstName is at index 1, lastName is at index 3 (from the column comment at top)
    final first = row.length > 1
        ? (row[1]?.toString().trim() ?? '')
        : '';
    final last = row.length > 3
        ? (row[3]?.toString().trim() ?? '')
        : '';
    return '$first $last'.trim();
  }

  String _rowDepartment(List<dynamic> row) =>
      row.length > _ColumnIndex.department
          ? (row[_ColumnIndex.department]?.toString().trim() ?? '')
          : '';

  String _rowTitle(List<dynamic> row) =>
      row.length > _ColumnIndex.title
          ? (row[_ColumnIndex.title]?.toString().trim() ?? '')
          : '';

  void _clearFilter() {
    setState(() {
      _department   = null;
      _role         = null;
      _title        = null;
      _workLocation = null;
      _supervisor   = null;
      _gender       = null;
      _country      = null;
      _fileFormat   = null;
      _language     = null;
      _showPreview  = false;
      _searchQuery  = '';
    });
  }

  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 0.08.w : 0.04.w,
        vertical: 0.04.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFilterPanel()),
            if (_showPreview) ...[
              VerticalDivider(width: 1, color: AppColors.border),
              Expanded(child: _buildPreviewPanel()),
            ],
          ],
        ),
      ),
    );
  }

  // ── Filter panel ──────────────────────────────────────────────────────────

  Widget _buildFilterPanel() {
    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Row(
              children: [
                Text(
                  S.of(context).exportDetails,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize018.w,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                // Live match count badge
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_localizedCount(context, _matchingRows.length)} '
                        '${S.of(context).matches}',
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize012.w,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _isDesktop
                  ? _buildDesktopDropdownGrid()
                  : _buildMobileDropdownList(),
            ),
          ),
          _buildFilterActions(),
        ],
      ),
    );
  }

  Widget _buildDesktopDropdownGrid() {
    final items = _dropdownItems();
    final rows  = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left  = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              SizedBox(width: 14.w),
              Expanded(child: right ?? const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _buildMobileDropdownList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _dropdownItems()
          .map((item) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: item,
      ))
          .toList(),
    );
  }

  List<Widget> _dropdownItems() {
    final s = S.of(context);

    // The first seven lists come straight out of the uploaded CSV, so their
    // OPTIONS are data and stay verbatim; only the label and the hint are
    // translated.
    return [
      _labeledDropdown(
        label: s.department,
        hint: s.selectDepartments,
        options: _optionsOf(_departments),
        value: _department,
        onChanged: (v) => setState(() { _department = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        label: s.role,
        hint: s.selectRole,
        options: _optionsOf(_roles),
        value: _role,
        onChanged: (v) => setState(() { _role = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        label: s.title,
        hint: s.selectTitle,
        options: _optionsOf(_titles),
        value: _title,
        onChanged: (v) => setState(() { _title = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        label: s.workLocation,
        hint: s.selectWorkLocation,
        options: _optionsOf(_workLocations),
        value: _workLocation,
        onChanged: (v) => setState(() { _workLocation = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        label: s.supervisor,
        hint: s.selectSupervisor,
        options: _optionsOf(_supervisors),
        value: _supervisor,
        onChanged: (v) => setState(() { _supervisor = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        label: s.gender,
        hint: s.selectGender,
        options: _optionsOf(_genders),
        value: _gender,
        onChanged: (v) => setState(() { _gender = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        label: s.country,
        hint: s.selectCountry,
        options: _optionsOf(_countries),
        value: _country,
        onChanged: (v) => setState(() { _country = v; _showPreview = false; }),
      ),
      // These two are app-defined choices, so their options are translated too.
      _labeledDropdown(
        label: s.fileFormat,
        hint: s.selectFileFormat,
        options: [
          for (final code in _fileFormatCodes)
            DropdownItem(value: code, label: _fileFormatLabel(context, code)),
        ],
        value: _fileFormat,
        onChanged: (v) => setState(() => _fileFormat = v),
      ),
      _labeledDropdown(
        label: s.language,
        hint: s.selectLanguage,
        options: [
          for (final code in _languageCodes)
            DropdownItem(value: code, label: _languageLabel(context, code)),
        ],
        value: _language,
        onChanged: (v) => setState(() => _language = v),
      ),
    ];
  }

  /// CSV-derived values used as both the stored value and the visible label.
  List<DropdownItem<String>> _optionsOf(List<String> values) =>
      [for (final value in values) DropdownItem(value: value, label: value)];

  Widget _labeledDropdown({
    required String label,
    required String hint,
    required List<DropdownItem<String>> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomDropdown<String>(
      label: label.isEmpty ? null : label,
      hint: hint,
      items: options,
      value: value,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(4.r),
      fillColor: AppColors.field,
    );
  }

  Widget _buildFilterActions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _clearFilter,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 42.h,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    S.of(context).clearFilter,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize013.w,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: InkWell(
              onTap: _matchingRows.isEmpty
                  ? null
                  : () => setState(() => _showPreview = true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 42.h,
                decoration: BoxDecoration(
                  color: _matchingRows.isEmpty
                      ? AppColors.greyDark
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    S.of(context).previewMatches(
                      _localizedCount(context, _matchingRows.length),
                    ),
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize013.w,
                      fontWeight: FontWeight.w600,
                      color: _matchingRows.isEmpty ? AppColors.white : AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
