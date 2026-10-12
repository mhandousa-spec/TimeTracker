/// Module: todo / t2_todo_form / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_page.dart
/// Purpose: Declares `TodoFormPage` — S2 "Creating To Do List" (no
///          [TodoFormPage.initial]) and "Editing To Do List" (with one).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma: LIST TO DO → Forms 1:30279 / 1:30098 / 1:30905 / 1:29923 (iPad
/// landscape), 1:30771 (portrait), 1:33404 (iPhone); dialogs 1:32857 /
/// 1:32925 (create) and 1:33085 / 1:33098 (edit).
///
/// Pushed inside the To-Do module navigator. Provides its own
/// [TodoFormCubit]; needs nothing from the list screen. The page owns the
/// TextEditingControllers and the picked times (MASTER_CODE_REVIEW §16); the
/// cubit owns the draft, validation and the write.
///
/// Flow: Create/Save → `validate()` → confirm dialog → `submit()` → success
/// dialog → pop. A failed submit shows the reason and leaves the form as is.
/// Create/Save is disabled until `TodoFormState.canSubmit` (valid draft and,
/// when editing, at least one change). Tapping it while disabled runs
/// `validate()` so each missing required field shows its error, and scrolls
/// the first one into view when it is off-screen — no dialog, no submit.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/controller/todo_form_cubit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_actions.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_basic_fields.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_frequency_section.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/widgets/todo_form_schedule_section.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoFormPage extends StatelessWidget {
  const TodoFormPage({super.key, this.initial});

  /// The to-do being edited; null opens the create form.
  final TodoEntity? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoFormCubit>(
      create: (_) => GetIt.instance<TodoFormCubit>(param1: initial),
      child: _TodoFormView(initial: initial),
    );
  }
}

class _TodoFormView extends StatefulWidget {
  const _TodoFormView({this.initial});

  final TodoEntity? initial;

  @override
  State<_TodoFormView> createState() => _TodoFormViewState();
}

