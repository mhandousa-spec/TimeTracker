/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: member_viewable_fields_list.dart
/// Purpose: Declares `MemberViewableFieldsList`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// Step 2 of "Editing Table Access" — Figma 7398:14122 (cards) and 7398:14296
/// (list), the two views of the same thing behind one toggle.
///
/// EVERY PERSON GETS THEIR OWN VIEWABLE FIELDS
/// -------------------------------------------
/// That is the whole screen. Until 17/8/2026 the review screen carried ONE
/// Viewable Fields control for the entire selection, which cannot express what
/// the design asks for: two people on one table being shown different columns.
/// `TableAccessState.memberFields` holds the per-person answer and
/// `TableAccessCubit.save` writes one grant document per DISTINCT field set.
///
/// WHAT IS NOT HERE, AND WHY
/// -------------------------
/// No Permissions dropdown and no Access Begins / Access Ends. Neither frame
/// draws them, and they are not missing — they come from the grant that was
/// created earlier and this screen carries them through untouched. The review
/// page renders the rule fields only when there is no rule to inherit (see
/// `TableAccessState.hasInheritedRule`), because a table nobody has ever
/// granted access to has no permission to carry and Save could never enable.
///
/// TWO VIEWS, ONE ROW MODEL
/// ------------------------
/// The card view (7398:14122) and the table view (7398:14296) show the same
/// four facts — face, name, department, job title — plus the same Viewable
/// Fields control. They differ only in arrangement, so they share
/// [_fieldsControl] and differ below it rather than being two widgets.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/viewable_fields_field.dart';

/// One person as this list needs them: the record, the columns they may see,
/// and the two labels the directory resolved.
class MemberFieldsRow {
  const MemberFieldsRow({
    required this.member,
    required this.fields,
    required this.nameLabel,
    required this.departmentLabel,
    required this.jobTitleLabel,
  });

  final DatabaseMember member;

  /// Column ids this person may see. Empty means all of them.
  final List<String> fields;

  /// Resolved by the PAGE, not here: `DatabaseMember` carries an EN and an AR
  /// name and choosing between them needs the locale, which a widget this deep
  /// would have to re-read on every row.
  final String nameLabel;

  final String departmentLabel;
  final String jobTitleLabel;
}

class MemberViewableFieldsList extends StatelessWidget {
  const MemberViewableFieldsList({
    super.key,
    required this.rows,
    required this.options,
    required this.isTableView,
    required this.onFieldsChanged,
    required this.onRemove,
    this.enabled = true,
  });

  final List<MemberFieldsRow> rows;

  /// Every column the table has — the same list for everybody, because the
  /// options are the TABLE's columns and only the choice among them is personal.
  final List<ViewableFieldOption> options;

  /// 7398:14296 when true, 7398:14122 when false.
  final bool isTableView;

  final void Function(DatabaseMember member, List<String> fields)
      onFieldsChanged;

  /// The red circle on a card, the tick column in the table.
  final ValueChanged<DatabaseMember> onRemove;

  final bool enabled;

  /// Measured from 7398:14296.
  static const double _tickWidth = 44;
  static const double _pictureWidth = 64;
  static const double _nameWidth = 160;
  static const double _departmentWidth = 130;
  static const double _jobWidth = 130;
  static const double _fieldsWidth = 420;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const CustomEmptyState();

