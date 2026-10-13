/// Module: time_tracker / tt13_vacation_balances / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balances_tab.dart
/// Purpose: Declares `VacationBalancesTab` — the "Vacation Balances" tab:
///          Search · Department · Export · Import, the list / grid toggle,
///          then one card (or table row) per employee: Employee ·
///          Department · Year · Total Days · Used · Remaining, with Edit.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Brief §B (`Vacation_Balance_Permissions`). Not in Figma — built like the
/// Request Types tab (`661:35833` / `661:36293`): same toolbar (icon-only
/// Export, yellow "Import" text button like Locations), core table / grid
/// toggle (Bounce), the module table (zebra, dark header) and cards on the
/// house grid (`CrossAxisCountHelperResponsive`). Gates: Export
/// `Export_Vacation_Balances`, Import `Import_Vacation_Balances`, Edit
/// `Edit_Vacation_Balance` (the yellow Edit on a card; a table row opens
/// the same dialog). The Department dropdown lists the departments that
/// have employees (placeholder "Department", "All" clears). Sections slide
/// in; the table resizes.
/// Updated: 9/10/2026 - owner review: the unselected LIST toggle uses the
/// card colour like the unselected GRID toggle (it used the page colour).
/// Updated: 9/10/2026 - owner review: toolbar dropdowns take the toolbar's
/// one height + corner radius (`TtToolbar` — same as Search / Export / Import).
/// Updated: 9/10/2026 - owner review: card name up to two lines; Edit is a
/// small icon-only square (`TtIconEditButton`) that never cuts the name.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): a YEAR selector (balances
/// are one document per employee per year; the list, Edit, Import and the
/// export follow the selected year). Remaining is computed (Total − Used).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/widgets/vacation_balance_edit_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/widgets/vacation_balance_import_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/widgets/vacation_balance_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class VacationBalancesTab extends StatefulWidget {
  const VacationBalancesTab({super.key});

  @override
  State<VacationBalancesTab> createState() => _VacationBalancesTabState();
}

