/// Module: GRC shared widgets
/// Description: The "Tasks" block at the foot of the Control Champion and
///              Control Owner details screens -- status count bar, search,
///              policy filter, export, and the task list (a table at
///              768 / 1024, one card per task at 375).
/// Author: Knowticed Plus team
/// Date: 2026-09-15
/// Dependencies: AssignmentControlCubit (champion tasks), MyAuditCubit
///               (owner tasks), FilterBarItem (79), AppSearchTextField (35),
///               CustomSortButton (47), customButtonWithSvg (6)
library;

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_tab.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/controller/my_audit_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_export.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_table_columns.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One status bucket on the count bar ("Approved", "Scored", ...).
class GrcTaskStatus {
  /// Untranslated English label -- the lookup key for [grcTr].
  final String label;
  final Color color;

  const GrcTaskStatus({required this.label, required this.color});
}

/// One task row, already reduced to what the table / card draws.
class GrcTaskRow {
  final String policyId;
  final String policyName;
  final String controlName;
  final GrcTaskStatus status;

  /// The Control Owner column (champion tasks only). Null hides it.
  final String? controlOwnerEmail;

  const GrcTaskRow({
    required this.policyId,
    required this.policyName,
    required this.controlName,
    required this.status,
    this.controlOwnerEmail,
  });
}

// ──────────────────────────────────────────────────────────────────────
// Data adapters
// ──────────────────────────────────────────────────────────────────────

/// class name: [GrcChampionTasksSection]
///
/// purpose: Tasks for one Control Champion -- the same rows the champion
///          sees on their own Assignment Controls list, loaded for
///          [championEmail] instead of the signed-in user.
class GrcChampionTasksSection extends StatelessWidget {
  final String moduleId;
  final String championEmail;

  const GrcChampionTasksSection({
    super.key,
    required this.moduleId,
    required this.championEmail,
  });

  /// Bar order as MAGDY draws it: All, Approved, Submitted, Pending,
  /// In review, Rejected, Overdue.
  static const List<AssignmentControlTab> _order = [
    AssignmentControlTab.approved,
    AssignmentControlTab.submitted,
    AssignmentControlTab.pending,
    AssignmentControlTab.inReview,
    AssignmentControlTab.rejected,
    AssignmentControlTab.overdue,
  ];

  static GrcTaskStatus _status(AssignmentControlTab tab) => GrcTaskStatus(
        label: tab.label,
        color: AssignmentControlTabStyle.of(tab).color,
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssignmentControlCubit>(
      create: (_) => GetIt.instance<AssignmentControlCubit>()
        ..getMyAssignmentControls(
          moduleId: moduleId,
          championEmail: championEmail,
        ),
      child: BlocBuilder<AssignmentControlCubit, AssignmentControlState>(
        builder: (context, state) {
          final bool isArabic = context.isArabic;
          return GrcAssigneeTasksSection(
            isLoading: state is AssignmentControlLoading ||
                state is AssignmentControlInitial,
            errorText: state is AssignmentControlFailure ? state.message : null,
            statuses: [for (final t in _order) _status(t)],
            showControlOwner: true,
            exportFileName: 'control_champion_tasks',
            rows: state is AssignmentControlListLoaded
                ? [
                    for (final item in state.items)
                      GrcTaskRow(
                        policyId: item.policy.id,
                        policyName: isArabic
                            ? item.policy.policyNameAr
                            : item.policy.policyNameEn,
                        controlName: isArabic
                            ? item.control.controlsNameAr
                            : item.control.controlsNameEn,
                        status: _status(item.tab),
                        controlOwnerEmail: item.ownerEmail,
                      ),
                  ]
                : const [],
          );
        },
      ),
    );
  }
}

/// class name: [GrcOwnerTasksSection]
///
/// purpose: Tasks for one Control Owner -- the rows of that owner's My
///          Audits list (Outstanding / Pending / Scored / Rejected /
///          Overdue).
class GrcOwnerTasksSection extends StatelessWidget {
  final String moduleId;
  final String ownerEmail;

  const GrcOwnerTasksSection({
    super.key,
    required this.moduleId,
    required this.ownerEmail,
  });

  static const List<MyAuditTab> _order = [
    MyAuditTab.outstanding,
    MyAuditTab.pending,
    MyAuditTab.scored,
    MyAuditTab.rejected,
    MyAuditTab.overdue,
  ];

