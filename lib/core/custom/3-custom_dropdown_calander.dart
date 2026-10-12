/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dropdown_calendar.dart
/// Purpose: Declares `CustomDropdownCalendar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 30/8/2026 - The picker opens at `DatePicker`'s size (520×380 on
///          tablet, 360×380 on phone) instead of a 320 square, so the app's two
///          calendars are the same dialog.
/// Updated: 30/8/2026 - The picker's two action buttons are `customButton`s,
///          one pinned to each edge of the dialog, and the month arrows are the
///          app's own `chevron_left` / `chevron_right` assets. `Get.locale` is
///          gone with them — text direction now comes from `Directionality`.

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// `hide TextDirection`: intl exports a class of that name whose members are
// `LTR` / `RTL`, and it wins the import race against the framework's enum —
// `TextDirection.rtl` in `_isRtl` below then fails to compile with
// "Member not found: 'rtl'". Only the date formatting is wanted from here.
import 'package:intl/intl.dart' hide TextDirection;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
// The app's one button. The picker's actions used to be a local
// `GestureDetector` + `Container` pair with their own height, radius and text
// style — a second button implementation living in a core file.
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
// For `kDropdownHintColor` — the single placeholder grey all three dropdowns
// share. Imported rather than redeclared: a local copy is exactly how this
// widget ended up with a different hint colour from `CustomDropdown`.
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// ── Picker dialog geometry ──────────────────────────────────────────────────
///
/// ADDED 30/8/2026, all RAW (the ScreenUtil suffix is applied at each point of
/// use — and note WHICH suffix: the tablet numbers are `.sp`, the phone ones
/// `.w` / `.h`, matching `DatePicker` below).
///
/// REVISED 30/8/2026: these were a single 320 square. `DatePicker`
/// (core/custom/53-custom_date_pic) — the app's other calendar, the one the
/// Knowledge Hub schedule fields open — is 520 × 380 on tablet and 360 × 380 on
/// phone, so the same seven columns had appreciably more room there and the two
/// pickers read as two different components. The numbers below are that
/// widget's, so the two now open at the same size.
///
/// The action buttons are measured FROM the dialog width, which is the only way
/// to get one button against each edge: `calendar_date_picker2` lays its
/// actions out as `Row(mainAxisAlignment: end, children: [cancel, ok])` with no
/// alignment or spacer of its own, so two content-sized buttons always huddle
/// on the trailing side. Give each one a slot of exactly half the dialog and
/// the row is full — the leftover space that would have pushed them together is
/// now inside the slots, and each button sits at its own outer edge.
///
/// The two slots must therefore add up to the dialog width EXACTLY: short, and
/// the pair drifts back toward the trailing edge; long, and the Row overflows.
/// That is why both come from [_pickerDialogSize] rather than from two
/// constants that could drift apart.
const double _kPickerDialogWidthTablet = 520;

/// REVISED: was 360, which is wider than a dialog can actually be on a phone.
/// `Dialog` reserves `insetPadding` (40 a side) plus the safe area, so on a
/// 402pt-wide handset the widest a dialog gets is ~322 — but the action-button
/// slots were still measured from the 360 that was ASKED for, so the two slots
/// added up to more than the row had and the trailing button overflowed. The
/// number is smaller now AND clamped to what is available in
/// [_pickerDialogSize]; do not raise it past what the narrowest supported
/// phone can show.
const double _kPickerDialogWidthPhone = 300;

/// Horizontal room a `Dialog` gives up before its child is laid out:
/// `insetPadding` is 40 on each side.
const double _kDialogInsetPadding = 40;

