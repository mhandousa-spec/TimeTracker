/// Module: GRC / module / presentation / ui / widgets
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_policy_table_view.dart
/// Purpose: The Policies tab's TABLE view — the other half of the card/table
///          toggle on GrcModulePoliciesTab.
/// Author: Knowticed Plus team
/// Created At: 14/9/2026
///
/// Built to the same recipe as RoleTableView
/// (roles/r1_role_management/presentation/ui/widgets/table_widget.dart), so
/// every table in the app reads the same way: locale-aware Directionality, a
/// horizontal scroller, a 10.sp rounded clip, fixed column widths, a
/// `blackShadow` header in white 14/500, and rows alternating between
/// `evenRowColor` and `oddRowColor` with 12/600 cells.
///
/// THREE DESIGN COLUMNS ARE MISSING, AND CANNOT BE FILLED YET
/// ---------------------------------------------------------
/// Figma draws twelve columns. `PolicyEntity` carries nine of them. It has no
/// creation date, no controls count and no departments, and nothing in the
/// policy models or the Firestore read supplies them — so rendering those
/// three would mean printing a hard-coded "-" in every row, which looks like
/// missing data rather than an unbuilt feature. They are left out until the
/// model carries them:
///
///   * Creation Date   — needs a createdAt on PolicyModel/PolicyEntity
///   * No of Controls  — derivable by counting each policy's Controls
///                       subcollection, the way PolicyWeightHistory does
///   * Departments     — not modelled on a policy at all
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_table_columns.dart';

class GrcPolicyTableView extends StatelessWidget {
  const GrcPolicyTableView({
    super.key,
    required this.policies,
    this.onPolicyTap,
    this.showScore = true,
  });

  /// Policy_Score permission -- false removes the Score column entirely,
  /// header and cells, matching PolicyListCard.showScore.
  final bool showScore;

  final List<PolicyEntity> policies;

  /// Same destination the card view opens — a row is the card, in a line.
  final void Function(PolicyEntity policy)? onPolicyTap;

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  // ── Column widths, same shape as RoleTableView's helpers ────────────────

  double get _noWidth => 60.w;

  double get _numberWidth => 110.w;

  double get _scoreWidth => 80.w;

  /// Policy Name sizes itself to its longest value, clamped between 150.w and
  /// 200.w exactly the way RoleTableView's Role Name column is.
  double _nameWidth(bool isArabic) {
    double maxLength = 0;
    for (final PolicyEntity p in policies) {
      final String name = isArabic ? p.policyNameAr : p.policyNameEn;
      if (name.isNotEmpty) {
        maxLength = math.max(maxLength, name.length.toDouble());
      }
    }
    if (maxLength == 0) return 150.w;
    return math.max(math.min((maxLength * 10.sp) + 40.w, 200.w), 150.w);
  }

  double get _descriptionWidth => 250.w;

  double get _weightWidth => 110.w;

  double get _dateWidth => 130.w;

  double get _statusWidth => 110.w;

