/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: location_rules_panel.dart
/// Purpose: Declares `LocationRulesPanel` (the PREVIEW of a location's
///          attendance rules + the "Use the location's rules" switch, shared
///          by the group form and the Assign / Reassign dialog),
///          `LocationRulesText` (the one-line summary) and `RulesSourceTag`
///          ("From location" / "Custom").
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (owner decision 33, round 6)
///
/// Owner decision 33: the location is the source of the rules. Under the
/// chosen location the form shows "Rules from <location>: 08:00 AM–04:00 PM
/// · Sun–Thu · Late after 10 min · Breaks 30 min · Pause allowed" and a
/// switch "Use the location's rules" (ON by default). OFF reveals the
/// caller's custom fields under "Custom rules for this group / employee —
/// Custom — overrides the location". Times in 12-hour, days by the app
/// language (Sunday first), digits localized.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationRulesText {
  const LocationRulesText._();

  static String _clock(BuildContext context, int minutes) =>
      TimeTrackerFormat.time(context, DateTime(2000, 1, 1, 0, minutes));

  /// Function Name: [days]
  ///
  /// Purpose: "Sun–Thu" for a run of days (Sunday first), else "Sun, Tue".
  ///
  /// Return type: [String]
  static String days(BuildContext context, List<int> working) {
    final String locale = Localizations.localeOf(context).languageCode;
    String name(int d) => DateFormat('EEE', locale).format(DateTime(2024, 1, d));
    final List<int> order = <int>[for (final int d in LocationFormRules.weekOrder) if (working.contains(d)) d];
    if (order.isEmpty) return TimeTrackerFormat.dash;
    final List<int> idx = <int>[for (final int d in order) LocationFormRules.weekOrder.indexOf(d)];
    final bool run = idx.length > 2 && idx.last - idx.first == idx.length - 1;
    return run ? '${name(order.first)}–${name(order.last)}' : order.map(name).join(', ');
  }

  /// Function Name: [rules]
  ///
  /// Purpose: "Breaks 30 min · Pause allowed" / "… · Pause up to 15 min"
  /// (approved schema `Allowed_Pause_Minutes`).
  ///
  /// Return type: [String]
  static String rules(BuildContext context, AttendanceRules r) {
    final S s = S.of(context);
    return <String>[
      r.isBreakAllowed && r.breakMinutes > 0
          ? s.timeTrackerBreaksMinutes(LocalizedNumber.of(context, r.breakMinutes))
          : s.timeTrackerNoBreaks,
      !r.isPauseAllowed
          ? s.timeTrackerNoPause
          : r.pauseMinutes > 0
              ? s.timeTrackerPauseUpToMinutes(LocalizedNumber.of(context, r.pauseMinutes))
              : s.timeTrackerPauseAllowed,
    ].join(' · ');
  }

  /// Function Name: [summary]
  ///
  /// Purpose: Hours · days · Late after · breaks · pause of [location].
  ///
  /// Return type: [String]
  static String summary(BuildContext context, WorkLocation location) {
    final S s = S.of(context);
    return <String>[
      '${_clock(context, location.workStartMinutes)}–${_clock(context, location.workEndMinutes)}',
      days(context, location.workingDays),
      if (location.lateAfterMinutes > 0)
        s.timeTrackerLateAfterMinutes(LocalizedNumber.of(context, location.lateAfterMinutes)),
      rules(context, EffectiveRulesResolver.locationRules(location)),
    ].join(' · ');
  }
}

/// The location's rules preview + "Use the location's rules".
class LocationRulesPanel extends StatelessWidget {
  const LocationRulesPanel({
    super.key,
    required this.location,
    required this.useLocation,
    required this.onUseLocation,
    required this.customTitle,
  });

  /// The chosen location (null = none yet → nothing is shown).
  final WorkLocation? location;
  final bool useLocation;
  final ValueChanged<bool> onUseLocation;

  /// "Custom rules for this group" / "… for this employee".
  final String customTitle;

  @override
  Widget build(BuildContext context) {
    final WorkLocation? l = location;
    if (l == null) return const SizedBox.shrink();
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          key: const ValueKey<String>('locationRulesPreview'),
          padding: EdgeInsetsDirectional.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadiusDirectional.circular(8.r),
          ),
          child: Text.rich(
            TextSpan(children: <InlineSpan>[
              TextSpan(
                text: '${s.timeTrackerRulesFromLocation(l.name(isArabic: ar))}: ',
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              ),
              TextSpan(
                text: LocationRulesText.summary(context, l),
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
              ),
            ]),
          ),
        ),
        SizedBox(height: 10.h),
        TtSwitchRow(
          key: const ValueKey<String>('useLocationRulesSwitch'),
          label: s.timeTrackerUseLocationRules,
          value: useLocation,
          onChanged: onUseLocation,
        ),
        if (!useLocation) ...<Widget>[
          SizedBox(height: 10.h),
          Text(customTitle, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
          SizedBox(height: 2.h),
          Text(
            s.timeTrackerCustomOverridesLocation,
            key: const ValueKey<String>('customRulesNote'),
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.orange),
          ),
        ],
      ],
    );
  }
}

/// "From location" (grey) / "Custom" (yellow) on an employee card.
class RulesSourceTag extends StatelessWidget {
  const RulesSourceTag({super.key, required this.source});

  final RulesSource source;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool custom = source != RulesSource.location;
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: custom ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadiusDirectional.circular(8.r),
      ),
      child: Text(
        custom ? s.timeTrackerRangeCustom : s.timeTrackerRulesFromLocationTag,
        style: StyleText.fontSize10Weight400.copyWith(
          color: custom ? AppColors.textButton : AppColors.secondaryText,
        ),
      ),
    );
  }
}
