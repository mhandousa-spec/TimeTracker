/// Module: GRC / Dashboard Of All Departments
/// Description: The two tables on the Departments tab, styled like the
///              module's existing GrcPolicyTableView (dark header, zebra
///              rows, horizontal + vertical scroll, header-fit widths).
///            * Policies: NO, Policy Number, Policy Name, Policy Score,
///              Policy Weight, Policy Description, Published By,
///              Start Date, End Date, No of controls.
///            * Controls: NO, Control Name, Control Score, Control Weight,
///              Control Description, Policy Name, Control Owner, Frequency.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/domain/entities/department_dashboard_data.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_common_widgets.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_table_columns.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart'
    show GrcAvatarName;

// ─────────────────────────────────────────────────────────────────────────
// Shared table shell
// ─────────────────────────────────────────────────────────────────────────

TextStyle get _headerStyle =>
    StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

double get _cellPadding => 10.sp;

String _date(BuildContext context, DateTime date) =>
    LocalizedDate.of(context, date, pattern: 'd MMM yyyy');

Widget _cell(Widget child) => Container(
      padding: EdgeInsets.symmetric(horizontal: _cellPadding, vertical: 12.sp),
      child: DefaultTextStyle.merge(
        style: StyleText.fontSize12Weight500,
        child: child,
      ),
    );