class _VacationBalancesTabState extends State<VacationBalancesTab> {
  final TextEditingController _search = TextEditingController();

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _export(List<VacationBalanceRow> rows) async {
    final S s = S.of(context);
    if (rows.isEmpty) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: s.export,
        subtitle: s.timeTrackerExportEmpty,
      );
      return;
    }
    await exportTimeTrackerCsv(
      context: context,
      defaultFileName: s.timeTrackerVacationBalancesExportName,
      header: <String>[s.timeTrackerColumnNo, ...VacationBalanceText.headers(context)],
      rows: <List<String>>[
        for (int i = 0; i < rows.length; i++) <String>['${i + 1}', ...VacationBalanceText.exportCells(context, rows[i])],
      ],
    );
  }

  void _edit(VacationBalanceRow row) {
    if (!_access.canEditVacationBalance) return;
    showVacationBalanceEdit(context, row);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacationBalancesCubit, VacationBalancesState>(
      builder: (BuildContext context, VacationBalancesState state) {
        final List<VacationBalanceRow> rows = state.visible;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SlideInContent(child: _toolbar(state, rows)),
            SizedBox(height: 10.h),
            // iPhone rule (owner 9/10/2026): no List / Grid toggle, no table —
            // the phone's second row is Year · Department (full width, so
            // neither the search hint nor a choice is cut).
            SlideInContent(
              delay: const Duration(milliseconds: 60),
              child: context.isPhone
                  ? Row(
                      children: <Widget>[
                        Expanded(child: _yearSelector(state)),
                        SizedBox(width: 10.w),
                        Expanded(child: _departmentFilter(state)),
                      ],
                    )
                  : _viewToggle(state),
            ),
            SizedBox(height: 10.h),
            SlideInContent(
              delay: const Duration(milliseconds: 120),
              child: BounceSwitcher(triggerValue: state.isGrid, child: _body(state, rows)),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _toolbar(VacationBalancesState state, List<VacationBalanceRow> rows) {
    final S s = S.of(context);
    return Row(
      children: <Widget>[
        TtSearchField(controller: _search, onChanged: context.read<VacationBalancesCubit>().search),
        // Phone: Department moves to the Year row under the toolbar.
        if (!context.isPhone) ...<Widget>[
          SizedBox(width: 15.w),
          SizedBox(width: 150.w, child: _departmentFilter(state)),
        ],
        if (_access.canExportVacationBalances) ...<Widget>[
          SizedBox(width: 15.w),
          TtExportButton(key: const ValueKey<String>('vacationExportButton'), onTap: () => _export(rows)),
        ],
        if (_access.canImportVacationBalances) ...<Widget>[
          SizedBox(width: 15.w),
          TtToolbarButton(
            key: const ValueKey<String>('vacationImportButton'),
            title: s.timeTrackerImport,
            icon: TtAssets.import,
            onTap: () => showVacationBalanceImport(context),
          ),
        ],
      ],
    );
  }

  Widget _departmentFilter(VacationBalancesState state) {
    final S s = S.of(context);
    final VacationBalancesCubit cubit = context.read<VacationBalancesCubit>();
    final Map<String, String> departments = state.usedDepartments;
    return CustomDropdown<String>(
      key: const ValueKey<String>('vacationDepartmentFilter'),
      hint: s.timeTrackerDepartment,
      height: TtToolbar.height,
      borderRadius: TtToolbar.radius,
      fillColor: AppColors.card,
      itemStyle: StyleText.fontSize12Weight400,
      value: state.departmentId.isEmpty || !departments.containsKey(state.departmentId) ? null : state.departmentId,
      items: <DropdownItem<String>>[
        DropdownItem<String>(value: '', label: s.timeTrackerAll),
        for (final MapEntry<String, String> d in departments.entries)
          DropdownItem<String>(value: d.key, label: d.value),
      ],
      onChanged: (String v) {
        HapticController.low();
        cubit.setDepartment(v);
      },
    );
  }

  /// 9/10/2026 (data model): the Year selector (one balance per employee
  /// per year) sits at the start of the view-toggle row, so the toolbar
  /// keeps its width on a phone.
  Widget _yearSelector(VacationBalancesState state) {
    final VacationBalancesCubit cubit = context.read<VacationBalancesCubit>();
    return SizedBox(
      width: context.isPhone ? 100.w : 120.w,
      child: CustomDropdown<int>(
        key: const ValueKey<String>('vacationYearFilter'),
        hint: S.of(context).timeTrackerRangeYear,
        height: TtToolbar.height,
        borderRadius: TtToolbar.radius,
        fillColor: AppColors.card,
        itemStyle: StyleText.fontSize12Weight400,
        value: state.year == 0 ? null : state.year,
        items: <DropdownItem<int>>[
          for (final int y in state.years)
            DropdownItem<int>(value: y, label: LocalizedNumber.digits(context, '$y')),
        ],
        onChanged: (int y) {
          HapticController.low();
          cubit.setYear(y);
        },
      ),
    );
  }

  Widget _viewToggle(VacationBalancesState state) {
    final VacationBalancesCubit cubit = context.read<VacationBalancesCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _yearSelector(state),
        const Spacer(),
        KeyedSubtree(
          key: const ValueKey<String>('vacationTableToggle'),
          child: customTableButton(
            function: () => cubit.setGrid(false),
            isSelected: !state.isGrid,
            // Owner (9/10/2026): unselected = the grid button's look.
            color: AppColors.card,
          ),
        ),
        SizedBox(width: 10.w),
        KeyedSubtree(
          key: const ValueKey<String>('vacationGridToggle'),
          child: customGridButton(function: () => cubit.setGrid(true), isSelected: state.isGrid),
        ),
      ],
    );
  }

  Widget _body(VacationBalancesState state, List<VacationBalanceRow> rows) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: const Center(child: CircleProgressMaster()),
      );
    }
    if (state.status == VacationBalancesStatus.failure) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: Text(S.of(context).timeTrackerLoadError,
            textAlign: TextAlign.center, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red)),
      );
    }
    if (rows.isEmpty) return const CustomEmptyState(key: ValueKey<String>('vacationEmpty'));
    final bool canEdit = _access.canEditVacationBalance;
    if (!state.isGrid && !context.isPhone) {
      return TimeTrackerTable(
        key: const ValueKey<String>('vacationTable'),
        columns: VacationBalanceText.columns(context),
        rowKeys: <Key>[for (final VacationBalanceRow r in rows) ValueKey<String>('vacationRow_${r.employee.email}')],
        rows: <List<TtCell>>[
          for (int i = 0; i < rows.length; i++) VacationBalanceText.tableCells(context, i, rows[i]),
        ],
        onRowTap: canEdit ? (int i) => _edit(rows[i]) : null,
      );
    }
    // UI quality pass (9/10/2026): cards hug their content (`TtCardGrid`).
    return TtCardGrid(
      key: const ValueKey<String>('vacationGrid'),
      children: <Widget>[
        for (final VacationBalanceRow r in rows) _VacationCard(row: r, onEdit: canEdit ? () => _edit(r) : null),
      ],
    );
  }
}

/// photo · name · department · title (+ Edit), then Year · Total Days ·
/// Used · Remaining.
class _VacationCard extends StatelessWidget {
  const _VacationCard({required this.row, this.onEdit});

  final VacationBalanceRow row;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final VoidCallback? edit = onEdit;
    final double left = row.balance.remainingDays;
    final String department = row.employee.department(isArabic: ar).trim();
    Widget figure(String label, String value, {Color? color}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label,
                  maxLines: 2,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
              Text(value, style: StyleText.fontSize16Weight500.copyWith(color: color ?? AppColors.text)),
            ],
          ),
        );
    return Container(
      key: ValueKey<String>('vacationCard_${row.employee.email}'),
      padding: EdgeInsetsDirectional.all(12.r),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TimeTrackerAvatar(photo: row.employee.photo, size: 40.r),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Owner (9/10/2026): up to two lines, no "…" for a
                    // normal name; the Edit square never shares its width.
                    Text(row.employee.name(isArabic: ar),
                        key: ValueKey<String>('vacationName_${row.employee.email}'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                    // UI quality pass: no "-" line when there is no
                    // department; a long one wraps (never "…").
                    if (department.isNotEmpty)
                      Text(department,
                          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
              if (edit != null) ...<Widget>[
                SizedBox(width: 8.w),
                TtIconEditButton(
                  key: ValueKey<String>('vacationEdit_${row.employee.email}'),
                  onTap: edit,
                ),
              ],
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              figure(s.timeTrackerRangeYear, LocalizedNumber.digits(context, '${row.balance.year}')),
              figure(s.timeTrackerTotalDays, VacationBalanceText.days(context, row.balance.totalDays)),
              figure(s.timeTrackerUsedDays, VacationBalanceText.days(context, row.balance.usedDays)),
              figure(s.timeTrackerRemainingDays, VacationBalanceText.days(context, left),
                  color: VacationBalanceText.remainingColor(row)),
            ],
          ),
        ],
      ),
    );
  }
}
