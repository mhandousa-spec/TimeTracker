/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_setup_widgets.dart
/// Purpose: Declares the small building blocks shared by the phase-3 set-up
///          screens (Locations, Employees, Groups, Request Types):
///          `TimeTrackerAvatar`, `TtFormCard`, `TtPair`, `TtSwitchRow`,
///          `TtBreakLengthField`, `TtRemovableChip`, `TtToolbarButton`,
///          `TtDialogHeader`, `TimeTrackerFormActions`,
///          `showTimeTrackerFailure` and `refreshingCheckIn`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// All built on core widgets (`CustomTextField`, `CustomDropdown`,
/// `DefaultSwitchButton`, `customButton`, `customButtonWithSvg`,
/// `CustomDialogManager`). Owner rules (playbook §4b): side-by-side fields
/// top-aligned (an error never misaligns the row), chips one height radius 8,
/// primary button grey until valid (tap reveals the errors), 15 padding,
/// typeable numbers, Arabic without tanween. Haptics: low on switches /
/// toolbar toggles, medium on yellow buttons, high on removing a chip.
/// Updated: 9/10/2026 - code review: [showTimeTrackerFailure] `failure`
/// (changed meanwhile / no vacation balance); the chip's remove icon is the
/// app's `minus_circle_red.svg` (was `Icons.remove_circle`).
/// Updated: 9/10/2026 - UI quality pass: `TtStatusSwitch` (status inside
/// the Edit form, Figma 661:44042) and `TtDeleteButton` (red + white).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

const String _defaultAvatar = 'assets/icons_assets/main_icons_assets/male_avatar.png';

/// Round employee photo (network URL, asset path, or the default avatar).
class TimeTrackerAvatar extends StatelessWidget {
  const TimeTrackerAvatar({super.key, required this.photo, this.size});

  final String photo;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double s = size ?? 44.r;
    final Widget fallback = Image.asset(_defaultAvatar, width: s, height: s, fit: BoxFit.cover);
    final Widget image = photo.startsWith('http')
        ? Image.network(photo, width: s, height: s, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback)
        : Image.asset(photo.isEmpty ? _defaultAvatar : photo, width: s, height: s,
            fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback);
    return ClipOval(child: SizedBox(width: s, height: s, child: image));
  }
}

/// The white form / details card (15 padding, house radius).
class TtFormCard extends StatelessWidget {
  const TtFormCard({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      padding: EdgeInsetsDirectional.all(15.r),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
      child: child,
    );
    final String? heading = title;
    if (heading == null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: 8.h),
          child: Text(heading,
              style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
        ),
        card,
      ],
    );
  }
}

/// Two fields side by side, TOP-aligned (stacked on phone).
class TtPair extends StatelessWidget {
  const TtPair({super.key, required this.start, this.end});

  final Widget start;
  final Widget? end;

  @override
  Widget build(BuildContext context) {
    final Widget? second = end;
    if (context.isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[start, if (second != null) ...<Widget>[SizedBox(height: 15.h), second]],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: start),
        SizedBox(width: 15.w),
        Expanded(child: second ?? const SizedBox.shrink()),
      ],
    );
  }
}

/// "Allow Pause ⬤" — a label and the core switch (low haptic).
class TtSwitchRow extends StatelessWidget {
  const TtSwitchRow({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label,
              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        ),
        DefaultSwitchButton(
          value: value,
          onChanged: (bool v) {
            HapticController.low();
            onChanged(v);
          },
        ),
      ],
    );
  }
}

