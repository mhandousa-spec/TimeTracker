/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: geofence_map_picker.dart
/// Purpose: Declares `GeofenceMapPicker` — the location form's "Location On
///          Map": a short address search with the "use my location" icon
///          next to it, and a live map preview — the pin, and the geofence
///          circle drawn at the typed radius (it redraws as the number
///          changes). Tap the map to move the pin.
/// Author: Knowticed Plus team
/// Created at: 12/10/2026 (owner review L1 / S5)
///
/// The map is the app's existing `flutter_map` + OpenStreetMap tiles (as the
/// chat "share location" map) — no Google Maps API key is configured in the
/// project, so a Google map would draw blank. The address search uses the
/// device geocoder (`geocoding`, Apple / Google on the phone, no key).
/// Under `flutter test` the tiles are skipped (no network) — the pin and the
/// circle still draw on the plain map background.
/// Haptics: map tap LOW, search / my-location MEDIUM.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Where the map opens when the location has no coordinates yet (Cairo).
const LatLng _fallbackCenter = LatLng(30.0444, 31.2357);

class GeofenceMapPicker extends StatefulWidget {
  const GeofenceMapPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.showCircle,
    required this.locating,
    required this.onPoint,
    required this.onLocate,
    this.onRadius,
  });

  final double? latitude;
  final double? longitude;
  final double radiusMeters;

  /// Geofence ON → draw the circle (and the quick radius buttons).
  final bool showCircle;

  /// "Use my location" is running.
  final bool locating;

  /// A new pin (map tap or address search).
  final ValueChanged<LatLng> onPoint;
  final VoidCallback onLocate;

  /// A quick radius button (100 / 250 / 500 / 1000 m); null = no buttons.
  final ValueChanged<int>? onRadius;

  /// Quick radius choices, in meters.
  static const List<int> quickRadii = <int>[100, 250, 500, 1000];

  @override
  State<GeofenceMapPicker> createState() => _GeofenceMapPickerState();
}

class _GeofenceMapPickerState extends State<GeofenceMapPicker> {
  final MapController _map = MapController();
  final TextEditingController _query = TextEditingController();
  bool _ready = false;
  bool _searching = false;
  bool _notFound = false;

  /// Real tiles only on a device (a widget test has no network).
  static final bool _tiles = !Platform.environment.containsKey('FLUTTER_TEST');