/// Dialog height — DERIVED, not a constant (9/9/2026).
///
/// It used to be a flat 380 scaled by `.sp` / `.h`, which the package then
/// FLOORED at 410 logical pixels (`max(dialogSize.height, 410)` in
/// `showCalendarDatePicker2Dialog`) — so on a phone the number asked for was
/// inert and the dialog was always exactly as tall as the content needed, with
/// nothing to spare. That is why [buttonPadding] at the call below had to be
/// zero on the vertical axis.
///
/// The action row now carries [_kPickerButtonMargin] above and below it, to
/// match the margin it already has on the left and right, so the height is
/// built from its parts instead. Note WHICH parts scale: the calendar's own
/// height is raw logical pixels straight out of the package, while the button
/// and its margins are `.sp` — a single scaled constant would shrink below the
/// 410 floor on a small phone and clip the row again.
///
/// Calendar block, all raw: `controlsHeight` (52, the month/year header) plus
/// `_dayPickerRowHeight` (42) for each of the six week rows and the weekday
/// header — 52 + 42 × 7.
const double _kPickerCalendarHeight = 346; // 52 + 42 * 7

/// The package's own `gapBetweenCalendarAndButtons` default, raw.
const double _kPickerCalendarButtonGap = 10;

/// `customButton`'s fixed height (5-custom_button.dart), scaled with `.sp`.
const double _kPickerButtonHeight = 38;

/// Room the package reserves on EACH side of the month / year pickers for the
/// prev / next month arrows: `_monthNavButtonsWidth` is 108 and
/// `centerAlignModePicker` halves it, so 54 + 54 comes off the header row
/// before either picker gets a pixel. Raw.
const double _kPickerNavButtonsRoom = 108;

/// Gap between the month picker and the year picker — the package's own
/// default for a centre-aligned header, passed explicitly so the width the
/// mode pickers are given below and the width the package actually leaves
/// between them cannot drift apart. Raw.
const double _kPickerModePickersGap = 15;

/// The button inside a slot, and its gap from the dialog edge. Both are
/// `DatePicker`'s. `button + margin` must fit within a slot (half the dialog).
const double _kPickerButtonWidthTablet = 150;
const double _kPickerButtonWidthPhone = 120;
const double _kPickerButtonMargin = 20;

/// Month-navigation chevrons, and the size they are drawn at.
const String _kChevronLeft =
    'assets/icons_assets/main_icons_assets/chevron_left.svg';
const String _kChevronRight =
    'assets/icons_assets/main_icons_assets/chevron_right.svg';
const double _kPickerArrowSize = 16;

class CustomDropdownCalendar extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool required;
  final bool enabled;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  /// Fixed height for the TRIGGER, or null to let it size itself. ADDED
  /// 17/8/2026 alongside the same parameter on `CustomDropdown`, so a row that
  /// holds one of each can pin both to one height.
  ///
  /// INTERPRETED IN `.sp` and scaled here — pass the raw design number (`36`),
  /// not `36.sp`, exactly as `CustomTextField.height` documents.
  ///
  /// It sizes the TRIGGER only, never the label or the error line under it.
  final double? height;

  /// Padding inside the trigger, or null for this widget's own default
  /// (12 horizontal / 10 vertical).
  ///
  /// ADDED 29/8/2026, mirroring `CustomDropdown.triggerPadding`. A screen that
  /// stands a dropdown and a date field side by side has to be able to give
  /// both the same inset — Adding New Access is the first — and the default
  /// here differs from `CustomDropdown`'s on purpose (see the note at the
  /// `contentPadding` use below), so it cannot simply be changed for everyone.
  ///
  /// Pre-scale it: unlike [height], this is passed through untouched.
  final EdgeInsetsGeometry? contentPadding;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// ADDED 16/9/2026. When true, only TODAY and later can be picked: every
  /// earlier day is greyed out and not tappable. Combines with [firstDate]
  /// (the later of the two wins). Off by default so filters / history
  /// pickers that need past dates keep working.
  final bool disablePastDates;
  final String Function(DateTime)? dateFormatter;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  /// Size / weight / family of the placeholder.
  ///
  /// The COLOUR is not taken from here — it is always [kDropdownHintColor].
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;

  const CustomDropdownCalendar({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.fillColor,
    this.borderRadius,
    this.height,
    this.contentPadding,
    this.firstDate,
    this.lastDate,
    this.disablePastDates = false,
    this.dateFormatter,
    this.labelStyle,
    this.valueStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
  });

  @override
  State<CustomDropdownCalendar> createState() => _CustomDropdownCalendarState();
}

