/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_page.dart
/// Purpose: Declares `TableAccessPage`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Step 1 of "Editing Table Access" — who gets to see this table.
///
///   iPad HORIZONTAL  1024 x 1097  (7398:13651)
///   iPad VERTICAL     768 x 1097  (7398:13925)
///
/// The card, top to bottom, exactly as 7398:13651 draws it:
///
///   Remove All Access   label + switch
///   Department          dropdown, then a chip per department with the
///                       filtered one highlighted
///   Viewable Fields     dropdown + a chip per picked column
///   Employee Information  search + Select All / Deselect All
///                       a three-across grid of people cards with check marks
///
/// and Discard Changes / Review under it.
///
/// The first three blocks were missing until 17/8/2026 — the screen opened
/// straight onto the employee grid, which made the table's Viewable Fields
/// unreachable before step 2 and left the Department dropdown squeezed in
/// beside the search box instead of labelled above it.
///
/// THE BREADCRUMB IS THE FIGMA'S FOUR (corrected 17/8/2026)
/// --------------------------------------------------------
/// "Database Name > Table Name > Access > Editing Table Access" (7398:13682).
///
/// This file used to carry a note claiming the third crumb led nowhere,
/// because "a table-level access LIST screen … does not exist". It does —
/// 7398:11000, sitting in the Figma under the misleading layer name "Sign Up":
/// All / Active / Removed chips over a six-column table of everyone who
/// reaches the table, with Edit Access on it. `DatabaseAccessPage` renders it
/// for a table as well as for a database, and it is what the Access button on
/// Table Name Details now opens. This screen is one step further in, so the
/// crumb above it is real and navigates.
///
/// MOST OF THIS IS SHARED WITH db1
/// -------------------------------
/// `MemberGrid` and `AccessRuleFields` live in db1 and every screen that picks
/// people uses them, which is why a person card looks identical whether it was
/// reached from the create wizard or from a table.
///
/// `ViewableFieldsField` is the exception: it moved into db3 on 16/8/2026 when
/// db1's copy was removed. Its options are a TABLE's columns, and the create
/// wizard has no tables — the control there could only ever render disabled.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_metrics.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/member_grid.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_access_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/viewable_fields_field.dart';

class TableAccessPage extends StatefulWidget {
  const TableAccessPage({
    super.key,
    required this.cubit,
    required this.database,
    required this.onReview,
    required this.onExit,
  });

  /// Provided by [TableAccessFlow]; never created here, so this screen cannot
  /// be used outside the flow that owns its state.
  final TableAccessCubit cubit;

  final DatabaseEntity database;

  /// Advance to step 2.
  final VoidCallback onReview;

  /// Leaves the flow entirely.
  ///
  /// `Navigator.of(context)` here resolves to the flow's INNER navigator, which
  /// can only move between steps — and on the FIRST route `maybePop` declines
  /// (bubble) while `pop` empties the navigator and renders nothing. Leaving is
  /// the host's job, hence a callback. Same note as db1's `CreateDatabasePage`.
  final VoidCallback onExit;

  @override
  State<TableAccessPage> createState() => _TableAccessPageState();
}

class _TableAccessPageState extends State<TableAccessPage> {
  final TextEditingController _search = TextEditingController();

