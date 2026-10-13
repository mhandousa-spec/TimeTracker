/// Module: time_tracker / tt6_employees / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: grant_access_dialog.dart
/// Purpose: Declares `showGrantAccessFlow` and `GrantAccessDialog` — the
///          "Review" dialog of Assign / Reassign (one or several employees):
///          employee card · Location · Start Date · Allow Breaks (+ length)
///          · Allow Pause · Allow Different Work Location (+ Select
///          Location) · Discard / Grant Access → "Access Granted".
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:95280` / `661:95106` (one employee) and `661:95172` (several).
/// No confirm is drawn for Grant Access, so the save runs straight away and
/// a success message follows (house pattern). Reassign is pre-filled with the
/// current assignment; a new assignment takes the chosen location's break /
/// pause settings until the user changes them. Grant Access stays grey until
/// the draft is valid (`AssignmentRules`); a tap on it reveals the errors.
/// Updated: 9/10/2026 - owner decision 33: under the location, a preview of
/// its rules + "Use the location's rules" (ON = nothing copied, the location
/// applies; OFF = custom Allow Breaks / Pause for this employee only,
/// pre-filled from the location); labels keep the text colour on an error
/// (dark-mode contrast). `AttendanceRulesFields.showBreakPause`.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/location_rules_panel.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// What the dialog returns on Grant Access.
class GrantAccessResult {
  const GrantAccessResult({required this.locationId, required this.startDate, required this.rules});

  final String locationId;
  final DateTime startDate;
  final AttendanceRules rules;
}

/// Function Name: [showGrantAccessFlow]
///
/// Purpose: Review dialog → save → "Access Granted" (or the failure).
///
/// Return type: [Future<void>]
Future<void> showGrantAccessFlow(BuildContext context, List<TimeTrackerEmployee> employees) async {
  if (employees.isEmpty) return;
  final EmployeesCubit cubit = context.read<EmployeesCubit>();
  final GrantAccessResult? result = await CustomDialogManager.showContent<GrantAccessResult>(
    context: context,
    width: 615,
    child: GrantAccessDialog(
      employees: employees,
      current: employees.length == 1 ? cubit.state.assignmentOf(employees.first.email) : null,
      locations: cubit.state.activeLocations,
    ),
  );
  if (result == null || !context.mounted) return;
  final bool ok = await refreshingCheckIn(context, () => cubit.grantAccess(
        emails: <String>[for (final TimeTrackerEmployee e in employees) e.email],
        locationId: result.locationId,
        startDate: result.startDate,
        rules: result.rules,
      ))();
  if (!context.mounted) return;
  final S s = S.of(context);
  if (ok) {
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.successful,
      title: s.timeTrackerAccessGrantedTitle,
      subtitle: s.timeTrackerAccessGranted,
    );
    return;
  }
  final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
  cubit.acknowledgeFailure();
  await showTimeTrackerFailure(context, denied: denied);
}

class GrantAccessDialog extends StatefulWidget {
  const GrantAccessDialog({super.key, required this.employees, required this.locations, this.current});

  final List<TimeTrackerEmployee> employees;
  final List<WorkLocation> locations;
  final LocationAssignment? current;

  @override
  State<GrantAccessDialog> createState() => _GrantAccessDialogState();
}

class _GrantAccessDialogState extends State<GrantAccessDialog> {
  final TextEditingController _break = TextEditingController();
  final TextEditingController _pauseLimit = TextEditingController();
  TtDurationUnit _unit = TtDurationUnit.minutes;
  String _locationId = '';
  DateTime? _start;
  bool _breaks = false;
  bool _pause = false;
  bool _different = false;
  List<String> _allowed = <String>[];
  bool _rulesTouched = false;
  bool _showErrors = false;

  /// Decision 33 (9/10/2026): "Use the location's rules" (ON for a new
  /// assignment; an existing one keeps what it had).
  bool _useLocation = true;

  @override
  void initState() {
    super.initState();
    final LocationAssignment? a = widget.current;
    if (a != null && a.isAssigned) {
      _locationId = a.locationId;
      _start = a.startDate;
      _applyRules(a.rules);
      _useLocation = !a.rules.isCustom;
      _rulesTouched = a.rules.isCustom;
    }
  }

  @override
  void dispose() {
    _break.dispose();
    _pauseLimit.dispose();
    super.dispose();
  }

  void _applyRules(AttendanceRules r) {
    _breaks = r.isBreakAllowed;
    _pause = r.isPauseAllowed;
    _different = r.isDifferentLocationAllowed;
    _allowed = List<String>.of(r.allowedLocationIds);
    final bool hours = r.breakMinutes > 0 && r.breakMinutes % 60 == 0;
    _unit = hours ? TtDurationUnit.hours : TtDurationUnit.minutes;
    _break.text = r.breakMinutes <= 0 ? '' : '${hours ? r.breakMinutes ~/ 60 : r.breakMinutes}';
    _pauseLimit.text = r.pauseMinutes <= 0 ? '' : '${r.pauseMinutes}';
  }

  AttendanceRules get _rules => AttendanceRules(
        isBreakAllowed: !_useLocation && _breaks,
        breakMinutes: _useLocation ? 0 : TtBreakLengthField.minutesOf(_break.text, _unit),
        isPauseAllowed: !_useLocation && _pause,
        pauseMinutes: !_useLocation && _pause ? TtPauseLimitField.minutesOf(_pauseLimit.text) : 0,
        isDifferentLocationAllowed: _different,
        // 12/10/2026 (owner T5): the extra work locations, always kept.
        allowedLocationIds: _allowed,
        isCustom: !_useLocation,
      );

  WorkLocation? get _location {
    for (final WorkLocation l in widget.locations) {
      if (l.id == _locationId) return l;
    }
    return null;
  }

  /// OFF starts the custom fields from the location's values.
  void _setUseLocation(bool use) => setState(() {
        _useLocation = use;
        final WorkLocation? l = _location;
        if (!use && !_rulesTouched && l != null) {
          final AttendanceRules from = EffectiveRulesResolver.locationRules(l);
          _breaks = from.isBreakAllowed;
          _pause = from.isPauseAllowed;
          _pauseLimit.text = from.pauseMinutes <= 0 ? '' : '${from.pauseMinutes}';
          final bool hours = from.breakMinutes > 0 && from.breakMinutes % 60 == 0;
          _unit = hours ? TtDurationUnit.hours : TtDurationUnit.minutes;
          _break.text = from.breakMinutes <= 0 ? '' : '${hours ? from.breakMinutes ~/ 60 : from.breakMinutes}';
        }
      });

  Set<AssignmentError> get _errors =>
      AssignmentRules.validate(locationId: _locationId, startDate: _start, rules: _rules);

  String? _error(AssignmentError e, String text) =>
      _showErrors && _errors.contains(e) ? text : null;

  void _pickLocation(String id) {
    setState(() {
      _locationId = id;
      if (_rulesTouched) return;
      for (final WorkLocation l in widget.locations) {
        if (l.id == id) {
          _applyRules(EffectiveRulesResolver.locationRules(l).copyWith(
            isDifferentLocationAllowed: _different,
            allowedLocationIds: _allowed,
          ));
        }
      }
    });
  }

  void _touch(VoidCallback change) => setState(() {
        _rulesTouched = true;
        change();
      });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool valid = _errors.isEmpty;
    return ScaleInContent(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TtDialogHeader(title: s.review),
            SizedBox(height: 15.h),
            _EmployeeSummary(employees: widget.employees),
            SizedBox(height: 15.h),
            // 12/10/2026 (owner T5 / T6 / U4): Work Locations, then the main
            // location's rules right under it, then the start date.
            _locationField(s),
            SizedBox(height: 15.h),
            // Decision 33 (9/10/2026): preview + "Use the location's rules".
            LocationRulesPanel(
              location: _location,
              useLocation: _useLocation,
              onUseLocation: _setUseLocation,
              customTitle: s.timeTrackerCustomRulesEmployee,
            ),
            SizedBox(height: 15.h),
            _startField(s),
            SizedBox(height: 15.h),
            _rulesFields(s),
            SizedBox(height: 20.h),
            TimeTrackerFormActions(
              primaryKey: const ValueKey<String>('grantAccessButton'),
              primaryTitle: s.timeTrackerGrantAccess,
              canSubmit: valid,
              onDiscard: () => Navigator.of(context).pop(),
              onSubmit: () => Navigator.of(context).pop(
                GrantAccessResult(locationId: _locationId, startDate: _start!, rules: _rules),
              ),
              onDisabledTap: () => setState(() => _showErrors = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationField(S s) {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    return TtWorkLocationsField(
      key: const ValueKey<String>('grantAccessLocation'),
      mainId: _locationId,
      extraIds: _allowed,
      locations: widget.locations,
      isArabic: ar,
      error: _error(AssignmentError.locationRequired, s.timeTrackerLocationRequired),
      onChanged: (String main, List<String> extras) {
        setState(() => _allowed = extras);
        if (main != _locationId) _pickLocation(main);
      },
    );
  }

  Widget _startField(S s) => CustomDropdownCalendar(
        key: const ValueKey<String>('grantAccessStartDate'),
        label: s.timeTrackerStartDate,
        labelStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        hint: s.timeTrackerChooseTheDate,
        value: _start,
        height: 36,
        errorText: _error(AssignmentError.startDateRequired, s.timeTrackerStartDateRequired),
        dateFormatter: (DateTime d) => LocalizedDate.of(context, d),
        onChanged: (DateTime? d) => setState(() => _start = d),
      );

  Widget _rulesFields(S s) {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    return AttendanceRulesFields(
      showBreakPause: !_useLocation,
      breaks: _breaks,
      pause: _pause,
      different: _different,
      breakController: _break,
      unit: _unit,
      locations: widget.locations,
      isArabic: ar,
      breakError: _error(AssignmentError.breakLengthRequired, s.timeTrackerBreakLengthRequired),
      onBreaks: (bool v) => _touch(() => _breaks = v),
      onPause: (bool v) => _touch(() => _pause = v),
      onDifferent: (bool v) => _touch(() => _different = v),
      onBreakLength: () => _touch(() {}),
      pauseController: _pauseLimit,
      onPauseLength: (_) => _touch(() {}),
      onUnit: (TtDurationUnit u) => _touch(() => _unit = u),
    );
  }
}

/// ADDED 12/10/2026 (owner T5 / T6): "Work Locations" — ONE multi-select
/// for every place the employee (or group) works. The FIRST picked is the
/// main location (its hours, days and rules apply — tag "Main"); the others
/// are extra offices they may also check in / out at (stored in
/// `AttendanceRules.allowedLocationIds`, so no data migration). Removing the
/// main one promotes the next. Shared by Grant Access and the group form.
class TtWorkLocationsField extends StatelessWidget {
  const TtWorkLocationsField({
    super.key,
    required this.mainId,
    required this.extraIds,
    required this.locations,
    required this.isArabic,
    required this.onChanged,
    this.error,
    this.labelStyle,
  });

  final String mainId;
  final List<String> extraIds;
  final List<WorkLocation> locations;
  final bool isArabic;

  /// (main id, extra ids) — main '' when nothing is picked.
  final void Function(String mainId, List<String> extraIds) onChanged;
  final String? error;
  final TextStyle? labelStyle;

  List<String> get _all => <String>[
        if (mainId.isNotEmpty) mainId,
        for (final String id in extraIds)
          if (id != mainId) id,
      ];

  void _set(List<String> picked) {
    final String main = picked.isEmpty ? '' : (picked.contains(mainId) ? mainId : picked.first);
    onChanged(main, <String>[for (final String id in picked) if (id != main) id]);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<String> all = _all;
    String name(String id) {
      for (final WorkLocation l in locations) {
        if (l.id == id) return l.name(isArabic: isArabic);
      }
      return id;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CustomMultiSelectDropdown<String>(
          label: s.timeTrackerWorkLocations,
          labelStyle: labelStyle ?? StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          hint: s.timeTrackerChooseLocation,
          // 12/10/2026 (owner U6): the field fill of every other dropdown
          // (the core default is the CARD colour — invisible on a card) and
          // the whole trigger 36 high (else the hint sits on the bottom edge).
          fillColor: kDropdownFillColor,
          height: 36,
          heightSizesWholeTrigger: true,
          alwaysShowHint: true,
          itemStyle: StyleText.fontSize12Weight400,
          values: all,
          errorText: error,
          items: <MultiSelectDropdownItem<String>>[
            for (final WorkLocation l in locations)
              MultiSelectDropdownItem<String>(value: l.id, label: l.name(isArabic: isArabic)),
          ],
          onChanged: _set,
        ),
        if (all.isNotEmpty) ...<Widget>[
          SizedBox(height: 8.h),
          Wrap(
            key: const ValueKey<String>('workLocationsChips'),
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              for (final String id in all)
                TtRemovableChip(
                  key: ValueKey<String>('workLocationChip_$id'),
                  label: id == mainId ? '${name(id)} · ${s.timeTrackerMainLocation}' : name(id),
                  onRemove: () => _set(<String>[for (final String x in all) if (x != id) x]),
                ),
            ],
          ),
          if (all.length > 1) ...<Widget>[
            SizedBox(height: 6.h),
            Text(s.timeTrackerWorkLocationsHint,
                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText)),
          ],
        ],
      ],
    );
  }
}

/// Allow Breaks (+ length) · Allow Pause · Allow Different Work Location —
/// shared by Grant Access and the group form.
/// Updated: 12/10/2026 - owner T6: the extra-location picker under "Allow
/// Different Work Location" is gone (extra offices live in
/// [TtWorkLocationsField]); the switch now means Remote / Client Site.
class AttendanceRulesFields extends StatelessWidget {
  const AttendanceRulesFields({
    super.key,
    required this.breaks,
    required this.pause,
    required this.different,
    required this.breakController,
    required this.unit,
    required this.locations,
    required this.isArabic,
    required this.onBreaks,
    required this.onPause,
    required this.onDifferent,
    required this.onBreakLength,
    required this.onUnit,
    this.breakError,
    this.showBreakPause = true,
    this.pauseController,
    this.onPauseLength,
  });

  /// ADDED 9/10/2026 (approved schema `Custom_Rules.Allowed_Pause_Minutes`):
  /// the "Maximum pause (minutes)" field under Allow Pause (null = hidden).
  final TextEditingController? pauseController;
  final ValueChanged<String>? onPauseLength;

  /// ADDED 9/10/2026 (decision 33): false while the location's rules apply
  /// (only "Allow Different Work Location" — not a location rule — shows).
  final bool showBreakPause;

  final bool breaks;
  final bool pause;
  final bool different;
  final TextEditingController breakController;
  final TtDurationUnit unit;
  final List<WorkLocation> locations;
  final bool isArabic;
  final ValueChanged<bool> onBreaks;
  final ValueChanged<bool> onPause;
  final ValueChanged<bool> onDifferent;
  final VoidCallback onBreakLength;
  final ValueChanged<TtDurationUnit> onUnit;
  final String? breakError;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showBreakPause) ...<Widget>[
        TtPair(
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TtSwitchRow(
                key: const ValueKey<String>('rulesBreakSwitch'),
                label: s.timeTrackerAllowBreaks,
                value: breaks,
                onChanged: onBreaks,
              ),
              if (breaks) ...<Widget>[
                SizedBox(height: 10.h),
                TtBreakLengthField(
                  controller: breakController,
                  unit: unit,
                  error: breakError,
                  onChanged: (_) => onBreakLength(),
                  onUnitChanged: onUnit,
                ),
              ],
            ],
          ),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TtSwitchRow(
                key: const ValueKey<String>('rulesPauseSwitch'),
                label: s.timeTrackerAllowPause,
                value: pause,
                onChanged: onPause,
              ),
              if (pause && pauseController != null) ...<Widget>[
                SizedBox(height: 10.h),
                TtPauseLimitField(
                  key: const ValueKey<String>('rulesPauseLimit'),
                  controller: pauseController!,
                  onChanged: (String v) => onPauseLength?.call(v),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 15.h),
        ],
        TtPair(
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TtSwitchRow(
                key: const ValueKey<String>('rulesDifferentSwitch'),
                label: s.timeTrackerAllowDifferentLocation,
                value: different,
                onChanged: onDifferent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One employee's card (Title · Department · Phone · Email) or "N
/// Employees Selected".
class _EmployeeSummary extends StatelessWidget {
  const _EmployeeSummary({required this.employees});

  final List<TimeTrackerEmployee> employees;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final TimeTrackerEmployee first = employees.first;
    final TextStyle label = StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);
    final TextStyle value = StyleText.fontSize12Weight500.copyWith(color: AppColors.text);
    Widget pair(String l, String v) => Text.rich(
          TextSpan(children: <InlineSpan>[
            TextSpan(text: '$l: ', style: label),
            TextSpan(text: v.isEmpty ? '-' : v, style: value),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    return Container(
      padding: EdgeInsetsDirectional.all(15.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadiusDirectional.circular(8.r),
      ),
      child: employees.length > 1
          ? Text(
              s.timeTrackerEmployeesSelected(LocalizedNumber.of(context, employees.length)),
              style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            )
          : Row(
              children: <Widget>[
                TimeTrackerAvatar(photo: first.photo, size: 64.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(first.name(isArabic: ar),
                          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
                      SizedBox(height: 6.h),
                      TtPair(
                        start: pair(s.timeTrackerTitleLabel, first.jobTitle(isArabic: ar)),
                        end: pair(s.timeTrackerPhoneNumber, first.phone),
                      ),
                      SizedBox(height: 4.h),
                      TtPair(
                        start: pair(s.timeTrackerDepartment, first.department(isArabic: ar)),
                        end: pair(s.timeTrackerEmail, first.email),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
