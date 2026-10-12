/// Module: GRC — Action Center
///
///*************************** FILE INFO ****************************///
/// File Name: grc_action_center_table.dart
/// Purpose: Declares `GrcActionCenterTable` — the Action Center issue table
///          (NO | Module | Policy | Control | Issue | Action).
/// Author: Amr Mesbah
/// Created: 17/9/2026
///
/// Built the same way as RoleTableView
/// (features/roles/r1_role_management/presentation/ui/widgets/table_widget.dart):
/// a Flutter [Table] in a horizontal scroll view, clipped to 10 radius, a
/// AppColors.blackShadow header with white 14/500 titles, alternating
/// AppColors.evenRowColor / oddRowColor rows, and 10 x 8 cell padding with
/// 12-size cell text. The columns stretch to fill the width when there is
/// room, and scroll horizontally when there is not.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/action_center/domain/entities/grc_action_issue.dart';

/// Recommendation text colour (Figma dark yellow).
const Color kGrcRecommendationColor = Color(0xFFC9A000);

class GrcActionCenterTable extends StatelessWidget {
  final List<GrcActionIssue> issues;
  final bool isArabic;

  /// Header labels, already localized: NO, Module, Policy, Control, Issue,
  /// Action (the last only used when [onFix] is set).
  final List<String> headers;

  /// Shows the Action column with a Fix button when set.
  final ValueChanged<GrcActionIssue>? onFix;

  /// Fix button label, already localized.
  final String fixLabel;

  /// Makes the policy name a green link when set.
  final ValueChanged<GrcActionIssue>? onOpenPolicy;

  const GrcActionCenterTable({
    super.key,
    required this.issues,
    required this.isArabic,
    required this.headers,
    this.onFix,
    this.onOpenPolicy,
    this.fixLabel = 'Fix',
  });

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  TextStyle get _cellStyle =>
      StyleText.fontSize12Weight500.copyWith(color: AppColors.text);

  // ── Column widths (design sizes; scaled up to fill) ─────────────────

  List<double> get _baseWidths => [
        50.w, // NO
        140.w, // Module
        150.w, // Policy
        130.w, // Control
        230.w, // Issue
        if (onFix != null) 90.w, // Action
      ];

  Color _issueColor(GrcIssueKind kind) => kind == GrcIssueKind.recommendation
      ? kGrcRecommendationColor
      : AppColors.red;

  // ── Cell helpers ─────────────────────────────────────────────────────

  Widget _cell(Widget child) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: DefaultTextStyle.merge(style: _cellStyle, child: child),
      );

  Widget _textCell(String text, {Color? color, int maxLines = 2}) => _cell(
        Text(
          text.isEmpty ? '—' : text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: _cellStyle.copyWith(color: color),
        ),
      );

  Widget _policyCell(GrcActionIssue issue) {
    final open = onOpenPolicy;
    final name = issue.policyName(isArabic: isArabic);
    if (open == null || issue.policy == null) return _textCell(name);
    return _cell(
      InkWell(
        onTap: () => open(issue),
        child: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _cellStyle.copyWith(color: AppColors.green),
        ),
      ),
    );
  }

  Widget _fixCell(BuildContext context, GrcActionIssue issue) {
    final fix = onFix;
    if (fix == null || issue.kind == GrcIssueKind.expired) {
      return _textCell('');
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: customButton(
          title: fixLabel,
          function: () => fix(issue),
          wrapContent: true,
          contentHorizontalPadding: 14.sp,
          color: AppColors.primary,
          textStyle:
              StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final base = _baseWidths;
    final double minWidth = base.fold(0, (s, w) => s + w);

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double available = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : minWidth;
          final double scale = math.max(1, available / minWidth);
          final columnWidths = <int, TableColumnWidth>{
            for (var i = 0; i < base.length; i++)
              i: FixedColumnWidth(base[i] * scale),
          };

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: columnWidths,
                children: [
                  // ── Header row ─────────────────────────────────────────
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.blackShadow),
                    children: [
                      for (var i = 0; i < base.length; i++)
                        Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            headers[i],
                            style: _headerStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                    ],
                  ),

                  // ── Data rows ──────────────────────────────────────────
                  for (var index = 0; index < issues.length; index++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: (index + 1).isEven
                            ? AppColors.evenRowColor
                            : AppColors.oddRowColor,
                      ),
                      children: [
                        _textCell('${index + 1}', maxLines: 1),
                        _textCell(issues[index].moduleName(isArabic: isArabic)),
                        _policyCell(issues[index]),
                        _textCell(
                            issues[index].controlName(isArabic: isArabic)),
                        _textCell(
                          issues[index].message(isArabic: isArabic),
                          color: _issueColor(issues[index].kind),
                        ),
                        if (onFix != null) _fixCell(context, issues[index]),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
