/// Module: Policy Management
/// Description: The Policy Weight Issue page's History tab: a table of
///              every recorded weight change across the module's policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, PolicyWeightHistoryCubit, EmployeeHelper, intl
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [PolicyWeightHistoryTab]
///
/// purpose: render the History tab of the Policy Weight Issue page,
///          reading an already-provided [PolicyWeightHistoryCubit] (the
///          parent page owns the [BlocProvider], same convention as the
///          Policies/Champions/Owners tabs on GrcModuleDetailsPage).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightHistoryTab extends StatelessWidget {
  const PolicyWeightHistoryTab({super.key});

  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PolicyWeightHistoryCubit, PolicyWeightHistoryState>(
      builder: (context, state) {
        if (state is PolicyWeightHistoryLoading || state is PolicyWeightHistoryInitial) {
          // Same screen's other tab -- same spinner.
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: const CircleProgressMaster(),
          );
        }

        if (state is PolicyWeightHistoryFailure) {
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

        final loaded = state as PolicyWeightHistoryLoaded;
        // Empty, not failed -- the Failure branch above keeps its own
        // message. This is the app's single wordless empty state.
        if (loaded.entries.isEmpty) {
          return const Center(child: CustomEmptyState());
        }

        final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

        // iPhone (375): the seven-column history table becomes a stack of
        // label/value cards, one per change, matching the phone design.
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
                    noOfControls:
                        loaded.controlCounts[loaded.entries[i].policyId] ?? 0,
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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(52),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1.2),
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
                      noOfControls: loaded.controlCounts[loaded.entries[i].policyId] ?? 0,
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
  // PHONE: one card per history entry (MAGDY 869:129438)
  //
  //   (person) Changed By: (avatar) Name          No of controls: 5
  //   Policy Name: X
  //   Policy Weight Current : 20        Policy Weight Previous: 10
  // ------------------------------------------------------------------
  static const String _personIcon =
      'assets/icons_assets/main_icons_assets/person_outline.svg';
  static const String _maleAvatar =
      'assets/icons_assets/main_icons_assets/assets_male.svg';

  Widget _historyCard({
    required BuildContext context,
    required PolicyWeightHistoryEntry entry,
    required int noOfControls,
    required DateFormat dateFormat,
  }) {
    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CustomSvgImage(
                      assetPath: _personIcon,
                      width: 12.sp,
                      height: 12.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${FormatHelper.capitalize(grcTr(context, 'Changed By'))}:',
                      style: _labelStyle,
                    ),
                    SizedBox(width: 5.w),
                    _avatar(12),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text(
                        FormatHelper.capitalize(
                            employeeDisplayName(context, entry.changedByEmail)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _valueStyle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _pair(context, 'No of Controls',
                  LocalizedNumber.of(context, noOfControls)),
            ],
          ),
          SizedBox(height: 8.h),
          _pair(
            context,
            'Policy Name',
            context.isArabic ? entry.policyNameAr : entry.policyNameEn,
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _pair(
                  context,
                  'Policy Weight Current',
                  _num(context, _formatWeight(entry.weightCurrent)),
                ),
              ),
              SizedBox(width: 8.w),
              _pair(
                context,
                'Policy Weight Previous',
                _num(context, _formatWeight(entry.weightPrevious)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle =>
      StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);

  TextStyle get _valueStyle =>
      StyleText.fontSize12Weight400.copyWith(color: AppColors.text);

  String _num(BuildContext context, String digits) =>
      LocalizedNumber.digits(context, digits);

  /// "Label: value" -- grey label, dark value, one line.
  Widget _pair(BuildContext context, String labelKey, String value) {
    return Text.rich(
      TextSpan(
        text: '${FormatHelper.capitalize(grcTr(context, labelKey))}: ',
        style: _labelStyle,
        children: [
          TextSpan(
            text: value.trim().isEmpty ? '-' : FormatHelper.capitalize(value),
            style: _valueStyle,
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// The male silhouette avatar every Changed By shows in the design.
  Widget _avatar(double radius) {
    return ClipOval(
      child: CustomSvgImage(
        assetPath: _maleAvatar,
        width: (radius * 2).sp,
        height: (radius * 2).sp,
        fit: BoxFit.cover,
      ),
    );
  }

  TableRow _headerRow(BuildContext context) {
    final headers = [
      'NO',
      'Changed By',
      'Policy Name',
      'No of Controls',
      'Policy Weight Current',
      'Policy Weight Previous',
      'Date Of Action',
    ];
    return TableRow(
      decoration: BoxDecoration(color: AppColors.blackShadow),
      children: [
        for (final header in headers)
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: Text(
              FormatHelper.capitalize(grcTr(context, header)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.white),
            ),
          ),
      ],
    );
  }

  TableRow _dataRow({
    required BuildContext context,
    required PolicyWeightHistoryEntry entry,
    required int noOfControls,
    required int index,
    required DateFormat dateFormat,
  }) {
    final int rowNumber = index + 1;
    return TableRow(
      decoration: BoxDecoration(
        color:
            rowNumber.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
      ),
      children: [
        _textCell(LocalizedNumber.of(context, rowNumber)),
        _cell(Row(
          children: [
            _avatar(15),
            SizedBox(width: 6.w),
            Flexible(
              child: _cellText(
                  employeeDisplayName(context, entry.changedByEmail)),
            ),
          ],
        )),
        _textCell(context.isArabic ? entry.policyNameAr : entry.policyNameEn),
        _textCell(LocalizedNumber.of(context, noOfControls)),
        _textCell(_num(context, _formatWeight(entry.weightCurrent))),
        _textCell(_num(context, _formatWeight(entry.weightPrevious))),
        _textCell(_num(context, dateFormat.format(entry.dateOfAction))),
      ],
    );
  }

  Widget _cellText(String text) => Text(
        FormatHelper.capitalize(text.trim().isEmpty ? '-' : text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
      );

  Widget _textCell(String text) => _cell(_cellText(text));

  Widget _cell(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: child,
    );
  }
}
