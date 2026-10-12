/// ************************ FILE INFO ********************************///
/// File Name: 61-custom_color_picker.dart
/// Purpose: Colour selection built on the flex_color_picker package.
///          Styled to sit alongside CustomTextField / CustomDropdown: filled
///          background, no border, 4.r radius, hint text while unset. Purely
///          presentational — it takes the current colours and reports changes,
///          so it has no controller dependency.
/// Module: core / custom
// *************************************************

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// A single colour field that opens the flex_color_picker dialog on tap.
///
/// While [color] is null the field shows [label] as a hint, exactly like an
/// empty CustomTextField. Once a colour is picked it shows a swatch plus the
/// hex code.
class CustomColorPickerField extends StatelessWidget {
  const CustomColorPickerField({
    super.key,
    required this.label,
    required this.color,
    required this.onColorSelected,
    this.dialogTitle,
    this.enabled = true,
  });

  /// Hint shown while no colour is selected, e.g. "Primary Color".
  final String label;

  /// Currently selected colour, or null when nothing has been chosen.
  final Color? color;

  /// Called with the newly picked colour. Not called if the user cancels.
  final ValueChanged<Color> onColorSelected;

  /// Optional dialog heading; defaults to [label].
  final String? dialogTitle;

  final bool enabled;

  static String hexOf(Color color) =>
      '#${(color.value & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';

  /// REBUILT 24/8/2026 — was `showColorPickerDialog(...)`.
  ///
  /// That helper draws its own chrome and gives no way to replace it: the
  /// copy / paste / ✓ / ✕ icon row across the top came from
  /// `copyPasteBehavior` + `actionButtons`, and the `0xFFRRGGBB` chip at the
  /// bottom from `showColorCode`. Both are gone now, and the only way to put
  /// the app's own `customButton` in their place is to own the dialog — so
  /// this builds an AlertDialog around the bare `ColorPicker` widget.
  ///
  /// It also fixes a real bug in the old flow: `showColorPickerDialog` returns
  /// the SEED colour when the user cancels, which is indistinguishable from
  /// deliberately re-picking that same colour. The old code papered over it
  /// with `if (color == null || picked != color)`, so cancelling on an empty
  /// field still reported a selection. Now Save and Discard are separate
  /// answers and Discard reports nothing, ever.
  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;

    // Seed the wheel with the current colour, or the app's primary when the
    // field is still empty.
    final Color start = color ?? AppColors.primary;

