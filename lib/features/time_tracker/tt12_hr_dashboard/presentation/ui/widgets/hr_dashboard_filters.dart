/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_filters.dart
/// Purpose: Declares `HrDashboardFilterBar` — the HR view's filters:
///          Employee (picker) · Department · Location · Time, and the
///          icon-only Export.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Figma `661:42563`: iPad — Employee (150×36 white, yellow once employees
/// are picked) at the start; Department 150 · Location 150 · Time 100 at
/// the end. iPhone `661:47746` — two rows: Employee + Department, Location
/// + Time. Gates (FINAL SPEC §1): Employee only with
/// `HR_Dashboard_Filter_By_Employee`, Department only with
/// `HR_Dashboard_All_Departments` (without it the data is the viewer's own
/// department). Export (yellow, `TtExportButton`) sits at the end of the
/// row — the CSV of what the view shows. Dropdowns are the core
/// `CustomDropdown` (placeholder until something is chosen; "All" clears);
/// Time reuses the personal dashboard's `DashboardRangeDropdown` (Day /
/// Week / Month / Year / Custom). LOW haptics on filters.
/// Updated: 9/10/2026 - owner review: toolbar dropdowns take the toolbar's
/// one height + corner radius (`TtToolbar` — same as Search / Export / Import).
/// Updated: 9/10/2026 - UI quality pass (owner 13:45 #4, 14:17 #4): the
/// Employee button takes the same height / radius as the dropdowns (it was
/// 36 raw); one equal gap between EVERY control and the row is shared
/// evenly (Employee and Department used to touch on the 11" iPad).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_export.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_employee_picker.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/ui/widgets/dashboard_range_menu.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HrDashboardFilterBar extends StatelessWidget {
  const HrDashboardFilterBar({super.key, required this.state});

  final HrDashboardState state;

  Future<void> _pickEmployees(BuildContext context) async {
    final HrDashboardCubit cubit = context.read<HrDashboardCubit>();
    final List<TimeTrackerEmployee> people = state.permitted;
    final Set<String> deps = <String>{for (final TimeTrackerEmployee e in people) e.departmentId};
    await CustomDialogManager.showContent<void>(
      context: context,
      width: 615,
      child: HrEmployeePicker(
        people: people,
        departments: <String, String>{
          for (final MapEntry<String, String> d in state.departments.entries)
            if (deps.contains(d.key)) d.key: d.value,
        },
        showDepartmentFilter: state.allDepartments,
        selected: state.filters.employeeEmails,
        onChanged: cubit.setEmployees,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final HrDashboardCubit cubit = context.read<HrDashboardCubit>();
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final Widget? employee = state.canFilterByEmployee
        ? _EmployeeButton(
            active: state.filters.employeeEmails.isNotEmpty,
            onTap: () => _pickEmployees(context),
          )
        : null;
    final Widget? department = state.allDepartments
        ? _FilterDropdown(
            key: const ValueKey<String>('hrDepartmentFilter'),
            hint: s.timeTrackerDepartment,
            value: state.filters.departmentId,
            items: <String, String>{...state.departments},
            onChanged: cubit.setDepartment,
          )
        : null;
    final Widget location = _FilterDropdown(
      key: const ValueKey<String>('hrLocationFilter'),
      hint: s.timeTrackerLocation,
      value: state.filters.locationId,
      items: <String, String>{
        for (final WorkLocation l in state.locations) l.id: l.name(isArabic: ar),
      },
      onChanged: cubit.setLocation,
    );
    final Widget time = DashboardRangeDropdown(
      key: const ValueKey<String>('hrRangeMenu'),
      range: state.range,
      width: double.infinity,
      customSpan: () => cubit.state.customSpan,
      onRange: cubit.selectRange,
      onCustom: (DateSpan span) => cubit.applyCustom(span.first, span.last),
    );
    final Widget export = TtExportButton(
      key: const ValueKey<String>('hrExportButton'),
      onTap: () => exportHrDashboard(context, cubit.state),
    );
    // UI quality pass (9/10/2026, owner 13:45 #4 / 14:17 #4): every control
    // the same height (`ButtonSizing.height`) and radius, ONE gap between
    // each of them, the row shared evenly — nothing ever touches.
    final double gap = context.isPhone ? 10.w : 15.w;
    Widget row(List<Widget> controls, {Widget? trailing}) => Row(
          children: <Widget>[
            for (int i = 0; i < controls.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: gap),
              Expanded(child: controls[i]),
            ],
            if (trailing != null) ...<Widget>[SizedBox(width: gap), trailing],
          ],
        );
    final List<Widget> people = <Widget>[if (employee != null) employee, if (department != null) department];
    if (context.isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: <Widget>[
          if (people.isNotEmpty) row(people),
          row(<Widget>[location, time], trailing: export),
        ],
      );
    }
    return row(<Widget>[...people, location, time], trailing: export);
  }
}

/// "Employee" — white, yellow once employees are picked (Figma `661:43225`).
class _EmployeeButton extends StatelessWidget {
  const _EmployeeButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey<String>('hrEmployeeButton'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        onTap();
      },
      // 9/10/2026 (UI pass): the toolbar's one height + radius (was 36 raw).
      child: Container(
        height: ButtonSizing.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.card,
          borderRadius: TtToolbar.radius,
        ),
        child: Text(
          S.of(context).employee,
          style: StyleText.fontSize12Weight400.copyWith(color: active ? AppColors.textButton : AppColors.text),
        ),
      ),
    );
  }
}

/// A white filter dropdown: placeholder [hint] until chosen, "All" clears.
class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;

  /// '' = nothing chosen.
  final String value;

  /// Id → name.
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      hint: hint,
      height: TtToolbar.height,
      borderRadius: TtToolbar.radius,
      fillColor: AppColors.card,
      itemStyle: StyleText.fontSize12Weight400,
      value: value.isEmpty || !items.containsKey(value) ? null : value,
      items: <DropdownItem<String>>[
        DropdownItem<String>(value: '', label: S.of(context).timeTrackerAll),
        for (final MapEntry<String, String> e in items.entries) DropdownItem<String>(value: e.key, label: e.value),
      ],
      onChanged: (String v) {
        HapticController.low();
        onChanged(v);
      },
    );
  }
}
