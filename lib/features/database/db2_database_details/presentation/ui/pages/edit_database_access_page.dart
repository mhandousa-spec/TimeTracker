/// Module: database / db2_database_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_access_page.dart
/// Purpose: Declares `EditDatabaseAccessPage`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Database > Database Name > Editing Database Access" — all THREE Figma
/// variants in one file, because the access type is a dropdown at the top of
/// the same card rather than three separate destinations:
///
///   OPEN        7398:9476 (iPad V) / 7398:9790 (iPad H)
///               department multi-select, chips, one permission + window per
///               department, employee grid, "Review".
///   RESTRICTED  7398:10176 cards / 7398:10331 list (iPad V)
///               search + department filter, a list/grid toggle, and each
///               person's OWN window and level. "Grant Access".
///   PERSONAL    7398:10612
///               the dropdown and nothing else. "Save".
///
/// WHY ONE PAGE AND NOT THREE
/// --------------------------
/// The dropdown that chooses between them is ON this screen. Three routes
/// would mean changing it had to pop one and push another, which loses the
/// screen's own scroll position and makes "I picked the wrong one, change it
/// back" a two-step manoeuvre through a navigator. Stacked side by side, the
/// three frames are the same card with a different middle.
///
/// Both iPad orientations share the file. The grid inside reflows through
/// `MemberGrid`, which drops from three columns to two below 900px — which is
/// exactly what the 768 frame draws.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/access_rule_fields.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/member_grid.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/controller/edit_database_access_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_details_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/member_access_rule_list.dart';

class EditDatabaseAccessPage extends StatefulWidget {
  const EditDatabaseAccessPage({
    super.key,
    required this.cubit,
    required this.onReview,
    required this.onCompleted,
    required this.onExit,
  });

  /// Provided by the flow host, not created here — the draft has to survive
  /// the review screen being pushed and popped.
  final EditDatabaseAccessCubit cubit;

  /// "Review" — pushes the per-department review screen (Open only).
  final VoidCallback onReview;

  /// A finished save. Carries the refreshed record back to the Access screen.
  final ValueChanged<DatabaseEntity> onCompleted;

  /// Leaves the editor without saving.
  ///
  /// Wired by the flow host: `Navigator.of(context)` here resolves to the
  /// flow's INNER navigator, which can only move between steps. Leaving means
  /// popping the route the Access screen pushed, one level up.
  final VoidCallback onExit;

  @override
  State<EditDatabaseAccessPage> createState() => _EditDatabaseAccessPageState();
}

class _EditDatabaseAccessPageState extends State<EditDatabaseAccessPage> {
  final TextEditingController _search = TextEditingController();

  /// The list/grid toggle on the Restricted variant (Figma 7398:10176 shows
  /// grid selected, 7398:10331 list).
  ///
  /// Widget state, not cubit state: it changes nothing that is saved and
  /// nothing another screen can see, so putting it in the draft would make
  /// every rebuild of the editor carry a view preference into a write.
  bool _tableView = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── Access type ──────────────────────────────────────────────────────────

  /// Changing the dropdown clears the current picks — see
  /// `EditDatabaseAccessCubit.accessTypeChanged` for why there is no honest
  /// automatic translation between the three.
  ///
  /// Because that is destructive, it ASKS first whenever there is something to
  /// lose. Nothing picked yet means nothing to warn about, so the switch is
  /// silent then.
  Future<void> _onAccessTypeChanged(DatabaseAccessType value) async {
    final CreateDatabaseState state = widget.cubit.state;
    if (state.accessType == value) return;

    if (state.grants.isEmpty) {
      widget.cubit.accessTypeChanged(value);
      return;
    }

    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    // Switching TO Personal is a different sentence from switching between the
    // other two: it is the only one that ends with nobody having access, so it
    // is worded as a revocation rather than as losing a selection.
    final bool toPersonal = value == DatabaseAccessType.personal;

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: toPersonal
          ? strings.personalDropsGrantsTitle
          : strings.accessTypeChangeTitle,
      subtitle: toPersonal
          ? strings.personalDropsGrants(state.totalEmployees)
          : strings.accessTypeChangeSubtitle(state.totalEmployees),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    widget.cubit.accessTypeChanged(value);
  }

