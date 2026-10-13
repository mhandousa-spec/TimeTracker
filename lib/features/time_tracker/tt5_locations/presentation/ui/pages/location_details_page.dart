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

import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/geofence_map_picker.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
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

  /// Redesigned 13/10/2026 (owner S4 / R12): visual, like the Request Type
  /// details — a header card (building tile, both names, status chip), the
  /// map with the geofence circle, then icon sections: Geofencing ·
  /// Address · Work Schedule · Attendance Rules · History, and the
  /// Assigned Employees.
  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool hr = state.companyHasHr;
    final WorkLocation l = location;
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final String other = (ar ? l.nameEn : l.nameAr).trim();
    final bool hasPoint = l.latitude != null && l.longitude != null;
    String onOff(bool v) => v ? s.timeTrackerOn : s.timeTrackerOff;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: LocationText.name(context, l),
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SlideInContent(child: _actions(context, s, hr)),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 40),
                child: TtFormCard(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 56.r,
                        height: 56.r,
                        padding: EdgeInsetsDirectional.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadiusDirectional.circular(12.r),
                        ),
                        child: TtIcon(const TtGlyph.svg(TtAssets.locBuilding), size: 32.r, color: AppColors.text),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(LocationText.name(context, l),
                                style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
                            if (other.isNotEmpty) ...<Widget>[
                              SizedBox(height: 2.h),
                              Text(other, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
                            ],
                            SizedBox(height: 4.h),
                            Text(LocationText.hours(context, l),
                                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      TtStatusChip(
                        key: const ValueKey<String>('locationDetailsStatus'),
                        label: LocationText.status(context, l.status),
                        color: LocationStatusText.colorOf(l.status),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasPoint) ...<Widget>[
                SizedBox(height: 15.h),
                SlideInContent(
                  delay: const Duration(milliseconds: 60),
                  child: TtDetailSection(
                    key: const ValueKey<String>('locationDetailsMap'),
                    title: s.timeTrackerSectionMap,
                    icon: TtAssets.location,
                    trailing: l.googleMapsUrl.trim().isEmpty
                        ? null
                        : TtLink(
                            key: const ValueKey<String>('locationOpenMaps'),
                            label: s.timeTrackerOpenInGoogleMaps,
                            onTap: () {
                              final Uri? uri = Uri.tryParse(l.googleMapsUrl.trim());
                              if (uri != null) {
                                unawaited(launchUrl(uri, mode: LaunchMode.externalApplication)
                                    .catchError((Object _) => false));
                              }
                            },
                          ),
                    rows: <Widget>[
                      GeofenceMapPicker.preview(
                        latitude: l.latitude,
                        longitude: l.longitude,
                        radiusMeters: l.geofenceRadiusMeters,
                        showCircle: l.isGeofenceEnabled,
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 80),
                child: TtPair(
                  start: TtDetailSection(title: s.timeTrackerGeofencing, icon: TtAssets.location, rows: <Widget>[
                    TtDetailRule(icon: TtAssets.locGeofence, label: s.timeTrackerGeofencing,
                        value: onOff(l.isGeofenceEnabled), on: l.isGeofenceEnabled),
                    TtDetailInfo(icon: TtAssets.locGeofence, label: s.timeTrackerGeofenceRadiusColumn,
                        value: LocationText.radius(context, l)),
                    TtDetailInfo(icon: TtAssets.location, label: s.timeTrackerLatitude,
                        value: _or(l.latitude?.toStringAsFixed(5))),
                    TtDetailInfo(icon: TtAssets.location, label: s.timeTrackerLongitude,
                        value: _or(l.longitude?.toStringAsFixed(5))),
                  ]),
                  end: TtDetailSection(title: s.timeTrackerSectionAddress, icon: TtAssets.locCity, rows: <Widget>[
                    TtDetailInfo(icon: TtAssets.locCountry, label: s.timeTrackerCountry,
                        value: LocationText.country(context, l)),
                    TtDetailInfo(icon: TtAssets.locCity, label: s.timeTrackerStateOrProvince,
                        value: LocationText.state(context, l)),
                    TtDetailInfo(icon: TtAssets.locCity, label: s.timeTrackerCity, value: LocationText.city(context, l)),
                    TtDetailInfo(icon: TtAssets.email, label: s.timeTrackerPostalCode, value: _or(l.postalCode)),
                  ]),
                ),
              ),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 100),
                child: TtPair(
                  start: TtDetailSection(title: s.timeTrackerWorkSchedule, icon: TtAssets.clock, rows: <Widget>[
                    TtDetailInfo(icon: TtAssets.dayOncoming, label: s.timeTrackerWorkSchedule,
                        value: LocationText.hours(context, l)),
                    TtDetailInfo(icon: TtAssets.dayCalendar, label: s.timeTrackerWorkingDays,
                        value: _or(LocationText.days(context, l))),
                    TtDetailInfo(icon: TtAssets.dayLeaving, label: s.timeTrackerLateAfter,
                        value: TimeTrackerLateText.of(context, l.lateAfterMinutes)),
                  ]),
                  end: TtDetailSection(
                      title: s.timeTrackerSectionAttendanceRules, icon: TtAssets.dayBreak, rows: <Widget>[
                    TtDetailRule(icon: TtAssets.dayBreak, label: s.timeTrackerAllowBreaks,
                        value: onOff(l.isBreakAllowed), on: l.isBreakAllowed),
                    if (l.isBreakAllowed)
                      TtDetailInfo(icon: TtAssets.dayTotal, label: s.timeTrackerBreak,
                          value: LocationText.breakLength(context, l)),
                    TtDetailRule(icon: TtAssets.locPause, label: s.timeTrackerAllowPause,
                        value: onOff(l.isPauseAllowed), on: l.isPauseAllowed),
                    if (l.isPauseAllowed && l.pauseMinutes > 0)
                      TtDetailInfo(icon: TtAssets.dayTotal, label: s.timeTrackerAllowPause,
                          value: s.timeTrackerPauseUpToMinutes(LocalizedNumber.of(context, l.pauseMinutes))),
                  ]),
                ),
              ),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 110),
                child: BlocBuilder<EmployeesCubit, EmployeesState>(
                  builder: (BuildContext context, EmployeesState people) {
                    String person(String email) => email.isEmpty
                        ? TimeTrackerFormat.dash
                        : (people.employeeByEmail(email)?.name(isArabic: ar) ?? email);
                    return TtDetailSection(title: s.timeTrackerSectionHistory, icon: TtAssets.clock, rows: <Widget>[
                      TtPair(
                        start: TtDetailInfo(icon: TtAssets.person, label: s.timeTrackerAddedBy,
                            value: person(l.audit.createdBy)),
                        end: TtDetailInfo(icon: TtAssets.calendar, label: s.timeTrackerCreationDate,
                            value: TimeTrackerFormat.date(context, l.audit.createdAt)),
                      ),
                      TtPair(
                        start: TtDetailInfo(icon: TtAssets.person, label: s.timeTrackerUpdatedBy,
                            value: person(l.audit.modifiedBy)),
                        end: TtDetailInfo(icon: TtAssets.clock, label: s.timeTrackerLastUpdate,
                            value: TimeTrackerFormat.date(context, l.audit.updatedAt)),
                      ),
                    ]);
                  },
                ),
              ),
              SizedBox(height: 20.h),
              SlideInContent(
                delay: const Duration(milliseconds: 120),
                child: _AssignedEmployees(emails: state.assignedTo(l.id)),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  static String _or(String? v) => (v ?? '').trim().isEmpty ? TimeTrackerFormat.dash : v!.trim();

  Widget _actions(BuildContext context, S s, bool hr) {
    // Owner (13/10/2026): the status is the chip in the header card.
    return Row(
      children: <Widget>[
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
