/// Module: GRC / Dashboard Of All Departments
/// Description: The "Departments" tab of the GRC module page (MAGDY →
///              "MAIN PAGE : Dashboard Of All Departments"):
///            * Department picker (all departments by default)
///            * Compliance Score / Applied Policies / Applied Controls
///            * Policies | Controls counters + "Reporting and Audit"
///            * Table | Analytics switch
///            * Table: search, status filter, CSV export, and the Policies
///              or Controls table
///            * Analytics: six-month score chart
///          Built from core/custom widgets: FilterBarItem (79),
///          CustomSegmentedTabs (9), AppSearchTextField (35),
///          customButton (5), customButtonWithSvg (6), CustomDropdown (1),
///          CustomEmptyState (89), CircleProgressMaster (66).
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_labeled_switch.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_department_dashboard_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/domain/entities/department_dashboard_data.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/controller/department_dashboard_cubit.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/pages/reporting_and_audit_page.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_analytics_card.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_common_widgets.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_tables.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_module_policies_tab.dart'
    show openGrcPolicy;
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_export.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [DepartmentDashboardTab]
///
/// purpose: owns the [DepartmentDashboardCubit] for one module. Expects a
///          bounded height (the module page gives its tab body an Expanded).
class DepartmentDashboardTab extends StatelessWidget {
  final GRCModuleEntity module;

  const DepartmentDashboardTab({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DepartmentDashboardCubit>(
      create: (_) => DepartmentDashboardCubit.create(module.moduleId)..load(),
      child: _DepartmentDashboardBody(module: module),
    );
  }
}

class _DepartmentDashboardBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _DepartmentDashboardBody({required this.module});

  @override
  State<_DepartmentDashboardBody> createState() =>
      _DepartmentDashboardBodyState();
}

class _DepartmentDashboardBodyState extends State<_DepartmentDashboardBody> {
  final TextEditingController _search = TextEditingController();

  // ── GRC bug report p5: the two Departments-tab switches ─────────────────
  GrcDepartmentDashboardSettings _settings =
      const GrcDepartmentDashboardSettings();
  bool _settingsLoaded = false;

  /// Who may flip the switches: anyone allowed to edit the module. Everyone
  /// else only feels their effect.
  bool get _canManage => GrcPermission.canEditModule;

  @override
  void initState() {
    super.initState();
    GrcDepartmentDashboardSettings.load(widget.module.moduleId).then((s) {
      if (!mounted) return;
      setState(() {
        _settings = s;
        _settingsLoaded = true;
      });
    });
  }

  Future<void> _updateSettings(GrcDepartmentDashboardSettings next) async {
    final previous = _settings;
    setState(() => _settings = next);
    try {
      await GrcDepartmentDashboardSettings.save(widget.module.moduleId, next);
    } catch (_) {
      if (mounted) setState(() => _settings = previous);
    }
  }

  /// The signed-in user's own department, matched against the dashboard's
  /// department names (English or Arabic, case-insensitive).
  String? _ownDepartment(DepartmentDashboardData d) {
    final me = findEmployeeByEmail(currentGrcUserEmail());
    if (me == null) return null;
    final Set<String> mine = {
      for (final String v in [
        me.localizedDepartment(context),
        if (me.departmentId != null)
          context.read<MainCoreDepartmentCubit>()
                  .getEnglishDepartmentNameFromDepartmentId(
                      departmentId: me.departmentId!) ??
              '',
        if (me.departmentId != null)
          context.read<MainCoreDepartmentCubit>()
                  .getArabicDepartmentNameFromDepartmentId(
                      departmentId: me.departmentId!) ??
              '',
      ])
        if (v.trim().isNotEmpty) v.trim().toLowerCase(),
    };
    for (final String dep in d.departments) {
      if (mine.contains(dep.trim().toLowerCase())) return dep;
    }
    return null;
  }

