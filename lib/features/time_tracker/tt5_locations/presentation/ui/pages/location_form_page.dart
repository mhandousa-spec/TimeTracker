/// Module: time_tracker / tt5_locations / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: location_form_page.dart
/// Purpose: Declares `LocationFormPage` — "Tracking Time › Creating New
///          Location" / "› Editing Location": Location Description (names,
///          Google Maps link, latitude / longitude + "Use My Current
///          Location", geofence radius, country / state / city twins, postal
///          code) · Work Schedule (start / end, working days, Late After) ·
///          Location Setting (breaks + length, pause) · Discard / Create|Save.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:39468` (geofence off) / `661:40152` (on) / `661:40322` (edit)
/// + owner-approved Work Start Time · Work End Time · Working Days · Late
/// After (decisions 13, 22). The Figma "Geofencing Area (m²)" is replaced by
/// the radius only (the geofence is a circle). Dialogs: `661:74261` →
/// `661:74337` (create), `661:95064` → `661:95077` (edit). Pushed inside the
/// module's nested Navigator; provides its own `LocationFormCubit`. The page
/// owns the text controllers (playbook §3).
/// Updated: 9/10/2026 - approved schema: "Maximum pause (minutes)" under
/// Allow Pause (`Allowed_Pause_Minutes`, empty = no limit).
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - QA KP-TT-004 (State / City hints name their own
/// field) and KP-TT-006 (searchable Country list).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:latlong2/latlong.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/location_data_service.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/geofence_map_picker.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/location_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationFormPage extends StatelessWidget {
  const LocationFormPage({super.key, this.original});

  /// The location to edit (null = create).
  final WorkLocation? original;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationFormCubit>(
      create: (_) => GetIt.instance<LocationFormCubit>(param1: original),
      child: const _LocationFormView(),
    );
  }
}

class _LocationFormView extends StatefulWidget {
  const _LocationFormView();

  @override
  State<_LocationFormView> createState() => _LocationFormViewState();
}

class _LocationFormViewState extends State<_LocationFormView> {
  final Map<String, TextEditingController> _c = <String, TextEditingController>{};
  TtDurationUnit _unit = TtDurationUnit.minutes;

  LocationFormCubit get _cubit => context.read<LocationFormCubit>();
  WorkLocation get _draft => _cubit.state.draft;

  TextEditingController _ctl(String key, String initial) =>
      _c.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  void initState() {
    super.initState();
    final WorkLocation l = context.read<LocationFormCubit>().state.draft;
    String num(double? v) => v == null ? '' : '$v';
    _ctl('nameEn', l.nameEn);
    _ctl('nameAr', l.nameAr);
    _ctl('maps', l.googleMapsUrl);
    _ctl('lat', num(l.latitude));
    _ctl('lng', num(l.longitude));
    _ctl('radius', l.geofenceRadiusMeters > 0 ? '${l.geofenceRadiusMeters.round()}' : '');
    _ctl('postal', l.postalCode);
    _ctl('late', l.lateAfterMinutes > 0 ? '${l.lateAfterMinutes}' : '');
    final bool hours = l.breakMinutes > 0 && l.breakMinutes % 60 == 0;
    _unit = hours ? TtDurationUnit.hours : TtDurationUnit.minutes;
    _ctl('break', l.breakMinutes <= 0 ? '' : '${hours ? l.breakMinutes ~/ 60 : l.breakMinutes}');
    _ctl('pause', l.pauseMinutes <= 0 ? '' : '${l.pauseMinutes}');
    // States / cities for the address dropdowns (9/10/2026).
    LocationDataService.instance.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _coordinates() {
    final double? lat = LocationFormRules.parseCoordinate(_c['lat']!.text);
    final double? lng = LocationFormRules.parseCoordinate(_c['lng']!.text);
    final WorkLocation cleared = _draft.copyWith(clearCoordinates: true);
    _cubit.update(cleared.copyWith(latitude: lat, longitude: lng));
  }

  void _breakChanged() => _cubit.update(_draft.copyWith(
        breakMinutes: TtBreakLengthField.minutesOf(_c['break']!.text, _unit),
      ));

  Future<void> _locate() async {
    HapticController.medium();
    final GeoPoint? p = await _cubit.useCurrentLocation();
    if (!mounted) return;
    if (p != null) {
      _c['lat']!.text = p.latitude.toStringAsFixed(6);
      _c['lng']!.text = p.longitude.toStringAsFixed(6);
      _coordinates();
      return;
    }
    final S s = S.of(context);
    final DeviceLocationIssue? issue = _cubit.state.locateIssue;
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: s.timeTrackerLocationNeededTitle,
      subtitle: issue == DeviceLocationIssue.serviceDisabled
          ? s.timeTrackerLocationServiceOff
          : (issue == DeviceLocationIssue.denied || issue == DeviceLocationIssue.deniedForever)
              ? s.timeTrackerLocationDeniedSetup
              : s.timeTrackerLocationUnavailable,
    );
  }

