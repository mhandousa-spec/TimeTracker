/// Module: todo / t2_todo_form / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_controls.dart
/// Purpose: Small building blocks shared by the "Creating / Editing To Do
///          List" sections — field label, error line, switch row, half-width
///          wrapper, the "− 1 +" stepper and the time field.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma (LIST TO DO → Forms 1:29923 / 1:30098, iPhone 1:33404): fields are
/// 36 high on the grey fill with 4 radius; the stepper is 80 wide; the time
/// field 100 wide with a 16 clock icon. "+ Reminder" is the core
/// `CustomAddRowButton`.
///
/// Owner type scale (7/10/2026): field TITLE 14, HINT 12, VALUE 12 — typed
/// text, picked dates/times, dropdown values AND dropdown menu items. Use
/// [todoFieldValueStyle] / [todoMenuItemStyle] so every field agrees.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Phone layout switch — the same `width < 600` test `SideFrameMasterServices`
/// and `buildResponsiveFields` use, so the form flips with its frame.
bool todoFormIsPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 600;

/// Height of every one-line control on the form (Figma: 36).
const double kTodoFieldHeight = 36;

/// 12 regular in the body colour — what a typed or picked VALUE looks like
/// (Name, Description, picked dates). A getter: the colour follows the theme.
TextStyle get todoFieldValueStyle =>
    StyleText.fontSize12Weight400.copyWith(color: AppColors.text);

/// 12 regular for dropdown MENU rows. The dropdown recolours each row itself
/// (selected / hovered / idle), so only size and weight matter here.
TextStyle get todoMenuItemStyle => StyleText.fontSize12Weight400;

/// "Start Date" / "First Reminder" — a label drawn above a control that has
/// none of its own (the date+time pair, the stepper rows).
class TodoFieldLabel extends StatelessWidget {
  const TodoFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: kFieldLabelGap.sp),
      child: Text(
        text,
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      ),
    );
  }
}

/// Red validation line under a control that has no `errorText` slot.
class TodoFieldErrorText extends StatelessWidget {
  const TodoFieldErrorText(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 4.sp),
      child: Text(
        text,
        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
      ),
    );
  }
}

/// Keeps [child] in the START half of the card on tablet (switch rows,
/// stepper rows sit under the Name column in Figma); full width on phone.
class TodoHalfWidth extends StatelessWidget {
  const TodoHalfWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (todoFormIsPhone(context)) return child;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: child),
        SizedBox(width: 15.sp),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

/// Two fields side by side on tablet (stacked on phone). Both columns are
/// TOP-aligned, so a validation line under one field grows only that column
/// and the two inputs stay on the same line (`buildResponsiveFields` centres
/// its Row, which pushed the error-free field down).
class TodoPairedFields extends StatelessWidget {
  const TodoPairedFields({
    super.key,
    required this.start,
    required this.end,
  });

  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) {
    if (todoFormIsPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[start, SizedBox(height: 15.sp), end],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: start),
        SizedBox(width: 15.sp),
        Expanded(child: end),
      ],
    );
  }
}

