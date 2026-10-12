/// Module: time_tracker / tt8_request_types / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_form_page.dart
/// Purpose: Declares `RequestTypeFormPage` — "Tracking Time › Creating
///          Request Type" / "› Editing Request Type": Request Name + Arabic
///          twin · Description + Arabic twin (0/500) · HR Approval · Manager
///          Approval · Requires Description · Requires Attachments · Deducts
///          From Vacation Balance · (edit) Active · Limit Location / Limit
///          Department Availability (chips) · Discard / Create | Save.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:43870` (create) / `661:44042` (edit) + the
/// `Is_Deducted_From_Vacation_Balance` switch (FINAL SPEC §2). Dialogs:
/// `661:44397` → `661:44410` (edit); create uses the house pattern (none
/// drawn). The Active switch shows only with `Change_Request_Type_Status`.
/// Provides its own `RequestTypeFormCubit`; locations / departments come
/// from `RequestTypesCubit`. The page owns the text controllers.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_type_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_type_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestTypeFormPage extends StatelessWidget {
  const RequestTypeFormPage({super.key, this.original});

  /// The type to edit (null = create).
  final RequestType? original;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestTypeFormCubit>(
      create: (_) => GetIt.instance<RequestTypeFormCubit>(param1: original),
      child: const _RequestTypeFormView(),
    );
  }
}

class _RequestTypeFormView extends StatefulWidget {
  const _RequestTypeFormView();

  @override
  State<_RequestTypeFormView> createState() => _RequestTypeFormViewState();
}

class _RequestTypeFormViewState extends State<_RequestTypeFormView> {
  late final TextEditingController _nameEn;
  late final TextEditingController _nameAr;
  late final TextEditingController _descEn;
  late final TextEditingController _descAr;

  RequestTypeFormCubit get _cubit => context.read<RequestTypeFormCubit>();
  RequestType get _draft => _cubit.state.draft;

