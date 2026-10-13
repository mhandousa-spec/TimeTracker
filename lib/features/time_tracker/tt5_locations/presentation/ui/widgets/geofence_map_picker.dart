/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: geofence_map_picker.dart
/// Purpose: Declares `GeofenceMapPicker` — the location form's "Location On
///          Map": an address search with the "use my location" button next
///          to it, a Map / Satellite switch, and a live map preview — the
///          pin, and the geofence circle drawn at the typed radius (it
///          redraws as the number changes). Tap the map to move the pin.
/// Author: Knowticed Plus team
/// Created at: 12/10/2026 (owner review L1 / S5)
///
/// Updated: 13/10/2026 - owner: core customs ONLY — the search is the core
/// search bar (`TtSearchField` → `AppSearchTextField` 35), my-location the
/// core icon button (`customButtonWithSvg` 6), Map / Satellite and the quick
/// radius the core segmented control (`TtSegmentedToggle` →
/// `CustomSegmentedTabs` 9), the pin `CustomSvgImage` 32, the spinner
/// `CircleProgressMaster` 66. "Satellite" shows the real buildings and
/// places from above (Esri World Imagery + place labels — free, no key).
///
/// The map is the app's existing `flutter_map` (as the chat "share location"
/// map) — no Google Maps API key is configured in the project, so a Google
/// map would draw blank. The address search uses the device geocoder
/// (`geocoding`, Apple / Google on the phone, no key). Under `flutter test`
/// the tiles are skipped (no network) — the pin and the circle still draw.
/// Haptics: map tap LOW, search / my-location MEDIUM.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
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
  }) : readOnly = false;

  /// 13/10/2026 (owner S4): the Location details' map — the pin and the
  /// geofence circle with the Satellite / Map switch only (no search, no
  /// "use my location", taps do nothing).
  const GeofenceMapPicker.preview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.showCircle,
  })  : locating = false,
        onPoint = _noPoint,
        onLocate = _noLocate,
        onRadius = null,
        readOnly = true;

  static void _noPoint(LatLng _) {}
  static void _noLocate() {}

  final bool readOnly;

  final double? latitude;
  final double? longitude;
  final double radiusMeters;

  /// Geofence ON → draw the circle (and the quick radius choices).
  final bool showCircle;

  /// "Use my location" is running.
  final bool locating;

  /// A new pin (map tap or address search).
  final ValueChanged<LatLng> onPoint;
  final VoidCallback onLocate;

  /// A quick radius choice (100 / 250 / 500 / 1000 m); null = none.
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

  /// 13/10/2026 (owner): the satellite view shows the real buildings.
  bool _satellite = true;

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
      _map.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(<LatLng>[
          d.offset(p, r, 0),
          d.offset(p, r, 90),
          d.offset(p, r, 180),
          d.offset(p, r, 270),
        ]),
        padding: EdgeInsets.all(24.r),
        maxZoom: 18,
      ));
    } else {
      _map.move(p, 17);
    }
  }

  Future<void> _search(String text) async {
    final String q = text.trim();
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

  List<Widget> _tileLayers() {
    if (!_tiles) return const <Widget>[];
    if (!_satellite) {
      return <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ensightvision',
          maxNativeZoom: 19,
        ),
      ];
    }
    return <Widget>[
      TileLayer(
        urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        userAgentPackageName: 'com.ensightvision',
        maxNativeZoom: 19,
      ),
      // Street and place names over the photo.
      TileLayer(
        urlTemplate:
            'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
        userAgentPackageName: 'com.ensightvision',
        maxNativeZoom: 19,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LatLng? p = _point;
    final double r = widget.radiusMeters;
    final bool circle = widget.showCircle && r > 0 && p != null;
    final int quick = GeofenceMapPicker.quickRadii.indexOf(r.round());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!widget.readOnly) ...<Widget>[
        Text(s.timeTrackerGeofencePreview, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            // Core search bar (self-Expanded in a Row).
            TtSearchField(
              key: const ValueKey<String>('geofenceSearchField'),
              controller: _query,
              hint: s.timeTrackerSearchAddress,
              fillColor: AppColors.background,
              onChanged: (_) {
                if (_notFound) setState(() => _notFound = false);
              },
              onSubmitted: _search,
              suffixIcon: _searching
                  ? Padding(
                      padding: EdgeInsets.all(10.r),
                      child: SizedBox(width: 16.r, height: 16.r, child: const CircleProgressMaster()),
                    )
                  : null,
            ),
            SizedBox(width: 10.w),
            // Owner S5: "use my current location" is the core icon button
            // next to the search (not a whole row).
            Semantics(
              button: true,
              label: s.timeTrackerUseMyLocation,
              child: KeyedSubtree(
                key: const ValueKey<String>('locationUseMyLocation'),
                child: widget.locating
                    ? SizedBox(width: 38.sp, height: 38.sp, child: const Center(child: CircleProgressMaster()))
                    : ShrinkOnTap(
                        child: customButtonWithSvg(
                          title: '',
                          function: widget.onLocate,
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: TtAssets.location,
                          widthImage: TtToolbar.iconSize,
                          heightImage: TtToolbar.iconSize,
                          svgColor: AppColors.textButton,
                          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
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
        ],
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TtSegmentedToggle(
            key: const ValueKey<String>('geofenceMapStyle'),
            tabs: <String>[s.timeTrackerSatelliteView, s.timeTrackerMapView],
            tabKeys: const <Key>[ValueKey<String>('geofenceSatellite'), ValueKey<String>('geofenceStreetMap')],
            compact: true,
            selectedIndex: _satellite ? 0 : 1,
            onChanged: (int i) => setState(() => _satellite = i == 0),
          ),
        ),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: CardStyles.radius(),
          child: SizedBox(
            key: const ValueKey<String>('geofenceMap'),
            height: context.isPhone ? 240.h : 320.h,
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: p ?? _fallbackCenter,
                initialZoom: p == null ? 11 : 17,
                backgroundColor: AppColors.background,
                // Preview: zoom only — a drag scrolls the page, not the map.
                interactionOptions: widget.readOnly
                    ? const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom)
                    : const InteractionOptions(),
                onMapReady: () {
                  _ready = true;
                  _frame();
                },
                onTap: widget.readOnly
                    ? null
                    : (TapPosition _, LatLng point) {
                        HapticController.low();
                        widget.onPoint(point);
                      },
              ),
              children: <Widget>[
                ..._tileLayers(),
                if (circle)
                  CircleLayer(
                    circles: <CircleMarker>[
                      CircleMarker(
                        point: p,
                        radius: r,
                        useRadiusInMeter: true,
                        color: AppColors.primary.withValues(alpha: 0.25),
                        borderColor: AppColors.primary,
                        borderStrokeWidth: 2.5,
                      ),
                    ],
                  ),
                if (p != null)
                  MarkerLayer(
                    markers: <Marker>[
                      Marker(
                        point: p,
                        width: 34.r,
                        height: 34.r,
                        alignment: Alignment.topCenter,
                        child: TtIcon(const TtGlyph.svg(TtAssets.location), size: 34.r, color: AppColors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (!widget.readOnly) ...<Widget>[
          SizedBox(height: 6.h),
          Text(s.timeTrackerTapMapHint, style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText)),
        ],
        if (widget.showCircle && widget.onRadius != null) ...<Widget>[
          SizedBox(height: 10.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TtSegmentedToggle(
              key: const ValueKey<String>('geofenceQuickRadius'),
              tabs: <String>[
                for (final int m in GeofenceMapPicker.quickRadii)
                  s.timeTrackerMetersValue(LocalizedNumber.of(context, m)),
              ],
              tabKeys: <Key>[
                for (final int m in GeofenceMapPicker.quickRadii) ValueKey<String>('geofenceQuickRadius_$m'),
              ],
              compact: true,
              selectedIndex: quick,
              onChanged: (int i) => widget.onRadius!(GeofenceMapPicker.quickRadii[i]),
            ),
          ),
        ],
      ],
    );
  }
}
