/// Module: todo / t2_todo_form / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_basic_fields.dart
/// Purpose: Declares `TodoFormBasicFields` — Name, Priority and Description
///          (0/500) at the top of the "Creating / Editing To Do List" card.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Tablet: Name | Priority side by side (`TodoPairedFields`, top-aligned so an
/// error under one never shifts the other), then Description full width.
/// Phone (Figma 1:33404): Name, Description, Priority stacked in that order.
///
/// Owner rules (7/10/2026): required fields carry NO red star/dot, the
/// Priority options are text only (no icons), and values / menu rows are 12
/// (titles 14, hints 12 come from the core fields).
///
/// [nameKey] / [priorityKey] let the page scroll to the first missing field
/// when the disabled Create / Save is tapped.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/controller/todo_form_cubit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_controls.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoFormBasicFields extends StatelessWidget {
  const TodoFormBasicFields({
    super.key,
    required this.state,
    required this.nameController,
    required this.descriptionController,
    this.nameKey,
    this.priorityKey,
  });

  final TodoFormState state;

  /// Owned by the page State (MASTER_CODE_REVIEW §16).
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  /// Scroll targets for the page's "show what is missing" jump.
  final Key? nameKey;
  final Key? priorityKey;

  @override
  Widget build(BuildContext context) {
    final Widget name = _nameField(context);
    final Widget priority = _priorityField(context);
    final Widget description = _descriptionField(context);

    if (todoFormIsPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          name,
          SizedBox(height: 15.sp),
          description,
          SizedBox(height: 15.sp),
          priority,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TodoPairedFields(start: name, end: priority),
        SizedBox(height: 15.sp),
        description,
      ],
    );
  }

  Widget _nameField(BuildContext context) {
    final TodoFormCubit cubit = context.read<TodoFormCubit>();
    return CustomTextField(
      key: nameKey,
      controller: nameController,
      label: S.of(context).name,
      hint: S.of(context).Texthere,
      height: kTodoFieldHeight,
      valueStyle: todoFieldValueStyle,
      textInputAction: TextInputAction.next,
      errorText: state.showError(TodoFormError.nameRequired)
          ? S.of(context).fieldRequired
          : null,
      onChanged: cubit.nameChanged,
    );
  }

  Widget _priorityField(BuildContext context) {
    final TodoFormCubit cubit = context.read<TodoFormCubit>();
    return CustomDropdown<TodoPriority>(
      key: priorityKey,
      label: S.of(context).priority,
      hint: S.of(context).todoChoose,
      height: kTodoFieldHeight,
      itemStyle: todoMenuItemStyle,
      value: state.priorityChosen ? state.draft.priority : null,
      errorText: state.showError(TodoFormError.priorityRequired)
          ? S.of(context).fieldRequired
          : null,
      items: TodoPriority.values
          .map(
            (TodoPriority p) => DropdownItem<TodoPriority>(
              value: p,
              label: p.label(context),
            ),
          )
          .toList(),
      onChanged: cubit.priorityChanged,
    );
  }

  Widget _descriptionField(BuildContext context) {
    final TodoFormCubit cubit = context.read<TodoFormCubit>();
    return CustomTextField(
      controller: descriptionController,
      label: S.of(context).description,
      hint: S.of(context).Texthere,
      height: 72,
      valueStyle: todoFieldValueStyle,
      maxLines: 3,
      minLines: 3,
      maxLength: 500,
      keyboardType: TextInputType.multiline,
      onChanged: cubit.descriptionChanged,
    );
  }
}
