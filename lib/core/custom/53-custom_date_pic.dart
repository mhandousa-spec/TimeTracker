/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: date_picker.dart
/// Purpose: Declares `DatePicker`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 30/8/2026 - Weekday header is abbreviated ("Sun Mon … Sat"), not
///          the full day name.
/// Updated: 28/8/2026 - Full localised weekday names, centred action buttons,
///          selected-day number uses AppColors.textButton, no button hover,
///          smaller & symmetric button padding.
/// Updated: 29/8/2026 - Month navigation uses the app's own chevron assets, and
///          the month / year mode-picker chevron is no longer glued to its
///          label; the month and year pickers now have a gap between them.

import 'dart:math' as math;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';


class DatePicker {
  Future<List<DateTime?>?> showDatePicker(
      BuildContext context,
      List<DateTime?> rangeDatePickerValueWithDefaultValue,
      DateTime? currentDate,
      CalendarDatePicker2Type? calendarType,
      {DateTime? firstDate}) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Weekday header labels.
    //
    // EDIT 28/8/2026: the header used the package default
    // (`localizations.narrowWeekdays`) — the single narrow letters
    // "S M T W T F S". `weekdayLabels` is a 7-element list the package indexes
    // 0 = Sunday … 6 = Saturday, so it is built Sunday-first here (4 Jan 2026
    // is a Sunday). The month/day locale ('ar' vs 'en') follows the active app
    // locale.
    //
    // EDIT 30/8/2026: ABBREVIATED, not full — "Sun Mon … Sat", the pattern
    // 'EEE' rather than 'EEEE'. Seven full names ("Wednesday") in seven day-
    // wide columns is what forced the FittedBox below to shrink each label to
    // fit, so the header read at a different size from everything else in the
    // dialog. Arabic has no shorter form for most days, so 'EEE' there returns
    // the same word 'EEEE' does — the FittedBox stays for that reason.
    final bool isArabic = !Get.locale.toString().contains('en');
    final List<String> weekdayLabels = List<String>.generate(
      7,
      (int i) => DateFormat(
        'EEE',
        isArabic ? 'ar' : 'en',
      ).format(DateTime(2026, 1, 4).add(Duration(days: i))),
    );

    return showCalendarDatePicker2Dialog(
        context: context,
        dialogBackgroundColor: AppColors.card,
        barrierDismissible: true,
        value: rangeDatePickerValueWithDefaultValue,
        config: CalendarDatePicker2WithActionButtonsConfig(
          firstDate: firstDate ?? DateTime(1900),
          lastDate: DateTime(2100),

          dayBuilder: ({
            required DateTime date,
            BoxDecoration? decoration,
            bool? isDisabled,
            bool? isSelected,
            bool? isToday,
            TextStyle? textStyle,
          }) {
            return Center(
              child: Container(
                  width: 25.sp,
                  height: 25.sp,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: isSelected == true
                          ? AppColors.primary
                          : AppColors.field,
                      border: Border.all(
                        color: date.day == DateTime.now().day &&
                            date.month == DateTime.now().month &&
                            date.year == DateTime.now().year
                            ? AppColors.primary
                            : AppColors.transparent,
                      )),
                  child: Center(
                      child: Text(
                        date.day.toString(),
                        style: StyleText.fontSize14Weight400.copyWith(
                          // EDIT 28/8/2026: the selected day number must use the
                          // on-primary colour so it reads against the primary
                          // pill (was AppColors.white).
                          color: isSelected == true
                              ? AppColors.textButton
                              : AppColors.secondaryText,
                        ),
                      ))),
            );
          },
          calendarViewMode: CalendarDatePicker2Mode.day,
          closeDialogOnCancelTapped: true,
          closeDialogOnOkTapped: true,
          currentDate: currentDate, //widget.dateTimeNow ?? DateTime.now(),
          centerAlignModePicker: true,
          dayBorderRadius: BorderRadius.circular(8),

          // EDIT 29/8/2026: the chevron sat flush against "أغسطس" / "2026",
          // so the label and its arrow read as one smudged glyph. The package
          // places this widget straight after the label with no gap of its
          // own, so the gap is part of the icon — a directional START inset,
          // which stays on the label's side in both LTR and RTL.
          //
          // Revised same day: 6 was still reading as one glyph at the sizes the
          // dialog actually renders at, so the inset is now 10 on phone / 12 on
          // tablet, tracking the icon's own height.
          customModePickerIcon: Padding(
            padding: EdgeInsetsDirectional.only(start: isTablet ? 12.sp : 10.sp),
            child: CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/chevron_down.svg',
              height: isTablet ? 16.sp : null,
              fit: BoxFit.fitHeight,
              color: AppColors.primary,
            ),
          ),

          // EDIT 29/8/2026: the month picker and the year picker are two
          // separate tap targets sitting side by side; with no gap the year
          // chevron ran straight into the month label. This is the package's
          // own spacing hook between the two pickers.
          modePickersGap: isTablet ? 20.sp : 16.sp,

