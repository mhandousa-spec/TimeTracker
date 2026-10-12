/// Module: todo / t2_todo_form / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_actions.dart
/// Purpose: Declares `TodoFormActions` — the grey Discard / Discard Changes
///          button at the start and the yellow Create / Save at the end.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma: 150 × 38 on tablet, radius 8. On phone the two buttons split the
/// row (Expanded) and every label stays on ONE line in EN and AR — if it is
/// still too wide its font scales down (fix 7/10/2026). `customButton`
/// fires the Medium haptic itself (Discard and Create are both Medium), so
/// nothing here adds another.
///
/// Owner rules (7/10/2026): Create / Save stays DISABLED — grey, no haptic,
/// no shrink, never submits — until [canSubmit] (every required field valid
/// and, when editing, something changed). Then it turns yellow. Tapping the
/// disabled button calls [onDisabledTap] so the page can reveal which
/// required fields are missing.
///
/// Disabled colours are readable in BOTH themes: the fill is the constant
/// `AppColors.disabledButton` (#CCCCCC) and the text the constant
/// `AppColors.colorGreyDark` (#6F6F6F, ≈3.1:1). The old `secondaryText` text
/// is #CCCCCC in dark mode — the same as the fill, i.e. invisible.
/// Discard uses the app-wide secondary pair (`secondaryAction` /
/// `onSecondaryAction`: #D9D9D9 + #2D2D2D light, #A6A6A6 + white dark).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_controls.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoFormActions extends StatelessWidget {
  const TodoFormActions({
    super.key,
    required this.isEdit,
    required this.canSubmit,
    required this.onDiscard,
    required this.onSubmit,
    required this.onDisabledTap,
  });

  final bool isEdit;

  /// From `TodoFormState.canSubmit`.
  final bool canSubmit;
  final VoidCallback onDiscard;
  final VoidCallback onSubmit;

  /// Tap on the DISABLED Create / Save — shows the missing fields; never
  /// submits.
  final VoidCallback onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final bool isPhone = todoFormIsPhone(context);
    final S s = S.of(context);
    final Widget discard = _OneLineButton(
      title: isEdit ? s.discardChanges : s.discard,
      onTap: onDiscard,
      fill: AppColors.secondaryAction,
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.onSecondaryAction),
    );
    final Widget submit = canSubmit
        ? ShrinkOnTap(
            child: _OneLineButton(
              title: isEdit ? s.save : s.create,
              onTap: onSubmit,
              fill: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
            ),
          )
        : _OneLineButton(
            title: isEdit ? s.save : s.create,
            onTap: onDisabledTap,
            haptic: _noHaptic,
            fill: AppColors.disabledButton,
            textStyle: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.colorGreyDark),
          );

    // Phone: the two buttons share the row (bug 7/10/2026: a fixed 135 wide
    // "Discard Changes" wrapped onto two lines). Tablet keeps Figma's 150.
    if (isPhone) {
      return Row(
        children: <Widget>[
          Expanded(child: discard),
          SizedBox(width: 15.sp),
          Expanded(child: submit),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(width: 150.sp, child: discard),
        SizedBox(width: 150.sp, child: submit),
      ],
    );
  }
}

/// A core `customButton` that fills the width its parent gives it and keeps
/// its label on ONE line in every language: when the label is wider than the
/// button, the font is scaled down just enough to fit (height stays 38).
class _OneLineButton extends StatelessWidget {
  const _OneLineButton({
    required this.title,
    required this.onTap,
    required this.fill,
    required this.textStyle,
    this.haptic = HapticController.medium,
  });

  final String title;
  final VoidCallback onTap;
  final Color fill;
  final TextStyle textStyle;
  final VoidCallback haptic;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        return customButton(
          title: title,
          function: onTap,
          haptic: haptic,
          width: width,
          color: fill,
          textStyle: _fitted(context, width - 2 * 8.sp),
        );
      },
    );
  }

  /// [textStyle], shrunk proportionally when [title] would not fit [room].
  TextStyle _fitted(BuildContext context, double room) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: title, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final double needed = painter.width;
    painter.dispose();
    final double? size = textStyle.fontSize;
    if (size == null || room <= 0 || needed <= room) return textStyle;
    return textStyle.copyWith(fontSize: size * room / needed * 0.98);
  }
}

/// The disabled button stays silent.
void _noHaptic() {}
