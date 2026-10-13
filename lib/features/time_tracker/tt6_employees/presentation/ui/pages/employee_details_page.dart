/// Module: time_tracker / tt6_employees / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_page.dart
/// Purpose: Declares `EmployeeDetailsPage` — "Tracking Time › {Employee}",
///          opened by tapping an employee on the Employees tab: the profile
///          (+ Message), the current assignment (who assigned them and when,
///          work locations, group, rules), the location history (transfers,
///          newest first), break-rule warnings and — for HR dashboard holders
///          — the employee's dashboard.
/// Author: Knowticed Plus team
/// Created at: 13/10/2026 (owner review T8)
///
/// Live from `EmployeesCubit` (above the module Navigator); the history is
/// read once by `EmployeeDetailsCubit`. The dashboard is the SAME personal
/// dashboard as `EmployeeDashboardPage` (its own `PersonalDashboardCubit`);
/// the break warnings are the days of the dashboard's range whose break was
/// longer than the employee's allowed break (or any break where breaks are
/// not allowed).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/location_rules_panel.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/pages/employee_dashboard_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_employee_header_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_message_button.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/ui/widgets/personal_dashboard_tab.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employee_details_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeeDetailsPage extends StatelessWidget {
  const EmployeeDetailsPage({super.key, required this.employeeEmail});

  final String employeeEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeeDetailsCubit>(
      create: (_) =>
          EmployeeDetailsCubit(assignments: GetIt.instance<LocationAssignmentBaseRepository>())..load(employeeEmail),
      child: BlocBuilder<EmployeesCubit, EmployeesState>(
        builder: (BuildContext context, EmployeesState state) {
          final TimeTrackerEmployee? employee = state.employeeByEmail(employeeEmail);
          if (employee == null) {
            return Scaffold(backgroundColor: AppColors.background, body: const Center(child: CustomEmptyState()));
          }
          return _Details(employee: employee, state: state);
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.employee, required this.state});

  final TimeTrackerEmployee employee;
  final EmployeesState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final bool mine = employee.email.trim().toLowerCase() == access.currentUserEmail;
    final bool dashboard = EmployeeDashboardPage.mayOpen(access, employee);
    final Widget body = SideFrameScrollableBody(
      child: Column(
        key: ValueKey<String>('employeeDetails_${employee.email}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SlideInContent(
            child: HrEmployeeHeaderCard(
              employee: employee,
              onMessage: mine ? null : () => openTimeTrackerChat(context, employee.email),
            ),
          ),
          SizedBox(height: 15.h),
          SlideInContent(
            delay: const Duration(milliseconds: 60),
            child: TtPair(
              start: _assignment(context, s, ar),
              end: _history(context, s, ar),
            ),
          ),
          if (dashboard) ...<Widget>[
            SizedBox(height: 15.h),
            SlideInContent(
                delay: const Duration(milliseconds: 120), child: _BreakWarnings(email: employee.email, state: state)),
            SizedBox(height: 15.h),
            Text(s.timeTrackerEmployeeDashboard, style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
            SizedBox(height: 10.h),
            const PersonalDashboardTab(key: ValueKey<String>('employeeDetailsDashboard')),
          ],
          SizedBox(height: 20.h),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: employee.name(isArabic: ar),
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: dashboard
            ? BlocProvider<PersonalDashboardCubit>(
                create: (_) => GetIt.instance<PersonalDashboardCubit>()
                  ..init(employeeEmail: employee.email, employeeId: employee.employeeId),
                child: body,
              )
            : body,
      ),
    );
  }

  String _person(String email, bool ar) {
    if (email.isEmpty) return TimeTrackerFormat.dash;
    return state.employeeByEmail(email)?.name(isArabic: ar) ?? email;
  }

  String _places(List<String> ids, bool ar) {
    final List<String> names = <String>[
      for (final String id in ids.toSet())
        if (state.locationById(id) != null) state.locationById(id)!.name(isArabic: ar),
    ];
    return names.isEmpty ? TimeTrackerFormat.dash : names.join(' · ');
  }

  Widget _assignment(BuildContext context, S s, bool ar) {
    final LocationAssignment? a = state.assignmentOf(employee.email);
    final EffectiveRules? rules = state.effectiveRulesOf(employee.email);
    final List<Widget> rows = a == null || !a.isAssigned
        ? <Widget>[
            Text(s.timeTrackerNotAssignedYet,
                key: const ValueKey<String>('employeeDetailsNotAssigned'),
                style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
          ]
        : <Widget>[
            _info(TtAssets.person, s.timeTrackerAssignedBy,
                _person(a.audit.modifiedBy.isNotEmpty ? a.audit.modifiedBy : a.audit.createdBy, ar),
                key: const ValueKey<String>('employeeDetailsAssignedBy')),
            _info(TtAssets.calendar, s.timeTrackerAssignDateLabel, TimeTrackerFormat.date(context, a.startDate)),
            _info(TtAssets.location, s.timeTrackerWorkLocations,
                _places(<String>[a.locationId, ...?rules?.rules.allowedLocationIds], ar)),
            if (a.groupId.isNotEmpty)
              _info(TtAssets.group, s.timeTrackerGroupNameLabel, state.groupById(a.groupId)?.label(isArabic: ar) ?? ''),
            if (rules != null)
              _info(
                TtAssets.clock,
                s.timeTrackerRulesLabel,
                '${LocationRulesText.rules(context, rules.rules)} · '
                '${rules.isFromLocation ? s.timeTrackerRulesFromLocationTag : s.timeTrackerRangeCustom}',
              ),
          ];
    return _section(s.timeTrackerCurrentAssignment, TtAssets.person, rows);
  }

  Widget _history(BuildContext context, S s, bool ar) {
    return BlocBuilder<EmployeeDetailsCubit, EmployeeDetailsState>(
      builder: (BuildContext context, EmployeeDetailsState h) {
        final List<Widget> rows;
        if (h.status == EmployeeDetailsStatus.loading) {
          rows = <Widget>[const Center(child: CircleProgressMaster())];
        } else if (h.status == EmployeeDetailsStatus.failure) {
          rows = <Widget>[
            Text(s.timeTrackerLoadError, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red)),
          ];
        } else if (h.history.isEmpty) {
          rows = <Widget>[
            Text(s.timeTrackerNoHistory, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
          ];
        } else {
          rows = <Widget>[
            for (int i = 0; i < h.history.length; i++)
              _HistoryStep(
                key: ValueKey<String>('employeeHistory_$i'),
                title: h.history[i].isRemoval
                    ? s.timeTrackerAssignmentRemovedEntry
                    : _places(<String>[h.history[i].locationId, ...h.history[i].extraLocationIds], ar),
                from: h.history[i].isRemoval || h.history[i].startDate == null
                    ? ''
                    : s.timeTrackerHistoryFrom(TimeTrackerFormat.date(context, h.history[i].startDate)),
                by: s.timeTrackerHistoryBy(
                  _person(h.history[i].changedBy, ar),
                  TimeTrackerFormat.date(context, h.history[i].changedAt),
                ),
                current: i == 0,
                last: i == h.history.length - 1,
              ),
          ];
        }
        return _section(s.timeTrackerLocationHistory, TtAssets.location, rows);
      },
    );
  }

  /// A titled card section with an icon.
  static Widget _section(String title, String icon, List<Widget> rows) => TtFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 28.r,
                  height: 28.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: TtIcon(TtGlyph.svg(icon), size: 15.r, color: AppColors.textButton),
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(title, style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text))),
              ],
            ),
            for (final Widget r in rows) ...<Widget>[SizedBox(height: 10.h), r],
          ],
        ),
      );

  /// icon · label / value (the value wraps).
  static Widget _info(String icon, String label, String value, {Key? key}) => Row(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(top: 2.h),
            child: TtIcon(TtGlyph.svg(icon), size: 16.r, color: AppColors.secondaryText),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                SizedBox(height: 2.h),
                Text(value, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
              ],
            ),
          ),
        ],
      );
}

