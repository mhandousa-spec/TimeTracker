/// Module: GRC — Action Center
///
///*************************** FILE INFO ****************************///
/// File Name: grc_action_center_page.dart
/// Purpose: "Action Center" (Figma MAGDY → "MAIN PAGE : Creating , Editing ,
///          Deleting Module", frames Action Center / — Errors /
///          — Recommendations / — Expired), opened from the GRC root page.
///            * Tabs: All Issues | Errors | Recommendations | Expired
///            * All Issues: Total / Errors / Recommendations summary, an
///              Errors | Recommendations switch, and the table without Action.
///            * Other tabs: department picker and the table with a Fix
///              button (Expired has no Fix).
///            * Search, module filter and CSV export on every tab.
///          Fix / the policy link open the policy details page (or the
///          module page for module-level issues); the list reloads on return.
/// Author: Amr Mesbah
/// Created: 17/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/action_center/domain/entities/grc_action_issue.dart';
import 'package:knowticed_plus/features/grc/action_center/presentation/controller/grc_action_center_cubit.dart';
import 'package:knowticed_plus/features/grc/action_center/presentation/ui/widgets/grc_action_center_table.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/pages/grc_module_details_page.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_details_page.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_export.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Strings the ARB files do not have yet.
String _tr(BuildContext context, String en, String ar) =>
    context.isArabic ? ar : en;

/// Value of the picker's "All Departments" row.
const String _allDepartments = '__all__';

class GrcActionCenterPage extends StatelessWidget {
  const GrcActionCenterPage({super.key});

  static Route<void> route() => PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GrcActionCenterPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcActionCenterCubit>(
      create: (_) => GrcActionCenterCubit.create()..load(),
      child: const _GrcActionCenterBody(),
    );
  }
}

class _GrcActionCenterBody extends StatefulWidget {
  const _GrcActionCenterBody();

  @override
  State<_GrcActionCenterBody> createState() => _GrcActionCenterBodyState();
}

class _GrcActionCenterBodyState extends State<_GrcActionCenterBody> {
  final TextEditingController _search = TextEditingController();

  GrcActionCenterCubit get _cubit => context.read<GrcActionCenterCubit>();

  bool get _isMobile => screenSizeOf(context) == ScreenSize.mobile;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── labels ─────────────────────────────────────────────────────────────

  String _errorsLabel() => _tr(context, 'Errors', 'الأخطاء');
  String _recsLabel() => _tr(context, 'Recommendations', 'التوصيات');

  List<String> _tabLabels() => [
        _tr(context, 'All Issues', 'جميع المشكلات'),
        _errorsLabel(),
        _recsLabel(),
        S.of(context).expired,
      ];

  List<String> _headers({required bool withAction}) {
    final s = S.of(context);
    return [
      s.no,
      s.module,
      s.policy,
      s.control,
      _tr(context, 'Issue', 'المشكلة'),
      if (withAction) _tr(context, 'Action', 'الإجراء'),
    ];
  }

  // ── navigation ─────────────────────────────────────────────────────────

