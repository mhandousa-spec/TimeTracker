/// Module: time_tracker / tt6_employees / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employees_tab.dart
/// Purpose: Declares `EmployeesTab` — the "Employees" tab: Employees |
///          Locations toggle; counters Assigned · Unassigned · Groups;
///          Search · Department · Filter · Export; Assigned cards (Reassign
///          · Remove), Unassigned cards (Assign + multi-select), Groups.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:93542` / `661:93830` / `661:94112` / `661:94406` /
/// `661:94690`. No-HR companies only (decision 14; hidden with HR). Gates:
/// the tab needs `View_Time_Tracker_Employees` or `View_Groups`; the
/// Assigned / Unassigned counters need View Employees, Groups needs View
/// Groups; Department dropdown only with `Employees_All_Departments`
/// (otherwise only the viewer's department is listed); Export
/// `Export_Time_Tracker_Employees`; Assign / Reassign / Remove their own
/// switches. Remove asks first (destructive, shakes once).
/// Updated: 9/10/2026 - UI fix round 1: the Employees | Locations toggle is
/// the module `TtSegmentedToggle` (Figma `661:93542`: card-colour container
/// on the page, 16 Medium); icon-only Filter / Export and the centred
/// search (`time_tracker_controls`).
/// Updated: 9/10/2026 - owner review: toolbar dropdowns take the toolbar's
/// one height + corner radius (`TtToolbar` — same as Search / Export / Import).
/// Updated: 9/10/2026 - UI quality pass (owner 13:45 #5): the redesigned
/// `EmployeeCard` — one primary action, Remove as the red trash icon.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employees_filter_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employees_locations_view.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/grant_access_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/widgets/groups_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeesTab extends StatefulWidget {
  const EmployeesTab({super.key});

  @override
  State<EmployeesTab> createState() => _EmployeesTabState();
}

