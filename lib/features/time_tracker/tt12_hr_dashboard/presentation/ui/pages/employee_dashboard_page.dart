/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: employee_dashboard_page.dart
/// Purpose: Declares `EmployeeDashboardPage` — "Tracking Time › {Employee}":
///          one employee's dashboard as HR sees it (profile card + Message,
///          Time range, Overall, Requests donut, Late History).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Figma `661:96459` (opened from a location's Assigned Employees; range
/// menu `661:94973` + calendar `661:94982`). The body is the SAME personal
/// dashboard (`PersonalDashboardTab`) over its own `PersonalDashboardCubit`
/// started for that employee (`init(employeeEmail:)`), so both always count
/// alike. Only for HR dashboard holders whose scope covers the employee's
/// department (`HR_Dashboard` + All Departments or the same department);
/// anyone else sees the no-access message. "Message" opens the chat (not
/// shown on one's own dashboard). Pushed inside the module's nested
/// Navigator; page padding 15 (core `SideFrameMasterServices`).
/// Updated: 9/10/2026 - UI quality pass (owner 14:17 #3 / #5): the header
/// is `HrEmployeeHeaderCard` (proper case, Message top-right, values in full).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_employee_header_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_message_button.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/ui/widgets/personal_dashboard_tab.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeeDashboardPage extends StatelessWidget {
  const EmployeeDashboardPage({super.key, required this.employee, this.cubit});

  final TimeTrackerEmployee employee;

  /// An already started cubit (tests); null = a new one for [employee].
  final PersonalDashboardCubit? cubit;

  /// Function Name: [mayOpen]
  ///
  /// Purpose: Whether the signed-in user may see [employee]'s dashboard.
  ///
  /// Return type: [bool]
  static bool mayOpen(TimeTrackerAccess access, TimeTrackerEmployee employee) =>
      access.canViewHrDashboard && access.hrDashboardCovers(employee.departmentId);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final String name = employee.name(isArabic: ar);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: name,
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: !mayOpen(access, employee)
            ? Center(
                key: const ValueKey<String>('employeeDashboardNoAccess'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const CustomEmptyState(),
                    SizedBox(height: 12.h),
                    Text(s.timeTrackerNoPermission,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              )
            : _provide(
                child: SideFrameScrollableBody(
                  child: Column(
                    key: ValueKey<String>('employeeDashboard_${employee.email}'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // UI quality pass (owner 14:17 #3 / #5): the shared
                      // header card — proper-case name / title / department,
                      // Message top-right, every value in full.
                      SlideInContent(
                        child: HrEmployeeHeaderCard(
                          employee: employee,
                          onMessage: employee.email.trim().toLowerCase() == access.currentUserEmail
                              ? null
                              : () => openTimeTrackerChat(context, employee.email),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      const PersonalDashboardTab(key: ValueKey<String>('employeeDashboardBody')),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _provide({required Widget child}) {
    final PersonalDashboardCubit? given = cubit;
    if (given != null) return BlocProvider<PersonalDashboardCubit>.value(value: given, child: child);
    return BlocProvider<PersonalDashboardCubit>(
      // 9/10/2026 (code review): the id finds an HR shift (schedule).
      create: (_) => GetIt.instance<PersonalDashboardCubit>()
        ..init(employeeEmail: employee.email, employeeId: employee.employeeId),
      child: child,
    );
  }
}