  /// `DropdownItem.value` is non-nullable, so "All departments" needs a real
  /// value to carry. An empty string cannot collide with a Firestore id.
  static const String _allDepartments = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// "Remove All Access" (Figma 7398:13651, the switch at the top of the card).
  ///
  /// A SWITCH that confirms and then springs back, not a stateful toggle: it
  /// performs an action rather than holding a setting, and leaving it "on"
  /// afterwards would claim a state the screen does not have — the very next
  /// person ticked would contradict it.
  Future<void> _onRemoveAllPressed(TableAccessState state) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    if (state.selectedMembers.isEmpty) return;

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.removeAllAccess,
      subtitle: strings.removeAllAccessSubtitle(state.selectedMembers.length),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    widget.cubit.removeAllAccess();
  }

  /// Discard on step 1 leaves the flow. Nothing has been written yet, so this
  /// only has to ask when something WOULD be lost.
  Future<void> _onDiscardPressed(TableAccessState state) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    if (state.selectedMembers.isEmpty) {
      widget.onExit();
      return;
    }

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.discardChanges,
      subtitle: strings.discardAccessSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    widget.onExit();
  }

  Future<void> _onReviewPressed(TableAccessState state) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    // Reviewing an empty selection would open a screen with a permission level,
    // two dates and nobody to give them to. Said as a prompt, not an error —
    // the form is incomplete, nothing broke.
    if (state.selectedMembers.isEmpty) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: strings.pickSomeoneFirst,
        closeLabel: strings.close,
      );
      return;
    }
    widget.onReview();
  }

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final bool isArabic = context.isArabic;

    return BlocBuilder<TableAccessCubit, TableAccessState>(
      bloc: widget.cubit,
      builder: (BuildContext context, TableAccessState state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: FormatHelper.capitalize(
                widget.database.localizedTitle(isArabic: isArabic)),
            secondTitle: FormatHelper.capitalize(
                state.table.localizedName(isArabic: isArabic)),
            thirdTitle: strings.accessCrumb,
            fourthTitle: strings.editingTableAccess,
            // Every upper crumb leaves the flow: the database, the table and
            // its access list all live behind the screen this was opened from,
            // and none is a route inside the flow's own navigator.
            onFirstTap: widget.onExit,
            onSecondTap: widget.onExit,
            onThirdTap: widget.onExit,
            child: CreateDatabaseMetrics.pageScroll(
              context,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.extraHorizontalInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: metrics.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(metrics.cardRadius),
                        boxShadow: CardStyles.shadow,
                      ),
                      child: state.isLoading
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 60.h),
                              child: const CircleProgressMaster(),
                            )
                          : _body(state, strings, isArabic),
                    ),
                    SizedBox(height: metrics.cardToActions),

                    // Discard Changes on the leading edge, Review on the
                    // trailing one — 7398:13651 draws both. An earlier reading
                    // of 7398:13882 had Review alone here on the grounds that
                    // nothing is written yet; the frame the flow actually
                    // matches has the pair, and "nothing written" is why
                    // Discard can leave without asking rather than why it
                    // should be absent.
                    Row(
                      children: <Widget>[
                        customButton(
                          title: strings.discardChanges,
                          function: () => _onDiscardPressed(state),
                          exactWidth: metrics.actionButtonWidth,
                          color: AppColors.darkGrey,
                          textColor: AppColors.text,
                        ),
                        const Spacer(),
                        customButton(
                          title: strings.review,
                          function: () => _onReviewPressed(state),
                          exactWidth: metrics.actionButtonWidth,
                          color: AppColors.primary,
                          textColor: AppColors.textButton,
                        ),
                      ],
                    ),
                    SizedBox(height: metrics.blockGap),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(
    TableAccessState state,
    CreateTableStrings strings,
    bool isArabic,
  ) {
    final TextStyle label =
        StyleText.fontSize14Weight500.copyWith(color: AppColors.text);
    final CreateTableMetrics tableMetrics = CreateTableMetrics.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ── Remove All Access (Figma 7398:13651) ─────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(strings.removeAllAccess, style: label),
            SizedBox(width: 12.sp),
            Switch(
              // Always OFF. See `_onRemoveAllPressed` — this performs an
              // action, it does not hold a setting.
              value: false,
              onChanged: state.selectedMembers.isEmpty
                  ? null
                  : (_) => _onRemoveAllPressed(state),
              activeColor: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 12.sp),

        // ── Department: the dropdown, then a chip each ───────────────────
        // The dropdown and the chips drive the SAME filter. Both are in the
        // Figma and neither is redundant: the dropdown is how you find a
        // department in a company with forty of them, the chips are how you
        // switch between the handful you are actually working through.
        Text(strings.department, style: label),
        SizedBox(height: 6.sp),
        // 250 is the Figma's width on an iPad, where the card is 865 or 655
        // wide and a 250pt dropdown reads as a control rather than as a field
        // that ran out of card. Below 600 the card is 315 and that same 250
        // leaves a 65pt stub of dead space on the trailing edge, so the
        // dropdown takes the line — which is what Figma 7398:12691 draws.
        tableMetrics.toolbarStacks
            ? _departmentFilter(state, strings, isArabic)
            : SizedBox(
                width: 250.sp,
                child: _departmentFilter(state, strings, isArabic),
              ),
        if (state.departments.isNotEmpty) ...<Widget>[
          SizedBox(height: 10.sp),
          _DepartmentChips(
            departments: state.departments,
            selectedId: state.departmentFilter,
            isArabic: isArabic,
            onSelected: widget.cubit.departmentFilterChanged,
          ),
        ],
        SizedBox(height: 16.sp),

        // ── Viewable Fields ──────────────────────────────────────────────
        // The options are THIS table's columns, which is what makes the
        // control live here and be absent from db1's create wizard — a
        // database being created has no tables and therefore no columns.
        ViewableFieldsField(
          options: state.fieldOptions,
          selected: state.grant.viewableFields,
          noOptionsLabel: strings.tableHasNoNamedColumns,
          onChanged: widget.cubit.viewableFieldsChanged,
        ),
        SizedBox(height: 16.sp),

        // ── Who gets it ──────────────────────────────────────────────────
        Text(strings.employeeInformation, style: label),
        SizedBox(height: 6.h),

        // SEARCH AND "SELECT ALL" STACK BELOW 600 (17/8/2026). Side by side in
        // a 315pt card they split roughly 155/150, and a 155pt search box shows
        // about eight characters of a name — which is the one thing this row is
        // for. Stacked, the search keeps the full width and the button keeps
        // its label; "Deselect All" at 150 in Arabic ellipsised to "إلغاء…".
        //
        // AppSearchTextField's root IS an Expanded, so it goes straight into a
        // Row — wrapping it in another one throws "Competing ParentDataWidgets"
        // — and it CANNOT go into a Column for the same reason. The stacked
        // branch therefore keeps it in a single-child Row rather than dropping
        // it in beside the button.
        if (tableMetrics.toolbarStacks) ...<Widget>[
          Row(
            children: <Widget>[
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: AppColors.background,
                onChanged: widget.cubit.searchChanged,
              ),
            ],
          ),
          SizedBox(height: tableMetrics.toolbarStackGap),
          customButton(
            title: state.allVisibleSelected
                ? strings.deselectAll
                : strings.selectAll,
            function: widget.cubit.toggleSelectAllVisible,
            // `fullWidth`, not an `exactWidth` measured off the phone frame:
            // stacked it has the whole card to itself, and Figma 7398:1670
            // gives the equivalent button on the phone the card's full 345.
            fullWidth: true,
            color: AppColors.primary,
            textColor: AppColors.textButton,
          ),
        ] else
          Row(
            children: <Widget>[
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: AppColors.background,
                onChanged: widget.cubit.searchChanged,
              ),
              SizedBox(width: 10.w),
              customButton(
                // The label follows the state of what is on screen, so the
                // button always says what pressing it will do.
                title: state.allVisibleSelected
                    ? strings.deselectAll
                    : strings.selectAll,
                function: widget.cubit.toggleSelectAllVisible,
                exactWidth: 150.w,
                color: AppColors.primary,
                textColor: AppColors.textButton,
              ),
            ],
          ),
        SizedBox(height: 12.h),

        MemberGrid(
          members: state.visibleEmployees,
          trailing: MemberGridTrailing.check,
          isSelected: state.isSelected,
          onTap: widget.cubit.toggleMember,
          // Department NAME, not the raw Firestore id the snapshot carries.
          departmentLabel: (DatabaseMember member) => state.departmentNameFor(
            member.departmentId,
            isArabic: isArabic,
          ),
        ),
      ],
    );
  }

  Widget _departmentFilter(
    TableAccessState state,
    CreateTableStrings strings,
    bool isArabic,
  ) {
    return CustomDropdown<String>(
      value: state.departmentFilter ?? _allDepartments,
      hint: strings.department,
      fillColor: AppColors.background,
      valueStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      items: <DropdownItem<String>>[
        DropdownItem<String>(
          value: _allDepartments,
          label: strings.allDepartments,
        ),
        for (final DatabaseDepartment d in state.departments)
          DropdownItem<String>(
            value: d.id,
            label: FormatHelper.capitalize(isArabic ? d.nameAr : d.nameEn),
          ),
      ],
      onChanged: (String value) => widget.cubit.departmentFilterChanged(
        value == _allDepartments ? null : value,
      ),
    );
  }
}

