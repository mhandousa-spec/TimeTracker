/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: access_review_page.dart
/// Purpose: Declares `AccessReviewPage`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// Step 3 — the last screen before anything is written. Both iPad
/// orientations and BOTH Figma review variants in one file:
///
///   SIMPLE            7398:17988 (H) / 7398:7697 (V)
///     two summary tiles, one permissions/dates block, one people list.
///
///   PER-DEPARTMENT    7398:18213 (H) / 7398:7855 (V)
///     four summary tiles, a count tab per department ("5 Marketing",
///     "7 Finance"), and its own permissions/dates block per tab.
///
/// WHY ONE FILE
/// ------------
/// These are not two designs — they are the same design rendering a
/// different number of access rules. `DatabaseAccessGrant` was shaped for
/// exactly this: one grant with a null department produces the simple
/// screen, several department-scoped grants produce the tabbed one. The page
/// counts grants and lays out accordingly, so a future third shape needs no
/// new file.
///
/// "Grant Access" is the flow's ONLY write.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/access_rule_fields.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/member_grid.dart';

class AccessReviewPage extends StatefulWidget {
  const AccessReviewPage({
    super.key,
    required this.cubit,
    required this.onCompleted,
    required this.onExit,
    this.createdBy,
  });

  final CreateDatabaseCubit cubit;

  /// Called once the write succeeds. The flow host closes the wizard and
  /// returns the record — this page must NOT unwind the stack itself, because
  /// it does not know how many Navigators it is nested inside. It sits in the
  /// flow's inner Navigator, which sits in the module's Navigator, which sits
  /// in the drawer's IndexedStack.
  final ValueChanged<DatabaseEntity> onCompleted;

  /// Leaves the wizard entirely and returns to the Database Builder list.
  ///
  /// Wired by the flow host, not done locally: `Navigator.of(context)` here
  /// resolves to the flow's INNER navigator, which can only move between
  /// steps. Exiting means popping the MODULE's navigator, one level up.
  final VoidCallback onExit;

  final String? createdBy;

  @override
  State<AccessReviewPage> createState() => _AccessReviewPageState();
}

class _AccessReviewPageState extends State<AccessReviewPage> {
  final TextEditingController _search = TextEditingController();

