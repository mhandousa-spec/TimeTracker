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

import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
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
            SlideInContent(
              child: Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: <Widget>[
                  for (final WorkLocation l in locations)
                    _chip(context, l.name(isArabic: ar), counts[l.id] ?? 0, l.id == open, l.id),
                ],
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

  Widget _chip(BuildContext context, String name, int count, bool open, String id) {
    return GestureDetector(
      key: ValueKey<String>('locationChip_$id'),
      onTap: () {
        HapticController.low();
        context.read<EmployeesCubit>().openChip(id);
      },
      child: Container(
        height: 36.h,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: open ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadiusDirectional.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(name,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: open ? AppColors.textButton : AppColors.text)),
            SizedBox(width: 8.w),
            Text(LocalizedNumber.of(context, count),
                style: StyleText.fontSize14Weight500
                    .copyWith(color: open ? AppColors.textButton : AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }
}
