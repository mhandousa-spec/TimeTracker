/// Module: time_tracker / tt6_employees / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employees_locations_view.dart
/// Purpose: Declares `EmployeesLocationsView` — the Employees tab's
///          "Locations" sub-view: one chip per location with its count of
///          assigned employees; the open chip lists those employees with
///          Assign Date and Reassign.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:94690`. Chips share one height, radius 8 (owner rule); the
/// open chip is yellow. Only employees in the viewer's department scope are
/// counted. Reassign needs `Reassign_Employee_Location`.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/grant_access_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeesLocationsView extends StatelessWidget {
  const EmployeesLocationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (BuildContext context, EmployeesState state) {
        final List<WorkLocation> locations = <WorkLocation>[
          for (final WorkLocation l in state.locations)
            if (l.status != LocationStatus.deleted) l,
        ];
        if (locations.isEmpty) return const CustomEmptyState();
        final Map<String, int> counts = EmployeesView.countsByLocation(state.rows);
        final String open = locations.any((WorkLocation l) => l.id == state.chipLocationId)
            ? state.chipLocationId
            : locations.first.id;
        final List<EmployeeAssignmentRow> rows = <EmployeeAssignmentRow>[
          for (final EmployeeAssignmentRow r in state.rows)
            if (r.isAssigned && r.locationId == open) r,
        ];
        final bool canReassign = access.canReassignEmployeeLocation(companyHasHr: state.companyHasHr);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 13/10/2026 (owner T9): the SAME filter control as the row
            // above (core segmented tabs) — "Location (count)"; scrolls
            // sideways when the locations do not fit.
            SlideInContent(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TtSegmentedToggle(
                  key: const ValueKey<String>('employeesLocationTabs'),
                  tabs: <String>[
                    for (final WorkLocation l in locations)
                      '${l.name(isArabic: ar)} (${LocalizedNumber.of(context, counts[l.id] ?? 0)})',
                  ],
                  tabKeys: <Key>[for (final WorkLocation l in locations) ValueKey<String>('locationChip_${l.id}')],
                  compact: context.isPhone,
                  selectedIndex: locations.indexWhere((WorkLocation l) => l.id == open),
                  onChanged: (int i) => context.read<EmployeesCubit>().openChip(locations[i].id),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            if (rows.isEmpty)
              const CustomEmptyState()
            else
              AnimatedSizeWrap(
                child: EmployeeCardGrid(
                  children: <Widget>[
                    for (final EmployeeAssignmentRow r in rows)
                      EmployeeCard(
                        employee: r.employee,
                        assignment: r.assignment,
                        rules: state.effectiveRulesOf(r.employee.email),
                        action: canReassign
                            ? EmployeeCardAction(
                                title: s.timeTrackerReassign,
                                onTap: () => showGrantAccessFlow(context, <TimeTrackerEmployee>[r.employee]),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
