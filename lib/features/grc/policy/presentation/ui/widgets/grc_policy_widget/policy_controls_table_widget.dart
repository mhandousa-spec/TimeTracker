/// Module: Policy Management
/// Description: Table widget that displays policy controls in preview mode,
///              supports inline weight editing, Equal Weight distribution,
///              and Total Weight validation (must equal 100 to publish).
/// Author: Mohamed Elrashidy
/// Date: 2026-07-06
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlModel
/// Revision History: 2026-07-06 - Initial creation

library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_controls_table_widget.dart
/// Purpose: Contains PolicyControlsTableWidget, the preview table for
///          policy controls with edit / equal-weight / publish-validation
///          capabilities.
/// Author: Mohamed Elrashidy
/// Created At: 6/7/2026

import 'dart:math' as math;

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [PolicyControlsTableWidget]
///
/// purpose: display the policy controls as a preview table. In view mode
///          rows are read-only; clicking Edit enables inline weight editing
///          per row. Equal Weight distributes 100 equally across all rows.
///          The Total Weight badge turns green at exactly 100 and red
///          otherwise, and a validation message appears when needed.
///
/// authors: Mohamed Elrashidy
///
/// created at: 6/7/2026
class PolicyControlsTableWidget extends StatefulWidget {
  final List<PolicyControlModel> controls;

  /// Called when the user taps Save after editing weights.
  final VoidCallback? onSave;

  /// The Create Policy "Arabic version" switch. On: the table (and the
  /// phone cards) also show each control's Arabic name and description.
  final bool isArabicEnabled;

  const PolicyControlsTableWidget({
    super.key,
    required this.controls,
    this.onSave,
    this.isArabicEnabled = false,
  });

  @override
  State<PolicyControlsTableWidget> createState() =>
      _PolicyControlsTableWidgetState();
}

