/// Module: time_tracker / tt13_vacation_balances / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_import_dialog.dart
/// Purpose: Declares `showVacationBalanceImport` and
///          `VacationBalanceImportDialog` — Import Vacation Balances:
///          Download Template (CSV: Email · Year · Total Days, pre-filled with
///          every employee) · Upload File (CSV / Excel) · validation preview
///          (new / updated / unchanged / skipped + each problem by line) ·
///          Discard / Import → confirm → success.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// `Import_Vacation_Balances` (brief §B — "validation preview like the
/// locations import; never deletes"). Same pieces and flow as
/// `LocationImportDialog` (file reading in the data layer,
/// `TimeTrackerSheetReader`); the confirm flow runs after this dialog
/// closes.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/local_data_source/time_tracker_sheet_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [showVacationBalanceImport]
///
/// Purpose: The whole Import Vacation Balances flow.
///
/// Return type: [Future<void>]
Future<void> showVacationBalanceImport(BuildContext context) async {
  final VacationBalancesCubit cubit = context.read<VacationBalancesCubit>();
  final VacationImportPlan? plan = await CustomDialogManager.showContent<VacationImportPlan>(
    context: context,
    width: 620,
    child: BlocProvider<VacationBalancesCubit>.value(value: cubit, child: const VacationBalanceImportDialog()),
  );
  if (plan == null || !context.mounted) return;
  final S s = S.of(context);
  await CustomDialogManager.showDialogFlow(
    context: context,
    confirmWidth: 411,
    scaleIn: true,
    confirmLottie: AppAssets.lottieConfirmation,
    confirmTitle: s.timeTrackerImportVacationBalances,
    confirmSubtitle: s.timeTrackerVacationImportConfirm,
    confirmYesText: s.yes,
    confirmNoText: s.no,
    onConfirm: () => cubit.applyImport(plan),
    successLottie: AppAssets.successful,
    successTitle: s.timeTrackerVacationImportDoneTitle,
    successSubtitle: s.timeTrackerVacationImportDone,
  );
  if (!context.mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
  final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
  cubit.acknowledgeFailure();
  await showTimeTrackerFailure(context, denied: denied);
}

class VacationBalanceImportDialog extends StatefulWidget {
  const VacationBalanceImportDialog({super.key});

  @override
  State<VacationBalanceImportDialog> createState() => _VacationBalanceImportDialogState();
}

class _VacationBalanceImportDialogState extends State<VacationBalanceImportDialog> {
  VacationImportPlan? _plan;
  String? _error;
  bool _reading = false;

  TimeTrackerSheetReader get _reader => GetIt.instance.isRegistered<TimeTrackerSheetReader>()
      ? GetIt.instance<TimeTrackerSheetReader>()
      : const TimeTrackerSheetReader();

  Future<void> _template() {
    final List<VacationBalanceRow> rows = context.read<VacationBalancesCubit>().state.rows;
    return exportTimeTrackerCsv(
      context: context,
      defaultFileName: S.of(context).timeTrackerVacationTemplateName,
      header: VacationBalanceImportRules.headings,
      rows: <List<String>>[for (final VacationBalanceRow r in rows) VacationBalanceImportRules.templateRow(r)],
    );
  }

  Future<void> _upload() async {
    final S s = S.of(context);
    final TimeTrackerSheetReader reader = _reader;
    setState(() {
      _reading = true;
      _error = null;
    });
    final VacationImportRead read = await context.read<VacationBalancesCubit>().readImport(
          () async => (await reader.pickAndRead())?.grid,
        );
    if (!mounted) return;
    final VacationImportPlan? plan = read.plan;
    setState(() {
      _reading = false;
      if (read.unreadable) {
        _plan = null;
        _error = s.timeTrackerImportFileError;
      } else if (plan != null) {
        _plan = plan;
        _error = plan.missingColumns
            ? s.timeTrackerVacationImportNoColumns
            : (plan.writable.isEmpty ? s.timeTrackerImportNothing : null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final VacationImportPlan? plan = _plan;
    final String year = LocalizedNumber.digits(context, '${context.read<VacationBalancesCubit>().state.year}');
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtDialogHeader(title: s.timeTrackerImportVacationBalances, icon: AppAssets.upload),
          SizedBox(height: 12.h),
          TtImportSteps(
            templateKey: const ValueKey<String>('vacationImportTemplate'),
            uploadKey: const ValueKey<String>('vacationImportUpload'),
            templateBody: s.timeTrackerImportStep1Balances,
            fillBody: s.timeTrackerImportStep2Balances(year),
            onTemplate: _template,
            onUpload: _reading ? () {} : _upload,
          ),
          if (_reading) ...<Widget>[
            SizedBox(height: 15.h),
            const Center(child: CircleProgressMaster()),
          ],
          if (_error != null) ...<Widget>[
            SizedBox(height: 12.h),
            Text(_error!, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
          ],
          if (plan != null && !plan.missingColumns) ...<Widget>[
            SizedBox(height: 15.h),
            VacationImportPreview(plan: plan),
          ],
          SizedBox(height: 20.h),
          TimeTrackerFormActions(
            primaryKey: const ValueKey<String>('vacationImportSubmit'),
            primaryTitle: s.timeTrackerImport,
            canSubmit: plan != null && plan.writable.isNotEmpty,
            onDiscard: () => Navigator.of(context).pop(),
            onSubmit: () => Navigator.of(context).pop(plan),
            onDisabledTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Summary line + one line per file row (e-mail · action · problems).
class VacationImportPreview extends StatelessWidget {
  const VacationImportPreview({super.key, required this.plan});

  final VacationImportPlan plan;

  String _action(S s, VacationImportAction a) {
    switch (a) {
      case VacationImportAction.create:
        return s.timeTrackerImportActionCreate;
      case VacationImportAction.update:
        return s.timeTrackerImportActionUpdate;
      case VacationImportAction.unchanged:
        return s.timeTrackerImportActionUnchanged;
      case VacationImportAction.skip:
        return s.timeTrackerImportActionSkip;
    }
  }

  String _problem(BuildContext context, S s, VacationImportIssue issue) {
    switch (issue) {
      case VacationImportIssue.unknownEmployee:
        return s.timeTrackerImportUnknownEmployee;
      case VacationImportIssue.duplicateEmail:
        return s.timeTrackerImportDuplicateEmail;
      case VacationImportIssue.wrongYear:
        return s.timeTrackerImportWrongYear(LocalizedNumber.digits(context, '${plan.year}'));
      case VacationImportIssue.totalRequired:
        return s.timeTrackerTotalDaysRequired;
      case VacationImportIssue.totalInvalid:
        return s.timeTrackerTotalDaysInvalid;
      case VacationImportIssue.totalTooLarge:
        return s.timeTrackerTotalDaysTooLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    String n(VacationImportAction a) => LocalizedNumber.of(context, plan.count(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          s.timeTrackerImportSummary(
            n(VacationImportAction.create),
            n(VacationImportAction.update),
            n(VacationImportAction.unchanged),
            n(VacationImportAction.skip),
          ),
          key: const ValueKey<String>('vacationImportSummary'),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 220.h),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              for (final VacationImportRow r in plan.rows)
                Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 6.h),
                  child: Text(
                    '${s.timeTrackerImportLine(LocalizedNumber.of(context, r.line))} · '
                    '${r.email.isEmpty ? '-' : r.email} · ${_action(s, r.action)}'
                    '${r.issues.isEmpty ? '' : ' — ${r.issues.map((VacationImportIssue i) => _problem(context, s, i)).join('; ')}'}',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: r.action == VacationImportAction.skip ? AppColors.red : AppColors.text,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
