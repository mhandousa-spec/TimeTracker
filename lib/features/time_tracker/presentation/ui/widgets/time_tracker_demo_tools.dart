/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_tools.dart
/// Purpose: Declares `TimeTrackerDemoToolsButton` — a DEBUG-ONLY 🧪 icon in
///          the "Tracking Time" title row that opens the "Demo tools"
///          dialog: Load demo data · Remove demo data.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — same placement / look as To-Do's
///            `TodoDebugToolsButton`)
///
/// The title row only builds this widget behind `if (kDebugMode)` (a
/// compile-time constant), so it is tree-shaken from release builds and no
/// client ever sees it. The work is done by `TimeTrackerDemoCubit`; after a
/// load / remove every Time Tracker list re-reads its data so the change
/// shows at once. Haptics: open = Low; Load = Medium (customButton); Remove =
/// High (a delete, red with white text).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/app_toast.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_demo_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Square 38 icon (same size as the toolbar icon buttons). Build it ONLY
/// under `kDebugMode`.
class TimeTrackerDemoToolsButton extends StatelessWidget {
  const TimeTrackerDemoToolsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.of(context).timeTrackerDemoTools,
      child: GestureDetector(
        key: const ValueKey<String>('timeTrackerDemoTools'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: Container(
          width: ButtonSizing.iconButtonSize,
          height: ButtonSizing.iconButtonSize,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadiusDirectional.circular(ButtonSizing.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(Icons.science_outlined, size: 20.sp, color: AppColors.secondaryText),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    HapticController.low();
    // Read here: the dialog route sits above the module's providers.
    final VoidCallback refresh = _refresher(context);
    showScaleDialog<void>(
      context: context,
      builder: (_) => BlocProvider<TimeTrackerDemoCubit>(
        create: (_) => GetIt.instance<TimeTrackerDemoCubit>(),
        child: _DemoToolsDialog(onChanged: refresh),
      ),
    );
  }

  /// Every Time Tracker list re-reads its data (each `init` cancels its old
  /// streams first). Only the cubits the module provides for this user.
  VoidCallback _refresher(BuildContext context) {
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<VoidCallback> jobs = <VoidCallback>[
      context.read<PersonalDashboardCubit>().init,
      context.read<AttendanceCubit>().init,
      context.read<LocationsCubit>().init,
      () => context.read<EmployeesCubit>().init(isArabic: ar),
      () => context.read<RequestTypesCubit>().init(isArabic: ar),
      () => context.read<RequestsCubit>().init(isArabic: ar),
      if (access.canCheckInAndOut) context.read<CheckInCubit>().init,
      if (access.canViewHrDashboard) () => context.read<HrDashboardCubit>().init(isArabic: ar),
      if (access.canViewVacationBalances) () => context.read<VacationBalancesCubit>().init(isArabic: ar),
    ];
    return () {
      for (final VoidCallback job in jobs) {
        job();
      }
    };
  }
}

class _DemoToolsDialog extends StatelessWidget {
  const _DemoToolsDialog({required this.onChanged});

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(12.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380.sp),
        child: Padding(
          padding: EdgeInsetsDirectional.all(20.sp),
          child: BlocBuilder<TimeTrackerDemoCubit, TimeTrackerDemoState>(
            builder: (BuildContext context, TimeTrackerDemoState state) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(s.timeTrackerDemoTools, style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
                SizedBox(height: 6.sp),
                Text(s.timeTrackerDemoToolsHint,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                SizedBox(height: 16.sp),
                if (state.isBusy)
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 12.sp),
                    child: Center(
                      child: SizedBox(
                        width: 28.sp,
                        height: 28.sp,
                        child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                      ),
                    ),
                  )
                else ...<Widget>[
                  KeyedSubtree(
                    key: const ValueKey<String>('timeTrackerDemoLoad'),
                    child: customButton(
                      title: s.timeTrackerDemoLoad,
                      function: () => _load(context),
                      fullWidth: true,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  KeyedSubtree(
                    key: const ValueKey<String>('timeTrackerDemoRemove'),
                    child: customButton(
                      title: s.timeTrackerDemoRemove,
                      function: () => _remove(context),
                      fullWidth: true,
                      haptic: HapticController.high,
                      color: AppColors.red,
                      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _load(BuildContext context) async {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final NavigatorState nav = Navigator.of(context);
    final TimeTrackerDemoOutcome r = await context.read<TimeTrackerDemoCubit>().load(isArabic: ar);
    if (r.ok && !r.alreadyLoaded) onChanged();
    nav.pop();
    AppToast.show(!r.ok
        ? s.timeTrackerActionFailed
        : r.alreadyLoaded
            ? s.timeTrackerDemoAlreadyLoaded
            : s.timeTrackerDemoLoadDone(
                LocalizedNumber.forLocale(r.documents, locale),
                LocalizedNumber.forLocale(r.files, locale),
              ));
  }

  Future<void> _remove(BuildContext context) async {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final NavigatorState nav = Navigator.of(context);
    final TimeTrackerDemoOutcome r = await context.read<TimeTrackerDemoCubit>().remove();
    if (r.ok) onChanged();
    nav.pop();
    AppToast.show(r.ok
        ? s.timeTrackerDemoRemoveDone(LocalizedNumber.forLocale(r.documents, locale))
        : s.timeTrackerActionFailed);
  }
}
