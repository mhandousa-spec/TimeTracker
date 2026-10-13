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
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
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
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_filter_frame.dart';
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
      // 13/10/2026 (owner): wider, so names and job titles stay on one line.
      width: TtDialogWidth.wide,
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
            selectedCount: state.filters.employeeEmails.length,
            onTap: () => _pickEmployees(context),
            // 13/10/2026 (owner): one tap back to every employee.
            onClear: () => cubit.setEmployees(const <String>{}),
          )
        : null;
    final Widget? department = state.allDepartments
        ? TtToolbarMultiFilter(
            key: const ValueKey<String>('hrDepartmentFilter'),
            hint: s.timeTrackerDepartment,
            values: state.filters.departmentIds,
            items: <String, String>{...state.departments},
            onChanged: cubit.setDepartments,
          )
        : null;
    final Widget location = TtToolbarMultiFilter(
      key: const ValueKey<String>('hrLocationFilter'),
      hint: s.timeTrackerLocation,
      values: state.filters.locationIds,
      items: <String, String>{
        for (final WorkLocation l in state.locations) l.id: l.name(isArabic: ar),
      },
      onChanged: cubit.setLocations,
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
    // 13/10/2026 (owner): Department and Location get more room (their
    // picks stay readable); Employee and the period need less.
    Widget row(List<(Widget, int)> controls, {Widget? trailing}) => Row(
          children: <Widget>[
            for (int i = 0; i < controls.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: gap),
              Expanded(flex: controls[i].$2, child: controls[i].$1),
            ],
            if (trailing != null) ...<Widget>[SizedBox(width: gap), trailing],
          ],
        );
    final List<(Widget, int)> people = <(Widget, int)>[
      if (employee != null) (employee, 2),
      if (department != null) (department, 3),
    ];
    if (context.isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: <Widget>[
          if (people.isNotEmpty) row(people),
          row(<(Widget, int)>[(location, 3), (time, 2)], trailing: export),
        ],
      );
    }
    return row(<(Widget, int)>[...people, (location, 3), (time, 2)], trailing: export);
  }
}

/// "Employee" — opens the employee picker.
///
/// Updated: 12/10/2026 - owner review N1 / R6: it IS the core dropdown
/// trigger (same fill, height, radius, text and chevron as Department /
/// Location / Time) instead of a yellow-when-active box; a selection shows
/// as "Employee (3)". The dropdown itself never opens — the tap goes to the
/// picker.
/// 13/10/2026 (owner): "Employee" is a BUTTON, not a dropdown — the text
/// centred, no arrow; it opens the Employees popup. With employees picked
/// it turns yellow ("Employee (2)"). Toolbar height + radius; LOW haptic,
/// shrinks on press.
class _EmployeeButton extends StatelessWidget {
  const _EmployeeButton({required this.selectedCount, required this.onTap, required this.onClear});

  final int selectedCount;
  final VoidCallback onTap;

  /// The small × (only when employees are picked): back to everyone.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final String title = S.of(context).employee;
    final bool picked = selectedCount > 0;
    return ShrinkOnTap(
      child: GestureDetector(
        key: const ValueKey<String>('hrEmployeeButton'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticController.low();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Same scaled height as the dropdowns and Export (`ButtonSizing`).
          height: ButtonSizing.height,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: picked ? AppColors.primary : AppColors.card,
            borderRadius: TtToolbar.radius,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // 13/10/2026 (owner): no count — yellow says "employees are
              // picked"; unpicked = the other filters' placeholder grey.
              Text(
                title,
                textAlign: TextAlign.center,
                style: picked
                    ? StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton)
                    : StyleText.fontSize12Weight400.copyWith(color: kDropdownHintColor),
              ),
              if (picked)
                PositionedDirectional(
                  end: 0,
                  child: GestureDetector(
                    key: const ValueKey<String>('hrEmployeeClear'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticController.low();
                      onClear();
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.all(4.r),
                      child: Icon(Icons.close_rounded, size: 16.r, color: AppColors.textButton),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