  /// The user may switch Active / Inactive (Edit form only).
  bool get _canChangeStatus => GetIt.instance<TimeTrackerAccess>()
      .canChangeLocationStatus(companyHasHr: context.read<LocationsCubit>().state.companyHasHr);

  Future<void> _submit() async {
    final LocationFormCubit cubit = _cubit;
    if (!cubit.revealErrors()) return;
    final S s = S.of(context);
    final bool edit = cubit.state.isEdit;
    // Owner rule (9/10/2026): an in-use location cannot be made Inactive.
    final WorkLocation? before = cubit.state.original;
    final LocationsCubit list = context.read<LocationsCubit>();
    if (edit && before != null &&
        before.status == LocationStatus.active && cubit.state.draft.status != LocationStatus.active) {
      final int assigned = list.assignedCount(before);
      if (assigned > 0) {
        await CustomDialogManager.showMessage(
          context: context,
          lottiePath: AppAssets.lottieWarning,
          title: s.timeTrackerLocationInUseTitle,
          subtitle: s.timeTrackerLocationInUse(LocalizedNumber.of(context, assigned)),
        );
        return;
      }
    }
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      confirmLottie: edit ? AppAssets.lottieEditDocument : AppAssets.lottieConfirmation,
      confirmTitle: edit ? s.timeTrackerEditingLocation : s.timeTrackerCreatingNewLocation,
      confirmSubtitle: edit ? s.timeTrackerEditLocationConfirm : s.timeTrackerCreateLocationConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: refreshingCheckIn(context, cubit.submit),
      successLottie: AppAssets.successful,
      successTitle: edit ? s.timeTrackerLocationEditedTitle : s.timeTrackerLocationCreatedTitle,
      successSubtitle: edit ? s.timeTrackerLocationEdited : s.timeTrackerLocationCreated,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
    if (!mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  /// The Discard · primary row (pinned on a phone, under the form on a tablet).
  Widget _actions(LocationFormState state) {
    final S s = S.of(context);
    return TimeTrackerFormActions(
      primaryKey: const ValueKey<String>('locationSubmitButton'),
      primaryTitle: state.isEdit ? s.save : s.create,
      canSubmit: state.canSubmit,
      onDiscard: () => Navigator.of(context).maybePop(),
      onSubmit: _submit,
      onDisabledTap: _cubit.revealErrors,
      // 12/10/2026 (owner R4 / K2): an unchanged Edit form says why Save is grey.
      hint: state.isEdit && state.showErrors && state.errors.isEmpty && !state.isDirty ? s.noChangeFound : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      // 12/10/2026 (owner R8): phone — the action row stays fixed.
      bottomNavigationBar: context.isPhone
          ? TtPinnedFormActions(
              child: BlocBuilder<LocationFormCubit, LocationFormState>(
                builder: (BuildContext context, LocationFormState state) => _actions(state),
              ),
            )
          : null,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: _cubit.state.isEdit ? s.timeTrackerEditingLocation : s.timeTrackerCreatingNewLocation,
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: BlocBuilder<LocationFormCubit, LocationFormState>(
            builder: (BuildContext context, LocationFormState state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // UI quality pass (owner 13:45 #8, Figma 661:44042 pattern):
                // Active / Inactive lives in the Edit form, top end.
                if (state.isEdit && _canChangeStatus) ...<Widget>[
                  TtStatusSwitch(
                    key: const ValueKey<String>('locationStatusSwitch'),
                    label: s.timeTrackerActive,
                    value: state.draft.status == LocationStatus.active,
                    onChanged: (bool v) => _cubit.update(_draft.copyWith(
                      status: v ? LocationStatus.active : LocationStatus.inactive,
                    )),
                  ),
                  SizedBox(height: 10.h),
                ],
                SlideInContent(
                  child: TtFormCard(title: s.timeTrackerLocationDescription, child: _description(state)),
                ),
                SizedBox(height: 15.h),
                SlideInContent(
                  delay: const Duration(milliseconds: 60),
                  child: TtFormCard(title: s.timeTrackerWorkSchedule, child: _schedule(state)),
                ),
                SizedBox(height: 15.h),
                SlideInContent(
                  delay: const Duration(milliseconds: 120),
                  child: TtFormCard(title: s.timeTrackerLocationSetting, child: _settings(state)),
                ),
                if (!context.isPhone) ...<Widget>[
                  SizedBox(height: 20.h),
                  _actions(state),
                  SizedBox(height: 20.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(
    String key, {
    required String label,
    String? hint,
    String? error,
    bool arabic = false,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChanged,
  }) {
    final S s = S.of(context);
    return CustomTextField(
      key: ValueKey<String>('locationField_$key'),
      controller: _c[key],
      label: label,
      hint: hint ?? (arabic ? s.timeTrackerTextHereAr : s.textHere),
      height: 36,
      errorText: error,
      keyboardType: keyboard,
      inputFormatters: formatters,
      textDirection: arabic ? TextDirection.rtl : null,
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      onChanged: onChanged,
    );
  }

  // ── Address: Country → State → City dropdowns (owner, 9/10/2026) ─────────
  // Same data + control as Settings › Personal Information
  // (`LocationDataService` + `CustomDropdown`): the value saved is a CODE
  // (ISO-2 country, state code, English city name) and the label is shown in
  // the app language, so no Arabic twin fields are needed. Changing a level
  // clears the levels under it.

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  Widget _dropdown({
    required String key,
    required String label,
    required String hint,
    required String? value,
    required List<LocationOption> options,
    required bool byLabel,
    required ValueChanged<String> onChanged,
  }) {
    final bool ar = _isArabic;
    final List<DropdownItem<String>> items = <DropdownItem<String>>[
      for (final LocationOption o in options)
        DropdownItem<String>(value: byLabel ? o.name : o.code, label: o.label(ar)),
    ];
    final bool known = value != null && items.any((DropdownItem<String> i) => i.value == value);
    return CustomDropdown<String>(
      key: ValueKey<String>('locationField_$key'),
      height: 36,
      enforceTypeScale: false,
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      label: label,
      hint: hint,
      value: known ? value : null,
      enabled: options.isNotEmpty,
      items: items,
      onChanged: onChanged,
    );
  }

  /// KP-TT-006 (9/10/2026): [field] keeps the dropdown's look, but a tap
  /// opens a SEARCHABLE list instead of the long overlay.
  Widget _searchable(
    Widget field, {
    required String title,
    required String searchHint,
    required String? selected,
    required List<LocationOption> options,
    required ValueChanged<String> onChanged,
  }) {
    final bool ar = _isArabic;
    Future<void> open() async {
      HapticController.low();
      final String? picked = await CustomDialogManager.showContent<String>(
        context: context,
        width: 420,
        child: TtSearchPickerDialog(
          title: title,
          searchHint: searchHint,
          selected: selected,
          options: <(String, String)>[for (final LocationOption o in options) (o.code, o.label(ar))],
        ),
      );
      if (picked != null && picked != selected) onChanged(picked);
    }

    return GestureDetector(
      key: const ValueKey<String>('locationCountryPicker'),
      behavior: HitTestBehavior.opaque,
      onTap: options.isEmpty ? null : open,
      child: IgnorePointer(child: field),
    );
  }

  Widget _address(WorkLocation d) {
    final S s = S.of(context);
    final LocationDataService data = LocationDataService.instance;
    final String country = d.country.trim().toUpperCase();
    final List<LocationOption> states = data.statesOf(country);
    final List<LocationOption> cities = data.citiesOf(country, d.state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TtPair(
          // KP-TT-006 (9/10/2026): ~250 countries → a searchable list.
          start: _searchable(
            _dropdown(
              key: 'country',
              label: s.timeTrackerCountry,
              hint: s.selectCountry,
              value: country.isEmpty ? null : country,
              options: data.countries(context),
              byLabel: false,
              onChanged: (String iso) =>
                  _cubit.update(_draft.copyWith(country: iso, state: '', city: '')),
            ),
            title: s.timeTrackerCountry,
            searchHint: s.searchCountry,
            selected: country.isEmpty ? null : country,
            options: data.countries(context),
            onChanged: (String iso) =>
                _cubit.update(_draft.copyWith(country: iso, state: '', city: '')),
          ),
          // KP-TT-004 (9/10/2026): each field names ITSELF in its hint
          // (it read "Select Country" / "Select State" before a country).
          end: _dropdown(
            key: 'state',
            label: s.timeTrackerStateOrProvince,
            hint: s.timeTrackerSelectState,
            value: d.state.isEmpty ? null : d.state,
            options: states,
            byLabel: false,
            onChanged: (String code) =>
                _cubit.update(_draft.copyWith(state: code, city: '')),
          ),
        ),
        SizedBox(height: 15.h),
        TtPair(
          start: _dropdown(
            key: 'city',
            label: s.timeTrackerCity,
            hint: s.selectCity,
            value: d.city.isEmpty ? null : d.city,
            options: cities,
            byLabel: true,
            onChanged: (String name) => _cubit.update(_draft.copyWith(city: name)),
          ),
          end: _text('postal', label: s.timeTrackerPostalCode,
              onChanged: (String v) => _cubit.update(_draft.copyWith(postalCode: v))),
        ),
      ],
    );
  }

  Widget _description(LocationFormState state) {
    final S s = S.of(context);
    final WorkLocation d = state.draft;
    final List<TextInputFormatter> coords = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[-0-9.٠-٩٫]')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TtPair(
          start: _text('nameEn', label: s.timeTrackerLocationName,
              error: state.shows(LocationFormError.nameEnRequired) ? s.timeTrackerNameRequired : null,
              onChanged: (String v) => _cubit.update(_draft.copyWith(nameEn: v))),
          end: _text('nameAr', label: s.timeTrackerLocationNameAr, arabic: true,
              error: state.shows(LocationFormError.nameArRequired) ? s.timeTrackerArabicNameRequired : null,
              onChanged: (String v) => _cubit.update(_draft.copyWith(nameAr: v))),
        ),
        SizedBox(height: 15.h),
        _text('maps', label: s.timeTrackerLocationAtGoogleMaps, hint: s.timeTrackerGoogleMapsHint,
            keyboard: TextInputType.url,
            onChanged: (String v) => _cubit.update(_draft.copyWith(googleMapsUrl: v))),
        SizedBox(height: 15.h),
        TtPair(
          start: _text('lat', label: s.timeTrackerLatitude, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
              formatters: coords, onChanged: (_) => _coordinates(),
              error: state.shows(LocationFormError.latitudeInvalid) ? s.timeTrackerLatitudeInvalid : null),
          end: _text('lng', label: s.timeTrackerLongitude, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
              formatters: coords, onChanged: (_) => _coordinates(),
              error: state.shows(LocationFormError.longitudeInvalid) ? s.timeTrackerLongitudeInvalid : null),
        ),
        TtFieldError(state.shows(LocationFormError.coordinatesRequired) ? s.timeTrackerCoordinatesRequired : null),
        SizedBox(height: 10.h),
        TtPair(
          start: TtSwitchRow(
            key: const ValueKey<String>('locationGeofenceSwitch'),
            label: s.timeTrackerAllowGeofence,
            value: d.isGeofenceEnabled,
            onChanged: (bool v) => _cubit.update(_draft.copyWith(isGeofenceEnabled: v)),
          ),
        ),
        if (d.isGeofenceEnabled) ...<Widget>[
          SizedBox(height: 10.h),
          TtPair(
            start: _text('radius', label: s.timeTrackerGeofenceRadius, hint: s.timeTrackerRadiusHint,
                keyboard: TextInputType.number,
                formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                error: state.shows(LocationFormError.radiusRequired) ? s.timeTrackerRadiusRequired : null,
                onChanged: (String v) => _cubit.update(
                    _draft.copyWith(geofenceRadiusMeters: (int.tryParse(v) ?? 0).toDouble()))),
          ),
        ],
        // 12/10/2026 (owner L1 / S5): address search + my-location icon +
        // the live map (pin, and the geofence circle at the typed radius).
        SizedBox(height: 15.h),
        GeofenceMapPicker(
          key: const ValueKey<String>('locationGeofenceMap'),
          latitude: d.latitude,
          longitude: d.longitude,
          radiusMeters: d.geofenceRadiusMeters,
          showCircle: d.isGeofenceEnabled,
          locating: state.isLocating,
          onLocate: _locate,
          onPoint: (LatLng p) {
            _c['lat']!.text = p.latitude.toStringAsFixed(6);
            _c['lng']!.text = p.longitude.toStringAsFixed(6);
            _coordinates();
          },
          onRadius: (int m) {
            _c['radius']!.text = '$m';
            _cubit.update(_draft.copyWith(geofenceRadiusMeters: m.toDouble()));
          },
        ),
        SizedBox(height: 15.h),
        _address(d),
      ],
    );
  }

  Widget _schedule(LocationFormState state) {
    final S s = S.of(context);
    final WorkLocation d = state.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TtPair(
          start: TtLabeledTimeField(
            key: const ValueKey<String>('locationWorkStart'),
            label: s.timeTrackerWorkStartTime,
            minutes: d.workStartMinutes,
            onChanged: (int m) => _cubit.update(_draft.copyWith(workStartMinutes: m)),
          ),
          end: TtLabeledTimeField(
            key: const ValueKey<String>('locationWorkEnd'),
            label: s.timeTrackerWorkEndTime,
            minutes: d.workEndMinutes,
            error: state.shows(LocationFormError.workTimesSame) ? s.timeTrackerWorkTimesSame : null,
            onChanged: (int m) => _cubit.update(_draft.copyWith(workEndMinutes: m)),
          ),
        ),
        SizedBox(height: 15.h),
        TtWorkingDaysChips(
          selected: d.workingDays,
          onToggle: _cubit.toggleDay,
          error: state.shows(LocationFormError.workingDaysRequired) ? s.timeTrackerWorkingDaysRequired : null,
        ),
        SizedBox(height: 15.h),
        TtPair(
          start: _text('late', label: s.timeTrackerLateAfter, hint: s.timeTrackerLateAfterHint,
              keyboard: TextInputType.number,
              formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              onChanged: (String v) => _cubit.update(_draft.copyWith(lateAfterMinutes: int.tryParse(v) ?? 0))),
        ),
      ],
    );
  }

  Widget _settings(LocationFormState state) {
    final S s = S.of(context);
    final WorkLocation d = state.draft;
    return TtPair(
      start: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtSwitchRow(
            key: const ValueKey<String>('locationBreakSwitch'),
            label: s.timeTrackerAllowBreaks,
            value: d.isBreakAllowed,
            onChanged: (bool v) => _cubit.update(_draft.copyWith(isBreakAllowed: v)),
          ),
          if (d.isBreakAllowed) ...<Widget>[
            SizedBox(height: 10.h),
            TtBreakLengthField(
              controller: _c['break']!,
              unit: _unit,
              error: state.shows(LocationFormError.breakLengthRequired) ? s.timeTrackerBreakLengthRequired : null,
              onChanged: (_) => _breakChanged(),
              onUnitChanged: (TtDurationUnit u) {
                setState(() => _unit = u);
                _breakChanged();
              },
            ),
          ],
        ],
      ),
      end: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtSwitchRow(
            key: const ValueKey<String>('locationPauseSwitch'),
            label: s.timeTrackerAllowPause,
            value: d.isPauseAllowed,
            onChanged: (bool v) => _cubit.update(_draft.copyWith(isPauseAllowed: v)),
          ),
          // Approved schema (9/10/2026): `Allowed_Pause_Minutes`, the
          // location's default longest pause (empty = no limit).
          if (d.isPauseAllowed) ...<Widget>[
            SizedBox(height: 10.h),
            TtPauseLimitField(
              key: const ValueKey<String>('locationPauseMinutes'),
              controller: _ctl('pause', d.pauseMinutes <= 0 ? '' : '${d.pauseMinutes}'),
              onChanged: (String v) =>
                  _cubit.update(_draft.copyWith(pauseMinutes: TtPauseLimitField.minutesOf(v))),
            ),
          ],
        ],
      ),
    );
  }
}