  // ── Primary action ───────────────────────────────────────────────────────

  /// What the primary button does depends on the variant, because the Figma
  /// gives the three different labels for three different next steps: Open
  /// reviews per department, Restricted grants straight away (every rule is
  /// already on screen), Personal just saves.
  Future<void> _onPrimaryPressed() async {
    final CreateDatabaseState state = widget.cubit.state;
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    switch (state.accessType) {
      case DatabaseAccessType.open:
        // Granting access to nobody is a mis-tap, not an intention.
        if (state.allMembers.isEmpty) {
          await showWarningDialog(
            context: context,
            title: strings.incompleteTitle,
            subtitle: strings.pickSomeoneFirst,
            closeLabel: strings.close,
          );
          return;
        }
        widget.onReview();
        return;

      case DatabaseAccessType.restricted:
        if (state.allMembers.isEmpty) {
          await showWarningDialog(
            context: context,
            title: strings.incompleteTitle,
            subtitle: strings.pickSomeoneFirst,
            closeLabel: strings.close,
          );
          return;
        }
        // Every person's window and level is edited on THIS screen, so this is
        // where they are checked — there is no review step to catch it later.
        if (!widget.cubit.individualRulesComplete) {
          await showWarningDialog(
            context: context,
            title: strings.incompleteTitle,
            subtitle: strings.incompleteRows,
            closeLabel: strings.close,
          );
          return;
        }
        await _confirmAndSave();
        return;

      case DatabaseAccessType.personal:
      case null:
        await _confirmAndSave();
        return;
    }
  }

