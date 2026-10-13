/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_import_review.dart
/// Purpose: Declares `TtImportReview` (+ `TtImportReviewRow`) — the
///          bulk-upload review every Time Tracker import shows after a file
///          is uploaded: totals, then one row per file line with EVERY
///          column of the file; editable cells (info columns read-only); a
///          cell with a problem has a red border and every reason is listed
///          under the row's status ("Column: reason"). Editing a
///          cell hands the new file back ([TtImportReview.onEdited]) so the
///          caller re-checks it at once.
/// Author: Knowticed Plus team
/// Created at: 13/10/2026
///
/// Owner (13/10/2026): "after upload, show the bulk-upload section with the
/// columns and the errors" — the house CRM bulk-upload pattern
/// (`crm_bulk_upload_table.dart`: total badge, header row, editable
/// `CustomTextField` cells, red warning icon). Values never end in "…"
/// (they wrap); one column gap (`ttTableColumnGap`).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// What the review shows for one file line.
class TtImportReviewRow {
  const TtImportReviewRow({
    required this.status,
    required this.color,
    this.cellProblems = const <int, List<String>>{},
    this.rowProblems = const <String>[],
  });

  /// "New" / "Update" / "No Change" / "Skipped".
  final String status;
  final Color color;

  /// Problems by column index of the file.
  final Map<int, List<String>> cellProblems;

  /// Problems of the whole row (shown under the status).
  final List<String> rowProblems;
}

class TtImportReview extends StatefulWidget {
  const TtImportReview({
    super.key,
    required this.grid,
    required this.rows,
    required this.totals,
    required this.onEdited,
    this.columnWidth,
    this.readOnly = const <int>{},
    this.rtl = const <int>{},
    this.keyPrefix = 'import',
  });

  /// The uploaded file (first row = headings).
  final List<List<String>> grid;

  /// File line (1-based, headings = 1) → its result; a line without one
  /// (a blank row) shows "-".
  final Map<int, TtImportReviewRow> rows;

  /// The count chips after "Total": (label with count, colour).
  final List<(String, Color)> totals;

  /// The file after a cell was edited.
  final ValueChanged<List<List<String>>> onEdited;

  /// Unscaled width of column [i] (default 160).
  final double Function(int i)? columnWidth;

  /// Columns shown as plain text (information only, not imported).
  final Set<int> readOnly;

  /// Columns typed right-to-left (Arabic names).
  final Set<int> rtl;

  /// Widget keys: '<prefix>Review', '<prefix>Row_<line>', '<prefix>Cell_<line>_<col>'.
  final String keyPrefix;

  @override
  State<TtImportReview> createState() => _TtImportReviewState();
}

class _TtImportReviewState extends State<TtImportReview> {
  late List<String> _header;
  late List<List<TextEditingController>> _cells;
  final ScrollController _across = ScrollController();

  @override
  void initState() {
    super.initState();
    _header = <String>[...widget.grid.first];
    _cells = <List<TextEditingController>>[
      for (int r = 1; r < widget.grid.length; r++)
        <TextEditingController>[
          for (int c = 0; c < _header.length; c++)
            TextEditingController(text: c < widget.grid[r].length ? widget.grid[r][c] : ''),
        ],
    ];
  }

  @override
  void dispose() {
    for (final List<TextEditingController> row in _cells) {
      for (final TextEditingController c in row) {
        c.dispose();
      }
    }
    _across.dispose();
    super.dispose();
  }

  void _changed() => widget.onEdited(<List<String>>[
        _header,
        for (final List<TextEditingController> row in _cells)
          <String>[for (final TextEditingController c in row) c.text],
      ]);

  double _width(int c) => (widget.columnWidth?.call(c) ?? 160).w;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final double gap = ttTableColumnGap;
    final double lineW = 50.w;
    // Wide enough for the reasons listed under the status.
    final double statusW = 240.w;
    double tableW = lineW + gap + statusW;
    for (int c = 0; c < _header.length; c++) {
      tableW += gap + _width(c);
    }