/// "Scheduled" / "Set Frequency" — label at the start, switch at the end.
class TodoFormSwitchRow extends StatelessWidget {
  const TodoFormSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return TodoHalfWidth(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            ),
          ),
          DefaultSwitchButton(
            value: value,
            onChanged: (bool next) {
              HapticController.low();
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

/// The "− 1 +" box (80 × 36). The number in the middle is an editable field:
/// tap it and type (digits only, Latin or Arabic-Indic), or use − / +.
/// Always stays within [min]…[max].
///
/// Holds its own TextEditingController (MASTER_CODE_REVIEW §16) and keeps it
/// in sync with [value] whenever the cubit changes it from outside.
class TodoNumberStepper extends StatefulWidget {
  const TodoNumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  State<TodoNumberStepper> createState() => _TodoNumberStepperState();
}

class _TodoNumberStepperState extends State<TodoNumberStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First fill needs the locale (Arabic-Indic digits in Arabic).
    if (_controller.text.isEmpty) _syncText();
  }

  @override
  void didUpdateWidget(TodoNumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only overwrite the text when it no longer says the cubit's value AND
    // the value really moved (− / +, row removed) or the field is idle — so a
    // user mid-way through retyping (field briefly empty) is not overwritten.
    final bool differs = _parse(_controller.text) != widget.value;
    final bool moved = widget.value != oldWidget.value;
    if (differs && (moved || !_focusNode.hasFocus)) _syncText();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncText() {
    final String text = LocalizedNumber.of(context, widget.value);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Leaving the field with nothing (or 0) typed restores the last value.
  void _onFocusChange() {
    if (!_focusNode.hasFocus && _parse(_controller.text) != widget.value) {
      _syncText();
    }
  }

  /// Latin or Arabic-Indic digits → int; null when empty.
  static int? _parse(String text) {
    if (text.isEmpty) return null;
    final String latin = String.fromCharCodes(
      text.codeUnits.map(
        (int unit) => unit >= 0x0660 && unit <= 0x0669 ? unit - 0x0630 : unit,
      ),
    );
    return int.tryParse(latin);
  }

  void _onTyped(String text) {
    final int? typed = _parse(text);
    if (typed == null || typed < widget.min) return;
    final int clamped = typed > widget.max ? widget.max : typed;
    if (clamped != typed) {
      final String fixed = LocalizedNumber.of(context, clamped);
      _controller.value = TextEditingValue(
        text: fixed,
        selection: TextSelection.collapsed(offset: fixed.length),
      );
    }
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final int value = widget.value;
    return Container(
      width: 80.sp,
      height: kTodoFieldHeight.sp,
      decoration: BoxDecoration(
        color: kDropdownFillColor,
        borderRadius: BorderRadiusDirectional.circular(4.r),
      ),
      child: Row(
        children: <Widget>[
          _StepButton(
            assetPath: AppAssets.crmMinus,
            iconHeight: 2,
            onTap:
                value > widget.min ? () => widget.onChanged(value - 1) : null,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9\u0660-\u0669]')),
                LengthLimitingTextInputFormatter(2),
              ],
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
              cursorColor: AppColors.text,
              decoration: const InputDecoration.collapsed(hintText: null),
              onChanged: _onTyped,
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
          _StepButton(
            assetPath: AppAssets.add,
            iconHeight: 12,
            onTap:
                value < widget.max ? () => widget.onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.assetPath,
    required this.iconHeight,
    required this.onTap,
  });

  final String assetPath;
  final double iconHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticController.low();
              onTap!();
            },
      child: SizedBox(
        width: 26.sp,
        height: kTodoFieldHeight.sp,
        child: Center(
          child: CustomSvgImage(
            assetPath: assetPath,
            width: 10.sp,
            height: iconHeight.sp,
            fit: BoxFit.contain,
            color: onTap == null
                ? AppColors.secondaryText.withValues(alpha: 0.4)
                : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

/// The "10:30 PM 🕒" field (100 × 36, 12-hour, localized). Opens the
/// platform time picker.
class TodoTimeField extends StatelessWidget {
  const TodoTimeField({
    super.key,
    required this.value,
    required this.onPicked,
    this.hasError = false,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onPicked;
  final bool hasError;

  Future<void> _pick(BuildContext context) async {
    HapticController.low();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TimeOfDay? time = value;
    final String text = time == null
        ? S.of(context).todoTimeHint
        : LocalizedDate.of(
            context,
            DateTime(2000, 1, 1, time.hour, time.minute),
            pattern: 'hh:mm a',
          );
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        height: kTodoFieldHeight.sp,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 8.sp),
        decoration: BoxDecoration(
          color: kDropdownFillColor,
          borderRadius: BorderRadiusDirectional.circular(4.r),
          border: hasError ? Border.all(color: AppColors.red) : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: time == null ? kDropdownHintColor : AppColors.text,
                ),
              ),
            ),
            CustomSvgImage(
              assetPath: AppAssets.timeSelectorIcon,
              width: 16.sp,
              height: 16.sp,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
