/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: member_access_rule_list.dart
/// Purpose: Declares `MemberAccessRuleList` and `MemberAccessRule`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
/// Updated: 16/8/2026 - Laid out from the measured Figma geometry rather than
///          from `Expanded`s; every number now comes from
///          `DatabaseDetailsMetrics`.
///
/// The people list on the RESTRICTED access editor, in both of the views the
/// Figma draws for it:
///
///   CARDS  7398:10176 (1024) / 7398:10458 (768) — one card per person:
///          avatar, name, "Job Title:", "Department:", a tick, and their own
///          Access Begins / Access Ends / Permissions row underneath.
///   TABLE  7398:19187 (768) — the same people as rows:
///          Picture | Name | Department | Job Title | Access Begin |
///          Access End | Permissions.
///
/// THE FIELDS ARE FIXED-WIDTH AND LEFT-ALIGNED
/// -------------------------------------------
/// This is the thing that makes the card read as the design rather than as a
/// generic form. `Frame 1597881880` measures its three controls at 150 / 150 /
/// 135 in the 655-wide card AND in the 865-wide one — so at 1024 the row ends
/// 351pt short of the card's right edge, on purpose. Stretched with `Expanded`
/// the fields become 270pt date pickers and the card stops looking like the
/// Figma at all. The widths live in `DatabaseDetailsMetrics`.
///
/// The identity row is fixed the same way: name at 60, "Job Title:" at 208,
/// "Department:" at 354 from the card's left edge, in both widths.
///
/// WHY THE FIELDS OF AN UNPICKED PERSON ARE DISABLED, NOT HIDDEN
/// ------------------------------------------------------------
/// Hiding them makes every card change height as it is ticked, and a list that
/// reflows under the finger is a list that gets mis-tapped.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_details_metrics.dart';

/// One person plus the rule they currently hold, or null while unpicked.
class MemberAccessRule {
  const MemberAccessRule({required this.member, this.grant});

  final DatabaseMember member;

  /// Their single-member grant. Null means "not picked" — which is why the
  /// widget can tell an unpicked person from one picked with nothing filled
  /// in, and refuse to write a rule for the former.
  final DatabaseAccessGrant? grant;

  bool get isSelected => grant != null;
}

class MemberAccessRuleList extends StatelessWidget {
  const MemberAccessRuleList({
    super.key,
    required this.metrics,
    required this.rules,
    required this.isTableView,
    required this.onToggle,
    required this.onPermissionChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.departmentLabel,
    this.enabled = true,
  });

  final DatabaseDetailsMetrics metrics;

  final List<MemberAccessRule> rules;

  /// True for the list layout (7398:19187), false for the cards (7398:10458).
  final bool isTableView;

  final ValueChanged<DatabaseMember> onToggle;
  final void Function(DatabaseMember, DatabasePermissionLevel) onPermissionChanged;
  final void Function(DatabaseMember, DateTime) onStartDateChanged;
  final void Function(DatabaseMember, DateTime) onEndDateChanged;

  /// Turns a member into the department NAME. The snapshot only carries the
  /// id, and a bare Firestore key under someone's name reads as corruption —
  /// the same rule `MemberGrid` follows, so the lookup is passed in rather
  /// than this widget reaching for a controller.
  final String Function(DatabaseMember member) departmentLabel;

  // `emptyLabel` REMOVED 16/8/2026 — the shared animation replaced it. See
  // `CustomEmptyState`.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return const CustomEmptyState();