/// The department chips under the Department dropdown (Figma 7398:13651 —
/// "Marketing / Design / Finance / IT / HR / Accounting", the filtered one
/// yellow).
///
/// A private widget rather than db2's `_DepartmentChips`: that one is private
/// to `edit_database_access_page.dart` and lives on a screen with a different
/// selection model — there it picks which department a grant COVERS, here it
/// only narrows what the grid below is showing. Two things that look alike and
/// mean different things are better kept apart than merged and re-explained.
class _DepartmentChips extends StatelessWidget {
  const _DepartmentChips({
    required this.departments,
    required this.selectedId,
    required this.isArabic,
    required this.onSelected,
  });

  final List<DatabaseDepartment> departments;

  /// Null means no filter — no chip is highlighted.
  final String? selectedId;

  final bool isArabic;

  /// Null clears the filter, which is what tapping the highlighted chip does.
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.sp,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.sp),
        itemBuilder: (BuildContext context, int index) {
          final DatabaseDepartment department = departments[index];
          final bool selected = department.id == selectedId;

          return GestureDetector(
            // Tapping the one that is already on clears it, so the chips can
            // undo themselves without the user hunting for "All Departments"
            // in the dropdown above.
            onTap: () => onSelected(selected ? null : department.id),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                FormatHelper.capitalize(
                  isArabic ? department.nameAr : department.nameEn,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: selected ? AppColors.textButton : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
