/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_review_page.dart
/// Purpose: Declares `TableAccessReviewPage`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// Step 2 of "Editing Table Access" — the rule, the fields, and the last look
/// at who it applies to.
///
///   iPad VERTICAL     768 x 1086  (7398:14553)
///   iPad HORIZONTAL  1024 x  923  (7398:14122, and 7398:14296 with the
///                                  Viewable Fields menu open)
///
/// Four summary tiles, a Permissions + dates block, the Viewable Fields
/// control, "Remove All Access", and the people grid with red minus badges.
/// Save and Discard Changes at the bottom.
///
/// PER-MEMBER FIELDS ARE NOT DRAWN
/// -------------------------------
/// 7398:14122 puts a Viewable Fields dropdown on EACH person's row, so two
/// people on the same table can see different columns. That is expressible in
/// the model already — a grant holds a member list, so one grant per person
/// says it — but the subcollection this screen writes holds ONE rule, and
/// splitting it per person changes what "Remove All Access" and the summary
/// tiles mean. So the control is grant-wide here and the tile reports the one
/// answer; per-person overrides are a follow-up that needs no migration, only a
/// second grant per member.
///
/// "Grant Access" IS THE FLOW'S ONLY WRITE, same as db1's review.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/access_rule_fields.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/member_viewable_fields_list.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/viewable_fields_field.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_access_cubit.dart';

import '../../../../db1_create_database/presentation/controller/create_database_cubit.dart';

class TableAccessReviewPage extends StatefulWidget {
  const TableAccessReviewPage({
    super.key,
    required this.cubit,
    required this.database,
    required this.onCompleted,
    required this.onExit,
    this.editedBy,
    this.editedByNameEn,
    this.editedByNameAr,
  });

  final TableAccessCubit cubit;
  final DatabaseEntity database;

  /// Called once the write succeeds, carrying the table with its refreshed
  /// member count. The flow host closes and returns it — this page must NOT
  /// unwind the stack itself, because it does not know how many Navigators it
  /// is nested inside.
  final ValueChanged<DatabaseTableEntity> onCompleted;

  /// Leaves the flow entirely. See `TableAccessPage.onExit`.
  final VoidCallback onExit;

  final String? editedBy;
  final String? editedByNameEn;
  final String? editedByNameAr;

  @override
  State<TableAccessReviewPage> createState() => _TableAccessReviewPageState();
}

class _TableAccessReviewPageState extends State<TableAccessReviewPage> {
  final TextEditingController _search = TextEditingController();

  /// Which of the two views of 7398:14122 / 14296 is showing. Local `setState`
  /// rather than cubit state: it is how this screen is being LOOKED at, not
  /// part of the rule being edited, and putting it in the cubit would make
  /// Discard Changes offer to undo it.
  bool _tableView = false;

  /// `DropdownItem.value` is non-nullable, so "All departments" needs a real
  /// value to carry. An empty string cannot collide with a Firestore id.
  static const String _allDepartments = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── Intents ──────────────────────────────────────────────────────────────

