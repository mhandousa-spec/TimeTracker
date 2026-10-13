/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dropdown_range_calendar.dart
/// Purpose: Declares `CustomDropdownRangeCalendar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 13/10/2026 - `showRangePicker` opens the range calendar on its
///          own (opt-in; the field itself is unchanged).

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
// For `kDropdownHintColor` — the single placeholder grey all three dropdowns
// share. Imported rather than redeclared: a local copy is exactly how this
// widget ended up with a different hint colour from `CustomDropdown`.
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CustomDropdownRangeCalendar extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end)? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final bool required;
  final bool enabled;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(DateTime)? dateFormatter;

  /// Separator between from/to — defaults to "  →  "
  final String? separator;

  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  /// Size / weight / family of the placeholder.
  ///
  /// The COLOUR is not taken from here — it is always [kDropdownHintColor].
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;

  const CustomDropdownRangeCalendar({
    super.key,
    this.startDate,
    this.endDate,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.fillColor,
    this.borderRadius,
    this.firstDate,
    this.lastDate,
    this.dateFormatter,
    this.separator,
    this.labelStyle,
    this.valueStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
  });

  /// ADDED 13/10/2026 (Time Tracker owner review): opens the same range
  /// calendar this field opens, without the field — for a menu item
  /// ("Custom") that should go straight to one date-range picker. Returns
  /// [start, end] (end may be null when only one day was tapped), or null
  /// when the picker was cancelled.
  static Future<List<DateTime?>?> showRangePicker(
    BuildContext context, {
    DateTime? start,
    DateTime? end,
    DateTime? firstDate,
    DateTime? lastDate,
  }) =>
      _CustomDropdownRangeCalendarState._show(
        context,
        start: start,
        end: end,
        firstDate: firstDate,
        lastDate: lastDate,
        standards: true,
      );

  @override
  State<CustomDropdownRangeCalendar> createState() =>
      _CustomDropdownRangeCalendarState();
}

