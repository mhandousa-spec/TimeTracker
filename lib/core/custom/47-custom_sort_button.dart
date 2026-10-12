/// Module: Core · Custom · Sort Button
/// Description: Reusable generic sort button with dropdown, extracted from
///              SortDropdownWidgetRole (account_status/search_and_filter).
///              When an item is selected the WHOLE container turns
///              AppColors.primary and the svg + text turn
///              AppColors.textButton. The selected menu item is highlighted
///              with a primary background as well.
/// Author: Knowticed Team
/// Date: 06/07/2026
/// Dependencies: CustomDropdown (1-custom_dropdown.dart), flutter_screenutil,
///               AppColors, StyleText, ButtonSizing, CustomSvgImage.
///
/// Revision History:
///   16/8/2026 — the trigger now keeps its own label ("Sort") after a selection
///   instead of being overwritten by the selected option; text comes from
///   `StyleText`; the icon is an explicit 20.sp and the prefix/suffix paddings
///   are tightened, so the button matches the height and rhythm of the Filter
///   button beside it.
///   16/8/2026 — icon and label are CENTRED as one pair rather than starting at
///   the leading edge, and the label is 12.sp. Both come from the trigger no
///   longer using InputDecorator's hint, which is start-anchored and sized to
///   whatever the prefix icon leaves; the pair is now a single centred Row in
///   the prefix slot, the same shape `CustomFilterIcon` uses. NOTHING about the
///   button's size changed with it — same `SizedBox`, same trigger padding.
///   16/8/2026 — the dead space on the RIGHT of the label is gone. Two things
///   were holding it open, and both had to go: `InputDecorator` applies
///   `contentPadding` to the INPUT area, which sits AFTER the prefix — so the
///   trigger's 8+8 horizontal padding was 16pt of empty input, not padding
///   around the button's content — and the suffix slot was still being built
///   even though a zero-width box was passed to it. The trigger's horizontal
///   padding is now 0 (the 8pt gutter moved INSIDE the prefix, where it
///   belongs) and `CustomDropdown.showSuffixIcon: false` drops the suffix
///   entirely, so the icon+label pair is centred in the WHOLE button.
///   12/9/2026 — the default size now follows [ButtonSizing]: 38.sp square
///   on phone, 135.sp x 38.sp otherwise (was a flat 70.sp wide at every
///   size, so it never lined up with the buttons next to it). An explicit
///   `width` / `height` still wins, so existing call sites are unchanged.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class CustomSortButton<T> extends StatelessWidget {
  static const String _defaultSvg =
      'assets/icons_assets/main_icons_assets/sort_lines.svg';

  /// Currently selected item (null = nothing selected → neutral colors).
  final T? value;

  /// Items shown in the dropdown menu.
  final List<T> items;

  /// Builds the display label of each item.
  final String Function(T item) labelBuilder;

  final ValueChanged<T?> onChanged;

  /// Button label. Hidden when [showTitle] is false (e.g. icon-only on mobile).
  ///
  /// Null (the default) resolves to `S.of(context).sort` at build time, so a
  /// caller that omits it gets "Sort"/"ترتيب" rather than the English literal
  /// this used to default to — which is how the GRC page shipped a hardcoded
  /// "Sort" into the Arabic UI. Pass a value only for a button that sorts
  /// something by a different name.
  final String? title;
  final bool showTitle;

  final String svgPath;
  final double? width, height;

  /// Kept for source compatibility. [CustomDropdown] sizes its overlay to the
  /// trigger, so set [width] instead — this value is ignored.
  final double? menuWidth;

  /// Gap between the trigger and the overlay.
  ///
  /// CHANGED 21/9/2026 — 16 → 2, the same gap CustomDropdown uses. 16 left a
  /// visible empty band between the Sort button and its menu.
  final double yOffset;

  /// ADDED 16/9/2026. Container colour while nothing is selected. Defaults
  /// to AppColors.card; a button sitting ON a card (the GRC dashboard chart
  /// headers) passes AppColors.background so it does not vanish into it.
  final Color? unselectedFillColor;

  /// ADDED 16/9/2026. Corner radius; defaults to 8.r as before.
  final BorderRadius? borderRadius;

  const CustomSortButton({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.title,
    this.showTitle = true,
    this.svgPath = _defaultSvg,
    this.width,
    this.height,
    this.menuWidth,
    this.yOffset = 2,
    this.unselectedFillColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Two states, and only two:
    //
    //   nothing selected  container AppColors.card,
    //                     icon + label AppColors.secondaryText at 50% —
    //                     it reads as available, not as active
    //   something selected  container AppColors.primary,
    //                       icon + label AppColors.textButton
    //
    // Tapping the active row again deselects (see `onChanged` at the bottom of
    // this build), which returns the button to the first state.
    //
    // The unselected container was AppColors.field, which on a toolbar sits on
    // the same fill as the search box beside it, and the unselected content was
    // full-strength secondaryText.
    final bool hasSelection = value != null;
    // Unselected content uses the app's dropdown hint colour, so the Sort
    // label reads the same grey as the dropdown placeholders beside it
    // (CHANGED 16/9/2026, was secondaryText at 50%).
    final Color contentColor =
        hasSelection ? AppColors.textButton : kDropdownHintColor;

    // App-wide button sizing: a 38.sp square on phone, 135.sp x 38.sp
    // everywhere else — the same pair `customButton` / `customButtonWithSvg`
    // get from [ButtonSizing], so a Sort button sits flush with the Filter and
    // Create buttons beside it on a toolbar. It was a flat 70.sp, which
    // matched neither.
    //
    // Read straight off [ButtonSizing.isMobile] rather than calling
    // [ButtonSizing.width]: that helper measures the label and returns null
    // (hug the text) when it does not fit, and this button needs a definite
    // width for its prefix slot, which spans the whole trigger.
    final double buttonWidth = width ??
        (ButtonSizing.isMobile(context)
            ? ButtonSizing.iconButtonSize
            : 100.sp);

    // 12.sp (16/8/2026, was 14). The label is a caption on a compact toolbar
    // button, not body text.
    final TextStyle triggerTextStyle =
        StyleText.fontSize14Weight400.copyWith(color: contentColor);

    final Widget svg = CustomSvgImage(
      // EXPLICIT 20.sp (16/8/2026), was `CustomSvgImage.natural`. Natural size
      // means the asset's own pixels — 23pt for sort_lines.svg — which does not
      // scale with the rest of the app and was the tallest thing in the
      // trigger, so it was the icon deciding the button's height. 20.sp is what
      // `CustomSortIcon` and `CustomFilterIcon` draw.
      assetPath: svgPath,
      width: 20.sp,
      height: 20.sp,
      fit: BoxFit.contain,
      color: contentColor,
    );

    return SizedBox(
      width: buttonWidth,
      height: height ?? ButtonSizing.height,
      child: CustomDropdown<T>(
        value: value,
        // ✅ WHOLE button container takes AppColors.primary when selected.
        fillColor: hasSelection
            ? AppColors.primary
            : (unselectedFillColor ?? AppColors.card),
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        // HORIZONTAL 0 (16/8/2026). `InputDecorator` does NOT wrap
        // contentPadding around the whole trigger — the prefix and suffix sit
        // OUTSIDE it, and the padding belongs to the input area between them.
        // This button's input area is empty, so 8+8 here was 16pt of blank
        // space wedged between the label and the button's right edge, which
        // also pushed the "centred" pair 8pt off centre. The gutter now lives
        // inside the prefix, which is the thing that actually holds the icon
        // and the label. Vertical is untouched — that is what gives the
        // trigger its height.
        triggerPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 13.sp),
        // TIGHT ICON PADDING (16/8/2026). CustomDropdown's defaults are sized
        // for a full-width form field — 12/8 around the prefix and 8/12 around
        // the suffix. On a compact toolbar button that is ~40pt of chrome plus
        // the icon, which left about 20pt for the label and rendered "Sort" as
        // "Sor". The suffix here is a zero-size box, so its padding was pure
        // dead space.
        prefixIconPadding: EdgeInsets.zero,
        suffixIconPadding: EdgeInsets.zero,
        // ✅ THE BUTTON ALWAYS READS "Sort" (16/8/2026).
        //
        // A form field swaps its hint for the value it holds, because there the
        // value is the answer. This is an action button: its label names what
        // the button does, and replacing it with "Last Updated" left a control
        // on the toolbar that no longer said what it was — and one whose width
        // changed with whichever option happened to be picked.
        //
        // The selection is still visible twice over: the container takes
        // AppColors.primary, and the menu highlights the row that is active.
        alwaysShowHint: true,
        enforceTypeScale: false,
        overlayOffset: yOffset.sp,
        itemHeight: 35.h,
        // The label is NOT the hint any more (16/8/2026). InputDecorator draws
        // its hint in whatever space the prefix icon leaves and anchors it to
        // the START, so "Sort" sat hard against the icon with 60pt of dead
        // space after it while the Filter button beside it centred its own
        // icon+label pair.
        //
        // So the whole pair moved into the prefix slot as ONE Row as wide as
        // the button — the same `mainAxisAlignment: center` + `Flexible` shape
        // `CustomFilterIcon` uses, which is why the two now read as a pair.
        // The hint is empty; the input slot it would have used is zero-width.
        hint: '',
        hintStyle: triggerTextStyle,
        valueStyle: triggerTextStyle,
        itemStyle: StyleText.fontSize14Weight400,
        prefixIcon: SizedBox(
          // THE FULL BUTTON WIDTH (16/8/2026, was `buttonWidth - 16.w`). With
          // the trigger's horizontal padding at 0 and no suffix, the prefix is
          // the only slot left — so it spans the button and the Row below
          // centres in the button ITSELF rather than in what was left over.
          //
          // It also drops a unit mismatch: `buttonWidth` is `.sp` and the old
          // subtraction was `.w`, which are not the same number under
          // `minTextAdapt`.
          width: buttonWidth,
          child: Padding(
            // The 8pt gutter that used to be `triggerPadding`. Here it does
            // what it was meant to do: keep a long translation off the
            // button's edges before the Flexible ellipsises it.
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: showTitle
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      svg,
                      SizedBox(width: 8.sp),
                      // Flexible, so a longer translation ellipsises inside
                      // the button instead of overflowing it.
                      Flexible(
                        child: Text(
                          title ?? S.of(context).sort,
                          style: triggerTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                // Icon-only on phone: centred in the 38pt square.
                : Center(child: svg),
          ),
        ),
        // NO SUFFIX SLOT AT ALL — the sort trigger has no chevron, the svg is
        // the whole affordance. A zero-width `SizedBox` was not enough: the
        // slot still got built, and with it the space it reserves.
        showSuffixIcon: false,
        items: items
            .map((T item) => DropdownItem<T>(
                  value: item,
                  label: labelBuilder(item),
                ))
            .toList(),
        onChanged: (T v) {
          // ✅ Tapping the already-selected item deselects it (toggle).
          onChanged(v == value ? null : v);
        },
      ),
    );
  }
}