  Widget _settingsSwitches() {
    final bool ar = context.isArabic;
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          GrcLabeledSwitch(
            label: ar ? 'إظهار لوحة الأقسام' : 'Show Department Dashboard',
            description: ar
                ? 'عند الإيقاف لا يرى مستخدمو الوحدة هذه اللوحة.'
                : 'When off, module users cannot see this dashboard.',
            value: _settings.showDashboard,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(showDashboard: v)),
          ),
          SizedBox(height: 10.h),
          GrcLabeledSwitch(
            label: ar ? 'السماح بالتبديل بين الأقسام' : 'Allow Switching Departments',
            description: ar
                ? 'عند الإيقاف يرى كل مستخدم قسمه فقط.'
                : 'When off, each user only sees their own department.',
            value: _settings.allowDepartmentSwitching,
            onChanged: (v) => _updateSettings(
                _settings.copyWith(allowDepartmentSwitching: v)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  DepartmentDashboardCubit get _cubit => context.read<DepartmentDashboardCubit>();

  bool get _isMobile => screenSizeOf(context) == ScreenSize.mobile;

  // ── filtering ────────────────────────────────────────────────────────

  List<PolicyEntity> _policies(DepartmentDashboardState st, DepartmentDashboardData d) {
    final bool ar = context.isArabic;
    final String q = st.search.trim().toLowerCase();
    return d.policiesFor(department: st.department).where((p) {
      if (st.statusFilter != null && p.status.value != st.statusFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final String name = ar ? p.policyNameAr : p.policyNameEn;
      final String number = ar ? p.policyNumberAr : p.policyNumberEn;
      return name.toLowerCase().contains(q) || number.toLowerCase().contains(q);
    }).toList();
  }

  List<DepartmentControlRef> _controls(
      DepartmentDashboardState st, DepartmentDashboardData d) {
    final bool ar = context.isArabic;
    final String q = st.search.trim().toLowerCase();
    return d.controlsFor(department: st.department).where((r) {
      if (st.statusFilter != null && r.control.status.value != st.statusFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final String name =
          ar ? r.control.controlsNameAr : r.control.controlsNameEn;
      final String policy = ar ? r.policy.policyNameAr : r.policy.policyNameEn;
      return name.toLowerCase().contains(q) || policy.toLowerCase().contains(q);
    }).toList();
  }

  // ── actions ──────────────────────────────────────────────────────────

  void _openReporting() {
    final cubit = _cubit;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BlocProvider.value(
          value: cubit,
          child: ReportingAndAuditPage(module: widget.module),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _openStatusFilter(DepartmentDashboardState st) async {
    final List<String> statuses = st.tab == DepartmentListTab.policies
        ? [
            for (final v in PolicyStatus.values)
              if (v != PolicyStatus.removed) v.value,
          ]
        : [for (final v in ControlStatus.values) v.value];
    final String? picked = await showDialog<String>(
      context: context,
      barrierColor: AppColors.totalBlack.withOpacity(0.4),
      builder: (_) => _StatusFilterDialog(
        statuses: statuses,
        initial: st.statusFilter,
      ),
    );
    if (picked == null || !mounted) return;
    _cubit.setStatusFilter(picked.isEmpty ? null : picked);
  }

  Future<void> _export(DepartmentDashboardState st, DepartmentDashboardData d) {
    final S s = S.of(context);
    final bool ar = context.isArabic;
    String date(DateTime v) => LocalizedDate.of(context, v, pattern: 'd MMM yyyy');
    if (st.tab == DepartmentListTab.policies) {
      final rows = _policies(st, d);
      return exportGrcCsv(
        context: context,
        defaultFileName: 'department_policies',
        header: [
          s.no,
          grcTr(context, 'Policy Number'),
          grcTr(context, 'Policy Name'),
          grcTr(context, 'Policy Score'),
          grcTr(context, 'Policy Weight'),
          grcTr(context, 'Policy Description'),
          s.publishedBy,
          grcTr(context, 'Start Date'),
          grcTr(context, 'End Date'),
          s.noOfControls,
        ],
        rows: [
          for (var i = 0; i < rows.length; i++)
            [
              i + 1,
              ar ? rows[i].policyNumberAr : rows[i].policyNumberEn,
              ar ? rows[i].policyNameAr : rows[i].policyNameEn,
              DepartmentPoliciesTable.policyPercent(rows[i]).round(),
              rows[i].policyWeight,
              ar ? rows[i].policyDescriptionAr : rows[i].policyDescriptionEn,
              departmentPersonName(context, rows[i].lastEditor),
              date(rows[i].startDate),
              date(rows[i].endDate),
              d.controlCount(rows[i].id, department: st.department),
            ],
        ],
      );
    }
    final rows = _controls(st, d);
    return exportGrcCsv(
      context: context,
      defaultFileName: 'department_controls',
      header: [
        s.no,
        grcTr(context, 'Control Name'),
        grcTr(context, 'Control Score'),
        grcTr(context, 'Control Weight'),
        grcTr(context, 'Control Description'),
        grcTr(context, 'Policy Name'),
        grcTr(context, 'Control Owner'),
        s.frequency,
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          [
            i + 1,
            ar ? rows[i].control.controlsNameAr : rows[i].control.controlsNameEn,
            rows[i].control.score,
            rows[i].control.controlsWeight,
            ar
                ? rows[i].control.controlsDescriptionAr
                : rows[i].control.controlsDescriptionEn,
            ar ? rows[i].policy.policyNameAr : rows[i].policy.policyNameEn,
            departmentPersonName(context, rows[i].ownerEmail),
            grcTr(context, rows[i].control.frequency),
          ],
      ],
    );
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartmentDashboardCubit, DepartmentDashboardState>(
      builder: (context, st) {
        final DepartmentDashboardData? d = st.data;
        if (d == null) {
          if (st.status == DepartmentLoadStatus.failure) {
            return Center(
              child: Text(
                st.message ?? S.of(context).noData,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.red),
              ),
            );
          }
          return const Center(child: CircleProgressMaster());
        }
        if (!_settingsLoaded) {
          return const Center(child: CircleProgressMaster());
        }

        // p5 switch 1: dashboard hidden from everyone who can't manage it.
        if (!_settings.showDashboard && !_canManage) {
          return Center(
            child: Text(
              context.isArabic
                  ? 'لوحة الأقسام غير متاحة لهذه الوحدة'
                  : 'The department dashboard is not available for this module',
              textAlign: TextAlign.center,
              style: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
          );
        }

        // p5 switch 2: held to their own department.
        final bool locked =
            !_settings.allowDepartmentSwitching && !_canManage;
        if (locked) {
          final String? own = _ownDepartment(d);
          if (own != null && st.department != own) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _cubit.setDepartment(own);
            });
          }
        }

        final Widget content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_canManage) ...[
                _settingsSwitches(),
                SizedBox(height: 15.h),
              ],
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IgnorePointer(
                  ignoring: locked,
                  child: Opacity(
                    opacity: locked ? 0.6 : 1,
                    child: DepartmentPicker(
                      hint: S.of(context).department,
                      value: st.department,
                      items: DepartmentPicker.departmentItems(context, d),
                      onChanged: _cubit.setDepartment,
                      includeAll: !locked,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              DepartmentStatsRow(data: d, department: st.department),
              SizedBox(height: 20.h),
              _countersRow(st, d),
              SizedBox(height: 15.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _viewSwitch(st),
              ),
              SizedBox(height: 15.h),
              if (st.view == DepartmentView.table) ...[
                _toolbar(st, d),
                SizedBox(height: 15.h),
                if (_isMobile)
                  _phoneCards(st, d)
                else
                  Expanded(child: _table(st, d)),
              ] else if (_isMobile)
                DepartmentAnalyticsCard(state: st, data: d)
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: DepartmentAnalyticsCard(state: st, data: d),
                  ),
                ),
              if (_isMobile) SizedBox(height: 20.h),
            ],
        );
        // Phone: the whole tab scrolls and the tables are drawn as cards,
        // the way every other GRC list is on a 375 screen.
        return _isMobile ? SingleChildScrollView(child: content) : content;
      },
    );
  }

  Widget _countersRow(DepartmentDashboardState st, DepartmentDashboardData d) {
    final S s = S.of(context);
    final Widget counters = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: _isMobile ? 20.sp : 30.sp,
        children: [
          FilterBarItem(
            title: s.policies,
            numberOfItems: d.policiesFor(department: st.department).length,
            isSelected: st.tab == DepartmentListTab.policies,
            onTap: () => _cubit.setTab(DepartmentListTab.policies),
          ),
          FilterBarItem(
            title: s.controls,
            numberOfItems: d.controlsFor(department: st.department).length,
            isSelected: st.tab == DepartmentListTab.controls,
            onTap: () => _cubit.setTab(DepartmentListTab.controls),
          ),
        ],
      ),
    );
    // Phone: 33.sp tall (customButton draws 38.sp; the tight box wins).
    final Widget reporting = SizedBox(
      height: _isMobile ? kDepartmentPhoneControlHeight.sp : null,
      child: customButton(
        title: s.reportingAndAudit,
        function: _openReporting,
        wrapContent: true,
        color: AppColors.primary,
        textStyle: (_isMobile
                ? StyleText.fontSize14Weight500
                : StyleText.fontSize16Weight400)
            .copyWith(color: AppColors.textButton),
      ),
    );