  Future<void> _confirmAndSave() async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    await showConfirmDialog(
      context: context,
      title: strings.editConfirmTitle,
      subtitle: strings.editConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => widget.cubit.saveAccess(),
    );
  }

  /// "Discard Changes" leaves the editor. Unlike the Editing Database card —
  /// where Discard is the form's undo and Save sits next to it — this screen's
  /// footer pairs it with the action that finishes the edit, and the Figma
  /// draws no third control. So it means "abandon", and it asks before
  /// throwing away picks.
  Future<void> _onDiscardPressed() async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.discardConfirmTitle,
      subtitle: strings.discardConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    widget.onExit();
  }

  /// Reports the write once and then clears the flag, so a rebuild cannot
  /// re-open either dialog.
  Future<void> _onStateChanged(
    BuildContext context,
    CreateDatabaseState state,
  ) async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    if (state.status == CreateDatabaseStatus.failure &&
        state.errorMessage != null) {
      // Cleared BEFORE the await: leaving the failure live while the dialog is
      // open re-opens it on the next emission.
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

    if (state.status == CreateDatabaseStatus.success) {
      await showSuccessDialog(
        context: context,
        title: strings.accessSavedTitle,
        subtitle: strings.accessSavedSubtitle,
        closeLabel: strings.close,
      );
      if (!mounted) return;
      final DatabaseEntity? saved = state.createdDatabase;
      if (saved != null) widget.onCompleted(saved);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final DatabaseDetailsMetrics details = DatabaseDetailsMetrics.of(context);
    final String title =
        FormatHelper.capitalize(
            widget.cubit.database.localizedTitle(isArabic: context.isArabic));

    return BlocConsumer<CreateDatabaseCubit, CreateDatabaseState>(
      bloc: widget.cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, CreateDatabaseState state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            // Three crumbs at 1024, two at 768 — see
            // `DatabaseDetailsMetrics.showRootCrumb` for why the design drops
            // the root one at the narrower width. Both spellings exit the
            // editor, so nothing is unreachable at either size.
            titleText: details.showRootCrumb ? strings.database : title,
            secondTitle: details.showRootCrumb
                ? title
                : strings.editingDatabaseAccess,
            thirdTitle:
                details.showRootCrumb ? strings.editingDatabaseAccess : null,
            onFirstTap: widget.onExit,
            onSecondTap: widget.onExit,
            // SideFrameMasterServices hands its child a BOUNDED height on
            // tablet, so a fixed Column overflows the moment the member list
            // is one pixel taller than the viewport. `pageScroll` is the
            // shared fix — and on a phone it hands the child straight through,
            // because that shell is already a scroll view.
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _accessTypeField(state, strings),
                          SizedBox(height: metrics.blockGap),
                          _variant(state, strings, metrics),
                        ],
                      ),
                    ),
                    SizedBox(height: metrics.cardToActions),
                    CreateDatabaseActions(
                      metrics: metrics,
                      discardLabel: strings.discardChanges,
                      primaryLabel: _primaryLabel(state, strings),
                      onDiscard: _onDiscardPressed,
                      onPrimary: _onPrimaryPressed,
                      isSubmitting: state.isSubmitting,
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

  String _primaryLabel(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
  ) {
    switch (state.accessType) {
      case DatabaseAccessType.open:
        return strings.review;
      // "Save", NOT "Grant Access". The Figma's editing frames label this
      // button `Save` (7398:10512 at 768, 7398:10230 at 1024) — "Grant Access"
      // belongs to the create wizard, where the button is granting access that
      // did not exist. Here it is saving a change to access that already does,
      // and every rule is already filled in on this screen, so there is no
      // review step between the two.
      case DatabaseAccessType.restricted:
      case DatabaseAccessType.personal:
      case null:
        return strings.save;
    }
  }

  /// The Access Management dropdown, half width on tablet — the same width as
  /// one column of the create card's title row, so it lines up with everything
  /// else in the module. `buildResponsiveFields` with an empty right slot is
  /// what produces that without a magic number.
  Widget _accessTypeField(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
  ) {
    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(strings.accessManagement, style: _labelStyle),
          SizedBox(height: 6.h),
          CustomDropdown<DatabaseAccessType>(
            value: state.accessType,
            hint: strings.accessManagement,
            fillColor: _fieldFill,
            enabled: !state.isSubmitting,
            borderRadius: BorderRadius.circular(4.r),
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            itemStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            items: DatabaseAccessType.values
                .map((DatabaseAccessType type) =>
                    DropdownItem<DatabaseAccessType>(
                      value: type,
                      label:
                          context.isArabic ? type.labelAr : type.labelEn,
                    ))
                .toList(growable: false),
            onChanged: _onAccessTypeChanged,
          ),
        ],
      ),
      right: const SizedBox.shrink(),
    );
  }

  Widget _variant(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    if (state.isLoadingDirectory) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        // `CircleProgressMaster` centres itself and sizes off the shortest
        // side, so it replaces the Center as well as the indicator.
        child: const CircleProgressMaster(),
      );
    }

    switch (state.accessType) {
      case DatabaseAccessType.open:
        return _openBody(state, strings, metrics);
      case DatabaseAccessType.restricted:
        return _restrictedBody(state, strings, metrics);
      case DatabaseAccessType.personal:
      case null:
        return _personalBody(strings);
    }
  }

  // ── Personal (7398:10612) ────────────────────────────────────────────────

  /// The Figma leaves this card empty below the dropdown. An empty white card
  /// reads as a screen that failed to load, so the empty state says what it
  /// MEANS instead of saying nothing.
  Widget _personalBody(DatabaseDetailsStrings strings) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Text(
        strings.personalAccessExplainer,
        style: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.secondaryText),
      ),
    );
  }

  // ── Open (7398:9476 / 9790) ──────────────────────────────────────────────

  Widget _openBody(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    // The rule shown belongs to the department in focus, so a department with
    // nobody picked yet still has fields to fill.
    final DatabaseAccessGrant grant = (state.selectedDepartmentId == null
            ? state.individualGrant
            : state.grantForDepartment(state.selectedDepartmentId!)) ??
        const DatabaseAccessGrant(members: <DatabaseMember>[]);

    // Every pick on this screen belongs to the department in FOCUS — that
    // scoping is what gives the review screen its per-department tabs. With no
    // department picked there is nowhere for a selection to go: the inherited
    // `toggleMember` would file people into an individual grant, the review
    // screen only renders department-scoped ones, and the user would be told
    // to "select at least one person" with a dozen already ticked. So the
    // grid is held back until there is a department to put them in.
    final bool hasDepartment = state.selectedDepartmentId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.department, style: _labelStyle),
        SizedBox(height: 6.h),
        buildResponsiveFields(
          context: context,
          left: CustomMultiSelectDropdown<String>(
            borderRadius: BorderRadius.circular(8.r),
            values: state.selectedDepartmentIds,
            hint: strings.department,
            // Same rule as the wizard's Department field (16/8/2026): the chip
            // row below is the list of picks, so the trigger keeps its label
            // instead of ellipsising a copy of them.
            alwaysShowHint: true,
            fillColor: _fieldFill,
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            itemStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            items: state.departments
                .map((DatabaseDepartment dept) =>
                    MultiSelectDropdownItem<String>(
                      value: dept.id,
                      label: dept.localizedName(isArabic: context.isArabic),
                    ))
                .toList(growable: false),
            onChanged: widget.cubit.departmentsChanged,
          ),
          right: const SizedBox.shrink(),
        ),
        SizedBox(height: 10.h),

        // Only the PICKED departments become chips — the Figma shows
        // "Marketing / Design / Finance" under a field reading "Marketing",
        // not the whole org chart.
        _DepartmentChips(
          departments: state.selectedDepartments,
          selectedId: state.selectedDepartmentId,
          onSelected: widget.cubit.departmentSelected,
        ),
        SizedBox(height: metrics.blockGap),

        // db1's block, unchanged: Permissions + the two dates, already wired
        // to apply to one department when given a `departmentId`. The editing
        // screen needs exactly the same control, so it uses exactly the same
        // widget rather than a copy that could drift on spacing or on the
        // end-before-start guard.
        AccessRuleFields(
          grant: grant,
          enabled: hasDepartment && !state.isSubmitting,
          onPermissionChanged: (DatabasePermissionLevel level) =>
              widget.cubit.permissionChanged(
            level,
            departmentId: state.selectedDepartmentId,
          ),
          onStartDateChanged: (DateTime date) =>
              widget.cubit.startDateChanged(
            date,
            departmentId: state.selectedDepartmentId,
          ),
          onEndDateChanged: (DateTime date) => widget.cubit.endDateChanged(
            date,
            departmentId: state.selectedDepartmentId,
          ),
        ),
        SizedBox(height: metrics.blockGap),

        if (!hasDepartment)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Text(
              strings.pickDepartmentFirst,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
          )
        else ...<Widget>[
        Text(strings.employeeInformation, style: _labelStyle),
        SizedBox(height: 6.h),
        Row(
          children: <Widget>[
            // AppSearchTextField's root IS an Expanded, so it goes straight
            // into the Row — wrapping it in another one throws "Competing
            // ParentDataWidgets".
            AppSearchTextField(
              controller: _search,
              hintText: strings.search,
              fillColor: _fieldFill,
              onChanged: widget.cubit.memberSearchChanged,
            ),
            SizedBox(width: 10.w),
            _PillButton(
              // The Figma shows "Deselect All", which is the label once
              // everything visible is already in — so the label follows the
              // state rather than being fixed.
              label: _allVisibleSelected(state)
                  ? strings.deselectAll
                  : strings.selectAll,
              onTap: widget.cubit.toggleAllVisible,
            ),
          ],
        ),
        SizedBox(height: metrics.blockGap),

        MemberGrid(
          members: state.visibleEmployees,
          trailing: MemberGridTrailing.check,
          isSelected: state.isMemberSelected,
          onTap: widget.cubit.toggleMember,
          departmentLabel: (DatabaseMember member) => state.departmentNameFor(
            member.departmentId,
            isArabic: context.isArabic,
          ),
        ),
        ],
      ],
    );
  }

  bool _allVisibleSelected(CreateDatabaseState state) {
    final List<DatabaseMember> visible = state.visibleEmployees;
    if (visible.isEmpty) return false;
    return visible.every(state.isMemberSelected);
  }

  // ── Restricted (7398:10176 cards / 7398:10331 list) ──────────────────────

  Widget _restrictedBody(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    final List<DatabaseMember> visible = widget.cubit.filteredEmployees;

    // The section's own measured numbers — field widths, avatar sizes, the
    // person card's geometry. `metrics` above still owns everything the create
    // wizard already measured (card padding, radius, the page inset), which is
    // why both are in scope rather than one wrapping the other.
    final DatabaseDetailsMetrics details = DatabaseDetailsMetrics.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.employeeInformation, style: _labelStyle),
        SizedBox(height: 6.h),

        // Search takes the remainder, department filter is a FIXED 150.
        //
        // Measured, not guessed: the filter is 150 wide in the 655 card
        // (7398:10500) and 150 in the 865 one (7398:10220) — it does not grow
        // with the card, so a flex weight would make it 150 at one width and
        // something else at the other. The 15pt gap is the same in both.
        //
        // Below 600px the row stacks: 150 out of a 345-wide card leaves the
        // search box unusable.
        if (details.isPhone) ...<Widget>[
          Row(
            children: <Widget>[
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fieldFill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _departmentFilter(state, strings),
        ] else
          Row(
            children: <Widget>[
              // AppSearchTextField's root IS an Expanded, so it goes straight
              // into the Row — wrapping it in another one throws "Competing
              // ParentDataWidgets".
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fieldFill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
              SizedBox(width: details.toolbarGap),
              SizedBox(
                width: details.departmentFilterWidth,
                child: _departmentFilter(state, strings),
              ),
              SizedBox(width: 12.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  customTableButton(
                    function: () => setState(() => _tableView = true),
                    isSelected: _tableView,
                  ),
                  SizedBox(width: details.viewToggleGap),
                  customGridButton(
                    function: () => setState(() => _tableView = false),
                    isSelected: !_tableView,
                  ),
                ],
              ),
            ],
          ),

        // The list / grid toggle, right-aligned to the card's inner edge
        // (Figma 7398:19230 / 19234 at 768, 7398:10325 / 10329 at 1024 — the
        // 768 CARDS frame simply omits it, the 768 LIST frame has it).
        // `customTableButton` and `customGridButton` are the shared pair, so
        // this toggle is the same 38sp square as every other one in the app.

        SizedBox(height: details.toggleToAvatars),

        // The strip of picked faces with a red remove badge (Figma 7398:10176).
        // Not `StackedAvatars` — that widget overlaps to save space and has no
        // per-avatar affordance; here each face is its own hit target.
        _PickedAvatarRow(
          metrics: details,
          members: state.allMembers.toList(growable: false),
          onRemove: widget.cubit.toggleIndividualMember,
        ),
        SizedBox(height: metrics.blockGap),

        MemberAccessRuleList(
          metrics: details,
          isTableView: _tableView,
          enabled: !state.isSubmitting,
          rules: visible
              .map((DatabaseMember m) => MemberAccessRule(
                    member: m,
                    grant: widget.cubit.grantForMember(m),
                  ))
              .toList(growable: false),
          onToggle: widget.cubit.toggleIndividualMember,
          onPermissionChanged: (DatabaseMember m, DatabasePermissionLevel l) =>
              widget.cubit.memberRuleChanged(m, permission: l),
          onStartDateChanged: (DatabaseMember m, DateTime d) =>
              widget.cubit.memberRuleChanged(m, startDate: d),
          onEndDateChanged: (DatabaseMember m, DateTime d) =>
              widget.cubit.memberRuleChanged(m, endDate: d),
          departmentLabel: (DatabaseMember member) => state.departmentNameFor(
            member.departmentId,
            isArabic: context.isArabic,
          ),
        ),
      ],
    );
  }

  /// The department FILTER on the Restricted screen — single-select with an
  /// "All" row. Narrowing a list is a different job from choosing who gets
  /// access, which is why this is a plain dropdown and the Open screen's is a
  /// multi-select.
  Widget _departmentFilter(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
  ) {
    // Sentinel for the "All" row: DropdownItem's value is non-nullable, so a
    // null option cannot be expressed directly.
    const String allSentinel = '';

    return CustomDropdown<String>(
      height: 38,
      borderRadius: BorderRadius.circular(8.r),
      value: state.selectedDepartmentId ?? allSentinel,
      hint: strings.department,
      fillColor: _fieldFill,
      valueStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      items: <DropdownItem<String>>[
        DropdownItem<String>(value: allSentinel, label: strings.all),
        ...state.departments.map(
          (DatabaseDepartment dept) => DropdownItem<String>(
            value: dept.id,
            label: dept.localizedName(isArabic: context.isArabic),
          ),
        ),
      ],
      onChanged: (String value) => widget.cubit
          .departmentSelected(value == allSentinel ? null : value),
    );
  }

  // ── Shared ───────────────────────────────────────────────────────────────

  /// The page colour — `CustomDropdown`'s own default fill — so the search box
  /// and the dropdowns match by construction rather than by two independent
  /// choices, and the theme map handles light/dark instead of an `isDark`
  /// branch here.
  Color get _fieldFill => AppColors.background;

  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);
}