/// One step of the location history: a dot on a line (yellow = current),
/// the locations, "From {date}" and "By {name} on {date}".
class _HistoryStep extends StatelessWidget {
  const _HistoryStep({
    super.key,
    required this.title,
    required this.from,
    required this.by,
    required this.current,
    required this.last,
  });

  final String title;
  final String from;
  final String by;
  final bool current;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 12.r,
                height: 12.r,
                margin: EdgeInsetsDirectional.only(top: 3.h),
                decoration: BoxDecoration(
                  color: current ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: current ? AppColors.primary : AppColors.secondaryText),
                ),
              ),
              if (!last) Expanded(child: Container(width: 1.5, color: AppColors.background)),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: last ? 0 : 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  if (from.isNotEmpty) Text(from, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text)),
                  Text(by, style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The days of the dashboard range whose break went over the employee's
/// allowed break (or any break where breaks are not allowed).
class _BreakWarnings extends StatelessWidget {
  const _BreakWarnings({required this.email, required this.state});

  final String email;
  final EmployeesState state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final EffectiveRules? rules = state.effectiveRulesOf(email);
    return BlocBuilder<PersonalDashboardCubit, PersonalDashboardState>(
      builder: (BuildContext context, PersonalDashboardState d) {
        final List<(AttendanceDay, String)> warnings = <(AttendanceDay, String)>[];
        if (rules != null) {
          final bool allowed = rules.rules.isBreakAllowed;
          final int limit = rules.rules.breakMinutes;
          for (final AttendanceDay day in d.days) {
            if (day.breakMinutes <= 0) continue;
            if (!allowed) {
              warnings.add((day, s.timeTrackerBreakNotAllowedLine(LocalizedNumber.of(context, day.breakMinutes))));
            } else if (limit > 0 && day.breakMinutes > limit) {
              warnings.add((
                day,
                s.timeTrackerBreakWarningLine(
                    LocalizedNumber.of(context, day.breakMinutes), LocalizedNumber.of(context, limit))
              ));
            }
          }
        }
        warnings.sort(((AttendanceDay, String) a, (AttendanceDay, String) b) => b.$1.date.compareTo(a.$1.date));
        return _Details._section(s.timeTrackerBreakWarnings, TtAssets.clock, <Widget>[
          if (warnings.isEmpty)
            Text(s.timeTrackerNoBreakWarnings,
                key: const ValueKey<String>('employeeNoBreakWarnings'),
                style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText))
          else
            for (final (AttendanceDay, String) w in warnings.take(8))
              Row(
                children: <Widget>[
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 8.w),
                  Text(TimeTrackerFormat.date(context, w.$1.date),
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(w.$2, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                  ),
                ],
              ),
        ]);
      },
    );
  }
}
