/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: access_management_page.dart
/// Purpose: Declares `AccessManagementPage`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// Step 2 of the flow — choosing who gets access. Both iPad orientations,
/// and BOTH Figma variants, in one file:
///
///   ADD MEMBERS      7398:7396 (H) / 7398:7520 (V)
///     search + department filter, a row of picked avatars, people cards.
///
///   BY DEPARTMENT    7398:18600 (H) / 7398:8692 (V)
///     department dropdown + chips, the permissions/dates block, a
///     select-all control, people cards scoped to the chosen department.
///
/// WHY ONE PAGE AND NOT TWO
/// ------------------------
/// Stacked side by side, the two frames are the same screen with two rows
/// swapped: the avatar strip is replaced by the department chips and the
/// access-rule block. Everything below — search, the people grid, the
/// Save For Later / Review footer — is identical, down to the button
/// positions. Two files would duplicate that and drift.
///
/// Which variant renders is driven by `state.step`, which the details screen
/// set from the access type the user chose. See
/// `CreateDatabaseCubit.validateDetailsAndAdvance`.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/access_rule_fields.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/member_grid.dart';

class AccessManagementPage extends StatefulWidget {
  const AccessManagementPage({
    super.key,
    required this.cubit,
    required this.onReview,
    required this.onExit,
    this.createdBy,
  });

  /// Provided by the flow host, not created here — the draft has to survive
  /// this screen being popped.
  final CreateDatabaseCubit cubit;

  /// Employee id stamped on a record saved from here. Only "Save For Later"
  /// writes from this screen; the finished write happens on Review.
  final String? createdBy;

  /// "Review" — pushes the review screen.
  final VoidCallback onReview;

  /// Leaves the wizard entirely and returns to the Database Builder list.
  ///
  /// Wired by the flow host, not done locally: `Navigator.of(context)` here
  /// resolves to the flow's INNER navigator, which can only move between
  /// steps. Exiting means popping the MODULE's navigator, one level up.
  final VoidCallback onExit;

  @override
  State<AccessManagementPage> createState() => _AccessManagementPageState();
}

