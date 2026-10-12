/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: viewable_fields_field.dart
/// Purpose: Declares `ViewableFieldsField` and `ViewableFieldOption`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The "Viewable Fields" control: a multi-select over a table's columns with
/// the picked ones spilled underneath as removable chips.
///
/// Figma: `Group 1597883013` (7398:14663, iPad V) and `Group 1597883009`
/// (7398:19078, iPad H) — a 310/410 x 36 trigger reading "Select Viewable
/// Fields", with 28pt chips below it each carrying a 12pt close glyph.
///
/// WHY IT LIVES IN db3 (MOVED 16/8/2026)
/// -------------------------------------
/// It started in db1 because two screens drew it: db1's Access Review and
/// db3's Editing Table Access. db1's copy is gone — a database being created
/// has no tables, so it had no columns to offer and rendered a permanently
/// disabled control plus a summary tile that could only ever say "All fields".
/// With one caller left, the widget belongs next to it: the options are a
/// TABLE's columns, and tables are db3's subject.
///
/// EMPTY SELECTION MEANS "ALL FIELDS"
/// ----------------------------------
/// Nothing ticked is not "this person sees nothing" — it is the unrestricted
/// grant, which is what every grant written before this control existed was.
/// The trigger says so rather than sitting blank, because a control whose empty
/// state looks like a missing answer gets filled in by people who did not need
/// to. See `DatabaseAccessGrant.viewableFields`.
///
/// NO OPTIONS IS A DIFFERENT STATE AGAIN
/// -------------------------------------
/// A table whose columns have no names yet has nothing to offer. The control is
/// disabled and says why, instead of opening an empty menu — the one thing that
/// would read as broken.

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';

/// One selectable field. Id and label are separate because the grant stores the
/// ID — a column can be renamed and the grant has to keep pointing at it.
class ViewableFieldOption {
  const ViewableFieldOption({required this.id, required this.label});

  final String id;
  final String label;
}

class ViewableFieldsField extends StatelessWidget {
  const ViewableFieldsField({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    this.noOptionsLabel,
    this.compact = false,
  });

  /// Every column the grant could be limited to.
  final List<ViewableFieldOption> options;

  /// Column ids currently ticked. Empty means "all fields".
  final List<String> selected;

  final ValueChanged<List<String>> onChanged;

  final bool enabled;

  /// Drops the "Viewable Fields" heading and lets the dropdown take the width
  /// it is given, for the PER-MEMBER copies on the review screen (Figma
  /// 7398:14122 / 14296) — a heading over every one of twenty rows would say
  /// the same thing twenty times, and the half-width treatment below is meant
  /// for a control sitting alone on a card.
  final bool compact;

  /// Shown in place of the menu when [options] is empty. The caller knows WHY
  /// there is nothing to pick, so it supplies the sentence rather than this
  /// widget guessing.
  final String? noOptionsLabel;

  Color get _fill => AppColors.background;

  TextStyle get _label =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  Widget _maybeResponsive(BuildContext context, Widget field) => compact
      ? field
      : buildResponsiveFields(
          context: context,
          left: field,
          right: const SizedBox.shrink(),
        );

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool hasOptions = options.isNotEmpty;

    // Ids that no longer match a column — the column was removed from the table
    // after the grant was written. They are dropped from the chips rather than
    // rendered as blanks.
    final List<ViewableFieldOption> chosen = <ViewableFieldOption>[
      for (final ViewableFieldOption option in options)
        if (selected.contains(option.id)) option,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (!compact) ...<Widget>[
          Text(strings.viewableFields, style: _label),
          SizedBox(height: 6.h),
        ],

        // Half width on tablet, full width on a narrow window — the same
        // treatment the Permissions dropdown gets one block above, so the two
        // line up instead of one running the card's full width. A compact copy
        // skips it and fills whatever slot the row gives it.
        _maybeResponsive(
          context,
          CustomMultiSelectDropdown<String>(
            values: <String>[
              for (final ViewableFieldOption option in chosen) option.id,
            ],
            items: <MultiSelectDropdownItem<String>>[
              for (final ViewableFieldOption option in options)
                MultiSelectDropdownItem<String>(
                  value: option.id,
                  label: option.label,
                ),
            ],
            hint: strings.selectViewableFields,
            fillColor: _fill,
            enabled: enabled && hasOptions,
            helperText: hasOptions
                ? null
                : (noOptionsLabel ?? strings.tableHasNoNamedColumns),
            helperStyle: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            itemStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.secondaryText),
            // "3 fields" rather than "Employee Name, Department, Job Title",
            // which overflows a 310pt trigger by the third column. The chips
            // below already name them, so the trigger only has to say how many.
            selectedTextBuilder:
                (List<MultiSelectDropdownItem<String>> picked) =>
                    picked.isEmpty
                        ? strings.allFields
                        : strings.fieldsSelected(picked.length),
            onChanged: onChanged,
          ),
        ),

        if (chosen.isNotEmpty) ...<Widget>[
          SizedBox(height: 12.h),
          // Wrap, not a Row: the Figma runs the chips onto a second line once
          // they pass the card's width (7398:14687 sits below 7398:14669), and
          // a Row would ellipsise instead of wrapping.
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              for (final ViewableFieldOption option in chosen)
                _FieldChip(
                  label: option.label,
                  onRemove: enabled
                      ? () => onChanged(<String>[
                            for (final String id in selected)
                              if (id != option.id) id,
                          ])
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// One picked field, with the close glyph the Figma puts on it (7398:14670 —
/// a 12pt vector inside a 28pt pill).
class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.label, this.onRemove});

  final String label;

  /// Null while the form is submitting, which greys the glyph rather than
  /// removing it — a chip that loses its X mid-save looks like it was already
  /// deleted.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color:
            AppTheme.isDark ? AppColors.colorBlack : AppColors.fieldFillLight,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style:
                StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            // A Material glyph rather than an SVG: the bundle has no plain
            // 12pt close mark — `AppAssets.close` is the red close-CIRCLE used
            // for destructive actions, and a red badge on every picked field
            // would read as an error state. Same call `MemberGrid._RemoveButton`
            // makes with `Icons.remove`.
            child: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/removed.svg")
          ),
        ],
      ),
    );
  }
}
