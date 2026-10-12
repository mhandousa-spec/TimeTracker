/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_date_picker2_with_action_buttons.dart
/// Purpose: Declares `CalendarDatePicker2WithActionButtons`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart' show AppFontStyle;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/calendar_package/src/models/calendar_date_picker2_config.dart';
import 'package:knowticed_plus/core/extensions/calendar_package/src/widgets/calendar_date_picker2.dart';


class CalendarDatePicker2WithActionButtons extends StatefulWidget {
  const CalendarDatePicker2WithActionButtons({
    required this.value,
    required this.config,
      this.isHome = false,
    this.onValueChanged,
    this.onDisplayedMonthChanged,
    this.onCancelTapped,
    this.onOkTapped,
    Key? key,
  }) : super(key: key);


  final bool? isHome;
  final List<DateTime?> value;

  /// Called when the user taps 'OK' button
  final ValueChanged<List<DateTime?>>? onValueChanged;

  /// Called when the user navigates to a new month/year in the picker.
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  /// The calendar configurations including action buttons
  final CalendarDatePicker2WithActionButtonsConfig config;

  /// The callback when cancel button is tapped
  final Function? onCancelTapped;

  /// The callback when ok button is tapped
  final Function? onOkTapped;

  @override
  State<CalendarDatePicker2WithActionButtons> createState() =>
      _CalendarDatePicker2WithActionButtonsState();
}

class _CalendarDatePicker2WithActionButtonsState
    extends State<CalendarDatePicker2WithActionButtons> {
  List<DateTime?> _values = [];
  List<DateTime?> _editCache = [];
  final HapticController hapticController = Get.put(HapticController());
  @override
  void initState() {
    _values = widget.value;
    _editCache = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(
      covariant CalendarDatePicker2WithActionButtons oldWidget) {
    var isValueSame = oldWidget.value.length == widget.value.length;

    if (isValueSame) {
      for (var i = 0; i < oldWidget.value.length; i++) {
        var isSame = (oldWidget.value[i] == null && widget.value[i] == null) ||
            DateUtils.isSameDay(oldWidget.value[i], widget.value[i]);
        if (!isSame) {
          isValueSame = false;
          break;
        }
      }
    }

    if (!isValueSame) {
      _values = widget.value;
      _editCache = widget.value;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MediaQuery.removePadding(
          context: context,
          child: CalendarDatePicker2(
           isHome: widget.isHome!,
            value: [..._editCache],
            config: widget.config,
            onValueChanged: (values) => _editCache = values,
            onDisplayedMonthChanged: widget.onDisplayedMonthChanged,
          ),
        ),
        SizedBox(height: widget.config.gapBetweenCalendarAndButtons ?? 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCancelButton(Theme.of(context).colorScheme, localizations),
            if ((widget.config.gapBetweenCalendarAndButtons ?? 0) > 0)
              SizedBox(width: widget.config.gapBetweenCalendarAndButtons),
            _buildOkButton(Theme.of(context).colorScheme, localizations),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelButton(
      ColorScheme colorScheme, MaterialLocalizations localizations) {
    return GestureDetector(
      onTap: () => setState(() {
        _editCache = _values;
        widget.onCancelTapped?.call();
        if ((widget.config.openedFromDialog ?? false) &&
            (widget.config.closeDialogOnCancelTapped ?? true)) {
          Navigator.pop(context);
        }
      }),
      child: Container(
        padding: widget.config.buttonPadding ??
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: widget.config.cancelButton ??
            Text(
              localizations.cancelButtonLabel.toUpperCase(),
              style: widget.config.cancelButtonTextStyle ??
                  AppFontStyle.cairoRegularStyle.copyWith(
                    color: widget.config.selectedDayHighlightColor ??
                        colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
            ),
      ),
    );
  }

  Widget _buildOkButton(
      ColorScheme colorScheme, MaterialLocalizations localizations) {
    return GestureDetector(
      onTap: () {
        hapticController.triggerHapticFeedback(
            vibration: VibrateType.heavyImpact,
            hapticFeedback: HapticFeedback.heavyImpact);
        setState(() {
          _values = _editCache;
          widget.onValueChanged?.call(_values);
          widget.onOkTapped?.call();
          if ((widget.config.openedFromDialog ?? false) &&
              (widget.config.closeDialogOnOkTapped ?? true)) {
            Navigator.pop(context, _values);
          }
        });
      },
      child: Container(
        padding: widget.config.buttonPadding ??
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: widget.config.okButton ??
            Text(
              localizations.okButtonLabel.toUpperCase(),
              style: widget.config.okButtonTextStyle ??
                  AppFontStyle.cairoRegularStyle.copyWith(
                    color: widget.config.selectedDayHighlightColor ??
                        colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
            ),
      ),
    );
  }
}