          // EDIT 29/8/2026: spread the two buttons to the edges — Cancel 20 from
          // the left, Set Date 20 from the right — instead of centring them.
          //
          // The package lays them out in a `Row` with a hardcoded
          // `MainAxisAlignment.end`, so both hug the trailing edge. The 20 on
          // the trailing side (Set Date → right) is just `buttonPadding` below.
          // To push Cancel to the leading edge, a wide directional END inset is
          // added to Cancel so the two containers together fill the whole row
          // width; with no free space left over, Cancel lands `buttonPadding`
          // (20) from the leading edge.
          //
          // Cancel end inset = dialogWidth - 2*buttonWidth - 4*buttonPadding
          //   tablet: 520 - 2*150 - 4*20 = 140
          //   phone : 360 - 2*120 - 4*20 = 40  (shaved to 24: the phone dialog
          //           width is in .w while the buttons are in .sp, so on a
          //           device whose .sp factor runs ahead of its .w factor the
          //           row came out ~12pt wider than the dialog — "A RenderFlex
          //           overflowed by 12 pixels on the right". The shave is the
          //           slack that absorbs that difference; Cancel simply sits a
          //           little further from the leading edge on such devices
          //           rather than striping.)
          // Re-derive it if the dialog width, button width, or buttonPadding
          // changes.
          okButton: GestureDetector(
            child: Container(
              height: 38.sp,
              width: isTablet ? 150.sp : 120.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.primary,
              ),
              child: Center(
                child: Text(
                  S.current.setDate,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.textButton),
                ),
              ),
            ),
          ),

          cancelButton: GestureDetector(
            child: Padding(
              // CHANGED 1/10/2026 — see [buttonPadding]: 3.5 more on each
              // side of both buttons, so 4 × 3.5 = 14 comes off this inset.
              padding: EdgeInsetsDirectional.only(end: isTablet ? 126.sp : 10.sp),
              child: Container(
                height: 38.sp,
                width: isTablet ? 150.sp : 120.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.secondaryAction,
                ),
                child: Center(
                  child: Text(
                    S.current.Cancel,
                    style: StyleText.fontSize14Weight400.copyWith(color: AppColors.onSecondaryAction),
                  ),
                ),
              ),
            ),
          ),


          // EDIT 29/8/2026: month navigation used `arrow_back_curved.svg` —
          // the curved BACK arrow — flipped 180° to stand in for "next". The
          // app has a matched pair of plain chevrons; they are used here, and
          // picked by direction rather than rotated, so neither arrow is a
          // mirror image of the other's asset.
          //
          // The package positions these two by physical side, not by reading
          // order, so in Arabic "previous month" is the arrow on the RIGHT —
          // which is why the pair swaps with the locale.
          lastMonthIcon: _monthArrow(
            isArabic
                ? 'assets/icons_assets/main_icons_assets/chevron_right.svg'
                : 'assets/icons_assets/main_icons_assets/chevron_left.svg',
            isTablet,
          ),
          nextMonthIcon: _monthArrow(
            isArabic
                ? 'assets/icons_assets/main_icons_assets/chevron_left.svg'
                : 'assets/icons_assets/main_icons_assets/chevron_right.svg',
            isTablet,
          ),
          weekdayLabels: weekdayLabels,
          // The `FittedBox` scales a label down to its column when it does not
          // fit. The English abbreviations ("Sun", "Mon") fit at full size and
          // are left alone by it; it still earns its place for Arabic, where
          // the day names have no short form ("الأربعاء") and would otherwise
          // clip.
          weekdayLabelBuilder: ({
            required int weekday,
            bool? isScrollViewTopHeader,
          }) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.sp),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    weekdayLabels[weekday],
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize16Weight400
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            );
          },
          weekdayLabelTextStyle: StyleText.fontSize16Weight400
              .copyWith(color: AppColors.primary),

          controlsTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.primary),
          // The selected year sits on a selectedDayHighlightColor pill, so its
          // label must be the on-primary colour. It was AppColors.primary —
          // the same yellow as the pill — which rendered the year you just
          // picked as a blank chip.
          selectedYearTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),
          selectedDayHighlightColor: AppColors.primary,
          dayTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),
          selectedDayTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),

          yearTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.text),
          todayTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.text),
          // CHANGED 22/9/2026 — SYMMETRIC. Reported as "padding from
          // horizontal as from vertical, but vertical not right".
          //
          // The horizontal 20 is the gap between each button and its side of
          // the dialog (Cancel↔left, Set Date↔right) and is exact. The
          // vertical was deliberately kept SMALLER (16 tablet / 8 phone) to
          // hold the dialog height down, which is what made the bottom gap
          // read wrong against the sides.
          //
          // It is one value on both axes now. Mind the asymmetry in how the
          // two are produced, because it is why this keeps coming back:
          //
          //   left / right gap = buttonPadding.horizontal              (exact)
          //   top / bottom gap = buttonPadding.vertical + slack / 2
          //
          // where `slack` is `dialogSize.height - content height`, split
          // evenly because the package centres its content vertically. So the
          // vertical gap is only equal to the horizontal one when the dialog
          // is sized close to its content — hence the paired change to
          // [dialogSize] below, which adds exactly the height this padding
          // costs so the slack is left as it was rather than turning into an
          // overflow.
          //
          // CHANGED 1/10/2026 (Services mobile QA p.8): the outer edges of
          // Cancel / Set Date sat ~3.5 outside the month arrows above them
          // (the arrows are 23.5 in from the dialog edge, the buttons were
          // 20). Horizontal is now 23.5 so each button lines up with its
          // arrow; vertical stays 20 so the dialog height is unchanged.
          buttonPadding: EdgeInsets.symmetric(horizontal: 23.5.sp, vertical: 20.sp),
          selectedRangeHighlightColor: AppColors.primary,
          calendarType: calendarType, //CalendarDatePicker2Type.range,
        ),
        // EDIT 29/8/2026: wider (room for the full weekday names + centred
        // buttons) and just tall enough to clear the overflow. The content is
        // vertically centred, so any excess height becomes large empty gaps at
        // the top and bottom — keep the height close to the content so those
        // gaps stay small (~20). Nudge the height up if the bottom ever
        // overflows again, down if the gaps look too big.
        // CHANGED 12/9/2026 — phone height 380 → 392: the buttons row is laid
        // out in .sp and overran the .h-sized dialog by ~4pt ("A RenderFlex
        // overflowed by 3.9 pixels on the bottom"). The extra 12 is split
        // between the top and bottom gaps, which stay small.
        // CHANGED 21/9/2026 — tablet/desktop height 380 → 372: the gap under
        // Cancel / Set Date measured ~23 against the 20 beside them, so the
        // vertical margin read bigger than the horizontal one. The content is
        // centred, so trimming 8 takes ~4 off the bottom (and top) gap and
        // leaves ~7 of slack before any overflow.
        //
        // CHANGED 22/9/2026 — heights raised by exactly what the symmetric
        // [buttonPadding] above added to the content, so the slack (and with
        // it the overflow margin) is unchanged:
        //   tablet: vertical 16 → 20, +4 top and bottom  → 372 + 8  = 380
        //   phone : vertical  8 → 20, +12 top and bottom → 392 + 24 = 416
        //
        // TO TUNE THE BOTTOM GAP, CHANGE THESE HEIGHTS, NOT THE PADDING.
        // Trimming a height takes half of what you trim off the bottom gap
        // (the other half comes off the top). The phone size mixes `.w`/`.h`
        // with buttons measured in `.sp`, so leave a few points of slack there
        // — on a device whose `.sp` factor runs ahead of its `.h` factor, zero
        // slack is an overflow rather than a tight fit.
        //
        // CHANGED 28/9/2026 (Role p.6 / Knowledge Hub p.20 — Cancel and Set
        // Date cut off by the bottom of the dialog). The fixed 380.sp could not
        // hold the content on desktop: the calendar block is RAW pixels
        // (52 header + 42 × 7 rows = 346) plus the package's 10 gap, and only
        // the button row (38) and its padding (20 above + 20 below) scale with
        // .sp — so any .sp-only number ends up short on some screen. The
        // height is now built from those parts plus 6 of slack, and the phone
        // keeps its old 416.h as a floor.
        dialogSize: isTablet
            ? Size(520.sp, _kPickerContentHeight + 6)
            : Size(360.w, math.max(416.h, _kPickerContentHeight + 6)),
        borderRadius: BorderRadius.circular(10),
        // EDIT 28/8/2026: remove the hover / ripple highlight that showed when
        // the pointer was over any button.
        //
        // The package wraps every control (the Cancel / Set Date buttons, the
        // month-navigation arrows, the day cells) in a Material `InkWell` that
        // reads its hover / splash / highlight colours from the ambient theme.
        // There is no per-button config to switch that off, so the whole dialog
        // is wrapped in a `Theme` whose ink colours are transparent and whose
        // splash factory is `NoSplash` — every InkWell inside then paints
        // nothing on hover or press.
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              hoverColor: AppColors.transparent,
              splashColor: AppColors.transparent,
              highlightColor: AppColors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        useSafeArea: true);
  }

  /// One month-navigation chevron.
  ///
  /// Tinted [AppColors.primary] (to match the header) rather than left with the asset's own colours: a
  /// fixed-colour glyph disappears against one of the two themes, and these
  /// arrows sit on the dialog's card background in both.
  Widget _monthArrow(String assetPath, bool isTablet) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.sp),
        child: CustomSvgImage(
          assetPath: assetPath,
          height: isTablet ? 16.sp : 14.sp,
          width: isTablet ? 16.sp : 14.sp,
          fit: BoxFit.contain,
          // CHANGED 28/9/2026 (Role p.6 / Knowledge Hub p.20 — "same color
          // as" the month / year header): was AppColors.text, which drew the
          // arrows white beside a yellow "September ⌄ 2026 ⌄".
          color: AppColors.primary,
        ),
      );

  /// Everything the dialog has to hold, top to bottom: the calendar block
  /// (raw), the package's gap above the buttons (raw), the button row and its
  /// 20.sp padding above and below (scaled). See [dialogSize] above.
  static double get _kPickerContentHeight => 346.0 + 10.0 + (38 + 40).sp;
}