    Widget head(String text, double width) => SizedBox(
          width: width,
          child: Text(text, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        );

    return Container(
      key: ValueKey<String>('${widget.keyPrefix}Review'),
      padding: EdgeInsetsDirectional.all(12.r),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _totals(s),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 380.h),
            child: Scrollbar(
              controller: _across,
              child: SingleChildScrollView(
                controller: _across,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableW,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        spacing: gap,
                        children: <Widget>[
                          head(s.timeTrackerColumnNo, lineW),
                          head(s.timeTrackerStatus, statusW),
                          for (int c = 0; c < _header.length; c++) head(_header[c], _width(c)),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _cells.length,
                          itemBuilder: (BuildContext context, int i) => _row(i, lineW, statusW, gap),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Total: 5" + one coloured chip per count.
  Widget _totals(S s) {
    Widget chip(String text, Color color, {bool plain = false}) => Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: plain ? AppColors.card : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(text, style: StyleText.fontSize12Weight500.copyWith(color: color)),
        );
    return Wrap(
      key: ValueKey<String>('${widget.keyPrefix}Summary'),
      spacing: 8.w,
      runSpacing: 8.h,
      children: <Widget>[
        chip('${s.timeTrackerTotal}: ${LocalizedNumber.of(context, widget.rows.length)}', AppColors.text,
            plain: true),
        for (final (String text, Color color) in widget.totals) chip(text, color),
      ],
    );
  }

  Widget _row(int i, double lineW, double statusW, double gap) {
    final int line = i + 2;
    final TtImportReviewRow? row = widget.rows[line];
    return Padding(
      key: ValueKey<String>('${widget.keyPrefix}Row_$line'),
      padding: EdgeInsetsDirectional.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: gap,
        children: <Widget>[
          SizedBox(
            width: lineW,
            height: 36.h,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(LocalizedNumber.of(context, line),
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
            ),
          ),
          SizedBox(
            width: statusW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 36.h,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: row == null
                        ? Text('-', style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText))
                        : Container(
                            padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: row.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(row.status, style: StyleText.fontSize12Weight500.copyWith(color: row.color)),
                          ),
                  ),
                ),
                // Every reason of the row here, so it is seen without
                // scrolling sideways ("Column: reason" for a cell).
                for (final String p in row?.rowProblems ?? const <String>[]) _Problem(text: p),
                if (row != null)
                  for (final MapEntry<int, List<String>> e in row.cellProblems.entries)
                    for (final String p in e.value)
                      // A reason that already names its column is not prefixed.
                      _Problem(text: p.contains(_header[e.key]) ? p : '${_header[e.key]}: $p'),
              ],
            ),
          ),
          for (int c = 0; c < _header.length; c++)
            SizedBox(
              width: _width(c),
              child: widget.readOnly.contains(c)
                  ? SizedBox(
                      height: 36.h,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _cells[i][c].text.trim().isEmpty ? '-' : _cells[i][c].text,
                          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
                        ),
                      ),
                    )
                  : _Cell(
                      key: ValueKey<String>('${widget.keyPrefix}Cell_${line}_$c'),
                      controller: _cells[i][c],
                      hint: _header[c],
                      rtl: widget.rtl.contains(c),
                      bad: (row?.cellProblems[c] ?? const <String>[]).isNotEmpty,
                      onChanged: _changed,
                    ),
            ),
        ],
      ),
    );
  }
}

/// One editable cell; a red border when it has a problem.
class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.controller,
    required this.hint,
    required this.rtl,
    required this.bad,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool rtl;

  /// Red border (the reason is listed under the row's status).
  final bool bad;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CustomTextField(
          controller: controller,
          hint: hint,
          height: 36.h,
          fillColor: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          textDirection: rtl ? TextDirection.rtl : null,
          // Red border only — the reasons are listed under the row's status
          // (never cut with "…").
          errorText: bad ? ' ' : null,
          errorStyle: StyleText.fontSize10Weight400.copyWith(color: AppColors.transparent, height: 0.01),
          valueStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
          hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

/// Red warning icon + the reason (wraps).
class _Problem extends StatelessWidget {
  const _Problem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomSvgImage(assetPath: AppAssets.crmWarning, color: AppColors.red, height: 12.r, width: 12.r),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(text, style: StyleText.fontSize10Weight400.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
