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
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/pages/employee_details_page.dart';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 12/10/2026 (owner T1): ONE segmented filter row — Assigned ·
            // Unassigned · Groups · Locations, each with its count (was a
            // toggle + three counter boxes on two rows).
            SlideInContent(child: _segments(context, state)),
            if (state.view == EmployeesSubView.locations && _access.canViewEmployees)
              const EmployeesLocationsView()
            else ...<Widget>[
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

  /// ADDED 12/10/2026 (owner T1): the one segmented filter (core
  /// `CustomSegmentedTabs` through `TtSegmentedToggle`). Hidden when the
  /// viewer may see only one of the four lists.
  Widget _segments(BuildContext context, EmployeesState state) {
    final S s = S.of(context);
    final EmployeesCubit cubit = context.read<EmployeesCubit>();
    String counted(String label, int n) => '$label (${LocalizedNumber.of(context, n)})';
    final List<(String, String, VoidCallback, bool)> tabs = <(String, String, VoidCallback, bool)>[
      if (_access.canViewEmployees) ...<(String, String, VoidCallback, bool)>[
        (
          'assigned',
          counted(s.timeTrackerAssigned, state.assignedCount),
          () => cubit
            ..setView(EmployeesSubView.employees)
            ..setSegment(EmployeesSegment.assigned),
          state.view == EmployeesSubView.employees && state.segment == EmployeesSegment.assigned,
        ),
        (
          'unassigned',
          counted(s.timeTrackerUnassigned, state.unassignedCount),
          () => cubit
            ..setView(EmployeesSubView.employees)
            ..setSegment(EmployeesSegment.unassigned),
          state.view == EmployeesSubView.employees && state.segment == EmployeesSegment.unassigned,
        ),
      ],
      if (_access.canViewGroups)
        (
          'groups',
          counted(s.timeTrackerGroupPermissions, state.liveGroups.length),
          () => cubit
            ..setView(EmployeesSubView.employees)
            ..setSegment(EmployeesSegment.groups),
          (state.view == EmployeesSubView.employees || !_access.canViewEmployees) &&
              state.segment == EmployeesSegment.groups,
        ),
      if (_access.canViewEmployees)
        (
          'locations',
          s.timeTrackerTabLocations,
          () => cubit.setView(EmployeesSubView.locations),
          state.view == EmployeesSubView.locations,
        ),
    ];
    if (tabs.length < 2) return const SizedBox.shrink();
    final int selected = tabs.indexWhere(((String, String, VoidCallback, bool) t) => t.$4);
    final bool phone = context.isPhone;
    final Widget toggle = TtSegmentedToggle(
      key: const ValueKey<String>('employeesSubToggle'),
      tabs: <String>[for (final (String, String, VoidCallback, bool) t in tabs) t.$2],
      tabKeys: <Key>[
        for (final (String, String, VoidCallback, bool) t in tabs) ValueKey<String>('employeesCounter_${t.$1}'),
      ],
      // Phone: the compact metrics (12 Medium).
      compact: phone,
      selectedIndex: selected < 0 ? 0 : selected,
      onChanged: (int i) => tabs[i].$3(),
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 15.h),
      // Phone: the whole control scales down evenly if it is wider than the
      // screen (Arabic), so every tab keeps the same text size.
      child: phone
          ? FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: toggle)
          : Align(alignment: AlignmentDirectional.centerStart, child: toggle),
    );
  }

  Widget _toolbar(BuildContext context, EmployeesState state) {
    final S s = S.of(context);
    final EmployeesCubit cubit = context.read<EmployeesCubit>();
    final bool assignedTab = state.segment == EmployeesSegment.assigned;
    final Map<String, String> departments = state.departments;
    return Row(
      children: <Widget>[
        TtSearchField(
          controller: _search,
          onChanged: cubit.searchChanged,
        ),
        // 12/10/2026 (owner T2): Department lives INSIDE the filter sheet
        // with Location (Location only for the Assigned list).
        if (assignedTab || _access.showEmployeesDepartmentFilter) ...<Widget>[
          SizedBox(width: 15.w),
          TtFilterButton(
            key: const ValueKey<String>('employeesFilterButton'),
            active: (assignedTab && state.locationFilter.isNotEmpty) || state.departmentId.isNotEmpty,
            onTap: () async {
              final EmployeesFilterResult? picked = await CustomDialogManager.showContent<EmployeesFilterResult>(
                context: context,
                width: TtDialogWidth.standard,
                child: EmployeesFilterDialog(
                  location: state.locationFilter,
                  department: state.departmentId,
                  locations: assignedTab ? state.locations : null,
                  departments: _access.showEmployeesDepartmentFilter ? departments : null,
                ),
              );
              if (picked == null) return;
              if (assignedTab) cubit.applyLocationFilter(picked.location);
              if (_access.showEmployeesDepartmentFilter) cubit.departmentChanged(picked.department);
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

  /// "Main · Extra · Extra" (names; unknown ids skipped).
  String _workLocations(EmployeesState state, EmployeeAssignmentRow r, bool ar) {
    final List<String> ids = <String>[
      r.locationId,
      ...?state.effectiveRulesOf(r.employee.email)?.rules.allowedLocationIds,
    ];
    final List<String> names = <String>[];
    for (final String id in ids.toSet()) {
      final String? name = state.locationById(id)?.name(isArabic: ar);
      if (name != null && name.isNotEmpty) names.add(name);
    }
    return names.join(' · ');
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
              // 12/10/2026 (owner T5): every work location, main first.
              locationName: assignedTab ? _workLocations(state, r, ar) : '',
              locationLabel: s.timeTrackerWorkLocations,
              rules: assignedTab ? state.effectiveRulesOf(r.employee.email) : null,
              selected: !assignedTab && canAssign ? state.selected.contains(r.employee.email) : null,
              onSelect: () => cubit.toggleSelected(r.employee.email),
              // 13/10/2026 (owner T8): tap an employee → Employee Details.
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => EmployeeDetailsPage(employeeEmail: r.employee.email)),
              ),
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