class _PolicyControlsTableWidgetState
    extends State<PolicyControlsTableWidget> {
  bool _isEditing = false;

  // Temporary weight controllers used while in edit mode.
  // Kept in a list parallel to widget.controls.
  late List<TextEditingController> _weightControllers;

  /// Full-precision weight behind each edit field (parallel list). The
  /// fields show 2 decimals; the maths uses these while a field still shows
  /// its value. See [_weightAt].
  late List<double?> _exactWeights;

  /// Display form of a weight: at most 2 decimals, trailing zeros dropped
  /// (16.666... -> 16.67, 25.0 -> 25).
  static String _display(double v) =>
      v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

  /// Display form of a stored weight string (which may carry every digit).
  static String _displayText(String raw) {
    final double? v = double.tryParse(raw.trim());
    return v == null ? raw.trim() : _display(v);
  }

  /// The value row [i] contributes to the total: the exact share while the
  /// field still shows it, otherwise whatever the user typed.
  double _weightAt(int i) {
    final String text = _weightControllers[i].text.trim();
    final double? exact = _exactWeights[i];
    if (exact != null && text == _display(exact)) return exact;
    return double.tryParse(text) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initWeightControllers();
  }

  @override
  void didUpdateWidget(PolicyControlsTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync if the controls list changed (e.g. control added/removed).
    if (oldWidget.controls.length != widget.controls.length) {
      _disposeWeightControllers();
      _initWeightControllers();
    }
  }

  /// function name: [_initWeightControllers]
  ///
  /// purpose: initialise one TextEditingController per control, seeded with
  ///          the control's current weight value.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _initWeightControllers() {
    _exactWeights = widget.controls
        .map((c) => double.tryParse(c.weightController.text.trim()))
        .toList();
    _weightControllers = widget.controls.map((c) {
      final text = c.weightController.text.trim();
      return TextEditingController(
          text: text.isEmpty ? '0' : _displayText(text));
    }).toList();
  }

  void _disposeWeightControllers() {
    for (final c in _weightControllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeWeightControllers();
    super.dispose();
  }

  /// function name: [_totalWeight]
  ///
  /// purpose: calculate the sum of all weight values currently held in the
  ///          temporary weight controllers.
  ///
  /// parameters: none
  ///
  /// return type: [double] - the current total weight
  double get _totalWeight {
    double sum = 0;
    for (int i = 0; i < _weightControllers.length; i++) {
      sum += _weightAt(i);
    }
    return sum;
  }

  // Tolerance, not ==: a sum of 2-decimal weights is rarely an exact double.
  bool get _isWeightValid => (_totalWeight - 100).abs() < 0.001;

  /// function name: [_applyEqualWeight]
  ///
  /// purpose: distribute 100 equally across all controls by setting each
  ///          weight to (100 / count), rounded to 2 decimal places.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _applyEqualWeight() {
    if (widget.controls.isEmpty) return;
    // Every field shows the rounded share (16.67); the exact share
    // (100 / 6 = 16.666...) is what the total and the saved weight use.
    final double share = 100 / _weightControllers.length;
    setState(() {
      for (var i = 0; i < _weightControllers.length; i++) {
        _exactWeights[i] = share;
        _weightControllers[i].text = _display(share);
      }
    });
  }

  /// function name: [_saveWeights]
  ///
  /// purpose: persist the edited weights back into each control's
  ///          [weightController] and exit edit mode.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _saveWeights() {
    for (int i = 0; i < widget.controls.length; i++) {
      // Store every digit, so the policy is saved with the exact share.
      widget.controls[i].weightController.text = _weightAt(i).toString();
    }
    setState(() => _isEditing = false);
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableActions(isMobile),
        SizedBox(height: 8.h),
        // iPhone (375) has no room for a five-column table, so the design
        // turns every control row into its own card. iPad (768) and desktop
        // (1024) keep the table.
        if (isMobile) _buildControlCards() else _buildTable(),
        SizedBox(height: 12.h),
        _buildTotalWeightBadge(isMobile),
      ],
    );
  }

  // ------------------------------------------------------------------
  // PHONE: one card per control
  // ------------------------------------------------------------------
  Widget _buildControlCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.controls.length; i++) ...[
          if (i != 0) SizedBox(height: 10.h),
          _buildControlCard(i),
        ],
      ],
    );
  }

  Widget _buildControlCard(int index) {
    final control = widget.controls[index];
    final name = control.nameController.text.trim();
    final description = control.descriptionController.text.trim();
    final frequency = control.frequency?.trim() ?? '';
    final weight = control.weightController.text.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
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
                child: Text(
                  name.isEmpty ? '-' : FormatHelper.capitalize(name),
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              _weightChip(index, weight),
            ],
          ),
          SizedBox(height: 6.h),
          Text.rich(
            TextSpan(
              text: '${FormatHelper.capitalize(S.of(context).frequency)}: ',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
              children: [
                TextSpan(
                  text: frequency.isEmpty
                      ? '-'
                      : FormatHelper.capitalize(grcTr(context, frequency)),
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            FormatHelper.capitalize(S.of(context).description),
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 4.h),
          Text(
            description.isEmpty ? '-' : FormatHelper.capitalize(description),
            style:
                StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
          if (widget.isArabicEnabled) ...[
            SizedBox(height: 8.h),
            Text(
              FormatHelper.capitalize(S.of(context).controlNameArabic),
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 4.h),
            Text(
              control.nameArController.text.trim().isEmpty
                  ? '-'
                  : FormatHelper.capitalize(
                      control.nameArController.text.trim()),
              textDirection: TextDirection.rtl,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.text),
            ),
            SizedBox(height: 8.h),
            Text(
              FormatHelper.capitalize(S.of(context).descriptionArabic),
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 4.h),
            Text(
              control.descriptionArController.text.trim().isEmpty
                  ? '-'
                  : FormatHelper.capitalize(
                      control.descriptionArController.text.trim()),
              textDirection: TextDirection.rtl,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.text),
            ),
          ],
        ],
      ),
    );
  }

  /// The "Control Weight: n" chip on a phone card -- an editable field
  /// while the list is in edit mode, a read-only pill otherwise.
  Widget _weightChip(int index, String weight) {
    if (_isEditing) {
      return SizedBox(
        width: 72.w,
        child: TextField(
          controller: _weightControllers[index],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style:
              StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            filled: true,
            fillColor: AppColors.field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide:
                  BorderSide(color: AppColors.primary.withOpacity(.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Text(
            FormatHelper.capitalize(
                '${S.of(context).controlWeight}: '),
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText),
          ),

          Text(
            FormatHelper.capitalize(
                '${weight.isEmpty ? '0' : _displayText(weight)}'),
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // TABLE ACTIONS ROW  (Edit  |  Equal Weight + Save)
  // ------------------------------------------------------------------
  Widget _buildTableActions(bool isMobile) {
    // 375 cannot fit Equal Weight + Save + Edit on one line, so the phone
    // lays them out trailing-aligned and lets them wrap.
    if (isMobile) {
      return SizedBox(
        width: double.infinity,
        child: Row(
          // spacing: 8.w,
          // runSpacing: 8.h,
          // alignment: WrapAlignment.end,
          // crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (_isEditing)
              _actionButton(
                label: S.of(context).equalWeight,
                color: AppColors.primary,
                textColor: AppColors.textButton,
                onTap: _applyEqualWeight,
              ),
            Spacer(),
            if (_isEditing)
              _actionButton(
                label: S.of(context).Save,
                color: AppColors.primary,
                textColor: AppColors.textButton,
                onTap: _saveWeights,
              ),
            if (!_isEditing) _editButton(isCompact: true),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isEditing)
          // Equal Weight button — only visible while editing
          _actionButton(
            label: S.of(context).equalWeight,
            color: AppColors.primary,
            textColor: AppColors.textButton,
            onTap: _applyEqualWeight,
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            if (_isEditing)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _actionButton(
                  label: S.of(context).Save,
                  color: AppColors.primary,
                  textColor: AppColors.textButton,
                  onTap: _saveWeights,
                ),
              ),
            // Edit (view mode) / Done (edit mode) toggle
            if (_isEditing)
              _actionButton(
                label: S.of(context).status_done,
                color: AppColors.background,
                textColor: AppColors.text,
                onTap: _toggleEditing,
                bordered: true,
              )
            else
              _editButton(isCompact: false),
          ],
        ),
      ],
    );
  }

  /// Flip between view and edit mode, discarding any temporary weight edits
  /// when leaving edit mode via Done.
  void _toggleEditing() {
    if (_isEditing) {
      // discard temporary edits on "Done" without saving
      _initWeightControllers();
    }
    setState(() => _isEditing = !_isEditing);
  }

  /// The Edit button — the shared customButtonWithSvg with the edit_pen
  /// svg on the primary colour. Icon-only 38.w square on a phone
  /// ([isCompact]), 135.w with the "Edit" label on tablet / desktop.
  /// `fixedWidth` is passed because customButtonWithSvg ignores `width`.
  Widget _editButton({required bool isCompact}) {
    final double buttonWidth = isCompact ? 38.w : 135.w;
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      svgColor: AppColors.textButton,
      image: "assets/icons_assets/data_grc_assets/edit_pen.svg",
      title: isCompact ? "" : S.of(context).Edit,
      function: _toggleEditing,
      width: buttonWidth,
      fixedWidth: buttonWidth,
      color: AppColors.primary,
      textStyle:
          StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    Widget? leading,
    bool bordered = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110.sp,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          border: bordered
              ? Border.all(color: AppColors.secondaryText.withOpacity(.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading, SizedBox(width: 6.w)],
            Text(FormatHelper.capitalize(label),
                style: StyleText.fontSize14Weight500.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // TABLE
  // ------------------------------------------------------------------
  // The preview table follows the same recipe as RoleTableView in
  // roles/r1_role_management/presentation/ui/widgets/table_widget.dart, so
  // every table in the app reads the same way: locale-aware Directionality,
  // a horizontal scroller, a 10.sp rounded clip, fixed column widths, a
  // blackShadow header in white 14/500, and rows alternating between
  // evenRowColor and oddRowColor with 12/600 cells.

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  // -- Column widths, same shape as RoleTableView's helpers ----------------

  double get _noWidth => 60.w;

  // Control Name sizes itself to its longest value, clamped between 150.w
  // and 200.w exactly the way the Role Name column is.
  double get _controlNameWidth {
    double maxLength = 0;
    for (final control in widget.controls) {
      final name = control.nameController.text.trim();
      if (name.isNotEmpty) {
        maxLength = math.max(maxLength, name.length.toDouble());
      }
    }
    if (maxLength == 0) return 150.w;
    final calculated = math.min((maxLength * 10.sp) + 40.w, 200.w);
    return math.max(calculated, 150.w);
  }

  double get _descriptionWidth => 250.w;

  double get _weightWidth => 100.w;

  double get _frequencyWidth => 150.w;

  /// Header text per column, in order. The Arabic pair sits right after its
  /// English twin when the Arabic switch is on.
  List<String> _headers(BuildContext context) {
    final S s = S.of(context);
    return <String>[
      grcTr(context, 'NO'),
      grcTr(context, 'Control Name'),
      if (widget.isArabicEnabled) s.controlNameArabic,
      grcTr(context, 'Description'),
      if (widget.isArabicEnabled) s.descriptionArabic,
      grcTr(context, 'Weight'),
      grcTr(context, 'Frequency'),
    ];
  }

  /// Data widths per column (same order as [_headers]).
  List<double> get _dataWidths => <double>[
        _noWidth,
        _controlNameWidth,
        if (widget.isArabicEnabled) _controlNameWidth,
        _descriptionWidth,
        if (widget.isArabicEnabled) _descriptionWidth,
        _weightWidth,
        _frequencyWidth,
      ];

  Widget _buildTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double available = constraints.maxWidth;
        final List<double> widths = _dataWidths;
        final Map<int, TableColumnWidth> columnWidths;
        final Widget table;

        if (!widget.isArabicEnabled) {
          // English only: the table spans the full width and every column
          // after NO gets an equal share, so the gaps between them match.
          columnWidths = <int, TableColumnWidth>{
            0: FixedColumnWidth(_noWidth),
            for (int i = 1; i < widths.length; i++)
              i: const FlexColumnWidth(1),
          };
          table = SizedBox(
            width: available,
            child: _table(columnWidths),
          );
        } else {
          // English + Arabic: seven columns can outgrow the page, so they
          // keep their data widths and scroll sideways; when they fit, the
          // spare width is shared out so the table still spans the page.
          final double total = widths.fold(0, (a, b) => a + b);
          final double extra = available - total;
          final double growable = total - widths.first;
          columnWidths = <int, TableColumnWidth>{
            for (int i = 0; i < widths.length; i++)
              i: FixedColumnWidth(
                i == 0 || extra <= 0
                    ? widths[i]
                    : widths[i] + extra * (widths[i] / growable),
              ),
          };
          table = _table(columnWidths);
        }

        return Directionality(
          textDirection:
              context.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: table,
            ),
          ),
        );
      },
    );
  }

  Widget _table(Map<int, TableColumnWidth> columnWidths) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: columnWidths,
      children: [
        _buildHeaderRow(),
        for (int i = 0; i < widget.controls.length; i++) _buildDataRow(i),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: AppColors.blackShadow),
      children: _headers(context)
          .map(
            (header) => Padding(
              padding: EdgeInsets.all(10.sp),
              child: Text(
                FormatHelper.capitalize(header),
                style: _headerStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _buildDataRow(int index) {
    final control = widget.controls[index];
    final rowNumber = index + 1;
    final frequency = control.frequency?.trim() ?? '';
    final weight = control.weightController.text.trim();

    return TableRow(
      decoration: BoxDecoration(
        color:
            rowNumber.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
      ),
      children: [
        _textCell('$rowNumber', maxLines: 1),
        _textCell(control.nameController.text.trim(), maxLines: 2),
        if (widget.isArabicEnabled)
          _textCell(control.nameArController.text.trim(), maxLines: 2),
        _textCell(control.descriptionController.text.trim(), maxLines: 3),
        if (widget.isArabicEnabled)
          _textCell(control.descriptionArController.text.trim(), maxLines: 3),
        // Weight -- an editable field while the list is in edit mode.
        _isEditing
            ? _cell(_weightField(index))
            : _textCell(weight.isEmpty ? '0' : _displayText(weight), maxLines: 1),
        _textCell(
          frequency.isEmpty ? '' : grcTr(context, frequency),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _weightField(int index) {
    return TextField(
      controller: _weightControllers[index],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _cell(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: StyleText.fontSize12Weight500,
        child: child,
      ),
    );
  }

  Widget _textCell(String text, {int maxLines = 2}) {
    return _cell(
      Text(
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ------------------------------------------------------------------
  // TOTAL WEIGHT BADGE
  // ------------------------------------------------------------------
  Widget _buildTotalWeightBadge(bool isMobile) {
    final total = _isEditing ? _totalWeight : _computeSavedTotal();
    final isValid = (total - 100).abs() < 0.001;
    final color = isValid ? AppColors.green : AppColors.red;
    // The phone design hangs the badge (and its warning) off the trailing
    // edge; iPad and desktop keep it centred under the table. The
    // full-width box is what lets either alignment actually take effect --
    // the parent Column lays this out at its intrinsic width otherwise.
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding:  EdgeInsets.all(4.r),
        child: Column(
          crossAxisAlignment:
              isMobile ? CrossAxisAlignment.end : CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Container(
                width: 115.sp,
                child: Row(
                  children: [
                    Text(
                      FormatHelper.capitalize(
                          '${S.of(context).totalWeight}: '),
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText),
                    ),
                    Text(
                      FormatHelper.capitalize(
                          ' ${_display(total)}'),
                      style: StyleText.fontSize14Weight500.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ),
            if (!isValid) ...[
              SizedBox(height: 6.h),
              Text(
                FormatHelper.capitalize(S.of(context).totalWeightShouldBe100),
                style:
                    StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
                textAlign: isMobile ? TextAlign.end : TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// function name: [_computeSavedTotal]
  ///
  /// purpose: compute the total weight from the controls' own
  ///          [weightController] text (the persisted values, not the
  ///          temporary edit controllers).
  ///
  /// parameters: none
  ///
  /// return type: [double] - the total of saved weight values
  double _computeSavedTotal() {
    return widget.controls.fold(
      0,
      (sum, c) =>
          sum + (double.tryParse(c.weightController.text.trim()) ?? 0),
    );
  }
}