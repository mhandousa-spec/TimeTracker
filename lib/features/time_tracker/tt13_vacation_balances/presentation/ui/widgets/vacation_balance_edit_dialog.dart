/// Module: time_tracker / tt13_vacation_balances / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_edit_dialog.dart
/// Purpose: Declares `showVacationBalanceEdit` (the whole Edit flow: dialog →
///          "Are You Sure…" → "Vacation Balance Edited") and
///          `VacationBalanceEditDialog` (employee · Year · Total Days · Used ·
///          Remaining).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// `Edit_Vacation_Balance` (brief §B). Not in Figma — built from the house
/// dialog pieces (`TtDialogHeader`, core `CustomTextField`, Discard / Save)
/// like the Grant Access dialog. Owner rules: Save stays grey until the
/// value is valid AND changed (tap shows the error), validation = red
/// border + message, the number is typeable (Arabic digits too, one
/// decimal), Remaining previews as you type. Then the house confirm →
/// success flow (`CustomDialogManager.showDialogFlow`, scale-in).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/widgets/vacation_balance_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [showVacationBalanceEdit]
///
/// Purpose: The whole Edit Vacation Balance flow for [row].
///
/// Return type: [Future<void>]
Future<void> showVacationBalanceEdit(BuildContext context, VacationBalanceRow row) async {
  final VacationBalancesCubit cubit = context.read<VacationBalancesCubit>();
  final double? total = await CustomDialogManager.showContent<double>(
    context: context,
    width: TtDialogWidth.standard,
    // 13/10/2026 (owner V2): scrolls above the keyboard instead of overflowing.
    scrollable: true,
    child: VacationBalanceEditDialog(row: row),
  );
  if (total == null || !context.mounted) return;
  final S s = S.of(context);
  await CustomDialogManager.showDialogFlow(
    context: context,
    confirmWidth: 411,
    scaleIn: true,
    confirmLottie: AppAssets.lottieConfirmation,
    confirmTitle: s.timeTrackerEditVacationBalance,
    confirmSubtitle: s.timeTrackerEditVacationConfirm,
    confirmYesText: s.yes,
    confirmNoText: s.no,
    onConfirm: () => cubit.editTotal(row.employee.email, total),
    successLottie: AppAssets.successful,
    successTitle: s.timeTrackerVacationEditedTitle,
    successSubtitle: s.timeTrackerVacationEdited,
  );
  if (!context.mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
  final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
  cubit.acknowledgeFailure();
  await showTimeTrackerFailure(context, denied: denied);
}

class VacationBalanceEditDialog extends StatefulWidget {
  const VacationBalanceEditDialog({super.key, required this.row});

  final VacationBalanceRow row;

  @override
  State<VacationBalanceEditDialog> createState() => _VacationBalanceEditDialogState();
}

class _VacationBalanceEditDialogState extends State<VacationBalanceEditDialog> {
  late final TextEditingController _total;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _total = TextEditingController(
      text: widget.row.isStored ? VacationBalanceList.days(widget.row.balance.totalDays) : '',
    );
  }

  @override
  void dispose() {
    _total.dispose();
    super.dispose();
  }

  String? _errorText(S s, VacationTotalError? e) {
    switch (e) {
      case VacationTotalError.required:
        return s.timeTrackerTotalDaysRequired;
      case VacationTotalError.invalid:
        return s.timeTrackerTotalDaysInvalid;
      case VacationTotalError.tooLarge:
        return s.timeTrackerTotalDaysTooLarge;
      case null:
        return null;
    }
  }

  /// A read-only value in the SAME field as Total Days, so the paired rows
  /// stay level (owner rule); keyed by its value so it refreshes as you type.
  Widget _value(String label, String value, {Color? color}) => CustomTextField(
        key: ValueKey<String>('vacationValue_${label}_$value'),
        label: label,
        initialValue: value,
        readOnly: true,
        height: 36,
        valueStyle: StyleText.fontSize12Weight400.copyWith(color: color ?? AppColors.text),
      );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final VacationBalanceRow row = widget.row;
    final VacationTotalError? error = VacationBalanceEditRules.validate(_total.text);
    final double? total = VacationBalanceEditRules.parseTotal(_total.text);
    final bool changed = !row.isStored || total != row.balance.totalDays;
    final bool valid = error == null && total != null;
    final double left = valid ? (total - row.balance.usedDays).clamp(0, double.infinity).toDouble() : row.balance.remainingDays;
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtDialogHeader(title: s.timeTrackerEditVacationBalance, icon: AppAssets.edit),
          SizedBox(height: 15.h),
          Row(
            children: <Widget>[
              TimeTrackerAvatar(photo: row.employee.photo, size: 40.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(row.employee.name(isArabic: ar),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                    Text(TimeTrackerFormat.orDash(row.employee.department(isArabic: ar)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          TtPair(
            start: _value(s.timeTrackerRangeYear, LocalizedNumber.digits(context, '${row.balance.year}')),
            end: CustomTextField(
              key: const ValueKey<String>('vacationTotalField'),
              controller: _total,
              label: s.timeTrackerTotalDays,
              hint: s.timeTrackerLateAfterHint,
              height: 36,
              errorText: _showErrors ? _errorText(s, error) : null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(6)],
              valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(height: 15.h),
          TtPair(
            start: _value(s.timeTrackerUsedDays, VacationBalanceText.days(context, row.balance.usedDays)),
            end: _value(
              s.timeTrackerRemainingDays,
              VacationBalanceText.days(context, left),
              color: left <= 0 ? AppColors.red : AppColors.lightGreen,
            ),
          ),
          SizedBox(height: 20.h),
          TimeTrackerFormActions(
            primaryKey: const ValueKey<String>('vacationEditSave'),
            primaryTitle: s.save,
            canSubmit: valid && changed,
            onDiscard: () => Navigator.of(context).pop(),
            onSubmit: () => Navigator.of(context).pop(total),
            onDisabledTap: () => setState(() => _showErrors = true),
          ),
        ],
      ),
    );
  }
}