    return isTableView ? _table(context) : _cards(context);
  }

  // ── Cards (7398:14122) ───────────────────────────────────────────────────

  Widget _cards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final MemberFieldsRow row in rows) ...<Widget>[
          _card(context, row),
          SizedBox(height: 12.sp),
        ],
      ],
    );
  }

  /// ON A PHONE THE IDENTITY LINE BECOMES THREE (17/8/2026)
  ///
  /// The four parts — name, Department, Job Title, remove — share one line on
  /// an iPad because the card is 835 or 625 wide. On the phone card the same
  /// row has about 195pt to split between three `Flexible` texts, which is 65
  /// each: every one of them ellipsises to its label and the card stops saying
  /// anything about anybody. Figma 7398:17843 stacks them — "Amro Handousa" /
  /// "Marketing Manger" / "Marketing", one per line — and so does this.
  ///
  /// The remove glyph stays on the FIRST line either way, beside the name it
  /// removes.
  Widget _card(BuildContext context, MemberFieldsRow row) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool stacked = CreateDatabaseMetrics.isNarrowWindow(context);

    final Widget name = Text(
      FormatHelper.capitalize(row.nameLabel),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
    );

    // Labelled inline, exactly as the Figma writes them — "Department: IT",
    // "Job Title: Technician" — because on a card with no column headings the
    // label is the only thing that says which of the two a value is.
    final Widget department = _labelled(strings.department, row.departmentLabel);
    final Widget jobTitle = _labelled(strings.colJobTitle, row.jobTitleLabel);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (stacked) ...<Widget>[
            Row(
              children: <Widget>[
                _avatar(row),
                SizedBox(width: 10.sp),
                Expanded(child: name),
                SizedBox(width: 10.sp),
                _removeButton(row),
              ],
            ),
            SizedBox(height: 6.sp),
            department,
            SizedBox(height: 2.sp),
            jobTitle,
          ] else
            Row(
              children: <Widget>[
                _avatar(row),
                SizedBox(width: 10.sp),
                Flexible(child: name),
                SizedBox(width: 16.sp),
                Flexible(child: department),
                SizedBox(width: 16.sp),
                Flexible(child: jobTitle),
                const Spacer(),
                _removeButton(row),
              ],
            ),
          SizedBox(height: 10.sp),
          _fieldsControl(row),
        ],
      ),
    );
  }

  Widget _labelled(String label, String value) {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style:
            StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
        children: <TextSpan>[
          TextSpan(
            text: value.isEmpty ? '—' : FormatHelper.capitalize(value),
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// The red circle of 7398:14122. Removing somebody here does NOT delete them
  /// silently — the cubit keeps them as a `RemovedAccessMember` so the Access
  /// list's "Removed" row can still be drawn.
  Widget _removeButton(MemberFieldsRow row) {
    return GestureDetector(
      onTap: enabled ? () => onRemove(row.member) : null,
      behavior: HitTestBehavior.opaque,
      child: CustomSvgImage(
        assetPath: CreateTableAssets.removeColumn,
        width: 22.sp,
        height: 22.sp,
        fit: BoxFit.contain,
      ),
    );
  }

  // ── Table (7398:14296) ───────────────────────────────────────────────────

  Widget _table(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool isLight = !AppTheme.isDark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // The same heading pair every table in this module uses.
            Container(
              height: 46.sp,
              color: isLight ? AppColors.black : AppColors.blackShadow,
              child: Row(
                children: <Widget>[
                  SizedBox(width: _tickWidth.sp),
                  _head(strings.colPicture, _pictureWidth),
                  _head(strings.colName, _nameWidth),
                  _head(strings.department, _departmentWidth),
                  _head(strings.colJobTitle, _jobWidth),
                  _head(strings.viewableFields, _fieldsWidth),
                ],
              ),
            ),
            for (int i = 0; i < rows.length; i++) _tableRow(rows[i], i, isLight),
          ],
        ),
      ),
    );
  }

  Widget _head(String label, double width) => SizedBox(
        width: width.sp,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.sp),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                StyleText.fontSize12Weight500.copyWith(color: AppColors.white),
          ),
        ),
      );

  Widget _tableRow(MemberFieldsRow row, int index, bool isLight) {
    final bool isEven = index.isEven;
    final Color stripe = isLight
        ? (isEven ? AppColors.oddRowColor : AppColors.white)
        : (isEven ? AppColors.darkDashboardTable : AppColors.black);

    return Container(
      color: stripe,
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: _tickWidth.sp,
            child: GestureDetector(
              onTap: enabled ? () => onRemove(row.member) : null,
              behavior: HitTestBehavior.opaque,
              // Not `const`: `CustomCheckBox` has mutable fields and no const
              // constructor. Align, not the bare box — a fixed-width slot hands
              // down a TIGHT width that a `Container`'s own width cannot
              // override, which would stretch the tick to the column.
              child: Align(
                alignment: AlignmentDirectional.center,
                child: CustomCheckBox(isSelected: true),
              ),
            ),
          ),
          SizedBox(
            width: _pictureWidth.sp,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                child: _avatar(row),
              ),
            ),
          ),
          _cell(FormatHelper.capitalize(row.nameLabel), _nameWidth),
          _cell(row.departmentLabel, _departmentWidth),
          _cell(row.jobTitleLabel, _jobWidth),
          SizedBox(
            width: _fieldsWidth.sp,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              child: _fieldsControl(row),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String value, double width) => SizedBox(
        width: width.sp,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.sp),
          child: Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
        ),
      );

  // ── Shared ───────────────────────────────────────────────────────────────

  /// The one control both views exist for.
  Widget _fieldsControl(MemberFieldsRow row) => ViewableFieldsField(
        compact: true,
        options: options,
        selected: row.fields,
        enabled: enabled,
        onChanged: (List<String> fields) => onFieldsChanged(row.member, fields),
      );

  Widget _avatar(MemberFieldsRow row) {
    final String? photo = row.member.photoUrl;

    return CircleAvatar(
      radius: 16.sp,
      backgroundColor: AppColors.moreLightGrey,
      foregroundImage:
          photo == null || photo.isEmpty ? null : NetworkImage(photo),
      // The placeholder is an unconditional child under the photo, so a broken
      // URL falls back to it rather than to an empty circle.
      child: CustomSvgImage(
        assetPath: 'assets/icons_assets/main_icons_assets/assets_male.svg',
        width: 32.sp,
        height: 32.sp,
        fit: BoxFit.cover,
      ),
    );
  }
}
