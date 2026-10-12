/// Module: GRC / shared / helpers
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_table_columns.dart
/// Purpose: The column model the GRC tables share, and the rule that keeps a
///          column header on ONE line.
/// Author: Knowticed Plus team
/// Created At: 15/9/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Both GRC tables (Policies, Controls) used to carry two parallel lists: a
/// `headers` list of strings and a `columnWidths` map of hand-tuned constants.
/// That has two failure modes, and both were live.
///
/// The widths were tuned to the DATA, not the header. "Control Number" and
/// "Policy Number" are wider at 14/500 than the 110.w their figures need, so
/// the header wrapped and those cells sat a line lower than the rest of the
/// header row.
///
/// And nothing tied entry N of the header list to entry N of the width map, so
/// inserting a column meant remembering to edit both — miss one and the table
/// prints a column's values under its neighbour's title.
///
/// [GrcTableColumn] pairs the two, and [resolveGrcColumnWidths] widens any
/// column whose header does not fit. Measuring beats a bigger constant because
/// the header is translated at render time: an Arabic label is a different
/// width from its English twin, and a width that fits one wraps the other.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [GrcTableColumn]
///
/// purpose: one column of a GRC table — its untranslated header key (run
///          through [grcTr] at render time) and the width its DATA wants.
///
/// authors: Knowticed Plus team
///
/// created at: 15/9/2026
class GrcTableColumn {
  const GrcTableColumn(this.header, this.width);

  /// The English key, e.g. 'Control Number'. Translated at render time.
  final String header;

  /// The width the column's VALUES want. A header too wide for it raises the
  /// column — see [resolveGrcColumnWidths].
  final double width;
}

/// function name: [resolveGrcColumnWidths]
///
/// purpose: the width each column is actually laid out at — the larger of its
///          data width and its translated header measured on one line.
///
/// parameters:
///            [BuildContext] context: for the translation and the text scaler
///            [List<GrcTableColumn>] columns: the table's columns, in order
///            [TextStyle] headerStyle: the style the header row renders with
///            [bool] isArabic: the active direction, which affects layout
///            [double] cellPadding: the header cell's padding on ONE side
///
/// return type: [List<double>] — one width per column, in the same order
List<double> resolveGrcColumnWidths(
  BuildContext context,
  List<GrcTableColumn> columns, {
  required TextStyle headerStyle,
  required bool isArabic,
  required double cellPadding,
}) {
  return columns.map((GrcTableColumn column) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: grcTr(context, column.header), style: headerStyle),
      maxLines: 1,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    // Padding on both sides, plus 2.sp of slack so a sub-pixel rounding
    // difference cannot trip the ellipsis on a header that does fit.
    final double needed = painter.width + (cellPadding * 2) + 2.sp;
    return math.max(column.width, needed);
  }).toList();
}
