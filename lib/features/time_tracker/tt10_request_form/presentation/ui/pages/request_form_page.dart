/// Module: time_tracker / tt10_request_form / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_form_page.dart
/// Purpose: Declares `RequestFormPage` — "Tracking Time › Creating New
///          Request": Request Type · Request Description (0/500) · Start Date
///          · End Date · All Day (off → Start Time / End Time) · Request
///          Attachments · Discard / Submit.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:16900` / `661:17016` (title fixed to "Creating New Request" —
/// owner fix); dialogs `661:16832` "Creating Request" — "Are You Sure You
/// Want To Create This Request ?" → `661:16808` "Successful" — "Your Request
/// Has Been Successfully Submitted". Request Type lists ACTIVE types
/// available to the employee's location AND department; Description and
/// Attachments become required when the type says so; a type that deducts
/// from the vacation balance cannot ask for more days than remain. Submit
/// stays grey until valid (a tap shows the errors). Provides its own
/// `RequestFormCubit`; the page owns the text controller.
/// Updated: 9/10/2026 - code review: "no vacation balance — contact HR"
/// (finding 10) and "you already have a request for this time" errors.
/// Updated: 9/10/2026 - data model: the remaining days shown are the
/// balance of the year the request starts in. Owner round 9 option b: a
/// draft spanning two years may be sent; when one of its years cannot cover
/// its share the error names that year ("2027 has only 2 vacation days
/// left") so the employee shortens the request.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/ui/widgets/request_form_fields.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestFormPage extends StatelessWidget {
  const RequestFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestFormCubit>(
      create: (_) => GetIt.instance<RequestFormCubit>()..init(),
      child: const _RequestFormView(),
    );
  }
}

class _RequestFormView extends StatefulWidget {
  const _RequestFormView();

  @override
  State<_RequestFormView> createState() => _RequestFormViewState();
}

class _RequestFormViewState extends State<_RequestFormView> {
  final TextEditingController _description = TextEditingController();

