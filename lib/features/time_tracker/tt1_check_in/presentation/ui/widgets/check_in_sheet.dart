/// Module: time_tracker / tt1_check_in / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: check_in_sheet.dart
/// Purpose: Declares `CheckInSheet` — the "Check In" popup (Work Location
///          dropdown + Start Shift) — and `LocationResultDialog` (Wrong
///          Location / location confirmed).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma: sheet `661:17263`, menu `661:17281`, Wrong Location `661:17251`,
/// Confirmed `661:17257`. Both are shown through
/// `CustomDialogManager.showContent` (core dialog shell) and scale in
/// (animation standard: dialogs = Scale); the Wrong Location dialog also
/// shakes once (an error the user must notice).
///
/// Owner form rules: dropdown items are text only; Start Shift stays
/// disabled (grey) until a location is chosen.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/check_in_options.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The check-in icon (calendar with "CHECK IN") of the Figma button.
const String kCheckInIcon = 'assets/icons_assets/home_assets/picker_check_in_out.svg';

class CheckInSheet extends StatefulWidget {
  const CheckInSheet({super.key, required this.options});

  final List<CheckInOption> options;

  @override
  State<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<CheckInSheet> {
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    // One choice only → pre-select it (nothing to decide).
    if (widget.options.length == 1) _selectedKey = widget.options.first.key;
  }

  CheckInOption? get _selected {
    for (final CheckInOption o in widget.options) {
      if (o.key == _selectedKey) return o;
    }
    return null;
  }

  String _label(BuildContext context, CheckInOption option) {
    final bool ar = context.isArabic;
    final String name = option.location == null
        ? ''
        : (ar && option.location!.nameAr.isNotEmpty
            ? option.location!.nameAr
            : option.location!.nameEn);
    return TimeTrackerFormat.placeLabel(context, option.type, officeName: name);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final CheckInOption? selected = _selected;
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsetsDirectional.all(6.r),
                child: CustomSvgImage(
                  assetPath: kCheckInIcon,
                  color: AppColors.textButton,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                s.timeTrackerCheckIn,
                style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CustomDropdown<String>(
            label: s.timeTrackerWorkLocation,
            hint: s.timeTrackerChooseWorkLocation,
            height: 36,
            itemStyle: StyleText.fontSize12Weight400,
            value: _selectedKey,
            items: <DropdownItem<String>>[
              for (final CheckInOption o in widget.options)
                DropdownItem<String>(value: o.key, label: _label(context, o)),
            ],
            onChanged: (String? key) => setState(() => _selectedKey = key),
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              width: 150.w,
              child: selected == null
                  ? customButton(
                      title: s.timeTrackerStartShift,
                      function: () {},
                      haptic: () {},
                      color: AppColors.disabledButton,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.colorGreyDark),
                    )
                  : ShrinkOnTap(
                      child: customButton(
                        title: s.timeTrackerStartShift,
                        function: () => Navigator.of(context).pop(selected),
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Wrong Location" (red pin, blocks) or "Confirmed" (green pin).
class LocationResultDialog extends StatelessWidget {
  const LocationResultDialog({
    super.key,
    required this.isMatch,
    required this.title,
    required this.body,
  });

  final bool isMatch;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final Color pin = isMatch ? AppColors.lightGreen : AppColors.red;
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 76.r,
          height: 76.r,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsetsDirectional.all(18.r),
          child: CustomSvgImage(assetPath: AppAssets.locationIcon, color: pin),
        ),
        SizedBox(height: 15.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        Text(
          body,
          textAlign: TextAlign.center,
          style: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
    return ScaleInContent(
      child: isMatch ? content : ShakeOnce(child: content),
    );
  }
}
