/// Module: time_tracker / tt5_locations / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: location_details_page.dart
/// Purpose: Declares `LocationDetailsPage` — "Tracking Time › {Location}":
///          the location's values (read-only), Edit · Delete · Active /
///          Inactive, and the Assigned Employees list.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:39620` / `661:39927`. Gates: Edit `Edit_Location`, Delete
/// `Delete_Location` (soft), the status switch `Change_Location_Status`.
/// Dialogs: `661:95093` "Deleting Location" → "Location Deleted" (owner
/// fix of the Figma "Deleting Request Type" title), "Changing Status" (house
/// pattern, like Request Types `661:44439`). Live from `LocationsCubit`;
/// names of the assigned employees from `EmployeesCubit`. A deleted
/// location closes the page.
/// Updated: 9/10/2026 - phase 5: an assigned employee's card opens their
/// dashboard (`661:96459`) for HR dashboard holders in scope, and carries
/// "Message" (Figma `661:39620`).
/// Updated: 9/10/2026 - code review (owner rule): Delete / make Inactive
/// with employees still assigned shows "Location In Use — N employees are
/// assigned to this location. Reassign them first." instead of the confirm.
/// Updated: 9/10/2026 - UI quality pass (owner 13:45 #6–8): Assigned
/// Employees use the Employees-tab card; Delete is red + white; the Active
/// switch moved INTO the Edit form (the header shows the status as text).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/pages/location_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_text.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/pages/employee_dashboard_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_navigation.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_message_button.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationDetailsPage extends StatelessWidget {
  const LocationDetailsPage({super.key, required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (BuildContext context, LocationsState state) {
        final WorkLocation? location = state.byId(locationId);
        if (location == null || location.status == LocationStatus.deleted) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(child: CustomEmptyState()),
          );
        }
        return _Details(location: location, state: state);
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.location, required this.state});

  final WorkLocation location;
  final LocationsState state;

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  Future<void> _afterFlow(BuildContext context) async {
    final LocationsCubit cubit = context.read<LocationsCubit>();
    if (!context.mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  /// Owner rule (9/10/2026): employees still assigned → explain and stop.
  Future<bool> _blockedByEmployees(BuildContext context, LocationsCubit cubit) async {
    final int assigned = cubit.assignedCount(location);
    if (assigned == 0) return false;
    final S s = S.of(context);
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: s.timeTrackerLocationInUseTitle,
      subtitle: s.timeTrackerLocationInUse(LocalizedNumber.of(context, assigned)),
    );
    return true;
  }

  Future<void> _delete(BuildContext context) async {
    final S s = S.of(context);
    final LocationsCubit cubit = context.read<LocationsCubit>();
    final NavigatorState nav = Navigator.of(context);
    if (await _blockedByEmployees(context, cubit) || !context.mounted) return;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerDeletingLocation,
      confirmSubtitle: s.timeTrackerDeleteLocationConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: refreshingCheckIn(context, () => cubit.delete(location)),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerLocationDeletedTitle,
      successSubtitle: s.timeTrackerLocationDeleted,
      onSuccessComplete: () => nav.maybePop(),
    );
    if (context.mounted) await _afterFlow(context);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool hr = state.companyHasHr;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: LocationText.name(context, location),
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SlideInContent(child: _actions(context, s, hr)),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 60),
                child: TtFormCard(child: _values(context)),
              ),
              SizedBox(height: 20.h),
              SlideInContent(
                delay: const Duration(milliseconds: 120),
                child: _AssignedEmployees(emails: state.assignedTo(location.id)),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, S s, bool hr) {
    // UI quality pass (owner 13:45 #7 / #8): status as text only — it is
    // changed inside Edit (`TtStatusSwitch`); Delete red + white.
    return Row(
      children: <Widget>[
        LocationStatusText(status: location.status),
        const Spacer(),
        if (_access.canEditLocation(companyHasHr: hr))
          CustomEditIcon(
            key: const ValueKey<String>('locationEditButton'),
            title: s.edit,
            onTap: () => Navigator.of(context).push<void>(MaterialPageRoute<void>(
              builder: (_) => LocationFormPage(original: location),
            )),
          ),
        if (_access.canDeleteLocation(companyHasHr: hr)) ...<Widget>[
          SizedBox(width: 10.w),
          TtDeleteButton(
            key: const ValueKey<String>('locationDeleteButton'),
            title: s.delete,
            onTap: () => _delete(context),
          ),
        ],
      ],
    );
  }

  Widget _values(BuildContext context) {
    final List<String> headers = LocationText.headers(context);
    final List<String> cells = LocationText.cells(context, location);
    final List<Widget> items = <Widget>[
      for (int i = 0; i < headers.length - 1; i++) _value(headers[i], cells[i]),
      _value(S.of(context).timeTrackerLateAfter,
          TimeTrackerLateText.of(context, location.lateAfterMinutes)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < items.length; i += 2) ...<Widget>[
          if (i > 0) SizedBox(height: 12.h),
          TtPair(start: items[i], end: i + 1 < items.length ? items[i + 1] : null),
        ],
      ],
    );
  }

  Widget _value(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
          SizedBox(height: 4.h),
          Text(value, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        ],
      );
}

/// "Late After" value: "10 Mins" or "-".
class TimeTrackerLateText {
  const TimeTrackerLateText._();

  static String of(BuildContext context, int minutes) =>
      minutes <= 0 ? '-' : S.of(context).timeTrackerMinsValue(LocalizedNumber.of(context, minutes));
}

/// "Assigned Employees": one card per employee at the location.
class _AssignedEmployees extends StatelessWidget {
  const _AssignedEmployees({required this.emails});

  final List<String> emails;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (BuildContext context, EmployeesState state) {
        final List<TimeTrackerEmployee> people = <TimeTrackerEmployee>[
          for (final String e in emails)
            state.employeeByEmail(e) ?? TimeTrackerEmployee(email: e),
        ];
        // Phase 5 (9/10/2026, Figma `661:39620` / `661:96459`): an HR
        // dashboard holder opens the employee's dashboard by tapping the
        // card; "Message" opens the chat (not on one's own card).
        final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(S.of(context).timeTrackerAssignedEmployees,
                style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
            SizedBox(height: 10.h),
            if (people.isEmpty)
              const CustomEmptyState()
            else
              EmployeeCardGrid(
                children: <Widget>[
                  // UI quality pass (owner 13:45 #6): the SAME card as the
                  // Employees tab, with "Message" as its one action.
                  for (final TimeTrackerEmployee p in people)
                    EmployeeCard(
                      key: ValueKey<String>('assignedEmployee_${p.email}'),
                      employee: p,
                      assignment: state.assignmentOf(p.email),
                      rules: state.effectiveRulesOf(p.email),
                      onTap: EmployeeDashboardPage.mayOpen(access, p)
                          ? () => HrDashboardNavigation.openEmployee(context, p)
                          : null,
                      action: p.email.trim().toLowerCase() == access.currentUserEmail
                          ? null
                          : EmployeeCardAction(
                              key: ValueKey<String>('assignedEmployeeMessage_${p.email}'),
                              title: S.of(context).message,
                              icon: TtAssets.message,
                              onTap: () => openTimeTrackerChat(context, p.email),
                            ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