class _CustomDropdownRangeCalendarState
    extends State<CustomDropdownRangeCalendar> {
  Future<void> _openPicker() async {
    if (!widget.enabled) return;
    final result = await CustomDropdownRangeCalendar.showRangePicker(
      context,
      start: widget.startDate,
      end: widget.endDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    if (result != null) {
      widget.onChanged?.call(
        result.isNotEmpty ? result[0] : null,
        result.length > 1 ? result[1] : null,
      );
    }
  }

  static Future<List<DateTime?>?> _show(
    BuildContext context, {
    DateTime? start,
    DateTime? end,
    DateTime? firstDate,
    DateTime? lastDate,
    bool standards = false,
  }) {
    // [standards] (13/10/2026, `showRangePicker` only): the app's dialog
    // standard — scale-in entrance, yellow button shrinks on press, haptics
    // Set Date = MEDIUM, Cancel = LOW. The field keeps its old behaviour.
    final Widget ok = _buildActionButton(S.of(context).setDate);
    final Widget cancel = _buildActionButton(S.of(context).Cancel, isCancel: true);
    return showCalendarDatePicker2Dialog(
      builder: standards
          ? (BuildContext ctx, Widget? dialog) => ScaleInContent(child: dialog!)
          : null,
      context: context,
      dialogBackgroundColor: AppColors.card,
      barrierDismissible: true,
      value: [start, end],
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDate: firstDate ?? DateTime(1900),
        lastDate: lastDate ?? DateTime(2100),
        calendarType: CalendarDatePicker2Type.range,
        calendarViewMode: CalendarDatePicker2Mode.day,
        closeDialogOnCancelTapped: true,
        closeDialogOnOkTapped: true,
        currentDate: start ?? DateTime.now(),
        centerAlignModePicker: true,
        dayBorderRadius: BorderRadius.circular(8.r),
        dayBuilder: _buildDay,
        customModePickerIcon: CustomSvgImage(
   assetPath: 'assets/icons_assets/main_icons_assets/chevron_down.svg',
   height: 14.sp,
   fit: BoxFit.fitHeight,
   colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
 ),
        lastMonthIcon: Transform.rotate(
          angle: Get.locale.toString().contains('en') ? 0 : 3.14,
          child: CustomSvgImage.natural(
   assetPath: 'assets/icons_assets/main_icons_assets/arrow_back_curved.svg',
   colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
 ),
        ),
        nextMonthIcon: Transform.rotate(
          angle: Get.locale.toString().contains('en') ? 3.14 : 0,
          child: CustomSvgImage.natural(
   assetPath: 'assets/icons_assets/main_icons_assets/arrow_back_curved.svg',
   colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
 ),
        ),
        okButton: standards
            ? Listener(
                onPointerUp: (_) => HapticController.medium(),
                child: ShrinkOnTap(child: ok),
              )
            : ok,
        cancelButton: standards
            ? Listener(onPointerUp: (_) => HapticController.low(), child: cancel)
            : cancel,
        weekdayLabelTextStyle: StyleText.fontSize16Weight400
            .copyWith(color: AppColors.primary),
        controlsTextStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.primary),
        selectedYearTextStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.primary),
        selectedDayHighlightColor: AppColors.primary,
        selectedRangeHighlightColor: AppColors.primary.withOpacity(0.15),
        dayTextStyle:
        StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        selectedDayTextStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.textButton),
        yearTextStyle:
        StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        todayTextStyle:
        StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        buttonPadding: EdgeInsets.symmetric(horizontal: 14.sp),
      ),
      dialogSize: Size(320.sp, 320.sp),
      borderRadius: BorderRadius.circular(10.r),
      useSafeArea: true,
    );
  }

  static Widget _buildDay({
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
          borderRadius: BorderRadius.circular(8.r),
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
                  : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildActionButton(String label, {bool isCancel = false}) {
    return GestureDetector(
      child: Container(
        height: 38.sp,
        width: 120.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: isCancel ? AppColors.secondaryButton : AppColors.primary,
        ),
        child: Center(
          child: Text(
            label,
            style: StyleText.fontSize14Weight400.copyWith(
              color: isCancel ? AppColors.text : AppColors.textButton,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      widget.dateFormatter?.call(d) ??
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _displayText {
    final sep = widget.separator ?? '  →  ';
    if (widget.startDate != null && widget.endDate != null) {
      return '${_formatDate(widget.startDate!)}$sep${_formatDate(widget.endDate!)}';
    } else if (widget.startDate != null) {
      return '${_formatDate(widget.startDate!)}$sep...';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(8.r);
    final isDisabled = !widget.enabled;
    final displayText = _displayText;
    final isEmpty = displayText.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: widget.labelStyle ??
                  StyleText.fontSize14Weight500.copyWith(
                    color: hasError
                        ? AppColors.red
                        : isDisabled
                        ? AppColors.text.withOpacity(0.4)
                        : AppColors.text,
                  ),
              children: widget.required
                  ? [TextSpan(text: ' *', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red))]
                  : [],
            ),
          ),
          SizedBox(height: 6.sp),
        ],
        GestureDetector(
          onTap: _openPicker,
          child: InputDecorator(
            isFocused: false,
            isEmpty: isEmpty,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
              filled: true,
              fillColor: isDisabled
                  ? (widget.fillColor ?? AppColors.card).withOpacity(0.5)
                  : widget.fillColor ?? AppColors.card,
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
              // ── prefixIcon removed ──
              prefixIcon: null,
              prefixIconConstraints: const BoxConstraints(),
              // ── calendar icon now on the right, arrow removed ──
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
                        : isDisabled
                        ? AppColors.text.withOpacity(0.3)
                        : AppColors.text.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
 ),
              ),
              suffixIconConstraints: const BoxConstraints(),
              hintText: isEmpty ? (widget.hint ?? '') : null,
              // The colour is forced last on purpose — see
              // [kDropdownHintColor]. `hintStyle` still decides size, weight
              // and family; it can no longer decide the grey.
              hintStyle: (widget.hintStyle ?? StyleText.fontSize14Weight400)
                  .copyWith(color: kDropdownHintColor),
              errorText: null,
            ),
            child: !isEmpty
                ? Text(
              displayText,
              style: widget.valueStyle ??
                  StyleText.fontSize14Weight400.copyWith(
                    color: isDisabled
                        ? AppColors.text.withOpacity(0.4)
                        : AppColors.text,
                  ),
              overflow: TextOverflow.ellipsis,
            )
                : const SizedBox.shrink(),
          ),
        ),
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
DateTime? _from;
DateTime? _to;

CustomDropdownRangeCalendar(
  label: 'Duration',
  hint: 'Select date range',
  required: true,
  startDate: _from,
  endDate: _to,
  separator: '  →  ',
  // errorText: 'Please select a range',
  onChanged: (start, end) => setState(() {
    _from = start;
    _to = end;
  }),
)
*/
