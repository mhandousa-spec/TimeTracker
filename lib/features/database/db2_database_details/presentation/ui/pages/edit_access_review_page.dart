/// Module: database / db2_database_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_access_review_page.dart
/// Purpose: Declares `EditAccessReviewPage`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Editing Access Management" — Figma 7398:18356 (iPad V, 1024 x 1158) /
/// 7398:10002 (iPad H, 768 x 1086).
///
///   Summary tiles, one tab per department ("5 Marketing", "7 Finance"), that
///   department's permission and window, its people with a red remove badge,
///   and a Discard / Save footer.
///
/// Only the OPEN path reaches this screen. Restricted edits every person's
/// rule on the previous screen — there is nothing left to review — and
/// Personal has nobody. See `EditDatabaseAccessPage._onPrimaryPressed`.
///
/// WHAT DIFFERS FROM db1's REVIEW
/// ------------------------------
/// The footer. db1's reads "Save For Later" / "Grant Access" because it is the
/// end of a wizard that has not written anything yet; this one reads "Discard"
/// / "Save" because the record already exists and the only question is whether
/// the new grants replace the old ones. The summary tiles, the tab row and the
/// rule block are the same widgets.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/access_rule_fields.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/member_grid.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/controller/edit_database_access_cubit.dart';

class EditAccessReviewPage extends StatefulWidget {
  const EditAccessReviewPage({
    super.key,
    required this.cubit,
    required this.onCompleted,
    required this.onExit,
  });

  final EditDatabaseAccessCubit cubit;

  /// A finished save, carrying the refreshed record.
  final ValueChanged<DatabaseEntity> onCompleted;

  /// Leaves the editor entirely — not one step back, which is what the system
  /// back gesture does. Wired by the flow host for the same reason as on the
  /// previous screen.
  final VoidCallback onExit;

  @override
  State<EditAccessReviewPage> createState() => _EditAccessReviewPageState();
}

class _EditAccessReviewPageState extends State<EditAccessReviewPage> {
  final TextEditingController _search = TextEditingController();

  /// Which department tab is open, by INDEX rather than by id: the tabs are
  /// positional in the Figma and a grant can be emptied out from under this
  /// screen by the red remove badge.
  int _activeTab = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _onSave(CreateDatabaseState state) async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    // Every grant needs a level and both dates before it can be written. The
    // guard blocks the save, so it is a dialog the user has to dismiss rather
    // than a toast they can miss.
    if (!state.canGrantAccess) {
      await showWarningDialog(
        context: context,
        title: strings.incompleteTitle,
        subtitle: strings.incompleteGrants,
        closeLabel: strings.close,
      );
      return;
    }