class _CustomDropdownCalendarState extends State<CustomDropdownCalendar> {
  /// Whether the tree this picker opens from reads right-to-left.
  ///
  /// Replaces the two `Get.locale.toString().contains('en')` reads that used to
  /// pick the month-arrow rotation: direction is a property of the widget tree,
  /// and this widget has a context.
  bool get _isRtl => Directionality.of(context) == TextDirection.rtl;

  /// The weekday header, abbreviated — "Sun Mon … Sat".
  ///
  /// ADDED 30/8/2026 to match `DatePicker` (core/custom/53-custom_date_pic),
  /// the app's other calendar: without this the package falls back to
  /// `localizations.narrowWeekdays`, the single letters "S M T W T F S", where
  /// three of the seven are ambiguous. `weekdayLabels` is a 7-element list the
  /// package indexes 0 = Sunday … 6 = Saturday, so it is built Sunday-first
  /// (4 Jan 2026 is a Sunday).
  ///
  /// 'EEE', not 'EEEE': the full names are far too wide for seven day-wide
  /// columns. Arabic has no shorter form for most days, so there 'EEE' returns
  /// what 'EEEE' would — which is what the `FittedBox` in the builder below is
  /// for.
  List<String> _weekdayLabels(BuildContext context) {
    final bool isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    return List<String>.generate(
      7,
      (int i) => DateFormat('EEE', isArabic ? 'ar' : 'en')
          .format(DateTime(2026, 1, 4).add(Duration(days: i))),
    );
  }

  /// `DatePicker`'s own breakpoint, so the two calendars switch size together.
  bool get _isTablet => MediaQuery.of(context).size.shortestSide > 600;

  /// The size the dialog opens at, and the single source the button slots are
  /// measured from — see the geometry block at the top of this file.
  Size _pickerDialogSize(bool isTablet) {
    final double requestedWidth = isTablet
        ? _kPickerDialogWidthTablet.sp
        : _kPickerDialogWidthPhone.w;

    // Clamp to the width a dialog can actually occupy. Asking for more than
    // this does not widen the dialog — the dialog is constrained anyway — it
    // only inflates the half-dialog slots `_buildActionButton` measures, which
    // is what overflowed the action row.
    final MediaQueryData mq = MediaQuery.of(context);
    final double available = mq.size.width -
        mq.padding.horizontal -
        _kDialogInsetPadding * 2;

    final double width =
        requestedWidth > available ? available : requestedWidth;

    return Size(
      width,
      // See the geometry block at the top of this file: the calendar's part is
      // raw, the button row's part scales.
      _kPickerCalendarHeight +
          _kPickerCalendarButtonGap +
          _kPickerButtonHeight.sp +
          _kPickerButtonMargin.sp * 2,
    );
  }

