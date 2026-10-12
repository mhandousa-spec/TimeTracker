/// Module: time_tracker / tt8_request_types / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_filter_dialog.dart
/// Purpose: Declares `RequestTypeFilterDialog` (+ `RequestTypeStatusChoice`)
///          — the Request Types "Filter" popup: Status (All / Active /
///          Inactive / Removed) · Reset / Apply.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Same shell as the other Time Tracker filters. "All" lists every status,
/// Removed included (owner rule). Pops a `RequestTypeStatusChoice` (its
/// `status` null = All) so "All" can be told apart from a dismissed popup.

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
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/widgets/request_type_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The popup's answer (null [status] = All).
class RequestTypeStatusChoice {
  const RequestTypeStatusChoice(this.status);

  final RequestTypeStatus? status;
}

class RequestTypeFilterDialog extends StatefulWidget {
  const RequestTypeFilterDialog({super.key, required this.initial});

  final RequestTypeStatus? initial;

  @override
  State<RequestTypeFilterDialog> createState() => _RequestTypeFilterDialogState();
}

class _RequestTypeFilterDialogState extends State<RequestTypeFilterDialog> {
  late RequestTypeStatus? _status = widget.initial;

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
          CustomDropdown<RequestTypeStatus?>(
            label: s.timeTrackerStatus,
            hint: s.timeTrackerAll,
            height: 36,
            itemStyle: StyleText.fontSize12Weight400,
            value: _status,
            items: <DropdownItem<RequestTypeStatus?>>[
              DropdownItem<RequestTypeStatus?>(value: null, label: s.timeTrackerAll),
              for (final RequestTypeStatus st in RequestTypeStatus.values)
                DropdownItem<RequestTypeStatus?>(value: st, label: RequestTypeText.status(context, st)),
            ],
            onChanged: (RequestTypeStatus? v) => setState(() => _status = v),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 130.w,
                child: customButton(
                  title: s.reset,
                  function: () => Navigator.of(context).pop(const RequestTypeStatusChoice(null)),
                  color: AppColors.secondaryAction,
                  textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
                ),
              ),
              SizedBox(
                width: 130.w,
                child: ShrinkOnTap(
                  child: customButton(
                    title: s.apply,
                    function: () => Navigator.of(context).pop(RequestTypeStatusChoice(_status)),
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