/// The horizontal chips under the Department multi-select (Figma 7398:9476 —
/// "Marketing / Design / Finance").
///
/// These are the departments already PICKED, not the ones available. Tapping
/// one focuses it — the yellow chip — which scopes the permission fields and
/// the employee list below.
class _DepartmentChips extends StatelessWidget {
  const _DepartmentChips({
    required this.departments,
    required this.selectedId,
    required this.onSelected,
  });

  final List<DatabaseDepartment> departments;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (departments.isEmpty) return const SizedBox.shrink();
    final bool isArabic = context.isArabic;

    return SizedBox(
      height: 28.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (BuildContext context, int index) {
          final DatabaseDepartment dept = departments[index];
          final bool selected = dept.id == selectedId;

          return GestureDetector(
            onTap: () => onSelected(dept.id),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.transparent,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                dept.localizedName(isArabic: isArabic),
                style: StyleText.fontSize14Weight400.copyWith(
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

/// The strip of picked avatars with a red remove badge.
/// Sizes come off `Ellipse 230` and `Close Circle` in the Figma: a 32pt face
/// on a 40pt pitch (so an 8pt gap) with a 10pt badge pinned to its trailing
/// top corner.
class _PickedAvatarRow extends StatelessWidget {
  const _PickedAvatarRow({
    required this.metrics,
    required this.members,
    required this.onRemove,
  });

  final DatabaseDetailsMetrics metrics;
  final List<DatabaseMember> members;
  final ValueChanged<DatabaseMember> onRemove;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final double size = metrics.avatarSize;
    final double badge = metrics.avatarBadgeSize;

    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => SizedBox(width: metrics.avatarGap),
        itemBuilder: (BuildContext context, int index) {
          final DatabaseMember member = members[index];

          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // FIXED 16/8/2026: a member with no photo drew a bare grey
                // circle. `backgroundImage: null` is not a placeholder — it is
                // the absence of one, and this strip sits directly above the
                // people cards, which have always shown a face.
                //
                // `foregroundImage` plus an SVG child, NOT `backgroundImage`:
                // the default avatar is an SVG and `AssetImage` cannot decode
                // one. A foreground image draws OVER the child, so the
                // placeholder shows while a real photo loads and stays visible
                // if the URL 404s. Same arrangement as `AccessTable._avatar`
                // and `PersonChipCard`, which is why these faces now match the
                // cards under them.
                CircleAvatar(
                  radius: size / 2,
                  backgroundColor: AppColors.moreLightGrey,
                  foregroundImage:
                      (member.photoUrl == null || member.photoUrl!.isEmpty)
                          ? null
                          : appImageProvider(member.photoUrl!),
                  child: ClipOval(
                    child: CustomSvgImage(
                      assetPath: AppAssets.defaultEmployeeAvatar,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: GestureDetector(
                    onTap: () => onRemove(member),
                    child: Container(
                      width: badge,
                      height: badge,
                      decoration: BoxDecoration(
                        color: AppColors.delete,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: badge * 0.7,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The yellow "Deselect All" pill (Figma 7398:9476).
class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
