/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_form_card.dart
/// Purpose: Declares `CreateTableFormCard`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The white card on the Creating Table screen: bilingual table name, bilingual
/// description, Comments Access, the two count fields, and the column blocks.
/// Figma `Rectangle 34625252` — node 7398:6534 (iPad H) / 7398:6733 (iPad V),
/// and 7398:6935 / 7398:7122 for the Editing Table Name variant.
///
/// ONE FILE FOR BOTH ORIENTATIONS AND BOTH MODES, for the same reason
/// `CreateDatabaseFormCard` is: the two orientations differ only by the field
/// widths inside a column block (`CreateTableMetrics.columnFieldWidth`), and
/// the two modes differ only by whether the two count fields are drawn. Every
/// other measurement is identical across all four frames.
///
/// FIELD ORDER IS THE FIGMA'S, NOT THE ENTITY'S
/// --------------------------------------------
/// Name -> Description EN -> Description AR -> Comments Access -> counts ->
/// columns. The counts sit BELOW the description rather than next to the name,
/// which reads oddly until you notice why: they size the blocks directly
/// underneath them, so the number and the thing it changes stay adjacent.
///
/// THE DRAG HANDLES ARE NOT DRAWN
/// ------------------------------
/// The Figma puts a three-bar handle in the 19pt gutter left of every block
/// (7398:6713 and siblings), implying the columns can be reordered by dragging.
/// Reordering is not implemented in this pass, so the handle is left out rather
/// than drawn dead — the same rule the details screen followed for "+ Table"
/// before this section existed. `CreateTableCubit` already re-stamps `order`
/// from list position on every mutation, so adding it later is one method, not
/// a migration.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/create_table_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_column_block.dart';

class CreateTableFormCard extends StatelessWidget {
  const CreateTableFormCard({
    super.key,
    required this.metrics,
    required this.state,
    required this.cubit,
    required this.nameEnController,
    required this.nameArController,
    required this.descriptionEnController,
    required this.descriptionArController,
    required this.rowCountController,
    required this.columnCountController,
    required this.columnControllerFor,
    required this.columnCountFocusNode,
    required this.onColumnCountChanged,
    required this.onColumnCountCommitted,
  });

  final CreateTableMetrics metrics;
  final CreateTableState state;
  final CreateTableCubit cubit;

  final TextEditingController nameEnController;
  final TextEditingController nameArController;
  final TextEditingController descriptionEnController;
  final TextEditingController descriptionArController;
  final TextEditingController rowCountController;
  final TextEditingController columnCountController;

  /// The page owns one controller per column id and hands it over here. Keeping
  /// them out of this widget is what lets a block survive the list being
  /// rebuilt: a controller created in `build` would reset the cursor on every
  /// keystroke.
  final TextEditingController Function(TableColumn column) columnControllerFor;

  /// Owned by the page so it can tell whether the user is mid-edit before
  /// rewriting the box — see [onColumnCountCommitted].
  final FocusNode columnCountFocusNode;

  /// Every keystroke in "Enter Column Number". Validates the range and nothing
  /// else.
  final ValueChanged<String> onColumnCountChanged;

  /// The user has FINISHED with "Enter Column Number" — submitted it or moved
  /// focus away.
  ///
  /// Resizing is deliberately not done per keystroke: going from 12 to 2 passes
  /// through "1", and a card that applied every intermediate value would delete
  /// eleven blocks before the user typed the second digit.
  ///
  /// The page handles it rather than the cubit, because shrinking the list can
  /// destroy named blocks and that needs a confirmation dialog — which needs a
  /// BuildContext the cubit does not have.
  final ValueChanged<String> onColumnCountCommitted;

  /// The grey fill behind every field ON THE CARD.
  ///
  /// Not `AppColors.field` — that is white in light mode, which would make the
  /// fields disappear into the white card. Note the column blocks invert this;
  /// see `TableColumnBlock`.
  Color get _fieldFill =>
      AppTheme.isDark ? AppColors.colorBlack : AppColors.fieldFillLight;

