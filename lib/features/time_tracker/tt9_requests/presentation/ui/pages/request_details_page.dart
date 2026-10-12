/// Module: time_tracker / tt9_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_details_page.dart
/// Purpose: Declares `RequestDetailsPage` — "Tracking Time › Request
///          Details" for the requester (Requests tab) and for an approver
///          (Approvals tab, [RequestDetailsPage.asApprover]).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Inventory §C (requester, every status) and §H2 (approver). Live from
/// `RequestsCubit` (the shared feed), so a decision made here — or by
/// someone else — shows at once. A request the viewer may not see in that
/// role (not theirs / not in their Approvals) reads as "not available", so a
/// deep link from a notification can never reveal someone else's request.
/// Pushed inside the module's nested Navigator (rail / nav bar stay);
/// sections slide in; page padding 15 (core `SideFrameMasterServices`).
/// Updated: 9/10/2026 - code review: the approver's view (also from a
/// notification link) needs `View_Approvals` — `ApprovalInbox.involves`
/// checks it; the approval cycle never shows a `skipped` step.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_comments_section.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_details_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestDetailsPage extends StatelessWidget {
  const RequestDetailsPage({super.key, required this.requestId, this.asApprover = false});

  final String requestId;

  /// Opened from the Approvals tab (approver buttons + Requested by).
  final bool asApprover;

  /// Function Name: [visibleTo]
  ///
  /// Purpose: Whether [request] may be shown in this role.
  ///
  /// Return type: [bool]
  static bool visibleTo(TimeTrackerRequest request, RequestsState state, {required bool asApprover}) =>
      asApprover
          ? ApprovalInbox.involves(request, state.viewer)
          : RequestCycleRules.isRequester(request, state.myEmail);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: s.timeTrackerRequestDetails,
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: BlocBuilder<RequestsCubit, RequestsState>(
          builder: (BuildContext context, RequestsState state) {
            if (state.isLoading) return const Center(child: CircleProgressMaster());
            final TimeTrackerRequest? request = state.byId(requestId);
            if (request == null || !visibleTo(request, state, asApprover: asApprover)) {
              return _NotAvailable(message: s.timeTrackerRequestNotFound);
            }
            return SideFrameScrollableBody(
              child: Column(
                key: ValueKey<String>('requestDetails_${request.id}'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SlideInContent(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 8.h),
                      child: Text(s.timeTrackerRequestDetails,
                          style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
                    ),
                  ),
                  SlideInContent(
                    delay: const Duration(milliseconds: 60),
                    child: RequestDetailsCard(request: request, state: state, asApprover: asApprover),
                  ),
                  SizedBox(height: 20.h),
                  SlideInContent(
                    delay: const Duration(milliseconds: 120),
                    child: RequestCommentsSection(request: request, state: state, asApprover: asApprover),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotAvailable extends StatelessWidget {
  const _NotAvailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey<String>('requestNotAvailable'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CustomEmptyState(),
          SizedBox(height: 12.h),
          Text(message,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}