class _EmployeesTabState extends State<EmployeesTab> {
  final TextEditingController _search = TextEditingController();

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (BuildContext context, EmployeesState state) {
        if (state.isLoading) {
          return Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
            child: const Center(child: CircleProgressMaster()),
          );
        }
        if (state.status == EmployeesLoadStatus.failure) {
          return Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
            child: Text(s.timeTrackerLoadError,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red)),
          );
        }
        final EmployeesCubit cubit = context.read<EmployeesCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_access.canViewEmployees)
              SlideInContent(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TtSegmentedToggle(
                    key: const ValueKey<String>('employeesSubToggle'),
                    tabs: <String>[s.timeTrackerTabEmployees, s.timeTrackerTabLocations],
                    selectedIndex: state.view.index,
                    onChanged: (int i) => cubit.setView(EmployeesSubView.values[i]),
                  ),
                ),
              ),
            SizedBox(height: 15.h),
            if (state.view == EmployeesSubView.locations && _access.canViewEmployees)
              const EmployeesLocationsView()
            else ...<Widget>[
              SlideInContent(delay: const Duration(milliseconds: 60), child: _counters(context, state)),
              SizedBox(height: 15.h),
              if (state.segment == EmployeesSegment.groups)
                const GroupsView()
              else ...<Widget>[
                SlideInContent(delay: const Duration(milliseconds: 120), child: _toolbar(context, state)),
                SizedBox(height: 15.h),
                SlideInContent(delay: const Duration(milliseconds: 180), child: _list(context, state)),
              ],
            ],
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _counters(BuildContext context, EmployeesState state) {
    final S s = S.of(context);
    final EmployeesCubit cubit = context.read<EmployeesCubit>();
    Widget counter(EmployeesSegment seg, int count, String label) {
      final bool on = state.segment == seg;
      return GestureDetector(
        key: ValueKey<String>('employeesCounter_${seg.name}'),
        // 9/10/2026: the gap between the number and the label taps too.
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticController.low();
          cubit.setSegment(seg);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 44.r,
              height: 44.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadiusDirectional.circular(8.r),
              ),
              child: Text(LocalizedNumber.of(context, count),
                  style: StyleText.fontSize18Weight500
                      .copyWith(color: on ? AppColors.textButton : AppColors.secondaryText)),
            ),
            SizedBox(width: 12.w),
            Text(label,
                style: StyleText.fontSize16Weight500
                    .copyWith(color: on ? AppColors.text : AppColors.secondaryText)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 30.w,
      runSpacing: 10.h,
      children: <Widget>[
        if (_access.canViewEmployees) ...<Widget>[
          counter(EmployeesSegment.assigned, state.assignedCount, s.timeTrackerAssigned),
          counter(EmployeesSegment.unassigned, state.unassignedCount, s.timeTrackerUnassigned),
        ],
        if (_access.canViewGroups)
          counter(EmployeesSegment.groups, state.liveGroups.length, s.timeTrackerGroupPermissions),
      ],
    );
  }

  Widget _toolbar(BuildContext context, EmployeesState state) {
    final S s = S.of(context);
    final EmployeesCubit cubit = context.read<EmployeesCubit>();
    final bool phone = context.isPhone;
    final bool assignedTab = state.segment == EmployeesSegment.assigned;
    final Map<String, String> departments = state.departments;
    return Row(
      children: <Widget>[
        TtSearchField(
          controller: _search,
          onChanged: cubit.searchChanged,
        ),
        if (_access.showEmployeesDepartmentFilter) ...<Widget>[
          SizedBox(width: 15.w),
          SizedBox(
            width: phone ? 140.w : 160.w,
            child: CustomDropdown<String>(
              key: const ValueKey<String>('employeesDepartmentFilter'),
              hint: s.timeTrackerDepartment,
              height: TtToolbar.height,
              borderRadius: TtToolbar.radius,
              fillColor: AppColors.card,
              itemStyle: StyleText.fontSize12Weight400,
              // 9/10/2026: nothing chosen shows the Figma placeholder
              // "Department" (was "All"); the "All" entry clears it.
              value: state.departmentId.isEmpty ? null : state.departmentId,
              items: <DropdownItem<String>>[
                DropdownItem<String>(value: '', label: s.timeTrackerAll),
                for (final MapEntry<String, String> d in departments.entries)
                  DropdownItem<String>(value: d.key, label: d.value),
              ],
              onChanged: cubit.departmentChanged,
            ),
          ),
        ],
        if (assignedTab) ...<Widget>[
          SizedBox(width: 15.w),
          TtFilterButton(
            key: const ValueKey<String>('employeesFilterButton'),
            active: state.locationFilter.isNotEmpty,
            onTap: () async {
              final String? picked = await CustomDialogManager.showContent<String>(
                context: context,
                width: 420,
                child: EmployeesFilterDialog(initial: state.locationFilter, locations: state.locations),
              );
              if (picked != null) cubit.applyLocationFilter(picked);
            },
          ),
        ],
        if (_access.canExportEmployees) ...<Widget>[
          SizedBox(width: 15.w),
          TtExportButton(
            key: const ValueKey<String>('employeesExportButton'),
            onTap: () => _export(context, state),
          ),
        ],
        if (!assignedTab &&
            state.selected.isNotEmpty &&
            _access.canAssignEmployee(companyHasHr: state.companyHasHr)) ...<Widget>[
          SizedBox(width: 15.w),
          TtToolbarButton(
            key: const ValueKey<String>('employeesAssignSelected'),
            title: s.timeTrackerAssignCount(LocalizedNumber.of(context, state.selected.length)),
            icon: TtAssets.add,
            onTap: () => showGrantAccessFlow(context, <TimeTrackerEmployee>[
              for (final EmployeeAssignmentRow r in state.unassigned)
                if (state.selected.contains(r.employee.email)) r.employee,
            ]),
          ),
        ],
      ],
    );
  }

  Future<void> _export(BuildContext context, EmployeesState state) async {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<EmployeeAssignmentRow> rows = <EmployeeAssignmentRow>[...state.assigned, ...state.unassigned];
    if (rows.isEmpty) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: s.export,
        subtitle: s.timeTrackerExportEmpty,
      );
      return;
    }
    await exportTimeTrackerCsv(
      context: context,
      defaultFileName: s.timeTrackerEmployeesExportName,
      header: <String>[
        s.timeTrackerEmployeeName, s.timeTrackerEmail, s.timeTrackerDepartment, s.timeTrackerTitleLabel,
        s.timeTrackerLocation, s.timeTrackerStartDate, s.timeTrackerGroupPermissions,
      ],
      rows: <List<String>>[
        for (final EmployeeAssignmentRow r in rows)
          <String>[
            r.employee.name(isArabic: ar),
            r.employee.email,
            r.employee.department(isArabic: ar),
            r.employee.jobTitle(isArabic: ar),
            r.isAssigned ? (state.locationById(r.locationId)?.name(isArabic: ar) ?? '') : s.timeTrackerUnassigned,
            r.isAssigned ? TimeTrackerFormat.date(context, r.assignment?.startDate) : TimeTrackerFormat.dash,
            state.groupById(r.assignment?.groupId ?? '')?.label(isArabic: ar) ?? '',
          ],
      ],
    );
  }

  Future<void> _remove(BuildContext context, TimeTrackerEmployee e) async {
    final S s = S.of(context);
    final EmployeesCubit cubit = context.read<EmployeesCubit>();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerRemovingAssignment,
      confirmSubtitle: s.timeTrackerRemoveAssignmentConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: refreshingCheckIn(context, () => cubit.removeAssignment(e.email)),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerAssignmentRemovedTitle,
      successSubtitle: s.timeTrackerAssignmentRemoved,
    );
    if (!context.mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  Widget _list(BuildContext context, EmployeesState state) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final EmployeesCubit cubit = context.read<EmployeesCubit>();
    final bool hr = state.companyHasHr;
    final bool assignedTab = state.segment == EmployeesSegment.assigned;
    final List<EmployeeAssignmentRow> rows = assignedTab ? state.assigned : state.unassigned;
    if (rows.isEmpty) return const CustomEmptyState();
    final bool canAssign = _access.canAssignEmployee(companyHasHr: hr);
    return AnimatedSizeWrap(
      child: EmployeeCardGrid(
        children: <Widget>[
          for (final EmployeeAssignmentRow r in rows)
            EmployeeCard(
              key: ValueKey<String>('employeeCard_${r.employee.email}'),
              employee: r.employee,
              assignment: r.assignment,
              locationName: assignedTab ? (state.locationById(r.locationId)?.name(isArabic: ar) ?? '') : '',
              rules: assignedTab ? state.effectiveRulesOf(r.employee.email) : null,
              selected: !assignedTab && canAssign ? state.selected.contains(r.employee.email) : null,
              onSelect: () => cubit.toggleSelected(r.employee.email),
              // UI quality pass (owner 13:45 #5): ONE action area —
              // Reassign / Assign is the primary (bottom end); Remove is the
              // small red trash at the top end, away from it.
              removeKey: ValueKey<String>('employeeRemove_${r.employee.email}'),
              onRemove: assignedTab && _access.canRemoveEmployeeAssignment(companyHasHr: hr)
                  ? () => _remove(context, r.employee)
                  : null,
              action: assignedTab
                  ? (_access.canReassignEmployeeLocation(companyHasHr: hr)
                      ? EmployeeCardAction(
                          key: ValueKey<String>('employeeReassign_${r.employee.email}'),
                          title: s.timeTrackerReassign,
                          onTap: () => showGrantAccessFlow(context, <TimeTrackerEmployee>[r.employee]),
                        )
                      : null)
                  : (canAssign
                      ? EmployeeCardAction(
                          key: ValueKey<String>('employeeAssign_${r.employee.email}'),
                          title: s.timeTrackerAssign,
                          onTap: () => showGrantAccessFlow(context, <TimeTrackerEmployee>[r.employee]),
                        )
                      : null),
            ),
        ],
      ),
    );
  }
}
