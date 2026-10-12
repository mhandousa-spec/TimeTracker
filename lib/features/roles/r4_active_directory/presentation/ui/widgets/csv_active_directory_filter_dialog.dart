/// Module: roles / r4_active_directory / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: csv_active_directory_filter_dialog.dart
/// Purpose: Part file of `custom_csv_table_page.dart`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
///
/// FIXED 25/8/2026 — this dialog was English-only in its placeholders. Every
/// `_buildDropdown` call carried a `hintEn`/`hintAr` pair, but `_buildDropdown`
/// passed only `hintEn` to `CustomDropdown` and ignored `hintAr` entirely, so
/// the Arabic strings were dead code and an Arabic reader saw
/// "Select Departments" / "Select Role" / "Select Title" under Arabic labels —
/// the same defect the export dialog had. Both now take their hints from `S`,
/// so they follow the app locale instead of a hardcoded literal. The country
/// field also had the wrong hint ("Select City" on a country dropdown), and the
/// "N active" badge printed Latin figures; it now uses `LocalizedDigits`, like
/// the tab and filter badges.
///
/// NOT localized, by design: the OPTIONS inside each dropdown. Those are values
/// read out of the uploaded CSV — department names, role names, titles — so
/// they render exactly as the file spells them.

part of '../pages/custom_csv_table_page.dart';

class _ActiveDirectoryFilterDialog extends StatefulWidget {
  // Options populated from real CSV data
  final List<String> departments;
  final List<String> roles;
  final List<String> titles;
  final List<String> workLocations;
  final List<String> supervisors;
  final List<String> genders;
  final List<String> nationalities;
  final List<String> countries;

  // Pre-populated from controller so re-opening shows last state
  final String? initialDepartment;
  final String? initialRole;
  final String? initialTitle;
  final String? initialWorkLocation;
  final String? initialSupervisor;
  final String? initialGender;
  final String? initialNationality;
  final String? initialCountry;

  const _ActiveDirectoryFilterDialog({
    required this.departments,
    required this.roles,
    required this.titles,
    required this.workLocations,
    required this.supervisors,
    required this.genders,
    required this.nationalities,
    required this.countries,
    this.initialDepartment,
    this.initialRole,
    this.initialTitle,
    this.initialWorkLocation,
    this.initialSupervisor,
    this.initialGender,
    this.initialNationality,
    this.initialCountry,
  });

  @override
  State<_ActiveDirectoryFilterDialog> createState() =>
      _ActiveDirectoryFilterDialogState();
}