class _TodoFormViewState extends State<_TodoFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  /// Kept apart from the cubit's dates so a time picked before its date
  /// survives until the date arrives.
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  /// Scroll targets for [_showMissingFields], in on-screen order.
  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _priorityKey = GlobalKey();
  final GlobalKey _scheduleKey = GlobalKey();
  final GlobalKey _frequencyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final TodoEntity? initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _descriptionController =
        TextEditingController(text: initial?.description ?? '');
    final DateTime? start = initial?.startAt;
    final DateTime? end = initial?.endAt;
    if (start != null) _startTime = TimeOfDay.fromDateTime(start);
    if (end != null) _endTime = TimeOfDay.fromDateTime(end);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  TodoFormCubit get _cubit => context.read<TodoFormCubit>();

  /// [date]'s day at [time] (midnight when no time was picked yet).
  static DateTime _combine(DateTime date, TimeOfDay? time) => DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );

  void _onScheduledChanged(bool value) {
    _cubit.scheduledToggled(value);
    if (!value) {
      setState(() {
        _startTime = null;
        _endTime = null;
      });
    }
  }

  void _onStartDate(DateTime date) =>
      _cubit.startChanged(_combine(date, _startTime));

  void _onEndDate(DateTime date) => _cubit.endChanged(_combine(date, _endTime));

  void _onStartTime(TimeOfDay time) {
    setState(() => _startTime = time);
    final DateTime? date = _cubit.state.draft.startAt;
    if (date != null) _cubit.startChanged(_combine(date, time));
  }

  void _onEndTime(TimeOfDay time) {
    setState(() => _endTime = time);
    final DateTime? date = _cubit.state.draft.endAt;
    if (date != null) _cubit.endChanged(_combine(date, time));
  }

  /// Discard / Discard Changes — nothing is written; just leave.
  void _discard() => Navigator.of(context).maybePop();

  /// Function Name: [_submit]
  ///
  /// Purpose: Validate, then run the confirm → submit → success flow. The
  /// success dialog only appears when the write really succeeded.
  ///
  /// Return type: [Future<void>]
  Future<void> _submit() async {
    final TodoFormCubit cubit = _cubit;
    if (!cubit.state.canSubmit || !cubit.validate()) return;
    final S s = S.of(context);
    final bool isEdit = cubit.state.isEdit;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      confirmLottie:
          isEdit ? AppAssets.lottieEditDocument : AppAssets.lottieConfirmation,
      confirmTitle: isEdit ? s.editingToDoTitle : s.creatingToDoTitle,
      confirmSubtitle: isEdit
          ? s.areYouSureYouWouldLikeToProceedWithEditingToDo
          : s.areYouSureYouWouldLikeToProceedWithCreatingToDo,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        await cubit.submit();
        return cubit.state.status == TodoFormStatus.success;
      },
      successLottie: AppAssets.successful,
      successTitle: s.successful,
      successSubtitle: isEdit
          ? s.youSuccessfullyEditedTheToDo
          : s.youSuccessfullyCreatedNewToDo,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop();
      },
    );

    if (!mounted || cubit.state.status != TodoFormStatus.failure) return;
    _showFailure(cubit);
  }

  /// Function Name: [_showMissingFields]
  ///
  /// Purpose: Tap on the DISABLED Create / Save. Reveals every required-field
  /// error under its field and, after that frame, scrolls the first one into
  /// view if it is off-screen. Never opens the confirm dialog or submits.
  ///
  /// Return type: [void]
  void _showMissingFields() {
    final TodoFormCubit cubit = _cubit;
    if (cubit.validate()) return; // e.g. edit with no change: nothing missing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? target =
          _firstErrorKey(cubit.state.errors)?.currentContext;
      if (target == null || _isFullyVisible(target)) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  GlobalKey? _firstErrorKey(Set<TodoFormError> errors) {
    if (errors.contains(TodoFormError.nameRequired)) return _nameKey;
    if (errors.contains(TodoFormError.priorityRequired)) return _priorityKey;
    if (errors.contains(TodoFormError.datesRequired) ||
        errors.contains(TodoFormError.endAfterStart)) {
      return _scheduleKey;
    }
    if (errors.contains(TodoFormError.weekDaysRequired)) return _frequencyKey;
    return null;
  }

  /// Whether [target] sits wholly inside its scroll viewport.
  static bool _isFullyVisible(BuildContext target) {
    final ScrollableState? scrollable = Scrollable.maybeOf(target);
    final RenderObject? box = target.findRenderObject();
    final RenderObject? viewport = scrollable?.context.findRenderObject();
    if (box is! RenderBox || viewport is! RenderBox) return true;
    final Rect field = box.localToGlobal(Offset.zero) & box.size;
    final Rect view = viewport.localToGlobal(Offset.zero) & viewport.size;
    return field.top >= view.top && field.bottom <= view.bottom;
  }

  void _showFailure(TodoFormCubit cubit) {
    final S s = S.of(context);
    final bool denied =
        cubit.state.errors.contains(TodoFormError.permissionDenied);
    final String reason = denied
        ? s.todoNoPermission
        : (cubit.state.errorMessage ?? s.errorOccurred);
    cubit.acknowledgeFailure();
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: s.errorOccurred,
      subtitle: reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool isEdit = widget.initial != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.toDoListTitle,
        secondTitle: isEdit ? s.editingToDoList : s.creatingToDoList,
        // The frame already fires the Low haptic for breadcrumb taps.
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: BlocBuilder<TodoFormCubit, TodoFormState>(
            builder: (BuildContext context, TodoFormState state) =>
                _content(state),
          ),
        ),
      ),
    );
  }

  Widget _content(TodoFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SlideInContent(child: _card(state)),
        SizedBox(height: 20.sp),
        SlideInContent(
          delay: const Duration(milliseconds: 100),
          child: TodoFormActions(
            isEdit: state.isEdit,
            canSubmit: state.canSubmit,
            onDiscard: _discard,
            onSubmit: _submit,
            onDisabledTap: _showMissingFields,
          ),
        ),
        SizedBox(height: 20.sp),
      ],
    );
  }

  Widget _card(TodoFormState state) {
    return Container(
      padding: EdgeInsetsDirectional.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadiusDirectional.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TodoFormBasicFields(
            state: state,
            nameController: _nameController,
            descriptionController: _descriptionController,
            nameKey: _nameKey,
            priorityKey: _priorityKey,
          ),
          SizedBox(height: 15.sp),
          TodoFormScheduleSection(
            key: _scheduleKey,
            state: state,
            startTime: _startTime,
            endTime: _endTime,
            onScheduledChanged: _onScheduledChanged,
            onStartDate: _onStartDate,
            onStartTime: _onStartTime,
            onEndDate: _onEndDate,
            onEndTime: _onEndTime,
          ),
          SizedBox(height: 15.sp),
          TodoFormFrequencySection(key: _frequencyKey, state: state),
        ],
      ),
    );
  }
}
