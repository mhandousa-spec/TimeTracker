/// Module: time_tracker / tt6_employees / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employees_filter_dialog.dart
/// Purpose: Declares `EmployeesFilterDialog` — the Employees "Filter" popup
///          (Assigned list): Location (All / one location) · Reset / Apply.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Not drawn in Figma; same shell as the other Time Tracker filters. Pops
/// the chosen location id ('' = all). Scales in.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeesFilterDialog extends StatefulWidget {
  const EmployeesFilterDialog({super.key, required this.initial, required this.locations});

  final String initial;
  final List<WorkLocation> locations;

  @override
  State<EmployeesFilterDialog> createState() => _EmployeesFilterDialogState();
}

class _EmployeesFilterDialogState extends State<EmployeesFilterDialog> {
  late String _location = widget.initial;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtDialogHeader(title: s.filter, icon: AppAssets.filter),
          SizedBox(height: 15.h),
          CustomDropdown<String>(
            label: s.timeTrackerLocation,
            hint: s.timeTrackerAll,
            height: 36,
            itemStyle: StyleText.fontSize12Weight400,
            value: _location,
            items: <DropdownItem<String>>[
              DropdownItem<String>(value: '', label: s.timeTrackerAll),
              for (final WorkLocation l in widget.locations)
                if (l.status != LocationStatus.deleted)
                  DropdownItem<String>(value: l.id, label: l.name(isArabic: ar)),
            ],
            onChanged: (String v) => setState(() => _location = v),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 130.w,
                child: customButton(
                  title: s.reset,
                  function: () => Navigator.of(context).pop(''),
                  color: AppColors.secondaryAction,
                  textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
                ),
              ),
              SizedBox(
                width: 130.w,
                child: ShrinkOnTap(
                  child: customButton(
                    title: s.apply,
                    function: () => Navigator.of(context).pop(_location),
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