    return isTableView ? _table(context) : _cards(context);
  }

  // ── Cards (7398:10458 / 10176) ───────────────────────────────────────────

  Widget _cards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < rules.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: metrics.personCardGap),
          _card(context, rules[i]),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, MemberAccessRule rule) {
    final bool live = enabled && rule.isSelected;

    return Container(
      width: double.infinity,
      // The Figma card is exactly 127 tall (`DatabaseDetailsMetrics.
      // personCardHeight`) and that is NOT imposed here. The three controls
      // are shared widgets that own their own heights — `CustomDropdown` and
      // `CustomDropdownCalendar` size themselves from the app's field
      // padding — so pinning the card to 127 would clip them the first time
      // that padding changed, which is a rendering overflow rather than a
      // design difference. The card hugs its content and lands within a few
      // points of the design; the WIDTHS, which are what actually read as
      // wrong, are pinned exactly.
      padding: metrics.personCardPadding,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _identityRow(context, rule),
          SizedBox(height: metrics.personRowGap),
          _ruleFields(context, rule, live),
        ],
      ),
    );
  }

  /// Avatar · name · "Job Title:" · "Department:" · tick.
  ///
  /// Fixed column widths taken straight off the frame (60 / 208 / 354), which
  /// is why the three labels line up between one card and the next even when
  /// the names underneath them are different lengths. On a phone the fixed
  /// columns do not fit at all, so it degrades to a wrap.
  Widget _identityRow(BuildContext context, MemberAccessRule rule) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    final Widget name = Text(
      FormatHelper.capitalize(rule.member.localizedName(isArabic: isArabic)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
    );
    final Widget job = _labelled(
      strings.jobTitleLabel,
      rule.member.localizedJobTitle(isArabic: isArabic),
    );
    final Widget department = _labelled(
      strings.departmentLabel,
      departmentLabel(rule.member),
    );

    return Row(
      children: <Widget>[
        _avatar(rule.member, metrics.personAvatarSize / 2),
        SizedBox(width: metrics.personAvatarGap),
        Expanded(
          child: metrics.isPhone
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 14.w,
                  runSpacing: 4.h,
                  children: <Widget>[name, job, department],
                )
              : Row(
                  children: <Widget>[
                    SizedBox(width: metrics.personNameWidth, child: name),
                    SizedBox(width: metrics.personJobWidth, child: job),
                    Expanded(child: department),
                  ],
                ),
        ),
        SizedBox(width: 10.w),
        _tick(rule.isSelected, () => onToggle(rule.member)),
      ],
    );
  }

  /// Access Begins | Access Ends | Permissions — fixed widths, left-aligned,
  /// with the card's remaining width left empty exactly as the Figma leaves
  /// it.
  ///
  /// `LayoutBuilder` rather than `context.isPhone`: these fields sit inside a
  /// card whose width is set by the page, so what matters is how much room
  /// THIS row actually got, not how big the device is.
  Widget _ruleFields(
    BuildContext context,
    MemberAccessRule rule,
    bool live,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked =
            constraints.maxWidth < DatabaseDetailsMetrics.ruleRowMinWidth.w;

        final List<Widget> fields = <Widget>[
          _startField(context, rule, live),
          _endField(context, rule, live),
          _permissionField(context, rule, live),
        ];

        if (stacked) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < fields.length; i++) ...<Widget>[
                if (i > 0) SizedBox(height: 10.h),
                fields[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: metrics.ruleDateFieldWidth, child: fields[0]),
            SizedBox(width: metrics.ruleFieldGap),
            SizedBox(width: metrics.ruleDateFieldWidth, child: fields[1]),
            SizedBox(width: metrics.ruleFieldGap),
            SizedBox(width: metrics.rulePermissionFieldWidth, child: fields[2]),
            // The rest of the card stays empty — that is the design, not a
            // missing `Expanded`. See this file's header.
            const Spacer(),
          ],
        );
      },
    );
  }

  Widget _startField(
    BuildContext context,
    MemberAccessRule rule,
    bool live,
  ) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    return CustomDropdownCalendar(
      label: strings.accessBegins,
      labelStyle: _labelStyle,
      hint: strings.date,
      value: rule.grant?.startDate,
      fillColor: _fill,
      enabled: live,
      dateFormatter: (DateTime date) =>
          DatabaseDateFormat.short(date, isArabic: isArabic),
      valueStyle:
          StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize12Weight400
          .copyWith(color: AppColors.secondaryText),
      // The picker hands back null when the field is cleared; a grant has no
      // way to express "unset", so only real dates travel.
      onChanged: (DateTime? date) {
        if (date != null) onStartDateChanged(rule.member, date);
      },
    );
  }

  Widget _endField(BuildContext context, MemberAccessRule rule, bool live) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    return CustomDropdownCalendar(
      label: strings.accessEnds,
      labelStyle: _labelStyle,
      hint: strings.date,
      value: rule.grant?.endDate,
      fillColor: _fill,
      borderRadius: BorderRadius.circular(8.r),
      enabled: live,
      // An end before the start is the one date mistake worth blocking at the
      // picker rather than reporting afterwards.
      firstDate: rule.grant?.startDate,
      dateFormatter: (DateTime date) =>
          DatabaseDateFormat.short(date, isArabic: isArabic),
      valueStyle:
          StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize12Weight400
          .copyWith(color: AppColors.secondaryText),
      onChanged: (DateTime? date) {
        if (date != null) onEndDateChanged(rule.member, date);
      },
    );
  }

  Widget _permissionField(
    BuildContext context,
    MemberAccessRule rule,
    bool live,
  ) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.permissions, style: _labelStyle),
        SizedBox(height: 11.h),
        CustomDropdown<DatabasePermissionLevel>(
          value: rule.grant?.permission,
          hint: strings.selectPermission,
          fillColor: AppColors.card,
          enabled: live,
          borderRadius: BorderRadius.circular(8.r),
          valueStyle:
              StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          itemStyle:
              StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          hintStyle: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
          items: DatabasePermissionLevel.selectable
              .map((DatabasePermissionLevel level) =>
                  DropdownItem<DatabasePermissionLevel>(
                    value: level,
                    label: isArabic ? level.labelAr : level.labelEn,
                  ))
              .toList(growable: false),
          onChanged: (DatabasePermissionLevel level) =>
              onPermissionChanged(rule.member, level),
        ),
      ],
    );
  }

  // ── Table (7398:19187) ───────────────────────────────────────────────────

  /// The list view — the Figma's full column set (7398:19187):
  ///
  ///   Name | Department | Job Title | Access Begin | Access End | Permissions
  ///
  /// THE RULE COLUMNS ARE BACK (17/8/2026)
  /// -------------------------------------
  /// Access Begin, Access End and Permissions were dropped on 16/8/2026, on the
  /// argument that fifteen live controls competing for one horizontal scroll
  /// made a table nobody could read across, and that the CARDS view is where a
  /// rule gets edited. Requested back: switching views to change one date is
  /// worse than a busy table, and this view is the only place the whole set of
  /// rules can be compared down a column — which is the thing a table is for.
  ///
  /// Three things keep it readable, and all three are why this is not simply a
  /// revert:
  ///
  ///   * The controls are UNLABELLED here. Each one's label is its column
  ///     heading, so a row is three boxes rather than three labelled blocks —
  ///     the cards view keeps its labels, because there the fields have no
  ///     heading above them.
  ///   * Every control is pinned to one row height (`_rowFieldHeight`) through
  ///     `CustomDropdown.height` and the calendar's own, so taking a value
  ///     cannot make a row grow and shove the rows under it down.
  ///   * The picture column stays gone. A face needs no heading, so it sits in
  ///     front of the name and the width it would have taken goes to the three
  ///     columns that came back.
  ///
  /// Still hand-built rather than `DataTable`: fixed widths inside a
  /// horizontal scroll keep the columns aligned between the header and the
  /// rows, which intrinsic sizing does not.
  Widget _table(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    // The old picture column's 90 folded into the name's 170 — the tick and
    // the avatar now sit in front of the name inside this one width, so the
    // three columns still start where they used to.
    const double nameWidth = 260;
    const double departmentWidth = 140;
    const double jobWidth = 150;

    // The three rule columns, back on 17/8/2026. The dates get more room than
    // the permission because "28 Nov 2025" plus a calendar glyph is the widest
    // thing either box has to hold; the permission's longest value is
    // "Full Access".
    const double dateWidth = 165;
    const double permissionWidth = 155;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
            child: Container(
              height: 46.h,
              // ONE HEADING COLOUR FOR EVERY TABLE IN THIS MODULE (17/8/2026)
              // — see `AccessTable` and `TableRowsGrid`, which use the same
              // pair. Was `AppColors.header`.
              color: AppTheme.isDark ? AppColors.blackShadow : AppColors.black,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: <Widget>[
                  _head(strings.colName, nameWidth.w),
                  _head(strings.colDepartment, departmentWidth.w),
                  _head(strings.colJobTitle, jobWidth.w),
                  // These three headings ARE the labels for the controls
                  // underneath them — see this method's doc for why the fields
                  // in this view carry none of their own.
                  _head(strings.accessBegins, dateWidth.w),
                  _head(strings.accessEnds, dateWidth.w),
                  _head(strings.permissions, permissionWidth.w),
                ],
              ),
            ),
          ),
          for (int i = 0; i < rules.length; i++)
            Container(
              // Zebra striping, the same pairing the access table uses so the
              // two tables in this section read as one component.
              color: i.isEven
                  ? (AppTheme.isDark
                      ? AppColors.tableRowDark
                      : AppColors.evenRowColor)
                  : (AppTheme.isDark
                      ? AppColors.tableDarkBackground
                      : AppColors.oddRowColor),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              child: Row(
                // The row is as tall as the controls in it, and the text cells
                // centre against them — left at the default the department and
                // job title would sit on the row's top edge with the boxes
                // hanging below.
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Tick, face and name in ONE column. The Figma's row has no
                  // separate select column either, and the row itself is not
                  // tappable — the tick is the only thing that grants or
                  // revokes, so it has to be its own hit target.
                  SizedBox(
                    width: nameWidth.w,
                    child: Row(
                      children: <Widget>[
                        _tick(
                          rules[i].isSelected,
                          () => onToggle(rules[i].member),
                        ),
                        SizedBox(width: 6.w),
                        _avatar(rules[i].member, 14.r),
                        SizedBox(width: 8.w),
                        // Expanded, not a fixed width: the name takes whatever
                        // the tick and the avatar leave, so a long one
                        // ellipsises instead of overflowing the column.
                        Expanded(
                          child: Text(
                            FormatHelper.capitalize(rules[i]
                                .member
                                .localizedName(isArabic: isArabic)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _cell(departmentLabel(rules[i].member), departmentWidth.w),
                  _cell(
                    rules[i].member.localizedJobTitle(isArabic: isArabic),
                    jobWidth.w,
                  ),
                  SizedBox(
                    width: dateWidth.w,
                    child: _rowStartField(context, rules[i]),
                  ),
                  SizedBox(
                    width: dateWidth.w,
                    child: _rowEndField(context, rules[i]),
                  ),
                  SizedBox(
                    width: permissionWidth.w,
                    child: _rowPermissionField(context, rules[i]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── The table's three rule controls ──────────────────────────────────────
  //
  // The card's `_startField` / `_endField` / `_permissionField` are NOT reused
  // here, and the difference is not styling: each of those is a LABELLED block
  // — a `Text` above the control — and in a table the label is the column
  // heading. Reusing them would print "Access Begins" five times down a column
  // already headed "Access Begins".
  //
  // Everything else is deliberately identical: the same widgets, the same
  // "live" rule, the same "null means cleared, so do not travel" guard on both
  // pickers, and the same `firstDate` on the end one.

  /// Every control in a row is pinned to this, so a row cannot change height as
  /// a value lands and shove the rows below it down.
  ///
  /// Raw, NOT `.h` — both `CustomDropdownCalendar.height` and
  /// `CustomDropdown.height` are documented as "interpreted in .h" and scale it
  /// themselves. A pre-scaled value would be scaled twice. 36 is
  /// `CreateDatabaseMetrics.figmaFieldHeight`, the module's standard field
  /// height, so these boxes match every other field in the section.
  static const double _rowFieldHeight = 36;

  /// Whether this person's rule can be edited: they have to be ticked, and the
  /// list as a whole has to be enabled. Same rule the cards use.
  bool _live(MemberAccessRule rule) => enabled && rule.isSelected;

  Widget _rowStartField(BuildContext context, MemberAccessRule rule) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    return CustomDropdownCalendar(
      hint: strings.date,
      value: rule.grant?.startDate,
      fillColor: AppColors.card,
      borderRadius: BorderRadius.circular(6.r),
      height: _rowFieldHeight,
      enabled: _live(rule),
      dateFormatter: (DateTime date) =>
          DatabaseDateFormat.short(date, isArabic: isArabic),
      valueStyle: StyleText.fontSize11Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize11Weight400
          .copyWith(color: AppColors.secondaryText),
      onChanged: (DateTime? date) {
        if (date != null) onStartDateChanged(rule.member, date);
      },
    );
  }

  Widget _rowEndField(BuildContext context, MemberAccessRule rule) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    return CustomDropdownCalendar(
      hint: strings.date,
      value: rule.grant?.endDate,
      fillColor: AppColors.card,
      borderRadius: BorderRadius.circular(6.r),
      height: _rowFieldHeight,
      enabled: _live(rule),
      // An end before the start is the one date mistake worth blocking at the
      // picker rather than reporting afterwards.
      firstDate: rule.grant?.startDate,
      dateFormatter: (DateTime date) =>
          DatabaseDateFormat.short(date, isArabic: isArabic),
      valueStyle: StyleText.fontSize11Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize11Weight400
          .copyWith(color: AppColors.secondaryText),
      onChanged: (DateTime? date) {
        if (date != null) onEndDateChanged(rule.member, date);
      },
    );
  }

  Widget _rowPermissionField(BuildContext context, MemberAccessRule rule) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    return CustomDropdown<DatabasePermissionLevel>(
      value: rule.grant?.permission,
      hint: strings.selectPermission,
      fillColor: AppColors.card,
      borderRadius: BorderRadius.circular(6.r),
      // `height` landed on CustomDropdown on 17/8/2026 for exactly this: a
      // dropdown that has to match a fixed row. Padding could not do it —
      // `contentPadding` grows the input AREA between the prefix and suffix
      // slots and cannot bring the trigger down to a target height.
      height: _rowFieldHeight,
      enabled: _live(rule),
      valueStyle: StyleText.fontSize11Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize11Weight400.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize11Weight400
          .copyWith(color: AppColors.secondaryText),
      items: DatabasePermissionLevel.selectable
          .map((DatabasePermissionLevel level) =>
              DropdownItem<DatabasePermissionLevel>(
                value: level,
                label: isArabic ? level.labelAr : level.labelEn,
              ))
          .toList(growable: false),
      onChanged: (DatabasePermissionLevel level) =>
          onPermissionChanged(rule.member, level),
    );
  }

  Widget _head(String label, double width) => SizedBox(
        width: width,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // The heading band is dark in BOTH themes (black light /
          // `blackShadow` dark), so the heading text is white in both rather
          // than following the body text colour.
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.white),
        ),
      );

  Widget _cell(String value, double width) => SizedBox(
        width: width,
        child: Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
        ),
      );

  // ── Shared pieces ────────────────────────────────────────────────────────

  /// The tick, wrapped in its own hit area.
  ///
  /// `CustomCheckBox` draws its square and nothing else — it takes no
  /// callback — so the padding here is what turns it into a target big enough
  /// to hit without aiming, on a row that also contains three other controls.
  /// The square itself is pinned to the Figma's 20pt (`Group 1597882873`).
  Widget _tick(bool selected, VoidCallback onTap) => GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(6.sp),
          child: CustomCheckBox(
            isSelected: selected,
            size: metrics.personCheckSize,
          ),
        ),
      );

  /// `foregroundImage` plus an SVG child, NOT `backgroundImage`: the app's
  /// default avatar is an SVG, which `AssetImage` cannot decode. A foreground
  /// image draws OVER the child, so the placeholder shows while the photo
  /// loads and stays visible if the URL 404s.
  Widget _avatar(DatabaseMember member, double radius) {
    final String? photo = member.photoUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.moreLightGrey,
      foregroundImage:
          (photo == null || photo.isEmpty) ? null : appImageProvider(photo),
      child: ClipOval(
        child: CustomSvgImage(
          assetPath: AppAssets.defaultEmployeeAvatar,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _labelled(String label, String value) => Text.rich(
        TextSpan(
          text: '$label ',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
          children: <InlineSpan>[
            TextSpan(
              text: value.isEmpty ? '—' : value,
              style:
                  StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  /// The page colour — `CustomDropdown`'s own default fill — so these controls
  /// sit on the same tone as the search box above them instead of on a
  /// near-black of their own.
  Color get _fill => AppColors.card;

  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);
}