  /// Opens where [issue] can be fixed, then reloads. The cubit is captured
  /// first: dialogs in those pages open on the root navigator, which can
  /// leave this context reporting unmounted when the push returns.
  Future<void> _open(GrcActionIssue issue) async {
    final cubit = _cubit;
    final policy = issue.policy;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => policy == null
            ? GrcModuleDetailsPage(module: issue.module)
            : PolicyDetailsPage(
                policyId: policy.id,
                moduleId: issue.module.moduleId,
                module: issue.module,
              ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    await cubit.load();
  }

  // ── export ─────────────────────────────────────────────────────────────

  Future<void> _export(GrcActionCenterState st) async {
    final rows = st.visible;
    final s = S.of(context);
    if (rows.isEmpty) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
        title: s.noData,
        subtitle: _tr(context, 'There are no issues to export.',
            'لا توجد مشكلات للتصدير.'),
      );
      return;
    }
    final bool ar = context.isArabic;
    await exportGrcCsv(
      context: context,
      defaultFileName: 'grc_action_center',
      header: _headers(withAction: false),
      rows: [
        for (var i = 0; i < rows.length; i++)
          [
            i + 1,
            rows[i].moduleName(isArabic: ar),
            rows[i].policyName(isArabic: ar),
            rows[i].controlName(isArabic: ar),
            rows[i].message(isArabic: ar),
          ],
      ],
    );
  }

  // ── build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SideFrameMasterServices(
      titleText: s.grc,
      onFirstTap: () => Navigator.of(context).maybePop(),
      secondTitle: _tr(context, 'Action Center', 'مركز الإجراءات'),
      child: SideFrameScrollableBody(
        child: BlocBuilder<GrcActionCenterCubit, GrcActionCenterState>(
          builder: (context, st) {
            switch (st.status) {
              case GrcActionCenterStatus.initial:
              case GrcActionCenterStatus.loading:
                if (st.issues.isEmpty) {
                  return SizedBox(
                    height: 300.sp,
                    child: const Center(child: CircleProgressMaster()),
                  );
                }
              case GrcActionCenterStatus.failure:
                return _failure(st.message);
              case GrcActionCenterStatus.loaded:
                break;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTabs(
                  tabs: _tabLabels(),
                  selectedValue: st.tab.index,
                  onChanged: (i) =>
                      _cubit.setTab(GrcActionCenterTab.values[i]),
                ),
                SizedBox(height: 20.h),
                if (st.tab == GrcActionCenterTab.allIssues) ...[
                  _summary(st),
                  SizedBox(height: 20.h),
                  _kindSwitch(st),
                ] else
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _departmentPicker(st),
                  ),
                SizedBox(height: 16.h),
                _toolbar(st),
                SizedBox(height: 10.h),
                _table(st),
                SizedBox(height: 30.h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _failure(String? message) {
    final s = S.of(context);
    return SizedBox(
      height: 300.sp,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? s.noData,
              textAlign: TextAlign.center,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
            ),
            SizedBox(height: 16.h),
            TextButton(onPressed: _cubit.load, child: Text(s.retry)),
          ],
        ),
      ),
    );
  }

  /// Total Issues 42 | Errors 6 | Recommendations 36
  Widget _summary(GrcActionCenterState st) {
    Widget card(String label, int value, Color color) => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: CardStyles.radius(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: (_isMobile
                        ? StyleText.fontSize14Weight400
                        : StyleText.fontSize18Weight400)
                    .copyWith(color: AppColors.secondaryText),
              ),
              SizedBox(width: 20.sp),
              Text(
                LocalizedNumber.digits(context, '$value'),
                style: (_isMobile
                        ? StyleText.fontSize14Weight500
                        : StyleText.fontSize18Weight500)
                    .copyWith(color: color),
              ),
            ],
          ),
        );

    return Wrap(
      spacing: 15.sp,
      runSpacing: 10.sp,
      children: [
        card(_tr(context, 'Total Issues', 'إجمالي المشكلات'), st.totalCount,
            AppColors.text),
        card(_errorsLabel(), st.errorCount, AppColors.red),
        card(_recsLabel(), st.recommendationCount, kGrcRecommendationColor),
      ],
    );
  }

  /// [14] Errors   [7] Recommendations
  Widget _kindSwitch(GrcActionCenterState st) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 30.sp,
        children: [
          FilterBarItem(
            title: _errorsLabel(),
            numberOfItems: st.errorCount,
            color: AppColors.text,
            isSelected: st.allIssuesKind != GrcIssueKind.recommendation,
            onTap: () => _cubit.setAllIssuesKind(GrcIssueKind.error),
          ),
          FilterBarItem(
            title: _recsLabel(),
            numberOfItems: st.recommendationCount,
            color: AppColors.text,
            isSelected: st.allIssuesKind == GrcIssueKind.recommendation,
            onTap: () =>
                _cubit.setAllIssuesKind(GrcIssueKind.recommendation),
          ),
        ],
      ),
    );
  }

  Widget _departmentPicker(GrcActionCenterState st) {
    return SizedBox(
      width: (_isMobile ? 150 : 170).w,
      child: CustomDropdown<String>(
        value: st.department ?? _allDepartments,
        height: _isMobile ? 33 : 38,
        fillColor: AppColors.card,
        items: [
          DropdownItem<String>(
            value: _allDepartments,
            label: _tr(context, 'All Departments', 'جميع الإدارات'),
          ),
          for (final d in st.departments)
            DropdownItem<String>(value: d, label: grcTr(context, d)),
        ],
        onChanged: (v) =>
            _cubit.setDepartment(v == _allDepartments ? null : v),
      ),
    );
  }

  /// Search | module filter | export
  Widget _toolbar(GrcActionCenterState st) {
    final s = S.of(context);
    final bool ar = context.isArabic;

    // Modules that have at least one issue, by id.
    final modules = <String, String>{
      for (final i in st.issues) i.module.moduleId: i.moduleName(isArabic: ar),
    };

    return Row(
      children: [
        AppSearchTextField(
          controller: _search,
          hintText: s.search,
          onChanged: _cubit.setSearch,
        ),
        SizedBox(width: 15.sp),
        CustomSortButton<String>(
          value: st.moduleId,
          items: modules.keys.toList(),
          labelBuilder: (id) => modules[id] ?? id,
          onChanged: _cubit.setModule,
          title: s.filter,
          showTitle: false,
          svgPath: AppAssets.filter,
        ),
        SizedBox(width: 15.sp),
        customButtonWithSvg(
          title: '',
          function: () => _export(st),
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

  Widget _table(GrcActionCenterState st) {
    final rows = st.visible;
    if (rows.isEmpty) return const CustomEmptyState();
    final bool withAction = st.tab == GrcActionCenterTab.errors ||
        st.tab == GrcActionCenterTab.recommendations;
    final bool linkPolicy = st.tab != GrcActionCenterTab.allIssues;
    return GrcActionCenterTable(
      issues: rows,
      isArabic: context.isArabic,
      headers: _headers(withAction: withAction),
      fixLabel: _tr(context, 'Fix', 'إصلاح'),
      onFix: withAction ? _open : null,
      onOpenPolicy: linkPolicy ? _open : null,
    );
  }
}