/// ADDED 9/10/2026 (UI quality pass — owner 13:45 #8, Figma `661:44042`):
/// the "〰 Active ⬤" status switch at the TOP END of an Edit form (locations,
/// request types). The status lives inside the Edit form, not on the details
/// page header. LOW haptic.
class TtStatusSwitch extends StatelessWidget {
  const TtStatusSwitch({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomSvgImage(assetPath: TtAssets.status, width: 16.r, height: 16.r, color: AppColors.text),
          SizedBox(width: 6.w),
          Text(label, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text)),
          SizedBox(width: 10.w),
          DefaultSwitchButton(
            value: value,
            onChanged: (bool v) {
              HapticController.low();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

/// ADDED 9/10/2026 (UI quality pass — owner 13:45 #7): the destructive
/// house style for every Delete / Remove button of a details page — RED
/// background, WHITE trash + text (the core `CustomDeleteIcon` defaults to
/// yellow). HIGH haptic comes from the core widget.
class TtDeleteButton extends StatelessWidget {
  const TtDeleteButton({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomDeleteIcon(
      title: title,
      onTap: onTap,
      color: AppColors.red,
      svgColor: AppColors.white,
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
    );
  }
}

/// Break length unit of [TtBreakLengthField].
enum TtDurationUnit { minutes, hours }

/// "30 | Mins ▾" — a typeable number and its unit (Figma `661:39468`).
class TtBreakLengthField extends StatelessWidget {
  const TtBreakLengthField({
    super.key,
    required this.controller,
    required this.unit,
    required this.onChanged,
    required this.onUnitChanged,
    this.error,
  });

  final TextEditingController controller;
  final TtDurationUnit unit;
  final ValueChanged<String> onChanged;
  final ValueChanged<TtDurationUnit> onUnitChanged;
  final String? error;

  /// Minutes for [text] in [unit] (0 when blank / unreadable).
  static int minutesOf(String text, TtDurationUnit unit) {
    final int n = int.tryParse(text.trim()) ?? 0;
    return unit == TtDurationUnit.hours ? n * 60 : n;
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: CustomTextField(
            controller: controller,
            hint: s.timeTrackerBreakLengthHint,
            height: 36,
            errorText: error,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 2,
          child: CustomDropdown<TtDurationUnit>(
            value: unit,
            height: 36,
            itemStyle: StyleText.fontSize12Weight400,
            items: <DropdownItem<TtDurationUnit>>[
              DropdownItem<TtDurationUnit>(value: TtDurationUnit.minutes, label: s.timeTrackerUnitMins),
              DropdownItem<TtDurationUnit>(value: TtDurationUnit.hours, label: s.timeTrackerUnitHours),
            ],
            onChanged: onUnitChanged,
          ),
        ),
      ],
    );
  }
}

/// ADDED 9/10/2026 (approved schema `Allowed_Pause_Minutes`): the longest
/// pause in minutes — empty / 0 = no limit (passing it is reported by the
/// Cloud Functions; the pause keeps running).
class TtPauseLimitField extends StatelessWidget {
  const TtPauseLimitField({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Function Name: [minutesOf]
  ///
  /// Purpose: The typed minutes (empty / invalid = 0 = no limit).
  ///
  /// Return type: [int]
  static int minutesOf(String text) {
    final int n = int.tryParse(text.trim()) ?? 0;
    return n < 0 ? 0 : n;
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return CustomTextField(
      controller: controller,
      label: s.timeTrackerMaxPauseMinutes,
      labelStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
      hint: s.timeTrackerNoLimit,
      height: 36,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      onChanged: onChanged,
    );
  }
}

/// A selected value with a red ⊖ (radius 8, one height).
class TtRemovableChip extends StatelessWidget {
  const TtRemovableChip({super.key, required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? remove = onRemove;
    return Container(
      height: 30.h,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadiusDirectional.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text)),
          if (remove != null) ...<Widget>[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () {
                HapticController.high();
                remove();
              },
              child: CustomSvgImage(assetPath: TtAssets.minusCircle, width: 16.r, height: 16.r),
            ),
          ],
        ],
      ),
    );
  }
}

/// Yellow toolbar button with an icon (icon-only on phone).
class TtToolbarButton extends StatelessWidget {
  const TtToolbarButton({super.key, required this.title, required this.icon, required this.onTap, this.iconSize});