  /// Which department tab is open. An index rather than an id because the
  /// tabs are positional in the Figma and a grant can be removed underneath.
  int _activeTab = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _onGrantAccess(CreateDatabaseState state) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    // Was a snackbar; the guard blocks the flow, so it is shown as a dialog
    // the user has to dismiss rather than a toast they can miss.
    //
    // REACHABLE AGAIN SINCE 16/8/2026. The button greys out when
    // `canGrantAccess` is false, and `CreateDatabaseActions` used to swallow
    // the tap along with it — so this dialog, the one place that says what is
    // wrong, could only fire in a state that no longer existed. The row now
    // lets a greyed primary through and leaves the refusing to this guard.
    if (!state.canGrantAccess) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: _missingWork(state, strings) ?? strings.incompleteGrants,
        closeLabel: strings.close,
      );
      return;
    }

    await showConfirmDialog(
      context: context,
      title: strings.confirmCreateTitle,
      subtitle: strings.confirmCreateSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () {
        widget.cubit.submit(
          requiredEnMessage: strings.titleEnRequired,
          requiredArMessage: strings.titleArRequired,
          tooShortMessage: strings.titleTooShort,
          // NOT confirmCreateTitle — that is the dialog heading ("New
          // Database"), and passing it here made a rejected write announce
          // itself with a title instead of a reason.
          duplicateMessage: strings.duplicateTitle,
          // Unreachable from here in practice — the wizard cannot reach
          // Review without an access type — but the guard is the cubit's, so
          // the message has to come from a screen either way.
          accessRequiredMessage: strings.accessRequired,
          createdBy: widget.createdBy,
        );
      },
    );
  }

  /// "Save For Later" — confirm, write the record as a DRAFT, and let
  /// [_onStateChanged] show the success dialog and close the wizard.
  ///
  /// It goes through the same confirm → write → success path as Grant Access
  /// rather than quietly exiting, because it is a write: the user is told
  /// what is about to happen, and then told it happened and where the record
  /// went. What it does NOT do is check `canGrantAccess` — an incomplete set
  /// of grants is the normal reason to park something for later.
  Future<void> _onSaveForLater() async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    await showConfirmDialog(
      context: context,
      title: strings.saveDraftTitle,
      subtitle: strings.saveDraftSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () {
        widget.cubit.saveAsDraft(
          requiredEnMessage: strings.titleEnRequired,
          requiredArMessage: strings.titleArRequired,
          tooShortMessage: strings.titleTooShort,
          duplicateMessage: strings.duplicateTitle,
          accessRequiredMessage: strings.accessRequired,
          createdBy: widget.createdBy,
        );
      },
    );
  }

  /// Shows the success dialog once, surfaces a failure once, then clears the
  /// flag so a rebuild cannot repeat either.
  Future<void> _onStateChanged(
    BuildContext context,
    CreateDatabaseState state,
  ) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    if (state.status == CreateDatabaseStatus.failure &&
        state.errorMessage != null) {
      // Was a red snackbar. Cleared before the await for the same reason as
      // in create_database_page: leaving the failure state live while the
      // dialog is open would re-open it on the next emission.
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
      // Two different things can have just succeeded. "Save For Later" wrote
      // a draft that granted nobody anything, so it must not claim the
      // database was created and access given.
      final bool draft = state.savedAsDraft;
      await showSuccessDialog(
        context: context,
        title: draft ? strings.draftSavedTitle : strings.successTitle,
        subtitle:
            draft ? strings.draftSavedSubtitle : strings.successSubtitle,
        closeLabel: strings.close,
      );
      if (!mounted) return;
      final DatabaseEntity? created = state.createdDatabase;
      if (created != null) widget.onCompleted(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phone gate removed 15/8/2026 — the mobile review frames (7398:13289
    // two tiles, 7398:13377 four tiles + department tabs) are implemented.
    // The tabs were already a horizontal ListView and SummaryTileRow now
    // wraps to two tiles per row on a phone.
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);

    return BlocConsumer<CreateDatabaseCubit, CreateDatabaseState>(
      bloc: widget.cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, CreateDatabaseState state) {
        final List<DatabaseAccessGrant> departmentGrants = state.grants
            .where((DatabaseAccessGrant g) => g.isDepartmentScoped)
            .toList(growable: false);

        // Open Access picks by DEPARTMENT, so its review is the tabbed
        // four-tile layout (Figma 7398:18213) — even with a single department
        // picked. Restricted Access picks individuals and gets the two-tile
        // layout (7398:17988). Keying off `length > 1` got this wrong for a
        // one-department draft.
        final bool tabbed = departmentGrants.isNotEmpty;
        final int tab = _activeTab.clamp(
          0,
          departmentGrants.isEmpty ? 0 : departmentGrants.length - 1,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: strings.database,
            secondTitle: strings.createNewDatabase,
            thirdTitle: strings.accessManagementCrumb,
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
                  Text(strings.summary,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text)),
                  SizedBox(height: 8.h),
                  Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8.r)
                      ),
                      child: SummaryTileRow(tiles: _tiles(state, strings, tabbed))),
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
                    child: tabbed
                        ? _tabbedBody(
                            state, strings, metrics, departmentGrants, tab)
                        : _singleBody(state, strings, metrics),
                  ),
                  SizedBox(height: metrics.cardToActions),

                  CreateDatabaseActions(
                    metrics: metrics,
                    discardLabel: strings.saveForLater,
                    primaryLabel: strings.grantAccess,
                    // "Save For Later" WRITES the record as a draft (it used
                    // to just call onExit, which threw the work away), then
                    // the success dialog closes the wizard through
                    // _onStateChanged.
                    onDiscard: _onSaveForLater,
                    onPrimary: () => _onGrantAccess(state),
                    isSubmitting: state.isSubmitting,
                    // Every grant needs a permission, both dates and at least
                    // one person before access can be granted. "Save For
                    // Later" is deliberately NOT gated — an incomplete set of
                    // grants is the normal reason to park a draft.
                    isPrimaryEnabled: state.canGrantAccess,
                    // …and when it is not, the row says which tabs are the
                    // reason, instead of leaving a grey button to be argued
                    // with.
                    primaryDisabledHint: _missingWork(state, strings),
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

  /// Names the tabs still holding "Grant Access" back, or null when nothing
  /// is. ADDED 16/8/2026.
  ///
  /// This is the answer to the question the screen kept refusing to answer.
  /// The tabbed review shows ONE department's rule at a time, so a user who
  /// fills the tab in front of them is looking at a complete form and a dead
  /// button — the two empty tabs behind it are three taps away and nothing
  /// pointed at them.
  ///
  /// Falls back to the generic sentence (via the `??` at each call site) when
  /// there is nothing to name — an empty grant list, which is the one case
  /// where naming a department would be a lie.
  String? _missingWork(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
  ) {
    final String names = state.blockingGrantNames(
      isArabic: context.isArabic,
      // The simple review has one unnamed grant. "Add Members" is the step it
      // came from, which is the only handle the user has on it.
      individualLabel: strings.addMembers,
    );
    if (names.isEmpty) return null;
    return strings.incompleteGrantsFor(names);
  }

  // ── Summary tiles ─────────────────────────────────────────────────────────

  List<SummaryTile> _tiles(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
    bool tabbed,
  ) {
    final bool isArabic = context.isArabic;

    final List<SummaryTile> tiles = <SummaryTile>[
      SummaryTile(
        label: strings.totalEmployees,
        value: '${state.totalEmployees}',
      ),
    ];

    // The four-tile layout is what the per-department variant shows
    // (7398:18213); the simple one shows two (7398:17988).
    if (tabbed) {
      tiles.add(SummaryTile(
        label: strings.totalDepartments,
        value: '${state.totalDepartments}',
      ));
      tiles.add(SummaryTile(
        label: strings.permissions,
        value: state.effectivePermission == null
            ? '—'
            : (isArabic
                ? state.effectivePermission!.labelAr
                : state.effectivePermission!.labelEn),
      ));
    }

    tiles.add(SummaryTile(
      label: strings.accessManagement,
      // Nullable since 15/8/2026 (the dropdown starts empty). Review is
      // unreachable without a choice, so the dash is defensive only.
      value: state.accessType == null
          ? '—'
          : (isArabic
              ? state.accessType!.labelAr
              : state.accessType!.labelEn),
    ));

    // The "Viewable Fields" tile was REMOVED 16/8/2026 along with the control
    // it summarised: a database being created has no tables, so the tile could
    // only ever read "All fields" and the field under it could only ever be
    // disabled. Both live on db3's Editing Table Access screen now, where a
    // table's columns give them something to say.

    return tiles;
  }

  // ── Variant A: one rule (7398:17988) ──────────────────────────────────────

  Widget _singleBody(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    final DatabaseAccessGrant grant = state.grants.isEmpty
        ? const DatabaseAccessGrant(members: <DatabaseMember>[])
        : state.grants.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AccessRuleFields(
          grant: grant,
          enabled: !state.isSubmitting,
          onPermissionChanged: widget.cubit.permissionChanged,
          onStartDateChanged: widget.cubit.startDateChanged,
          onEndDateChanged: widget.cubit.endDateChanged,
        ),
        SizedBox(height: metrics.blockGap),
        _memberSection(state, strings, grant.members),
      ],
    );
  }

  // ── Variant B: one rule per department (7398:18213) ───────────────────────

  Widget _tabbedBody(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
    CreateDatabaseMetrics metrics,
    List<DatabaseAccessGrant> grants,
    int tab,
  ) {
    final DatabaseAccessGrant active = grants[tab];
    final bool isArabic = context.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 32.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: grants.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (BuildContext context, int index) => _DepartmentTab(
              count: grants[index].memberCount,
              label: FormatHelper.capitalize(
                  grants[index].localizedDepartmentName(isArabic: isArabic)),
              isActive: index == tab,
              // A tab whose rule is unfinished carries a red dot, so the two
              // that are blocking the button are visible from the one the user
              // is standing on — without having to open each in turn.
              isIncomplete: !grants[index].isComplete ||
                  grants[index].hasInvalidDateRange,
              onTap: () => setState(() => _activeTab = index),
            ),
          ),
        ),
        SizedBox(height: metrics.blockGap),

        AccessRuleFields(
          grant: active,
          enabled: !state.isSubmitting,
          onPermissionChanged: (level) => widget.cubit
              .permissionChanged(level, departmentId: active.departmentId),
          onStartDateChanged: (date) => widget.cubit
              .startDateChanged(date, departmentId: active.departmentId),
          onEndDateChanged: (date) => widget.cubit
              .endDateChanged(date, departmentId: active.departmentId),
        ),
        SizedBox(height: metrics.blockGap),

        _memberSection(state, strings, active.members),
      ],
    );
  }

  // ── Shared: "Employee Information" + the list ─────────────────────────────

  Widget _memberSection(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
    List<DatabaseMember> members,
  ) {
    final String query = state.memberSearchQuery.trim().toLowerCase();
    final List<DatabaseMember> visible = query.isEmpty
        ? members
        : members
            .where((DatabaseMember m) =>
                m.nameEn.toLowerCase().contains(query) ||
                m.nameAr.contains(query))
            .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.employeeInformation,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.text)),
        SizedBox(height: 6.h),
        // AppSearchTextField's root is an Expanded, which cannot live in a
        // Column of unbounded height (this one is inside a
        // SingleChildScrollView). A Row gives it the bounded main axis it
        // needs.
        Row(
          children: <Widget>[
            AppSearchTextField(
              controller: _search,
              hintText: strings.search,
              // The page colour, matching the dropdowns' own default fill —
              // same rule as the Access Management screen.
              fillColor: AppColors.background,
              onChanged: widget.cubit.memberSearchChanged,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        MemberGrid(
          members: visible,
          trailing: MemberGridTrailing.remove,
          onTap: widget.cubit.removeMemberEverywhere,
          // Department NAME, not the raw id the snapshot carries.
          departmentLabel: (DatabaseMember member) => state.departmentNameFor(
            member.departmentId,
            isArabic: context.isArabic,
          ),
        ),
      ],
    );
  }
}

/// A count-and-name tab ("5 Marketing"). The count sits in its own square,
/// yellow when active, matching Figma 7398:18213.
class _DepartmentTab extends StatelessWidget {
  const _DepartmentTab({
    required this.count,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isIncomplete = false,
  });

  final int count;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  /// This department's rule is missing a permission or a date, so it is one of
  /// the reasons "Grant Access" is grey. ADDED 16/8/2026.
  ///
  /// Drawn as a dot rather than by recolouring the tab: the count square
  /// already uses colour to mean "active", and a second meaning on the same
  /// surface would make a selected-but-unfinished tab unreadable.
  final bool isIncomplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 30.r,
            height: 30.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : (AppTheme.isDark
                      ? AppColors.colorBlack
                      : AppColors.fieldFillLight),
              borderRadius: BorderRadius.circular(context.isPhone ? 4.r :6.r),
            ),
            child: Text(
              '$count',
              style: StyleText.fontSize14Weight500.copyWith(
                color: isActive ? AppColors.textButton : AppColors.text,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: StyleText.fontSize14Weight400.copyWith(
              color: isActive ? AppColors.text : AppColors.secondaryText,
            ),
          ),
          if (isIncomplete) ...<Widget>[
            SizedBox(width: 6.w),
            Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
