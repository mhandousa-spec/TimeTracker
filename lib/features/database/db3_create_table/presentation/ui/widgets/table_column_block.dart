/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_column_block.dart
/// Purpose: Declares `TableColumnBlock`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// One grey column block on the Creating Table card — Figma 7398:6667 (and its
/// three siblings) inside 7398:6533, 7398:6869 inside 7398:6732.
///
///   "1st Column"                     Data Type [ General  v ]   Column Name [ … ]
///   [copy] [remove]
///
/// THE FILL IS INVERTED, ON PURPOSE
/// --------------------------------
/// Everywhere else in this module a field is grey on a white card. Here the
/// BLOCK is grey and the two fields inside it are white — that is what the
/// Figma draws, and it is what makes a block read as one group rather than as
/// two loose fields. So `fillColor` on these two fields is `AppColors.card`,
/// not the `fieldFillLight` the rest of the card uses.
///
/// THE DATA TYPE NO LONGER GOVERNS THE BOX BESIDE IT (17/8/2026)
/// ------------------------------------------------------------
/// It used to. Picking "Number" made the Column Name box take only digits — a
/// keystroke filter, a numeric keyboard and a "1234.56" hint, plus an inline
/// error and a guard on Create when the text did not match.
///
/// That was the rule pointed at the wrong field. The Data Type describes what
/// goes UNDER a heading, not what the heading is called: it made a Number
/// column impossible to call "Salary" and a Date column impossible to call
/// "Start Date". So the two fields are now independent — the dropdown records
/// the type, the box records the name, and neither constrains the other.
///
/// `TableColumnInputRules` and `TableColumnType.accepts` are both still there,
/// unused by this block, waiting for the Form Builder's cell editors — the
/// place where "this column holds numbers" is a statement about the input.
///
/// ON A PHONE THE BLOCK IS AN ACCORDION (17/8/2026)
/// ------------------------------------------------
/// Figma 7398:11704 / 11833 draw the phone's blocks folded — a 43pt tile with
/// the heading, the two glyphs and a chevron (7398:11775, 7398:11757) — and
/// open exactly one of them (7398:11789, 220pt) with the Data Type above the
/// Column Name and the glyphs beneath both.
///
/// Two different reasons, one per orientation, which is why
/// `CreateTableMetrics.collapsibleColumns` asks about both:
///
///   PORTRAIT   250 + 15 + 250 does not fit beside a heading in a 315pt card,
///              so the fields have to stack, and four stacked blocks are ~800pt
///              of card — the two count fields that SIZE those blocks scroll
///              off the top while you type into the blocks they made.
///   LANDSCAPE  812 x 375. The row fits; the screen is 375 tall. Four open
///              blocks are six screenfuls.
///
/// Folded, the tile shows the column's OWN NAME once it has one and falls back
/// to "1st Column" until then. The Figma says "First Row" on every tile because
/// it is drawn with empty fields — a list of four identical tiles is not
/// something you can navigate, and the name is the thing that tells them apart.
///
/// The state is per block and lives here rather than in the cubit: which block
/// is open is a property of this screen being looked at, not of the table being
/// built, and putting it in the cubit would make it survive into the record.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_metrics.dart';

class TableColumnBlock extends StatefulWidget {
  const TableColumnBlock({
    super.key,
    required this.metrics,
    required this.index,
    required this.column,
    required this.nameController,
    required this.onNameChanged,
    required this.onTypeChanged,
    required this.onDuplicate,
    required this.onRemove,
    this.canRemove = true,
    this.canDuplicate = true,
    this.enabled = true,
  });

  final CreateTableMetrics metrics;

  /// Zero-based position, rendered as "1st Column".
  final int index;

  final TableColumn column;

  /// Owned by the page, keyed by `column.id`, so a removed block cannot leave
  /// its text behind in the block that takes its place.
  final TextEditingController nameController;

  final ValueChanged<String> onNameChanged;
  final ValueChanged<TableColumnType> onTypeChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  /// False on the last remaining block: a table with no columns is not a table,
  /// so the control is hidden rather than shown and then refused.
  final bool canRemove;

  /// False once the card is at `CreateTableLimits.maxColumns`.
  final bool canDuplicate;

  final bool enabled;

  @override
  State<TableColumnBlock> createState() => _TableColumnBlockState();
}