  final String title;
  final String icon;
  final VoidCallback onTap;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return ShrinkOnTap(
      child: customButtonWithSvg(
        title: context.isPhone ? '' : title,
        function: onTap,
        color: AppColors.primary,
        colorBorder: AppColors.transparent,
        image: icon,
        widthImage: iconSize ?? 18.r,
        heightImage: iconSize ?? 18.r,
        svgColor: AppColors.textButton,
        textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
      ),
    );
  }
}

/// Dialog header: a yellow circle with an icon + the title.
class TtDialogHeader extends StatelessWidget {
  const TtDialogHeader({super.key, required this.title, this.icon = AppAssets.edit});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 30.r,
          height: 30.r,
          padding: EdgeInsetsDirectional.all(7.r),
          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: CustomSvgImage(assetPath: icon, color: AppColors.textButton),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(title,
              style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
        ),
      ],
    );
  }
}

/// Grey Discard (start) · yellow primary (end, grey until [canSubmit]).
class TimeTrackerFormActions extends StatelessWidget {
  const TimeTrackerFormActions({
    super.key,
    required this.primaryTitle,
    required this.canSubmit,
    required this.onDiscard,
    required this.onSubmit,
    required this.onDisabledTap,
    this.primaryKey,
  });

  final String primaryTitle;
  final bool canSubmit;
  final VoidCallback onDiscard;
  final VoidCallback onSubmit;
  final VoidCallback onDisabledTap;
  final Key? primaryKey;

  @override
  Widget build(BuildContext context) {
    final Widget discard = customButton(
      title: S.of(context).discard,
      function: onDiscard,
      color: AppColors.secondaryAction,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
    );
    final Widget primary = KeyedSubtree(
      key: primaryKey,
      child: canSubmit
          ? ShrinkOnTap(
              child: customButton(
                title: primaryTitle,
                function: onSubmit,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
              ),
            )
          : customButton(
              title: primaryTitle,
              function: onDisabledTap,
              haptic: () {},
              color: AppColors.disabledButton,
              textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.colorGreyDark),
            ),
    );
    if (context.isPhone) {
      return Row(children: <Widget>[
        Expanded(child: discard),
        SizedBox(width: 15.w),
        Expanded(child: primary),
      ]);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(width: 150.w, child: discard),
        SizedBox(width: 150.w, child: primary),
      ],
    );
  }
}

/// Function Name: [showTimeTrackerFailure]
///
/// Purpose: The house warning after a failed save: "no permission" or
/// "could not be saved" — since 9/10/2026 also "changed by someone else"
/// and "no vacation balance" when [failure] says so.
///
/// Return type: [Future<void>]
Future<void> showTimeTrackerFailure(
  BuildContext context, {
  required bool denied,
  TimeTrackerActionFailure? failure,
  // 9/10/2026 (owner round 9 b): a ready message ("2027 has only 2 days left").
  String? message,
}) {
  final S s = S.of(context);
  final String subtitle = message ??
      switch (failure) {
        TimeTrackerActionFailure.changed => s.timeTrackerRequestChangedMeanwhile,
        TimeTrackerActionFailure.noBalance => s.timeTrackerNoBalanceApprover,
        _ => denied ? s.timeTrackerNoPermission : s.timeTrackerActionFailed,
      };
  return CustomDialogManager.showMessage(
    context: context,
    lottiePath: AppAssets.lottieWarning,
    title: s.errorOccurred,
    subtitle: subtitle,
  );
}

/// Function Name: [refreshingCheckIn]
///
/// Purpose: Wrap a set-up save so that, when it succeeds, the signed-in
/// user's Check In control reloads its work set-up (a location / assignment
/// / group change may concern them — e.g. "assign myself, then check in").
/// The cubit is read BEFORE the save (no context across the async gap).
///
/// Return type: [Future<bool> Function()] — for `showDialogFlow.onConfirm`.
Future<bool> Function() refreshingCheckIn(
  BuildContext context,
  Future<bool> Function() save,
) {
  final CheckInCubit? checkIn =
      GetIt.instance<TimeTrackerAccess>().canCheckInAndOut ? context.read<CheckInCubit>() : null;
  return () async {
    final bool ok = await save();
    if (ok) checkIn?.init();
    return ok;
  };
}