  Future<void> _onSavePressed(TableAccessState state) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    // The guard lives here rather than in the cubit because it needs the
    // localized sentence that names what is missing.
    if (!state.canSave) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: state.grant.hasInvalidDateRange
            ? strings.endBeforeStart
            : strings.incompleteGrant,
        closeLabel: strings.close,
      );
      return;
    }

    // NOTHING TO SAVE (17/8/2026). Runs AFTER the completeness check because
    // that one is the more specific complaint: an untouched rule that is also
    // missing a date is better answered by naming the date than by saying
    // nothing changed.
    //
    // Writing an unchanged rule is not harmless — `replaceTableGrants` rewrites
    // the whole subcollection and stamps `updated_at` on the table AND on the
    // database, so a mis-tap would put a fresh "Last Edit" on records nobody
    // edited.
    //
    // The button beside this is already greyed for the same reason; this is
    // what it says when tapped, because `CreateDatabaseActions` deliberately
    // still fires a disabled-but-not-submitting primary.
    if (!state.isDirty) {
      await showWarningDialog(
        context: context,
        title: strings.nothingChangedTitle,
        subtitle: strings.nothingChanged,
        closeLabel: strings.close,
      );
      return;
    }

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.confirmAccessTitle,
      subtitle: strings.confirmAccessSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    await widget.cubit.save(
      grantedBy: widget.editedBy,
      grantedByNameEn: widget.editedByNameEn,
      grantedByNameAr: widget.editedByNameAr,
    );
  }

  /// "Remove All Access" — the one destructive control on the screen, so it
  /// confirms and names how many people it is about to drop.
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

  Future<void> _onDiscardPressed(TableAccessState state) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    // An untouched screen does not need a confirmation — the dialog would just
    // be friction on a mis-tap.
    if (!state.isDirty) {
      widget.onExit();
      return;
    }

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.discardConfirmTitle,
      subtitle: strings.discardAccessSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    // Restores the rule as loaded and STAYS. There is a saved record behind
    // this screen to keep working on, unlike the create wizard where discarding
    // leaves because there is nothing to go back to.
    widget.cubit.discard();
  }

  Future<void> _onStateChanged(
    BuildContext context,
    TableAccessState state,
  ) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    if (state.status == TableAccessStatus.failure &&
        state.errorMessage != null) {
      // Read and cleared BEFORE the await: leaving the failure state live while
      // the dialog is open would re-open it on the next emission.
      final String message = state.errorMessage!;
      widget.cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    if (state.status == TableAccessStatus.success) {
      await showSuccessDialog(
        context: context,
        title: strings.successTitle,
        subtitle: strings.accessSavedSubtitle,
        closeLabel: strings.close,
      );
      if (!mounted) return;
      widget.onCompleted(state.table);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final bool isArabic = context.isArabic;

    return BlocConsumer<TableAccessCubit, TableAccessState>(
      bloc: widget.cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, TableAccessState state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: FormatHelper.capitalize(
                widget.database.localizedTitle(isArabic: isArabic)),
            secondTitle: FormatHelper.capitalize(
                state.table.localizedName(isArabic: isArabic)),
            thirdTitle: strings.editingTableAccess,
            onFirstTap: widget.onExit,
            // The table's own crumb is one step back — to the picker, which is
            // this flow's first route. `maybePop` on the INNER navigator is the
            // right call there; the crumb above it leaves the flow entirely.
            onSecondTap: () => Navigator.of(context).maybePop(),
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
                    Text(
                      strings.summary,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: SummaryTileRow(
                          tiles: _tiles(state, strings, isArabic),
                        ),
                      ),
                    ),
                    SizedBox(height: metrics.blockGap),

                    Container(
                      width: double.infinity,
                      padding: metrics.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(metrics.cardRadius),
                        boxShadow: CardStyles.shadow,
                      ),
                      child: _body(state, strings, metrics, isArabic),
                    ),
                    SizedBox(height: metrics.cardToActions),

                    CreateDatabaseActions(
                      metrics: metrics,
                      discardLabel: strings.discardChanges,
                      primaryLabel: strings.save,
                      onDiscard: () => _onDiscardPressed(state),
                      onPrimary: () => _onSavePressed(state),
                      isSubmitting: state.isSubmitting,
                      // Grey until the rule differs from the one that was
                      // loaded — see `_onSavePressed` for why an unchanged
                      // save is not a harmless one.
                      isPrimaryEnabled: state.isDirty,
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

  /// The four tiles of Figma 7398:14697-14708.
  ///
  /// "Viewable Fields / Custom" is not reachable from this screen — one grant
  /// cannot disagree with itself — so it reports the real answer instead:
  /// "All fields" when nothing is restricted, otherwise how many.
  List<SummaryTile> _tiles(
    TableAccessState state,
    CreateTableStrings strings,
    bool isArabic,
  ) {
    return <SummaryTile>[
      SummaryTile(
        label: strings.totalEmployees,
        value: '${state.selectedMembers.length}',
      ),
      SummaryTile(
        label: strings.totalDepartments,
        value: '${state.totalDepartments}',
      ),
      SummaryTile(
        label: strings.permissions,
        value: state.grant.permission == null
            ? '—'
            : (isArabic
                ? state.grant.permission!.labelAr
                : state.grant.permission!.labelEn),
      ),
      SummaryTile(
        label: strings.viewableFields,
        value: state.grant.viewableFields.isEmpty
            ? strings.allFields
            : strings.fieldsSelected(state.grant.viewableFields.length),
      ),
    ];
  }

  Widget _body(
    TableAccessState state,
    CreateTableStrings strings,
    CreateDatabaseMetrics metrics,
    bool isArabic,
  ) {
    final CreateTableMetrics tableMetrics = CreateTableMetrics.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ── Remove All Access (Figma 7398:14280) ─────────────────────────
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: state.isSubmitting || state.selectedMembers.isEmpty
                ? null
                : () => _onRemoveAllPressed(state),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 32.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              strings.removeAllAccess,
              style: StyleText.fontSize12Weight500.copyWith(
                color: state.selectedMembers.isEmpty
                    ? AppColors.disabledGrey
                    : AppColors.delete,
              ),
            ),
          ),
        ),
        SizedBox(height: metrics.blockGap),

        // ── The rule: Permissions + the two dates ────────────────────────
        //
        // ONLY WHEN THERE IS NOTHING TO INHERIT (17/8/2026). Figma 7398:14122
        // and 7398:14296 draw neither control: the permission and the dates
        // were settled when the access was created, and this screen edits who
        // sees which COLUMNS. Rendering them again would invite an edit the
        // design never asked for.
        //
        // They still appear on a table nobody has ever granted access to,
        // because `DatabaseAccessGrant.isComplete` needs all three and without
        // them Save could never enable — a blank screen with a dead button is
        // worse than one control more than the frame.
        if (!state.hasInheritedRule) ...<Widget>[
          AccessRuleFields(
            grant: state.grant,
            enabled: !state.isSubmitting,
            onPermissionChanged: widget.cubit.permissionChanged,
            onStartDateChanged: widget.cubit.startDateChanged,
            onEndDateChanged: widget.cubit.endDateChanged,
          ),
          SizedBox(height: metrics.blockGap),
        ],

        // ── Who it applies to, and what each of them sees ────────────────
        Text(
          strings.employeeInformation,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.h),
        // STACKS BELOW 600 (17/8/2026). 150 is the Figma's fixed filter width
        // on both iPad frames and it does not grow with the card — but at 315
        // it leaves the search box 155pt, and this screen's search is how you
        // find one person among the selected. Figma 7398:17843 draws the phone
        // version as a full-width search with "Department: IT" on its own line
        // underneath, which is this.
        //
        // AppSearchTextField's root IS an Expanded, so it has to sit in a Row
        // in both branches — a Column would throw "Incorrect use of
        // ParentDataWidget".
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
          _departmentFilter(state, strings, isArabic),
        ] else
          Row(
            children: <Widget>[
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: AppColors.background,
                onChanged: widget.cubit.searchChanged,
              ),
              SizedBox(width: 10.sp),
              SizedBox(
                width: 150.sp,
                child: _departmentFilter(state, strings, isArabic),
              ),
            ],
          ),
        SizedBox(height: 10.sp),

        // The list / grid toggle of 7398:14122 (grid lit) and 7398:14296
        // (list lit). The shared pair, so this toggle is the same 38sp square
        // as every other one in the app.
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            customTableButton(
              function: () => setState(() => _tableView = true),
              isSelected: _tableView,
            ),
            SizedBox(width: 8.sp),
            customGridButton(
              function: () => setState(() => _tableView = false),
              isSelected: !_tableView,
            ),
          ],
        ),
        SizedBox(height: 12.h),

        MemberViewableFieldsList(
          rows: <MemberFieldsRow>[
            for (final DatabaseMember member in _visibleSelected(state))
              MemberFieldsRow(
                member: member,
                fields: state.fieldsFor(member),
                nameLabel: member.localizedName(isArabic: isArabic),
                departmentLabel: state.departmentNameFor(
                  member.departmentId,
                  isArabic: isArabic,
                ),
                jobTitleLabel: member.localizedJobTitle(isArabic: isArabic),
              ),
          ],
          options: state.fieldOptions,
          isTableView: _tableView,
          enabled: !state.isSubmitting,
          onFieldsChanged: (DatabaseMember member, List<String> fields) =>
              widget.cubit.memberFieldsChanged(member.employeeId, fields),
          onRemove: widget.cubit.removeMember,
        ),
      ],
    );
  }

  /// The Department dropdown beside the search box (Figma 7398:14122).
  ///
  /// It narrows WHICH of the picked people are listed — it does not change who
  /// has access. Same control and same reading as step 1's, one screen back.
  Widget _departmentFilter(
    TableAccessState state,
    CreateTableStrings strings,
    bool isArabic,
  ) {
    return CustomDropdown<String>(
      height: 38,
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

  /// The picked people, narrowed by the search box.
  ///
  /// `state.visibleEmployees` is the wrong list here — that one searches the
  /// whole DIRECTORY, which on this screen would offer up people who were never
  /// granted anything and hand them a red remove badge.
  List<DatabaseMember> _visibleSelected(TableAccessState state) {
    final String needle = state.searchQuery.trim().toLowerCase();
    final String? department = state.departmentFilter;

    if (needle.isEmpty && department == null) return state.selectedMembers;

    return state.selectedMembers.where((DatabaseMember m) {
      if (department != null && m.departmentId != department) return false;
      if (needle.isEmpty) return true;
      return m.nameEn.toLowerCase().contains(needle) ||
          m.nameAr.toLowerCase().contains(needle);
    }).toList(growable: false);
  }
}