class _TableColumnBlockState extends State<TableColumnBlock> {
  /// Whether this block is open. Only consulted when the block is drawn as an
  /// accordion; the iPad layout has no folded state.
  ///
  /// Starts open on the FIRST block and folded on the rest. A card that opens
  /// with everything folded looks empty and gives no clue that a tile unfolds;
  /// one that opens with everything unfolded is the wall of fields the
  /// accordion exists to prevent. One open tile demonstrates the control.
  late bool _expanded = widget.index == 0;

  CreateTableMetrics get metrics => widget.metrics;

  /// The fields sit ON the grey block, so they take the card's colour to stand
  /// out — the inverse of the rule the rest of the form follows.
  Color get _fieldFill => AppColors.card;

  Color get _blockFill =>
      AppTheme.isDark ? AppColors.colorBlack : AppColors.fieldFillLight;

  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  TextStyle get _hintStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText);

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    return Container(
      width: double.infinity,
      padding: metrics.columnBlockPadding,
      decoration: BoxDecoration(
        color: _blockFill,
        borderRadius: BorderRadius.circular(metrics.columnBlockRadius),
      ),
      child: metrics.collapsibleColumns
          ? _accordion(context, strings)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Expanded, not a fixed width: the heading and the two icons
                // are the only part of the block that can absorb a narrower
                // iPad, and pinning it would push the fields off the edge
                // instead of letting the gap close.
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: metrics.columnLeadingWidth,
                    ),
                    child: _heading(context, strings),
                  ),
                ),
                _typeField(
                  context,
                  strings,
                  width: metrics.columnFieldWidth,
                ),
                SizedBox(width: metrics.columnFieldGap),
                _nameField(strings, width: metrics.columnFieldWidth),
              ],
            ),
    );
  }

  // ── Phone: the folded block ────────────────────────────────────────────────

  /// Figma 7398:11775 (folded) and 7398:11789 (open).
  ///
  /// The two glyphs stay on the FOLDED bar as well as the open one, so a column
  /// can be duplicated or dropped without opening it first — the Figma draws
  /// them on both, and hunting for the remove control inside a tile you have to
  /// unfold is the thing an accordion usually gets wrong.
  Widget _accordion(BuildContext context, CreateTableStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _foldedBar(strings),
        if (_expanded) ...<Widget>[
          SizedBox(height: metrics.stackedFieldGap),
          _typeField(context, strings, width: null),
          SizedBox(height: metrics.stackedFieldGap),
          _nameField(strings, width: null),
          SizedBox(height: metrics.columnIconsTopGap),
          _iconRow(strings, gap: metrics.stackedIconGap),
        ],
      ],
    );
  }

  /// The always-visible bar: title, the two glyphs, the chevron.
  Widget _foldedBar(CreateTableStrings strings) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(metrics.columnBlockRadius),
      child: SizedBox(
        height: metrics.collapsedColumnHeight,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _foldedTitle(strings),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.text),
              ),
            ),
            // Only on the folded bar — once the block is open the glyphs sit
            // under the fields, where Figma 7398:11803 / 11809 put them.
            if (!_expanded) _iconRow(strings, gap: metrics.columnIconGap),
            SizedBox(width: metrics.columnIconGap),
            // Turns to point up when the block is open, which is the whole
            // reason the chevron is there rather than a static glyph.
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: metrics.columnChevronSize,
                color: AppColors.icon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The column's own name once it has one, "1st Column" until then.
  ///
  /// See this file's header: the Figma's tiles all read "First Row" because
  /// they are drawn empty, and four tiles with the same label are a list you
  /// cannot navigate.
  String _foldedTitle(CreateTableStrings strings) {
    final String typed = widget.nameController.text.trim();
    return typed.isEmpty ? strings.nthColumn(widget.index) : typed;
  }

  // ── Parts ──────────────────────────────────────────────────────────────────

  /// "1st Column" with the duplicate and remove glyphs under it.
  Widget _heading(BuildContext context, CreateTableStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          strings.nthColumn(widget.index),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: metrics.columnHeadingToIcons),
        _iconRow(strings, gap: metrics.columnIconGap),
      ],
    );
  }

  /// The duplicate and remove glyphs, side by side.
  ///
  /// Shared by all three placements — under the heading on an iPad, on the
  /// folded bar, and under the stacked fields — because they are the same two
  /// controls doing the same two things. Only the [gap] between them moves:
  /// wider when they stand alone on a phone (see
  /// `CreateTableMetrics.stackedIconGap`).
  Widget _iconRow(CreateTableStrings strings, {required double gap}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.canDuplicate)
          _iconButton(
            asset: CreateTableAssets.duplicateColumn,
            tooltip: strings.duplicateColumn,
            onTap: widget.onDuplicate,
            // The copy glyph is a neutral outline in the Figma, so it takes
            // the icon colour; the remove glyph ships pre-coloured red.
            color: AppColors.icon,
          ),
        if (widget.canDuplicate && widget.canRemove) SizedBox(width: gap),
        if (widget.canRemove)
          _iconButton(
            asset: CreateTableAssets.removeColumn,
            tooltip: strings.removeColumn,
            onTap: widget.onRemove,
          ),
      ],
    );
  }

  /// A 20pt glyph with a real tap target around it.
  ///
  /// The Figma draws these at 20x20 with 25pt of air between them, which is
  /// under the 44pt minimum a finger needs — so the ICON stays 20 and the
  /// `InkResponse` takes the extra room, rather than the icon growing and the
  /// block no longer matching the design.
  Widget _iconButton({
    required String asset,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: widget.enabled ? onTap : null,
        radius: 22.r,
        child: Padding(
          padding: EdgeInsets.all(2.r),
          child: CustomSvgImage(
            assetPath: asset,
            width: metrics.columnIconSize,
            height: metrics.columnIconSize,
            color: color,
          ),
        ),
      ),
    );
  }

  /// "Data Type" — the six-value menu, Figma `Columns type` 7398:8196.
  Widget _typeField(
    BuildContext context,
    CreateTableStrings strings, {
    required double? width,
  }) {
    final bool isArabic = context.isArabic;

    final Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.dataType, style: _labelStyle),
        SizedBox(height: 6.h),
        CustomDropdown<TableColumnType>(
          value: widget.column.type,
          hint: strings.selectDataType,
          fillColor: _fieldFill,
          enabled: widget.enabled,
          valueStyle:
              StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
          itemStyle:
              StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
          hintStyle: _hintStyle,
          items: TableColumnType.values
              .map(
                (TableColumnType type) => DropdownItem<TableColumnType>(
                  value: type,
                  label: type.localizedLabel(isArabic: isArabic),
                ),
              )
              .toList(),
          onChanged: widget.onTypeChanged,
        ),
      ],
    );

    return width == null ? field : SizedBox(width: width, child: field);
  }

  /// "Column Name" — one field, not an EN/AR pair. See `TableColumn.name`.
  ///
  /// NO VALIDATION (17/8/2026). It takes any text.
  ///
  /// It used to be governed by the dropdown beside it: the Data Type supplied a
  /// keystroke filter, a keyboard and a hint, an inline error appeared when the
  /// text did not match the type, and Create refused to save until it did. All
  /// of that is gone, because the rule was aimed at the wrong thing.
  ///
  /// A Column Name is a HEADING — "Salary", "Start Date", "Employee Name". The
  /// type describes what will go UNDER it, not what it is called, so a Number
  /// column could not be called "Salary" and a Date column could not be called
  /// "Start Date". The filter was refusing every heading anybody would actually
  /// type.
  ///
  /// The type rule itself is untouched on `TableColumnType`, and
  /// `TableColumnInputRules` still exists: both are waiting for the Form
  /// Builder's cell editors, which is where "this column holds numbers" is a
  /// statement about the input.
  ///
  /// The one formatter left is the length cap, which is not a validity rule —
  /// it is the Figma's ceiling on the field, and without it a pasted paragraph
  /// becomes a table heading.
  Widget _nameField(CreateTableStrings strings, {required double? width}) {
    final Widget field = CustomTextField(
      controller: widget.nameController,
      label: strings.columnName,
      labelStyle: _labelStyle,
      hint: strings.columnNameHint,
      hintStyle: _hintStyle,
      onChanged: widget.onNameChanged,
      enabled: widget.enabled,
      // Plain text, whatever the Data Type says. A numeric keypad over a field
      // that accepts anything would be the old rule surviving as an obstacle.
      keyboardType: TextInputType.text,
      // Raw Figma value, NOT a scaled one: CustomTextField documents `height`
      // as "interpreted in .h" and applies it itself, so a pre-scaled number
      // would be scaled twice.
      height: CreateDatabaseMetrics.figmaFieldHeight,
      fillColor: _fieldFill,
      // The Figma shows no counter under a column name. CustomTextField turns
      // its counter on whenever `maxLength` is set, so the limit rides in as a
      // formatter instead — the same trick `CreateDatabaseFormCard` uses on the
      // title fields.
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(
          CreateTableLimits.columnNameMaxLength,
        ),
      ],
      showCharCount: false,
    );

    return width == null ? field : SizedBox(width: width, child: field);
  }
}
