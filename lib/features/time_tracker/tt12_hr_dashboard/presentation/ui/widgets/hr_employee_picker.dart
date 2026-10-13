/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_employee_picker.dart
/// Purpose: Declares `HrEmployeePicker` — the HR view's "Employees" popup:
///          Search + Department on ONE compact row, then the employees as
///          cards with a tick box; several can be picked.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Figma `661:93462` (615 wide, same popup as the Approvals picker) and the
/// HR dashboard states `661:42895` (one employee picked) / `661:43247`
/// (four picked — so the HR picker is multi-select). Owner rule (9/10):
/// no "All Employees" row — picking nobody = every employee. Each tap
/// applies at once ([onChanged]); the popup has no Apply button in Figma,
/// closing it keeps the choice. The Department dropdown only with
/// `HR_Dashboard_All_Departments` (without it every listed employee is the
/// viewer's department anyway). Scales in; cards fire a LOW haptic.
/// Updated: 9/10/2026 - owner review: toolbar dropdowns take the toolbar's
/// one height + corner radius (`TtToolbar` — same as Search / Export / Import).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/19-Custom_Employee_Card.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HrEmployeePicker extends StatefulWidget {
  const HrEmployeePicker({
    super.key,
    required this.people,
    required this.departments,
    required this.showDepartmentFilter,
    required this.selected,
    required this.onChanged,
  });

  final List<TimeTrackerEmployee> people;

  /// Department id → name.
  final Map<String, String> departments;
  final bool showDepartmentFilter;

  /// Lower-cased e-mails picked so far.
  final Set<String> selected;

  /// Called with the new choice after every tap.
  final ValueChanged<Set<String>> onChanged;

  @override
  State<HrEmployeePicker> createState() => _HrEmployeePickerState();
}

class _HrEmployeePickerState extends State<HrEmployeePicker> {
  final TextEditingController _search = TextEditingController();
  String? _department;
  late Set<String> _picked;

  @override
  void initState() {
    super.initState();
    _picked = <String>{...widget.selected};
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<TimeTrackerEmployee> _rows(bool ar) {
    final String q = _search.text.trim().toLowerCase();
    return <TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in widget.people)
        if ((q.isEmpty || e.searchText.contains(q)) && (_department == null || e.departmentId == _department)) e,
    ]..sort((TimeTrackerEmployee a, TimeTrackerEmployee b) =>
        a.name(isArabic: ar).toLowerCase().compareTo(b.name(isArabic: ar).toLowerCase()));
  }

  void _toggle(String email) {
    HapticController.low();
    final String key = email.trim().toLowerCase();
    setState(() => _picked.contains(key) ? _picked.remove(key) : _picked.add(key));
    widget.onChanged(Set<String>.unmodifiable(_picked));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final bool phone = context.isPhone;
    final List<TimeTrackerEmployee> rows = _rows(ar);
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtDialogHeader(title: s.timeTrackerTabEmployees, icon: AppAssets.group),
          SizedBox(height: 15.h),
          Row(
            children: <Widget>[
              TtSearchField(
                controller: _search,
                fillColor: AppColors.background,
                onChanged: (_) => setState(() {}),
              ),
              if (widget.showDepartmentFilter) ...<Widget>[
                SizedBox(width: 15.w),
                SizedBox(width: phone ? 140.w : 155.w, child: _departmentFilter(s)),
              ],
            ],
          ),
          SizedBox(height: 15.h),
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 24.h),
              child: Text(s.noEmployeesFound,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
            )
          else
            // 13/10/2026 (owner C1): the core person card; cards hug their
            // content (no fixed cell height) so the avatar's padding is equal
            // on the left, top and bottom.
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 320.h),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final double w = phone ? c.maxWidth : (c.maxWidth - 15.w) / 2;
                  return SingleChildScrollView(
                    key: const ValueKey<String>('hrPickerGrid'),
                    child: Wrap(
                      spacing: 15.w,
                      runSpacing: 15.h,
                      children: <Widget>[for (final TimeTrackerEmployee e in rows) _card(e, ar, w)],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Compact Department filter: placeholder "Department"; "All" clears it.
  Widget _departmentFilter(S s) {
    return CustomDropdown<String>(
      key: const ValueKey<String>('hrPickerDepartment'),
      hint: s.timeTrackerDepartment,
      height: TtToolbar.height,
      borderRadius: TtToolbar.radius,
      fillColor: AppColors.background,
      itemStyle: StyleText.fontSize12Weight400,
      value: _department,
      items: <DropdownItem<String>>[
        DropdownItem<String>(value: '', label: s.timeTrackerAll),
        for (final MapEntry<String, String> d in widget.departments.entries)
          DropdownItem<String>(value: d.key, label: d.value),
      ],
      onChanged: (String v) => setState(() => _department = v.isEmpty ? null : v),
    );
  }

  /// photo · name · department · job title · tick box (core `PersonChipCard`).
  Widget _card(TimeTrackerEmployee e, bool ar, double width) {
    final bool on = _picked.contains(e.email.trim().toLowerCase());
    return KeyedSubtree(
      key: ValueKey<String>('hrPickerRow_${e.email}'),
      child: PersonChipCard(
        width: width,
        name: e.name(isArabic: ar),
        subtitle1: TimeTrackerFormat.orDash(e.department(isArabic: ar)),
        subtitle2: e.jobTitle(isArabic: ar),
        avatar: e.photo.startsWith('http') ? NetworkImage(e.photo) : null,
        avatarRadius: 24,
        backgroundColor: AppColors.background,
        trailing: CustomCheckBox(key: ValueKey<String>('hrPickerTick_${e.email}'), isSelected: on),
        onTap: () => _toggle(e.email),
      ),
    );
  }
}
