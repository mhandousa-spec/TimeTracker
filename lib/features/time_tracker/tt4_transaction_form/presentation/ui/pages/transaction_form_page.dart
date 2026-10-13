/// Module: time_tracker / tt4_transaction_form / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: transaction_form_page.dart
/// Purpose: Declares `TransactionFormPage` — "Tracking Time › Creating
///          Transaction": Check In date + time · Check Out date + time ·
///          Description (0/500) · Transaction Document · Discard / Submit.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:80120` / `661:80227`; dialogs `661:80044` ("Are You Sure You
/// Want To Create This Transaction ?") → `661:80112` ("You Successfully
/// Submitted This Transaction"). Pushed inside the module's nested Navigator
/// (shell rail / nav bar stay). Provides its own `TransactionFormCubit`.
/// The page owns the text controller and the picked TIMES; the cubit owns
/// the draft (playbook §3). Breadcrumb frame = core `SideFrameMasterServices`.
/// Updated: 13/10/2026 - owner rule: Description and Transaction Document are
/// required (red border + message, Submit stays disabled until both exist).
/// Updated: 9/10/2026 - code review finding 6: the Check Out field says
/// when the check-out is not on the check-in day (or the next day for an
/// overnight shift) or the span passes 24 hours.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/controller/transaction_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/ui/widgets/transaction_form_fields.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TransactionFormPage extends StatelessWidget {
  const TransactionFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      // 9/10/2026 (code review finding 6): learn the shift (overnight?).
      create: (_) => GetIt.instance<TransactionFormCubit>()..init(),
      child: const _TransactionFormView(),
    );
  }
}

class _TransactionFormView extends StatefulWidget {
  const _TransactionFormView();

  @override
  State<_TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<_TransactionFormView> {
  final TextEditingController _description = TextEditingController();
  DateTime? _inDate;
  TimeOfDay? _inTime;
  DateTime? _outDate;
  TimeOfDay? _outTime;

  TransactionFormCubit get _cubit => context.read<TransactionFormCubit>();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  static DateTime? _combine(DateTime? date, TimeOfDay? time) =>
      date == null || time == null
          ? null
          : DateTime(date.year, date.month, date.day, time.hour, time.minute);

  void _pushIn() {
    final DateTime? value = _combine(_inDate, _inTime);
    if (value != null) _cubit.checkInChanged(value);
  }

  void _pushOut() {
    final DateTime? value = _combine(_outDate, _outTime);
    if (value != null) _cubit.checkOutChanged(value);
  }

  Future<void> _submit() async {
    final TransactionFormCubit cubit = _cubit;
    if (!cubit.revealErrors()) return;
    final S s = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: s.timeTrackerCreatingTransaction,
      confirmSubtitle: s.timeTrackerCreateTransactionConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: cubit.submit,
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerSubmittedTransaction,
      successSubtitle: s.timeTrackerTransactionSubmitted,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
    if (!mounted || cubit.state.status != TransactionFormStatus.failure) return;
    final bool denied = cubit.state.permissionDenied;
    cubit.acknowledgeFailure();
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: s.errorOccurred,
      subtitle: denied ? s.timeTrackerNoPermission : s.timeTrackerActionFailed,
    );
  }

  String? _timeError(TransactionFormState state, {required bool isIn}) {
    final S s = S.of(context);
    if (isIn && state.shows(TransactionError.checkInRequired)) {
      return s.timeTrackerCheckInRequired;
    }
    if (!isIn && state.shows(TransactionError.checkOutRequired)) {
      return s.timeTrackerCheckOutRequired;
    }
    if (!isIn && state.shows(TransactionError.checkOutBeforeCheckIn)) {
      return s.timeTrackerCheckOutAfterCheckIn;
    }
    if (state.shows(TransactionError.inFuture)) {
      return s.timeTrackerTransactionInFuture;
    }
    // 9/10/2026 (code review finding 6).
    if (!isIn && state.shows(TransactionError.checkOutWrongDay)) {
      return state.overnightShift ? s.timeTrackerCheckOutSameOrNextDay : s.timeTrackerCheckOutSameDay;
    }
    if (!isIn && state.shows(TransactionError.tooLong)) {
      return s.timeTrackerTransactionTooLong;
    }
    return null;
  }

  /// The Discard · primary row (pinned on a phone, under the form on a tablet).
  Widget _actions(TransactionFormState state) {
    return TransactionFormActions(
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
              child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
                builder: (BuildContext context, TransactionFormState state) => _actions(state),
              ),
            )
          : null,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: s.timeTrackerCreatingTransaction,
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
            builder: (BuildContext context, TransactionFormState state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SlideInContent(child: _card(state)),
                if (!context.isPhone) ...<Widget>[
                  SizedBox(height: 20.h),
                  _actions(state),
                  SizedBox(height: 20.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(TransactionFormState state) {
    final S s = S.of(context);
    String? fileError;
    if (state.fileTooLarge) {
      fileError = s.timeTrackerFileTooLarge;
    } else if (state.uploadFailed) {
      fileError = s.timeTrackerUploadFailed;
    } else if (state.shows(TransactionError.documentRequired)) {
      // 13/10/2026 (owner rule): the document is required.
      fileError = s.timeTrackerTransactionDocumentRequired;
    }
    return Container(
      padding: EdgeInsetsDirectional.all(15.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TransactionDateTimeRow(
            key: const ValueKey<String>('transactionCheckInRow'),
            label: s.timeTrackerCheckInDate,
            date: _inDate,
            time: _inTime,
            error: _timeError(state, isIn: true),
            onDate: (DateTime d) {
              setState(() => _inDate = d);
              _pushIn();
            },
            onTime: (TimeOfDay t) {
              setState(() => _inTime = t);
              _pushIn();
            },
          ),
          SizedBox(height: 15.h),
          TransactionDateTimeRow(
            key: const ValueKey<String>('transactionCheckOutRow'),
            label: s.timeTrackerCheckOutDate,
            date: _outDate,
            time: _outTime,
            error: _timeError(state, isIn: false),
            onDate: (DateTime d) {
              setState(() => _outDate = d);
              _pushOut();
            },
            onTime: (TimeOfDay t) {
              setState(() => _outTime = t);
              _pushOut();
            },
          ),
          SizedBox(height: 15.h),
          CustomTextField(
            controller: _description,
            label: s.timeTrackerDescription,
            hint: s.textHere,
            height: 72,
            maxLines: 3,
            minLines: 3,
            maxLength: TransactionRules.maxDescriptionLength,
            keyboardType: TextInputType.multiline,
            // 13/10/2026 (owner rule): the description is required.
            errorText: state.shows(TransactionError.descriptionRequired)
                ? s.timeTrackerTransactionDescriptionRequired
                : null,
            valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: _cubit.descriptionChanged,
          ),
          SizedBox(height: 15.h),
          TransactionDocumentField(
            attachment: state.attachment,
            isUploading: state.isUploading,
            error: fileError,
            onUpload: _cubit.pickAndUpload,
            onRemove: _cubit.removeAttachment,
          ),
        ],
      ),
    );
  }
}
