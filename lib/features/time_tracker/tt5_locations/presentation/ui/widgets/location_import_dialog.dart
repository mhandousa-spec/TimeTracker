/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: location_import_dialog.dart
/// Purpose: Declares `showLocationImportDialog` and `LocationImportDialog`
///          — Import Locations: Download Template (CSV, pre-filled with the
///          current locations) · Upload File (CSV / Excel) · validation
///          preview (new / updated / unchanged / skipped + every problem by
///          line and column) · Discard / Import → confirm → success.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// `Import_Locations` (phase 3 brief): never deletes; a blank cell keeps the
/// stored value; rows with a problem are skipped. Not in Figma — built from
/// the house dialog pieces (`CustomDialogManager.showContent`, header badge,
/// Discard / primary). The confirm flow runs after this dialog closes.
/// Updated: 9/10/2026 - phase 5: the Import button uses the module's
/// `timeTrackerImport` (the core `import` key reads "تصدير" in Arabic).

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
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [showLocationImportDialog]
///
/// Purpose: The whole Import Locations flow.
///
/// Return type: [Future<void>]
Future<void> showLocationImportDialog(BuildContext context) async {
  final LocationsCubit cubit = context.read<LocationsCubit>();
  final LocationImportPlan? plan = await CustomDialogManager.showContent<LocationImportPlan>(
    context: context,
    width: 620,
    child: BlocProvider<LocationsCubit>.value(value: cubit, child: const LocationImportDialog()),
  );
  if (plan == null || !context.mounted) return;
  final S s = S.of(context);
  await CustomDialogManager.showDialogFlow(
    context: context,
    confirmWidth: 411,
    scaleIn: true,
    confirmLottie: AppAssets.lottieConfirmation,
    confirmTitle: s.timeTrackerImportLocations,
    confirmSubtitle: s.timeTrackerImportConfirm,
    confirmYesText: s.yes,
    confirmNoText: s.no,
    onConfirm: refreshingCheckIn(context, () => cubit.applyImport(plan)),
    successLottie: AppAssets.successful,
    successTitle: s.timeTrackerImportDoneTitle,
    successSubtitle: s.timeTrackerImportDone,
  );
  if (!context.mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
  final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
  cubit.acknowledgeFailure();
  await showTimeTrackerFailure(context, denied: denied);
}

class LocationImportDialog extends StatefulWidget {
  const LocationImportDialog({super.key});

  @override
  State<LocationImportDialog> createState() => _LocationImportDialogState();
}

class _LocationImportDialogState extends State<LocationImportDialog> {
  LocationImportPlan? _plan;
  String? _error;
  bool _reading = false;

  TimeTrackerSheetReader get _reader => GetIt.instance.isRegistered<TimeTrackerSheetReader>()
      ? GetIt.instance<TimeTrackerSheetReader>()
      : const TimeTrackerSheetReader();

  Future<void> _template() {
    final List<WorkLocation> existing = <WorkLocation>[
      for (final WorkLocation l in context.read<LocationsCubit>().state.locations)
        if (l.status != LocationStatus.deleted) l,
    ];
    return exportTimeTrackerCsv(
      context: context,
      defaultFileName: S.of(context).timeTrackerImportTemplateName,
      header: LocationImportRules.headings,
      rows: <List<String>>[for (final WorkLocation l in existing) LocationImportRules.rowOf(l)],
    );
  }

  Future<void> _upload() async {
    final S s = S.of(context);
    final TimeTrackerSheetReader reader = _reader;
    setState(() {
      _reading = true;
      _error = null;
    });
    final LocationImportRead read = await context.read<LocationsCubit>().readImport(
          () async => (await reader.pickAndRead())?.grid,
        );
    if (!mounted) return;
    final LocationImportPlan? plan = read.plan;
    setState(() {
      _reading = false;
      if (read.unreadable) {
        _plan = null;
        _error = s.timeTrackerImportFileError;
      } else if (plan != null) {
        _plan = plan;
        _error = plan.missingNameColumn
            ? s.timeTrackerImportNoNameColumn
            : (plan.writable.isEmpty ? s.timeTrackerImportNothing : null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final LocationImportPlan? plan = _plan;
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtDialogHeader(title: s.timeTrackerImportLocations, icon: AppAssets.upload),
          SizedBox(height: 12.h),
          TtImportSteps(
            templateKey: const ValueKey<String>('locationImportTemplate'),
            uploadKey: const ValueKey<String>('locationImportUpload'),
            templateBody: s.timeTrackerImportStep1Locations,
            fillBody: s.timeTrackerImportStep2Locations,
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
          if (plan != null && !plan.missingNameColumn) ...<Widget>[
            SizedBox(height: 15.h),
            _Preview(plan: plan),
          ],
          SizedBox(height: 20.h),
          TimeTrackerFormActions(
            primaryKey: const ValueKey<String>('locationImportSubmit'),
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

/// Summary line + one row per file line (name · action · problems).
class _Preview extends StatelessWidget {
  const _Preview({required this.plan});

  final LocationImportPlan plan;

  String _action(S s, LocationImportAction a) {
    switch (a) {
      case LocationImportAction.create:
        return s.timeTrackerImportActionCreate;
      case LocationImportAction.update:
        return s.timeTrackerImportActionUpdate;
      case LocationImportAction.unchanged:
        return s.timeTrackerImportActionUnchanged;
      case LocationImportAction.skip:
        return s.timeTrackerImportActionSkip;
    }
  }

  String _problem(S s, LocationImportIssue issue) {
    final String column = issue.column?.heading ?? '';
    if (identical(issue, LocationImportIssue.duplicateName)) return s.timeTrackerImportDuplicate;
    switch (issue.error) {
      case null:
      case LocationFormError.latitudeInvalid:
      case LocationFormError.longitudeInvalid:
        return s.timeTrackerImportUnreadable(column);
      case LocationFormError.nameEnRequired:
        return s.timeTrackerNameRequired;
      case LocationFormError.nameArRequired:
        return s.timeTrackerArabicNameRequired;
      case LocationFormError.coordinatesRequired:
        return s.timeTrackerCoordinatesRequired;
      case LocationFormError.radiusRequired:
        return s.timeTrackerRadiusRequired;
      case LocationFormError.workTimesSame:
        return s.timeTrackerWorkTimesSame;
      case LocationFormError.workingDaysRequired:
        return s.timeTrackerWorkingDaysRequired;
      case LocationFormError.breakLengthRequired:
        return s.timeTrackerBreakLengthRequired;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    String n(LocationImportAction a) => LocalizedNumber.of(context, plan.count(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          s.timeTrackerImportSummary(
            n(LocationImportAction.create),
            n(LocationImportAction.update),
            n(LocationImportAction.unchanged),
            n(LocationImportAction.skip),
          ),
          key: const ValueKey<String>('locationImportSummary'),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 220.h),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              for (final LocationImportRow r in plan.rows)
                Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 6.h),
                  child: Text(
                    '${s.timeTrackerImportLine(LocalizedNumber.of(context, r.line))} · '
                    '${r.name.isEmpty ? '-' : r.name} · ${_action(s, r.action)}'
                    '${r.issues.isEmpty ? '' : ' — ${r.issues.map((LocationImportIssue i) => _problem(s, i)).join('; ')}'}',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: r.action == LocationImportAction.skip ? AppColors.red : AppColors.text,
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
