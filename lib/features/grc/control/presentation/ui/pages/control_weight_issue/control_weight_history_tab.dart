/// Module: Policy Management
/// Description: The Control Weight Issue page's History tab: a table of
///              every recorded weight change across one Policy's Controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, ControlWeightHistoryCubit, EmployeeHelper, intl
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [ControlWeightHistoryTab]
///
/// purpose: render the History tab of the Control Weight Issue page,
///          reading an already-provided [ControlWeightHistoryCubit] (the
///          parent page owns the [BlocProvider]).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightHistoryTab extends StatelessWidget {
  const ControlWeightHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControlWeightHistoryCubit, ControlWeightHistoryState>(
      builder: (context, state) {
        if (state is ControlWeightHistoryLoading || state is ControlWeightHistoryInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is ControlWeightHistoryFailure) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                state.message,
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final loaded = state as ControlWeightHistoryLoaded;
        // Empty, not failed -- the Failure branch above keeps its own
        // message. This is the app's single wordless empty state.
        if (loaded.entries.isEmpty) {
          return const Center(child: CustomEmptyState());
        }

        final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

        // iPhone (375): the seven-column table becomes one card per recorded
        // change, matching the phone design. iPad (768) and desktop (1024)
        // keep the table -- its FlexColumnWidths already fit 768.
        if (screenSizeOf(context) == ScreenSize.mobile) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < loaded.entries.length; i++) ...[
                  if (i != 0) SizedBox(height: 10.h),
                  _historyCard(
                    context: context,
                    entry: loaded.entries[i],
                    noOfDepartments: loaded
                            .departmentCounts[loaded.entries[i].controlId] ??
                        0,
                    dateFormat: dateFormat,
                  ),
                ],
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(52),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1.4),
                  4: FlexColumnWidth(1.4),
                  5: FlexColumnWidth(1.4),
                  6: FlexColumnWidth(1.6),
                },
                children: [
                  _headerRow(context),
                  for (var i = 0; i < loaded.entries.length; i++)
                    _dataRow(
                      context: context,
                      entry: loaded.entries[i],
                      noOfDepartments: loaded.departmentCounts[loaded.entries[i].controlId] ?? 0,
                      index: i,
                      dateFormat: dateFormat,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // PHONE (375): one card per recorded weight change
  // ------------------------------------------------------------------

  /// Same shape PolicyWeightHistoryTab uses, so the two History tabs read
  /// identically on a phone: a label/value line per column of the table.
  Widget _historyCard({
    required BuildContext context,
    required ControlWeightHistoryEntry entry,
    required int noOfDepartments,
    required DateFormat dateFormat,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _historyLine(
            context,
            grcTr(context, 'Control Name'),
            context.isArabic ? entry.controlsNameAr : entry.controlsNameEn,
          ),
          _historyLine(
            context,
            grcTr(context, 'Control Weight Current'),
            formatControlWeight(entry.weightCurrent),
          ),
          _historyLine(
            context,
            grcTr(context, 'Control Weight Previous'),
            formatControlWeight(entry.weightPrevious),
          ),
          _historyLine(
            context,
            grcTr(context, 'No of Departments'),
            '$noOfDepartments',
          ),
          _historyLine(
            context,
            grcTr(context, 'Changed By'),
            employeeDisplayName(context, entry.changedByEmail),
          ),
          _historyLine(
            context,
            grcTr(context, 'Date Of Action'),
            dateFormat.format(entry.dateOfAction),
          ),
        ],
      ),
    );
  }

  Widget _historyLine(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '$label:',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 4,
            child: Text(
              value.trim().isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _headerRow(BuildContext context) {
    final headers = [
      'NO',
      'Changed By',
      'Control Name',
      'No of Departments',
      'Control Weight Current',
      'Control Weight Previous',
      'Date Of Action',
    ];
    return TableRow(
      decoration: const BoxDecoration(color: Colors.black),
      children: headers
          .map(
            (header) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: Text(grcTr(context, header),
                style: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _dataRow({
    required BuildContext context,
    required ControlWeightHistoryEntry entry,
    required int noOfDepartments,
    required int index,
    required DateFormat dateFormat,
  }) {
    final isEven = index % 2 == 0;
    return TableRow(
      decoration: BoxDecoration(color: isEven ? AppColors.background : AppColors.field),
      children: [
        _cell(Text('${index + 1}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(employeeDisplayName(context, entry.changedByEmail),
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text(context.isArabic ? entry.controlsNameAr : entry.controlsNameEn,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text('$noOfDepartments', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(formatControlWeight(entry.weightCurrent), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text))),
        _cell(Text(formatControlWeight(entry.weightPrevious), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(dateFormat.format(entry.dateOfAction), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h), child: child);
  }
}