  Color _statusColor(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.active:
        return AppColors.green;
      case PolicyStatus.inactive:
        return AppColors.orange;
      case PolicyStatus.scheduled:
        return AppColors.orange;
      case PolicyStatus.expired:
        return AppColors.red;
      case PolicyStatus.draft:
      case PolicyStatus.removed:
        return AppColors.colorGrey;
    }
  }

  /// The padding inside every header and data cell, on one side. Named
  /// because [resolveGrcColumnWidths] has to add it back when it measures.
  double get _cellPadding => 10.sp;

  /// The columns, in order: each one's header key (translated at render time)
  /// and the width its DATA wants. A header too wide for its column raises the
  /// column rather than wrapping -- "Policy Number" and "Policy Weight" are
  /// both wider at 14/500 than the figures under them need.
  List<GrcTableColumn> _columns(bool isArabic) => <GrcTableColumn>[
        GrcTableColumn('NO', _noWidth),
        GrcTableColumn('Policy Number', _numberWidth),
        // Policy_Score switch: off drops the column, same as the card view.
        if (showScore) GrcTableColumn('Score', _scoreWidth),
        GrcTableColumn('Policy Name', _nameWidth(isArabic)),
        GrcTableColumn('Policy Description', _descriptionWidth),
        GrcTableColumn('Policy Weight', _weightWidth),
        GrcTableColumn('Start Date', _dateWidth),
        GrcTableColumn('End Date', _dateWidth),
        GrcTableColumn('Last Edit Date', _dateWidth),
        GrcTableColumn('Status', _statusWidth),
      ];

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    final List<GrcTableColumn> columns = _columns(isArabic);
    final List<double> widths = resolveGrcColumnWidths(
      context,
      columns,
      headerStyle: _headerStyle,
      isArabic: isArabic,
      cellPadding: _cellPadding,
    );

    final Map<int, TableColumnWidth> columnWidths = <int, TableColumnWidth>{
      for (int i = 0; i < widths.length; i++) i: FixedColumnWidth(widths[i]),
    };

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: columnWidths,
              children: <TableRow>[
                _headerRow(context, columns),
                for (int i = 0; i < policies.length; i++)
                  _dataRow(context, i, isArabic),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _headerRow(BuildContext context, List<GrcTableColumn> columns) {
    return TableRow(
      decoration: BoxDecoration(color: AppColors.blackShadow),
      children: columns
          .map(
            (GrcTableColumn column) => Padding(
              padding: EdgeInsets.all(_cellPadding),
              child: Text(
                grcTr(context, column.header),
                style: _headerStyle,
                // ONE line, always. The column was widened to fit it in
                // [resolveGrcColumnWidths], so this can no longer clip -- it
                // is the guarantee that a header never wraps, not a
                // truncation.
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
          )
          .toList(),
    );
  }

  /// Every figure in a row goes through [LocalizedNumber] / [LocalizedDate],
  /// never `toString()` or a bare `DateFormat`. `DateFormat('d MMM yyyy','ar')`
  /// gives Arabic month names but LATIN digits, which is why the table read
  /// "14 سبتمبر 2026" and "99" beside counts that were already ٠-٩. Those two
  /// helpers map the digits themselves for any `ar` tag, so the whole row
  /// counts in one numbering system.
  TableRow _dataRow(
    BuildContext context,
    int index,
    bool isArabic,
  ) {
    final PolicyEntity policy = policies[index];
    final int rowNumber = index + 1;

    return TableRow(
      decoration: BoxDecoration(
        color:
            rowNumber.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
      ),
      children: <Widget>[
        _tap(
          policy,
          _textCell(LocalizedNumber.of(context, rowNumber), maxLines: 1),
        ),
        _tap(
          policy,
          _textCell(
            // The Arabic and English policy numbers are separate stored
            // fields, so the text is whoever typed it -- only stray ASCII
            // digits inside the Arabic one are rewritten.
            LocalizedNumber.digits(
              context,
              isArabic ? policy.policyNumberAr : policy.policyNumberEn,
            ),
            maxLines: 1,
          ),
        ),
        // Score keeps the card view's rule: 0 reads as "not scored yet", not
        // as a zero score.
        if (showScore)
        _tap(
          policy,
          _cell(
            Text(
              policy.score == 0
                  ? '-'
                  : LocalizedNumber.digits(
                      context, policy.score.toStringAsFixed(0)),
              style: StyleText.fontSize12Weight600
                  .copyWith(color: AppColors.text),
            ),
          ),
        ),
        _tap(
          policy,
          _textCell(
            isArabic ? policy.policyNameAr : policy.policyNameEn,
            maxLines: 2,
          ),
        ),
        _tap(
          policy,
          _textCell(
            isArabic ? policy.policyDescriptionAr : policy.policyDescriptionEn,
            maxLines: 3,
          ),
        ),
        _tap(
          policy,
          _textCell(
            LocalizedNumber.digits(
                context, policy.policyWeight.toStringAsFixed(0)),
            maxLines: 1,
          ),
        ),
        _tap(
          policy,
          _textCell(_date(context, policy.startDate), maxLines: 1),
        ),
        _tap(
          policy,
          _textCell(_date(context, policy.endDate), maxLines: 1),
        ),
        _tap(
          policy,
          _textCell(
              // A Draft has not been published yet, so its date shows as '-'.
              policy.status == PolicyStatus.draft
                  ? '-'
                  : _date(context, policy.lastModifiedDate),
              maxLines: 1),
        ),
        _tap(
          policy,
          _cell(
            Text(
              grcTr(context, policy.status.value),
              style: StyleText.fontSize12Weight600
                  .copyWith(color: _statusColor(policy.status)),
            ),
          ),
        ),
      ],
    );
  }

  /// Month name from the active locale, digits to match -- "14 Sep 2026" in
  /// English, "١٤ سبتمبر ٢٠٢٦" in Arabic.
  String _date(BuildContext context, DateTime date) =>
      LocalizedDate.of(context, date, pattern: 'd MMM yyyy');

  /// Makes a cell open the policy, so the whole row is tappable — a row is a
  /// card laid flat, and the card opens on tap.
  Widget _tap(PolicyEntity policy, Widget child) {
    if (onPolicyTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onPolicyTap!(policy),
      child: child,
    );
  }

  Widget _cell(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _cellPadding, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: StyleText.fontSize12Weight500,
        child: child,
      ),
    );
  }

  Widget _textCell(String text, {int maxLines = 2}) {
    return _cell(
      Text(
        FormatHelper.capitalize(text.trim().isEmpty ? '-' : text),
        maxLines: maxLines,
        style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