  @override
  void initState() {
    super.initState();
    final RequestType t = context.read<RequestTypeFormCubit>().state.draft;
    _nameEn = TextEditingController(text: t.nameEn);
    _nameAr = TextEditingController(text: t.nameAr);
    _descEn = TextEditingController(text: t.descriptionEn);
    _descAr = TextEditingController(text: t.descriptionAr);
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _descEn.dispose();
    _descAr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final RequestTypeFormCubit cubit = _cubit;
    if (!cubit.revealErrors()) return;
    final S s = S.of(context);
    final bool edit = cubit.state.isEdit;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      confirmLottie: edit ? AppAssets.lottieEditDocument : AppAssets.lottieConfirmation,
      confirmTitle: edit ? s.timeTrackerEditingRequestType : s.timeTrackerCreatingRequestType,
      confirmSubtitle: edit ? s.timeTrackerEditRequestTypeConfirm : s.timeTrackerCreateRequestTypeConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: cubit.submit,
      successLottie: AppAssets.successful,
      successTitle: edit ? s.timeTrackerRequestTypeEditedTitle : s.timeTrackerRequestTypeCreatedTitle,
      successSubtitle: edit ? s.timeTrackerRequestTypeEdited : s.timeTrackerRequestTypeCreated,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
    if (!mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool edit = _cubit.state.isEdit;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: edit ? s.timeTrackerEditingRequestType : s.timeTrackerCreatingRequestType,
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: BlocBuilder<RequestTypeFormCubit, RequestTypeFormState>(
            builder: (BuildContext context, RequestTypeFormState state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // UI quality pass (owner 13:45 #8, Figma 661:44042): the
                // status switch sits at the top end of the Edit form.
                if (state.isEdit && GetIt.instance<TimeTrackerAccess>().canChangeRequestTypeStatus) ...<Widget>[
                  TtStatusSwitch(
                    key: const ValueKey<String>('requestTypeActiveSwitch'),
                    label: s.timeTrackerActive,
                    value: state.draft.status == RequestTypeStatus.active,
                    onChanged: (bool v) => _cubit.update(_draft.copyWith(
                      status: v ? RequestTypeStatus.active : RequestTypeStatus.inactive,
                    )),
                  ),
                  SizedBox(height: 10.h),
                ],
                SlideInContent(child: TtFormCard(child: _fields(state))),
                SizedBox(height: 20.h),
                TimeTrackerFormActions(
                  primaryKey: const ValueKey<String>('requestTypeSubmitButton'),
                  primaryTitle: edit ? s.save : s.create,
                  canSubmit: state.canSubmit,
                  onDiscard: () => Navigator.of(context).maybePop(),
                  onSubmit: _submit,
                  onDisabledTap: _cubit.revealErrors,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text(TextEditingController c, String label, {required bool arabic, String? error,
      bool multiline = false, required ValueChanged<String> onChanged, Key? key}) {
    final S s = S.of(context);
    return CustomTextField(
      key: key,
      controller: c,
      label: label,
      hint: arabic ? s.timeTrackerTextHereAr : s.textHere,
      height: multiline ? 72 : 36,
      maxLines: multiline ? 3 : 1,
      minLines: multiline ? 3 : 1,
      maxLength: multiline ? RequestTypeFormRules.maxDescriptionLength : null,
      keyboardType: multiline ? TextInputType.multiline : null,
      textDirection: arabic ? TextDirection.rtl : null,
      errorText: error,
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      onChanged: onChanged,
    );
  }

  Widget _fields(RequestTypeFormState state) {
    final S s = S.of(context);
    final RequestType d = state.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TtPair(
          start: _text(_nameEn, s.timeTrackerRequestName, arabic: false,
              key: const ValueKey<String>('requestTypeNameEn'),
              error: state.shows(RequestTypeFormError.nameEnRequired) ? s.timeTrackerNameRequired : null,
              onChanged: (String v) => _cubit.update(_draft.copyWith(nameEn: v))),
          end: _text(_nameAr, s.timeTrackerRequestNameAr, arabic: true,
              key: const ValueKey<String>('requestTypeNameAr'),
              error: state.shows(RequestTypeFormError.nameArRequired) ? s.timeTrackerArabicNameRequired : null,
              onChanged: (String v) => _cubit.update(_draft.copyWith(nameAr: v))),
        ),
        SizedBox(height: 15.h),
        _text(_descEn, s.timeTrackerDescription, arabic: false, multiline: true,
            onChanged: (String v) => _cubit.update(_draft.copyWith(descriptionEn: v))),
        SizedBox(height: 15.h),
        _text(_descAr, s.timeTrackerDescriptionAr, arabic: true, multiline: true,
            onChanged: (String v) => _cubit.update(_draft.copyWith(descriptionAr: v))),
        SizedBox(height: 15.h),
        TtPair(
          start: TtSwitchRow(label: s.timeTrackerHrApproval, value: d.isHrApprovalRequired,
              onChanged: (bool v) => _cubit.update(_draft.copyWith(isHrApprovalRequired: v))),
          end: TtSwitchRow(label: s.timeTrackerRequiresDescription, value: d.isDescriptionRequired,
              onChanged: (bool v) => _cubit.update(_draft.copyWith(isDescriptionRequired: v))),
        ),
        SizedBox(height: 15.h),
        TtPair(
          start: TtSwitchRow(label: s.timeTrackerManagerApproval, value: d.isManagerApprovalRequired,
              onChanged: (bool v) => _cubit.update(_draft.copyWith(isManagerApprovalRequired: v))),
          end: TtSwitchRow(label: s.timeTrackerRequiresAttachments, value: d.isAttachmentRequired,
              onChanged: (bool v) => _cubit.update(_draft.copyWith(isAttachmentRequired: v))),
        ),
        SizedBox(height: 15.h),
        TtPair(
          start: TtSwitchRow(
            key: const ValueKey<String>('requestTypeDeductsSwitch'),
            label: s.timeTrackerDeductsFromVacation,
            value: d.isDeductedFromVacationBalance,
            onChanged: (bool v) => _cubit.update(_draft.copyWith(isDeductedFromVacationBalance: v)),
          ),
        ),
        SizedBox(height: 15.h),
        _availability(state),
      ],
    );
  }

  Widget _availability(RequestTypeFormState state) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final RequestTypesState list = context.watch<RequestTypesCubit>().state;
    final RequestType d = state.draft;
    final Map<String, String> locationNames = <String, String>{
      for (final WorkLocation l in list.locations) l.id: l.name(isArabic: ar),
    };
    Widget limit({
      required String label,
      required bool on,
      required ValueChanged<bool> onToggle,
      required Map<String, String> options,
      required List<String> values,
      required ValueChanged<List<String>> onChanged,
      required String? error,
      required Key key,
    }) =>
        Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TtPair(start: TtSwitchRow(label: label, value: on, onChanged: onToggle)),
            if (on) ...<Widget>[
              SizedBox(height: 10.h),
              TtPair(
                start: CustomMultiSelectDropdown<String>(
                  hint: s.timeTrackerChooseHere,
                  alwaysShowHint: true,
                  height: 36,
                  itemStyle: StyleText.fontSize12Weight400,
                  values: values,
                  items: <MultiSelectDropdownItem<String>>[
                    for (final MapEntry<String, String> o in options.entries)
                      MultiSelectDropdownItem<String>(value: o.key, label: o.value),
                  ],
                  onChanged: onChanged,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: <Widget>[
                  for (final String id in values)
                    TtRemovableChip(
                      label: options[id] ?? id,
                      onRemove: () => onChanged(<String>[for (final String x in values) if (x != id) x]),
                    ),
                ],
              ),
              TtFieldError(error),
            ],
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        limit(
          key: const ValueKey<String>('requestTypeLimitLocations'),
          label: s.timeTrackerLimitLocationAvailability,
          on: state.limitLocations,
          onToggle: _cubit.setLimitLocations,
          options: locationNames,
          values: d.locationIds,
          onChanged: (List<String> v) => _cubit.update(_draft.copyWith(locationIds: v)),
          error: state.shows(RequestTypeFormError.locationsRequired) ? s.timeTrackerChooseOneLocation : null,
        ),
        SizedBox(height: 15.h),
        limit(
          key: const ValueKey<String>('requestTypeLimitDepartments'),
          label: s.timeTrackerLimitDepartmentAvailability,
          on: state.limitDepartments,
          onToggle: _cubit.setLimitDepartments,
          options: list.departments,
          values: d.departmentIds,
          onChanged: (List<String> v) => _cubit.update(_draft.copyWith(departmentIds: v)),
          error: state.shows(RequestTypeFormError.departmentsRequired) ? s.timeTrackerChooseOneDepartment : null,
        ),
      ],
    );
  }
}