class _AccessManagementPageState extends State<AccessManagementPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Directory is loaded once per flow; calling again is a no-op while a
    // load is in flight, so arriving here twice costs nothing.
    widget.cubit.loadDirectory();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _onReviewPressed(CreateDatabaseState state) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    // Granting access to nobody is a mis-tap, not an intention.
    // Was a snackbar; the guard blocks the flow, so it is shown as a dialog
    // the user has to dismiss rather than a toast they can miss.
    if (state.allMembers.isEmpty) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: strings.pickSomeoneFirst,
        closeLabel: strings.close,
      );
      return;
    }

    // An unfinished access rule is refused HERE, not carried to Review.
    // ADDED 16/8/2026: on the By Department variant the Permissions dropdown
    // and both date fields are on this screen, so "Review" with an empty
    // permission or end date only moved the problem one screen along — to a
    // Grant Access button that greyed out without saying which department was
    // short. `canReview` is what greys this button; this is the same condition
    // read on the tap, for the state that changed between frame and touch.
    if (!state.canReview) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: _missingWork(state, strings) ?? strings.incompleteGrants,
        closeLabel: strings.close,
      );
      return;
    }

    widget.onReview();
  }

  /// Names the departments still holding "Review" back, or null when there is
  /// nothing to name. ADDED 16/8/2026.
  ///
  /// The screen shows ONE department's rule at a time — the chips switch which
  /// — so a user looking at a filled Permissions box needs to be told that a
  /// different chip is the empty one. Same helper, same strings and the same
  /// `?? incompleteGrants` fallback as the Review screen, so both screens
  /// refuse in the same words.
  String? _missingWork(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
  ) {
    final String names = state.blockingGrantNames(
      isArabic: context.isArabic,
      // A grant with no department is the Add Members one. It has no name of
      // its own, and the step it came from is the only handle on it.
      individualLabel: strings.addMembers,
    );
    if (names.isEmpty) return null;
    return strings.incompleteGrantsFor(names);
  }

  /// "Save For Later" — confirm, write the record as a DRAFT, report, leave.
  ///
  /// This button used to be wired straight to [AccessManagementPage.onExit],
  /// so it closed the wizard and wrote nothing: the work was gone and the
  /// Drafts chip on the list stayed at zero. It is a real write now.
  ///
  /// The dialogs are driven inline rather than from a Bloc listener because
  /// this screen is a plain BlocBuilder — the Review screen, which already
  /// has a listener for its own submit, reuses that one instead.
  Future<void> _onSaveForLater() async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    // showConfirmDialog pops before calling onConfirm, so this is set while
    // the await below is still suspended. Cancel and barrier leave it false.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.saveDraftTitle,
      subtitle: strings.saveDraftSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    await widget.cubit.saveAsDraft(
      requiredEnMessage: strings.titleEnRequired,
      requiredArMessage: strings.titleArRequired,
      tooShortMessage: strings.titleTooShort,
      duplicateMessage: strings.duplicateTitle,
      accessRequiredMessage: strings.accessRequired,
      createdBy: widget.createdBy,
    );
    if (!mounted) return;

    final CreateDatabaseState state = widget.cubit.state;

    // A rejected write leaves the user HERE, with their picks intact — the
    // whole point of the button is not losing them.
    if (state.status != CreateDatabaseStatus.success) {
      final String message = state.errorMessage ?? strings.couldNotSave;
      widget.cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    await showSuccessDialog(
      context: context,
      title: strings.draftSavedTitle,
      subtitle: strings.draftSavedSubtitle,
      closeLabel: strings.close,
    );
    if (!mounted) return;

    // Leaving is what "for later" means. The list reloads on return, so the
    // new draft is on screen under Drafts by the time the user is back.
    widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    // Phone gate removed 15/8/2026 — the mobile frames (7398:13193 Add
    // Members, 7398:13096 By Department) are implemented: MemberGrid already
    // drops to one column below 600px, the rule fields already stack, and the
    // page shell already swaps its breadcrumb for a back chevron + title.
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);

    return BlocBuilder<CreateDatabaseCubit, CreateDatabaseState>(
      bloc: widget.cubit,
      builder: (BuildContext context, CreateDatabaseState state) {
        final bool byDepartment =
            state.step == CreateDatabaseStep.byDepartment;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: strings.database,
            secondTitle: strings.createNewDatabase,
            thirdTitle: strings.accessManagementCrumb,
            // "Database" leaves the wizard; "Create New Database" is one
            // step back. They are different destinations, so they get
            // different callbacks.
            onFirstTap: widget.onExit,
            onSecondTap: () => Navigator.of(context).maybePop(),
              // SideFrameMasterServices hands its child a BOUNDED height
              // (`Expanded(child: child!)` in that widget), so a fixed-height
              // Column overflows the moment the content is one pixel taller
              // than the viewport — the "BOTTOM OVERFLOWED BY 1.3 PIXELS"
              // stripe. Scrolling is the fix rather than shaving a gap: the
              // card grows with the description boxes and the member list, so
              // no fixed height would hold for long.
            child: CreateDatabaseMetrics.pageScroll(
              context,
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
                    child: byDepartment
                        ? _byDepartmentBody(state, strings, metrics)
                        : _addMembersBody(state, strings, metrics),
                  ),
                  SizedBox(height: metrics.cardToActions),
                  CreateDatabaseActions(
                    metrics: metrics,
                    discardLabel: strings.saveForLater,
                    primaryLabel: strings.review,
                    // "Save For Later" WRITES the draft and then leaves — it
                    // is not "back one step" (that is the second breadcrumb
                    // crumb) and no longer a silent exit.
                    onDiscard: _onSaveForLater,
                    onPrimary: () => _onReviewPressed(state),
                    isSubmitting: state.isSubmitting,
                    // Nobody picked, nothing to review. "Save For Later" stays
                    // live: parking an empty pick list is a legitimate thing
                    // to want, and it is the only way off this screen that
                    // keeps the title and access type already entered.
                    isPrimaryEnabled: state.canReview,
                    // Never grey without saying why: nobody picked yet, or a
                    // department whose permission / dates are still empty.
                    primaryDisabledHint: state.allMembers.isEmpty
                        ? strings.pickSomeoneFirst
                        : _missingWork(state, strings),
                  ),
                  SizedBox(height: metrics.blockGap),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Variant A: Add Members (7398:7396) ─────────────────────────────────────

  Widget _addMembersBody(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          strings.addMembers,
          style:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.h),

        // Search on the left, department filter on the right — NOT a 50/50
        // split. Figma 7398:7396 measures, inside an 834-wide card body:
        //
        //     search 669w   gap 15   department 150w
        //
        // so the search is roughly four fifths of the row and the department
        // box is a narrow trailing control. Kept as flex WEIGHTS rather than
        // fixed widths so that ratio holds at 1024, 1366 and 1920 alike; a
        // fixed 150 would shrink to a stub on a wide desktop.
        //
        // NOT `buildResponsiveFields` here: that helper wraps both slots in
        // `Expanded`, and AppSearchTextField is already an Expanded.
        //
        // The search sits inside a one-child Row because its own `Expanded`
        // is hard-coded to flex 1 — wrapping it in another Expanded is the
        // ParentDataWidget crash from earlier. The inner Row takes the
        // weighted slot; the search's Expanded then fills that Row.
        //
        // PHONE (Figma 7398:13193): the row becomes a stack. That 669:150
        // ratio inside a 345-wide card leaves the department box about 63pt —
        // narrower than the word "Department" — so on a phone the search
        // takes the full width and the department filter sits under it.
        if (metrics.isPhone) ...<Widget>[
          Row(
            children: <Widget>[
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
            ],
          ),
          SizedBox(height: metrics.blockGap),
          _departmentDropdown(state, strings, showAllOption: true),
        ] else
          Row(
            children: <Widget>[
              Expanded(
                flex: 669,
                child: Row(
                  children: <Widget>[
                    AppSearchTextField(
                      controller: _search,
                      hintText: strings.search,
                      fillColor: _fill,
                      onChanged: widget.cubit.memberSearchChanged,
                    ),
                  ],
                ),
              ),
              SizedBox(width: metrics.columnGap),
              Expanded(
                flex: 150,
                child: _departmentDropdown(state, strings, showAllOption: true),
              ),
            ],
          ),
        SizedBox(height: metrics.blockGap),

        _PickedAvatarRow(
          members: state.allMembers.toList(growable: false),
          onRemove: widget.cubit.removeMemberEverywhere,
        ),
        SizedBox(height: metrics.blockGap),

        _grid(state, strings),
      ],
    );
  }

  // ── Variant B: By Department (7398:18600) ─────────────────────────────────

  Widget _byDepartmentBody(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    // NOTHING BELOW THE DROPDOWN UNTIL A DEPARTMENT IS PICKED, fixed 16/8/2026.
    //
    // The screen used to render its whole body from the moment Open Access was
    // chosen: an empty chip row, a Permissions block and a pair of date fields
    // bound to no department, and the full employee directory with a "Deselect
    // All" button next to it. Filling those fields did nothing that survived —
    // `permissionChanged(departmentId: null)` with no grants has nothing to
    // write to — and "Select All" offered to grant access to the whole company
    // through a screen whose entire job is scoping access to one department.
    //
    // The gate is `selectedDepartmentIds`, not `selectedDepartmentId`: ticking
    // the first department in the multi-select also focuses it (see
    // `CreateDatabaseCubit.departmentsChanged`), so the two are never out of
    // step here, and keying off the list says what the rule actually is —
    // nothing is in play until at least one department is.
    final bool hasDepartment = state.selectedDepartmentIds.isNotEmpty;

    // The access rule shown here belongs to the department in focus, so a
    // department with no one picked yet still has fields to fill.
    final DatabaseAccessGrant grant = (state.selectedDepartmentId == null
            ? state.individualGrant
            : state.grantForDepartment(state.selectedDepartmentId!)) ??
        const DatabaseAccessGrant(members: <DatabaseMember>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.department,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.text)),
        SizedBox(height: 6.h),
        buildResponsiveFields(
          context: context,
          left: _departmentMultiSelect(state, strings),
          right: const SizedBox.shrink(),
        ),

        // Everything else waits for a pick.
        if (!hasDepartment) ...<Widget>[
        ] else ...<Widget>[
          SizedBox(height: 10.h),

          // Only the PICKED departments become chips — Figma 7398:18600 shows
          // "Marketing / Design / Finance" under a field reading "Marketing",
          // not the whole org chart. Listing every department here turned the
          // row into a directory and left nothing showing what was chosen.
          _DepartmentChips(
            departments: state.selectedDepartments,
            selectedId: state.selectedDepartmentId,
            onSelected: widget.cubit.departmentSelected,
          ),
          SizedBox(height: metrics.blockGap),

          AccessRuleFields(
            grant: grant,
            onPermissionChanged: (level) => widget.cubit.permissionChanged(
              level,
              departmentId: state.selectedDepartmentId,
            ),
            onStartDateChanged: (date) => widget.cubit.startDateChanged(
              date,
              departmentId: state.selectedDepartmentId,
            ),
            onEndDateChanged: (date) => widget.cubit.endDateChanged(
              date,
              departmentId: state.selectedDepartmentId,
            ),
          ),
          SizedBox(height: metrics.blockGap),

          Text(strings.employeeInformation,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),

          Row(
            children: <Widget>[
              // Already an Expanded internally, so no wrapper here.
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
              SizedBox(width: 10.w),
              _SelectAllButton(
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

          _grid(state, strings),
        ],
      ],
    );
  }

  // ── Shared pieces ─────────────────────────────────────────────────────────

  bool _allVisibleSelected(CreateDatabaseState state) {
    final List<DatabaseMember> visible = state.visibleEmployees;
    if (visible.isEmpty) return false;
    return visible.every(state.isMemberSelected);
  }

  Widget _grid(CreateDatabaseState state, CreateDatabaseStrings strings) {
    if (state.isLoadingDirectory) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        // `CircleProgressMaster` centres itself and sizes off the shortest
        // side, so it replaces the Center as well as the indicator.
        child: const CircleProgressMaster(),
      );
    }

    final bool isArabic = context.isArabic;

    return MemberGrid(
      members: state.visibleEmployees,
      trailing: MemberGridTrailing.check,
      isSelected: state.isMemberSelected,
      onTap: widget.cubit.toggleMember,
      // The card shows the department NAME. The member snapshot only holds
      // the id, and the id in this org is a bare number, so the join happens
      // here where the loaded department list is in reach.
      departmentLabel: (DatabaseMember member) =>
          state.departmentNameFor(member.departmentId, isArabic: isArabic),
    );
  }

  /// The Department field on the By Department screen — a MULTI-SELECT, not a
  /// dropdown.
  ///
  /// Access is granted to several departments at once (that is the whole point
  /// of the chip row underneath), so one-at-a-time selection could never
  /// express what the screen is for. `CustomMultiSelectDropdown` is the core
  /// widget for this: it mirrors `CustomDropdown`'s trigger exactly — same
  /// InputDecorator, same chevron — so the field sits flush with Permissions
  /// below it, and each row carries a `CustomCheckBox`.
  ///
  /// The trigger keeps its own label rather than previewing the picks
  /// (`alwaysShowHint`): the chip row below is the real affordance for seeing
  /// and focusing them, and a comma-joined copy above it said the same thing
  /// twice while costing the field its name.
  Widget _departmentMultiSelect(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
  ) {
    final bool isArabic = context.isArabic;

    return CustomMultiSelectDropdown<String>(
      borderRadius: BorderRadius.circular(4.r),
      values: state.selectedDepartmentIds,
      hint: strings.department,
      // The field keeps saying "Department" (16/8/2026). The chip row directly
      // underneath IS the list of picks, and it is the better one — each chip
      // is tappable and shows which department is in focus, where the trigger
      // could only ellipsise "Marketing, Design, Fin…".
      alwaysShowHint: true,
      fillColor: _fill,
      valueStyle:
          StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      items: state.departments
          .map((DatabaseDepartment dept) => MultiSelectDropdownItem<String>(
                value: dept.id,
                label: dept.localizedName(isArabic: isArabic),
              ))
          .toList(growable: false),
      onChanged: widget.cubit.departmentsChanged,
    );
  }

  /// The department FILTER on the Add Members screen — single-select, with an
  /// "All" row. Narrowing a list is a different job from choosing who gets
  /// access, which is why that screen keeps a plain dropdown.
  Widget _departmentDropdown(
    CreateDatabaseState state,
    CreateDatabaseStrings strings, {
    required bool showAllOption,
  }) {
    final bool isArabic = context.isArabic;

    // Sentinel for the "All" row: DropdownItem's value is non-nullable, so a
    // null option cannot be expressed directly.
    const String allSentinel = '';

    return CustomDropdown<String>(


      borderRadius: BorderRadius.circular(8.r),

      value: state.selectedDepartmentId ?? (showAllOption ? allSentinel : null),
      hint: strings.department,
      fillColor: _fill,
      valueStyle:
          StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      items: <DropdownItem<String>>[
        // "All" only makes sense while picking individuals — the department
        // variant scopes every action to one department, so an all-departments
        // state there would have nothing to apply a permission to.
        if (showAllOption)
          DropdownItem<String>(value: allSentinel, label: strings.all),
        ...state.departments.map(
          (DatabaseDepartment dept) => DropdownItem<String>(
            value: dept.id,
            label: dept.localizedName(isArabic: isArabic),
          ),
        ),
      ],
      onChanged: (String value) => widget.cubit
          .departmentSelected(value == allSentinel ? null : value),
    );
  }

  /// Field fill for the search box and the dropdowns on this screen.
  ///
  /// `AppColors.background` — the page colour — not a black/near-white pair.
  /// It is already `CustomDropdown`'s own default fill, so search and dropdown
  /// now match by construction instead of by two independent choices, and the
  /// theme map handles light/dark rather than an `isDark` branch here.
  Color get _fill => AppColors.background;
}

