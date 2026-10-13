/// Module: time_tracker / tt13_vacation_balances / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_history_page.dart
/// Purpose: Declares `VacationHistoryPage` — "Tracking Time › {Employee}":
///          opened by tapping an employee on Vacation Balances (owner V1):
///          the employee, the year's Total / Used / Remaining (+ Edit), then
///          every vacation request of that year — approved (with the days
///          taken), pending, rejected and cancelled (with the reason) —
///          newest first, with its details.
/// Author: Knowticed Plus team
/// Created at: 13/10/2026 (owner review V1)
///
/// Balance live from `VacationBalancesCubit`; requests from
/// `VacationHistoryCubit` (`watchRequestsOf`); type names / the "deducts
/// from vacation" flag from `RequestsCubit`.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_employee_header_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_state.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_history_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/widgets/vacation_balance_edit_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/ui/widgets/vacation_balance_text.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class VacationHistoryPage extends StatelessWidget {
  const VacationHistoryPage({super.key, required this.employeeEmail});

  final String employeeEmail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VacationHistoryCubit>(
      create: (_) => VacationHistoryCubit(requests: GetIt.instance<RequestBaseRepository>())..watch(employeeEmail),
      child: BlocBuilder<VacationBalancesCubit, VacationBalancesState>(
        builder: (BuildContext context, VacationBalancesState state) {
          VacationBalanceRow? row;
          for (final VacationBalanceRow r in state.rows) {
            if (r.employee.email.trim().toLowerCase() == employeeEmail.trim().toLowerCase()) row = r;
          }
          final VacationBalanceRow? found = row;
          if (found == null) {
            return Scaffold(backgroundColor: AppColors.background, body: const Center(child: CustomEmptyState()));
          }
          return _History(row: found, year: state.year);
        },
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.row, required this.year});

  final VacationBalanceRow row;
  final int year;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final bool canEdit = GetIt.instance<TimeTrackerAccess>().canEditVacationBalance;
    Widget figure(String label, String value, Color color) => Expanded(
          child: Column(
            children: <Widget>[
              Text(value, style: StyleText.fontSize24Weight600.copyWith(color: color)),
              SizedBox(height: 2.h),
              Text(label,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
            ],
          ),
        );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: row.employee.name(isArabic: ar),
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: Column(
            key: ValueKey<String>('vacationHistory_${row.employee.email}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SlideInContent(child: HrEmployeeHeaderCard(employee: row.employee)),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 60),
                child: TtDetailSection(
                  title: '${s.timeTrackerVacationHistory} · ${LocalizedNumber.digits(context, '$year')}',
                  icon: TtAssets.dayCalendar,
                  trailing: canEdit
                      ? TtIconEditButton(
                          key: const ValueKey<String>('vacationHistoryEdit'),
                          onTap: () => showVacationBalanceEdit(context, row),
                        )
                      : null,
                  rows: <Widget>[
                    Row(
                      children: <Widget>[
                        figure(s.timeTrackerTotalDays, VacationBalanceText.days(context, row.balance.totalDays),
                            AppColors.text),
                        figure(s.timeTrackerUsedDays, VacationBalanceText.days(context, row.balance.usedDays),
                            AppColors.orange),
                        figure(s.timeTrackerRemainingDays,
                            VacationBalanceText.days(context, row.balance.remainingDays),
                            VacationBalanceText.remainingColor(row)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              BlocBuilder<VacationHistoryCubit, VacationHistoryState>(
                builder: (BuildContext context, VacationHistoryState h) =>
                    BlocBuilder<RequestsCubit, RequestsState>(
                  builder: (BuildContext context, RequestsState rs) => _list(context, s, h, rs),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, S s, VacationHistoryState h, RequestsState rs) {
    if (h.status == VacationHistoryStatus.loading) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 40.h),
        child: const Center(child: CircleProgressMaster()),
      );
    }
    bool vacation(TimeTrackerRequest r) {
      if (r.isTransaction) return false;
      final RequestType? t = rs.typeOf(r);
      if (t != null) return t.isDeductedFromVacationBalance;
      // Type not loaded: only when days were really taken.
      return (r.deductedVacationDays ?? 0) > 0;
    }

    final List<TimeTrackerRequest> list = <TimeTrackerRequest>[
      for (final TimeTrackerRequest r in h.requests)
        if (vacation(r) && (r.startAt.year == year || r.endAt.year == year)) r,
    ]..sort((TimeTrackerRequest a, TimeTrackerRequest b) => b.startAt.compareTo(a.startAt));
    if (list.isEmpty) {
      return TtFormCard(
        child: Text(s.timeTrackerNoVacationsInYear(LocalizedNumber.digits(context, '$year')),
            key: const ValueKey<String>('vacationHistoryEmpty'),
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(s.timeTrackerVacationRequestsCount(LocalizedNumber.of(context, list.length)),
            style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 10.h),
        for (int i = 0; i < list.length; i++) ...<Widget>[
          SlideInContent(
            delay: Duration(milliseconds: 40 * (i < 6 ? i : 6)),
            child: _VacationItem(request: list[i], state: rs, year: year),
          ),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

/// One vacation request: type + status chip, request date, timeframe,
/// total time, the days taken from the balance (approved), the cancellation
/// / rejection reason, and the description.
class _VacationItem extends StatelessWidget {
  const _VacationItem({required this.request, required this.state, required this.year});

  final TimeTrackerRequest request;
  final RequestsState state;
  final int year;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TimeTrackerRequest r = request;
    final double? taken = r.deductedDaysByYear?[year];
    String rejection = '';
    for (final step in r.approvalSteps) {
      if (step.reason.trim().isNotEmpty && r.status == RequestStatus.rejected) rejection = step.reason.trim();
    }
    final bool canceled = r.status == RequestStatus.canceled || r.status == RequestStatus.canceledByHr;
    return TtFormCard(
      key: ValueKey<String>('vacationHistoryItem_${r.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const RequestIconBox(),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(RequestText.typeName(context, r, state),
                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
              ),
              TtStatusChip(label: RequestText.statusLabel(context, r.status), color: RequestText.statusColor(r.status), small: true),
            ],
          ),
          SizedBox(height: 6.h),
          RequestInfoLine(
            icon: const TtGlyph.svg(TtAssets.calendar),
            label: s.timeTrackerRequestDate,
            value: RequestText.requestDate(context, r),
          ),
          ...RequestCardLines.timeLines(context, r),
          if (r.status == RequestStatus.approved && taken != null)
            RequestInfoLine(
              icon: const TtGlyph.svg(TtAssets.dayTotal),
              label: s.timeTrackerDeductedFromBalance,
              value: VacationBalanceText.days(context, taken),
            ),
          if (canceled && r.cancellationReason.trim().isNotEmpty)
            RequestInfoLine(
              icon: const TtGlyph.svg(TtAssets.status),
              label: s.timeTrackerReasonsOfCancellation,
              value: r.cancellationReason.trim(),
            ),
          if (rejection.isNotEmpty)
            RequestInfoLine(
              icon: const TtGlyph.svg(TtAssets.status),
              label: s.timeTrackerReasonsOfRejection,
              value: rejection,
            ),
          if (r.description.trim().isNotEmpty)
            RequestInfoLine(
              icon: const TtGlyph.svg(TtAssets.description),
              label: s.timeTrackerDescription,
              value: r.description.trim(),
            ),
        ],
      ),
    );
  }
}
