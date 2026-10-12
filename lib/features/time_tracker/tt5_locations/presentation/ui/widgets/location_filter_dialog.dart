/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: location_filter_dialog.dart
/// Purpose: Declares `LocationFilterDialog` — the Locations "Filter" popup:
///          Status (All / Active / Inactive) · Geofencing (All / Yes / No) ·
///          Reset / Apply.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Same shell as the phase-2 attendance filter (`AttendanceFilterDialog`):
/// yellow filter badge + title, fields top-aligned in pairs, Reset (grey)
/// returns `LocationsFilter.none`, Apply (yellow, Shrink) the picked values.
/// Scales in (animation standard).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationFilterDialog extends StatefulWidget {
  const LocationFilterDialog({super.key, required this.initial});

  final LocationsFilter initial;

  @override
  State<LocationFilterDialog> createState() => _LocationFilterDialogState();
}

class _LocationFilterDialogState extends State<LocationFilterDialog> {
  late LocationStatus? _status = widget.initial.status;
  late bool? _geofence = widget.initial.geofence;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtDialogHeader(title: s.filter, icon: AppAssets.filter),
          SizedBox(height: 15.h),
          TtPair(
            start: CustomDropdown<LocationStatus?>(
              label: s.timeTrackerStatus,
              hint: s.timeTrackerAll,
              height: 36,
              itemStyle: StyleText.fontSize12Weight400,
              value: _status,
              items: <DropdownItem<LocationStatus?>>[
                DropdownItem<LocationStatus?>(value: null, label: s.timeTrackerAll),
                DropdownItem<LocationStatus?>(value: LocationStatus.active, label: s.timeTrackerActive),
                DropdownItem<LocationStatus?>(value: LocationStatus.inactive, label: s.timeTrackerInactive),
              ],
              onChanged: (LocationStatus? v) => setState(() => _status = v),
            ),
            end: CustomDropdown<bool?>(
              label: s.timeTrackerGeofencing,
              hint: s.timeTrackerAll,
              height: 36,
              itemStyle: StyleText.fontSize12Weight400,
              value: _geofence,
              items: <DropdownItem<bool?>>[
                DropdownItem<bool?>(value: null, label: s.timeTrackerAll),
                DropdownItem<bool?>(value: true, label: s.yes),
                DropdownItem<bool?>(value: false, label: s.no),
              ],
              onChanged: (bool? v) => setState(() => _geofence = v),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 130.w,
                child: customButton(
                  title: s.reset,
                  function: () => Navigator.of(context).pop(LocationsFilter.none),
                  color: AppColors.secondaryAction,
                  textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
                ),
              ),
              SizedBox(
                width: 130.w,
                child: ShrinkOnTap(
                  child: customButton(
                    title: s.apply,
                    function: () => Navigator.of(context)
                        .pop(LocationsFilter(status: _status, geofence: _geofence)),
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