/// The strip of picked avatars with a red remove badge (Figma 7398:7396).
///
/// Not `StackedAvatars` — that widget overlaps its avatars to save space and
/// has no per-avatar affordance. Here each face has its own tap target.
class _PickedAvatarRow extends StatelessWidget {
  const _PickedAvatarRow({required this.members, required this.onRemove});

  final List<DatabaseMember> members;
  final ValueChanged<DatabaseMember> onRemove;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34.r,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (BuildContext context, int index) {
          final DatabaseMember member = members[index];
          return SizedBox(
            width: 34.r,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // Brought in line with the rest of the module 16/8/2026.
                //
                // It already had a placeholder, but as a `backgroundImage` plus
                // a CONDITIONAL child: the SVG was drawn only while `photoUrl`
                // was empty, so a photo whose URL 404s left a bare grey circle —
                // the exact case a placeholder exists for. `foregroundImage`
                // draws OVER a child that is always present, so the fallback
                // survives a failed load.
                //
                // The asset was also a hardcoded string; it is
                // `AppAssets.defaultEmployeeAvatar` now — the same constant
                // `MemberGrid` hands the cards directly below this strip.
                CircleAvatar(
                  radius: 15.r,
                  backgroundColor: AppColors.moreLightGrey,
                  foregroundImage:
                      (member.photoUrl == null || member.photoUrl!.isEmpty)
                          ? null
                          : appImageProvider(member.photoUrl!),
                  child: ClipOval(
                    child: CustomSvgImage(
                      assetPath: AppAssets.defaultEmployeeAvatar,
                      width: 30.r,
                      height: 30.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: -2,
                  end: 0,
                  child: GestureDetector(
                    onTap: () => onRemove(member),
                    child: Container(
                      width: 14.r,
                      height: 14.r,
                      decoration: BoxDecoration(
                        color: AppColors.delete,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close,
                          size: 9.r, color: AppColors.white),
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

/// The horizontal chips under the Department multi-select (Figma 7398:18600 —
/// "Marketing / Design / Finance").
///
/// These are the departments already PICKED, not the ones available: picking
/// happens in the multi-select above. Tapping a chip focuses it — the yellow
/// one — which scopes the permission fields and the employee list below.
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
                color: selected ? AppColors.primary : AppColors.background,
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

/// The yellow "Deselect All" pill (Figma 7398:18600).
class _SelectAllButton extends StatelessWidget {
  const _SelectAllButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 37.sp,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            CustomSvgImage(assetPath: 'assets/icons_assets/database_builder_assets/select.svg',width: 16.sp,height: 16.sp,),
            SizedBox(width: 8.sp),
            Text(
              label,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.textButton),
            ),
          ],
        ),
      ),
    );
  }
}