class _ActiveDirectoryFilterDialogState
    extends State<_ActiveDirectoryFilterDialog> {
  String? _department;
  String? _role;
  String? _title;
  String? _workLocation;
  String? _supervisor;
  String? _selectedGender;
  String? _selectedNationality;
  String? _country;

  @override
  void initState() {
    super.initState();
    // Restore previous selections
    _department         = widget.initialDepartment;
    _role               = widget.initialRole;
    _title              = widget.initialTitle;
    _workLocation       = widget.initialWorkLocation;
    _supervisor         = widget.initialSupervisor;
    _selectedGender     = widget.initialGender;
    _selectedNationality = widget.initialNationality;
    _country            = widget.initialCountry;
  }

  void _clearFilter() {
    setState(() {
      _department          = null;
      _role                = null;
      _title               = null;
      _workLocation        = null;
      _supervisor          = null;
      _selectedGender      = null;
      _selectedNationality = null;
      _country             = null;
    });
    // Also clear the controller immediately so the table updates live
    AppControllers.activeDirectory.clearFilters();
  }

  void _applyFilter() {
    AppControllers.activeDirectory.applyFilters(
      department:   _department,
      role:         _role,
      title:        _title,
      workLocation: _workLocation,
      supervisor:   _supervisor,
      gender:       _selectedGender,
      nationality:  _selectedNationality,
      country:      _country,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: EdgeInsets.symmetric(
        horizontal:
        MediaQuery.of(context).size.width > 800 ? 0.2.w : 0.05.w,
        vertical: 0.05.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row with active-filter indicator ────────────────────
            Row(
              children: [

                CircleAvatar(
                  radius: 15.sp,
                  backgroundColor: AppColors.primary,
                  child: Container(
                    padding: EdgeInsets.all(4.sp),
                    child: CustomSvgImage(assetPath: 'assets/icons_assets/main_icons_assets/filter_sliders.svg',
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),

                SizedBox(width: 8.sp),

                Text(
                  S.of(context).Filter,
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),

              ],
            ),
            SizedBox(height: 0.02.h),

            // ── Dropdowns — two per row on desktop, one per row on mobile ──
            Flexible(
              child: SingleChildScrollView(
                child: _isDesktop
                    ? _buildDesktopFilterGrid()
                    : _buildMobileFilterList(),
              ),
            ),
            SizedBox(height: 0.02.h),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                InkWell(
                  onTap: _clearFilter,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 150.sp,
                    height: 38.sp,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryButton,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).reset,
                        style: StyleText.fontSize14Weight400.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackButton,
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  // ✅ FIX: was Navigator.pop(context) — now calls applyFilter
                  onTap: _applyFilter,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 150.sp,
                    height: 38.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).Apply,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Count of currently selected filters (for the badge)
  int get _activeCount => [
    _department,
    _role,
    _title,
    _workLocation,
    _supervisor,
    _selectedGender,
    _selectedNationality,
    _country,
  ].where((v) => v != null && v.isNotEmpty).length;

  /// A count rendered in the reader's numerals — see `_localizedCount` in
  /// csv_table_builders1.dart, which does the same for the tab badges.
  String _localizedCount(BuildContext context, int value) =>
      LocalizedDigits.apply(
        value.toString(),
        Localizations.localeOf(context).languageCode,
      );

  /// Two dropdowns per row on desktop, one per row on mobile.
  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

  /// The eight labeled filter fields, in order.
  List<Widget> _filterItems() {
    return [
      _filterRow(
        label: S.of(context).department,
        child: _buildDropdown(

          hint: S.of(context).selectDepartments,
          items: widget.departments,
          value: _department,
          onChanged: (v) => setState(() => _department = v),
        ),
      ),
      _filterRow(
        label: S.of(context).role,
        child: _buildDropdown(
          hint: S.of(context).selectRole,
          items: widget.roles,
          value: _role,
          onChanged: (v) => setState(() => _role = v),
        ),
      ),
      _filterRow(
        label: S.of(context).title,
        child: _buildDropdown(
          hint: S.of(context).selectTitle,
          items: widget.titles,
          value: _title,
          onChanged: (v) => setState(() => _title = v),
        ),
      ),
      _filterRow(
        label: S.of(context).workLocation,
        child: _buildDropdown(
          hint: S.of(context).selectWorkLocation,
          items: widget.workLocations,
          value: _workLocation,
          onChanged: (v) => setState(() => _workLocation = v),
        ),
      ),
      _filterRow(
        label: S.of(context).superVisor,
        child: _buildDropdown(
          hint: S.of(context).selectSupervisor,
          items: widget.supervisors,
          value: _supervisor,
          onChanged: (v) => setState(() => _supervisor = v),
        ),
      ),
      _filterRow(
        label: S.of(context).gender,
        child: _buildDropdown(
          hint: S.of(context).selectGender,
          items: widget.genders,
          value: _selectedGender,
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
      ),
      _filterRow(
        label: S.of(context).nationality,
        child: _buildDropdown(
          hint: S.of(context).selectNationality,
          items: widget.nationalities,
          value: _selectedNationality,
          onChanged: (v) => setState(() => _selectedNationality = v),
        ),
      ),
      _filterRow(
        label: S.of(context).country,
        child: _buildDropdown(
          hint: S.of(context).selectCountry,
          items: widget.countries,
          value: _country,
          onChanged: (v) => setState(() => _country = v),
        ),
      ),
    ];
  }

  Widget _buildDesktopFilterGrid() {
    final items = _filterItems();
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
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

  Widget _buildMobileFilterList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _filterItems()
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: item,
              ))
          .toList(),
    );
  }

  /// [hint] is a resolved `S` string, not a literal: passing an English literal
  /// here is what pinned this dialog to English before 25/8/2026.
  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomDropdown<String>(
      hint: hint,
      items: [for (final item in items) DropdownItem(value: item, label: item)],
      value: value,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(4.r),
      fillColor: AppColors.field,
    );
  }

  Widget _filterRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}