    // The working value. `ColorPicker` reports every change through
    // `onColorChanged`; nothing is handed back to the caller until Save.
    Color working = start;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          insetPadding:
              EdgeInsets.symmetric(horizontal: 16.sp, vertical: 24.sp),
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          title: Text(
            dialogTitle ?? label,
            style:
                StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          ),
          // BUTTON ROW 24/8/2026 — moved OUT of `actions:` into the content.
          //
          // `AlertDialog.actions` renders its children in an OverflowBar, which
          // is not a Flex: it lays each child out at its intrinsic width and
          // ignores flex entirely. A `Spacer()` between the two buttons
          // therefore did nothing and both stayed bunched at the end.
          //
          // As a plain Row inside the content, `spaceBetween` works: Discard
          // pins to the leading edge, Save to the trailing one. The picker
          // above it keeps its own scroll view, so the buttons stay put instead
          // of scrolling away with a tall wheel.
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: SingleChildScrollView(
                  child: ColorPicker(
                  color: working,
                  onColorChanged: (Color value) => working = value,
                  width: 40.sp,
                  height: 36.sp,
                  spacing: 4,
                  runSpacing: 4,
                  borderRadius: 4,
                  wheelDiameter: 190.sp,
                  // Smaller tab labels so "Primary" is not cut to "Primar"
                  // on a phone-width dialog.
                  pickerTypeTextStyle: StyleText.fontSize12Weight400,
                  enableShadesSelection: true,
                  // The hex chip at the bottom of the old dialog.
                  showColorCode: false,
                  // The copy / paste icons at the top.
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    copyButton: false,
                    pasteButton: false,
                    longPressMenu: false,
                  ),
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.both: false,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: false,
                    ColorPickerType.wheel: true,
                  },
                  // The ✓ and ✕ icons at the top. All three off — the dialog
                  // supplies its own actions below.
                    actionButtons: const ColorPickerActionButtons(
                      okButton: false,
                      closeButton: false,
                      dialogActionButtons: false,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              // Discard leading, Save trailing. Direction-aware, like every
              // other row in the app: in Arabic it mirrors along with the rest
              // of the UI, so Save stays on the reader's "forward" side.
              // Settings bug report p.15: customButton ignores `width` and
              // sizes itself, so the two fixed buttons touched each other and
              // Save ran past the dialog edge on a phone. They now share the
              // row equally with a 12 gap, so both always fit.
              Row(
                children: <Widget>[
                  Expanded(
                    child: customButton(
                      title: S.of(context).discard,
                      function: () => Navigator.of(dialogContext).pop(false),
                      color: AppColors.darkGrey,
                      fullWidth: true,
                      height: 36,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: customButton(
                      title: S.of(context).save,
                      function: () => Navigator.of(dialogContext).pop(true),
                      color: AppColors.primary,
                      fullWidth: true,
                      height: 36,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (saved == true) onColorSelected(working);
  }

  @override
  Widget build(BuildContext context) {
    final Color? value = color;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () => _pick(context),
        child: Container(
          // Same recipe as the CustomDropdown trigger (12.sp horizontal,
          // 10.sp vertical, all in .sp — 12.w/12.h scaled on the other axis
          // and made the colour fields stand taller than the font dropdowns
          // beside them).
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          // 20.sp is what the dropdown's chevron holds its content row open
          // to, so 10.sp + 20.sp + 10.sp lands on the same rendered height —
          // and the empty (hint-only) field matches the filled one, instead of
          // collapsing to the text's line height.
          child: SizedBox(
            height: 20.sp,
            child: Row(
              children: [
                if (value != null) ...[
                  Container(
                    width: 20.sp,
                    height: 20.sp,
                    decoration: BoxDecoration(
                      color: value,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: AppColors.text.withOpacity(0.15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.sp),
                ],
                Expanded(
                  child: Text(
                    value != null ? hexOf(value) : label,
                    textDirection: value != null ? TextDirection.ltr : null,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // Matches CustomTextField: real values use AppColors.text,
                    // hints drop to 40% opacity.
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: value != null
                          ? AppColors.text
                          : AppColors.text.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Colors" heading plus the primary/secondary pair — side by side on
/// tablet/desktop, stacked on phones.
class CustomColorPickerSection extends StatelessWidget {
  const CustomColorPickerSection({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onPrimaryColorSelected,
    required this.onSecondaryColorSelected,
    this.showHeading = true,
  });

  /// Null renders the field in its hint state.
  final Color? primaryColor;
  final Color? secondaryColor;
  final ValueChanged<Color> onPrimaryColorSelected;
  final ValueChanged<Color> onSecondaryColorSelected;

  /// Set false when the caller already draws its own section title.
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final Widget primary = CustomColorPickerField(

      label: S.of(context).primaryColor,
      color: primaryColor,
      onColorSelected: onPrimaryColorSelected,
    );
    final Widget secondary = CustomColorPickerField(
      label: S.of(context).secondaryColor,
      color: secondaryColor,
      onColorSelected: onSecondaryColorSelected,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeading) ...[
          Text(
            S.of(context).colors,
            style:
                StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 12.h),
        ],
        if (isVertical) ...[
          primary,
          SizedBox(height: 12.h),
          secondary,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: primary),
              SizedBox(width: 12.w),
              Expanded(child: secondary),
            ],
          ),
      ],
    );
  }
}