  LatLng? get _point {
    final double? lat = widget.latitude;
    final double? lng = widget.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  void dispose() {
    _query.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GeofenceMapPicker old) {
    super.didUpdateWidget(old);
    if (old.latitude != widget.latitude ||
        old.longitude != widget.longitude ||
        old.radiusMeters != widget.radiusMeters ||
        old.showCircle != widget.showCircle) {
      _frame();
    }
  }

  /// Fit the camera to the circle (or centre on the pin).
  void _frame() {
    final LatLng? p = _point;
    if (!_ready || p == null) return;
    final double r = widget.radiusMeters;
    if (widget.showCircle && r > 0) {
      const Distance d = Distance();
      final LatLng north = d.offset(p, r, 0);
      final LatLng south = d.offset(p, r, 180);
      final LatLng east = d.offset(p, r, 90);
      final LatLng west = d.offset(p, r, 270);
      _map.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(<LatLng>[north, south, east, west]),
        padding: EdgeInsets.all(24.r),
        maxZoom: 18,
      ));
    } else {
      _map.move(p, 16);
    }
  }

  Future<void> _search() async {
    final String q = _query.text.trim();
    if (q.isEmpty || _searching) return;
    HapticController.medium();
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _notFound = false;
    });
    List<Location> found = const <Location>[];
    try {
      found = await Geocoding().locationFromAddress(q);
    } catch (_) {
      found = const <Location>[];
    }
    if (!mounted) return;
    setState(() {
      _searching = false;
      _notFound = found.isEmpty;
    });
    if (found.isNotEmpty) widget.onPoint(LatLng(found.first.latitude, found.first.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LatLng? p = _point;
    final double r = widget.radiusMeters;
    final bool circle = widget.showCircle && r > 0 && p != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(s.timeTrackerGeofencePreview, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: CustomTextField(
                key: const ValueKey<String>('geofenceSearchField'),
                controller: _query,
                hint: s.timeTrackerSearchAddress,
                height: 36,
                hideCounter: true,
                textInputAction: TextInputAction.search,
                prefixIcon: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w),
                  child: _searching
                      ? SizedBox(width: 16.r, height: 16.r, child: const CircleProgressMaster())
                      : Icon(Icons.search, size: 18.r, color: AppColors.secondaryText),
                ),
                valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
                onSubmitted: (_) => _search(),
              ),
            ),
            SizedBox(width: 10.w),
            // Owner S5: "use my current location" is an ICON next to the
            // search (not a whole row).
            Semantics(
              button: true,
              label: s.timeTrackerUseMyLocation,
              child: ShrinkOnTap(
                child: GestureDetector(
                  key: const ValueKey<String>('locationUseMyLocation'),
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.locating
                      ? null
                      : () {
                          HapticController.medium();
                          widget.onLocate();
                        },
                  child: Container(
                    width: 36.sp,
                    height: 36.sp,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(ButtonSizing.radius),
                    ),
                    child: widget.locating
                        ? SizedBox(width: 16.r, height: 16.r, child: const CircleProgressMaster())
                        : Icon(Icons.my_location, size: 18.r, color: AppColors.textButton),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_notFound) ...<Widget>[
          SizedBox(height: 4.h),
          Text(s.timeTrackerAddressNotFound,
              key: const ValueKey<String>('geofenceNotFound'),
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
        ],
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: CardStyles.radius(),
          child: SizedBox(
            key: const ValueKey<String>('geofenceMap'),
            height: context.isPhone ? 220.h : 280.h,
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: p ?? _fallbackCenter,
                    initialZoom: p == null ? 11 : 16,
                    backgroundColor: AppColors.background,
                    onMapReady: () {
                      _ready = true;
                      _frame();
                    },
                    onTap: (TapPosition _, LatLng point) {
                      HapticController.low();
                      widget.onPoint(point);
                    },
                  ),
                  children: <Widget>[
                    if (_tiles)
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ensightvision',
                        maxNativeZoom: 19,
                      ),
                    if (circle)
                      CircleLayer(
                        circles: <CircleMarker>[
                          CircleMarker(
                            point: p,
                            radius: r,
                            useRadiusInMeter: true,
                            color: AppColors.primary.withValues(alpha: 0.22),
                            borderColor: AppColors.primary,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    if (p != null)
                      MarkerLayer(
                        markers: <Marker>[
                          Marker(
                            point: p,
                            width: 36.r,
                            height: 36.r,
                            alignment: Alignment.topCenter,
                            child: Icon(Icons.location_on, size: 36.r, color: AppColors.red),
                          ),
                        ],
                      ),
                  ],
                ),
                if (circle)
                  PositionedDirectional(
                    start: 8.w,
                    bottom: 8.h,
                    child: Container(
                      key: const ValueKey<String>('geofenceRadiusBadge'),
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(ButtonSizing.radius),
                      ),
                      child: Text(
                        s.timeTrackerMetersValue(LocalizedNumber.of(context, r.round())),
                        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(s.timeTrackerTapMapHint, style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText)),
        if (widget.showCircle && widget.onRadius != null) ...<Widget>[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              for (final int m in GeofenceMapPicker.quickRadii)
                _RadiusChip(
                  key: ValueKey<String>('geofenceQuickRadius_$m'),
                  label: s.timeTrackerMetersValue(LocalizedNumber.of(context, m)),
                  selected: r.round() == m,
                  onTap: () {
                    HapticController.low();
                    widget.onRadius!(m);
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A quick radius choice ("500 m"); yellow when it is the current radius.
class _RadiusChip extends StatelessWidget {
  const _RadiusChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(ButtonSizing.radius),
        ),
        child: Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: selected ? AppColors.textButton : AppColors.text,
          ),
        ),
      ),
    );
  }
}
