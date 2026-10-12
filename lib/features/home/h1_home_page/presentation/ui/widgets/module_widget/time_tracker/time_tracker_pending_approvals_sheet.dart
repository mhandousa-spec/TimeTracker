/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_pending_approvals_sheet.dart
/// Purpose: Declares `showTimeTrackerPendingApprovals` — the dialog the
///          Tracker Approver card's Pending tile opens: the requests whose
///          current step waits for the viewer, each with Reject / Approve.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Time Tracker phase 6 (brief §A: "pending approvals for the viewer with
/// Approve / Reject — same dialogs, reasons"). Nothing is redrawn here: the
/// rows ARE the module's `ApprovalCard` (Figma `661:83996`), whose buttons
/// run the module's own `RequestFlows` (confirm → reason → success, the
/// same permission and scope checks, System Log and notifications), over a
/// `RequestsCubit` + `RequestActionsCubit` from get_it provided inside the
/// dialog. Tapping a card closes the dialog and opens that request's
/// approval details in the module. A decided request leaves the list as
/// soon as the requests stream updates.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/time_tracker/time_tracker_home_card_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt11_approvals/presentation/ui/widgets/approval_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [showTimeTrackerPendingApprovals]
///
/// Purpose: Open the pending-approvals dialog; a tapped card opens its
/// approval details in the module afterwards.
///
/// Parameters:
///   [BuildContext] context
///
/// Return type: [Future<void>]
Future<void> showTimeTrackerPendingApprovals(BuildContext context) async {
  final GetIt sl = GetIt.instance;
  if (!sl.isRegistered<RequestsCubit>() || !sl.isRegistered<RequestActionsCubit>()) return;
  final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final RequestsCubit requests = sl<RequestsCubit>()..init(isArabic: isArabic);
  final RequestActionsCubit actions = sl<RequestActionsCubit>();
  final String? opened = await CustomDialogManager.showContent<String>(
    context: context,
    width: 460,
    // The page background, so the white approval cards stand out as on the
    // Approvals tab.
    backgroundColor: AppColors.background,
    child: MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestsCubit>.value(value: requests),
        BlocProvider<RequestActionsCubit>.value(value: actions),
      ],
      child: const _PendingApprovalsSheet(),
    ),
  );
  await requests.close();
  await actions.close();
  if (opened != null && context.mounted) {
    openTimeTrackerModule(context, requestId: opened, asApproval: true);
  }
}

class _PendingApprovalsSheet extends StatelessWidget {
  const _PendingApprovalsSheet();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<RequestsCubit, RequestsState>(
      builder: (BuildContext context, RequestsState state) {
        final RequestActionsCubit actions = context.read<RequestActionsCubit>();
        final List<TimeTrackerRequest> waiting = state.approvalRequests.where(actions.mayDecide).toList()
          ..sort((TimeTrackerRequest a, TimeTrackerRequest b) => (TimeTrackerHomeStatsRules.waitingSince(a) ?? a.startAt)
              .compareTo(TimeTrackerHomeStatsRules.waitingSince(b) ?? b.startAt));
        return Column(
          key: const ValueKey<String>('timeTrackerPendingApprovalsSheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              s.timeTrackerPendingApprovals,
              style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
            ),
            SizedBox(height: 12.h),
            if (state.isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
              )
            else if (waiting.isEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CustomEmptyState(size: 120),
                  Text(
                    s.timeTrackerNoPendingApprovals,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: waiting.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  // The card fills a fixed cell (it has Expanded / Spacer
                  // rows) — same 340 extent as the Approvals tab grid.
                  itemBuilder: (BuildContext context, int i) => SizedBox(
                    height: 340.h,
                    child: ApprovalCard(
                      request: waiting[i],
                      state: state,
                      onTap: () => Navigator.of(context).pop(waiting[i].id),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
