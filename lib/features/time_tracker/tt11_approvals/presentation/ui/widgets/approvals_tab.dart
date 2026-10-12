/// Module: time_tracker / tt11_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_tab.dart
/// Purpose: Declares `ApprovalsTab` — the "Approvals" tab: status counters,
///          Search · Filter · Employees selector, then the approval cards.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:83996` (+ Filter `661:93425`, Employees `661:93462`).
/// Counters All · Approved · Pending · Rejected · Canceled (no Under Review
/// counter — a cancellation under review counts as Pending). The tab needs
/// `View_Approvals`; it lists the requests that involve the viewer as an
/// approver (`ApprovalInbox`: direct manager; HR in scope once the request
/// reached HR; approved ones for `Cancel_Request_After_Approving`). The
/// cards' Reject / Approve need `Approve_And_Reject` and the current step.
/// Sections slide in; LOW haptics on the toolbar.
/// Updated: 9/10/2026 - UI fix round 1: icon-only Filter, centred search
/// (`time_tracker_controls`); the Employees picker opens at the Figma width
/// (615, `661:93462`).
/// Updated: 9/10/2026 - UI quality pass (owner 13:45 #3): the Filter holds
/// Request Type · Status · From – To + Department (All Departments approvers
/// only) → Employee; the separate Employees button is gone. Cards hug
/// their content (`TtCardGrid`).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/tt11_approvals/presentation/ui/widgets/approval_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/pages/request_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_filter_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ApprovalsTab extends StatefulWidget {
  const ApprovalsTab({super.key});

  /// The Approvals counters (Figma: no Under Review).
  static const List<RequestBucket> buckets = <RequestBucket>[
    RequestBucket.all,
    RequestBucket.approved,
    RequestBucket.pending,
    RequestBucket.rejected,
    RequestBucket.canceled,
  ];

  @override
  State<ApprovalsTab> createState() => _ApprovalsTabState();
}

class _ApprovalsTabState extends State<ApprovalsTab> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.text = context.read<RequestsCubit>().state.approvals.query;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestsCubit, RequestsState>(
      builder: (BuildContext context, RequestsState state) {
        final RequestsCubit cubit = context.read<RequestsCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SlideInContent(
              child: KeyedSubtree(
                key: const ValueKey<String>('approvalsCounters'),
                child: RequestStatusCounters(
                  buckets: ApprovalsTab.buckets,
                  counts: state.approvalCounts,
                  selected: state.approvals.bucket,
                  onSelected: (RequestBucket b) => cubit.setBucket(RequestScope.approvals, b),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            SlideInContent(delay: const Duration(milliseconds: 60), child: _toolbar(state)),
            SizedBox(height: 15.h),
            SlideInContent(delay: const Duration(milliseconds: 120), child: _body(state)),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _toolbar(RequestsState state) {
    final RequestsCubit cubit = context.read<RequestsCubit>();
    final bool allDepartments = GetIt.instance<TimeTrackerAccess>().showApprovalsDepartmentFilter;
    final List<TimeTrackerEmployee> people = state.approvalRequesters;
    final Set<String> usedDepartments = <String>{for (final TimeTrackerEmployee e in people) e.departmentId};
    return Row(
      children: <Widget>[
        TtSearchField(
          controller: _search,
          onChanged: (String q) => cubit.search(RequestScope.approvals, q),
        ),
        SizedBox(width: 15.w),
        // UI quality pass (owner 13:45 #3): Department (scope rules) and
        // Employee live in the Filter — no separate Employees button.
        TtFilterButton(
          key: const ValueKey<String>('approvalsFilterButton'),
          active: state.approvals.filter.isActive || state.approvals.employeeEmail.isNotEmpty,
          onTap: () async {
            final RequestFilter? picked = await CustomDialogManager.showContent<RequestFilter>(
              context: context,
              width: 520,
              child: RequestFilterDialog(
                initial: state.approvals.employeeEmail.isEmpty
                    ? state.approvals.filter
                    : RequestFilter(
                        kind: state.approvals.filter.kind,
                        requestTypeId: state.approvals.filter.requestTypeId,
                        status: state.approvals.filter.status,
                        from: state.approvals.filter.from,
                        to: state.approvals.filter.to,
                        departmentId: state.approvals.filter.departmentId,
                        employeeEmail: state.approvals.employeeEmail,
                      ),
                types: state.types,
                departments: allDepartments
                    ? <String, String>{
                        for (final MapEntry<String, String> d in state.departments.entries)
                          if (usedDepartments.contains(d.key)) d.key: d.value,
                      }
                    : null,
                employees: people,
              ),
            );
            if (picked == null) return;
            cubit.setEmployee('');
            cubit.setFilter(RequestScope.approvals, picked);
          },
        ),
      ],
    );
  }

  Widget _body(RequestsState state) {
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
    final List<TimeTrackerRequest> rows = state.visibleApprovals;
    if (rows.isEmpty) return const CustomEmptyState(key: ValueKey<String>('approvalsEmpty'));
    // UI quality pass (9/10/2026): cards hug their content (`TtCardGrid`).
    return TtCardGrid(
      key: const ValueKey<String>('approvalsGrid'),
      children: <Widget>[
        for (final TimeTrackerRequest r in rows)
          ApprovalCard(
            request: r,
            state: state,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => RequestDetailsPage(requestId: r.id, asApprover: true),
              ),
            ),
          ),
      ],
    );
  }
}
