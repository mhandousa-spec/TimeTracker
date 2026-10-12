/// Module: todo / t2_todo_form / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_frequency_section.dart
/// Purpose: Declares `TodoFormFrequencySection` — "Set Frequency" switch and,
///          when it is on, the interval stepper, the Daily / Weekly / Monthly
///          dropdown and (Weekly only) the Sun…Sat weekday chips.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Weekday names come from intl (`DateFormat.E` / narrow `EEEEE` on phone)
/// in the active locale — never hardcoded. Chips are stored with
/// `DateTime.weekday` numbering (1 = Mon … 7 = Sun), shown Sunday-first like
/// the Figma.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/controller/todo_form_cubit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_controls.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoFormFrequencySection extends StatelessWidget {
  const TodoFormFrequencySection({super.key, required this.state});

  final TodoFormState state;

  @override
  Widget build(BuildContext context) {
    final TodoFormCubit cubit = context.read<TodoFormCubit>();
    final bool on = state.draft.hasFrequency;
    final TodoFrequency frequency = state.draft.frequency;
    final double gap = todoFormIsPhone(context) ? 10.sp : 15.sp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TodoFormSwitchRow(
          label: S.of(context).setFrequency,
          value: on,
          onChanged: cubit.frequencyToggled,
        ),
        ImplicitExpand(
          expanded: on,
          child: Padding(
            padding: EdgeInsetsDirectional.only(top: 15.sp),
            child: TodoHalfWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      TodoNumberStepper(
                        value: frequency.interval,
                        min: kTodoStepperMin,
                        max: kTodoStepperMax,
                        onChanged: (int v) => cubit.frequencyChanged(
                          frequency.copyWith(interval: v),
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(child: _unitDropdown(context, frequency)),
                    ],
                  ),
                  // A plain conditional inside one AnimatedSize (no second
                  // fade nested in the section's own ImplicitExpand): the
                  // chips are in the tree the very frame Weekly is picked.
                  AnimatedSizeWrap(
                    duration: const Duration(milliseconds: 250),
                    child: frequency.unit == TodoFrequencyUnit.weekly
                        ? Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: 80.sp + gap,
                              top: 10.sp,
                            ),
                            child: _WeekdayChips(
                              selected: frequency.weekDays,
                              error: state.showError(
                                TodoFormError.weekDaysRequired,
                              )
                                  ? S.of(context).todoWeekDaysRequired
                                  : null,
                              onToggle: (int day) => cubit.frequencyChanged(
                                frequency.copyWith(
                                  weekDays: _toggled(frequency.weekDays, day),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _unitDropdown(BuildContext context, TodoFrequency frequency) {
    return CustomDropdown<TodoFrequencyUnit>(
      value: frequency.unit,
      height: kTodoFieldHeight,
      itemStyle: todoMenuItemStyle,
      items: TodoFrequencyUnit.values
          .map(
            (TodoFrequencyUnit u) => DropdownItem<TodoFrequencyUnit>(
              value: u,
              label: u.label(context),
            ),
          )
          .toList(),
      onChanged: (TodoFrequencyUnit u) => context
          .read<TodoFormCubit>()
          .frequencyChanged(frequency.copyWith(unit: u)),
    );
  }

  static List<int> _toggled(List<int> days, int day) {
    final List<int> next = days.contains(day)
        ? days.where((int d) => d != day).toList()
        : <int>[...days, day];
    next.sort();
    return next;
  }
}

/// Sun…Sat chips — 36×36 on tablet, 25×25 single-letter on phone; the
/// selected ones turn yellow.
class _WeekdayChips extends StatelessWidget {
  const _WeekdayChips({
    required this.selected,
    required this.onToggle,
    this.error,
  });

  final List<int> selected;
  final ValueChanged<int> onToggle;
  final String? error;

  /// 4 Jan 2026 is a Sunday, so +0…+6 walks Sun → Sat.
  static final DateTime _firstSunday = DateTime(2026, 1, 4);

  @override
  Widget build(BuildContext context) {
    final bool isPhone = todoFormIsPhone(context);
    final String locale = Localizations.localeOf(context).languageCode;
    final DateFormat format =
        isPhone ? DateFormat('EEEEE', locale) : DateFormat.E(locale);
    final double size = isPhone ? 25 : 36;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: isPhone ? 8.sp : 10.sp,
          runSpacing: 8.sp,
          children: List<Widget>.generate(7, (int i) {
            final DateTime date = _firstSunday.add(Duration(days: i));
            final int weekday = date.weekday;
            return _DayChip(
              label: format.format(date),
              size: size,
              isSelected: selected.contains(weekday),
              onTap: () => onToggle(weekday),
            );
          }),
        ),
        TodoFieldErrorText(error),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticController.low();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(minWidth: size.sp, minHeight: size.sp),
        padding: EdgeInsetsDirectional.symmetric(horizontal: 4.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : kDropdownFillColor,
          borderRadius: BorderRadiusDirectional.circular(4.r),
        ),
        // widthFactor/heightFactor 1: hug the label (the min constraints
        // above keep the square) instead of stretching across the Wrap.
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            label,
            style: StyleText.fontSize12Weight400.copyWith(
              color:
                  isSelected ? AppColors.textButton : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