  RequestFormCubit get _cubit => context.read<RequestFormCubit>();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final RequestFormCubit cubit = _cubit;
    if (!cubit.revealErrors()) return;
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: s.timeTrackerCreatingRequest,
      confirmSubtitle: s.timeTrackerCreateRequestConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () => cubit.submit(isArabic: ar),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerSuccessful,
      successSubtitle: s.timeTrackerRequestSubmitted,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
    if (!mounted || cubit.state.status != RequestFormStatus.failure) return;
    final bool denied = cubit.state.permissionDenied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  /// The Discard · primary row (pinned on a phone, under the form on a tablet).
  Widget _actions(RequestFormState state) {
    final S s = S.of(context);
    return TimeTrackerFormActions(
      primaryKey: const ValueKey<String>('requestSubmitButton'),
      primaryTitle: s.submit,
      canSubmit: state.canSubmit,
      onDiscard: () => Navigator.of(context).maybePop(),
      onSubmit: _submit,
      onDisabledTap: _cubit.revealErrors,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      // 12/10/2026 (owner R8): phone — the action row stays fixed.
      bottomNavigationBar: context.isPhone
          ? TtPinnedFormActions(
              child: BlocBuilder<RequestFormCubit, RequestFormState>(
                builder: (BuildContext context, RequestFormState state) => _actions(state),
              ),
            )
          : null,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: s.timeTrackerCreatingNewRequest,
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: BlocBuilder<RequestFormCubit, RequestFormState>(
          builder: (BuildContext context, RequestFormState state) {
            return SideFrameScrollableBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SlideInContent(child: TtFormCard(child: _fields(state))),
                  if (!context.isPhone) ...<Widget>[
                    SizedBox(height: 20.h),
                    _actions(state),
                    SizedBox(height: 20.h),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// A day count without a useless ".0" (2.5 stays 2.5).
  static num _days(double value) =>
      value == value.roundToDouble() ? value.round() : double.parse(value.toStringAsFixed(1));

  String? _error(RequestFormState state, Map<RequestFormError, String> messages) {
    for (final MapEntry<RequestFormError, String> e in messages.entries) {
      if (state.shows(e.key)) return e.value;
    }
    return null;
  }

  /// 9/10/2026 (owner round 9 b): for a draft spanning two years, the
  /// first year that cannot cover its share ("2027 has only 2 vacation days
  /// left"); null for a one-year draft (the usual messages apply).
  String? _yearShortMessage(RequestFormState state, RequestDraft d) {
    if (RequestFormRules.daysByYear(d, schedule: state.setup.schedule).length < 2) return null;
    final VacationShortfall? short = RequestFormRules.shortfall(
      d,
      schedule: state.setup.schedule,
      balance: state.setup.balanceForDraft(d),
      balances: state.setup.balances,
    );
    if (short == null) return null;
    return S.of(context).timeTrackerYearBalanceShort(
          LocalizedNumber.digits(context, '${short.year}'),
          LocalizedNumber.digits(context, VacationBalanceList.days(short.daysLeft)),
        );
  }

  Widget _fields(RequestFormState state) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final RequestDraft d = state.draft;
    final String? yearShort = _yearShortMessage(state, d);
    final List<RequestType> types = state.setup.types;
    final RequestType? type = d.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TtPair(
          start: CustomDropdown<RequestType>(
            key: const ValueKey<String>('requestTypeDropdown'),
            label: s.timeTrackerRequestType,
            hint: s.timeTrackerChooseHere,
            height: 36,
            itemStyle: StyleText.fontSize12Weight400,
            value: d.type,
            errorText: _error(state, <RequestFormError, String>{
              RequestFormError.typeRequired: s.timeTrackerRequestTypeRequired,
            }),
            items: <DropdownItem<RequestType>>[
              for (final RequestType t in types) DropdownItem<RequestType>(value: t, label: t.name(isArabic: ar)),
            ],
            onChanged: (RequestType? t) {
              if (t != null) _cubit.typeChanged(t);
            },
          ),
        ),
        if (types.isEmpty && state.setupReady)
          Padding(
            key: const ValueKey<String>('requestNoTypes'),
            padding: EdgeInsetsDirectional.only(top: 6.h),
            child: Text(s.timeTrackerNoRequestTypesAvailable,
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
          ),
        // 13/10/2026 (owner P2): nothing else until a type is chosen; then
        // only what THAT type needs.
        if (type == null && !(types.isEmpty && state.setupReady))
          Padding(
            key: const ValueKey<String>('requestPickTypeFirst'),
            padding: EdgeInsetsDirectional.only(top: 8.h),
            child: Text(s.timeTrackerPickTypeFirst,
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
          ),
        if (type != null) ..._typeFields(state, s, d, type, yearShort),
      ],
    );
  }

  /// The fields of the chosen [type]: Description ("Optional" unless the
  /// type requires it), dates, times and — only when the type requires
  /// them — Attachments.
  List<Widget> _typeFields(RequestFormState state, S s, RequestDraft d, RequestType type, String? yearShort) {
    return <Widget>[
      SizedBox(height: 15.h),
      CustomTextField(
        key: const ValueKey<String>('requestDescription'),
        controller: _description,
        label: type.isDescriptionRequired
            ? s.timeTrackerRequestDescription
            : '${s.timeTrackerRequestDescription} (${s.timeTrackerOptional})',
        hint: s.textHere,
        height: 72,
        maxLines: 3,
        minLines: 3,
        maxLength: RequestFormRules.maxDescriptionLength,
        keyboardType: TextInputType.multiline,
        errorText: _error(state, <RequestFormError, String>{
          RequestFormError.descriptionRequired: s.timeTrackerDescriptionRequired,
        }),
        valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
        onChanged: _cubit.descriptionChanged,
      ),
      SizedBox(height: 15.h),
      TtPair(
        start: CustomDropdownCalendar(
          key: const ValueKey<String>('requestStartDate'),
          label: s.timeTrackerStartDate,
          hint: s.chooseDate,
          value: d.startDate,
          height: 36,
          errorText: _error(state, <RequestFormError, String>{
            RequestFormError.startDateRequired: s.timeTrackerStartDateRequired,
          }),
          dateFormatter: (DateTime x) => LocalizedDate.of(context, x),
          onChanged: (DateTime? x) {
            if (x != null) _cubit.startDateChanged(x);
          },
        ),
        end: CustomDropdownCalendar(
          key: const ValueKey<String>('requestEndDate'),
          label: s.timeTrackerEndDate,
          hint: s.chooseDate,
          value: d.endDate,
          height: 36,
          errorText: _error(state, <RequestFormError, String>{
            RequestFormError.endDateRequired: s.timeTrackerEndDateRequired,
            RequestFormError.endBeforeStart: s.timeTrackerEndAfterStart,
          }),
          dateFormatter: (DateTime x) => LocalizedDate.of(context, x),
          onChanged: (DateTime? x) {
            if (x != null) _cubit.endDateChanged(x);
          },
        ),
      ),
      SizedBox(height: 15.h),
      TtPair(
        start: TtSwitchRow(
          key: const ValueKey<String>('requestAllDaySwitch'),
          label: s.timeTrackerAllDay,
          value: d.isAllDay,
          onChanged: _cubit.allDayChanged,
        ),
      ),
      if (!d.isAllDay) ...<Widget>[
        SizedBox(height: 15.h),
        TtPair(
          start: RequestTimeField(
            key: const ValueKey<String>('requestStartTime'),
            label: s.timeTrackerStartTime,
            minutes: d.startMinutes,
            error: _error(state, <RequestFormError, String>{
              RequestFormError.startTimeRequired: s.timeTrackerStartTimeRequired,
            }),
            onChanged: _cubit.startTimeChanged,
          ),
          end: RequestTimeField(
            key: const ValueKey<String>('requestEndTime'),
            label: s.timeTrackerEndTime,
            minutes: d.endMinutes,
            error: _error(state, <RequestFormError, String>{
              RequestFormError.endTimeRequired: s.timeTrackerEndTimeRequired,
            }),
            onChanged: _cubit.endTimeChanged,
          ),
        ),
      ],
      // 9/10/2026 (owner round 9 b): a draft over two years names the year.
      if (yearShort != null &&
          (state.shows(RequestFormError.exceedsBalance) || state.shows(RequestFormError.noBalance)))
        KeyedSubtree(
          key: const ValueKey<String>('requestYearBalanceError'),
          child: TtFieldError(yearShort),
        ),
      if (yearShort == null && state.shows(RequestFormError.exceedsBalance))
        KeyedSubtree(
          key: const ValueKey<String>('requestBalanceError'),
          child: TtFieldError(s.timeTrackerExceedsBalance(
            TimeTrackerFormat.count(context, _days(RequestFormRules.requestedDays(d, schedule: state.setup.schedule))),
            TimeTrackerFormat.count(context, _days(state.setup.balanceForDraft(d)?.remainingDays ?? 0)),
          )),
        ),
      // 9/10/2026 (code review finding 10 + overlap check).
      if (yearShort == null && state.shows(RequestFormError.noBalance))
        KeyedSubtree(
          key: const ValueKey<String>('requestNoBalanceError'),
          child: TtFieldError(s.timeTrackerNoBalanceEmployee),
        ),
      if (state.shows(RequestFormError.overlapsExisting))
        KeyedSubtree(
          key: const ValueKey<String>('requestOverlapError'),
          child: TtFieldError(s.timeTrackerRequestOverlaps),
        ),
      if (type.isAttachmentRequired || d.attachments.isNotEmpty) ...<Widget>[
        SizedBox(height: 15.h),
        RequestAttachmentsField(
          files: d.attachments,
          isUploading: state.isUploading,
          canAdd: state.canAddAttachment,
          onUpload: _cubit.pickAndUpload,
          onRemove: _cubit.removeAttachment,
          error: state.fileTooLarge
              ? s.timeTrackerFileTooLarge
              : state.uploadFailed
                  ? s.timeTrackerUploadFailed
                  : _error(state, <RequestFormError, String>{
                      RequestFormError.attachmentsRequired: s.timeTrackerAttachmentsRequired,
                    }),
        ),
      ],
    ];
  }
}