  static GrcTaskStatus _status(MyAuditTab tab) => GrcTaskStatus(
        label: tab.label,
        color: MyAuditTabStyle.of(tab).color,
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyAuditCubit>(
      create: (_) => GetIt.instance<MyAuditCubit>()
        ..getMyAudits(moduleId: moduleId, ownerEmail: ownerEmail),
      child: BlocBuilder<MyAuditCubit, MyAuditState>(
        builder: (context, state) {
          final bool isArabic = context.isArabic;
          return GrcAssigneeTasksSection(
            isLoading: state is MyAuditLoading || state is MyAuditInitial,
            errorText: state is MyAuditFailure ? state.message : null,
            statuses: [for (final t in _order) _status(t)],
            showControlOwner: false,
            exportFileName: 'control_owner_tasks',
            rows: state is MyAuditListLoaded
                ? [
                    for (final item in state.items)
                      GrcTaskRow(
                        policyId: item.policy.id,
                        policyName: isArabic
                            ? item.policy.policyNameAr
                            : item.policy.policyNameEn,
                        controlName: isArabic
                            ? item.control.controlsNameAr
                            : item.control.controlsNameEn,
                        status: _status(item.tab),
                        controlOwnerEmail: ownerEmail,
                      ),
                  ]
                : const [],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
// Presentation
// ──────────────────────────────────────────────────────────────────────

/// class name: [GrcAssigneeTasksSection]
///
/// purpose: draws the Tasks block from already-reduced [rows]. Owns the
///          selected status, search text and policy filter.
class GrcAssigneeTasksSection extends StatefulWidget {
  final List<GrcTaskRow> rows;
  final List<GrcTaskStatus> statuses;
  final bool isLoading;
  final String? errorText;
  final bool showControlOwner;
  final String exportFileName;

  const GrcAssigneeTasksSection({
    super.key,
    required this.rows,
    required this.statuses,
    required this.isLoading,
    required this.showControlOwner,
    required this.exportFileName,
    this.errorText,
  });

  @override
  State<GrcAssigneeTasksSection> createState() =>
      _GrcAssigneeTasksSectionState();
}

class _GrcAssigneeTasksSectionState extends State<GrcAssigneeTasksSection> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// null = "All".
  String? _statusLabel;

  /// null = every policy.
  String? _policyId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GrcTaskRow> get _visible {
    final String q = _query.trim().toLowerCase();
    return widget.rows.where((r) {
      if (_statusLabel != null && r.status.label != _statusLabel) return false;
      if (_policyId != null && r.policyId != _policyId) return false;
      if (q.isEmpty) return true;
      return r.policyName.toLowerCase().contains(q) ||
          r.controlName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final List<GrcTaskRow> visible = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).tasks,
          style: StyleText.fontSize20Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 10.h),
        _statusBar(context),
        SizedBox(height: 15.h),
        _toolbar(context, isMobile, visible),
        SizedBox(height: 10.h),
        if (widget.isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: const CircleProgressMaster(),
            ),
          )
        else if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: Text(
                widget.errorText!,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.red),
              ),
            ),
          )
        else if (visible.isEmpty)
          const CustomEmptyState(size: 160)
        else if (isMobile)
          _cards(context, visible)
        else
          _table(context, visible),
      ],
    );
  }

  // ── status count bar ────────────────────────────────────────────────

  Widget _statusBar(BuildContext context) {
    int countOf(String? label) => label == null
        ? widget.rows.length
        : widget.rows.where((r) => r.status.label == label).length;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 30.sp,
          children: [
            FilterBarItem(
              title: S.of(context).all,
              numberOfItems: countOf(null),
              isSelected: _statusLabel == null,
              onTap: () => setState(() => _statusLabel = null),
            ),
            for (final GrcTaskStatus s in widget.statuses)
              FilterBarItem(
                title: grcTr(context, s.label),
                numberOfItems: countOf(s.label),
                color: s.color,
                isSelected: _statusLabel == s.label,
                onTap: () => setState(() => _statusLabel = s.label),
              ),
          ],
        ),
      ),
    );
  }

  // ── search / filter / export ────────────────────────────────────────

  Widget _toolbar(
      BuildContext context, bool isMobile, List<GrcTaskRow> visible) {
    // Policies present in this person's tasks, for the Filter menu.
    final Map<String, String> policies = {
      for (final r in widget.rows) r.policyId: r.policyName,
    };

    return Row(
      spacing: 10.w,
      children: [
        AppSearchTextField(
          controller: _searchController,
          hintText: S.of(context).search,
          onChanged: (v) => setState(() => _query = v),
        ),
        CustomSortButton<String>(
          value: _policyId,
          items: policies.keys.toList(),
          labelBuilder: (id) => policies[id] ?? id,
          onChanged: (id) => setState(() => _policyId = id),
          title: S.of(context).filter,
          showTitle: !isMobile,
          svgPath: AppAssets.filter,
          menuWidth: 220.w,
        ),
        customButtonWithSvg(
          title: isMobile ? '' : S.of(context).export,
          function: () => _export(context, visible),
          textStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),
          color: AppColors.primary,
          image: AppAssets.export,
          widthImage: 20.sp,
          heightImage: 20.sp,
          space: 8.w,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, List<GrcTaskRow> rows) {
    final S s = S.of(context);
    return exportGrcCsv(
      context: context,
      defaultFileName: widget.exportFileName,
      header: [
        s.no,
        s.policyName,
        s.controlName,
        s.status,
        if (widget.showControlOwner) s.controlOwner,
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          [
            i + 1,
            rows[i].policyName,
            rows[i].controlName,
            grcTr(context, rows[i].status.label),
            if (widget.showControlOwner)
              employeeDisplayName(context, rows[i].controlOwnerEmail ?? ''),
          ],
      ],
    );
  }

  // ── 768 / 1024: table ───────────────────────────────────────────────
  //
  // Same recipe as RoleTableView (roles/r1_role_management/.../
  // table_widget.dart): locale-aware Directionality, a horizontal scroller,
  // a 10.sp rounded clip, fixed column widths, a `blackShadow` header in
  // white 14/500, and rows alternating `evenRowColor` / `oddRowColor` with
  // 12/600 cells.

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  Widget _table(BuildContext context, List<GrcTaskRow> rows) {
    final bool isArabic = context.isArabic;
    final List<GrcTableColumn> columns = [
      GrcTableColumn('NO', 60.w),
      GrcTableColumn('Policy Name', 170.w),
      GrcTableColumn('Control Name', 170.w),
      GrcTableColumn('Status', 120.w),
      if (widget.showControlOwner) GrcTableColumn('Control Owner', 220.w),
    ];
    final List<double> widths = resolveGrcColumnWidths(
      context,
      columns,
      headerStyle: _headerStyle,
      isArabic: isArabic,
      cellPadding: 10.sp,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // When the columns are narrower than the page, share the spare
        // width across ALL of them (in proportion to each column's own
        // width) so the table spans the full width with the columns spread
        // out, instead of bunching them on the leading side. The NO column
        // keeps its width. Narrower than the page: scroll sideways as-is.
        final double total = widths.fold(0, (a, b) => a + b);
        final double extra = constraints.maxWidth - total;
        final List<double> laidOut = [...widths];
        if (extra > 0) {
          final double growable = total - widths.first;
          for (var i = 1; i < laidOut.length; i++) {
            laidOut[i] += extra * (widths[i] / growable);
          }
        }

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  for (var i = 0; i < laidOut.length; i++)
                    i: FixedColumnWidth(laidOut[i]),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.blackShadow),
                    children: [
                      for (final GrcTableColumn c in columns)
                        Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Text(
                            grcTr(context, c.header),
                            style: _headerStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  for (var i = 0; i < rows.length; i++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: (i + 1).isEven
                            ? AppColors.evenRowColor
                            : AppColors.oddRowColor,
                      ),
                      children: [
                        _textCell(LocalizedNumber.of(context, i + 1)),
                        _textCell(rows[i].policyName),
                        _textCell(rows[i].controlName),
                        _cell(Text(
                          grcTr(context, rows[i].status.label),
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: rows[i].status.color),
                        )),
                        if (widget.showControlOwner)
                          _cell(GrcAvatarName(
                            email: rows[i].controlOwnerEmail ?? '',
                            style: StyleText.fontSize12Weight600
                                .copyWith(color: AppColors.text),
                          )),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cell(Widget child) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: child,
      );

  Widget _textCell(String text) => _cell(
        Text(
          FormatHelper.capitalize(text.isEmpty ? '-' : text),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        ),
      );

  Widget _person(BuildContext context, String? email) =>
      GrcAvatarName(email: email ?? '');

  // ── 375: cards ──────────────────────────────────────────────────────

  Widget _cards(BuildContext context, List<GrcTaskRow> rows) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          _card(context, rows[i]),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, GrcTaskRow row) {
    final S s = S.of(context);
    final String? email = row.controlOwnerEmail;
    final String department = email == null
        ? ''
        : findEmployeeByEmail(email).localizedDepartment(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  FormatHelper.capitalize(row.controlName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: '${s.status}: ',
                  style: CardStyles.label(10),
                  children: [
                    TextSpan(
                      text: grcTr(context, row.status.label),
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: row.status.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          _labelValue('${s.policyName}:', row.policyName),
          if (widget.showControlOwner && email != null) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Text('${s.controlOwner}:', style: CardStyles.label(10)),
                SizedBox(width: 5.w),
                Flexible(child: _person(context, email)),
              ],
            ),
          ],
          if (department.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _labelValue('${s.department}:', department),
          ],
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value) => Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(10),
          children: [
            TextSpan(
              text: FormatHelper.capitalize(value),
              style: CardStyles.value(10),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}