  /// Figma labels are the small 12/500 token, not CustomTextField's 14/500
  /// default.
  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  TextStyle get _hintStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText);

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    return Container(
      width: double.infinity,
      padding: metrics.base.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(metrics.base.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ── Table name: English | Arabic (Figma 7398:6580 / 6583) ─────────
          buildResponsiveFields(
            context: context,
            left: _nameField(
              controller: nameEnController,
              label: strings.tableNameEn,
              hint: strings.hintEn,
              direction: TextDirection.ltr,
              errorText: state.visibleNameEnError,
              onChanged: cubit.nameEnChanged,
            ),
            right: _nameField(
              controller: nameArController,
              label: strings.tableNameAr,
              hint: strings.hintAr,
              direction: TextDirection.rtl,
              errorText: state.visibleNameArError,
              onChanged: cubit.nameArChanged,
            ),
          ),
          SizedBox(height: metrics.base.blockGap),

          // ── Description: English (Figma 7398:6695) ────────────────────────
          // Stacked rather than side by side because the Figma gives each
          // description the card's full width (835 landscape / 635 portrait).
          _descriptionField(
            controller: descriptionEnController,
            label: strings.descriptionEn,
            hint: strings.hintEn,
            direction: TextDirection.ltr,
            onChanged: cubit.descriptionEnChanged,
          ),
          SizedBox(height: metrics.base.blockGap),

          // ── Description: Arabic (Figma 7398:6699) ─────────────────────────
          _descriptionField(
            controller: descriptionArController,
            label: strings.descriptionAr,
            hint: strings.hintAr,
            direction: TextDirection.rtl,
            onChanged: cubit.descriptionArChanged,
          ),
          SizedBox(height: metrics.base.blockGap),

          // ── Comments Access (Figma 7398:6702) ─────────────────────────────
          _commentsAccessField(context, strings),
          SizedBox(height: metrics.base.blockGap),

          // ── Row / Column counts — CREATE ONLY (Figma 7398:6577 / 6586) ────
          // The Editing Table Name frame (7398:6934) drops both: the row count
          // is fixed once the table exists, and the column count is edited by
          // adding and removing blocks directly.
          if (!state.isEditing) ...<Widget>[
            buildResponsiveFields(
              context: context,
              left: _countField(
                controller: rowCountController,
                label: strings.enterRowNumber,
                errorText: state.visibleRowCountError,
                onChanged: (String value) => cubit.rowCountChanged(
                  value,
                  rangeMessage: strings.rowCountRange,
                ),
              ),
              right: _countField(
                controller: columnCountController,
                focusNode: columnCountFocusNode,
                label: strings.enterColumnNumber,
                errorText: state.visibleColumnCountError,
                onChanged: onColumnCountChanged,
                onSubmitted: onColumnCountCommitted,
                onFocusChanged: (bool hasFocus) {
                  if (hasFocus) return;
                  onColumnCountCommitted(columnCountController.text);
                },
              ),
            ),
            SizedBox(height: metrics.countsToColumns),
          ],

          // ── Column blocks ─────────────────────────────────────────────────
          for (int i = 0; i < state.columns.length; i++) ...<Widget>[
            TableColumnBlock(
              // Keyed by the column's own id, NOT by index: without this,
              // removing the second of four blocks makes Flutter reuse the
              // third block's element for the row that used to be fourth and
              // the names visibly shuffle.
              key: ValueKey<String>(state.columns[i].id),
              metrics: metrics,
              index: i,
              column: state.columns[i],
              nameController: columnControllerFor(state.columns[i]),
              enabled: !state.isSubmitting,
              canRemove: state.columns.length > CreateTableLimits.minColumns,
              canDuplicate:
                  state.columns.length < CreateTableLimits.maxColumns,
              onNameChanged: (String value) =>
                  cubit.columnNameChanged(state.columns[i].id, value),
              onTypeChanged: (TableColumnType type) =>
                  cubit.columnTypeChanged(state.columns[i].id, type),
              onDuplicate: () => cubit.duplicateColumn(state.columns[i].id),
              onRemove: () => cubit.removeColumn(state.columns[i].id),
            ),
            if (i != state.columns.length - 1)
              SizedBox(height: metrics.columnBlockGap),
          ],
        ],
      ),
    );
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  /// One table-name field. The Arabic side is wrapped in an RTL
  /// [Directionality] so its label right-aligns and its counter mirrors — the
  /// same trick the bilingual database card uses.
  Widget _nameField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextDirection direction,
    required String? errorText,
    required ValueChanged<String> onChanged,
  }) {
    return Directionality(
      textDirection: direction,
      child: CustomTextField(
        controller: controller,
        label: label,
        labelStyle: _labelStyle,
        hint: hint,
        hintStyle: _hintStyle,
        errorText: errorText,
        onChanged: onChanged,
        textDirection: direction,
        // The Figma shows no counter under the names — only under the two
        // descriptions. CustomTextField switches its counter on whenever
        // `maxLength` is set, so the limit is enforced by a formatter instead.
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(CreateDatabaseLimits.titleMaxLength),
        ],
        // Raw Figma value: CustomTextField applies `.h` itself.
        height: CreateDatabaseMetrics.figmaFieldHeight,
        fillColor: _fieldFill,
        showCharCount: false,
        enabled: !state.isSubmitting,
      ),
    );
  }

  /// One description block: label, 72pt box, and the `0 / 500` counter
  /// underneath. The counter, its numerals and its side are all handled by
  /// CustomTextField once `textDirection` is set — an RTL field counts in
  /// Arabic-Indic digits, which is what `٥٠٠/٠` in the Figma is.
  Widget _descriptionField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextDirection direction,
    required ValueChanged<String> onChanged,
  }) {
    return Directionality(
      textDirection: direction,
      child: CustomTextField(
        controller: controller,
        label: label,
        labelStyle: _labelStyle,
        hint: hint,
        hintStyle: _hintStyle,
        onChanged: onChanged,
        textDirection: direction,
        maxLines: null,
        minLines: 3,
        maxLength: CreateDatabaseLimits.descriptionMaxLength,
        showCharCount: true,
        height: CreateDatabaseMetrics.figmaDescriptionHeight,
        fillColor: _fieldFill,
        enabled: !state.isSubmitting,
      ),
    );
  }

  /// "Enter Row Number" / "Enter Column Number".
  ///
  /// `onlyDigits` does three things at once — a digits-only formatter, a number
  /// keyboard, and the "Only numbers are allowed." message — so none of them
  /// has to be restated here.
  Widget _countField({
    required TextEditingController controller,
    required String label,
    required String? errorText,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChanged,
  }) {
    return CustomTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      labelStyle: _labelStyle,
      hint: '0',
      hintStyle: _hintStyle,
      errorText: errorText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChanged: onFocusChanged,
      textInputAction: TextInputAction.done,
      onlyDigits: true,
      height: CreateDatabaseMetrics.figmaFieldHeight,
      fillColor: _fieldFill,
      enabled: !state.isSubmitting,
    );
  }

  /// Comments Access. Half-width on both orientations (410 landscape / 310
  /// portrait) — the same width as one name column, so it lines up with the
  /// field above it. `buildResponsiveFields` with an empty right slot is what
  /// produces that without a magic number.
  ///
  /// The Figma explains the two values in a hover card (7398:6706). A hover
  /// card cannot be opened on an iPad, so the selected value's own sentence is
  /// shown inline as helper text instead — the information the designer wanted
  /// there, delivered by something a finger can reach.
  Widget _commentsAccessField(
    BuildContext context,
    CreateTableStrings strings,
  ) {
    final bool isArabic = context.isArabic;

    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(strings.commentsAccess, style: _labelStyle),
          SizedBox(height: 6.h),
          CustomDropdown<TableCommentsAccess>(
            value: state.commentsAccess,
            hint: strings.selectCommentsAccess,
            helperText: state.commentsAccess.localizedHint(isArabic: isArabic),
            helperStyle: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
            fillColor: _fieldFill,
            enabled: !state.isSubmitting,
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            itemStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            hintStyle: _hintStyle,
            items: TableCommentsAccess.values
                .map(
                  (TableCommentsAccess access) =>
                      DropdownItem<TableCommentsAccess>(
                    value: access,
                    label: access.localizedLabel(isArabic: isArabic),
                  ),
                )
                .toList(),
            onChanged: cubit.commentsAccessChanged,
          ),
        ],
      ),
      // Empty second column keeps the dropdown at half width on tablet and lets
      // it go full width on a narrow window, matching the name row's behaviour
      // instead of contradicting it.
      right: const SizedBox.shrink(),
    );
  }
}