  Future<void> _openPicker() async {
    if (!widget.enabled) return;

    final List<String> weekdayLabels = _weekdayLabels(context);
    final bool isTablet = _isTablet;
    final Size dialogSize = _pickerDialogSize(isTablet);
    final bool isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    // Earliest selectable day: [firstDate], raised to today when
    // [disablePastDates] is on. A current value before it is not pre-selected
    // (it can no longer be picked), so the calendar opens on that first day.
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    DateTime effectiveFirstDate = widget.firstDate ?? DateTime(1900);
    if (widget.disablePastDates && effectiveFirstDate.isBefore(today)) {
      effectiveFirstDate = today;
    }
    final DateTime? initialValue = widget.value != null &&
            DateTime(widget.value!.year, widget.value!.month, widget.value!.day)
                .isBefore(effectiveFirstDate)
        ? null
        : widget.value;

    final result = await showCalendarDatePicker2Dialog(
      context: context,
      dialogBackgroundColor: AppColors.card,
      barrierDismissible: true,
      value: [initialValue],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: effectiveFirstDate,
        lastDate: widget.lastDate ?? DateTime(2100),
        calendarType: CalendarDatePicker2Type.single,
        calendarViewMode: CalendarDatePicker2Mode.day,
        closeDialogOnCancelTapped: true,
        closeDialogOnOkTapped: true,

        // ADDED 13/9/2026 — the last two strips of the hover highlight.
        //
        // The package builds each action as
        // `InkWell(child: Padding(padding: buttonPadding, child: <our button>))`,
        // so the InkWell's hit area — and its highlight — is our widget PLUS
        // that padding. Covering the slot from inside `_buildActionButton`
        // therefore hid the middle band but left the padding showing above and
        // below it as two grey bars.
        //
        // With the padding at zero the InkWell is exactly our widget, so the
        // opaque slot covers all of it. Our own geometry is unaffected: the
        // two slots are measured from `dialogSize.width`, never from the
        // package's padding, and the button keeps its spacing from
        // `_kPickerButtonMargin` inside the slot.
        buttonPadding: EdgeInsets.zero,
        currentDate: initialValue ??
            (now.isBefore(effectiveFirstDate) ? effectiveFirstDate : now),
        centerAlignModePicker: true,
        dayBorderRadius: BorderRadius.circular(4.r),
        dayBuilder: _buildDay,
        modePickersGap: _kPickerModePickersGap,

        // ADDED 9/9/2026 — this is what clears the "RIGHT OVERFLOWED BY 3
        // PIXELS" stripe over the header.
        //
        // The package lays the two pickers out as
        // `Expanded(Row(children: [month, gap, year]))`, and NEITHER picker is
        // flexible: each is a `Row(mainAxisSize: min)` handed unbounded width,
        // so it takes its label's full intrinsic width and the pair overflows
        // the Expanded as soon as the labels plus two chevrons plus the
        // package's own 10-a-side padding exceed
        // `dialogWidth - _kPickerNavButtonsRoom`. On a 300.w phone dialog that
        // budget is ~197, and "September" + "2026" wanted a few more.
        //
        // `modePickerBuilder` is the only hook that replaces that inner
        // content, so each picker is given a fixed slice of the room that IS
        // available, with a FittedBox inside: a label too long for its slice
        // scales down instead of overflowing — at any dialog width, in any
        // locale, for the longest month name there is.
        //
        // It replaces `customModePickerIcon` (29/8/2026), which the package
        // only reads on the path this builder now takes over — the chevron and
        // its gap moved into `_modePicker` unchanged.
        modePickerBuilder: ({
          required CalendarDatePicker2Mode viewMode,
          required DateTime monthDate,
          bool? isMonthPicker,
        }) {
          final bool isMonth = isMonthPicker == true;
          final double room = dialogSize.width -
              _kPickerNavButtonsRoom -
              _kPickerModePickersGap;

          // FIXED 29/9/2026 (Settings mobile bug p.1 — "increase font size"
          // on the year). The year got a flat 40% slice; on a phone-width
          // dialog that was narrower than "1977" + its chevron, so the
          // FittedBox shrank the year to a few pixels. The year now always
          // gets the width it needs (4 digits + chevron) and the month takes
          // the rest, still inside the room the header has.
          final double yearNeeded = _labelWidth('0000') + 14.sp + 12.sp + 4;
          final double yearSlice =
              yearNeeded > room * 0.40 ? yearNeeded : room * 0.40;
          final double monthSlice = (room - yearSlice - 2).clamp(0.0, room);

          return _modePicker(
            width: isMonth ? monthSlice : yearSlice,
            label: isMonth
                ? DateFormat('MMMM', isArabic ? 'ar' : 'en').format(monthDate)
                // Western digits, like the day cells — `formatYear` would give
                // Arabic-Indic ones in Arabic and the header would not match
                // the grid under it.
                : monthDate.year.toString(),
            // The chevron points up while that picker's own list is open.
            isOpen: viewMode ==
                (isMonth
                    ? CalendarDatePicker2Mode.month
                    : CalendarDatePicker2Mode.year),
          );
        },
        // CHANGED 30/8/2026: the app's own chevrons. These were one
        // `arrow_back_curved` asset drawn twice and flipped with
        // `Transform.rotate(3.14)` — a rotation, not a mirror, so the curve
        // came out upside down on whichever of the two was rotated, and the
        // angle was picked by asking `Get.locale` for the language.
        lastMonthIcon: _monthArrow(forward: false),
        nextMonthIcon: _monthArrow(forward: true),
        okButton: _buildActionButton(
          S.of(context).setDate,
          dialogWidth: dialogSize.width,
          isTablet: isTablet,
        ),
        cancelButton: _buildActionButton(
          S.of(context).Cancel,
          dialogWidth: dialogSize.width,
          isTablet: isTablet,
          isCancel: true,
        ),
        weekdayLabels: weekdayLabels,
        // The `FittedBox` scales a label down to its column only when it does
        // not fit: the English abbreviations ("Sun", "Mon") are left at full
        // size, and it earns its place for Arabic, where the day names have no
        // short form ("الأربعاء") and would otherwise clip.
        weekdayLabelBuilder: ({
          required int weekday,
          bool? isScrollViewTopHeader,
        }) {
          // Bug report (Settings mobile p.1): the full Arabic day names ran
          // into each other on a phone. Smaller type on a phone and a real gap
          // either side of each name.
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 1.sp : 3),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  weekdayLabels[weekday],
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: (isTablet
                          ? StyleText.fontSize16Weight400
                          : StyleText.fontSize12Weight400)
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
        selectedYearTextStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.primary),
        selectedDayHighlightColor: AppColors.primary,
        dayTextStyle:
        StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        // Days outside firstDate / lastDate: dimmed so they read as not
        // selectable.
        disabledDayTextStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.text.withOpacity(.25)),
        selectedDayTextStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.textButton),
        yearTextStyle:
        StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        todayTextStyle:
        StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        // HORIZONTAL: still zero. This padding wraps each action button INSIDE
        // the row, so any of it here comes out of the half-dialog slot
        // `_buildActionButton` measures (see the geometry block at the top of
        // this file). The gap from the dialog edge is the button's own margin
        // instead — `_kPickerButtonMargin`.
        //
        // VERTICAL: `_kPickerButtonMargin` as well, since 9/9/2026, so the
        // space above and below the action row matches the space beside it.
        // It was zero because the dialog height was a flat 380 that the
        // package floored at 410 — exactly the content — and 8 across the pair
        // was enough to paint "BOTTOM OVERFLOWED BY 1.6 PIXELS". The height is
        // derived from these parts now (see [_kPickerCalendarHeight]), so the
        // room comes with the padding.
        // buttonPadding: EdgeInsets.symmetric(vertical: _kPickerButtonMargin.sp),
      ),
      dialogSize: dialogSize,
      borderRadius: BorderRadius.circular(4.r),
      useSafeArea: true,
    );
    if (result != null && result.isNotEmpty) {
      widget.onChanged?.call(result.first);
    }
  }

  Widget _buildDay({
    required DateTime date,
    BoxDecoration? decoration,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    TextStyle? textStyle,
  }) {
    final now = DateTime.now();
    final isTodayDate =
        date.day == now.day && date.month == now.month && date.year == now.year;
    return Center(
      child: Container(
        width: 25.sp,
        height: 25.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: isSelected == true ? AppColors.primary : AppColors.field,
          border: Border.all(
            color: isTodayDate ? AppColors.primary : AppColors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: StyleText.fontSize14Weight400.copyWith(
              color: isSelected == true
                  ? AppColors.textButton
                  // Not selectable (before firstDate / after lastDate).
                  : isDisabled == true
                      ? AppColors.secondaryText.withOpacity(.25)
                      : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  /// One month-navigation chevron.
  ///
  /// ADDED 30/8/2026. The package positions these by PHYSICAL side, not by
  /// reading order — the "previous month" arrow is on the right in Arabic — so
  /// the asset is picked by direction rather than by rotating one arrow into
  /// the other. [forward] is "next month".
  Widget _monthArrow({required bool forward}) {
    final bool pointsEnd = forward != _isRtl;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.sp),
      child: CustomSvgImage(
        assetPath: pointsEnd ? _kChevronRight : _kChevronLeft,
        width: _kPickerArrowSize.sp,
        height: _kPickerArrowSize.sp,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }

  /// One of the picker's two action buttons, in its half of the dialog.
  ///
  /// CHANGED 30/8/2026: the button is now the app's [customButton] rather than
  /// a local `GestureDetector` + `Container` with its own height, radius and
  /// text style, and the two are pushed apart — Cancel against the leading
  /// edge, Set Date against the trailing one. See the geometry block at the top
  /// of this file for why each button is given exactly half the dialog width.
  ///
  /// [IgnorePointer] is load-bearing: `customButton` carries its own
  /// `GestureDetector`, and a live gesture detector here would win the arena
  /// against the `InkWell` the PACKAGE wraps this widget in — the one that
  /// actually commits the date and closes the dialog. Taps must fall through,
  /// so the button is passed a no-op `function` and made invisible to hit
  /// testing. (The cost is `customButton`'s haptic, which never fires.)
  /// One header picker — "September ⌄", "2026 ⌄" — inside a fixed [width].
  ///
  /// The width is what keeps the header from overflowing (see
  /// `modePickerBuilder` above); the `FittedBox` is what keeps a label legible
  /// inside it rather than clipped. `BoxFit.scaleDown` only ever shrinks, so a
  /// label that already fits — every English month, every Arabic one — is
  /// drawn at full size and nothing about the header changes.
  /// Width of [text] in the header label style.
  double _labelWidth(String text) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
          text: text,
          style: StyleText.fontSize14Weight400.copyWith(color: AppColors.primary)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  Widget _modePicker({
    required double width,
    required String label,
    required bool isOpen,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
          // The gap that keeps the label and its chevron from reading as one
          // glyph ("أغسطس⌄") — 29/8/2026, moved here 9/9/2026.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            child: RotatedBox(
              quarterTurns: isOpen ? 2 : 0,
              child: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/chevron_down.svg',
                height: 14.sp,
                fit: BoxFit.fitHeight,
                colorFilter:
                    ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label, {
    required double dialogWidth,
    required bool isTablet,
    bool isCancel = false,
  }) {
    // Half the dialog, taken from the width the dialog was actually opened
    // at — the two slots have to add up to it exactly.
    final double slot = dialogWidth / 2;
    // Never under 16 logical px: on a narrow desktop window `.sp` shrank the
    // margin until Cancel touched the dialog edge (Settings mobile bug p.1).
    final double margin =
        _kPickerButtonMargin.sp < 16 ? 16 : _kPickerButtonMargin.sp;

    // The button plus its own margin must fit INSIDE the slot. On a narrow
    // phone the fixed width no longer does, and the surplus is exactly what
    // used to paint the overflow stripe over the trailing button — so shrink
    // the button to the room it has rather than letting the row overflow.
    final double desiredButtonWidth = isTablet
        ? _kPickerButtonWidthTablet.sp
        : _kPickerButtonWidthPhone.sp;
    final double maxButtonWidth = slot - margin;
    final double buttonWidth = maxButtonWidth <= 0
        ? slot
        : (desiredButtonWidth > maxButtonWidth
            ? maxButtonWidth
            : desiredButtonWidth);

    // The grey rectangle on hover is NOT this button — it is the InkWell the
    // picker package wraps this whole slot in (see the IgnorePointer note
    // above: that InkWell is what commits the date). It covers the full
    // `slot`, i.e. half the dialog, which is why the highlight was far wider
    // than the button and bled past it.
    //
    // A `Theme` override here does NOT work, and that was the first attempt:
    // Theme only reaches descendants, and the InkWell is this widget's
    // ANCESTOR — it reads the theme from its own position, above us.
    //
    // What does work is paint order. An InkWell's hover / highlight / splash
    // are InkFeatures drawn by the nearest ancestor Material, and that
    // Material paints its ink layer BEFORE its child subtree. So anything
    // opaque in the subtree covers the ink. Filling the whole slot with the
    // dialog's own background (`dialogBackgroundColor: AppColors.card`, passed
    // where this picker is opened) hides the highlight while leaving the
    // dialog looking exactly as it does now — and the tap still reaches the
    // InkWell underneath, because ColoredBox is not a hit-test barrier the way
    // an AbsorbPointer would be.
    return ColoredBox(
      color: AppColors.card,
      child: SizedBox(
      width: slot,
      child: Align(
        alignment: isCancel
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: isCancel ? margin : 0,
            end: isCancel ? 0 : margin,
          ),
          child: IgnorePointer(
            child: customButton(
              title: label,
              function: () {},
              width: buttonWidth,
              color: isCancel ? AppColors.secondaryButton : AppColors.primary,
              textStyle: StyleText.fontSize14Weight400.copyWith(
                color: isCancel ? AppColors.text : AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      widget.dateFormatter?.call(d) ??
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _sized(Widget trigger) {
    final double? h = widget.height;
    if (h == null) return trigger;
    return SizedBox(height: h.sp, child: trigger);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = BorderRadius.circular(4.r);
    final isDisabled = !widget.enabled;
    final displayText = widget.value != null ? _formatDate(widget.value!) : null;

    // ADDED 21/9/2026 — pin the painted box to [height], exactly as
    // `CustomDropdown._buildTrigger` does (its 16/9/2026 note). Without this
    // `height` only sized the SizedBox AROUND the decorator: the decorator kept
    // its own vertical content padding plus an unconstrained suffix, so it drew
    // a box of a different height from a `height: 36` dropdown beside it — the
    // Role Type / Access Granted / Access Revoked row (bug report p.10). With a
    // pinned height the vertical padding goes to 0, the suffix slot is held to
    // the height (InputDecorator uses it as the container minimum) and the
    // value is centred. A caller passing its own [contentPadding] is untouched.
    final double? pinnedHeight = widget.height != null && widget.contentPadding == null
        ? widget.height!.sp
        : null;

    // ── Label 14.sp / hint 12.sp, ALWAYS (16/8/2026) ──────────────────────
    //
    // Same contract as `CustomTextField` and `CustomDropdown`. This widget is
    // never alone on a row — "Start Date Of Access" and "End Date Of Access"
    // sit beside each other under a Permissions dropdown — so it has to measure
    // its title and its placeholder the same way they do. Its hint defaulted to
    // 14, which is why an empty date box's placeholder read larger than the
    // dropdown's above it.
    //
    // [labelStyle] still owns colour, weight and the rest; only the size is
    // reapplied. [hintStyle] no longer owns the colour — see
    // [kDropdownHintColor], forced on below.
    final TextStyle labelStyle = (widget.labelStyle ??
            StyleText.fontSize14Weight500.copyWith(
              color: hasError ? AppColors.red : AppColors.text,
            ))
        .copyWith(fontSize: 14.sp);

    final TextStyle hintStyle = (widget.hintStyle ??
            StyleText.fontSize12Weight400)
        .copyWith(fontSize: 12.sp, color: kDropdownHintColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: labelStyle,
              children: widget.required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.red,
                          fontSize: 14.sp,
                        ),
                      )
                    ]
                  : [],
            ),
          ),
          // Shared with `CustomDropdown` (29/8/2026) so a labelled dropdown and
          // a labelled date field standing side by side start at the same
          // height. The literal 6 that used to be here is now [kFieldLabelGap],
          // imported from the same file this widget already takes
          // `kDropdownHintColor` from — for exactly the same reason.
          SizedBox(height: kFieldLabelGap.sp),
        ],
        // `_sized` applies [CustomDropdownCalendar.height] to the trigger and
        // nothing else — see that field.
        _sized(GestureDetector(
          onTap: _openPicker,
          child: InputDecorator(
            isFocused: false,
            textAlignVertical:
                pinnedHeight != null ? TextAlignVertical.center : null,
            isEmpty: displayText == null,
            decoration: InputDecoration(
              isDense: true,
              // ADDED 21/9/2026 — the decorator itself is held to [height], not
              // just the SizedBox around it. The suffix-slot trick alone left the
              // painted box a few px short in some rows (Gender / Birthday /
              // Marital Status drew 37 / 40 / 37 px at the same `height: 40`).
              constraints: widget.height == null
                  ? null
                  : BoxConstraints.tightFor(height: widget.height!.sp),
              // 10.sp vertical (16/8/2026, was 12.sp). The trigger carries a
              // 18.sp calendar icon in its suffix, so its content is already
              // taller than a text field's single line — the same padding on
              // both made the date boxes stand proud of the fields beside them.
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(
                      horizontal: 12.sp,
                      vertical: pinnedHeight != null ? 0 : 10.sp),
              filled: true,
              fillColor: isDisabled
                  ? (widget.fillColor ?? AppColors.background)
                  : widget.fillColor ?? AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: radius, borderSide: BorderSide.none),
              enabledBorder: hasError
                  ? OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: AppColors.red, width: 1.5.sp))
                  : OutlineInputBorder(
                  borderRadius: radius, borderSide: BorderSide.none),
              focusedBorder: hasError
                  ? OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: AppColors.red, width: 1.5.sp))
                  : OutlineInputBorder(
                  borderRadius: radius, borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(
                  borderRadius: radius, borderSide: BorderSide.none),
              prefixIcon: null,
              prefixIconConstraints: const BoxConstraints(),
              // ── calendar icon now on the right, arrow removed ──
              // CHANGED 8/9/2026 — the icon was full-strength AppColors.text,
              // which read as darker and heavier than the chevron on the
              // dropdown standing next to it in the same row. It is now
              // AppColors.grey at 50%, matching that chevron. The error colour
              // is untouched: a red field still gets a red icon.
              suffixIcon: Padding(
                padding: EdgeInsets.only(left: 8.sp, right: 12.sp),
                child: CustomSvgImage(
   assetPath: 'assets/icons_assets/roles_assets/calendar.svg',
   width: 18.sp,
   height: 18.sp,
   fit: BoxFit.contain,
   colorFilter: ColorFilter.mode(
                    hasError
                        ? AppColors.red
                        // Role QA p.6: was grey at 50% — too faint to see.
                        : kDropdownTrailingIconColor(hasValue: true),
                    BlendMode.srcIn,
                  ),
 ),
              ),
              suffixIconConstraints: pinnedHeight != null
                  ? BoxConstraints(
                      minHeight: pinnedHeight, maxHeight: pinnedHeight)
                  : const BoxConstraints(),
              hintText: displayText == null ? (widget.hint ?? '') : null,
              hintStyle: hintStyle,
              errorText: null,
            ),
            child: displayText != null
                ? Text(
              displayText,
              style: widget.valueStyle ??
                  StyleText.fontSize14Weight400.copyWith(
                    color: isDisabled
                        ? AppColors.text
                        : AppColors.text,
                  ),
              overflow: TextOverflow.ellipsis,
            )
                : const SizedBox.shrink(),
          ),
        )),
        if (hasError) ...[
          SizedBox(height: 4.sp),
          Text(widget.errorText!,
              style: widget.errorStyle ??
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: 4.sp),
          Text(widget.helperText!,
              style: widget.helperStyle ??
                  StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text.withOpacity(0.5))),
        ],
      ],
    );
  }
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
DateTime? _date;

CustomDropdownCalendar(
  label: 'Birth Date',
  hint: 'Select date',
  required: true,
  value: _date,
  // errorText: 'Date is required',
  onChanged: (d) => setState(() => _date = d),
)
*/