Widget _textCell(String text, {int maxLines = 2, Color? color}) => _cell(
      Text(
        FormatHelper.capitalize(text.trim().isEmpty ? '-' : text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize12Weight400
            .copyWith(color: color ?? AppColors.text),
      ),
    );

Widget _scoreCell(BuildContext context, double score) => _cell(
      Text(
        departmentScoreText(context, score),
        style: StyleText.fontSize12Weight400
            .copyWith(color: departmentScoreColor(score)),
      ),
    );

String _weight(BuildContext context, double w) => LocalizedNumber.digits(
      context,
      w == w.roundToDouble() ? w.toInt().toString() : w.toStringAsFixed(2),
    );

/// Horizontal + vertical scrolling [Table] with a dark header row.
class _DepartmentTable extends StatelessWidget {
  final List<GrcTableColumn> columns;
  final int rowCount;
  final List<Widget> Function(int index) rowBuilder;
  final void Function(int index)? onRowTap;

  const _DepartmentTable({
    required this.columns,
    required this.rowCount,
    required this.rowBuilder,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final List<double> widths = resolveGrcColumnWidths(
      context,
      columns,
      headerStyle: _headerStyle,
      isArabic: isArabic,
      cellPadding: _cellPadding,
    );
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: <int, TableColumnWidth>{
                for (int i = 0; i < widths.length; i++)
                  i: FixedColumnWidth(widths[i]),
              },
              children: <TableRow>[
                TableRow(
                  decoration: BoxDecoration(color: AppColors.blackShadow),
                  children: [
                    for (final c in columns)
                      Padding(
                        padding: EdgeInsets.all(_cellPadding),
                        child: Text(
                          grcTr(context, c.header),
                          style: _headerStyle,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                for (int i = 0; i < rowCount; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: (i + 1).isEven
                          ? AppColors.evenRowColor
                          : AppColors.oddRowColor,
                    ),
                    children: [
                      for (final Widget cell in rowBuilder(i))
                        onRowTap == null
                            ? cell
                            : GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onRowTap!(i),
                                child: cell,
                              ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Policies
// ─────────────────────────────────────────────────────────────────────────

/// class name: [DepartmentPoliciesTable]
class DepartmentPoliciesTable extends StatelessWidget {
  final List<PolicyEntity> policies;
  final DepartmentDashboardData data;
  final String? department;
  final void Function(PolicyEntity policy)? onPolicyTap;

  const DepartmentPoliciesTable({
    super.key,
    required this.policies,
    required this.data,
    required this.department,
    this.onPolicyTap,
  });

  /// Policy compliance as 0–100: its score over its weight.
  static double policyPercent(PolicyEntity p) => p.policyWeight > 0
      ? (p.score / p.policyWeight * 100).clamp(0, 100).toDouble()
      : 0;

  @override
  Widget build(BuildContext context) {
    final bool ar = context.isArabic;
    return _DepartmentTable(
      columns: [
        GrcTableColumn('NO', 60.w),
        GrcTableColumn('Policy Number', 110.w),
        GrcTableColumn('Policy Name', 150.w),
        GrcTableColumn('Policy Score', 110.w),
        GrcTableColumn('Policy Weight', 110.w),
        GrcTableColumn('Policy Description', 220.w),
        GrcTableColumn('Published By', 170.w),
        GrcTableColumn('Start Date', 120.w),
        GrcTableColumn('End Date', 120.w),
        GrcTableColumn('No of controls', 110.w),
      ],
      rowCount: policies.length,
      onRowTap:
          onPolicyTap == null ? null : (i) => onPolicyTap!(policies[i]),
      rowBuilder: (i) {
        final PolicyEntity p = policies[i];
        return [
          _textCell(LocalizedNumber.of(context, i + 1), maxLines: 1),
          _textCell(
            LocalizedNumber.digits(
                context, ar ? p.policyNumberAr : p.policyNumberEn),
            maxLines: 1,
          ),
          _textCell(ar ? p.policyNameAr : p.policyNameEn),
          _scoreCell(context, policyPercent(p)),
          _textCell(_weight(context, p.policyWeight), maxLines: 1),
          _textCell(ar ? p.policyDescriptionAr : p.policyDescriptionEn),
          _cell(GrcAvatarName(
            email: p.lastEditor,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          )),
          _textCell(
            p.status == PolicyStatus.draft ? '-' : _date(context, p.startDate),
            maxLines: 1,
          ),
          _textCell(
            p.status == PolicyStatus.draft ? '-' : _date(context, p.endDate),
            maxLines: 1,
          ),
          _textCell(
            LocalizedNumber.of(
                context, data.controlCount(p.id, department: department)),
            maxLines: 1,
          ),
        ];
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Controls
// ─────────────────────────────────────────────────────────────────────────

/// class name: [DepartmentControlsTable]
class DepartmentControlsTable extends StatelessWidget {
  final List<DepartmentControlRef> controls;
  final void Function(DepartmentControlRef ref)? onControlTap;

  const DepartmentControlsTable({
    super.key,
    required this.controls,
    this.onControlTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool ar = context.isArabic;
    return _DepartmentTable(
      columns: [
        GrcTableColumn('NO', 60.w),
        GrcTableColumn('Control Name', 150.w),
        GrcTableColumn('Control Score', 110.w),
        GrcTableColumn('Control Weight', 110.w),
        GrcTableColumn('Control Description', 220.w),
        GrcTableColumn('Policy Name', 150.w),
        GrcTableColumn('Control Owner', 170.w),
        GrcTableColumn('Frequency', 110.w),
      ],
      rowCount: controls.length,
      onRowTap:
          onControlTap == null ? null : (i) => onControlTap!(controls[i]),
      rowBuilder: (i) {
        final DepartmentControlRef r = controls[i];
        final ControlEntity c = r.control;
        return [
          _textCell(LocalizedNumber.of(context, i + 1), maxLines: 1),
          _textCell(ar ? c.controlsNameAr : c.controlsNameEn),
          _scoreCell(context, c.score.toDouble()),
          _textCell(_weight(context, c.controlsWeight), maxLines: 1),
          _textCell(ar ? c.controlsDescriptionAr : c.controlsDescriptionEn),
          _textCell(ar ? r.policy.policyNameAr : r.policy.policyNameEn),
          _cell(
            (r.ownerEmail ?? '').isEmpty
                ? Text('-',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text))
                : GrcAvatarName(
                    email: r.ownerEmail!,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text),
                  ),
          ),
          _textCell(grcTr(context, c.frequency), maxLines: 1),
        ];
      },
    );
  }
}

/// Plain display name for exports (no widgets).
String departmentPersonName(BuildContext context, String? email) =>
    (email == null || email.isEmpty) ? '-' : employeeDisplayName(context, email);

// ─────────────────────────────────────────────────────────────────────────
// Phone cards (the tables' mobile form)
// ─────────────────────────────────────────────────────────────────────────
//
// MAGDY has no 375 frame for this section. Every other GRC list on a phone
// (modules, requests, approvals) drops the table for a stack of white cards:
// title on the first line with a small date / chip on the trailing edge,
// "Label: value" lines under it, and a status or score pill bottom-trailing.
// These follow that pattern.

Widget _cardLine(String label, String value, {int maxLines = 1, Color? color}) {
  return Padding(
    padding: EdgeInsets.only(top: 6.h),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: StyleText.fontSize10Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          TextSpan(
            text: value.trim().isEmpty ? '-' : value,
            style: StyleText.fontSize10Weight400
                .copyWith(color: color ?? AppColors.text),
          ),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

/// Grey "Score: 100" chip, number coloured by band.
Widget _scoreChip(BuildContext context, double score) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${grcTr(context, 'Score')}: ',
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
          TextSpan(
            text: departmentScoreText(context, score),
            style: StyleText.fontSize12Weight400
                .copyWith(color: departmentScoreColor(score)),
          ),
        ],
      ),
    ),
  );
}

Widget _phoneCard({required Widget child, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
    ),
  );
}

/// class name: [DepartmentPolicyCards]
///
/// purpose: the Policies table as phone cards.
class DepartmentPolicyCards extends StatelessWidget {
  final List<PolicyEntity> policies;
  final DepartmentDashboardData data;
  final String? department;
  final void Function(PolicyEntity policy)? onPolicyTap;

  const DepartmentPolicyCards({
    super.key,
    required this.policies,
    required this.data,
    required this.department,
    this.onPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool ar = context.isArabic;
    return Column(
      children: [
        for (int i = 0; i < policies.length; i++) ...[
          if (i > 0) SizedBox(height: 15.h),
          () {
            final PolicyEntity p = policies[i];
            return _phoneCard(
              onTap: onPolicyTap == null ? null : () => onPolicyTap!(p),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          FormatHelper.capitalize(
                              ar ? p.policyNameAr : p.policyNameEn),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.text),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        LocalizedNumber.digits(
                            context, ar ? p.policyNumberAr : p.policyNumberEn),
                        style: StyleText.fontSize10Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  _cardLine(
                    grcTr(context, 'Policy Description'),
                    ar ? p.policyDescriptionAr : p.policyDescriptionEn,
                    maxLines: 2,
                  ),
                  _cardLine(grcTr(context, 'Policy Weight'),
                      _weight(context, p.policyWeight)),
                  _cardLine(
                    grcTr(context, 'No of controls'),
                    LocalizedNumber.of(
                        context, data.controlCount(p.id, department: department)),
                  ),
                  _cardLine(grcTr(context, 'Published By'),
                      departmentPersonName(context, p.lastEditor)),
                  _cardLine(
                    grcTr(context, 'Start Date'),
                    p.status == PolicyStatus.draft
                        ? '-'
                        : _date(context, p.startDate),
                  ),
                  _cardLine(
                    grcTr(context, 'End Date'),
                    p.status == PolicyStatus.draft
                        ? '-'
                        : _date(context, p.endDate),
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _scoreChip(
                        context, DepartmentPoliciesTable.policyPercent(p)),
                  ),
                ],
              ),
            );
          }(),
        ],
      ],
    );
  }
}

/// class name: [DepartmentControlCards]
///
/// purpose: the Controls table as phone cards.
class DepartmentControlCards extends StatelessWidget {
  final List<DepartmentControlRef> controls;

  const DepartmentControlCards({super.key, required this.controls});

  @override
  Widget build(BuildContext context) {
    final bool ar = context.isArabic;
    return Column(
      children: [
        for (int i = 0; i < controls.length; i++) ...[
          if (i > 0) SizedBox(height: 15.h),
          () {
            final DepartmentControlRef r = controls[i];
            final ControlEntity c = r.control;
            return _phoneCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          FormatHelper.capitalize(
                              ar ? c.controlsNameAr : c.controlsNameEn),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.text),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _scoreChip(context, c.score.toDouble()),
                    ],
                  ),
                  _cardLine(grcTr(context, 'Policy Name'),
                      ar ? r.policy.policyNameAr : r.policy.policyNameEn),
                  _cardLine(
                    grcTr(context, 'Control Description'),
                    ar ? c.controlsDescriptionAr : c.controlsDescriptionEn,
                    maxLines: 2,
                  ),
                  _cardLine(grcTr(context, 'Control Weight'),
                      _weight(context, c.controlsWeight)),
                  _cardLine(
                      grcTr(context, 'Frequency'), grcTr(context, c.frequency)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${grcTr(context, 'Control Owner')}: ',
                        style: StyleText.fontSize10Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                      Flexible(
                        child: (r.ownerEmail ?? '').isEmpty
                            ? Text('-',
                                style: StyleText.fontSize10Weight400
                                    .copyWith(color: AppColors.text))
                            : GrcAvatarName(
                                email: r.ownerEmail!,
                                avatarRadius: 12,
                                style: StyleText.fontSize12Weight400
                                    .copyWith(color: AppColors.text),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }(),
        ],
      ],
    );
  }
}