    await showConfirmDialog(
      context: context,
      title: strings.editConfirmTitle,
      subtitle: strings.editConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => widget.cubit.saveAccess(),
    );
  }

  Future<void> _onDiscard() async {
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

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final bool isArabic = context.isArabic;
    final String title = FormatHelper.capitalize(
        widget.cubit.database.localizedTitle(isArabic: isArabic));

    return BlocConsumer<CreateDatabaseCubit, CreateDatabaseState>(
      bloc: widget.cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, CreateDatabaseState state) {
        final List<DatabaseAccessGrant> grants = state.grants
            .where((DatabaseAccessGrant g) => g.isDepartmentScoped)
            .toList(growable: false);

        final int tab =
            _activeTab.clamp(0, grants.isEmpty ? 0 : grants.length - 1);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: strings.database,
            secondTitle: title,
            thirdTitle: strings.editingAccessManagement,
            onFirstTap: widget.onExit,
            // The record's own crumb is one step back — to the screen that
            // picked the departments — which is the inner navigator's job.
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
                        child: SummaryTileRow(tiles: _tiles(state, strings)),
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
                      child: grants.isEmpty
                          ? _empty(strings)
                          : _body(state, strings, metrics, grants, tab),
                    ),
                    SizedBox(height: metrics.cardToActions),

                    CreateDatabaseActions(
                      metrics: metrics,
                      discardLabel: strings.discardChanges,
                      primaryLabel: strings.save,
                      onDiscard: _onDiscard,
                      onPrimary: () => _onSave(state),
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

  /// Every person can be removed from the previous screen AND from here, so
  /// this screen has to survive being emptied rather than rendering a tab row
  /// with no tabs.
  Widget _empty(DatabaseDetailsStrings strings) => Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            strings.pickSomeoneFirst,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      );

  /// "Total Employees / 20", "Total Departments / 3", "Permissions / Custom",
  /// "Access Management / Open Access" — the four tiles of 7398:18356.
  ///
  /// `SummaryTileRow` lays them out four across on a tablet and 2 x 2 on a
  /// phone, so the count is handed over as-is rather than trimmed here.
  List<SummaryTile> _tiles(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
  ) {
    final bool isArabic = context.isArabic;
    final DatabasePermissionLevel? permission = state.effectivePermission;

    return <SummaryTile>[
      SummaryTile(
        label: strings.totalEmployees,
        value: '${state.totalEmployees}',
      ),
      SummaryTile(
        label: strings.totalDepartments,
        value: '${state.totalDepartments}',
      ),
      SummaryTile(
        label: strings.permissions,
        // Null while nothing has been chosen anywhere; "Custom" once two
        // departments disagree, which is what the Figma's Custom tile means.
        value: permission == null
            ? '—'
            : (isArabic ? permission.labelAr : permission.labelEn),
      ),
      SummaryTile(
        label: strings.accessManagement,
        value: state.accessType == null
            ? '—'
            : (isArabic
                ? state.accessType!.labelAr
                : state.accessType!.labelEn),
      ),
    ];
  }

  Widget _body(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
    List<DatabaseAccessGrant> grants,
    int tab,
  ) {
    final DatabaseAccessGrant grant = grants[tab];
    final bool isArabic = context.isArabic;
    final String query = state.memberSearchQuery.trim().toLowerCase();

    // The search box narrows the PEOPLE IN THIS TAB, not the directory: this
    // screen is a review of who was picked, so searching it must not offer
    // somebody who was not.
    final List<DatabaseMember> members = grant.members
        .where((DatabaseMember m) =>
            query.isEmpty ||
            m.nameEn.toLowerCase().contains(query) ||
            m.nameAr.contains(state.memberSearchQuery.trim()))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The department tabs. `StatusChipFilter` is the app's count-chip row
        // — the same widget the Database Builder list and the Access screen
        // use — so "5 Marketing" here is the same component as "14 Active"
        // there rather than a third thing that looks almost like it.
        StatusChipFilter(
          items: <StatusChipItem>[
            for (int i = 0; i < grants.length; i++)
              StatusChipItem(
                key: '$i',
                label: FormatHelper.capitalize(
                    grants[i].localizedDepartmentName(isArabic: isArabic)),
                count: grants[i].memberCount,
              ),
          ],
          selectedKey: '$tab',
          onSelected: (String key) =>
              setState(() => _activeTab = int.tryParse(key) ?? 0),
        ),
        SizedBox(height: metrics.blockGap),

        // db1's block again, scoped to the department in focus.
        AccessRuleFields(
          grant: grant,
          enabled: !state.isSubmitting,
          onPermissionChanged: (DatabasePermissionLevel level) => widget.cubit
              .permissionChanged(level, departmentId: grant.departmentId),
          onStartDateChanged: (DateTime date) => widget.cubit
              .startDateChanged(date, departmentId: grant.departmentId),
          onEndDateChanged: (DateTime date) => widget.cubit
              .endDateChanged(date, departmentId: grant.departmentId),
        ),
        SizedBox(height: metrics.blockGap),

        Text(
          strings.employeeInformation,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.h),
        Row(
          children: <Widget>[
            // AppSearchTextField's root IS an Expanded, so it goes straight
            // into the Row.
            AppSearchTextField(
              controller: _search,
              hintText: strings.search,
              fillColor: AppColors.background,
              onChanged: widget.cubit.memberSearchChanged,
            ),
          ],
        ),
        SizedBox(height: metrics.blockGap),

        MemberGrid(
          members: members,
          trailing: MemberGridTrailing.remove,
          // The red minus is not scoped to this tab — `removeMemberEverywhere`
          // takes the person off every grant. Somebody removed on the
          // Marketing tab who was also in Finance would otherwise stay,
          // and the tile above would keep counting them.
          onTap: widget.cubit.removeMemberEverywhere,
          departmentLabel: (DatabaseMember member) => state.departmentNameFor(
            member.departmentId,
            isArabic: isArabic,
          ),
        ),
      ],
    );
  }
}
