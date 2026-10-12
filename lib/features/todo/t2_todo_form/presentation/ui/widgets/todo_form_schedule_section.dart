/// Module: todo / t2_todo_form / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_schedule_section.dart
/// Purpose: Declares `TodoFormScheduleSection` — the "Scheduled" switch and,
///          when it is on, Start / End date + time, the "First Reminder" rows
///          and "+ Reminder".
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// The cubit stores one `DateTime` per end of the range. The page keeps the
/// picked TIME separately so a time chosen before its date is not lost; it
/// passes both in here and combines them when either changes.
///
/// Display (owner rule 7/10/2026): dates "16 Jun 2026" (`LocalizedDate.of`
/// default pattern, no commas), times "10:30 PM", both localized, all at 12. Start | End are top-aligned (`TodoPairedFields`) so an
/// error under one never shifts the other. At most [kTodoMaxReminders]
/// reminders — "+ Reminder" disappears at the cap.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/100-custom_add_row_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/controller/todo_form_cubit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_controls.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoFormScheduleSection extends StatelessWidget {
  const TodoFormScheduleSection({
    super.key,
    required this.state,
    required this.startTime,
    required this.endTime,
    required this.onScheduledChanged,
    required this.onStartDate,
    required this.onStartTime,
    required this.onEndDate,
    required this.onEndTime,
  });

  final TodoFormState state;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<bool> onScheduledChanged;
  final ValueChanged<DateTime> onStartDate;
  final ValueChanged<TimeOfDay> onStartTime;
  final ValueChanged<DateTime> onEndDate;
  final ValueChanged<TimeOfDay> onEndTime;

  @override
  Widget build(BuildContext context) {
    final bool on = state.draft.isScheduled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TodoFormSwitchRow(
          label: S.of(context).scheduled,
          value: on,
          onChanged: onScheduledChanged,
        ),
        ImplicitExpand(
          expanded: on,
          child: Padding(
            padding: EdgeInsetsDirectional.only(top: 15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TodoPairedFields(
                  start: _dateTimeGroup(context, isStart: true),
                  end: _dateTimeGroup(context, isStart: false),
                ),
                SizedBox(height: 15.sp),
                _RemindersBlock(
                  reminders: state.draft.reminders,
                  canAdd: state.canAddReminder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Label + (date field | time field). Errors: "dates required" on whichever
  /// end is missing, "end after start" on the end date.
  Widget _dateTimeGroup(BuildContext context, {required bool isStart}) {
    final DateTime? value = isStart ? state.draft.startAt : state.draft.endAt;
    final bool missing =
        state.showError(TodoFormError.datesRequired) && value == null;
    final bool order = !isStart && state.showError(TodoFormError.endAfterStart);
    final String? error = missing
        ? S.of(context).todoDatesRequired
        : (order ? S.of(context).todoEndAfterStart : null);
    final DateTime? start = state.draft.startAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TodoFieldLabel(
            isStart ? S.of(context).startDate : S.of(context).endDate),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: CustomDropdownCalendar(
                value: value,
                hint: S.of(context).todoDateHint,
                height: kTodoFieldHeight,
                valueStyle: todoFieldValueStyle,
                errorText: error,
                disablePastDates: !state.isEdit,
                firstDate: isStart || start == null
                    ? null
                    : DateTime(start.year, start.month, start.day),
                // "16 Oct 2026" / "١٦ أكتوبر ٢٠٢٦" — the default pattern.
                dateFormatter: (DateTime d) => LocalizedDate.of(context, d),
                onChanged: (DateTime? d) {
                  if (d == null) return;
                  isStart ? onStartDate(d) : onEndDate(d);
                },
              ),
            ),
            SizedBox(width: 10.sp),
            SizedBox(
              width: 100.sp,
              child: TodoTimeField(
                value: isStart ? startTime : endTime,
                hasError: error != null,
                onPicked: isStart ? onStartTime : onEndTime,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "First Reminder" + one stepper/unit row per reminder + "+ Reminder"
/// (only while [canAdd] — fewer than [kTodoMaxReminders]).
class _RemindersBlock extends StatelessWidget {
  const _RemindersBlock({required this.reminders, required this.canAdd});

  final List<TodoReminder> reminders;
  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    final TodoFormCubit cubit = context.read<TodoFormCubit>();
    return AnimatedSizeWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (reminders.isNotEmpty) TodoFieldLabel(S.of(context).firstReminder),
          for (int i = 0; i < reminders.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: 10.sp),
              child: TodoHalfWidth(
                child: _ReminderRow(
                  reminder: reminders[i],
                  onChanged: (TodoReminder r) => cubit.updateReminder(i, r),
                  onRemove: () => cubit.removeReminder(i),
                ),
              ),
            ),
          if (canAdd)
            CustomAddRowButton(
              label: S.of(context).reminder,
              onTap: cubit.addReminder,
            ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.reminder,
    required this.onChanged,
    required this.onRemove,
  });

  final TodoReminder reminder;
  final ValueChanged<TodoReminder> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool isPhone = todoFormIsPhone(context);
    return Row(
      children: <Widget>[
        TodoNumberStepper(
          value: reminder.value,
          min: kTodoStepperMin,
          max: kTodoStepperMax,
          onChanged: (int v) => onChanged(reminder.copyWith(value: v)),
        ),
        SizedBox(width: isPhone ? 10.sp : 15.sp),
        Expanded(
          child: CustomDropdown<TodoReminderUnit>(
            value: reminder.unit,
            height: kTodoFieldHeight,
            itemStyle: todoMenuItemStyle,
            items: TodoReminderUnit.values
                .map(
                  (TodoReminderUnit u) => DropdownItem<TodoReminderUnit>(
                    value: u,
                    label: u.label(context),
                  ),
                )
                .toList(),
            onChanged: (TodoReminderUnit u) =>
                onChanged(reminder.copyWith(unit: u)),
          ),
        ),
        SizedBox(width: 8.sp),
        GestureDetector(
          onTap: () {
            HapticController.high();
            onRemove();
          },
          child: CustomSvgImage(
            assetPath: AppAssets.minusCircle,
            width: 20.sp,
            height: 20.sp,
          ),
        ),
      ],
    );
  }
}