    if (_isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          counters,
          SizedBox(height: 10.h),
          Align(alignment: AlignmentDirectional.centerEnd, child: reporting),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: counters),
        SizedBox(width: 10.sp),
        reporting,
      ],
    );
  }

  Widget _viewSwitch(DepartmentDashboardState st) {
    final S s = S.of(context);
    final Widget tabs = CustomSegmentedTabs(
      tabs: [s.table, s.analytics],
      selectedIndex: st.view == DepartmentView.table ? 0 : 1,
      onTabSelected: (i) =>
          _cubit.setView(i == 0 ? DepartmentView.table : DepartmentView.analytics),
      containerColor: AppColors.card,
      unselectedColor: AppColors.card,
      selectedColor: AppColors.primary,
      selectedTextColor: AppColors.textButton,
      unselectedTextColor: AppColors.secondaryText,
      containerPadding: EdgeInsets.all(_isMobile ? 4.sp : 6.sp),
      tabHorizontalPadding: 16.sp,
      // Phone: fits 33.sp — 4 + 4 container padding, ~18 for the label.
      tabVerticalPadding: _isMobile
          ? ((kDepartmentPhoneControlHeight.sp - 8.sp - 18.sp) / 2)
              .clamp(0, 10)
              .toDouble()
          : 6.sp,
      spacing: 14.sp,
      textStyle: _isMobile
          ? StyleText.fontSize14Weight400
          : StyleText.fontSize16Weight400,
    );
    if (!_isMobile) return tabs;
    return SizedBox(height: kDepartmentPhoneControlHeight.sp, child: tabs);
  }

  Widget _toolbar(DepartmentDashboardState st, DepartmentDashboardData d) {
    final bool filtered = st.statusFilter != null;
    return Row(
      children: [
        AppSearchTextField(
          controller: _search,
          hintText: S.of(context).search,
          onChanged: _cubit.setSearch,
        ),
        SizedBox(width: 15.sp),
        customButtonWithSvg(
          title: '',
          function: () => _openStatusFilter(st),
          textStyle: StyleText.fontSize14Weight400,
          color: filtered ? AppColors.primary : AppColors.card,
          image: AppAssets.filter,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: AppColors.transparent,
          svgColor: filtered ? AppColors.textButton : AppColors.secondaryText,
        ),
        SizedBox(width: 15.sp),
        customButtonWithSvg(
          title: '',
          function: () => _export(st, d),
          textStyle: StyleText.fontSize14Weight400,
          color: AppColors.primary,
          image: AppAssets.export,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        ),
      ],
    );
  }

  /// Phone: the tables become cards (the whole tab scrolls there).
  Widget _phoneCards(DepartmentDashboardState st, DepartmentDashboardData d) {
    if (st.tab == DepartmentListTab.policies) {
      final rows = _policies(st, d);
      if (rows.isEmpty) return const CustomEmptyState();
      return DepartmentPolicyCards(
        policies: rows,
        data: d,
        department: st.department,
        onPolicyTap: (p) async {
          await openGrcPolicy(context, p, widget.module);
          if (mounted) _cubit.load();
        },
      );
    }
    final rows = _controls(st, d);
    if (rows.isEmpty) return const CustomEmptyState();
    return DepartmentControlCards(controls: rows);
  }

  Widget _table(DepartmentDashboardState st, DepartmentDashboardData d) {
    if (st.tab == DepartmentListTab.policies) {
      final rows = _policies(st, d);
      if (rows.isEmpty) return const Center(child: CustomEmptyState());
      return DepartmentPoliciesTable(
        policies: rows,
        data: d,
        department: st.department,
        onPolicyTap: (p) async {
          await openGrcPolicy(context, p, widget.module);
          if (mounted) _cubit.load();
        },
      );
    }
    final rows = _controls(st, d);
    if (rows.isEmpty) return const Center(child: CustomEmptyState());
    return DepartmentControlsTable(controls: rows);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Status filter dialog
// ─────────────────────────────────────────────────────────────────────────

/// Resolves to the chosen status value, `''` for "clear", null if dismissed.
class _StatusFilterDialog extends StatefulWidget {
  final List<String> statuses;
  final String? initial;

  const _StatusFilterDialog({required this.statuses, required this.initial});

  @override
  State<_StatusFilterDialog> createState() => _StatusFilterDialogState();
}

class _StatusFilterDialogState extends State<_StatusFilterDialog> {
  late String? _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 24.sp),
      shape: RoundedRectangleBorder(borderRadius: CardStyles.radius()),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.sp),
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.filter,
                style:
                    StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
              ),
              SizedBox(height: 20.h),
              CustomDropdown<String>(
                label: s.status,
                hint: s.all,
                value: _value,
                items: [
                  for (final v in widget.statuses)
                    DropdownItem<String>(value: v, label: grcTr(context, v)),
                ],
                onChanged: (v) => setState(() => _value = v),
              ),
              SizedBox(height: 25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  customButton(
                    title: s.reset,
                    function: () => Navigator.of(context).pop(''),
                    width: 120.sp,
                    // GRC bug report p31: secondary-button style, same as
                    // Discard (darkGrey / white), not the field colour.
                    color: AppColors.darkGrey,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.white),
                  ),
                  SizedBox(width: 10.sp),
                  customButton(
                    title: s.apply,
                    function: () => Navigator.of(context).pop(_value ?? ''),
                    width: 120.sp,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
