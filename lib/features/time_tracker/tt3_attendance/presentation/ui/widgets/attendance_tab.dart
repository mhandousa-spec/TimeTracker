/// Module: time_tracker / tt3_attendance / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_tab.dart
/// Purpose: Declares `AttendanceTab` — the "Attendance" tab: status tiles ·
///          Search · Filter · Export · + Transaction · the attendance table
///          (cards on phone).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:14182`. Permission gates (FINAL SPEC §1 section 3): the tab
/// itself needs `View_Attendance`; Export needs `Export_Attendance`;
/// + Transaction needs `Request_Transaction` (switch OFF → button hidden).
/// Tiles are the core `AttendanceTilesCard` (two rows per card, three
/// cards). Toolbar: `TtSearchField` (core search, self-Expanded),
/// `TtFilterButton`, `TtExportButton`, `customButtonWithSvg`.
/// The table resizes with `AnimatedSizeWrap`; sections slide in.
/// Updated: 9/10/2026 - UI fix round 1: Filter and Export are ICON-ONLY
/// (Figma iPad portrait `661:19747`: white Tuning square, yellow tray-arrow
/// square) and the search text is centred — `TtSearchField`,
/// `TtFilterButton`, `TtExportButton` (finding 3, 4).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/30-custom_attendance_tiles_card.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/ui/widgets/attendance_filter_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/ui/widgets/attendance_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/ui/pages/transaction_form_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  final TextEditingController _search = TextEditingController();

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final AttendanceCubit cubit = context.read<AttendanceCubit>();
    final AttendanceFilter? picked =
        await CustomDialogManager.showContent<AttendanceFilter>(
      context: context,
      width: 650,
      child: AttendanceFilterDialog(initial: cubit.state.filter),
    );
    if (picked == null) return;
    picked.isActive ? cubit.applyFilter(picked) : cubit.resetFilter();
  }

  Future<void> _export(List<AttendanceDay> rows) async {
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
      defaultFileName: s.timeTrackerAttendanceExportName,
      header: AttendanceRowText.headers(context),
      rows: <List<String>>[
        for (int i = 0; i < rows.length; i++)
          <String>['${i + 1}', ...AttendanceRowText.cells(context, rows[i])],
      ],
    );
  }

  void _openTransaction() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const TransactionFormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (BuildContext context, AttendanceState state) {
        final List<AttendanceDay> rows = state.rows(
          (AttendanceDay d) => AttendanceRowText.describe(context, d),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SlideInContent(child: _Tiles(counts: state.tiles)),
            SizedBox(height: 15.h),
            SlideInContent(
              delay: const Duration(milliseconds: 80),
              child: _toolbar(context, state, rows),
            ),
            SizedBox(height: 15.h),
            SlideInContent(
              delay: const Duration(milliseconds: 160),
              child: _body(context, state, rows),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _toolbar(
    BuildContext context,
    AttendanceState state,
    List<AttendanceDay> rows,
  ) {
    final S s = S.of(context);
    final TimeTrackerAccess access = _access;
    return Row(
      children: <Widget>[
        TtSearchField(
          controller: _search,
          onChanged: context.read<AttendanceCubit>().searchChanged,
        ),
        SizedBox(width: 15.w),
        TtFilterButton(
          key: const ValueKey<String>('attendanceFilterButton'),
          active: state.filter.isActive,
          onTap: _openFilter,
        ),
        if (access.canExportAttendance) ...<Widget>[
          SizedBox(width: 15.w),
          TtExportButton(
            key: const ValueKey<String>('attendanceExportButton'),
            onTap: () => _export(rows),
          ),
        ],
        if (access.canRequestTransaction) ...<Widget>[
          SizedBox(width: 15.w),
          // 12/10/2026 (owner R7 / O2): the shared toolbar button.
          TtToolbarButton(
            key: const ValueKey<String>('attendanceTransactionButton'),
            title: s.timeTrackerTransactionButton,
            icon: TtAssets.add,
            onTap: _openTransaction,
          ),
        ],
      ],
    );
  }

  Widget _body(BuildContext context, AttendanceState state, List<AttendanceDay> rows) {
    switch (state.status) {
      case AttendanceLoadStatus.initial:
      case AttendanceLoadStatus.loading:
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
          child: const Center(child: CircleProgressMaster()),
        );
      case AttendanceLoadStatus.failure:
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
          child: Text(
            S.of(context).timeTrackerLoadError,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red),
          ),
        );
      case AttendanceLoadStatus.loaded:
        if (rows.isEmpty) return const CustomEmptyState();
        return context.isPhone
            ? AttendanceCardList(days: rows)
            : AttendanceTableView(days: rows);
    }
  }
}

/// Present · Absent | Late · Vacation | Sick Leave · Excuse Leave.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.counts});

  final AttendanceTileCounts counts;

  AttendanceItem _item(BuildContext context, String label, int value, String icon, Color color) =>
      AttendanceItem(
        label: label,
        count: TimeTrackerFormat.count(context, value).padLeft(2, TimeTrackerFormat.count(context, 0)),
        color: color,
        icon: CustomSvgImage(assetPath: icon, color: color),
      );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AttendanceTilesCard(
      key: const ValueKey<String>('attendanceTiles'),
      itemsPerCard: 2,
      columns: 3,
      items: <AttendanceItem>[
        _item(context, s.timeTrackerPresent, counts.present, ChartSvg.present,
            TimeTrackerFormat.statusColor(AttendanceStatus.present)),
        _item(context, s.timeTrackerAbsent, counts.absent, ChartSvg.absent,
            TimeTrackerFormat.statusColor(AttendanceStatus.absent)),
        _item(context, s.timeTrackerLate, counts.late, ChartSvg.late,
            TimeTrackerFormat.statusColor(AttendanceStatus.late)),
        _item(context, s.timeTrackerVacation, counts.vacation, ChartSvg.vacation,
            TimeTrackerFormat.statusColor(AttendanceStatus.vacation)),
        _item(context, s.timeTrackerSickLeave, counts.sickLeave, ChartSvg.excused,
            TimeTrackerFormat.statusColor(AttendanceStatus.sickLeave)),
        _item(context, s.timeTrackerExcuseLeave, counts.excused, ChartSvg.excused,
            TimeTrackerFormat.statusColor(AttendanceStatus.excused)),
      ],
    );
  }
}
