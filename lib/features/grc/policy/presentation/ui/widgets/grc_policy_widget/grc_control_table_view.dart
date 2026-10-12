/// Module: GRC / policy / presentation / ui / widgets / grc_policy_widget
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_control_table_view.dart
/// Purpose: The Controls list's TABLE view — the other half of the card/table
///          toggle on the Policy Details page, so a Control list reads exactly
///          like the Policies list one level up.
/// Author: Knowticed Plus team
/// Created At: 15/9/2026
///
/// Built to the same recipe as [GrcPolicyTableView] (which in turn follows
/// RoleTableView), so every table in the app reads the same way: locale-aware
/// Directionality, a horizontal scroller, a 10.sp rounded clip, fixed column
/// widths, a `blackShadow` header in white 14/500, and rows alternating
/// between `evenRowColor` and `oddRowColor` with 12/600 cells.
///
/// ONE DELIBERATE DIFFERENCE FROM GrcPolicyTableView
/// -------------------------------------------------
/// This table owns NO vertical scroller. The policies tab hands its table an
/// [Expanded] with a bounded height, so the table scrolls itself. The Controls
/// list is rendered inside PolicyDetailsPage's page-wide
/// [SingleChildScrollView] instead — a second vertical viewport there would be
/// handed an unbounded height and assert. So the rows simply shrink-wrap and
/// the page's own scroller moves them.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_table_columns.dart';

/// class name: [GrcControlTableView]
///
/// purpose: renders [controls] as the app's standard table. A row is a
///          [ControlCardWidget] laid flat and opens the same destination on
///          tap, so the toggle only changes how the list looks.
///
/// authors: Knowticed Plus team
///
/// created at: 15/9/2026
class GrcControlTableView extends StatelessWidget {
  const GrcControlTableView({
    super.key,
    required this.controls,
    this.onControlTap,
  });

  final List<ControlEntity> controls;

  /// Same destination the card view opens — a row is the card, in a line.
  final void Function(ControlEntity control)? onControlTap;

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  // ── Column widths, same shape as GrcPolicyTableView's helpers ───────────

  double get _noWidth => 60.w;

  double get _numberWidth => 110.w;

  double get _scoreWidth => 80.w;

  /// Control Name sizes itself to its longest value, clamped between 150.w and
  /// 200.w exactly the way the Policy Name column is.
  double _nameWidth(bool isArabic) {
    double maxLength = 0;
    for (final ControlEntity c in controls) {
      final String name = isArabic ? c.controlsNameAr : c.controlsNameEn;
      if (name.isNotEmpty) {
        maxLength = math.max(maxLength, name.length.toDouble());
      }
    }
    if (maxLength == 0) return 150.w;
    return math.max(math.min((maxLength * 10.sp) + 40.w, 200.w), 150.w);
  }

  double get _descriptionWidth => 250.w;

  double get _weightWidth => 110.w;

  double get _frequencyWidth => 120.w;

  double get _dateWidth => 130.w;

  double get _statusWidth => 110.w;

  /// Chip/row color per [ControlStatus]. Kept keyed by the enum, not by its
  /// display string, so a renamed label cannot silently drop a color — the
  /// same rule ControlCardWidget follows.
  Color _statusColor(ControlStatus status) {
    switch (status) {
      case ControlStatus.active:
        return AppColors.green;
      case ControlStatus.inactive:
        return AppColors.orange;
      case ControlStatus.scheduled:
        return AppColors.primary;
      case ControlStatus.expired:
        return AppColors.red;
      case ControlStatus.unassigned:
        return AppColors.blue; // GRC bug report p17, matches the filter tab
      case ControlStatus.draft:
        return AppColors.colorGrey;
    }
  }

  /// The padding inside every header and data cell, on one side. Named
  /// because [resolveGrcColumnWidths] has to add it back when it measures.
  double get _cellPadding => 10.sp;

  /// The columns, in order: each one's header key (translated at render time)
  /// and the width its DATA wants. A header too wide for its column raises the
  /// column rather than wrapping -- see [resolveGrcColumnWidths].
  List<GrcTableColumn> _columns(bool isArabic) => <GrcTableColumn>[
        GrcTableColumn('NO', _noWidth),
        GrcTableColumn('Control Number', _numberWidth),
        GrcTableColumn('Score', _scoreWidth),
        GrcTableColumn('Control Name', _nameWidth(isArabic)),
        GrcTableColumn('Control Description', _descriptionWidth),
        GrcTableColumn('Control Weight', _weightWidth),
        GrcTableColumn('Frequency', _frequencyWidth),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: <TableRow>[
              _headerRow(context, columns),
              for (int i = 0; i < controls.length; i++)
                _dataRow(context, i, isArabic),
            ],
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
  /// never `toString()` or a bare `DateFormat` — otherwise an Arabic row reads
  /// "١٤ سبتمبر 2026", half the digits in each numbering system.
  TableRow _dataRow(BuildContext context, int index, bool isArabic) {
    final ControlEntity control = controls[index];
    final int rowNumber = index + 1;

    return TableRow(
      decoration: BoxDecoration(
        color:
            rowNumber.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
      ),
      children: <Widget>[
        _tap(
          control,
          _textCell(LocalizedNumber.of(context, rowNumber), maxLines: 1),
        ),
        _tap(
          control,
          _textCell(
            // The Arabic and English control numbers are separate stored
            // fields, so the text is whoever typed it -- only stray ASCII
            // digits inside the Arabic one are rewritten.
            LocalizedNumber.digits(
              context,
              isArabic ? control.controlsNumberAr : control.controlsNumberEn,
            ),
            maxLines: 1,
          ),
        ),
        // Score prints as-is, including 0 -- the same reading ControlCardWidget
        // gives it, so a control does not say "0" on its card and "-" in the
        // table.
        _tap(
          control,
          _cell(
            Text(
              LocalizedNumber.of(context, control.score),
              style:
                  StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
            ),
          ),
        ),
        _tap(
          control,
          _textCell(
            isArabic ? control.controlsNameAr : control.controlsNameEn,
            maxLines: 2,
          ),
        ),
        _tap(
          control,
          _textCell(
            isArabic
                ? control.controlsDescriptionAr
                : control.controlsDescriptionEn,
            maxLines: 3,
          ),
        ),
        _tap(
          control,
          _textCell(
            // formatControlWeight, not toStringAsFixed(0): an equal split can
            // produce 33.33 and rounding it to "33" makes three controls read
            // as 99.
            LocalizedNumber.digits(
              context,
              formatControlWeight(control.controlsWeight),
            ),
            maxLines: 1,
          ),
        ),
        _tap(
          control,
          // frequency is a stored English string ("Annually", "Bi weekly"),
          // which is exactly what grcTr exists to translate at render time.
          _textCell(grcTr(context, control.frequency), maxLines: 1),
        ),
        _tap(control, _textCell(_date(context, control.startDate), maxLines: 1)),
        _tap(control, _textCell(_date(context, control.endDate), maxLines: 1)),
        _tap(
          control,
          _textCell(_date(context, control.lastModifiedDate), maxLines: 1),
        ),
        _tap(
          control,
          _cell(
            Text(
              grcTr(context, control.status.value),
              style: StyleText.fontSize12Weight600
                  .copyWith(color: _statusColor(control.status)),
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

  /// Makes a cell open the control, so the whole row is tappable — a row is a
  /// card laid flat, and the card opens on tap.
  Widget _tap(ControlEntity control, Widget child) {
    if (onControlTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onControlTap!(control),
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
