/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: requests_tab.dart
/// Purpose: Declares `RequestsTab` — the employee's "Requests" tab: status
///          counters, Search · Filter · Export · + Request, the card / table
///          toggle, then their requests and transactions.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:14909` (cards) / `661:14645` (table: No · Request Date ·
/// Request Type · Start Date · End Date · Total Time · Status). Counters All
/// · Approved · Pending · Rejected · Under Review · Canceled (Canceled By HR
/// counted as Canceled). Gates: the tab `View_Time_Tracker_Requests`;
/// Export `Export_Time_Tracker_Requests` (CSV, like phase 2); + Request
/// `Create_Time_Tracker_Request`. Transactions are listed too. List ↔ grid
/// bounces; sections slide in; the table resizes; header fixed, list
/// scrolls with the page.
/// Updated: 9/10/2026 - UI fix round 1: icon-only Filter / Export (Figma
/// iPad portrait `661:75715`) and the centred search (`time_tracker_controls`).
/// Updated: 9/10/2026 - owner review: the unselected LIST toggle uses the
/// card colour like the unselected GRID toggle (it used the page colour).
/// Updated: 9/10/2026 - UI quality pass: cards hug their content
/// (`TtCardGrid`); iPhone = cards only (no table, no List / Grid toggle).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/ui/pages/request_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/pages/request_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_filter_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  final TextEditingController _search = TextEditingController();

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void initState() {
    super.initState();
    _search.text = context.read<RequestsCubit>().state.mine.query;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget page) =>
      Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));

  Future<void> _export(RequestsState state, List<TimeTrackerRequest> rows) async {
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
      defaultFileName: s.timeTrackerRequestsExportName,
      header: <String>[s.timeTrackerColumnNo, ...RequestText.headers(context)],
      rows: <List<String>>[
        for (int i = 0; i < rows.length; i++)
          <String>['${i + 1}', ...RequestText.cells(context, rows[i], state)],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestsCubit, RequestsState>(
      builder: (BuildContext context, RequestsState state) {
        final List<TimeTrackerRequest> rows = state.visibleMine;
        final RequestsCubit cubit = context.read<RequestsCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SlideInContent(
              child: KeyedSubtree(
                key: const ValueKey<String>('requestsCounters'),
                child: RequestStatusCounters(
                  buckets: RequestBucket.values,
                  counts: state.myCounts,
                  selected: state.mine.bucket,
                  onSelected: (RequestBucket b) => cubit.setBucket(RequestScope.mine, b),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            SlideInContent(delay: const Duration(milliseconds: 60), child: _toolbar(state, rows)),
            // iPhone rule (owner 9/10/2026): no List / Grid toggle on a phone.
            if (!context.isPhone) ...<Widget>[
              SizedBox(height: 10.h),
              SlideInContent(delay: const Duration(milliseconds: 90), child: _viewToggle(state)),
            ],
            SizedBox(height: 10.h),
            SlideInContent(
              delay: const Duration(milliseconds: 120),
              child: BounceSwitcher(triggerValue: state.mine.isGrid, child: _body(state, rows)),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _toolbar(RequestsState state, List<TimeTrackerRequest> rows) {
    final S s = S.of(context);
    final RequestsCubit cubit = context.read<RequestsCubit>();
    return Row(
      children: <Widget>[
        TtSearchField(
          controller: _search,
          onChanged: (String q) => cubit.search(RequestScope.mine, q),
        ),
        SizedBox(width: 15.w),
        TtFilterButton(
          key: const ValueKey<String>('requestsFilterButton'),
          active: state.mine.filter.isActive,
          onTap: () async {
            final RequestFilter? picked = await CustomDialogManager.showContent<RequestFilter>(
              context: context,
              width: 460,
              child: RequestFilterDialog(initial: state.mine.filter, types: state.types),
            );
            if (picked != null) cubit.setFilter(RequestScope.mine, picked);
          },
        ),
        if (_access.canExportRequests) ...<Widget>[
          SizedBox(width: 15.w),
          TtExportButton(
            key: const ValueKey<String>('requestsExportButton'),
            onTap: () => _export(state, rows),
          ),
        ],
        if (_access.canCreateRequest) ...<Widget>[
          SizedBox(width: 15.w),
          TtToolbarButton(
            key: const ValueKey<String>('requestsAddButton'),
            title: s.timeTrackerRequestWord,
            icon: AppAssets.add,
            iconSize: 16.r,
            onTap: () => _push(const RequestFormPage()),
          ),
        ],
      ],
    );
  }

  Widget _viewToggle(RequestsState state) {
    final RequestsCubit cubit = context.read<RequestsCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        KeyedSubtree(
          key: const ValueKey<String>('requestsTableToggle'),
          child: customTableButton(
            function: () => cubit.setGrid(RequestScope.mine, false),
            isSelected: !state.mine.isGrid,
            // Owner (9/10/2026): unselected = the grid button's look.
            color: AppColors.card,
          ),
        ),
        SizedBox(width: 10.w),
        KeyedSubtree(
          key: const ValueKey<String>('requestsGridToggle'),
          child: customGridButton(
            function: () => cubit.setGrid(RequestScope.mine, true),
            isSelected: state.mine.isGrid,
          ),
        ),
      ],
    );
  }

  Widget _body(RequestsState state, List<TimeTrackerRequest> rows) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: const Center(child: CircleProgressMaster()),
      );
    }
    if (state.status == RequestsLoadStatus.failure) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: Text(S.of(context).timeTrackerLoadError,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red)),
      );
    }
    if (rows.isEmpty) return const CustomEmptyState(key: ValueKey<String>('requestsEmpty'));
    void open(TimeTrackerRequest r) => _push(RequestDetailsPage(requestId: r.id));
    // iPhone rule (owner 9/10/2026): no tables on a phone — always cards.
    if (!state.mine.isGrid && !context.isPhone) {
      return TimeTrackerTable(
        key: const ValueKey<String>('requestsTable'),
        columns: RequestText.columns(context),
        rowKeys: <Key>[for (final TimeTrackerRequest r in rows) ValueKey<String>('requestRow_${r.id}')],
        rows: <List<TtCell>>[
          for (int i = 0; i < rows.length; i++) RequestText.tableCells(context, i, rows[i], state),
        ],
        onRowTap: (int i) => open(rows[i]),
      );
    }
    // UI quality pass (9/10/2026): cards hug their content (`TtCardGrid`).
    return TtCardGrid(
      key: const ValueKey<String>('requestsGrid'),
      children: <Widget>[
        for (final TimeTrackerRequest r in rows) RequestCard(request: r, state: state, onTap: () => open(r)),
      ],
    );
  }
}
